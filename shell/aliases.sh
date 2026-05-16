# kitty
alias kitty-reload="kill -SIGUSR1 \$(pidof kitty)"

# general
alias ll='ls -laFh'
alias tree='tree -LC 2'
alias cl='clear'

# navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ~='cd ~'
alias dot='cd ~/dotfiles'

# network
alias ping='ping -c 5'

# git
alias gs="git status"
alias gl="git log --pretty=format:\"%C(yellow)%h %ad%Cred%d %Creset%s%Cblue [%cn]\" --decorate --date=relative"

# docker
alias dc="docker compose"

# kubectl
alias kucontexts="kubectl config get-contexts"
alias kupods="kubectl get pods"
alias kudeletepod="kubectl delete pod"
alias kudescribepod="kubectl describe pod"
alias kulogs="kubectl logs"
alias kushell='function _kubectlshell(){ kubectl exec --stdin --tty "$1" -- /bin/sh; };_kubectlshell'
