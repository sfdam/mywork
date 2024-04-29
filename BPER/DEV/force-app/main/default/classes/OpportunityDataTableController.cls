public class OpportunityDataTableController {
    @AuraEnabled
    public static List<Opportunity> getAllData(String recordId, Integer pagina){
        List<Opportunity> opps = new List<Opportunity>();
        if(pagina==1){
            opps=[SELECT Id, Name, CreatedDate, toLabel(CRM_ProductCategory__c), toLabel(StageName), CRM_OriginCC__c, CRM_NotAnsweredIcon__c, 
                        CreatedBy.Name, CRM_RecallDate__c, CRM_AppointmentDateAtTheBranch__c, CRM_AppointmentBranchName__c, Owner.Name
                          FROM Opportunity 
                          WHERE AccountId=:recordId ORDER BY CreatedDate DESC];
    
           
        }
        if(pagina==2){
            opps=[SELECT Id, Name, CreatedDate, toLabel(CRM_ProductCategory__c), toLabel(StageName), CRM_OriginCC__c, CRM_NotAnsweredIcon__c, 
                        CreatedBy.Name, CRM_RecallDate__c, CRM_AppointmentDateAtTheBranch__c, CRM_AppointmentBranchName__c, Owner.Name
                          FROM Opportunity 
                          WHERE AccountId IN (SELECT AccountId FROM Case WHERE Id=:recordId) ORDER BY CreatedDate DESC];
        }
        
        return opps;
    }
}