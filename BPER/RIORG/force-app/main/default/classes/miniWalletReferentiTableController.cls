public with sharing class miniWalletReferentiTableController {

    @AuraEnabled
    public static List<Assignment__c> getReferenti(String miniwalletId){
        List<Assignment__c> referenti = new List<Assignment__c>();
        MiniWallet__c miniwalletc = [SELECT PTF_Portafoglio__c FROM MiniWallet__c WHERE Id =: miniwalletId LIMIT 1];
        Id walletid = miniwalletc.PTF_Portafoglio__c;
        referenti = [SELECT Id, PTF_Gestore__c, PTF_Gestore_Name__c, PTF_RegistrationNumber__c, PTF_Filiale__c, PTF_ModelloDiServizio__c, PTF_MiniPortafoglio__c
                    FROM Assignment__c
                    WHERE PTF_MicroWallet__c =: walletId
                    AND PTF_EndDate__c = NULL
                    AND PTF_MiniPortafoglio__c = NULL];
        return referenti;
    }

    @AuraEnabled
    public static List<Assignment__c> getReferentiAssegnati(String miniwalletId){
        List<Assignment__c> referentiAssegnati = new List<Assignment__c>();
        referentiAssegnati = [SELECT Id, PTF_Gestore__c, PTF_Gestore_Name__c, PTF_RegistrationNumber__c, PTF_Filiale__c, PTF_ModelloDiServizio__c, PTF_MiniPortafoglio__c
                    FROM Assignment__c
                    WHERE PTF_MiniPortafoglio__c =: miniwalletId
                    AND PTF_EndDate__c = NULL];
        return referentiAssegnati;
    }

    @AuraEnabled
    public static Map<String, String> getReferentePrimario(String miniwalletId){
        String referentePrimarioName = 'si è verificato un errore';
        String idReferentePrimario = '';
        try{
            List<MiniWallet__c> currentMiniwallet = [SELECT Referente__c, Referente__r.Name FROM MiniWallet__c WHERE Id =: miniwalletId LIMIT 1];
            if(currentMiniwallet != null && currentMiniwallet.size() == 1 && currentMiniwallet.get(0).Referente__c != null){
                referentePrimarioName = currentMiniwallet.get(0).Referente__r.Name;
                idReferentePrimario = currentMiniwallet.get(0).Referente__c;
            }else{
                referentePrimarioName = 'nessun referente primario selezionato';
            }        
        }catch(Exception e){
            System.debug('AdF getReferentePrimarioName exception: ' + e.getMessage());
        }

        return new Map<String, String>{
            'name' => referentePrimarioName,
            'id' => idReferentePrimario
        };
    }

    @AuraEnabled
    public static void AssegnaReferenti(String miniWalletID, List<Assignment__c> referenti, List<Assignment__c> referentePrincipale){

        if(miniWalletID != null && referenti != null && miniWalletID != '')
        {

            try{
                
                if(referenti.size() > 0){
                    for(Assignment__c referente : referenti){
                        referente.PTF_MiniPortafoglio__c = miniWalletID;
                    }
                    update referenti;
                }

                if(referentePrincipale != null && referentePrincipale.size() == 1){
                    MiniWallet__c miniwalletc = [SELECT Referente__c FROM MiniWallet__c WHERE Id =: miniwalletId LIMIT 1];
                    miniwalletc.Referente__c = referentePrincipale.get(0).PTF_Gestore__c;
                    update miniwalletc;
                }

            }catch(Exception e){
                System.debug('error AssegnaReferenti: ' + e.getMessage());
            }

        }

    }

    @AuraEnabled
    public static void deleteReferente(String assignment, String referente, String referentePrimario, String miniWalletId){
        try {
            update new Assignment__c (Id = assignment, PTF_MiniPortafoglio__c = null);
            if(referente == referentePrimario){
                update new MiniWallet__c(Id =miniWalletId, Referente__c = null);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void addReferente(List<Assignment__c> referenti, String miniWalletId){
        try {
            for(Assignment__c assignment : referenti){

                assignment.PTF_MiniPortafoglio__c = miniWalletId;
            }
            update referenti;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void addReferentePrimario(String gestore, String miniWalletId){
        try {
            update new MiniWallet__c(Id =miniWalletId, Referente__c = gestore);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}