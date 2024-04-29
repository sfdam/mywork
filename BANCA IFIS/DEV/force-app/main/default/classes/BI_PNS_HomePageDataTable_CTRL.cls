public class BI_PNS_HomePageDataTable_CTRL  {
    
    @AuraEnabled
    public static List < WorkflowMutui__c > fetchWorkflowsMCCForHomePage(String searchFilter, String searchFilterHorizon) {
        
        List < WorkflowMutui__c > myResult = new List < WorkflowMutui__c >();
        
        // QUERY TO OBTAIN LAST USER WORKFLOWS

		String inProgressMutuiWorkflowState = 'BOZZA_DATI';
		String elaboratedMutuiWorkflowState = 'INVIATA';
		String defaultHorizonValue = 'ULTIME';

		searchFilter = '%' + searchFilter + '%';
        
		if(String.isEmpty(searchFilterHorizon))
			searchFilterHorizon = defaultHorizonValue;

		String theQuery = '';

		// RICERCA PRATICHE RECENTI E TUTTE LE PRATICHE

		if(searchFilterHorizon != defaultHorizonValue){

			theQuery = 'SELECT Id, Name, PartitaIVA__c, Ragione_Sociale__c, CreatedDate, TOLABEL(Stato__c), Owner.Name, Importo__c, DataInvioIfis__c, Tipologia_Mutuo__c, StatoElaborazione__c FROM WorkflowMutui__c WHERE (PartitaIVA__c like : searchFilter OR Owner.Name like : searchFilter OR Name like : searchFilter) ORDER BY Name DESC'; 
        
		}
		else {

			theQuery = 'SELECT Id, Name, PartitaIVA__c, Ragione_Sociale__c, CreatedDate, TOLABEL(Stato__c), Owner.Name, Importo__c, DataInvioIfis__c, Tipologia_Mutuo__c, StatoElaborazione__c FROM WorkflowMutui__c WHERE ((Stato__c = :elaboratedMutuiWorkflowState AND DataInvioIfis__c = LAST_N_DAYS:7) OR (Stato__c != :elaboratedMutuiWorkflowState)) AND (PartitaIVA__c like : searchFilter OR Owner.Name like : searchFilter OR Name like : searchFilter) ORDER BY CreatedDate DESC, Name DESC';
		}

		myResult = Database.query(theQuery);

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