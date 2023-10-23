function _log_big() {
    echo "---"
    echo $1
    echo "---"
}

function _log() {
    echo $1
}

function _error() {
    _log "ERROR: $1"
    exit 1
}

function _ensure_dir() {
    _log "Ensuring directory $1 exists"
    @sudo@ mkdir -p "$1"
}

function _symlink() {
    _log "Symlinking $1 to $2"
    if [ ! -f "$1" ]; then
        _error "$1 does not exist!"
    fi
    @sudo@ ln -sf "$1" "$2"
}

function _remove() {
    _log "Ensuring $1 is removed"
    if [ ! -f "$1" ]; then
        _error "$1 does not exist!"
    fi
    @sudo@ rm -rf "$1"
}

function _diff_to_create() {
    file="$1"

    result=()

    if [ ! -f "$previousGenerationDir/$file" ]; then
      while read -r item; do
        if [[ $item ]]; then
          result+=( "$item" )
        fi
      done <<< "$(cat "$generationDir/$file")"
    else
      while read -r item; do
        if [[ $item ]]; then
          result+=( "$item" )
        fi
      done <<< "$(comm -13 <(sort "$previousGenerationDir/$file") <(sort "$generationDir/$file"))"

    fi

    echo "${result[@]}"
}

function _diff_to_update() {
    file="$1"

    result=()

    if [ -f "$previousGenerationDir/$file" ]; then
      while read -r item; do
        if [[ $item ]]; then
          result+=( "$item" )
        fi
      done <<< "$(comm -12 <(sort "$previousGenerationDir/$file") <(sort "$generationDir/$file"))"
    fi

    echo "${result[@]}"
}

function _diff_to_remove() {
    file="$1"

    result=()

    if [ -f "$previousGenerationDir/$file" ]; then
      while read -r item; do
        if [[ $item ]]; then
          result+=( "$item" )
        fi
      done <<< "$(comm -23 <(sort "$previousGenerationDir/$file") <(sort "$generationDir/$file"))"
    fi

    echo "${result[@]}"
}
