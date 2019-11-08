public class dataTableController {

    @AuraEnabled(cacheable=false)
    public static String togglePerms() {
        switchPerms();
        return assignedPermset();
    }

    @auraEnabled(cacheable=true)
    public static LIST<SObject> listForLightning(String flowName, String recordId){
        
        Flow.Interview flow = Flow.Interview.createInterview(flowName, new MAP<String, Object> {'recordId' => recordId});
        flow.start();
        LIST<SObject> records = (LIST<SObject>) flow.getVariableValue('records');
        return records;
    }

    @auraEnabled(cacheable=false)
    public static String listForLightningWithColumns(String flowName, String recordId, String fieldsetName, string fActions){
        FlowUtility flowUtil = new FlowUtility();
        Flow.Interview flow = Flow.Interview.createInterview(flowName, new MAP<String, Object> {'recordId' => recordId});
        flow.start();
        LIST<SObject> records = (LIST<SObject>) flow.getVariableValue('records');
        FlowUtility.DynamicResults cleanedUp = flowUtil.disassembleSObjects(applyFieldSet(records, fieldsetName), fActions);
        return JSON.serialize(cleanedUp);
    }

    @auraEnabled(cacheable=true)
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
        System.debug('Fieldset fields: ' + fields);
        String objectType = records.getSObjectType().getDescribe().getLocalName();
        List<Id> ids = new List<Id>();
        for (SObject obj : records) {
            ids.add(obj.Id);
        }
        List<SObject> recs = Database.query('Select ' + fields + ' FROM ' + objectType + ' Where Id IN (\'' + String.join(ids, '\',\'') + '\')');
        return recs;
    }

    public static List<SObject> getRecords(String query){
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE,
            [Select Id, Name, Industry From Account]);
        List<Account> accts =  decision.getRecords();
        for (Account acct : accts) {
            System.debug('\nName: ' + acct.Name + '\nIndustry: ' + acct.Industry);
        }
        System.debug('Removed fields: ' + decision.getRemovedFields());
        System.debug('Modified records: ' + decision.getModifiedIndexes());
        return accts;
    }

    public static PermissionSetAssignment getPermsetAssignment(String userId, String permsetId) {
        List<PermissionSetAssignment> psas = [SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :userId AND PermissionSetId = :permsetId];
        if (psas.size() > 0) {
            return psas[0];
        } else {
            return null;
        }
    }
    
    public static PermissionSet getPermset(string permsetName) {
        List<PermissionSet> ps = [SELECT Id, Name FROM PermissionSet WHERE Name = :permsetName];
        if (ps.size() > 0) {
            return ps[0];
        } else {
            return null;
        }
    }
    
    public static String assignedPermset() {
        PermissionSet permset = getPermset('demo');
        String assigneeId = UserInfo.getUserId();
        PermissionSetAssignment permsetAssignment = getPermsetAssignment(assigneeId, permset.Id);
        if (permsetAssignment == null) {
            return 'assigned';
        } else {
            return 'removed';
        }
    }

    public static void switchPerms() {
        PermissionSet permset = getPermset('demo');
        String assigneeId = UserInfo.getUserId();
        PermissionSetAssignment permsetAssignment = getPermsetAssignment(assigneeId, permset.Id);
        if (permsetAssignment == null) {
	        PermissionSetAssignment psa = new PermissionSetAssignment();
	        psa.PermissionSetId = permset.Id;
            psa.AssigneeId = assigneeId;
            insert psa;
        } else {
            delete permsetAssignment;
        }
    }
    
}