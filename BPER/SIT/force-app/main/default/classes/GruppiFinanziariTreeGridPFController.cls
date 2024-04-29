public class GruppiFinanziariTreeGridPFController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static WrapperObj getAllData(String recordId, String recordType){
        System.debug('SV getAllData recordId: ' + recordId);
        System.debug('SV getAllData recordType: ' + recordType);

        WrapperObj response = new WrapperObj();

        Map<String, SObject> accMap = new Map<String, SObject>();
        Map<String, SObject> accInGruppiFMap = new Map<String, SObject>();
        Map<String, SObject> gruppiFMap = new Map<String, SObject>();
        Set<String> accGruppoId = new Set<String>();
        Set<String> accId = new Set<String>();

        Set<Id> accToSearch = new Set<Id>();



        try {

            accMap = SV_Utilities.keyBy([SELECT Id, Name, ParentId, PTF_Filiale__c, PTF_Filiale__r.Name, CRM_NDG__c, CRM_VAT__c,  PTF_NaturaGiuridica__c,PTF_TipoCollegamento__c, PTF_DescTipoCollegamento__c,  PTF_Capogruppo__c,
                                            PTF_Portafoglio__c, PTF_Portafoglio__r.PTF_ModelloDiServizio__c, PTF_Portafoglio__r.Name, PTF_OFS__c,PTF_RiportafogliazioneTAG__c,PTF_MiniPortafoglio__c,PTF_MiniPortafoglio__r.PTF_SL__r.Name,
                                            ModelloDiServizio__c,PTF_SegmentoComportamentale__c
                                            //(SELECT CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Account__c  FROM CRM_LinkedNDG__r)
                                        FROM Account
                                        WHERE PTF_Portafoglio__c =: recordId AND 
                                            PTF_DeletionDate__c = NULL ], 'Id', false);

            // accMap = SV_Utilities.keyBy([ SELECT Id, Name, ParentId, PTF_Gruppo__c, PTF_NaturaGiuridica__c, PTF_Portafoglio__c, 
            //             PTF_Portafoglio__r.PTF_ModelloDiServizio__c, PTF_Portafoglio__r.Name,
            //             Filiale__c, PTF_Filiale__c, PTF_Filiale__r.Name, CRM_NDG__c, CRM_VAT__c, PTF_GruppoGestionale__c, PTF_OFS__c
            //         FROM Account
            //         WHERE PTF_Gruppo__c IN : gruppiFSet AND PTF_Portafoglio__c != NULL AND PTF_DeletionDate__c = NULL Order By PTF_Capogruppo__c DESC], 'Id', false);
            System.debug('DK AssignAccMap: ' + accMap);
            
            response.accMap = accMap;

            for (Id aId : accMap.keySet()) {
                accToSearch.add(aId);
            }

            //Select Id Account
            List<CRM_LinkedNDG__c> accList = [SELECT Id, CRM_Account__c, CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Status__c FROM CRM_LinkedNDG__c WHERE CRM_RelatedAccount__c IN : accToSearch AND CRM_LinkCode__c IN ('113', '165') AND CRM_Status__c='A' ORDER BY CRM_LinkCode__c ASC ];
            
            Map<String,CRM_LinkedNDG__c> accToLinkObj= new Map<String,CRM_LinkedNDG__c>();
            for(CRM_LinkedNDG__c acc: accList){
                accGruppoId.add(acc.CRM_Account__c);
                accId.add(acc.CRM_RelatedAccount__c);
                accToLinkObj.put(acc.CRM_RelatedAccount__c, acc);
            }
            response.accToLinkObj=accToLinkObj;

            gruppiFMap = SV_Utilities.keyBy([ SELECT Id, Name, ParentId,  PTF_NaturaGiuridica__c, PTF_Portafoglio__c, 
                        PTF_Portafoglio__r.PTF_ModelloDiServizio__c, PTF_Portafoglio__r.Name,
                        Filiale__c, PTF_Filiale__c, PTF_Filiale__r.Name, CRM_NDG__c, CRM_VAT__c, PTF_GruppoGestionale__c, PTF_OFS__c,PTF_RiportafogliazioneTAG__c,
                        PTF_MiniPortafoglio__c,PTF_MiniPortafoglio__r.PTF_SL__r.Name,ModelloDiServizio__c,PTF_SegmentoComportamentale__c
                    FROM Account
                    WHERE Id IN : accGruppoId AND 
                        RecordType.DeveloperName = 'GruppoFinanziario' AND 
                        PTF_DeletionDate__c = NULL ], 'Id', false);
            System.debug('DK gruppiFMap: ' + gruppiFMap);           
            response.gruppiFMap = gruppiFMap;




















            // gruppiFMap = SV_Utilities.keyBy([ SELECT Id, Name, ParentId, PTF_Gruppo__c, PTF_NaturaGiuridica__c, PTF_Portafoglio__c, 
            //             PTF_Portafoglio__r.PTF_ModelloDiServizio__c, PTF_Portafoglio__r.Name,
            //             Filiale__c, PTF_Filiale__c, PTF_Filiale__r.Name, CRM_NDG__c, CRM_VAT__c, PTF_GruppoGestionale__c, PTF_OFS__c
            //         FROM Account
            //         WHERE PTF_Portafoglio__c =: recordId AND RecordType.DeveloperName = 'GruppoFinanziario' AND PTF_DeletionDate__c = NULL ], 'Id', false);
            // System.debug('DK gruppiFMap: ' + gruppiFMap);           
            // response.gruppiFMap = gruppiFMap;
            

            // for (Id gId : gruppiFMap.keySet()) {
            //     accGruppoId.add(gId);
            // }

            // //Select Id Account
            // List<CRM_LinkedNDG__c> accList = [SELECT Id, CRM_Account__c, CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Status__c FROM CRM_LinkedNDG__c WHERE CRM_Account__c IN : accGruppoId AND CRM_LinkCode__c IN ('113', '165') ORDER BY CRM_LinkCode__c ASC ];
            // //Add AccountId
            // Map<String,CRM_LinkedNDG__c> accToLinkObj= new Map<String,CRM_LinkedNDG__c>();
            // for(CRM_LinkedNDG__c acc: accList){
            //     accId.add(acc.CRM_RelatedAccount__c);
            //     accToLinkObj.put(acc.CRM_RelatedAccount__c, acc);
            // }
            // response.accToLinkObj=accToLinkObj;

            
            // accMap = SV_Utilities.keyBy([SELECT Id, Name, ParentId, PTF_Filiale__c, PTF_Filiale__r.Name, CRM_NDG__c, CRM_VAT__c,  PTF_NaturaGiuridica__c,PTF_TipoCollegamento__c, PTF_DescTipoCollegamento__c, PTF_Gruppo__c, PTF_Capogruppo__c,
            //                                 PTF_Portafoglio__c, PTF_Portafoglio__r.PTF_ModelloDiServizio__c, PTF_Portafoglio__r.Name, PTF_OFS__c
            //                                 //(SELECT CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Account__c  FROM CRM_LinkedNDG__r)
            //                             FROM Account
            //                             WHERE Id IN : accId AND PTF_Portafoglio__c != NULL AND PTF_DeletionDate__c = NULL ], 'Id', false);

            // // accMap = SV_Utilities.keyBy([ SELECT Id, Name, ParentId, PTF_Gruppo__c, PTF_NaturaGiuridica__c, PTF_Portafoglio__c, 
            // //             PTF_Portafoglio__r.PTF_ModelloDiServizio__c, PTF_Portafoglio__r.Name,
            // //             Filiale__c, PTF_Filiale__c, PTF_Filiale__r.Name, CRM_NDG__c, CRM_VAT__c, PTF_GruppoGestionale__c, PTF_OFS__c
            // //         FROM Account
            // //         WHERE PTF_Gruppo__c IN : gruppiFSet AND PTF_Portafoglio__c != NULL AND PTF_DeletionDate__c = NULL Order By PTF_Capogruppo__c DESC], 'Id', false);
            // System.debug('DK AssignAccMap: ' + accMap);
            
            // response.accMap = accMap;

        } catch(System.CalloutException e) { 
            //Exception handling goes here.... retry the call, whatever 
            System.debug('SV CalloutException ' + e);
 
        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('SV BaseException ' + e);

        } 

        return response;

    }

    @AuraEnabled
    public static Wallet__c getRecordInfo(String recordId){
        System.debug('SV getRecordInfo recordId: ' + recordId);

        
        return [ SELECT Id, Name, RecordTypeId, RecordType.DeveloperName, PTF_Filiale__c FROM Wallet__c WHERE Id =: recordId];

    }



    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperObj {

        @AuraEnabled public Map<String, SObject> accMap;
        @AuraEnabled public Map<String, SObject> gruppiFMap;
        @AuraEnabled public Map<String, CRM_LinkedNDG__c> accToLinkObj;

    }
}