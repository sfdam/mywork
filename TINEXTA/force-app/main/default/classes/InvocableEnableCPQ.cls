public class InvocableEnableCPQ {
    
    public class ActionRequest {
        @AuraEnabled  @InvocableVariable
        public String Check;
        
    }     
    
    //This invocable method is used for processing the business by taking the input from process builder
    @InvocableMethod(label='Accensione CPQ')
    public static List<String> AccensioneCPQ(List<ActionRequest> requests){        
        SBQQ.TriggerControl.enable();
        
        List<String> res = new List<String>();
        res.add ('OK');
        
        
        return res;
        
    }
}