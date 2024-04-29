global without sharing class Batch_CheckAnomaliePrimarioCO implements Schedulable, Database.Batchable<sObject>,Database.stateful{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'select id, CRM_Account__c, CRM_JointOwnership__c from CRM_AccountAccountJointOwnershipRelation__c WHERE CRM_Active__c =true AND CRM_PrimaryNDG__c =true AND PTF_JointOwnNDGWallet__c != \'\' AND PTF_PrimaryNDGWallet__c !=\'\' AND CRM_JointOwnership__r.ModelloDiServizio__c NOT IN (\'Residuale\',\'Consulenti Finanziari\') AND CRM_Account__r.ModelloDiServizio__c != \'Consulenti Finanziari\' AND PTF_CheckPortafoglio__c =false';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<CRM_AccountAccountJointOwnershipRelation__c> scope) {

        System.debug('DK scope: ' + scope.size());
        Map<String, SObject> scopeMap = SV_Utilities.keyBy(scope, 'Id');
        List<Anomalia__c> anomalieToInsert = new List<Anomalia__c>();
        Map<String, SObject> anomalieMap = SV_Utilities.keyBy([SELECT id, PTF_Relazione_di_cointestazione__c FROM Anomalia__c WHERE PTF_Relazione_di_cointestazione__c IN: scopeMap.keySet()], 'PTF_Relazione_di_cointestazione__c');
        for(String relazioneId : scopeMap.keySet()){
            if(!anomalieMap.containsKey(relazioneId)){
                anomalieToInsert.add(new Anomalia__c(PTF_Relazione_di_cointestazione__c = relazioneId, PTF_Primario__c = (Id)scopeMap.get(relazioneId).get('CRM_Account__c'), PTF_Cointestazione__c = (Id)scopeMap.get(relazioneId).get('CRM_JointOwnership__c')));
            }
        }
        insert anomalieToInsert;
    }

    global void execute(SchedulableContext SC) {
        
        Id batchJobId = Database.executeBatch(new Batch_CheckAnomaliePrimarioCO(), 200);
    }

    global void finish(Database.BatchableContext BC) {}
}