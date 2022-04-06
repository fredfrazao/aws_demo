

## Creating a SSH Key Pair

In order to have an SSH session with the servers from task 2 without using Session Manager, it is necessary to have a key pair in the region and pass its name to the `deploy.sh` script. If you don't have a key configured, use the script `create_ssh_key.sh` to generate one.

```bash
make gen-ssh-key
```
The script will create a SSH Key pair in the desired region that can be configured using environment variables

### Optional Environment Variables

Environment variables can be used to pass parameters to the script

* `AWS_REGION`: Region to deploy the key pair - Default: `'eu-west-2'`
* `SSH_KEY_NAME`: Name to use in Key creation - Default: `'code-key'`


#Changing key name and AWS Region
AWS_REGION='eu-west-1' SSH_KEY_NAME='other-key-name'./create_ssh_key.sh

## Deploying the solution

This Project has a `deploy.sh` script, that will perform the following actions:

```bash
make deploy
```


### Optional Environment Variables

Environment variables can be used to pass parameters to the script

* `AWS_REGION`: Region to deploy the solution - Default: `'eu-west-2'`
* `DB_INSTANCE_TYPE`: Instance type to be used by RDS - Default: `'db.t3.micro'`
* `DEV_PUBLIC_IP` - Default: Automatically gets public IP from Machine running `deploy.sh`
* `INSTANCE_TYPE`- Instance type to be used by servers from task 2 - Default: `'t3.micro'`
* `OWNER`: Stack Owner, value will be used in R53 Domain and S3 Bucket - Default: `'someone'`
* `DOMAIN_NAME`: Domain that will be used to create the Bucket and HostedZone - Default: `'${OWNER]-${AWS_REGION}-somechallenge.com'`
* `NETWORK_Name`: Name of Stack containing core network resources - Default: `'network'`
* `COMPUTE_name`: Name of Stack containing Compute resources - Default: `'compute'`
* `PERSISTENCE_Name`: Name of Stack containing Persistence resources- Default: `'persistence'`
* `SSH_KEY_NAME`: Name from SSH key - Default: none



* To get running Instances IP Address:
```bash
AWS_REGION='eu-west-2'
COMPUTE_name='compute'

aws ec2 describe-instances \
    --filters "Name=tag:aws:cloudformation:stack-name,Values=${COMPUTE_name}" \
    --region "${AWS_REGION}" | jq -r ".Reservations[].Instances[].PublicIpAddress"
```


The credentials for the database are created automatically by AWS and they are stored in SecretsManager,
under the following secret name: `Secret`

Get Domain Name used to deploy HostedZone

* Get DB Credentials 

```bash
AWS_REGION='eu-west-2'
aws secretsmanager get-secret-value --region "${AWS_REGION}" --secret-id Secret | jq -r ".SecretString"
```

#Using psql
amazon-linux-extras install postgresql13 -y
PGPASSWORD=<DB_password> psql -h <RDS-ENDPOINT> -p <RDS-PORT> -U <DB_Username> CodeChallengeDB
```
## Deleting Solution Resources

```bash
make cleanup
```
