public class dataTableController {

    @auraEnabled
    public static LIST<SObject> listForLightning(String flowName, String recordId){
        
        Flow.Interview flow = Flow.Interview.createInterview(flowName, new MAP<String, Object> {'recordId' => recordId});
        flow.start();
        LIST<SObject> lightningList = (LIST<SObject>) flow.getVariableValue('records');
        return lightningList;
    }

    @auraEnabled
    public static String listForLightningWithColumns(String flowName, String recordId, String fieldsetName, string fActions){
        FlowUtility flowUtil = new FlowUtility();
        Flow.Interview flow = Flow.Interview.createInterview(flowName, new MAP<String, Object> {'recordId' => recordId});
        flow.start();
        LIST<SObject> lightningList = (LIST<SObject>) flow.getVariableValue('records');
        FlowUtility.DynamicResults cleanedUp = flowUtil.disassembleSObjects(applyFieldSet(lightningList, fieldsetName), fActions);
        return JSON.serialize(cleanedUp);
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

    public static List<SObject> applyFieldSet(List<SObject> records, String fieldSetName) {
        FlowUtility flowUtil = new FlowUtility();
        List<String> fieldSetArray = flowUtil.getFieldListFromFieldSetFromSObjectList(records, fieldSetName);
        String fields = string.join(fieldSetArray, ', ');
        String objectType = records.getSObjectType().getDescribe().getLocalName();
        List<Id> ids = new List<Id>();
        for (SObject obj : records) {
            ids.add(obj.Id);
        }
        return Database.query('Select ' + fields + ' FROM ' + objectType + ' Where Id IN (\'' + String.join(ids, '\',\'') + '\')');
    }

    
}