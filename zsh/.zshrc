path=(
  /opt/homebrew/bin(N-/)
  /opt/homebrew/sbin(N-/)
  /usr/bin
  /usr/sbin
  /bin
  /sbin
  /usr/local/bin(N-/)
  /usr/local/sbin(N-/)
  /Library/Apple/usr/bin
  ~/.local/bin
)

[[ ! -f ~/.zaliases ]] || source ~/.zaliases # import aliases
bindkey -e # Ctrl+AやCtrl+Bが^Aのようになる対策

eval "$(mise activate zsh)"
eval "$(starship init zsh)"

export EDITOR='nvim' # editor

autoload -Uz colors ; colors # 色を使用
autoload -Uz compinit ; compinit # 補完機能を有効

# cdとlsの省略
setopt auto_cd
function chpwd() { ls }

export LSCOLORS=cxfxcxdxbxegedabagacad # lsのカラー表示

zstyle ":completion:*:commands" rehash 1 # 新しいコマンドを即認識

# historyの保存数を増やす
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000

setopt print_eight_bit # 日本語ファイル名を表示可能に
setopt share_history # 同時に起動した zsh の間でヒストリを共有する
setopt hist_ignore_dups # 直前と同じコマンドの場合はヒストリに追加しない
setopt hist_ignore_all_dups # 同じコマンドをヒストリに残さない
setopt hist_reduce_blanks # ヒストリに保存するときに余分なスペースを削除する
setopt hist_ignore_space  # 先頭にスペースがある場合はヒストリに残さない

