public class bifis_crm_c_MccNsaHomePageDataTableCtrl {
    
    @AuraEnabled
    public static List < WorkflowMutui__c > fetchWorkflowsMCCForHomePage(String searchFilter) {
        
        List < WorkflowMutui__c > myResult = new List < WorkflowMutui__c >();
        
        // QUERY TO OBTAIN LAST USER WORKFLOWS

		searchFilter = '%' + searchFilter + '%';
        
        myResult = [SELECT Id, Name, PartitaIVA__c, Ragione_Sociale__c, CreatedDate, TOLABEL(Stato__c), DurataTotale__c, Owner.Name, Importo__c, DataInvioIfis__c, Tipologia_Mutuo__c, StatoElaborazione__c FROM WorkflowMutui__c WHERE (PartitaIVA__c like : searchFilter OR Owner.Name like : searchFilter OR Name like : searchFilter) ORDER BY CreatedDate DESC, Stato__c LIMIT 60];
        
        return myResult;
    }
    
    @AuraEnabled
    public static boolean deleteWorkflowMutuiForHomePage(String workflowId) {

        List < WorkflowMutui__c > myResult = new List < WorkflowMutui__c >();
        
        // QUERY TO DELETE SELECTED WORKFLOW
        
        myResult = [SELECT Id FROM WorkflowMutui__c WHERE Id = :workflowId];
     
        if(myResult.size() == 1){
            
            try {
                
                delete myResult;
                return true;
                
            } catch (DmlException e) {
                
				System.debug(e);

                return false;
                
            }            
            
        }
        
        return false;
    }
}