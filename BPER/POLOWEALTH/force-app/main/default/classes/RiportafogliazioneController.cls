public without sharing class RiportafogliazioneController {
    @AuraEnabled
    public static List<Riportafogliazione__c> getAllData(String tipoImpurezza){
        List<User> userList=[SELECT Id, idced__c  FROM User WHERE Id=:UserInfo.getUserId()];
        List<Account> fil=[SELECT Id FROM Account WHERE PTF_IdCed__c=:userList[0].idced__c AND RecordType.DeveloperName='FilialeDiRelazione'];
        List<Riportafogliazione__c> returnList = [SELECT Id,  Altro__c, Stato_Spostamento__c,Motivo_di_rifiuto__c, NDG__c, NDGId__r.RecordType.DeveloperName, NDGId__r.Name, NDGId__r.PTF_IndiceSegmentoComportamentale__c, NDGId__r.PTF_Patrimonio__c, NDGId__r.AnnualRevenue, NDGId__r.PTF_Utilizzato__c, NDGId__r.PTF_Accordato__c, MMDS_Obiettivo__c, Portafoglio_Old__c, Portafoglio_Old__r.PTF_ModelloDiServizio__c,Referente__c, Portafoglio_Di_Partenza__c, Portafoglio_Di_Destinazione__c, Portafoglio_Alternativo__c, Portafoglio_Alternativo_Name__c
                                                 FROM Riportafogliazione__c WHERE Tipo_spostamento__c=:tipoImpurezza and Filiale_Old__c=:fil[0].Id];
        return returnList;
    }

    @AuraEnabled
    public static CondWrapper getInfoFiliale(){
        CondWrapper returnwrap= new CondWrapper();
        List<User> userList=[SELECT Id, idced__c  FROM User WHERE Id=:UserInfo.getUserId()];
        List<Account> filialeList=[SELECT Id, PTF_Capofila__c FROM Account WHERE PTF_IdCED__c=:userList[0].idced__c AND RecordType.DeveloperName='FilialeDiRelazione'];
        returnwrap.filialeCondition= 'PTF_Filiale__c=\''+ String.escapeSingleQuotes(filialeList[0].Id)+'\'';
        if(String.isNotBlank(filialeList[0].PTF_Capofila__c)){
            returnwrap.capofilaCondition= 'PTF_Capofila__c=\''+ String.escapeSingleQuotes(filialeList[0].PTF_Capofila__c)+'\'';
        }
        
        return returnwrap;
    }
    @AuraEnabled
    public static void noSpost(Id walletId, List<Id> recordIds, String motivo, String altro){
        List<Riportafogliazione__c> updateList= new List<Riportafogliazione__c>();
        for(Id recordId:recordIds){
            Riportafogliazione__c record = new Riportafogliazione__c();
            record.Id=recordId;
            record.Altro__c=altro;
            record.Motivo_di_rifiuto__c=motivo;
            record.Portafoglio_Alternativo__c=walletId;
            record.Stato_Spostamento__c=false;
            updateList.add(record);
        }
        update updateList;
    }

    @AuraEnabled
    public static void annullaRifiuto(List<Id> recordIds){
        List<Riportafogliazione__c> updateList= new List<Riportafogliazione__c>();
        for(Id recordId:recordIds){
            Riportafogliazione__c record = new Riportafogliazione__c();
            record.Id=recordId;
            record.Altro__c=null;
            record.Motivo_di_rifiuto__c=null;
            record.Portafoglio_Alternativo__c=null;
            record.Stato_Spostamento__c=true;
            updateList.add(record);
        }
        update updateList;
    }
    public class CondWrapper{
        @AuraEnabled public String filialeCondition;
        @AuraEnabled public String capofilaCondition;
    }
}