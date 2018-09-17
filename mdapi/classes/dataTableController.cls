public class dataTableController {

    @auraEnabled
    public static LIST<SObject> listForLightning(String flowName, String recordId){
        
        Flow.Interview flow = Flow.Interview.createInterview(flowName, new MAP<String, Object> {'recordId' => recordId});
        flow.start();
        LIST<SObject> lightningList = (LIST<SObject>) flow.getVariableValue('records');
        return lightningList;
    }
    
    @auraEnabled
    public static string actionForLightning(String flowName, String recordId, String selectedRecordId){
        
        MAP<String,Object> inputs = new MAP<String,Object>();
        inputs.put('recordId', recordId);
        inputs.put('selectedRecordId', selectedRecordId);
        
        Flow.Interview flow = Flow.Interview.createInterview(flowName, inputs);
        flow.start();
        String complete = 'Complete';
        return complete;
        
    }
    
    @auraEnabled
    public static string getFieldsFromFieldSet(String fsName, String oName, String fActions){
    
        String columns = '[';
        Integer i = 0;
        
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
    	Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get(oName);
    	Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
    	Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get(fsName);
        LIST<FieldSetMember> fsFields = fieldSetObj.getFields();
        
        for(FieldSetMember fsm : fsFields){
            if(i == 0){
                columns += '{"label":"'+fsm.label+'","fieldName":"'+oName+'Link__c","type":"url","typeAttributes":{"label":{"fieldName":"'+fsm.fieldpath+'"}}},';
            } else {
            	columns += '{"label":"'+fsm.label+'","fieldName":"'+fsm.fieldpath+'","type":"'+(fsm.type + '').toLowerCase()+'"},';
            }
            i++;
        }
        
        system.debug('fActions = '+fActions);
        
        if(fActions != Null){
            LIST<String> flowActions = fActions.split(',');
            system.debug(flowActions);
            columns += '{"type":"action","typeAttributes":{"rowActions":[';
            for(Flow_Action__mdt fa: [SELECT DeveloperName,MasterLabel FROM Flow_Action__mdt WHERE DeveloperName in: flowActions]){
                columns += '{"label":"'+fa.MasterLabel+'","name":"'+fa.DeveloperName+'"},';
            }
            columns = columns.removeEnd(',');
            columns += ']}}';
        }else{
            columns = columns.removeEnd(',');
        }
        
        columns += ']';
        system.debug(columns);
        
        return columns;
        
    }
    
}