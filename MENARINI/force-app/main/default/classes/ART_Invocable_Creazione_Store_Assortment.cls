public class ART_Invocable_Creazione_Store_Assortment {
	@InvocableMethod(label='Create or delete store assortment' )
    // here input param is smsRequest of List type
    public static list<string> CallFutureMethod(Params[] requests){
        system.debug('Params '+requests);
        ART_Future_Creazione_store_assortment.CDStoreAssortment(requests[0].Operation,requests[0].AccountId,requests[0].AssortmentId,requests[0].StartDate);
        return new list<string>();
    }
    
    
    public class Params {
        @InvocableVariable(required=true)
        public String Operation;
        
        @InvocableVariable(required=true)
        public String AccountId;
        
        @InvocableVariable(required=true)
        public String AssortmentId;
        
        @InvocableVariable(required=true)
        public Date StartDate;
    }
}