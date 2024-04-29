trigger OnSlaveDataTrigger on Slave_Data__c (after insert, after update, after delete) {
   Funzionalita__c f = Funzionalita__c.getInstance();
  if (f.Disabilita_tutti_i_trigger__c)return;
   if (Trigger.isInsert){
      if(Trigger.isAfter){
         OnSlaveDataTriggerHandler.UpdateFieldsToAccount('isUpsert', Trigger.new);
      }      
   }
   if(Trigger.isUpdate){
      if(Trigger.isAfter){
      OnSlaveDataTriggerHandler.UpdateFieldsToAccount('isUpsert', Trigger.new);
      } 
   }
   if (Trigger.isDelete){
      if(Trigger.isAfter){
      OnSlaveDataTriggerHandler.UpdateFieldsToAccount('isDelete', Trigger.old);
      } 
   }
}