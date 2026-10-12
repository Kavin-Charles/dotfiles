#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# opencode
export PATH=/home/kavin/.opencode/bin:$PATH

# Load the line editor before configuring completion and the prompt.
if [[ ! ${BLE_VERSION-} && -t 0 && -t 1 && -r "$HOME/.local/share/blesh/ble.sh" ]]; then
    source -- "$HOME/.local/share/blesh/ble.sh" --attach=none
fi

# Git's installed completion supports commands, branches, paths and options.
if [[ -r /usr/share/git/completion/git-completion.bash ]]; then
    source /usr/share/git/completion/git-completion.bash
fi

alias g='git'
alias gs='git status --short --branch'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --graph --decorate --oneline --all'
alias ga='git add'
alias gc='git commit'
alias gsw='git switch'
alias gf='git fetch'
alias gpl='git pull --ff-only'

if declare -F __git_complete >/dev/null; then
    __git_complete g __git_main
    __git_complete gs _git_status
    __git_complete gd _git_diff
    __git_complete gds _git_diff
    __git_complete gl _git_log
    __git_complete ga _git_add
    __git_complete gc _git_commit
    __git_complete gsw _git_switch
    __git_complete gf _git_fetch
    __git_complete gpl _git_pull
fi

# Purple search windows and completion, using ble.sh's compatible bindings.
if command -v fzf >/dev/null; then
    [[ ! -r "$HOME/.config/fzf/config.sh" ]] || source "$HOME/.config/fzf/config.sh"
    if [[ ${BLE_VERSION-} ]]; then
        ble-import -d integration/fzf-completion
        ble-import -d integration/fzf-key-bindings
    elif [[ ! ${_OBSIDIAN_FZF_INITIALIZED-} ]]; then
        eval "$(fzf --bash)"
        _OBSIDIAN_FZF_INITIALIZED=1
    fi
fi

# Single-line Obsidian Purple prompt; initialize only once per shell.
# Keep existing hooks after Starship so Ghostty can mark the finished prompt.
if command -v starship >/dev/null; then
    if [[ ${BLE_VERSION-} ]]; then
        if [[ ! ${_OBSIDIAN_STARSHIP_BLE_INITIALIZED-} ]]; then
            # Support an existing session that previously used the plain prompt.
            _obsidian_prompt_hooks=()
            for _obsidian_hook in "${PROMPT_COMMAND[@]}"; do
                [[ -z "$_obsidian_hook" || "$_obsidian_hook" == starship_precmd || "$_obsidian_hook" == _obsidian_prompt ]] && continue
                _obsidian_prompt_hooks+=("$_obsidian_hook")
            done
            PROMPT_COMMAND=("${_obsidian_prompt_hooks[@]}")
            # Remove the old plain-Bash timing hook if switching to ble.sh.
            if declare -F starship_precmd >/dev/null; then
                PS0=${PS0//'${STARSHIP_START_TIME:$((STARSHIP_START_TIME="$(starship_preexec_ps0)",STARSHIP_PREEXEC_READY=0,0)):0}'/}
            fi
            eval "$(starship init bash)"
            _OBSIDIAN_STARSHIP_BLE_INITIALIZED=1
            unset _obsidian_prompt_hooks _obsidian_hook
        fi
    elif ! declare -F starship_precmd >/dev/null; then
        _obsidian_prompt_hooks=()
        for _obsidian_hook in "${PROMPT_COMMAND[@]}"; do
            [[ -z "$_obsidian_hook" || "$_obsidian_hook" == _obsidian_prompt ]] && continue
            _obsidian_prompt_hooks+=("$_obsidian_hook")
        done
        unset PROMPT_COMMAND
        unset -f _obsidian_prompt 2>/dev/null
        eval "$(starship init bash)"
        PROMPT_COMMAND=(starship_precmd "${_obsidian_prompt_hooks[@]}")
        unset _obsidian_prompt_hooks _obsidian_hook
    fi
else
    PS1='\[\e[35m\]\w\[\e[0m\] \$ '
fi

# Attach only after all prompt and completion hooks have been configured.
[[ ! ${BLE_VERSION-} ]] || ble-attach

# AI: Obsidian Purple Aider launcher
alias ai='/home/kavin/Projects/ai/scripts/aider.sh'
