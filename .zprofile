export EDITOR=nvim

if ! command -v brew >/dev/null 2>&1; then
  export PATH="/opt/homebrew/bin:/home/linuxbrew/.linuxbrew/bin:/usr/local/bin"
  eval "$(brew shellenv)"
fi

export NODE_COMPILE_CACHE=~/.cache/nodejs-compile-cache
export ERL_AFLAGS="-kernel shell_history enabled"
export HOMEBREW_NO_ENV_HINTS=1
export MIX_OS_DEPS_COMPILE_PARTITION_COUNT=4

if [[ -d "$HOME/.bun/bin" ]]; then
  export PATH="$HOME/.bun/bin:$PATH"
fi
