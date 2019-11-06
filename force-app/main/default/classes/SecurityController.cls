public with sharing class SecurityController {
    public SecurityController() {
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Account> getRecords(){
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
        List<PermissionSet> ps = [SELECT Id FROM PermissionSet WHERE Name = :permsetName];
        if (ps.size() > 0) {
            return ps[0];
        } else {
            return null;
        }
    }
    
    @AuraEnabled(cacheable=false)
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