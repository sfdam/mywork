public class InvocableRinnoviRules {
             
    //An invocable variable used as input or output variables in the process builder
    public class ActionRequest {

        //in ingresso prendo i tre vettori quote, quoteline e opportunity
        @InvocableVariable(required=true)
        public SBQQ__Quote__c QuoteObject;
        @InvocableVariable(required=true)
        public SBQQ__QuoteLine__c QuoteLineObject;
   

        //Elenco dei campi screen
        @AuraEnabled @InvocableVariable 
        public String tipoprogetto;
       	@AuraEnabled  @InvocableVariable
        public String progetto;
       	@AuraEnabled  @InvocableVariable
        public String mandato;

        
        //Elenco Campi Picklist da fare a mano
        @AuraEnabled  @InvocableVariable
        public String pickmandato;
        @AuraEnabled  @InvocableVariable
        public String pickfattura;
        @AuraEnabled  @InvocableVariable
        public String pickprogetto;
        @AuraEnabled  @InvocableVariable
        public String pickesercizio; 
        @AuraEnabled  @InvocableVariable
        public String pickeofferta;
        @AuraEnabled  @InvocableVariable
        public String PickAnnocompotenza;
        @AuraEnabled  @InvocableVariable
        public String MandatopOpp;
        @AuraEnabled  @InvocableVariable
        public String PickGruppo;
        @AuraEnabled  @InvocableVariable
        public String PickDomanda;
        @AuraEnabled  @InvocableVariable
        public String AziendaQuote;
        @AuraEnabled  @InvocableVariable
        public String AziendaQuoteLine;
       
    }     

    //This invocable method is used for processing the business by taking the input from process builder
    @InvocableMethod(label='Update Rinnovi')
    public static List<String> UpdateRinnoviCheck(List<ActionRequest> requests){        
    	
        //Record
        SBQQ__Quote__c QuoteUpdate= requests[0].QuoteObject;
        SBQQ__QuoteLine__c QuoteLineUpdate= requests[0].QuoteLineObject;


SBQQ.TriggerControl.disable();        
      
        String tipologiaprog = requests[0].tipoprogetto;
        String prog = requests[0].progetto;
        String tipomandato = requests[0].mandato;
        String pickesercizio=requests[0].pickesercizio;
        String pickfattura = requests[0].pickfattura;
        String pickmandato=requests[0].pickmandato;
        String pickprogetto=requests[0].pickprogetto;
        String pickeofferta=requests[0].pickeofferta;
        String PickAnnocompotenza=requests[0].PickAnnocompotenza;
        String MandatopOpp=requests[0].MandatopOpp;
        String PickGruppo= requests[0].PickGruppo;
        String TipoDomanda= requests[0].PickDomanda;
		String AziendaQuote= requests[0].AziendaQuote;
        String AziendaQuoteLine= requests[0].AziendaQuoteLine;
        

    
    //Senza Condizioni

    //OpportunityUpdate.StageName=pickeofferta;
    QuoteUpdate.StageName__c=pickeofferta;
    //Anno di competenza su QuoteLine
    //QuoteLineUpdate.Anno_di_competenza__c = PickAnnocompotenza;
    QuoteLineUpdate.WRT_altro_fattura__c=pickfattura;
    //QuoteLineUpdate.WRT_esercizio__c= QuoteLineUpdate.WRT_esercizio__c + pickesercizio;
    QuoteLineUpdate.WRT_esercizio__c= pickesercizio;
    QuoteLineUpdate.Tipo_domanda__c=TipoDomanda;
    QuoteLineUpdate.Azienda_WarrantCPQ__c=AziendaQuoteLine;
    QuoteUpdate.Azienda_WarrantCPQ__c=AziendaQuote;


    if(tipologiaprog != pickprogetto && tipologiaprog!= null && pickprogetto!= null){
        QuoteLineUpdate.WRT_tipo_progetto__c= tipologiaprog;
    }
    else{
        QuoteLineUpdate.WRT_tipo_progetto__c=pickprogetto;
    } 
    //if (prog != QuoteLineUpdate.WRT_progetto__c && prog!= null){

    //}
    if (tipomandato != pickmandato && tipomandato!= null){
        QuoteLineUpdate.Tipo_Mandato__c=tipomandato;
    }else{
        QuoteLineUpdate.Tipo_Mandato__c=pickmandato;
    }

        

           
        Database.DMLOptions dml = new Database.DMLOptions();
		dml.DuplicateRuleHeader.AllowSave = true;

        Database.SaveResult sq = Database.update(QuoteUpdate, dml);
        
        Database.SaveResult sql = Database.update(QuoteLineUpdate, dml);
        
       // Database.SaveResult so = Database.update(OpportunityUpdate, dml);
        
        List<String> res = new List<String>();

        
        
        if( sq.getErrors().size() > 0){
            Database.error errq = sq.getErrors()[0];
            res.add ('failure Quote | ' + errq.getStatusCode() + ': ' + errq.getMessage());
        } else if(sql.getErrors().size() > 0){
              Database.error errql = sql.getErrors()[0];
            res.add ('failure QuoteLine| ' + errql.getStatusCode() + ': ' + errql.getMessage());
        } /*else if(so.getErrors().size() > 0){
            Database.error errop=so.getErrors()[0];       
            res.add ('failure QuoteLine| ' + errop.getStatusCode() + ': ' + errop.getMessage());
        }*/else { res.add ('Rinnovo Inserito Correttamente '); }
        
        return res;

	}
    
}