public class GoogleMapViewController {
    
    public SObject CurRec{get;set;}
    public User user{get;set;}

    
    
    public GoogleMapViewController(ApexPages.StandardController stdController){
        
        // Ricavo il record che è attualmente nel contesto in base al valore del'id contenuto nell'URL della pagina Visualforce.
        CurRec  = (SObject)stdController.getRecord();
		system.debug('SV CurRec: ' + CurRec);
        
        user  = [SELECT Id, Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
		system.debug('SV User: ' + user);
        
    }


}