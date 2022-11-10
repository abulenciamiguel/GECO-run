#!/bin/bash
# Set some default values:
grid_userIP=USER@IP
gridPASS=PASSWORD
sshpass -p $gridPASS ssh -t $grid_userIP "cd /data; exec \$SHELL -l"