
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
  {
    echo "* Model: \`$LLC_MODEL\`"
    echo "* Server: \`$LLC_SERVER\`"
    echo "* Key File: \`$LLC_KEY_FILE\`"
  } | sd
}

function change-server {
  local _path="${_this_path}servers"
  local chosen

  if [[ -n "$1" ]]; then
    chosen="$1"
  elif [[ ! -e "$path" ]]; then
    read "?Server > " chosen
  else
    chosen="$(echo $(cat "$_path" | fzf) | cut -d ' ' -f 1)"
  fi

  if [[ -n "$chosen" ]]; then
    if [[ "$chosen" != "$LLC_SERVER" ]]; then
      echo "Resetting Key File\n"
      change-key "" ""
      touch "$_path"
      { 
          echo "$chosen"; 
          cat "$_path"; 
      } | sort | uniq > "${_path}.tmp"
      mv "${_path}.tmp" "$_path"
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

  if [[ -n "$1" ]]; then
    chosen="$1"
  else
    chosen="$(llcat -u $LLC_SERVER -m | sort | fzf)"
  fi

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

  if [[ $# -gt 0 ]]; then
    chosen="${1:-/dev/null}"
  else
    read "?Key file > " chosen
  fi

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
    CONV="$1" ursh gh:day50-dev/llcat/examples/conversation.sh -u "$LLC_SERVER" -m "
$LLC_MODEL" -k "$LLC_KEY"
    exit
  fi
  convo="$(mktemp)"
  echo "Conversation: $convo" > /dev/stderr
  llcat -c "$convo" -k "$LLC_KEY" -m "$LLC_MODEL" -u "$LLC_SERVER" "$@" 2> >(jq '.' >&2) | sd
}
