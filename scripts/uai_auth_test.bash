#! /bin/bash

name="mvmltm"

file=bigip.conf

storage="https://${name}.blob.core.windows.net/f5-bigip/$file"
tokenUrl="http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/"
tokenHdr="-HMetadata:true"

#echo "curl -0s $tokenHdr '$tokenUrl'"
token=$(curl -0s $tokenHdr $tokenUrl | jq -r .access_token)
storageHdrs="-H \"x-ms-version: 2017-11-09\" -H \"Authorization: Bearer $token\""
stHdr01="x-ms-version:2017-11-09"
stHdr02="Authorization: Bearer $token"
#echo curl -0s -H \"$stHdr01\" -H \"$stHdr02\" $storage 


curl -0s -H "$stHdr01" -H "$stHdr02" $storage  -o $file


#rm $uai_headers
#rm $ltm_cfg 
