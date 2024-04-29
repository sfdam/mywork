public class TreeGridController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static WrapperObj getAllData(String recordId, String recordType){
        System.debug('SV getAllData recordId: ' + recordId);
        System.debug('SV getAllData recordType: ' + recordType);

        Map<String, SObject> cointestazioniMap = new Map<String, SObject>();
        Map<String, SObject> accMap = new Map<String, SObject>();
        Set<Id> accCointestazioniId = new Set<Id>();
        Set<String> accId = new Set<String>();

        WrapperObj response = new WrapperObj();

        try {

            if(recordType == 'PersonAccount'){
                cointestazioniMap = SV_Utilities.keyBy([SELECT Id, Name, CRM_Account__c, CRM_JointOwnership__c, CRM_PrimaryNDG__c 
                                                    FROM CRM_AccountAccountJointOwnershipRelation__c
                                                    WHERE CRM_Account__c =: recordId AND CRM_JointOwnership__r.PTF_Portafoglio__c != NULL AND CRM_Active__c = true AND CRM_RuoloCointestatario__c=true ], 'Id', false);
            
                for(Id key : cointestazioniMap.keySet()){
                    accCointestazioniId.add((Id)cointestazioniMap.get(key).get('CRM_JointOwnership__c'));
                }
            } else if(recordType == 'Cointestazione'){
                accCointestazioniId.add(recordId);
            }

            cointestazioniMap = SV_Utilities.keyBy([ SELECT Id, Name, CRM_Account__c, CRM_JointOwnership__c, CRM_PrimaryNDG__c 
                                                     FROM CRM_AccountAccountJointOwnershipRelation__c
                                                     WHERE CRM_JointOwnership__c IN : accCointestazioniId AND CRM_JointOwnership__r.PTF_Portafoglio__c != NULL AND CRM_Account__r.PTF_Portafoglio__c != NULL AND CRM_Active__c = true AND CRM_RuoloCointestatario__c=true ORDER BY CRM_PrimaryNDG__c ], '{CRM_JointOwnership__c}_{CRM_Account__c}', true);

            System.debug('SV cointestazioniMap: ' + cointestazioniMap);

            response.cointestazioniMap = cointestazioniMap;

            for(String key : cointestazioniMap.keySet()){
                accId.add(key.split('_')[1]);
                accId.add(key.split('_')[0]);
            }

            accMap = SV_Utilities.keyBy([ SELECT Id, Name, PTF_NaturaGiuridica__c, PTF_Filiale__r.Name, CRM_NDG__c, Description, PTF_Portafoglio__r.Name,  PTF_Portafoglio__c
                                          FROM Account
                                          WHERE Id IN : accId AND PTF_Portafoglio__c != NULL ], 'Id', false);

            System.debug('SV accMap: ' + accMap);

            response.accMap = accMap;
            

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

        @AuraEnabled public Map<String, SObject> cointestazioniMap;
        @AuraEnabled public Map<String, SObject> accMap;

    }
}