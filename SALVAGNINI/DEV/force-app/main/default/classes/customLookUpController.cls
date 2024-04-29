public with sharing class customLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, string country, Boolean isAmedmentClone) {
        
        String searchKey = '%' + searchKeyWord + '%';
        String sQuery =  'SELECT Id, Name from ' + ObjectName + ' WHERE Name LIKE :searchKey ';
        if(isAmedmentClone){
            String role = [SELECT Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId()]?.Name;
            if(String.isNotBlank(role) && (role.containsignoreCase('Area Manager') || role.containsignoreCase('Region Manager'))){
                sQuery+='AND isActive = true AND Type__c != \'IC\' AND Type__c != \'Cost\'';
            }else{
                sQuery += 'AND isActive = true';
            }
        }
        
        sQuery += ' order by createdDate DESC limit 20';

        return Database.query(sQuery);
    }
}