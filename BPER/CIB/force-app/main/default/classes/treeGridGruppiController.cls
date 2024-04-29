public class treeGridGruppiController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static WrapperObj getAllData(String recordId, String recordType){
        System.debug('SV getAllData recordId: ' + recordId);
        System.debug('SV getAllData recordType: ' + recordType);

        Map<String, SObject> gruppiMap = new Map<String, SObject>();
        Map<String, SObject> accMap =new Map<String, SObject>();
        Set<Id> accGruppoId = new Set<Id>();
        Set<String> accId = new Set<String>();

        WrapperObj response = new WrapperObj();

        try {
            Map<String,CRM_LinkedNDG__c> accToLinkObj= new Map<String,CRM_LinkedNDG__c>();

            if(recordType != 'GruppoFinanziario'){
                //Select ParentId
                gruppiMap = SV_Utilities.keyBy([SELECT Id, CRM_Account__c, CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Status__c,CRM_LinkType__c FROM CRM_LinkedNDG__c WHERE CRM_RelatedAccount__c =: recordId AND CRM_LinkCode__c IN ('113', '165') AND CRM_Status__c='A' ], 'CRM_RelatedAccount__c', false);

                //ADD ParentId
                if(gruppiMap.containsKey(recordId)){
                    accGruppoId.add((Id)gruppiMap.get(recordId).get('CRM_Account__c'));
                }
                
                
                //Select Id Account
                
                if(accGruppoId.size()>0){
                    List<CRM_LinkedNDG__c> accList = [SELECT Id, CRM_Account__c, CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Status__c,CRM_LinkType__c FROM CRM_LinkedNDG__c WHERE CRM_Account__c IN : accGruppoId AND CRM_LinkCode__c IN ('113', '165') ORDER BY CRM_LinkCode__c ASC ];
                    
                
                //Add AccountId
                    
                    for(CRM_LinkedNDG__c acc: accList){
                        accId.add(acc.CRM_RelatedAccount__c);
                        accToLinkObj.put(acc.CRM_RelatedAccount__c, acc);
                    }
                    
                }
                

            } else if(recordType == 'GruppoFinanziario'){
                //ADD ParentId
                accGruppoId.add(recordId);

                //Select Id Account
                List<CRM_LinkedNDG__c> accList = [SELECT Id, CRM_Account__c, CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Status__c,CRM_LinkType__c FROM CRM_LinkedNDG__c WHERE CRM_Account__c IN : accGruppoId AND CRM_LinkCode__c IN ('113', '165')  AND CRM_Status__c='A' ORDER BY CRM_LinkCode__c ASC ];
                //Add AccountId
                for(CRM_LinkedNDG__c acc: accList){
                    accId.add(acc.CRM_RelatedAccount__c);
                    accToLinkObj.put(acc.CRM_RelatedAccount__c, acc);
                }
            }
            //Gruppo Select
            gruppiMap = SV_Utilities.keyBy([SELECT Id, ParentId, PTF_Filiale__c, PTF_Filiale__r.Name, CRM_NDG__c, Name,  PTF_NaturaGiuridica__c,PTF_TipoCollegamento__c, PTF_DescTipoCollegamento__c, PTF_Capogruppo__c
                                            FROM Account
                                            WHERE Id IN : accGruppoId], 'Id', false);
           

            System.debug('SV cointestazioniMap: ' + gruppiMap);

            response.gruppiMap = gruppiMap;


            accMap = SV_Utilities.keyBy([SELECT Id, ParentId, PTF_Filiale__c, PTF_Filiale__r.Name, CRM_NDG__c, Name,  PTF_NaturaGiuridica__c,PTF_TipoCollegamento__c, PTF_DescTipoCollegamento__c, PTF_Capogruppo__c,ModelloDiServizio__c,PTF_SegmentoComportamentale__c
                                            //(SELECT CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Account__c  FROM CRM_LinkedNDG__r)
                                        FROM Account
                                        WHERE Id IN : accId ], 'Id', false);

            System.debug('SV accMap: ' + accMap);

            response.accMap = accMap;

            response.accToLinkObj=accToLinkObj;
            

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
    public static WrapperObj crm_getAllData(String recordId, String recordType){
        System.debug('SV getAllData recordId: ' + recordId);
        System.debug('SV getAllData recordType: ' + recordType);

        Map<String, SObject> gruppiMap = new Map<String, SObject>();
        Map<String, SObject> accMap =new Map<String, SObject>();
        Set<Id> accGruppoId = new Set<Id>();
        Set<String> accId = new Set<String>();

        WrapperObj response = new WrapperObj();

        try {
            Map<String,CRM_LinkedNDG__c> accToLinkObj= new Map<String,CRM_LinkedNDG__c>();

            if(recordType != 'GruppoFinanziario'){
                //Select ParentId
                gruppiMap = SV_Utilities.keyBy([SELECT Id, CRM_Account__c, CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Status__c,CRM_LinkType__c FROM CRM_LinkedNDG__c WHERE CRM_RelatedAccount__c =: recordId AND CRM_LinkCode__c IN ('113', '165', '166') ], 'CRM_RelatedAccount__c', false);

                //ADD ParentId
                if(gruppiMap.containsKey(recordId)){
                    accGruppoId.add((Id)gruppiMap.get(recordId).get('CRM_Account__c'));
                }
                
                
                //Select Id Account
                
                if(accGruppoId.size()>0){
                    List<CRM_LinkedNDG__c> accList = [SELECT Id, CRM_Account__c, CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Status__c,CRM_LinkType__c FROM CRM_LinkedNDG__c WHERE CRM_Account__c IN : accGruppoId AND CRM_LinkCode__c IN ('113', '165','166') ORDER BY CRM_LinkCode__c ASC ];
                    
                
                //Add AccountId
                    
                    for(CRM_LinkedNDG__c acc: accList){
                        accId.add(acc.CRM_RelatedAccount__c);
                        accToLinkObj.put(acc.CRM_RelatedAccount__c, acc);
                    }
                    
                }
                

            } else if(recordType == 'GruppoFinanziario'){
                //ADD ParentId
                accGruppoId.add(recordId);

                //Select Id Account
                List<CRM_LinkedNDG__c> accList = [SELECT Id, CRM_Account__c, CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Status__c,CRM_LinkType__c FROM CRM_LinkedNDG__c WHERE CRM_Account__c IN : accGruppoId AND CRM_LinkCode__c IN ('113', '165','166') ORDER BY CRM_LinkCode__c ASC ];
                //Add AccountId
                for(CRM_LinkedNDG__c acc: accList){
                    accId.add(acc.CRM_RelatedAccount__c);
                    accToLinkObj.put(acc.CRM_RelatedAccount__c, acc);
                }
            }
            //Gruppo Select
            gruppiMap = SV_Utilities.keyBy([SELECT Id, PTF_StatoCRMFull__c, ModelloDiServizio__c, CRM_CrossSelling__c, CRM_MargineIntermediazione__c, CRM_ProdottoBancarioLordo__c, ParentId, PTF_Filiale__c, PTF_Filiale__r.Name, CRM_NDG__c, Name,  PTF_NaturaGiuridica__c,PTF_TipoCollegamento__c, PTF_DescTipoCollegamento__c, PTF_Capogruppo__c,
                                                    PTF_SegmentoComportamentale__c
                                            FROM Account
                                            WHERE Id IN : accGruppoId], 'Id', false);
           

            System.debug('SV cointestazioniMap: ' + gruppiMap);

            response.gruppiMap = gruppiMap;


            accMap = SV_Utilities.keyBy([SELECT Id, PTF_StatoCRMFull__c, ModelloDiServizio__c, CRM_CrossSelling__c, CRM_MargineIntermediazione__c, CRM_ProdottoBancarioLordo__c, ParentId, PTF_Filiale__c, PTF_Filiale__r.Name, CRM_NDG__c, Name,  PTF_NaturaGiuridica__c,PTF_TipoCollegamento__c, PTF_DescTipoCollegamento__c, PTF_Capogruppo__c,
                                                PTF_SegmentoComportamentale__c
                                            //(SELECT CRM_LinkCode__c, CRM_RelatedAccount__c, CRM_Account__c  FROM CRM_LinkedNDG__r)
                                        FROM Account
                                        WHERE Id IN : accId ], 'Id', false);

            System.debug('SV accMap: ' + accMap);

            response.accMap = accMap;

            response.accToLinkObj=accToLinkObj;
            

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
    public static Account getRecordInfo(String recordId){
        System.debug('SV getRecordInfo recordId: ' + recordId);

        
        return [ SELECT Id, Name, RecordTypeId, RecordType.DeveloperName FROM Account WHERE Id =: recordId ];

    }



    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperObj {

        @AuraEnabled public Map<String, SObject> gruppiMap;
        @AuraEnabled public Map<String, SObject> accMap;
        @AuraEnabled public Map<String, CRM_LinkedNDG__c> accToLinkObj;

    }
}