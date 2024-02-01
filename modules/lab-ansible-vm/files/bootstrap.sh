#!/usr/bin/env bash

# Load environment variables. These are initially populated by cloud-init
source /etc/ansible-runner/environment.sh

: "${HOST_NAME:?Variable HOST_NAME not set or empty}"
: "${WORKSPACE_PATH:?Variable WORKSPACE_PATH not set or empty}"
: "${PROJECT_PATH:?Variable PROJECT_PATH not set or empty}"
: "${VAULT_PATH:?Variable VAULT_PATH not set or empty}"
: "${PROJECT_REPOSITORY_URL:?Variable PROJECT_REPOSITORY_URL not set or empty}"
: "${VAULT_REPOSITORY_URL:?Variable VAULT_REPOSITORY_URL not set or empty}"

if [ -d "${WORKSPACE_PATH}" ]; then
  echo "Workspace path (${WORKSPACE_PATH}) already exists! Aborting."
  exit 1
fi

# copy keys from our permanent storage
sudo cp /var/lib/ansible/ssh-keys/* $HOME/.ssh/
sudo chown -R "${USER}:${USER}" $HOME/.ssh

# 'unlock' keys by adding them to the ssh-agent (will prompt for passphrase)
eval `ssh-agent`
ssh-add

# clone repositories
mkdir -p "${WORKSPACE_PATH}"
git clone "${PROJECT_REPOSITORY_URL}" "${PROJECT_PATH}"
git clone "${VAULT_REPOSITORY_URL}" "${VAULT_PATH}"

cd "${PROJECT_PATH}"

# install any Galaxy requirements
ansible-galaxy install -r project/requirements.yml

# run with ansible-playbook during bootstrap, which will install ansible-runner for future use
ansible-playbook \
  -i inventory \
  -l "$(hostname)" \
  --vault-id lab@/var/lib/ansible/vault-password \
  --extra-vars @../vault/vault.yml \
  project/playbook.yml
