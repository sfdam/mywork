public class OnLeadTriggerHandler {
    public static void manageTerritoryOnInsert(List<Lead> leadList){        
        leadList = TerritoryManagement.handleLeadTerritory(leadList);      
    }
    public static void manageTerritoryOnUpdate(Map<Id,Lead> oldLeadMap,Map<Id,Lead> newLeadMap){    
        List<Lead> updLeadList = new List<Lead>();  
        for(Id key : newLeadMap.keySet()){
            if(oldLeadMap.get(key).CountryCode != newLeadMap.get(key).CountryCode || 
                oldLeadMap.get(key).StateCode != newLeadMap.get(key).StateCode ||
                oldLeadMap.get(key).PostalCode != newLeadMap.get(key).PostalCode){
                    updLeadList.add(newLeadMap.get(key));
                }
        }
        System.debug('updLeadList: '+updLeadList);

        updLeadList = TerritoryManagement.handleLeadTerritory(updLeadList);    
        
    }
    
}