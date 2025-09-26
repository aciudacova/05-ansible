#!/bin/bash
terraform output -raw ssh_private_key > key.pem
chmod 400 key.pem