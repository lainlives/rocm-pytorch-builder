mkvenv() {
    if [ -d "$2/.venvs/$1" ]; then
        return 0
    fi
    "python$1" -m ensurepip -U
    "python$1" -m pip install virtualenv
    mkdir -p "$2/.venvs"
    "python$1" -m venv "$2/.venvs/$1"
    source "$2/.venvs/$1/bin/activate"
    pip install build &
}
activatevenv() {
    if [ -f "$2/.venvs/$1/bin/activate" ]; then
        source "$2/.venvs/$1/bin/activate"
    fi
}