cat << EOF >> /etc/bash.bashrc

set -o vi

alias d='docker'
alias k='mickrk8s kubectl'
alias kubectl='mickrk8s kubectl'
EOF
