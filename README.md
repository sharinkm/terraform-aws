

## This is the code for deploying 1 master node and 1 worker node with terraform into AWS

## Once this setup is ready you can apply kubespray to deploy the k8s cluster



## Post depolyment manual steps

# post deployment ssh into jump server and run below

# scp ~/Downloads/pvt-key-pair.pem ubuntu@52.66.176.x:/tmp

# chmod 400 /tmp/pvt-key-pair.pem

# ssh -i pvt-key-pair.pem ubuntu@10.0.10.x # both master and worker and append the k8s-key.pub to authorised keys


# rename k8s_key && k8s_key.pub into id_rsa id_rsa.pub 

# Also copy the content of id_ras.pub into authorisedkey file in both master node and worker node using vim command "o" after ssh to both nodes
