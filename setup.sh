sfdx force:org:create -s -f config/project-scratch-def.json -a dataTableTest
sfdx force:source:push
sfdx force:user:permset:assign -n datatable
sfdx force:org:open