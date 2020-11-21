cat << EOF >> /etc/bash.bashrc

set -o vi

alias d='docker'
alias k='mickrk8s kubectl'
alias kubectl='mickrk8s kubectl'
alias kw='watch "microk8s kubectl get pod -A"'
alias kww='watch "microk8s kubectl get pod -A | grep -v Running"'

EOF
