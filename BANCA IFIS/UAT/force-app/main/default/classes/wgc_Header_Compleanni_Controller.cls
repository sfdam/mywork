public with sharing class wgc_Header_Compleanni_Controller {
    public wgc_Header_Compleanni_Controller()
    {

    }

    @AuraEnabled
    public static Integer countCompleanni(){
        System.debug('SV countCompleanni');

        List<SObject> resultsContact = Database.query('SELECT Id FROM Contact WHERE Prossimo_compleanno__c = TODAY AND Account.WGC_Specialista_Factoring__c = \'' + UserInfo.getUserId() + '\'');
        List<SObject> resultsCompleanno = Database.query('SELECT Referente__c FROM Compleanno__c WHERE Utente__c = \'' + UserInfo.getUserId() + '\' AND Referente__r.Prossimo_compleanno__c = TODAY');


        System.debug('SV resultsContact: ' + resultsContact);
        System.debug('SV resultsCompleanno: ' + resultsCompleanno);

        Set<Id> resultIds = (new Map<Id,SObject>(resultsContact)).keySet();

        resultIds.addAll((new Map<Id,SObject>(resultsCompleanno)).keySet());

        return resultIds.size();
    }
}