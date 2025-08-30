# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ -z "$PATH" || "$PATH" == "/bin:/usr/bin" ]]
then
	export PATH="/usr/local/bin:/usr/bin:/bin:/usr/games"
fi

if [[ -z "$XDG_CONFIG_HOME" ]]
then
	export XDG_CONFIG_HOME="$HOME/.config/"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
then
	export ZDOTCONFIG="$XDG_CONFIG_HOME/zsh/"
fi

[ -f "${ZDOTDIR}/optionrc " ] && source "${ZDOTDIR/zsh/optionrc}"

export PATH="$PATH:/opt/nvim/"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$PATH:$(npm prefix -g)/bin"


source $ZDOTDIR/plugins/powerlevel10k/powerlevel10k.zsh-theme
source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source "$ZDOTDIR/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

# To customize prompt, run `p10k configure` or edit ~/.config/zsh/.p10k.zsh.
[[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh
