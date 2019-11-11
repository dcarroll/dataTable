#!/bin/bash

if [ $# -lt 1 ]
then
    echo Usage: setup.sh youremailaddress
    exit
fi

sfdx force:org:delete -u demoAdmin -p
sfdx force:org:create -s -f config/project-scratch-def.json -a demoAdmin
sfdx force:user:password:generate -u demoAdmin
sfdx force:user:create -a standard email=$1 -u demoAdmin profileName="Standard User"
sfdx force:user:password:generate -u standard
sfdx force:source:push
sfdx force:user:permset:assign -n DataTable -u demoAdmin
sfdx force:user:permset:assign -n DataTable -u standard
sfdx force:org:open -u demoAdmin

echo "After you org opens, navigate to an Opportunity record and add the lightning component"
echo "the Opportunity record page and activate it."
echo ""
echo "There are two actions you can add to the component, addContactToOpportunity and deactivateContact."
echo "You can also play with changing the Flows to include different filtering criteria and"
echo "also mess with different field sets for the Contact object."