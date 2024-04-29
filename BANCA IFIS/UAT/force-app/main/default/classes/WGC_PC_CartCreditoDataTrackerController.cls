public with sharing class WGC_PC_CartCreditoDataTrackerController {

    @AuraEnabled(cacheable=false)
    public static List<WGC_PC_CartCreditoDataTracker__mdt> getMetadata(){
        List<WGC_PC_CartCreditoDataTracker__mdt> x = [ SELECT Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, 
                                                        sezione__c, formatter__c, readOnly__c, visibility__c, required__c, apiName__c, type__c,
                                                        options__c, formulaReadOnly__c, formulaVisibility__c, formulaDefaultValue__c,
                                                        posizioneSezione__c, posizioneField__c, sizeField__c, buttonActionName__c
                                                    FROM WGC_PC_CartCreditoDataTracker__mdt
                                                    ORDER BY posizioneSezione__c, posizioneField__c ASC ];      
        
        
        System.debug('SV getMetadata: ' + x);
        return x;
    }

    
    // public static WGC_Valore_IRR__mdt getValoriIRR(String optyRT){
	// AM. SDHDFNZ-101026 - Gestione valori mdt storici
    //public static WGC_Valore_IRR__mdt getValoriIRR(){
    @AuraEnabled(cacheable=true)
	public static WGC_Valore_IRR__mdt getValoriIRR(Id opportunitaId){
        String type = 'Procedure';
        // if( optyRT == 'IFISOpportunitaFastFinance'){
        //     type = 'Procedure';
        // } else {
        //     type = 'InBonis';
        // }
		Opportunity opp = [SELECT Id, Name, WGC_Data_Fase_Valutazione_Pratica__c FROM Opportunity WHERE Id =: opportunitaId];
        Date Data_Fase_Valutazione_Pratica = (opp.WGC_Data_Fase_Valutazione_Pratica__c != null ? opp.WGC_Data_Fase_Valutazione_Pratica__c : Date.today());
		//return [SELECT Id, Costo_Denaro__c, Spread__c, Tasso_di_riferimento__c, Tasso_interesse_attivo__c FROM WGC_Valore_IRR__mdt WHERE DeveloperName =: type LIMIT 1];
		return [SELECT Id, Costo_Denaro__c, Spread__c, Tasso_di_riferimento__c, Tasso_interesse_attivo__c FROM WGC_Valore_IRR__mdt WHERE Tipo_Credito__c =: type AND Inizio_Validita__c <=: Data_Fase_Valutazione_Pratica AND Fine_Validita__c >=: Data_Fase_Valutazione_Pratica];
    }

    @AuraEnabled
    public static WrapperResponse saveCredito(String credito){
        System.debug('SV Credito__c: ' + credito);
        WrapperResponse response = new WrapperResponse();

        try{

            Credito__c customObject = (Credito__c)JSON.deserialize(credito, Sobject.class);

            Upsert customObject;
            response.data.add(credito);
        } catch(exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    public class WrapperResponse{
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = '';
            this.success = true;
        }
    }


}