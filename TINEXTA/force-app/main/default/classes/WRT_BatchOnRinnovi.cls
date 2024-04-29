global class WRT_BatchOnRinnovi implements Database.Batchable<sObject> {
    
  

     global Database.queryLocator start(Database.BatchableContext bc){
         
         
          String query = 'SELECT Id,Name,CreatedDate FROM Impostazioni_Rinnovo__c where CreatedDate = LAST_N_DAYS:7';
          return Database.getQueryLocator(query); 
    }
    
    
     global void execute (Database.BatchableContext BC, List<Impostazioni_Rinnovo__c> scope){
         
         //il custom setting
        list <Funzionalita__c> x =[SELECT id,Disabilita_Integrazione__c,Disabilita_tutti_i_process_builder__c,Disabilita_tutti_i_trigger__c FROM Funzionalita__c LIMIT 1];
        x[0].Disabilita_Integrazione__c = true;
        x[0].Disabilita_tutti_i_process_builder__c= true;
        x[0].Disabilita_tutti_i_trigger__c = true;        
        update x;
         //il custom setting
         
      //   List <Impostazioni_Rinnovo__c> RinnoviDaCancellare = new list <Impostazioni_Rinnovo__c> ();
         
         
         
            /*  date d = system.today().addMonths(-1);
                if (r.CreatedDate <= d)*/
    
         //forse è necessario time/date ?
        // date d = system.today();
       /*  for (Impostazioni_Rinnovo__c r : scope){
             if (r.CreatedDate == d) {
                 RinnoviDaCancellare.add(r);
                 
             }
             
         }*/


         system.debug ('deleted these records:' + scope + scope.size());
         delete scope ;
       
           
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
       		Nuovo.Nome_Classe__c='WRT_BatchOnRinnovi';
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