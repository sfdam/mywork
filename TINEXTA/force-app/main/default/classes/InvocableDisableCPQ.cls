public class InvocableDisableCPQ {
    
    public class ActionRequest {
        @AuraEnabled  @InvocableVariable
        public String Check;
        
    }     

    //This invocable method is used for processing the business by taking the input from process builder
    @InvocableMethod(label='Spegnimento CPQ')
    public static List<String> SpegnimentoCPQ(List<ActionRequest> requests){        
    	SBQQ.TriggerControl.disable();
        
        List<String> res = new List<String>();
        
		 res.add ('OK');

        
        return res;

}
}