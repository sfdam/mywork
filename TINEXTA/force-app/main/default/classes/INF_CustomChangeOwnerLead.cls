public class INF_CustomChangeOwnerLead {

@AuraEnabled
public static WrapperResponse getLead(Id recordId){
    WrapperResponse result = new WrapperResponse();
    try{
        Lead l = [SELECT Id, OwnerId, Stato_Trasferimento__c FROM Lead WHERE id=:recordId];
        system.debug('l : '+l);
        result.data.add(l);

    }catch (Exception e){
            result.success = false; 
            result.msg = e.getMessage();        
        }
    return result;
}

@AuraEnabled
public static WrapperResponse saveLead(Id recordId){
    boolean test=true;
     WrapperResponse result = new WrapperResponse();
   
    try{
         Lead l = [SELECT Id, OwnerId, Stato_Trasferimento__c FROM Lead WHERE id=:recordId];
        List<User> romano = [SELECT Id FROM User WHERE Name = 'Romano Menicacci'];
        
        If(l.Stato_Trasferimento__c == false){
            	l.OwnerId=romano[0].id;
   				l.Stato_Trasferimento__c=true;
            	update l;
            
        }
        
    result.data.add(l);
    }catch (Exception e){
            result.success = false; 
            result.msg = e.getMessage();        
        }
        
        return result;     
   
}
    
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