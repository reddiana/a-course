cat << EOF >> /etc/bash.bashrc

set -o vi

alias d='docker'
alias k='microk8s kubectl'
alias kubectl='microk8s kubectl'
alias kw='watch "microk8s kubectl get pod -A"'
alias kww='watch "microk8s kubectl get pod -A | grep -v Running"'

EOF