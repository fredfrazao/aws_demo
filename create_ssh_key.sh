#!/bin/sh

set -eu

SSH_KEY_NAME=${SSH_KEY_NAME:-'ssh-key'}
AWS_REGION=${AWS_REGION:-'eu-west-2'}

aws ec2 create-key-pair \
    --region "${AWS_REGION}" \
    --key-name "${SSH_KEY_NAME}" \
    --key-type rsa \
    --query "KeyMaterial" \
    --output text > "${SSH_KEY_NAME}.pem"

chmod 400 "${SSH_KEY_NAME}.pem"
