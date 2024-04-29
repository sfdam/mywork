public with sharing class WGC_AttivitaOdierneController {
    
    @AuraEnabled
    public static Object init(){

        return new map<String, Object>{
            'daContattare' => [SELECT Account.Name, count(Id) from Task WHERE ActivityDate = TODAY AND OwnerId =: UserInfo.getUserId() AND DataOraEsitazione__c = NULL AND Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() GROUP BY Account.Name],
            'daVisitare' => [SELECT Account.Name, count(Id) from Event WHERE ActivityDate = TODAY AND OwnerId =: UserInfo.getUserId() AND DataOraEsitazione__c = NULL AND Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() GROUP BY Account.Name]
        };
    }

    @AuraEnabled(cacheable=true)
    public static List<AggregateResult> getPieChartValues(){
        List<AggregateResult> result =  [SELECT count(Id) tot, Campagna__c campagna from Task WHERE ActivityDate = TODAY AND OwnerId =: UserInfo.getUserId() AND DataOraEsitazione__c = NULL AND Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() GROUP BY Campagna__c];
        result.addAll([SELECT count(Id) tot, Campagna__c campagna from Event WHERE ActivityDate = TODAY AND OwnerId =: UserInfo.getUserId() AND DataOraEsitazione__c = NULL AND Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() GROUP BY Campagna__c]);
        return result ;
    }
}