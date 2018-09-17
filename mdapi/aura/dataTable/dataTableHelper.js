({
	getData : function(component) {
		var action = component.get('c.listForLightning');
        action.setParams({
            recordId : component.get("v.recordId"),
            flowName : component.get("v.flowNameLookup")
        });
        action.setCallback(this, $A.getCallback(function (response) {
        	var state = response.getState();
            if(state === "SUCCESS"){
            	component.set('v.records',response.getReturnValue());
        	} else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
    	}));
    	$A.enqueueAction(action);
	},
    recordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED"){
            component.find('entries').reloadRecord(true);
        }
    }
})