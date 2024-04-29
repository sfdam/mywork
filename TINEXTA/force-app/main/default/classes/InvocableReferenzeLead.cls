public class InvocableReferenzeLead {
             
    //An invocable variable used as input or output variables in the process builder
    public class ActionRequest {
        
        @InvocableVariable(required=true)
        public Lead LeadObject;  
        @AuraEnabled @InvocableVariable 
        public String businessarea;
       	@AuraEnabled  @InvocableVariable
        public String societa;
       	@AuraEnabled  @InvocableVariable
        public String statoreferenza;
        @AuraEnabled  @InvocableVariable
        public String Ruolo;
        @AuraEnabled  @InvocableVariable
        public String StatoLead;
        @AuraEnabled  @InvocableVariable
        public String Origine;
        
    }     

    //This invocable method is used for processing the business by taking the input from process builder
    @InvocableMethod(label='Insert senza Duplicate Rules')
    public static List<String> InsertReferenzaDuplicateRules(List<ActionRequest> requests){        
    	
        Lead LeadToInsert = requests[0].LeadObject;
      
        String ruolo = requests[0].Ruolo;
        String soc = requests[0].societa;
        String bu = requests[0].businessarea;
        string lead= requests[0].StatoLead;
        String stato= requests[0].statoreferenza;
        string level = requests[0].Origine;

            
       LeadToInsert.Ruolo_ricoperto__c = ruolo;
       LeadToInsert.Societa_di_riferimento__c = soc;
       LeadToInsert.Stato_Referenza__c=stato;
       LeadToInsert.Status=lead;
       LeadToInsert.Business_Area__c=bu;
       LeadToInsert.Origine_Lead_Livello_1__c=level; 

        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;

        Database.SaveResult sr = Database.insert(LeadToInsert, dml);
        Database.SaveResult idLead = sr;
        system.debug('srList' + idLead.getId());
        
        List<String> res = new List<String>();
        
        if( sr.getErrors().size() > 0 ){
            Database.error err = sr.getErrors()[0];
            res.add ('Errore | ' + err.getStatusCode() + ': ' + err.getMessage());
        } else { res.add (idLead.getId()); }

        
        return res;

	}
    
}