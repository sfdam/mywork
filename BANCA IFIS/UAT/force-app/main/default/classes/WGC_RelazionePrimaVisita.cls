public with sharing class WGC_RelazionePrimaVisita {
	
    public class WrapperResponse{
        
        @AuraEnabled public Account acc;
        @AuraEnabled public RelazionePrimaVisita__c rpv;

        public WrapperResponse(){
            this.acc = acc;
            this.rpv = rpv;
        }
        
    }

    @AuraEnabled
    public static WrapperResponse getRPV(String accountId){

        List<RelazionePrimaVisita__c> rpvList = new List<RelazionePrimaVisita__c>();
        List<Account> accList = new List<Account>();
        WrapperResponse wr = new WrapperResponse();

        rpvList = [SELECT Id, Name, Account__c, Account__r.Name, Settore__c, AnniDiAttivita__c,
                ClientelaFornitoriPub__c, ClientelaFornitoriNaz__c, ClientelaFornitoriPriv__c,
                ClientelaFornitoriEst__c, ConcentrazioneClientelaFornitori__c, DurataMediaRapportoPrincipaliClientiForn__c,
                FornituraOrdinativiCont__c, AppaltoOperaFornituraConPosa__c, FornituraOrdinativiSpot__c,
                AppaltoDiServiziFornOrd__c, FornituraBeni__c, FornituraServizi__c, FatturatoUltimoAnno__c,
                PrevisioneAnnoInCorso__c, FatturatoAnnoPrecedente__c, PrevisioneAnnoSuccessivo__c, Ruolo_referente__c,
                DisponibilitaReferente__c, AtteggiamentoReferente__c, Note__c 
                FROM RelazionePrimaVisita__c WHERE Account__c =: accountId ORDER BY CreatedDate DESC LIMIT 1];
        
        if(!rpvList.isEmpty()){
            wr.rpv = rpvList.get(0);
            wr.acc = null;
            return wr;
        }
        else{
            accList = [SELECT Id, Name FROM Account WHERE Id =: accountId];
            wr.acc = accList.get(0);
            wr.rpv = null;
            return wr;
        }
    }
    
    @AuraEnabled
    public static String SaveRecord(RelazionePrimaVisita__c record){
        System.debug('@@@ record ' + record);
        record.Account__r = null;
        record.Opportunita__r = null;

        if(record.get('Id') != null){
            update record;
        }
        else{
            insert record;
        }

        return 'ok';
    }
}