public class INF_SendEmailOppItemComponentController {
    @AuraEnabled 
    public static WrapperResponse getData(String recordId){
        WrapperResponse result = new WrapperResponse();
        Opportunity currOpp = [SELECT Id, isWon, Codice_Cliente__c FROM Opportunity WHERE Id =: recordId];
        // if(currOpp.isWon && currOpp.Codice_Cliente__c != null){result.isSendable = true;}
        if(currOpp.isWon){
            result.isSendableClosedWon = true;
        }
        if(currOpp.Codice_Cliente__c != null){
            result.isSendableCodCliente = true;
        }
       	Map<String,sObject> oppItemMap = Utilities.keyBy([SELECT Id,Name,ProductName__c,Description FROM OpportunityLineItem WHERE OpportunityId =:recordId],'Id');
         system.debug('oppItemMap: '+ oppItemMap);
        Map<String,sObject> oppScheduleMap =  Utilities.keyBy([SELECT Id,OpportunityLineItemId,Type, Revenue, Quantity, Description, ScheduleDate, Fatturabile__c, Data_ultimo_invio__c FROM OpportunityLineItemSchedule WHERE OpportunityLineItemId IN: oppItemMap.keySet()], 'Id');
         system.debug('oppScheduleMap: '+ oppScheduleMap);
        result.ItemList = oppItemMap.values();
        result.scheduleList = oppScheduleMap.values();
        return result;
      
        
    }

    @AuraEnabled
    public static Boolean SaveItems(String itemList, Boolean send){
        system.debug('itemList'+itemList);
        system.debug('send: '+send);
        itemList = itemList.replaceAll('Fatturabile__c', 'Fatturabile');
        itemList=  itemList.replaceAll('\"data\":', '');
        itemList= itemList.removeEnd('}');
        itemList = itemList.removeStart('{');

        List<WrapperObj> wrapList = (List<WrapperObj>)JSON.deserialize(itemList,List<WrapperObj>.class);

        system.debug('opp'+wrapList);
        try{
            List<OpportunityLineItemSchedule> newitems = new List<OpportunityLineItemSchedule>();
            Map<Id,OpportunityLineItemSchedule> toSend = new Map<Id,OpportunityLineItemSchedule>();
            Map <String, Schema.SObjectType> scheduleItemSchema = Schema.getGlobalDescribe();
            String objectNameSchedule='OpportunityLineItemSchedule';
            Map<String, Schema.SObjectField> fieldMapschedule = scheduleItemSchema.get(objectNameSchedule).getDescribe().fields.getMap();
            // RIC TI AMMAZZO
            Set<Id> idItem = new Set<Id>();
            for(WrapperObj item : wrapList){
                idItem.add(item.Id);
            }
            Map<String, SObject> oppSchMap  = Utilities.keyBy([ SELECT Id ,Type, Revenue, Quantity, Description, ScheduleDate,OpportunityLineItemId, Fatturabile__c, Data_ultimo_invio__c FROM OpportunityLineItemSchedule WHERE Id IN : idItem ], 'Id');

            for(WrapperObj item : wrapList){
                oppSchMap.get(item.Id).put('Fatturabile__c',item.Fatturabile);
                if(item.Invio && send){
                    oppSchMap.get(item.Id).put('Data_ultimo_invio__c', Date.today());
                    toSend.put(item.Id,((OpportunityLineItemSchedule)oppSchMap.get(item.Id)));
                }              
            } 
            if(send && !toSend.isEmpty()){
                system.debug('invio');
                system.debug ('toSend: '+toSend);
                INF_SendMail.sendOppScheduleMail(toSend);
            }
            
            if(send && toSend.isEmpty()){
                return false;
            }
            update oppSchMap.values();
            return true;
        }catch(Exception e){
            return false;       
        }
    }
	
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> ItemList;
        @AuraEnabled public List<Object> scheduleList;
        @AuraEnabled public Boolean isSendableClosedWon;
        @AuraEnabled public Boolean isSendableCodCliente;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            ItemList = new List<Object>();
            scheduleList = new List<Object>();
            isSendableClosedWon = false;
            isSendableCodCliente = false;
        }
    }

    public class WrapperObj {
        public Id Id;
        public Id OpportunityLineItemId;
        public String Type;
        public Decimal Revenue;
        public Date ScheduleDate;
        public Boolean Fatturabile;
        public String Name;
        public Boolean Invio;
        public String Description;
        public Decimal Quantity;
    }
}