#!/bin/bash


if [ "$#" -ne 2 ]; then
    echo "Illegal number of parameters: user host"
    exit 1
fi


USER=$1
HOST=$2

ssh-copy-id $USER@$HOST
ssh $USER@$HOST "sudo cp ~/.ssh/authorized_keys /root/.ssh/authorized_keys"
