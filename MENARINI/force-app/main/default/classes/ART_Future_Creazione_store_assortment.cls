public class ART_Future_Creazione_store_assortment {
	@future
    public static void CDStoreAssortment(String operation, string AccountId, string AssortmentId, Date StartDate){
        if(operation == 'Create'){
            StoreAssortment SA = new StoreAssortment();
            SA.AccountId=AccountId;
            SA.AssortmentId=AssortmentId;
            SA.startDate =StartDate;
            Insert SA;
        }else{
            
            StoreAssortment SA=[select id from StoreAssortment where assortmentId=:AssortmentId And Accountid=:AccountId];
        	delete SA;
        }
    }
}