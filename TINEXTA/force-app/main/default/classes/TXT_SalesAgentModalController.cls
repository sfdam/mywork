public class TXT_SalesAgentModalController {
    
    @AuraEnabled
    public static WrapperResponse getAgents(String recordId){
        
        WrapperResponse result = new WrapperResponse();
        list<Lead> LeadCAP = [SELECT PostalCode FROM Lead WHERE id=:recordId];
        
        try{
            result.data= [ SELECT Titolare__c, Name, Citta__c, Favourite_Agent_for_CAP__c 
                           FROM Anagrafica_Venditori__c 
                           WHERE CAP__c =: LeadCAP[0].PostalCode ORDER BY Favourite_Agent_for_CAP__c DESC, Titolare__c NULLS LAST ];
            
        } catch (Exception e){
            result.success = false; 
            result.msg = e.getMessage();
        }
        
        return result;
        
    }

    @AuraEnabled
    public static User getUserInfo(){
        return [ SELECT Id, Name, Agent_List_Access__c, Agent_Selected_Access__c FROM User WHERE Id =: UserInfo.getUserId() ];
        
    }
    
    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<Object>();
        }
    }

}