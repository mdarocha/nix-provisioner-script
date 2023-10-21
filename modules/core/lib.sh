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
