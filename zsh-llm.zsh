
_this_file="$0"
_this_path="$(dirname "$_this_file")/llc-"
_secrets="${_this_path}secrets"

if [[ ! -e "$_secrets" ]]; then
  cat > "$_secrets" << ENDL
LLC_MODEL=
LLC_SERVER=
LLC_KEY_FILE=
ENDL
fi

source "$_secrets"

function show-llm {
  if [[ "$1" == "push" ]]; then
    echo "pushing to $2"
    set -x
    scp "$_secrets" "$2:$_secrets"
    ssh "$2" "mkdir -p $(dirname "$LLC_KEY_FILE")"
    scp "$LLC_KEY_FILE" "$2:$LLC_KEY_FILE"
    set +x
  elif [[ "$1" == "pull" ]]; then
    echo "pulling from $2"
    scp "$2:$_secrets" "$_secrets"
  fi
  
  {
    echo "* Model: \`$LLC_MODEL\`"
    echo "* Server: \`$LLC_SERVER\`"
    echo "* Key File: \`$LLC_KEY_FILE\`"
  } | sd
}

function change-server {
  local sfile="${_this_path}servers"
  local chosen

  if [[ -n "$1" ]]; then
    chosen="$1"
  elif [[ ! -e "$sfile" ]]; then
    read "?Server > " chosen
  else
    chosen="$(echo $(cat "$sfile" | fzf) | cut -d ' ' -f 1)"
  fi

  if [[ -n "$chosen" ]]; then
    if [[ "$chosen" != "$LLC_SERVER" ]]; then
      echo "Resetting Key File\n"
      change-key "" ""
      touch "$sfile"
      { 
          echo "$chosen"; 
          cat "$sfile"; 
      } | sort | uniq > "${sfile}.tmp"
      mv "${sfile}.tmp" "$sfile"
      export LLC_SERVER="$chosen"
      sed -i 's|^LLC_SERVER=[^ ]*$|LLC_SERVER='$chosen'|g' "$_secrets"
    fi
  else
    echo "Fine! Server unchanged!\n"
  fi
  show-llm
}

function change-model {
  local chosen

  [[ -n "$1" ]] && chosen="$1" || chosen="$(llcat -u $LLC_SERVER -m | sort | fzf)"

  if [[ -n "$chosen" ]]; then
    export LLC_MODEL="$chosen"
    sed -i 's|^LLC_MODEL=[^ ]*$|LLC_MODEL='$chosen'|g' "$_secrets"
  else
    echo "Fine! Model unchanged!\n"
  fi
  show-llm
}

function change-key {
  local chosen

  [[ $# -gt 0 ]] && chosen="${1:-/dev/null}" || read "?Key file > " chosen

  if [[ -n "$chosen" ]]; then

    if [[ ! -e "$chosen" ]]; then
      echo "\nCan't find that key!\nIt should be a path to file, not a secret.\n"
      return 1
    fi

    export LLC_KEY_FILE="$chosen"
    export LLC_KEY="$(< $LLC_KEY_FILE )"
    sed -i 's|^LLC_KEY_FILE=[^ ]*$|LLC_KEY_FILE='$chosen'|g' "$_secrets"
  else
    echo "Fine! Key unchanged!\n"
  fi
  [[ $# -lt 2 ]] && show-llm
}

function llc() {
  [[ -n "$LLC_KEY_FILE" ]] && LLC_KEY="$(< $LLC_KEY_FILE )" || LLC_KEY="any"
  llcat -k "$LLC_KEY" -m "$LLC_MODEL" -u "$LLC_SERVER" "$@"
}

function llm() {
  [[ -n "$LLC_KEY_FILE" ]] && LLC_KEY="$(< $LLC_KEY_FILE )" || LLC_KEY="any"
  if [[ -r "$1" ]]; then
    CONV="$1" ursh gh:day50-dev/llcat/examples/conversation.sh -u "$LLC_SERVER" -m "$LLC_MODEL" -k "$LLC_KEY"
    exit
  fi
  convo="$(mktemp)"
  echo "Conversation: $convo" > /dev/stderr
  llcat -c "$convo" -k "$LLC_KEY" -m "$LLC_MODEL" -u "$LLC_SERVER" "$@" 2> >(jq '.' >&2) | sd
}
