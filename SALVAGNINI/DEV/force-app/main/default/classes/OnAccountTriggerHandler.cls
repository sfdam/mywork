public class OnAccountTriggerHandler {
    public static void manageTerrioryOnInsert(List<Account> accList){        
        accList = TerritoryManagement.handleAccountTerritory(accList);      
    }
    public static void manageTerritoryOnUpdate(Map<Id,Account> oldAccMap,Map<Id,Account> newAccMap){    
        List<Account> updAccountList = new List<Account>();  
        for(Id key : newAccMap.keySet()){
            if(oldAccMap.get(key).BillingCountryCode != newAccMap.get(key).BillingCountryCode || 
                oldAccMap.get(key).BillingStateCode != newAccMap.get(key).BillingStateCode ||
                oldAccMap.get(key).BillingPostalCode != newAccMap.get(key).BillingPostalCode){
                    updAccountList.add(newAccMap.get(key));
                }
        }
        updAccountList = TerritoryManagement.handleAccountTerritory(updAccountList);    
        
    }

}