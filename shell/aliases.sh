# kitty
alias kitty-reload="kill -SIGUSR1 \$(pidof kitty)"

# general
alias cat="bat --theme=base16 --style=plain"
alias catl="bat --theme=base16"
alias batl="catl"
alias ll='ls -laFh'
# show permissions as numeric values e.g. 755 -rwxr-xr-x, 4755 -rwsr-xr-x
alias lln='ls -lFh | awk "{k=0;for(i=0;i<=8;i++){c=substr(\$1,i+2,1);if(c~/[rwxst]/)k+=2^(8-i)};if(substr(\$1,4,1)~/[sS]/)k+=2048;if(substr(\$1,7,1)~/[sS]/)k+=1024;if(substr(\$1,10,1)~/[tT]/)k+=512;if(k)printf(\"%o \",k);print}"'
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
