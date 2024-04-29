public without sharing class OnLeadTriggerHandler_wSharing{

    public static void relateActivityToConvertedAccount(Map<Id, Lead> newLeadMap, Map<Id, Lead> oldLeadMap){

        //Recupero record type Warrant e creo collection per gestire record
        Id leadRT = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Warrant').getRecordTypeId();
        Id contactRT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Warrant').getRecordTypeId();
        Map<Id, Lead> leadToProcess = new Map<Id, Lead>();
        Set<Id> accountId = new Set<Id>();
        List<Event> eventToUpdate = new List<Event>(); 
        
        //Controllo se sono in conversione del lead e salvo l'account appena convertito
        for(Id i:newLeadMap.keySet()){
            if(newLeadMap.get(i).RecordTypeId==leadRT && newLeadMap.get(i).IsConverted==true && oldLeadMap.get(i).IsConverted==false){
                leadToProcess.put(i,newLeadMap.get(i));
                accountId.add(newLeadMap.get(i).ConvertedAccountId);
            }
        }

        //Recupero contatti di Warrant associati all'account appena convertito
        Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountId AND RecordTypeId = :contactRT]);

        //Recupero eventi associati ai contatti di Warrant
        List<Event> eventList = new List<Event>([SELECT Id, WhatId, WhoId FROM Event WHERE WhoId IN :contactMap.keyset()]);

        //Associo eventi all'account appena convertito
        for(Id i:contactMap.keySet()){
            for(Event eve:eventList){
                if(eve.WhoId == contactMap.get(i).Id){
                    eve.WhatId = contactMap.get(i).AccountId;
                    eventToUpdate.add(eve);
                }
            }
        }

        //Aggiorno eventi
        if(eventToUpdate.size()>0){
            update eventToUpdate;
        }
    }
}