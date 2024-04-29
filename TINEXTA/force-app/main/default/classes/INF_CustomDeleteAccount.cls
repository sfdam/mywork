public without sharing class INF_CustomDeleteAccount {
	  @AuraEnabled
    	public static WrapperResponse deleteRecord(String recordId){
            WrapperResponse result = new WrapperResponse();
        	List<Account> accountList = [SELECT Id,Name FROM Account WHERE Id =:recordId];
            List<Coverage_Team_Member__c> ctmList =[SELECT Id,Name FROM Coverage_Team_Member__c WHERE Account__c =:recordId];
            List <Slave_Data__c> slaveList = [SELECT Id,Name FROM Slave_Data__c WHERE Account__c =:recordId];
            List <Map_Slave__c> mapList = [SELECT Id,Name FROM Map_Slave__c WHERE Account__c =:recordId];

           try{
               
                if(slaveList.size()>0)delete(slaveList);
                if(mapList.size()>0)delete(mapList);       
               if(ctmList.size()>0)delete(ctmList);
               if(accountList.size()>0)delete(accountList);
               
            
        } catch (Exception e){
            result.success = false; 
            result.msg = e.getMessage();
           throw new AuraHandledException(e.getMessage());
        }
        
        return result;     
       
       
        
    }
   public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        //@AuraEnabled public List<Object> data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            //data = new List<Object>();
        }
   }
    

}