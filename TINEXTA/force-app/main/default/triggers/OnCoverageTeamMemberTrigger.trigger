trigger OnCoverageTeamMemberTrigger on Coverage_Team_Member__c (before insert, after insert,after update,before update, after delete) {
   Funzionalita__c f = Funzionalita__c.getInstance();
  if (f.Disabilita_Trigger_CTM__c)return;
   if (Trigger.isInsert){
      if (Trigger.isBefore){
         OnCoverageTeamTriggerHandler.updateAccountOwner(Trigger.new);
         OnCoverageTeamTriggerHandler.updateAccountTeamFromTopAcct(Trigger.new);
         OnCoverageTeamTriggerHandler.ControlloWarrantInsert(Trigger.new);
      }
      if(Trigger.isAfter){
         //OnCoverageTeamTriggerHandler.CreateAccountTeamMember(Trigger.new);
         OnCoverageTeamTriggerHandler.UpdateFieldsToAccount('isUpsert', Trigger.new);
         //OnCoverageTeamTriggerHandler.afterInsertSocConcat(Trigger.new);
         //OnCoverageTeamTriggerHandler.afterInsertExternalIDConcat(Trigger.new);
      }      
   }
   if(Trigger.isUpdate){
      if(Trigger.isAfter){
         OnCoverageTeamTriggerHandler.UpdateAccountTeamMember(Trigger.old, Trigger.new);
         // verificare se si aggiornano i campi
      // OnCoverageTeamTriggerHandler.UpdateFieldsToAccount('isInsert', Trigger.new);
         OnCoverageTeamTriggerHandler.UpdateFieldsToAccount('isUpsert', Trigger.new);


      } 
       if(Trigger.isBefore){
           OnCoverageTeamTriggerHandler.ControlloWarrantUpdate(Trigger.newmap, Trigger.oldmap);
       }
   }
    
   if (Trigger.isDelete){
      //OnCoverageTeamTriggerHandler.afterDeleteRemoveSoc(Trigger.old);
      //OnCoverageTeamTriggerHandler.afterDeleteRemoveExternalId(Trigger.old);
      OnCoverageTeamTriggerHandler.UpdateFieldsToAccount('isDelete', Trigger.old);
      OnCoverageTeamTriggerHandler.DeleteAccountTeamMember(Trigger.old);
   }
}