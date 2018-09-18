#!/bin/bash
sfdx force:org:create -s -f config/project-scratch-def.json -a dataTableTest
sfdx force:source:push
sfdx force:user:permset:assign -n datatable
sfdx force:org:open

echo "After you org opens, navigate to an Opportunity record and add the lightning component"
echo "the Opportunity record page and activate it."
echo ""
echo "There are two actions you can add to the component, addContactToOpportunity and deactivateContact."
echo "You can also play with changing the Flows to include different filtering criteria and"
echo "also mess with different field sets for the Contact object."