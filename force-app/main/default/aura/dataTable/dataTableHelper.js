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

    getSecondaryData : function(component, event, helper) {
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
                console.log('Columns\n\n' + columns);
                // this.ammendRecords(component, records, columns);
                component.set('v.records', records);
                component.set('v.myColumns', columns);
            }
        }); 
        $A.enqueueAction(action);
    },


    recordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED"){
            component.find('entries').reloadRecord(true);
        }
    }
})