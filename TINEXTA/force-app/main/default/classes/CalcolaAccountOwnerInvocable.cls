public class CalcolaAccountOwnerInvocable {
             
    //An invocable variable used as input or output variables in the process builder
    public class ActionRequest {
        
        @InvocableVariable(required=true)
        public Id AccountId;
        
        @InvocableVariable(required=true)
        public Id UserId;
       
       }     

    //This invocable method is used for processing the business by taking the input from process builder
    @InvocableMethod(label='Calcola Account Owner per Società')
    public static List<string> getAccountOwnerId(List<ActionRequest> requests){        
    	
        ActionRequest request = requests[0];
        List<String> returnValue = new List<String>();
        
        List<Coverage_Team_Member__c> ctmlist = new List<Coverage_Team_Member__c>([SELECT User__c, User__r.societa__c 
                                                                                   FROM Coverage_Team_Member__c
                                                                                  WHERE Account__c =: request.AccountId]);
        User usr = [SELECT societa__c 
                    FROM User 
                    WHERE Id =: request.UserId];
        
        System.debug('Dentro Metodo Invocable');
        
        for( Coverage_Team_Member__c ctm: ctmlist){
            if( ctm.user__r.societa__c == usr.societa__c )
                returnValue.add(ctm.user__c);
        }
        
        return returnValue;
	}
    
}