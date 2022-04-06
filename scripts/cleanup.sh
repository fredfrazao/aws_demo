#!/bin/sh

set -eu

AWS_REGION=${AWS_REGION:-'eu-west-2'}
NETWORK_Name=${NETWORK_Name:-'network'}
COMPUTE_name=${COMPUTE_name:-'compute'}
PERSISTENCE_Name=${PERSISTENCE_Name:-'persistence'}

main(){

    delete_stack "${COMPUTE_name}"

    empty_ecr

    empty_bucket

    delete_stack "${PERSISTENCE_Name}"

    delete_stack "${NETWORK_Name}"

}

empty_ecr(){
    ECR_NAME=$(get_output "${PERSISTENCE_Name}" "ECRName")

    IMAGE_LIST=$(aws ecr list-images --region ${AWS_REGION} --repository-name "${ECR_NAME}" |jq -r ".imageIds[].imageTag")

    for ecr_image in "${IMAGE_LIST}"; do
        aws ecr batch-delete-image \
            --repository-name "${ECR_NAME}" --region "${AWS_REGION}" \
            --image-ids "imageTag=${ecr_image}"
    done
}

empty_bucket(){
    BUCKET_NAME=$(get_output "${PERSISTENCE_Name}" "BucketName")
    aws s3 rm "s3://${BUCKET_NAME}" --recursive

}

delete_stack(){
    sam delete --stack-name "${1}" --no-prompts --region "${AWS_REGION}"

}

get_output(){
    echo $(aws cloudformation describe-stacks --region "${AWS_REGION}" --stack-name "${1}" --query "Stacks[0].Outputs[?OutputKey=='${2}'].OutputValue" --output text)
}

main "$@"