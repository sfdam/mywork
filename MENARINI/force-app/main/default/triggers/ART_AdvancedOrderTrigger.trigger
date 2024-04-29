trigger ART_AdvancedOrderTrigger on cgcloud__Order__c (before insert, before update, after insert, after update) {
    System.debug('***** SONO NEL TRIGGER DEGLI ORDER Trigger');
    //TEST
    if(Trigger.isBefore && Trigger.isInsert){
        System.debug('******* START Before insert *******');
        for(cgcloud__Order__c o : Trigger.New){
            System.debug('**** Phase => ' + o.cgcloud__Phase__c);
            System.debug('**** OrderTemplate => ' + o.cgcloud__Order_Template__c);
            System.debug('**** OrderTemplate => ' + o.cgcloud__Mobility_Release__c);
            System.debug('**** Intero ordine => ' + o);
        }
        System.debug('******* END Before insert *******');
        
        //MS - Se la condizione è rispettata, si va a controllare se l’operatore ha selezionato una dilazione pagamento
        ART_AdvancedOrderTriggerHandler.dilazionePagamentoBeforeInsert(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        System.debug('******* START Before update *******');
        for(cgcloud__Order__c o : Trigger.New){
            System.debug('**** Phase => ' + o.cgcloud__Phase__c);
            System.debug('**** OrderTemplate => ' + o.cgcloud__Order_Template__c);
            System.debug('**** OrderTemplate => ' + o.cgcloud__Mobility_Release__c);
            System.debug('**** Intero ordine => ' + o);
        }
        System.debug('******* END Before update *******');
        
        ART_AdvancedOrderTriggerHandler.dilazionePagamentoBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
    //FINE TEST
    
    if(Trigger.isAfter && Trigger.isInsert)
    {
        ART_AdvancedOrderTriggerHandler.dilazionePagamentoAfterInsert(Trigger.new);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        ART_AdvancedOrderTriggerHandler.dilazionePagamentoAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}