public class WGC_Analytics_Graphics_Controller {

    @AuraEnabled
    public static WrapperResponse getUserInformation(){

        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();
        
        try{

            User userInfo = [ SELECT Id, Name, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId() ];

            
            records.userInfo = userInfo;
            result.data.add(records);

        } catch(exception e){
            result.success = false; 
            result.msg = e.getMessage();
        }

        return result;
    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperRecords {
        @AuraEnabled public User userInfo;
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