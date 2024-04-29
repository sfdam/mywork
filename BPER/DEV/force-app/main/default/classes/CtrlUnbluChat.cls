public without sharing class CtrlUnbluChat {
    
    @AuraEnabled(cacheable=true)
    public static String getConversationUrl(String recordId){

        String resultUrl = '';

        Id recId = Id.valueOf(recordId);

        if(recId.getSobjectType() == Case.getSObjectType()){

            Case currentCase = [SELECT Id, CC_Id_Conversationd_Unblu__c FROM Case WHERE Id = :recordId LIMIT 1];

            if(String.isNotBlank(currentCase.CC_Id_Conversationd_Unblu__c)){
                resultUrl = CC_Unblu_Settings__c.getInstance('CONVERSATION_URL').CC_Value__c + currentCase.CC_Id_Conversationd_Unblu__c;
            }

        }

        return resultUrl;

    }

}