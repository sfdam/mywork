public class bifis_crm_c_SGAHomePageDataTableCtrl {
    
    @AuraEnabled
    public static List < WorkflowSGA__c > fetchWorkflowsSGAForHomePage(String searchFilter) {
        
        List < WorkflowSGA__c > myResult = new List < WorkflowSGA__c >();
        
        // QUERY TO OBTAIN LAST USER WORKFLOWS

		searchFilter = '%' + searchFilter + '%';
        
        myResult = [SELECT Id, Name, PartitaIVA__c, Ragione_Sociale__c, CreatedDate, TOLABEL(Stato__c), Owner.Name, DataInvioIfis__c FROM WorkflowSGA__c WHERE (PartitaIVA__c like : searchFilter OR Owner.Name like : searchFilter OR Name like : searchFilter) ORDER BY CreatedDate DESC, Stato__c LIMIT 20];

        return myResult;
    }    
    
    
    @AuraEnabled
    public static boolean deleteWorkflowSGAForHomePage(String workflowId) {
        
        List < WorkflowSGA__c > myResult = new List < WorkflowSGA__c >();
        
        // QUERY TO DELETE SELECTED WORKFLOW
        
        myResult = [SELECT Id FROM WorkflowSGA__c WHERE Id = :workflowId];
        
        if(myResult.size() == 1){
            
            try {
                
                delete myResult;
                return true;
                
            } catch (DmlException e) {
                
                return false;
                
            }            
            
        }
        
        return false;
    }    
    
}