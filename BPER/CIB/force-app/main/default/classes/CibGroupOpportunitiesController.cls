public with sharing class CibGroupOpportunitiesController {
    
    @AuraEnabled
    public static Map<String, Object> init(String recordId, String whereCondition){
        Map<String, Object> response = new Map<String, Object>{
            'opportunities' => Database.query('SELECT Id, Name, Account.Name, CIB_Nome_Opportunita__c, Owner.Name, StageName, RecordTypeName__c, Tipo_Operazione__c, Desk__c FROM Opportunity WHERE ' +(!String.isBlank(whereCondition) ? '(' + whereCondition + ') AND ' : '') + ' RecordTypeName__c IN (\'Structured Finance\', \'Traditional Banking\',\'Corporate Finance\') AND AccountId IN (SELECT CRM_RelatedAccount__c FROM CRM_LinkedNDG__c WHERE CRM_Account__c =: recordId AND CRM_LinkCode__c IN (\'113\', \'165\'))')
        };
        return response;
    }
}