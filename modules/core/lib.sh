function _log_big() {
    echo "---"
    echo $1
    echo "---"
}

function _log() {
    echo $1
}

function _ensure_dir() {
    echo "Ensuring directory $1 exists"
    @sudo@ mkdir -p "$1"
}
