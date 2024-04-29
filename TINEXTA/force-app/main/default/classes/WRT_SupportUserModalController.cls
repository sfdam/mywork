public class WRT_SupportUserModalController {
    
    @AuraEnabled
    public static WrapperResponse getSupportUsers(){
        
        WrapperResponse result = new WrapperResponse();
		Id currUserId = UserInfo.getUserId();
		system.debug('currUserId:'+ currUserId);        
        try{
            result.data= [ SELECT Id, Name 
                           FROM User 
                           WHERE Warrant_customer_service__c =: currUserId]; 
            
        } catch (Exception e){
            result.success = false; 
            result.msg = e.getMessage();
        }
        
        return result;
        
    }

    @AuraEnabled
    public static User getUserInfo(){
        return [ SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId() ];
        
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