#!/bin/bash
echo "Running Deployment"

echo "Current Working directory:"
pwd

if [ -n "$PRIV_KEY" ]; then
mkdir -p ~/.ssh
echo "${PRIV_KEY}" | tr "," "\n" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
echo "Added Private key"
else
echo "Private Key not defined"
fi

alias svn='svn --username=$SVN_USERNAME --password=$SVN_PASSWORD'

if [ -n "$SVN_USERNAME" ] && [ -n "$SVN_PASSWORD" ] && [ -n "$SVN_REPO" ]; then
yes yes | svn co $SVN_REPO
else
echo "No SVN Credentials sent"
fi

echo "$SVN_REPO_URL"