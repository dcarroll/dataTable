({
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
                console.log('Columns\n\n' + columns);
                // this.ammendRecords(component, records, columns);
                component.set('v.records', records);
                component.set('v.myColumns', columns);
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