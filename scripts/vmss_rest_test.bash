#! /bin/bash

metadataUrl="http://169.254.169.254/metadata/instance?api-version=2021-02-01"

subscription_id=$(curl -sHMetadata:true $metadataUrl | jq -r .compute.subscriptionId)
resource_group=$(curl -sHMetadata:true $metadataUrl | jq -r .compute.resourceGroupName)
scale_set=$(curl -sHMetadata:true $metadataUrl | jq -r .compute.vmScaleSetName)
instance_id="1"

httpCmd="GET"
changes="delete|deallocate|redeploy|reimage|restart"

#action="instanceView"
#action="delete"
#action="deallocate"
#action="redeploy"
action="read"
#action="instanceView"


# https://docs.microsoft.com/en-us/rest/api/compute/virtual-machine-scale-set-vms/redeploy
uri="management.azure.com/subscriptions/$subscription_id"
uri="$uri/resourceGroups/$resource_group/providers/Microsoft.Compute"
uri="$uri/virtualMachineScaleSets/$scale_set"
uri="$uri/virtualMachines/$instance_id"
if [[ $action =~ $changes ]]; then
  uri="$uri/$action"
  httpCmd="POST"
fi
uri="$uri?api-version=2021-07-01"


# Get auth header
tokenUrl="http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/"
tokenHdr="-HMetadata:true"
token=$(curl -0s $tokenHdr $tokenUrl | jq -r .access_token)

stHdr01="x-ms-version:2017-11-09"
stHdr02="Authorization: Bearer $token"



#echo https://$uri
if [[ $httpCmd == "POST" ]]; then
  echo curl -H "$stHdr01" -H "$stHdr02" -X $httpCmd "https://$uri" -d ""
  #echo -e "\n\n"
  status=$(curl -w "%{http_code}" -sH "$stHdr01" -H "$stHdr02" -X $httpCmd https://$uri -d "")
else
  #echo curl -H "$stHdr01" -H "$stHdr02" -X $httpCmd https://$uri
  #echo -e "\n\n"
  curl -w "%{http_code}" -sH "$stHdr01" -H "$stHdr02" -X $httpCmd https://$uri
  #echo "status: $?"
fi
