Task:
 Deploy a multi-tier web application infrastructure using Apache or Nginx as the web server and HAProxy as the load balancer. The task involves creating custom roles (Ansible), cookbooks (Chef), or modules (Puppet) to manage the deployment, with a focus on advanced configuration management, security, and environment-specific settings.
 

1. Setup and Installation:
* install ansible
run ```brew install ansible```
check install ```ansible --version```

* create remote hosts on AWS via terraform
run ```cd terraform```
```terraform init```
```terraform apply -auto-approve```

write private key to a file:
```terraform output -raw private_key > key.pem```
```chmod 400 key.pem```
get ec2 public ip addresses:
```terraform output ec2_public_ip```
pick an ip from list to ssh into instance:
```ssh -i key.pem admin@<ec2_public_ip>```

2. Provisioning and Configuration:
* to create a self-signed SSL certificate run:
```openssl genrsa -out secret.key 2048```
```openssl req -new -key secret.key -out secret.csr```
```openssl req -text -noout -verify -in secret.csr```
```openssl x509 -req -days 365 -in secret.csr -signkey secret.key -out secret.crt```
```cat secret.crt secret.key > haproxy.pem```

3. Inventory and Environment Management:

An ansible.cfg file at 05-ansible/ansible/ was set up to use the inventory.ini file as a default one.
Now there is no need to pass the ```-i inventory.ini``` when running the playbooks.

* to run on ALL environments
cd to ansible directory ```cd ansible```
run ```ansible-playbook playbook.yaml```
(optionally) if ansible-vault enabled, pass ```--ask-vault-pass```
(debug) for verbosity mode add ```-vvv``` flag

to see the HAProxy Stats page go to:
http://<load_balancer_ip>:8404/stats

* to run ONLY on development environment
```ansible-playbook playbook.yaml --ask-vault-pass --limit development```


4. Security and Secrets Management:
* create an encrypted secrets file
```ansible-vault create secrets.yaml```
enter a password on prompt, pass the secrets to file, type `:wq` to save and exit.
when need to see the secrets, run ```ansible-vault view secrets.yaml``` and enter password on prompt.


5. Templates and Dynamic Configuration:

install the ansible crypto collection
```ansible-galaxy collection install community.crypto```


6. Testing and Validation:

Validate that the web server is properly serving the custom HTML page:

```ansible-playbook test_web_content.yaml -e "ENV=stg"```

Validate that HAProxy is correctly balancing the load between the web servers:

```ansible-playbook test_haproxy_load_balance.yaml -e "ENV=prod"```

* to pass a specific amount of requests, add `requests_count=<number_of_requests>`
```ansible-playbook test_haproxy_load_balance.yaml -e "ENV=prod requests_count=20"```

Perform security checks to ensure that only necessary ports are open and the services are running as expected:

```ansible-playbook test_ports.yaml -e "ENV=development"```


7. Infrastructure diagram

```bash
       +-------------------------+
       |   IP of this PC (User)  |
       +-------------------------+
                 |
                 | Traffic (Port 80)
                 v
+----------------------------------------------------------+
|       AWS Cloud / VPC (10.0.0.0/16)                      |
|                                                          |
|    +---------------------------------+                   |
|    | HAProxy Load Balancer (EC2)     |                   |
|    |---------------------------------|                   |
|    | Public IP:  13.51.56.118        |                   |
|    | Private IP: 10.0.1.173          |                   |
|    +---------------------------------+                   |
|                 |                                        |
|                 | Load Balanced Traffic                  |
|                 | (to Private IPs)                       |
|                 |                                        |
|   +-------------+-----------------+                      |
|   |                               |                      |
|   v                               v                      |
| +-----------------------+      +-----------------------+ |
| | Nginx Web Server 1    |      | Nginx Web Server 2    | |
| |-------------------    |      |-----------------------| |
| | Public IP: 34.x.x.x   |      | Public IP: 35.x.x.x   | |
| | Private IP: 10.0.1.50 |      | Private IP: 10.0.1.51 | |
| +-----------------------+      +-----------------------+ |
|                                                          |
+----------------------------------------------------------+
```
