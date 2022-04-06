#!/bin/sh

set -eu

AWS_REGION=${AWS_REGION:-'eu-west-2'}
OWNER=${OWNER:-"someone"}

DOMAIN_NAME=${DOMAIN_NAME:-"${OWNER}-${AWS_REGION}-somechallenge.com"}
NETWORK_Name=${NETWORK_Name:-'network'}
COMPUTE_name=${COMPUTE_name:-'compute'}
PERSISTENCE_Name=${PERSISTENCE_Name:-'persistence'}

SSH_KEY_NAME=${SSH_KEY_NAME:-'false'}
INSTANCE_TYPE=${INSTANCE_TYPE:-'t3.micro'}
DB_INSTANCE_TYPE=${DB_INSTANCE_TYPE:-'db.t3.micro'}
DEV_PUBLIC_IP=${DEV_PUBLIC_IP:-"$(curl https://checkip.amazonaws.com)"}

main (){
    deploy_network
    deploy_persistence
    deploy_compute
    copy_html_to_s3
}

deploy_network(){
    name="${NETWORK_Name}"
    PAR_OVERRIDES="--parameter-overrides DomainName=${DOMAIN_NAME}"
    deploy_stack 'stack/network.yml' "${PAR_OVERRIDES}"
}

deploy_compute(){
    name="${COMPUTE_name}"

    VPC2_name=$(get_output "${NETWORK_Name}" "VPC2StackName")
    ECR_URL=$(get_output "${PERSISTENCE_Name}" "ECRUrl")

    docker_build_and_push

    PAR_OVERRIDES="--parameter-overrides SSHKeyName=${SSH_KEY_NAME} LocalIP=${DEV_PUBLIC_IP} VPC2StackName=${VPC2_name} InstanceType=${INSTANCE_TYPE} PersistencyStack=${PERSISTENCE_Name} ContainerImage=${ECR_URL}:latest"
    EXTRA_PARAMETERS="--capabilities CAPABILITY_NAMED_IAM ${PAR_OVERRIDES}"
    deploy_stack 'stack/compute.yml' "${EXTRA_PARAMETERS}"
}

deploy_persistence(){
    name="${PERSISTENCE_Name}"
    PAR_OVERRIDES="--parameter-overrides DomainName=${DOMAIN_NAME} NetworkStack=${NETWORK_Name} DbInstanceSize=${DB_INSTANCE_TYPE}"
    deploy_stack 'stack/persistence.yml' "${PAR_OVERRIDES}"
}

docker_build_and_push(){
    ECR_REPO=$(get_output "${PERSISTENCE_Name}" "ECRName")

    aws ecr get-login-password --region "${AWS_REGION}" | docker login --username AWS --password-stdin $(echo "${ECR_URL}" | cut -d "/" -f 1)

    docker build -t "${ECR_REPO}" .

    docker tag "${ECR_REPO}:latest" "${ECR_URL}:latest"
    docker push "${ECR_URL}:latest"
}

copy_html_to_s3(){
    BUCKET_NAME=$(get_output "${PERSISTENCE_Name}" "BucketName")
    aws s3 sync html "s3://${BUCKET_NAME}/"
}

get_output(){
    echo $(aws cloudformation describe-stacks --region "${AWS_REGION}" --stack-name "${1}" --query "Stacks[0].Outputs[?OutputKey=='${2}'].OutputValue" --output text)
}

deploy_stack(){
    sam build -t "${1}"

    sam deploy --stack-name "${name}" --region "${AWS_REGION}" --no-fail-on-empty-changeset --resolve-s3 ${2}
}

main "$@"
