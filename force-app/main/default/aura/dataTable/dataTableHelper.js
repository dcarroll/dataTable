({
    doEcho : function(cmp)  {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c.serverEcho");
        action.setParams({ firstName : cmp.get("v.firstName") });

        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Alert the user with the value returned 
                // from the server
                alert("From server: " + response.getReturnValue());
                debugger;
                cmp.set('v.myColumns',response.getReturnValue());
                this.getData(cmp);
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
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
        console.log(component.get('v.fActions'));
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
                // this.ammendRecords(component, records, columns);
                debugger;
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
                    { label: 'SObject', fieldName: 'object', type: 'text'},
                    { label: 'Field', fieldName: 'field', type: 'text' }
                ]);
                component.set('v.records', records);
                component.set('v.myColumns', columns);
                if (removedFields.length === 0) {
                    component.set('v.titleString', 'Active Contact List (Permset Not Assigned)');
                    component.set('v.buttonLabel', 'Assign Permerset');
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

    switchPerms : function(component) {
        console.log('In the togglePermset helper');
        // debugger;
        var action = component.get('c.switchPerms');
        console.log('Got the action, going to set callback and then enqueueu');
        action.setParams({
            
        });
        action.setCallback(this, function(response) {
            console.log("Got response from switchPerms apex method");
            var state = response.getState();
            var result = response.getReturnValue();
            if (result === undefined) {
                return;
            }
            console.log('State is ' + state);
            console.log('Response from callback is \n' + JSON.stringify(result, null, 4));
            if (state === 'SUCCESS') {
                // component.set('v.records',response.getReturnValue());
                // this.getData(component);
                // this.getData(component)
            }
        }); 
        $A.enqueueAction(action);
    },
})