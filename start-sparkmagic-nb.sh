#!/bin/bash

# just in case
export NB_USER=$NEW_USER

# check for keytab presence and perform kinit
KEYTAB=$(find ~/keytab | tail -n 1)
if [ -n "$KEYTAB" ] 
then
	PRINCIPAL=$(klist -k $KEYTAB | tail -n 1 | grep -oE "[^ ]+$")
	kinit -kt $KEYTAB $PRINCIPAL
fi

# echo "$(getent ahostsv4 $LIVY_HOST | head -n 1 | grep -oE "^[^ ]+")	$LIVY_HOST" > /ets/hosts

# create sparkmagic config file
if [ ! -f "~/.sparkmagic/config.json" ]
then
	mkdir -p ~/.sparkmagic
	cp /sparkmagic/config.json ~/.sparkmagic
	sed -i "s|%livy-url%|$LIVY_URL|g" ~/.sparkmagic/config.json
	sed -i "s|%proxy-user%|$NB_USER|g" ~/.sparkmagic/config.json
fi

if [ ! -f "~/.condarc" ]
then
    printf "envs_dirs:\n  - /home/%s/conda" "$NB_USER" > ~/.condarc
fi

cd ~

exec jupyterhub-singleuser $@