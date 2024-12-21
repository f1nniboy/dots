# antigen plugin manager
source /usr/share/zsh/share/antigen.zsh

# starship prompt
export STARSHIP_CONFIG=$XDG_CONFIG_HOME/starship.toml
eval "$(starship init zsh)"

# plugins
antigen bundles <<EOBUNDLES
  rupa/z@master                         # life depends on this
  desyncr/key-bindings

  zsh-users/zsh-syntax-highlighting
  zsh-users/zsh-autosuggestions

  desyncr/auto-ls
EOBUNDLES

antigen apply

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=245'
ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(
    "expand-or-complete"
    "pcomplete"
    "copy-earlier-word"
)

# load individual config fiels
for file in $XDG_CONFIG_HOME/zsh/conf.d/*; do
    source "$file"
done
