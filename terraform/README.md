
begin with ```cd shared_network```.

shared_network directory serves as a place where shared across all Environments resources are created, such as:
- ssh key - private and public
- vpc
- subnets - public and private
- igw
- security groups
- route table

run 
```terraform init```
```terraform apply -auto-appove```

to save the ssh key into a file run
```cd .. && ./make_key.sh```

being in the root terraform directory run:
```terraform init```


man dev env:
```terraform workspace new dev```
```terraform apply -var-file="env_tfvars/dev.tfvars"```

for stg env:
```terraform workspace new stg```
```terraform apply -var-file="env_tfvars/stg.tfvars"```

for prod env:
```terraform workspace new prod```
```terraform apply -var-file="env_tfvars/prod.tfvars"```


depending on <ENV> (dev/stg/prod) the resources will be created.
!!!!!
it is important to use the workspaces as they separate the states of environment.

to connect via ssh to an instance use
```ssh -i key.pem admin@<public-instance-ids>```

**managing workspaces**
when the workspaces are already created simply change bewtween them before running the apply command:
```terraform workspace list```
```terraform workspace select <ENV>```
```terraform state list```

to destroy resources in workspaces run, where <ENV> is dev/stg/prod:
```terraform workspace select <ENV>``` 
```terraform destroy -var-file="env_tfvars/<ENV>.tfvars"``
