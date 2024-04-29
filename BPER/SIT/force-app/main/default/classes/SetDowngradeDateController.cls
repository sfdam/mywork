public without sharing class SetDowngradeDateController {
    
    @AuraEnabled
    public static Account init(String recordId) {
        return [SELECT Id, Name, PTF_DowngradeReqStartDate__c, PTF_DowngradeReqEndDate__c FROM Account WHERE Id =: recordId];
    }

    @AuraEnabled
    public static List<Contact> getContactInfo() {

        return [SELECT Id, PTF_User__r.Profilo__c, AccountId FROM Contact WHERE PTF_User__c =: UserInfo.getUserId() LIMIT 1];
    }

    @AuraEnabled
    public static void saveRecord(Account account){
        try{
            update account;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }
}