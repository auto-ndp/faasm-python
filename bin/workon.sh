#!/bin/bash

# ----------------------------
# Container-specific settings
# ----------------------------

MODE="undetected"
if [[ -z "$CPP_DOCKER" ]]; then

    THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
    if [ "$(ps -o comm= -p $$)" = "zsh" ]; then
        THIS_DIR="$( cd "$( dirname "${ZSH_ARGZERO}" )" >/dev/null 2>&1 && pwd )"
    fi
    PROJ_ROOT="${THIS_DIR}/.."

    # Normal terminal
    MODE="terminal"
else
    # Running inside the container, we know the project root
    PROJ_ROOT="/code/python"

    # Use containerised redis
    alias redis-cli="redis-cli -h redis"

    MODE="container"
fi

pushd ${PROJ_ROOT}>>/dev/null

# ----------------------------
# Virtualenv
# ----------------------------

if [ ! -d "venv" ]; then
    python3 -m venv venv
    (
        source venv/bin/activate
        pip install -U pip
        pip install -U setuptools
        pip install -U wheel
        pip install -r requirements.txt
        pip install third-party/cpp/
    )
fi

export VIRTUAL_ENV_DISABLE_PROMPT=1
source venv/bin/activate

# ----------------------------
# Invoke tab-completion
# (http://docs.pyinvoke.org/en/stable/invoke.html#shell-tab-completion)
# ----------------------------

_complete_invoke() {
    local candidates
    candidates=`invoke --complete -- ${COMP_WORDS[*]}`
    COMPREPLY=( $(compgen -W "${candidates}" -- $2) )
}

# If running from zsh, run autoload for tab completion
if [ "$(ps -o comm= -p $$)" = "zsh" ]; then
    autoload bashcompinit
    bashcompinit
fi
complete -F _complete_invoke -o default invoke inv

# ----------------------------
# Environment vars
# ----------------------------

VERSION_FILE=${PROJ_ROOT}/VERSION
export CPP_ROOT=${PROJ_ROOT}/third-party/cpp
export CPP_VERSION=$(cat ${CPP_ROOT}/VERSION)
export PYTHON_ROOT=${PROJ_ROOT}
export PYTHON_VERSION=$(cat ${VERSION_FILE})

export PS1="(python) $PS1"

# -----------------------------
# Splash
# -----------------------------

echo ""
echo "----------------------------------"
echo "Python CLI"
echo "Version: ${PYTHON_VERSION}"
echo "Project root: ${PYTHON_ROOT}"
echo "Mode: ${MODE}"
echo "----------------------------------"
echo ""

popd >> /dev/null
