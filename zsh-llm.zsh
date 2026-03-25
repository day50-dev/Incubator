
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
  local path="${_this_path}servers"

  if [[ -n "$1" ]]; then
    chosen="$1"
  elif [[ ! -e "$path" ]]; then
    read -p "Server> " chosen
  else
    chosen="$(echo $(cat "$path" | fzf) | cut -d ' ' -f 1)"
  fi

  if [[ -n "$chosen" ]]; then
    echo "Setting to $chosen"
    export LLC_SERVER="$chosen"
    sed -i 's|^LLC_SERVER=[^ ]*$|LLC_SERVER='$chosen'|g' "$_secrets"
    touch "$path"
    { echo "$chosen"; cat "$path"; } | sort | uniq > "${path}.tmp"
    mv "${path}.tmp" "$path"
  fi
}

function change-model {
  if [[ -n "$1" ]]; then
    chosen="$1"
  else
    chosen="$(llcat -u $LLC_SERVER -m | sort | fzf)"
  fi

  if [[ -n "$chosen" ]]; then
    echo "Setting to $chosen"
    export LLC_MODEL="$chosen"
    sed -i 's|^LLC_MODEL=[^ ]*$|LLC_MODEL='$chosen'|g' "$_secrets"
  fi
}

function change-key {
  chosen="$1"
  echo "Setting to $chosen"
  export LLC_KEY_FILE="$chosen"
  export LLC_KEY="$(< $LLC_KEY_FILE )"
  sed -i 's|^LLC_KEY_FILE=[^ ]*$|LLC_KEY_FILE='$chosen'|g' "$_secrets"
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
  llcat -c $convo -k "$LLC_KEY" -m "$LLC_MODEL" -u "$LLC_SERVER" "$@" 2> >(jq '.' >&2) | sd
}
