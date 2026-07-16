#!/bin/bash

export YELLOW="\001\033[1;33m\002" RESET="\001\033[0m\002"

logger() {
    printf "$YELLOW\t\t$1$RESET\n"
}



logger 'Saving garage node ids to files...'

kubectl exec pod/garage-0 -- /garage status |
awk '
/^==== HEALTHY NODES ====$/ { found=1; next }

found && $1 != "ID" && length($1) == 16 {
    print $1 > ("node_" ++n "_id.txt")
    close("node_" n "_id.txt")
    if (n == 3) exit
}
'

logger 'Node id files:'
ls
