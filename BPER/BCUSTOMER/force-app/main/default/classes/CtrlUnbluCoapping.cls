public without sharing class CtrlUnbluCoapping {

    public class ResponseWrapper{
        @AuraEnabled public String coappingURL          {get; set;}
        @AuraEnabled public Boolean showComponent       {get; set;}
    }
    
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getCoappingUrl(String recordId, String filterStatus){

        ResponseWrapper response = new ResponseWrapper();
        response.showComponent = false;

        Case currentCase = [SELECT Id, AccountId FROM Case WHERE Id = :recordId LIMIT 1];

        if(String.isNotBlank(currentCase.AccountId)){

            List<String> statuses = (String.isNotBlank(filterStatus)) ? (filterStatus.trim()).split(',') : new List<String>{'Active','ATTIVO'};
            
            List<CRM_Channel__c> channelList = [SELECT Id FROM CRM_Channel__c WHERE CRM_Account__c = :currentCase.AccountId AND CRM_UserCodeStatus__c IN :statuses];

            if(!channelList.isEmpty()){
                response.showComponent = true;
                response.coappingURL = CC_Unblu_Settings__c.getInstance('COAPPING_URL').CC_Value__c;
            }

        }

        return response;

    }

}