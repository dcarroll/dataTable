({
    doEcho : function(component)  {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = component.get("c.togglePerms");
        // action.setParams({ firstName : cmp.get("v.firstName") });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            var permsetResult = response.getReturnValue();
            if (state === "SUCCESS") {
               component.find('notifLib').showNotice({
                    "variant": (permsetResult === 'assigned') ? "info" : "error",
                    "header": "Permset Change",
                    "message": "You have just " + permsetResult + " the permset for this user"
                });
                component.set('v.myColumns', permsetResult);
                this.getData(component);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        // optionally set storable, abortable, background flag here

        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    },

    getData : function(component) {
        var action = component.get("c.listForLightningWithColumns");
        action.setParams({
            recordId: component.get("v.recordId"),
            flowName: component.get('v.flowNameLookup'),
            fieldsetName: component.get('v.fsName'),
            fActions: component.get('v.fActions')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === 'SUCCESS') {
                var result = JSON.parse(response.getReturnValue());
                var columns = result.columns;
                var records = result.records;
                var removedFieldsMap = result.removedFields;
                console.log('Columns\n\n' + columns);
                var removedFields = [];
                for (var key in removedFieldsMap) {
                    for (var i = 0; i < removedFieldsMap[key].length; i++) {
                        removedFields.push({ index: i, object: key, field: removedFieldsMap[key][i] })
                    }
                }
                var cols = [ { label: 'SObject', fieldName: 'object', type: 'text'},
                             { label: 'Field', fieldName: 'field', type: 'text' }];
                component.set('v.removedFields', removedFields);
                component.set('v.removedColumns', [ 
                    { 
                        label: 'SObject', 
                        fieldName: 'object', 
                        type: 'text',
                        cellAttributes: {
                            class: "red"
                        }
                    },
                    { 
                        label: 'Field', 
                        fieldName: 'field', 
                        type: 'text' ,
                        cellAttributes: {
                            class: "red"
                        }
                    }
                ]);
                component.set('v.records', records);
                component.set('v.myColumns', columns);
                if (removedFields.length === 0) {
                    component.set('v.titleString', 'Active Contact List (Permset Not Assigned)');
                    component.set('v.buttonLabel', 'Assign Permset');
                } else {
                    component.set('v.titleString', 'Active Contact List (Permset Assigned)');
                    component.set('v.buttonLabel', 'Remove Permset');
                }
            }
        }); 
        $A.enqueueAction(action);
    },

    doAction : function(component, event) {
		var action = component.get('c.actionForLightning');
        action.setParams({
            recordId : component.get('v.recordId'),
            selectedRecordId : event.getParam('row').Id,
            flowName : event.getParam('action').name
        });
        action.setCallback(this, $A.getCallback(function (response) {
        	var state = response.getState();
            if(state === "SUCCESS"){
            	component.set('v.records',response.getReturnValue());
        		this.getData(component);
        	} else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
    	}));
    	$A.enqueueAction(action);
    },
})