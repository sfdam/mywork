/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-05-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   09-14-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public class treeGridPatriaPotestaController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static Map<String,SObject> getAllData(String recordId, String recordType){
        System.debug('EDB getAllData recordId: ' + recordId);
        System.debug('EDB getAllData recordType: ' + recordType);

        Map<String,SObject> mFigli = new Map<String,SObject>();

        try {
            if(recordType == 'PersonAccount') {
                System.debug('AAA recordType '+recordType);
                System.debug('AAA recordId '+recordId);
                Set<Id> idFigli = new Set<Id>();
                Set<Id> idAccount = new Set<Id>();
                // recupero lista CRM_Account__c dove CRM_RelatedAccount__c = recordId (padre)
                List<CRM_LinkedNDG__c> parentLinkedNDG = [
                    SELECT  Id,
                            CRM_Account__c,
                            CRM_RelatedAccount__c,
                            CRM_LinkCode__c
                    FROM CRM_LinkedNDG__c
                    WHERE CRM_RelatedAccount__c=:recordId
                    AND CRM_LinkCode__c = '118'
                ];
                if (parentLinkedNDG!=null && parentLinkedNDG.size()>0) {
                    for (CRM_LinkedNDG__c ndg :parentLinkedNDG) {
                        idFigli.add(ndg.CRM_Account__c);
                    }
                }
                idFigli.add(recordId);
                // recupero le informazioni dove recordId coindice con CRM_Account__c (figlio)
                mFigli = SV_Utilities.keyBy([
                    SELECT  Id,
                    CRM_Account__c,
                    CRM_Account__r.Name,
                    CRM_Account__r.CRM_NDG__c,
                    CRM_Account__r.Filiale__c,
                    CRM_Account__r.PTF_TipoCollegamento__c,
                    CRM_Account__r.PTF_DescTipoCollegamento__c,
                    CRM_Account__r.PTF_NaturaGiuridica__c,
                    CRM_Account__r.PTF_Filiale__c,
                    CRM_Account__r.PTF_Filiale__r.Name,
                    CRM_RelatedAccount__c,
                    CRM_RelatedAccount__r.Name,
                    CRM_RelatedAccount__r.CRM_NDG__c,
                    CRM_RelatedAccount__r.Filiale__c,
                    CRM_RelatedAccount__r.PTF_Filiale__c,
                    CRM_RelatedAccount__r.PTF_Filiale__r.Name,
                    CRM_RelatedAccount__r.PTF_TipoCollegamento__c,
                    CRM_RelatedAccount__r.PTF_DescTipoCollegamento__c,
                    CRM_RelatedAccount__r.PTF_NaturaGiuridica__c,
                    CRM_LinkCode__c,
                    CRM_LinkType__c
                    FROM CRM_LinkedNDG__c
                    WHERE CRM_LinkCode__c = '118'
                    AND CRM_Account__c IN:idFigli
                ], '{CRM_Account__c}_{CRM_RelatedAccount__c}',true);
            }

        } catch(System.CalloutException e) { 
            //Exception handling goes here.... retry the call, whatever 
            System.debug('SV CalloutException ' + e);
 
        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return mFigli;

    }

    @AuraEnabled
    public static Account getRecordInfo(String recordId){
        System.debug('SV getRecordInfo recordId: ' + recordId);

        
        return [ SELECT Id, Name, RecordTypeId, RecordType.DeveloperName FROM Account WHERE Id =: recordId ];

    }
}