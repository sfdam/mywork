public without sharing class BI_PSE_HomePageDataTable_CTRL  {
    
    @AuraEnabled
    public static List < WorkflowSegnalatori__c > fetchWorkflowsSegnalazioniForHomePage(String searchFilter) {
        
        List < WorkflowSegnalatori__c > myResult = new List < WorkflowSegnalatori__c >();
        
        // QUERY TO OBTAIN LAST USER WORKFLOWS

		String inProgressWorkflowState = 'BOZZA_DATI';
		String elaboratedWorkflowState = 'INVIATA';

		searchFilter = '%' + searchFilter + '%';

		String theQuery = '';

		// RICERCA PRATICHE RECENTI E TUTTE LE PRATICHE

		String userId = UserInfo.getUserId();
		String enteSegnalante = '';
		List<User> codiceEnteSegnalante = [SELECT Id, Contact.Account.BI_CodiceAccordo__c FROM User WHERE Id =: userId];
		if (codiceEnteSegnalante != null && codiceEnteSegnalante.size() > 0){
			enteSegnalante = codiceEnteSegnalante[0].Contact.Account.BI_CodiceAccordo__c;
		}

		theQuery = 'SELECT Id, Name, NomeReferente__c, CognomeReferente__c, PartitaIVA__c, Ragione_Sociale__c, CreatedDate, TOLABEL(Stato__c), Owner.Name, DataInvioIfis__c, Tipo_Segnalazione__c, TOLABEL(Tipologia_Segnalazione__c), TOLABEL(MotivazioneRifiutoPrevalutazione__c), TOLABEL(OpportunitaCollegata__r.StageName), TOLABEL(OpportunitaCollegata__r.CategoriaChiusuraTrattativa__c),OpportunitaCollegata__r.Owner.Name, OpportunitaCollegata__r.Owner.Phone,  OpportunitaCollegata__r.Commerciale_Cross_Selling__c, OpportunitaCollegata__r.Telefono_Commerciale_Cross_Selling__c FROM WorkflowSegnalatori__c WHERE (PartitaIVA__c like : searchFilter OR Name like : searchFilter OR Ragione_Sociale__c like : searchFilter) AND Ente_segnalante__c =:enteSegnalante ORDER BY CreatedDate DESC'; 
        
		myResult = Database.query(theQuery);

        return myResult;
    }
    
    @AuraEnabled
    public static boolean deleteWorkflowSegnalazioniForHomePage(String workflowId) {

        List < WorkflowSegnalatori__c > myResult = new List < WorkflowSegnalatori__c >();
        
        // QUERY TO DELETE SELECTED WORKFLOW
        
        myResult = [SELECT Id FROM WorkflowSegnalatori__c WHERE Id = :workflowId];
     
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