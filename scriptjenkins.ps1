# create security group 
az network nsg create --resource-group SimplonRG_CarlierSylvain --name NSG-jenkins

# create security rules
az network nsg rule create --resource-group SimplonRG_CarlierSylvain --nsg-name NSG-jenkins  --name TCP-rule --priority 1000 --destination-address-prefixes '*' --destination-port-ranges 22 --protocol Tcp --description "AllowSSH"
az network nsg rule create --resource-group SimplonRG_CarlierSylvain --nsg-name NSG-jenkins  --name TCP-rule --priority 1010 --destination-address-prefixes '*' --destination-port-ranges 8080 --protocol Any --description "Open-port-8080"

# create NIC win 
az network nic create -g SimplonRG_CarlierSylvain --vnet-name vnet-pfsenseSyl --subnet backend -n nicjenkins --private-ip-address 10.0.2.112


#create virtual machine
az vm create --resource-group SimplonRG_CarlierSylvain --name jenkins --image Ubuntu2204 --admin-username "useradmin" --generate-ssh-keys --public-ip-sku Standard --custom-data cloud-init-jenkins.txt

#verify the creation (and state) of the new virtual machine
az vm list -d -o table --query "[?name=='jenkins']"

#open port 8080 on the new virtual machine.
az vm open-port --resource-group SimplonRG_CarlierSylvain --name jenkins --port 8080 --priority 1010

#get the public IP address for the sample virtual machine
az vm show --resource-group SimplonRG_CarlierSylvain --name jenkins -d --query [publicIps] --output tsv