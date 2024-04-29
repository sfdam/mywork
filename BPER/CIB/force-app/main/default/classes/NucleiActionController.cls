/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-08-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-02-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public without sharing class NucleiActionController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    
    @AuraEnabled
    public static Account assegnaCaponucleo(Account rec) {

        try {
            List<Account> ndg = [
                SELECT  Id,
                        PTF_Nucleo__c,
                        PTF_Caponucleo__c
                FROM Account 
                WHERE PTF_Nucleo__c =:rec.PTF_Nucleo__c
                AND PTF_Caponucleo__c=TRUE
            ];
            if (ndg!=null && ndg.size()>0) {
                for (Account acc : ndg) {
                    acc.PTF_Caponucleo__c = false;
                }
                rec.PTF_Caponucleo__c = true;
                ndg.add(rec);
                update ndg;
            }
            else {
                rec.PTF_Caponucleo__c = true;
                update rec;
            }
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage()); 
        }
        return rec;
    }

    @AuraEnabled
    public static Account eliminaNDGDaNucleo(Account rec) {
        try {
            Nucleo__c nucleo = new Nucleo__c();
            insert nucleo;
            rec.PTF_Nucleo__c = nucleo.Id;
            rec.PTF_Caponucleo__c = true;
            update rec;
        }
        catch (Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return rec;
    }

    @AuraEnabled
    public static Account getNDG(Id recordId) {
        Account acc = null;
        try {
            acc = [
                SELECT  Id,
                        PTF_Nucleo__c,
                        PTF_Caponucleo__c,
                        RecordType.DeveloperName
                FROM Account
                WHERE Id =:recordId
            ];
        }
        catch(Exception exc) {
            throw new AuraHandledException(exc.getMessage());
        }
        return acc;
    }

    @AuraEnabled
    public static WrapperObj getNDG_aggiungiNDG(Id recordId){
        
        WrapperObj response = new WrapperObj();
        Map<String, SObject> capiNucleo = new Map<String, SObject>();
        

        try { 

            Account record = [ SELECT Id, PTF_Nucleo__c FROM Account WHERE Id =: recordId];
                                                               
            //Indiretti Nuclei
            List<String> nuclei = new List<String>();                                         
                List<Account> accListInd = [SELECT Id, PTF_Nucleo__c FROM Account WHERE PTF_Portafoglio__c IN (SELECT PTF_MicroWallet__c FROM Assignment__c WHERE PTF_Gestore__r.PTF_User__c =: UserInfo.getUserId() AND RecordType.DeveloperName = 'Primario' AND PTF_EndDate__c = null) AND Id !=: recordId AND PTF_Portafoglio__c != NULL AND PTF_DeletionDate__c = NULL ];
                for(Account acc:accListInd){
                    if(String.isNotBlank(acc.PTF_Nucleo__c)){
                        nuclei.add(acc.PTF_Nucleo__c);
                    }
                }
            

            
            /*Diretti Nuclei
            if(String.isNotBlank(record.PTF_Nucleo__c)){
                List<Account> accListDir= [SELECT Id, PTF_Nucleo__c, PTF_Portafoglio__c FROM Account WHERE PTF_Nucleo__c=:record.PTF_Nucleo__c];
                List<String> portafogliId= new List<String>();
                for(Account acc:accListDir){
                    if(String.isNotBlank(acc.PTF_Portafoglio__c)){
                        portafogliId.add(acc.PTF_Portafoglio__c);
                    }
                }
                List<Account> accPortList= [SELECT Id, PTF_Nucleo__c FROM Account WHERE PTF_Portafoglio__c IN:portafogliId and Id !=: recordId];
                for(Account acc:accPortList){
                    if(String.isNotBlank(acc.PTF_Nucleo__c)){
                        nuclei.add(acc.PTF_Nucleo__c);
                    }
                }
            }*/
            

            capiNucleo =  SV_Utilities.keyBy([ SELECT Id, Filiale__c, Name, PTF_NaturaGiuridica__c, CRM_NDG__c, PTF_Nucleo__c 
                                                    FROM Account
                                                    WHERE PTF_Caponucleo__c = true AND PTF_Nucleo__c IN:nuclei ], 'Id', false);
            
                                                    
            List<Account> accListNuc= [SELECT Id, PTF_Nucleo__c FROM Account WHERE PTF_Nucleo__c IN:nuclei];
            Map<String,String> mapNucleoNumero = new Map<String,String>();
            for(String n:nuclei){
                Integer count=0;
                for(Account acc:accListNuc){
                    if(n==acc.PTF_Nucleo__c){
                        count=count+1;
                    }
                    mapNucleoNumero.put(n,String.valueOf(count));
                }
                
            }
            response.accMap=capiNucleo;
            response.numeroMembri=mapNucleoNumero;
            
             //Lista Account di quei Nuclei          
             //Mappa <Id del CapoNucleo, Numero di Membri del Nucleo>
            /*for(String capoNucleoId:capiNucleo.keySet()){
                String str=JSON.serialize(capiNucleo.get(capoNucleoId));
                JSON.deserialize(str, Map<String,String>.class);
                System.Debug('@@@@@: '+str);
                
                
            }*/
            



        } catch(System.CalloutException e) { 
            //Exception handling goes here.... retry the call, whatever 
            System.debug('SV CalloutException ' + e);
 
        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return response;
    }
    public class WrapperObj {

        @AuraEnabled public Map<String, SObject> accMap;
        @AuraEnabled public Map<String, String> numeroMembri;

    }
}