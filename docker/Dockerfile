FROM alpine:latest
RUN apk add --update --no-cache python3 py3-pip
RUN pip3 install --no-cache-dir awscli boto3
CMD [ "sh", "-c", "while true; do sleep 2000; done"]