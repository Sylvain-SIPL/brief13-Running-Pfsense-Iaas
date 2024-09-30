
######### create disk and image pfsense ######

#create managed disk 
az disk create -g SimplonRG_CarlierSylvain -n pfsense1 --location northeurope --source https://pfsestorage.blob.core.windows.net/pfsense/pfsense.vhd

# create the image 
$Destfile = "https://pfsestorage.blob.core.windows.net/pfsense/pfsense.vhd"
az image create --name pfsense-img --resource-group SimplonRG_CarlierSylvain --os-type Linux --source $Destfile


######## config network ###############

#create vnet 
az network vnet create --name vnet-pfsenseSyl --resource-group SimplonRG_CarlierSylvain --address-prefix 10.0.0.0/16

# create subnet frontend 

az network vnet subnet create --name frontend --vnet-name vnet-pfsenseSyl --resource-group SimplonRG_CarlierSylvain --address-prefix 10.0.1.0/24

# create subnet backend

az network vnet subnet create --name backend --vnet-name vnet-pfsenseSyl --resource-group SimplonRG_CarlierSylvain --address-prefix 10.0.2.0/24

# create security group 
az network nsg create --resource-group SimplonRG_CarlierSylvain --name NSG-pfsense
az network nsg create --resource-group SimplonRG_CarlierSylvain --name NSG-client

# create security rules
az network nsg rule create --resource-group SimplonRG_CarlierSylvain --nsg-name NSG-pfsense --name TCP-rule --priority 300 --destination-address-prefixes '*' --destination-port-ranges 443 --protocol Tcp --description "AllowHTTPS"
az network nsg rule create --resource-group SimplonRG_CarlierSylvain --nsg-name NSG-pfsense --name TCP-rule --priority 300 --destination-address-prefixes '*' --destination-port-ranges 80 --protocol Tcp --description "AllowHTTP"
az network nsg rule create --resource-group SimplonRG_CarlierSylvain --nsg-name NSG-pfsense --name UDP-rule --priority 200 --destination-address-prefixes '*' --destination-port-ranges 1194 --protocol Udp --description "AllowOpenvpn"
az network nsg rule create --resource-group SimplonRG_CarlierSylvain --nsg-name NSG-client  --name RDP-rule --priority 300 --destination-address-prefixes '*' --destination-port-ranges 3389 --protocol Tcp --description "AllowRDP"
az network nsg rule create --resource-group SimplonRG_CarlierSylvain --nsg-name NSG-pfsense  --name TCP-rule --priority 300 --destination-address-prefixes '*' --destination-port-ranges 22 --protocol Tcp --description "AllowSSH"

# create NIC pfense
az network nic create -g SimplonRG_CarlierSylvain --vnet-name vnet-pfsenseSyl --subnet frontend -n frontnic --private-ip-address 10.0.1.10
az network nic create -g SimplonRG_CarlierSylvain --vnet-name vnet-pfsenseSyl --subnet backend -n backnic --private-ip-address 10.0.2.20

#create NIC win 
az network nic create -g SimplonRG_CarlierSylvain --vnet-name vnet-pfsenseSyl --subnet backend -n nicwin --private-ip-address 10.0.2.100

# create public ip address
az network public-ip create -g SimplonRG_CarlierSylvain --name lbpip --sku Standard --zone 1
az network public-ip create -g SimplonRG_CarlierSylvain --name pfsensepip --sku Standard --zone 1


############ Install client ########################


#install client windows

az vm create --resource-group SimplonRG_CarlierSylvain --location northeurope --nics nicwin --name win10 --image MicrosoftWindowsDesktop:Windows-10:win10-22h2-pron-g2:19045.3803.231204 --admin-username useradmin --admin-password Sylvain290176@


