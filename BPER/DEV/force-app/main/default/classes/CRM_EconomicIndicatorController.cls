public with sharing class CRM_EconomicIndicatorController {

    @AuraEnabled
    public static User getUserInfo() {
        return [ SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId() ];
        
    }

    @AuraEnabled
    public static Account getAccountData(String accId) {
        Account acc = [SELECT id, 
                        CRM_NDG__c,
                        Name
                        FROM Account
                        WHERE Id =: accId];
        return acc;
    }



    @AuraEnabled
    public static Map<String,SObject> getRelazioniAccount(String accId) {
        Map<String,SObject> resultMap = SV_Utilities.keyBy([SELECT id, 
                                                    CRM_Account__c,
                                                    CRM_Account__r.CRM_NDG__c,
                                                    CRM_Account__r.Name,
                                                    CRM_JointOwnership__c,
                                                    CRM_JointOwnership__r.CRM_NDG__c,
                                                    CRM_JointOwnership__r.Name,
                                                    CRM_Active__c
                                                    FROM CRM_AccountAccountJointOwnershipRelation__c
                                                    WHERE CRM_Account__c =: accId 
                                                    AND CRM_PrimaryNDG__c = false ], '{CRM_Account__c}_{CRM_JointOwnership__c}', true);
        
        return resultMap;
    }

    @AuraEnabled
    public static Map<String,Sobject> getCointestazioni(List<String> accIdList){
        Map<String,SObject> resultMap = SV_Utilities.keyBy([SELECT count(id) numeroCointestatari, 
                                                    CRM_JointOwnership__c 
                                                    FROM CRM_AccountAccountJointOwnershipRelation__c 
                                                    WHERE CRM_JointOwnership__c IN:accIdList 
                                                    AND CRM_Active__c = true 
                                                    AND CRM_PrimaryNDG__c = false 
                                                    GROUP BY CRM_JointOwnership__c ], 'CRM_JointOwnership__c', false);
        return resultMap;
    }



    @AuraEnabled
    public static Map<String,Sobject> getIndicatoriCliente(List<String> accIdList){
        Map<String,SObject> resultMap = new Map<String,SObject>();
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('CRM_IndicatoriCliente__c'));
        query += ' WHERE  CRM_Account__c  IN: accIdList and RecordType.Developername = \'FLAT\'';

        List<Sobject> slist = Database.query(query);

        System.debug('GB ObjRecord '+slist);
        for(Sobject so : slist){ resultMap.put((String)so.get('CRM_Account__c'),so); }

        return resultMap;
    }

    @AuraEnabled
    public static Map<String,Sobject> getIndicatoriPF(String accId){
        Map<String,SObject> resultMap = new Map<String,SObject>();
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('CRM_IndicatoriCliente__c'));
        query += ' WHERE  CRM_Account__c  =: accId and RecordType.Developername = \'FLAT\'';

        List<Sobject> slist = Database.query(query);

        System.debug('GB ObjRecord '+slist);
        for(Sobject so : slist){ resultMap.put((String)so.get('CRM_Account__c'),so); }
        return resultMap;
    }

}