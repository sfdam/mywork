public class InvockeOnLeadWRTORIGINE {
       
    public virtual class BaseException extends Exception {}
   	public class OtherException extends BaseException {}
    
       public class ActionRequest {
        @InvocableVariable(required=true)
        public Lead LeadObject; 
        
        @AuraEnabled @InvocableVariable 
        public String basket;
       }
 
    @InvocableMethod(label='Controllo campi origine')
        
      public static void Origine_WRT (List<ActionRequest> requests){
          
          Savepoint sp = Database.setSavepoint();
          
          try { 

              Lead LeadToUpdate = requests[0].LeadObject;
   
          	String basketlead = requests[0].basket;
          	LeadToUpdate.Basket_del_Lead__c=basketlead;
          
        	Database.DMLOptions dml = new Database.DMLOptions();
			dml.DuplicateRuleHeader.AllowSave = true;

        	Database.SaveResult sr = Database.update(LeadToUpdate, dml);

        } catch (BaseException e) {  
            // This catches the OtherException
            System.debug('EU BaseException ' + e);
            Database.rollback( sp );

        }
          
    }
}