export EDITOR=vim
export HISTSIZE=10000

export CLICOLOR=1

export LSCOLORS=GxFxCxDxBxegedabagaced

export TERM="xterm-color"
PS1='\[\e[0;33m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ '

PS1='\[\e[0;31m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ '

drac() {
        SERVER=$1
        sudo ssh -N -f -L 443:$SERVER:443 dhau@205.234.15.61 -i /Users/dhau/.ssh/id_rsa
        sudo ssh -N -f -L 5900:$SERVER:5900 dhau@205.234.15.61 -i /Users/dhau/.ssh/id_rsa
        sudo ssh -N -f -L 5901:$SERVER:5901 dhau@205.234.15.61 -i /Users/dhau/.ssh/id_rsa
        sudo ssh -N -f -L 8192:$SERVER:8192 dhau@205.234.15.61 -i /Users/dhau/.ssh/id_rsa
        open -a Google\ Chrome "https://localhost:443"
}
killdrac() {
        ps aux | grep "\-N \-f \-L" | awk '{ print $2 }' | xargs sudo kill -15
        }
