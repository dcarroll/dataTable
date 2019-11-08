({

    init: function(component, event, helper) {
        component.set('v.removedFields', [{ object: 'Contact', field: 'Department'}]);
        component.set('v.removedColumns', [ 
            { label: 'SObject', fieldName: 'object', type: 'text'},
            { label: 'Field', fieldName: 'field', type: 'text' }
        ]);

        helper.getData(component);
    },
    
    echo: function(component, event, helper) {
        helper.doEcho(component, event);
    },

    doAction: function(componet, event, helper) {
        helper.doAction(componet, event);
    },

    dumpColumns: function(component) {
        console.log(JSON.stringify(component.get('v.myColumns'), null, 4));
    },

    dumpData: function(component) {
        console.log(JSON.stringify(component.get('v.records'), null, 4));
    }

})