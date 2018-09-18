({
    getData : function(component, event, helper) {
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
})