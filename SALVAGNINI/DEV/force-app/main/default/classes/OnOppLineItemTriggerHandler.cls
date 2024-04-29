public class OnOppLineItemTriggerHandler {
    public static void manageModelsField(Map<Id,OpportunityLineItem> lineItemMap){
        SYstem.debug('lineItemMap: : '+lineItemMap);

        List<Id> OppIdList = new List<Id>();
        List<Opportunity> toUpdateOppList = new List<Opportunity>();
        List<Id> prodIdList = new List<Id>();
        for(OpportunityLineItem item : lineItemMap.values()){
            OppIdList.add(item.OpportunityId);
        }
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, Models__c FROM Opportunity WHERE Id IN:OppIdList]);
        Map<Id,OpportunityLineItem> oppLineItemMap = new Map<Id,OpportunityLineItem>([SELECT Id,OpportunityId,Product2Id, Product2.Name FROM OpportunityLineItem WHERE OpportunityId IN: OppIdList]);
        for(OpportunityLineItem item : oppLineItemMap.values()){
            prodIdList.add(item.Product2Id);
        }
        Map<Id,Product2> productMap = new Map<Id,Product2>([SELECT Id,Name FROM Product2 WHERE Id IN: prodIdList]);

        
        SYstem.debug('oppLineItemMap: : '+oppLineItemMap);

        sObject opp;
        String models;
        String isNull;

        for(OpportunityLineItem item : lineItemMap.values()){
            SYstem.debug('item: : '+item);

            opp = oppMap.get(item.OpportunityId);
            Set<String> modelsSet = new Set<String>();
            for (String key : oppLineItemMap.keySet()){
                String productName = (String)productMap.get((Id)oppLineItemMap.get(key).get('Product2Id')).get('Name');
                if((String)oppLineItemMap.get(key).get('OpportunityId') == (String)opp.get('Id')){
                    if(productName!= null)modelsSet.add(productName);
                }
            }
            List<String> modelsList = new List<String>(modelsSet);
            models = String.join(modelsList,';');
            oppMap.get(item.OpportunityId).put('Models__c',models);
           // toUpdateOppList.add((Opportunity)opp);
        }
        update oppMap.values();
    }

    public static void fillOpportunitySystem(Map<Id,OpportunityLineItem> lineItemMap){
        System.debug('RC fillOpportunitySystem');
        List<Id> oppIds = new List<Id>();
        for(OpportunityLineItem item : lineItemMap.values()){
            oppIds.add(item.OpportunityId);
        }
        if(oppIds.isEmpty())return; //aggiungere errore
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([SELECT Id, System__c FROM Opportunity WHERE Id IN: oppIds]);
        List<OpportunityLineItem> itemList = [SELECT Id, OpportunityId, Product2.System__r.Name FROM OpportunityLineItem WHERE Id IN: lineItemMap.keyset()];
        Opportunity opp = new Opportunity();
        for(OpportunityLineItem item : itemList){
            opp = oppMap.get(item.OpportunityId);
            opp.System__c = item.Product2.System__r.Name;
            oppMap.put(item.OpportunityId, opp);
        }
        update oppMap.values();

    }



}