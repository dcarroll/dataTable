({

    init: function(component, event, helper) {
        helper.getData(component);
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