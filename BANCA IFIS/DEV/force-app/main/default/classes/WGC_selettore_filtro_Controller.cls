public with sharing class WGC_selettore_filtro_Controller {

    @AuraEnabled(cacheable=true)
    public static List<User> getUserWithFiliali(String userId){
        List<User> currentUserList = new List<User>();
        try {
            currentUserList = [SELECT Id, WGC_La_mia_filiale__c, toLabel(WGC_La_mia_filiale__c) filialiLabel FROM User WHERE Id = :userId LIMIT 1];
            if(currentUserList.isEmpty()){
                throw new AuraHandledException('No current User found');
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '' + e.getStackTraceString());
        }
        return currentUserList;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getCommerciali(String userId){
        List<User> currentUserList = new List<User>();
        List<User> commercialiUserList = new List<User>();
        try {
            currentUserList = [SELECT Id, WGC_La_mia_filiale__c FROM User WHERE Id = :userId LIMIT 1];
            
            if(currentUserList.isEmpty()){
                throw new AuraHandledException('No current User found');
            }
            if(String.isNotBlank(currentUserList.get(0).WGC_La_mia_filiale__c)){
                List<String> filialiList = currentUserList.get(0).WGC_La_mia_filiale__c.split(';');
                commercialiUserList = [SELECT Id, Name FROM User
                                        WHERE Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali' AND WGC_La_mia_filiale__c IN :filialiList ORDER BY Name];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + '' + e.getStackTraceString());
        }
        return commercialiUserList;
    }

}