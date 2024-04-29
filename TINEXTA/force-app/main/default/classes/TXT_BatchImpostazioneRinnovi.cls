global class TXT_BatchImpostazioneRinnovi implements Database.Batchable<sObject> {
    
  

     global Database.queryLocator start(Database.BatchableContext bc){
         
         system.debug('start');
          return Database.getQueryLocator('SELECT Id,Name,CreatedDate FROM Impostazioni_Rinnovi_Tinexta__c where CreatedDate <= LAST_N_DAYS:7'); 
    }
    
    
     global void execute (Database.BatchableContext BC, List<Impostazioni_Rinnovi_Tinexta__c> scope){
         system.debug('Bc' + BC);
         system.debug('scope'+ scope);
         
         //il custom setting
        list <Funzionalita__c> x =[SELECT id,Disabilita_Integrazione__c,Disabilita_tutti_i_process_builder__c,Disabilita_tutti_i_trigger__c FROM Funzionalita__c LIMIT 1];
        x[0].Disabilita_Integrazione__c = true;
        x[0].Disabilita_tutti_i_process_builder__c= true;
        x[0].Disabilita_tutti_i_trigger__c = true;        
        update x;
         //il custom setting
         List<Impostazioni_Rinnovi_Tinexta__c> Todelete = new List<Impostazioni_Rinnovi_Tinexta__c>();
         
         for(Impostazioni_Rinnovi_Tinexta__c i:scope){
             Todelete.add(i);
         }
         system.debug ('deleted these records:' + scope + scope.size());
         delete Todelete ;
       
           
     }
    
    global void finish(Database.BatchableContext BC){  
           
        list <Log__c> addLog= new list<Log__c>();
         set <Log__c> setlog = new set <Log__c>();
        
        
        //il custom setting
        list <Funzionalita__c> x =[SELECT id,Disabilita_Integrazione__c,Disabilita_tutti_i_process_builder__c,Disabilita_tutti_i_trigger__c FROM Funzionalita__c LIMIT 1];
        if(x.size()>0){
        x[0].Disabilita_Integrazione__c = false;
        x[0].Disabilita_tutti_i_process_builder__c= false;
        x[0].Disabilita_tutti_i_trigger__c = false;
        update x;     
        }
        //il custom setting
                                            
       Map<Id, AsyncApexJob > mtpBatchMap  = new Map<Id, AsyncApexJob>([SELECT Id, CreatedDate, CreatedById, JobType, ApexClassId, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset FROM AsyncApexJob WHERE Id =: BC.getJobId()]);

                
        for (id s:mtpBatchMap.keyset()){         
        If(mtpBatchMap.get(s).JobItemsProcessed != 0){
            Log__c Nuovo = new Log__c();
       		Nuovo.Nome_Classe__c='TXT_BatchOnRinnovi';
        	Nuovo.Data_Log__c=system.today();
        	Nuovo.Status__c = mtpBatchMap.get(s).Status;
        	Nuovo.Dettagli__c= mtpBatchMap.get(s).ExtendedStatus;
        	Nuovo.Numero__c=mtpBatchMap.get(s).JobItemsProcessed;
        	Nuovo.Numero_Errori__c=mtpBatchMap.get(s).NumberOfErrors;
   
            setLog.add(Nuovo);
         
        }
                        
        }
        addLog.addall(setLog);
        upsert addLog; 
   
    }
}