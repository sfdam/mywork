trigger OnAccountTrigger on Account (before insert,before update,after insert,after update, after delete) {
    /************************************
    * Developer       :       Riccardo@TEN
    * Create Date     :       01/07/2019
    * Name            :       OnAccountTrigger
    * Dependent Class :       OnAccountTriggerHandler
    * Description     :       Manage account fields
                            Creates Slave_Data__c and Map_Slave__c
    ************************************/        
    Funzionalita__c f = Funzionalita__c.getInstance();
    System.debug('Funzionalita__c.getInstance()'+  Funzionalita__c.getInstance());
    if (f.Disabilita_tutti_i_trigger__c)return;
  
    // if(CheckRecursive.runOnce()){
    if(trigger.isInsert){
            
        if(trigger.isBefore){
            OnAccountTriggerHandler.manageAccountBeforeInsert(trigger.new);
        }
        
        if(trigger.isAfter){
            OnAccountTriggerHandler.CreateMapSlave(trigger.new);
            OnAccountTriggerHandler.updateAccountAsyncAndCreateSlaveData(trigger.new);
            // INTEGRAZIONE (SHAREPOINT)
            if(CheckRecursive.runOnce()){
                OnAccountTriggerHandler.makeCallAccount(Trigger.newMap);
            }
        }
        // CheckRecursive.resetRunOnce();
    }

    if(trigger.isUpdate){
        if(trigger.isBefore){
            OnAccountTriggerHandler.manageAccountBeforeUpdate(trigger.newMap, trigger.oldMap);
            OnAccountTriggerHandler.checkAccountPartnerInfocert(trigger.newMap, trigger.oldMap); //AMS-001123
            // CheckRecursive.resetRunOnce();
        }
        if(trigger.isAfter){
            OnAccountTriggerHandler.VerifyDuplicatedCTM(trigger.new);
            //OnAccountTriggerHandler.updateSlave(trigger.new);
            // OnAccountTriggerHandler.updateAccountAsyncAndCreateSlaveData_Dedup(Trigger.new, Trigger.oldMap);
            // INTEGRAZIONE (SHAREPOINT)
            //Interruttore integrazione sharepoint
            //if(f.Abilita_Update_Sharepoint_Account__c)

            if(CheckRecursive.runOnce()){
                OnAccountTriggerHandler.makeCallAccount(Trigger.newMap);
            }
        }
    }
            
    if(trigger.isDelete){
        if(trigger.isAfter){
            //OnAccountTriggerHandler.createSlaveAssociationWhenAccountDelete(trigger.old);
        }
    }
    // }
}