public with sharing class CRM_OptManagement
{
    @AuraEnabled
    public static List<Opportunity> getOpportunities(Id accountId)
    {
        return [SELECT Id, Name, Account.Name, StageName, Owner.Name, CRM_Canale__c, CRM_Bisogno__c, CloseDate, CRM_EsitoContatto__c, CRM_AssegnatarioFormulaNew__c, CRM_Oggetto__c FROM Opportunity WHERE AccountId = :accountId AND CRM_VisibilitaOpportunita__c = true AND RecordType.DeveloperName != 'Opportunit_per_il_CC' AND CRM_Appuntamento_Presso_Filiale_Diversa__c = false];
    }

    @AuraEnabled
    public static List<Opportunity> getCointestazioni(Id accountId)
    {
        List<CRM_AccountAccountJointOwnershipRelation__c> joints = [SELECT Id, Name, CRM_Account__r.Name, CRM_JointOwnership__c FROM CRM_AccountAccountJointOwnershipRelation__c WHERE CRM_Account__c = :accountId];
        Set<Id> accountIds = new Set<Id>();
        for (CRM_AccountAccountJointOwnershipRelation__c joint : joints )
        {
            accountIds.add(joint.CRM_JointOwnership__c);
        }

        return [SELECT Id, Name, Account.Name, StageName, Owner.Name, CRM_Canale__c, CRM_Bisogno__c, CloseDate, CRM_EsitoContatto__c, CRM_AssegnatarioFormulaNew__c, CRM_Oggetto__c FROM Opportunity WHERE AccountId = :accountIds AND CRM_VisibilitaOpportunita__c = true AND RecordType.DeveloperName != 'Opportunit_per_il_CC' AND CRM_Appuntamento_Presso_Filiale_Diversa__c = false];
    }
}