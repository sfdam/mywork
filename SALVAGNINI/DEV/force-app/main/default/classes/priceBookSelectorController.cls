public with sharing class priceBookSelectorController {
    @AuraEnabled(cacheable=true)
    public static list<sObject> fetchLookupData() {    
        List < sObject > returnList = new List < sObject > ();
        String uRoleId = UserInfo.getUserRoleId();
        String roleName = [SELECT Name FROM UserRole WHERE Id = :uRoleId LIMIT 1]?.Name;
        string sQuery = 'Select Id,name From Pricebook2'  ;
        if(roleName != null && roleName != ''){
            if(roleName.contains('Area Manager') || roleName.contains('Region Manager')){
                sQuery += + ' Where Type__c != \'IC\' AND Type__c != \'Cost\'';
            }
            else if(roleName.contains('Territory Manager') || roleName.contains('PM Locale')){
                //non può modificare quindi nada
            }
            else if(roleName.contains('PM Corporate') ){
                sQuery += + ' Where Type__c != \'Cost\' ';
            }
            else if(roleName.contains('Assistant Corporate')){
                //niente ma lo lascio, si sa mai
            }
        }
        squery += ' order by Name ASC';
        for (sObject obj: database.query(sQuery)) {
            returnList.add(obj);
        }
        return returnList;
     }
     
     // Method to fetch lookup default value 
     @AuraEnabled
     public static sObject fetchDefaultRecord(string recordId , string sObjectApiName) {
         string sRecId = recordId;    
         string sQuery = 'Select Id,SBQQ__Type__c, SBQQ_Account__r.BillingCountry From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
         for (sObject obj: database.query(sQuery)) {
             return obj;
         }
         return null;
     }

     @AuraEnabled
     public static string assignRecords(string recordId , string pricebookId) {
        SBQQ__Quote__c quote = [SELECT Id  FROM SBQQ__Quote__c WHERE Id = :recordId];
        system.debug('Quote da agg:: ' + recordId + 'pricebookId:: '+ pricebookId );
        quote.SBQQ__PricebookId__c = pricebookId;
        update quote;
        return 'OK';
     }
}