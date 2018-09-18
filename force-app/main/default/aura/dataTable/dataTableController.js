({
	init : function(component, event, helper) {
        var action = component.get('c.getFieldsFromFieldSet');
        action.setParams({
            fsName : component.get('v.fsName'),
            oName : component.get('v.oName'),
            fActions : component.get('v.fActions')
        });
        action.setCallback(this, $A.getCallback(function (response) {
        	var state = response.getState();
            if(state === "SUCCESS"){
                component.set('v.myColumns',JSON.parse(response.getReturnValue()));
        	} else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
    	}));
    	$A.enqueueAction(action);
        helper.getData(component);
    },
    

    secondaryInit: function(component, event, helper) {
        helper.getSecondaryData(component, event, helper);
    },
    
    doAction : function(component,event,helper) {
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
                helper.recordUpdated(component, event, helper);
        		helper.getData(component);
        	} else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
    	}));
    	$A.enqueueAction(action);
    },

    dumpColumns: function(component, event, helper) {
        console.log(JSON.stringify(component.get('v.myColumns'), null, 4));
    },

    dumpData: function(component, event, helper) {
        console.log(JSON.stringify(component.get('v.records'), null, 4));
    }

})