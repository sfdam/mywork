@RestResource(urlMapping='/CRM_WS_Predial/*')
global without sharing class CRM_WS_Predial {

    @HttpPost
    global static PredialResponse retrieveIsContactable(String idMember) {
        Boolean isContactable = true;
        PredialResponse response = new PredialResponse();
        try{
            CampaignMember cm = [SELECT Id, 
                                        CampaignId, 
                                        Campaign.CRM_EsclusioneLivelloPrivacyMulti__c,
                                        Contact.Account.CRM_Privacy_1Level__c,
                                        Contact.Account.CRM_Privacy_2Level__c, 
                                        Contact.Account.CRM_Privacy_3Level__c, 
                                        Contact.Account.CRM_Privacy_4Level__c, 
                                        Contact.Account.CRM_Deceduto__c  
                                        FROM CampaignMember WHERE id =: idMember];

        List<String> valueList = new List<String>();
        if(cm.Contact.Account.CRM_Deceduto__c){ isContactable = false;
        }else{
            if(!String.isBlank(cm.Campaign.CRM_EsclusioneLivelloPrivacyMulti__c)){
                valueList.addAll(cm.Campaign.CRM_EsclusioneLivelloPrivacyMulti__c.split(';'));
                if(valueList.contains('Privacy Livello 1') && !'Yes'.equalsIgnoreCase(cm.Contact.Account.CRM_Privacy_1Level__c)) isContactable = false;
                if(valueList.contains('Privacy Livello 2') && !'Yes'.equalsIgnoreCase(cm.Contact.Account.CRM_Privacy_2Level__c)) isContactable = false;
                if(valueList.contains('Privacy Livello 3') && !'Yes'.equalsIgnoreCase(cm.Contact.Account.CRM_Privacy_3Level__c)) isContactable = false;
                if(valueList.contains('Privacy Livello 4') && !'Yes'.equalsIgnoreCase(cm.Contact.Account.CRM_Privacy_4Level__c)) isContactable = false;
            }
        }

        }catch(Exception e){
            isContactable = false;
        }
        response.result = String.valueOf(isContactable);

        return response;
    }
    global class PredialResponse{
        global String result;
    }
    
}