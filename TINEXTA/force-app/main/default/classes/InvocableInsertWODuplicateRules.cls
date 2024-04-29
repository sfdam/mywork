public class InvocableInsertWODuplicateRules {
             
    //An invocable variable used as input or output variables in the process builder
    public class ActionRequest {
        
        @InvocableVariable(required=true)
        public Lead LeadObject;  
        @AuraEnabled @InvocableVariable 
        public String posizione;
       	@AuraEnabled  @InvocableVariable
        public String societa;
       	@AuraEnabled  @InvocableVariable
        public String fonte;
        @AuraEnabled  @InvocableVariable
        public String fonteLead;
        @AuraEnabled  @InvocableVariable
        public String StatoSegnalazione;
        @AuraEnabled  @InvocableVariable
        public String Origine;
        @AuraEnabled  @InvocableVariable
        public String Omissione;
        @AuraEnabled  @InvocableVariable
        public String RuoloCMK;
        
    }     

    //This invocable method is used for processing the business by taking the input from process builder
    @InvocableMethod(label='Insert senza Duplicate Rules')
    public static List<String> InsertWODuplicateRules(List<ActionRequest> requests){        
    	
        Lead LeadToInsert = requests[0].LeadObject;
      
        String ruolo = requests[0].posizione;
        String soc = requests[0].societa;
        String fon = requests[0].fonte;
        string lead= requests[0].fonteLead;
        String stato= requests[0].StatoSegnalazione;
        string level = requests[0].Origine;
        string omis = requests[0].Omissione;
        String CMKruolo= requests[0].RuoloCMK;
            
       LeadToInsert.Ruolo_ricoperto__c = ruolo;
       LeadToInsert.Fonte_Segnalatore__c = fon;
       LeadToInsert.Societa_di_riferimento__c = soc;
       LeadToInsert.Fonte_Lead_Warrant__c=lead;
       LeadToInsert.Stato_Segnalazione_Warrant__c = stato;
       LeadToInsert.Origine_Lead_Livello_1__c=level;
       LeadToInsert.WRT_Motivazione_omissione_PIVA_CF__c=omis;
       LeadToInsert.Ruolo_ricoperto__c=CMKruolo;
           
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;

        Database.SaveResult sr = Database.insert(LeadToInsert, dml);
        
        List<String> res = new List<String>();
        //List<String> respos = new List<String>();
        
        if( sr.getErrors().size() > 0 ){
            Database.error err = sr.getErrors()[0];
            res.add ('failure | ' + err.getStatusCode() + ': ' + err.getMessage());
           // res.add ('Errore di inserimento, contattare amministratore');
        } else { res.add ('Segnalazione inserita correttamente'); }

        
        return res;
        //return respos;
	}
    
}