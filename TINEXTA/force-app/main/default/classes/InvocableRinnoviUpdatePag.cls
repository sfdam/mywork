public class InvocableRinnoviUpdatePag {
    
    
    
     public class ActionRequest {
          @InvocableVariable
        public list <pagamenti__c> collezPag;        
      
        
    }
    
    
    @InvocableMethod(label='UpdatePag')
    
    public static List<String> UpdatePag (List<ActionRequest> requests){
        
    list <pagamenti__c> collezPag = requests[0].collezPag;
    
    list<string> h = new list <string> ();
        
        if (collezPag.size () > 0){

     Database.SaveResult[] srListPag = Database.update(collezPag, false);
            
             for (Database.SaveResult sr : srListPag) {
            if (sr.isSuccess()) {
                
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                                       
     h.add (err.getMessage() + 'errore su questi campi:' + err.getFields());
                    
                  
                }
            }
        }
            
            
            
            

     
}
        SBQQ.TriggerControl.enable();
        
        
        
    return h;
}
}