# Rounded search windows matching the Ghostty / Obsidian Purple palette.
export FZF_DEFAULT_OPTS="--height=45% --layout=reverse --border=rounded --padding=1,2 --info=inline --prompt='❯ ' --pointer='›' --marker='✓' --color=bg:#17101f,bg+:#382447,fg:#eee6f7,fg+:#eee6f7,hl:#b58cff,hl+:#d6beff,border:#53366e,label:#d6beff,info:#927da6,prompt:#b58cff,pointer:#b58cff,marker:#a6d9a6,spinner:#b58cff,header:#927da6"
export FZF_CTRL_R_OPTS='--border-label=" history "'
export FZF_CTRL_T_OPTS='--walker-skip=.git,node_modules,.venv,__pycache__ --border-label=" files "'
export FZF_ALT_C_OPTS='--walker-skip=.git,node_modules,.venv,__pycache__ --border-label=" folders "'
