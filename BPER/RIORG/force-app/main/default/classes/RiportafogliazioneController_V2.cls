public without sharing class RiportafogliazioneController_V2 {
    @AuraEnabled

    public static List<User> init(){
        List<User> userList=[SELECT Id, idced__c,Profilo__c FROM User WHERE Id=:UserInfo.getUserId()];
        return userList;
    }

    @AuraEnabled
    public static List<Riportafogliazione__c> getAllData(String tipoImpurezza, String sottoTipologiaSpostamento){
        List<User> userList=[SELECT Id, idced__c, Profilo__c  FROM User WHERE Id=:UserInfo.getUserId()];
        String query = 'SELECT Id, Altro__c,Stato_Spostamento__c,Motivo_di_rifiuto__c, NDG__c, NDGId__r.RecordType.DeveloperName, NDGId__r.Name, NDGId__r.PTF_IndiceSegmentoComportamentale__c, NDGId__r.PTF_Patrimonio__c, NDGId__r.AnnualRevenue, NDGId__r.PTF_Utilizzato__c, NDGId__r.PTF_Accordato__c, MMDS_Obiettivo__c, Portafoglio_Old__c, Portafoglio_Old__r.PTF_ModelloDiServizio__c,Referente__c, Portafoglio_Di_Partenza__c, Portafoglio_Di_Destinazione__c, Portafoglio_Alternativo__c, Filiale_New__c, Portafoglio_New__r.PTF_ModelloDiServizio__c, Portafoglio_Alternativo_Name__c' +
        ' FROM Riportafogliazione__c WHERE NDGId__c != NULL AND Tipo_spostamento__c=:tipoImpurezza AND Tipologia_Clientela__c=:sottoTipologiaSpostamento';
        if(userList[0].Profilo__c != 'NEC_D.0'){
            List<Account> fil=[SELECT Id FROM Account WHERE PTF_IdCed__c=:userList[0].idced__c AND RecordType.DeveloperName='FilialeDiRelazione'];
            String filialeId = fil[0].Id;
            query += ' AND Filiale_Old__c=:filialeId';
        }
        List<Riportafogliazione__c> returnList = Database.query(query);
        return returnList;
    }

    @AuraEnabled
    public static List<Riportafogliazione_Conf__c> getInfoConfig(String tipoImpurezza, String sottoTipologiaSpostamento){
        List<User> userList=[SELECT Id, idced__c  FROM User WHERE Id=:UserInfo.getUserId()];
        List<Account> fil=[SELECT Id, ptf_direzioneregionale__c FROM Account WHERE PTF_IdCed__c=:userList[0].idced__c AND RecordType.DeveloperName='FilialeDiRelazione'];        
        List<Riportafogliazione_Conf__c> returnList = [SELECT id,  PTF_Direzione_Territoriale__r.Name, PTF_Id_Ced__c, PTF_ABI__c, Perc_Affinamento__c, Tipologia_Spostamento__c, Sottotipologia_Spostamento__c 
                                                       FROM Riportafogliazione_Conf__c WHERE Tipologia_Spostamento__c=:tipoImpurezza AND PTF_Direzione_Territoriale__c =:fil[0].ptf_direzioneregionale__c AND Sottotipologia_Spostamento__c=:sottoTipologiaSpostamento];
        return returnList;
    }

    @AuraEnabled
    public static void updateValues(List<Riportafogliazione__c> recordsToUpdate) {
        try {        
            update recordsToUpdate;
        } catch (Exception e) {
            System.debug('err: ' + e.getMessage());
        }
    }

     @AuraEnabled
    public static Map<String, String> checkPortafoglioExists(List<String> nomePTFSet){
        Map<String, String> nomePTMap = new Map<String, String>();
        for(Wallet__c wallet : [SELECT id,Name, PTF_Filiale__c, PTF_ModelloDiServizio__c FROM Wallet__c WHERE Name IN: nomePTFSet]){
            nomePTMap.put(wallet.Name, wallet.Id);
        }
        return nomePTMap;
    }

    
    public class CondWrapper{
        @AuraEnabled public String filialeCondition;
        @AuraEnabled public String capofilaCondition;
    }
}