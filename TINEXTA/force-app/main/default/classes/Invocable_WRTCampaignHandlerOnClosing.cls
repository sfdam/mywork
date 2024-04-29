public class Invocable_WRTCampaignHandlerOnClosing {
    
    @InvocableMethod(label='WRTCampaignQueries')
    public static void Invocable_WRTCampaignHandlerOnClosing(List<String> Campaign) {
        
        List<String> campagnaSplit = Campaign[0].split(',');
        String Campagna = campagnaSplit[0];
        Date startDate = Date.valueOf(campagnaSplit[1]);
        Date endDate = Date.valueOf(campagnaSplit[2]);
        
        Map<Id,Articolo_Campagna__c> articoliCampagnaMap = new Map<Id,Articolo_Campagna__c>([SELECT Codice_SAP__c 
                                                                                             FROM Articolo_Campagna__c 
                                                                                             WHERE Campagna__c = :Campagna]);
        
        Set<String> codiciSap = new Set<String>();            
        for(Articolo_Campagna__c articoloCampagna :articoliCampagnaMap.values()){
            codiciSap.add(articoloCampagna.Codice_Sap__c);
        }
        
        Map<Id,Product2> prodMap = new Map<Id,Product2>([SELECT Id 
                                                         FROM Product2 
                                                         WHERE Codice_SAP_w__c IN :codiciSap AND 
                                                         isActive = true]);
        
        Map<Id,OpportunityLineItem> oppLineMap = new Map<Id,OpportunityLineItem>([SELECT Id, OpportunityId, 
                                                                                  createdDate, Opportunity.AccountId 
                                                                                  FROM OpportunityLineItem 
                                                                                  WHERE Product2Id IN :prodMap.keySet() AND 
                                                                                  createdDate>= :startDate AND 
                                                                                  createdDate <= :endDate]);
        
        Map<Id,List<Id>> opportunities = new Map<Id,List<Id>>();
        List<Id> opportunityList = new List<Id>();
        
        Set<String> AccountIds = new Set<String>();
        for(OpportunityLineItem oppLineIt :oppLineMap.values()){
            AccountIds.add(oppLineIt.Opportunity.AccountId);
            opportunityList = (opportunities.containsKey(oppLineIt.Opportunity.AccountId))?opportunities.get(oppLineIt.Opportunity.AccountId):new List<Id>();
            opportunityList.add(oppLineIt.OpportunityId);
            opportunities.put(oppLineIt.Opportunity.AccountId, opportunityList);
        }
        
        Map<Id,Contact> contMap = new Map<Id,Contact>([SELECT Id, 
                                                       AccountId 
                                                       FROM Contact 
                                                       WHERE AccountId IN :AccountIds AND 
                                                       recordtype.name = 'Warrant' AND 
                                                       createdDate>= :startDate AND 
                                                       createdDate <= :endDate]);
        
        Map<Id,CampaignMember> memberMap = new Map<Id,CampaignMember>([SELECT ContactId 
                                                                       FROM CampaignMember 
                                                                       WHERE CampaignId = :Campagna AND 
                                                                       ContactId IN :contMap.keySet()]);
        Set<Id> OppIds = new Set<Id>();
        
        for(CampaignMember membro :memberMap.values()){
            OppIds.addAll(opportunities.get(contMap.get(membro.contactId).AccountId));                
        }
        List<Opportunity> listOppToUpdate = new List<Opportunity>();
        for(Opportunity opp:[SELECT Id, 
                             CampaignId 
                             FROM Opportunity 
                             WHERE Id IN :OppIds]){
            opp.CampaignId = Campagna;
            listOppToUpdate.add(opp);
        }
        
        if(listOppToUpdate.size()>0) update listOppToUpdate;  
    }
    
}