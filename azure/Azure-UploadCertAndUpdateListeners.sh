#!/usr/bin/env bash
## Author: oreno@adobe.com
### ToDo: Backup original configuration first, set up logging, clean up output formatting... maybe, works for my purposes for now.

echo Nothing sucks more than the Azure console.
echo This script updates the SSL certificate for ALL listeners on an Application Gateway.
echo Please copy and paste the following.
echo You only need to specify a Certificate path and password if you are uploading a new certificate to the gateway.
echo Feel free to contribute, fork, or whatever. Do what you must.

### Define Variables
#AZRESOURCEGROUP=""
#AZGATEWAYNAME=""
#AZNEWSSLCERT=""
#AZNEWSSLCERTPATH=""
#AZNEWSSLCERTPW=""

### Or Read User Input
read -p 'Azure Resource Group: ' AZRESOURCEGROUP
read -p 'Azure Gateway Name: ' AZGATEWAYNAME
read -p 'Azure New SSL Certificate Name: ' AZNEWSSLCERT
read -p 'Local Path of New SSL Certificate in .pfx format: (Only needed if uploading cert to gateway, hit enter to ignore): ' AZNEWSSLCERTPATH
read -p 'Azure New SSL Certificate Password (Only needed if uploading cert to gateway, hit enter to ignore): ' AZNEWSSLCERTPW

AZHOSTNAMES=$(az network application-gateway http-listener list -g $AZRESOURCEGROUP --gateway-name $AZGATEWAYNAME --query "[].name" --output tsv | grep -v appgateway)

read -p "Upload New Certificate to $AZGATEWAYNAME?" -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    az network application-gateway ssl-cert create -g $AZRESOURCEGROUP --gateway-name $AZGATEWAYNAME -n $AZNEWSSLCERT --cert-file $AZNEWSSLCERTPATH --cert-password $AZNEWSSLCERTPW
  fi

echo "Now ready to update listeners on $AZGATEWAYNAME to use SSL CERT $AZNEWSSLCERT:
echo $AZHOSTNAMES"

read -p "Do you want to proceed? (yes/no) " yn
    case $yn in
    	yes ) echo ok, proceeding..;;
    	no ) echo exiting...;
    		exit;;
    	* ) echo invalid response;
    		exit 1;;
    esac

for i in $AZHOSTNAMES; do
    #echo $i
    az network application-gateway http-listener update -g $AZRESOURCEGROUP --gateway-name $AZGATEWAYNAME \
    -n $i --ssl-cert $AZNEWSSLCERT
    if [ $? -ne 0 ]; then
        echo "Failed to update"
        exit 1
    fi
    echo Certificate updated successfully.
done
