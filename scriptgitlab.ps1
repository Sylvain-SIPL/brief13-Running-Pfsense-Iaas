# create security group 
az network nsg create --resource-group SimplonRG_CarlierSylvain --name NSG-gitlab

# create security rules
az network nsg rule create --resource-group SimplonRG_CarlierSylvain --nsg-name NSG-gitlab  --name TCP-rule --priority 1000 --destination-address-prefixes '*' --destination-port-ranges 22 --protocol Tcp --description "AllowSSH"
az network nsg rule create --resource-group SimplonRG_CarlierSylvain --nsg-name NSG-gitlab  --name TCP-rule --priority 1010 --destination-address-prefixes '*' --destination-port-ranges 80 --protocol Tcp --description "Allowhttp"
az network nsg rule create --resource-group SimplonRG_CarlierSylvain --nsg-name NSG-gitlab  --name TCP-rule --priority 1010 --destination-address-prefixes '*' --destination-port-ranges 443 --protocol Tcp --description "Allowhttps"

# create NIC win 
az network nic create -g SimplonRG_CarlierSylvain --vnet-name vnet-pfsenseSyl --subnet backend -n nicgitlab --private-ip-address 10.0.2.104

#create virtual machine
az vm create -g SimplonRG_CarlierSylvain --name gitlab --image Ubuntu2204 --admin-username "useradmin" --generate-ssh-keys --public-ip-sku Standard --custom-data cloud-init-gitlab.txt

#verify the creation (and state) of the new virtual machine
az vm list -d -o table --query "[?name=='gitlab']"

#get the public IP address for the sample virtual machine
az vm show --resource-group SimplonRG_CarlierSylvain --name gitlab -d --query [publicIps] --output tsv