#!/bin/bash

# Simple script to upgrade/install packages and hotfixes on specific Objects based on user selection

SID=$(mgmt_cli -r true login --format json | jq -r '.sid') 
 
printf "Logged in with session ID: ${SID}" 
echo " "
echo -n "Enter the version of the object to Install the JHF on (e.g. R80.40 or R81) and press [ENTER]: " 
 
read -r src_version 
 
JSON=$(mgmt_cli show gateways-and-servers details-level full --format json --session-id "${SID}" | jq -r --arg src "${src_version}" '.objects[] | select(.version == $src) | .name ') 
echo " "
printf "This is a list of all the object with ${src_version} version" 

echo " "

for item in ${JSON}     
	do        
 		echo "${item}"     
	done 

packages=$(mgmt_cli show repository-packages offset 0 details-level "standard"  --format json --session-id "${SID}" 2>/dev/null | jq -r '.tasks[] ."task-details"[] | .packages[]' ) 

package_names=$(echo ${packages} | jq -r '.name')
echo " "
 
printf "Available packages for ${src_version}"
echo " "
PS3="Choose the package to install: "
select package_name in ${package_names}
	do
	echo " "
	break 
	done

echo " "

 for item in ${JSON}     
 	do        
 		echo "${item}"     

printf "Verifying package ${package_name} for all ${src_version} objects" 
verify_package=$(mgmt_cli verify-software-package name ${package_name} download-package "true" targets.1 ${item}  --format json --session-id "${SID}")
printf "${verify_package}"
echo " "
printf "Verifying package ${package_name} for all ${src_version} objects" 
install_package=$(mgmt_cli install-software-package name ${package_name} targets.1 ${item}  --format json --session-id "${SID}")
printf "${install_package}"
	
	done 

echo " "

echo logging out from session ID "${SID}" 
 
mgmt_cli logout --session-id "${SID}"
