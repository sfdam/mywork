trigger OnFinancialAccountRole on FinServ__FinancialAccountRole__c (before insert, after insert) {

    Funzionalita__c f = Funzionalita__c.getInstance();
    if (f.Disable_Trigger__c) return;
    if (f.Disable_FinancialAccountTrigger__c) return;


    if(trigger.isInsert){
        if(trigger.isBefore){
            System.debug('SV Account INSERT trigger.isBefore');
            OnFinancialAccountRoleTriggerHandler.setFields(Trigger.new);
        }
        
        /*if(trigger.isAfter){
            System.debug('SV Account INSERT trigger.isAfter');
            

        }*/        
    }
    
    /*if(trigger.isUpdate){
        if(trigger.isBefore){
            System.debug('SV Account UPDATE trigger.isBefore');

        }
        
        if(trigger.isAfter){
            System.debug('SV Account UPDATE trigger.isAfter');
            
        }
    }

    if(trigger.isDelete){
        if(trigger.isAfter){
            System.debug('SV Account DELETE trigger.isAfter');
        }
    }*/
}