trigger OnSedeOperativaTrigger on Sede_Operativa_Warrant__c (before insert, before update) 
{
    Funzionalita__c f = Funzionalita__c.getInstance();
    if(f.Disabilita_Trigger_SedeOperativa__c) return;

    //controllo per la ripetizione del trigger, usare con solo metodi della classe OnSedeOperativaTriggerHandler
    if(!OnSedeOperativaTriggerHandler.disableSedeOperativaTrigger)
    {
        if(trigger.isUpdate)
        {
            if(trigger.isBefore)
            {
                OnSedeOperativaTriggerHandler.checkSedeDefault(Trigger.new);
            }
            //if(trigger.isAfter){}
        }
        if(trigger.isInsert)
        {
            if(trigger.isBefore)
            {
                OnSedeOperativaTriggerHandler.checkSedeDefault(Trigger.new);
            }
            //if(trigger.isAfter){}
        }
    }
}