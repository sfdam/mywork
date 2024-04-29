global class WRT_BatchOnLeadTimeout implements Database.Batchable<sObject> {

    
     global Database.queryLocator start(Database.BatchableContext bc){
     return Database.getQueryLocator('SELECT Id,AccountSegnalatore__c,Giorni_Passati__c,Societa_di_riferimento__c FROM Lead WHERE AccountSegnalatore__c != null');
    }
    
     global void execute (Database.BatchableContext BC, List<Lead> LeadList){
         
           list <Funzionalita__c> x =[SELECT id,Disabilita_Integrazione__c,Disabilita_tutti_i_process_builder__c,Disabilita_tutti_i_trigger__c FROM Funzionalita__c LIMIT 1];
        x[0].Disabilita_Integrazione__c = true;
        x[0].Disabilita_tutti_i_process_builder__c= true;
        x[0].Disabilita_tutti_i_trigger__c = true;        
        update x;
         
      Set <string> leadid = new Set<string>();
      Set <string> leventi = new Set<string>();
      List<Segnalazioni__c> segnupdate = new list<Segnalazioni__c>();
       
         Map <String, Lead> mtpleadeventi = new Map<String, Lead>();  
        Map<String, SObject> associatedLead = Utilities.keyBy(LeadList,'id');
         
         
         for(Lead l : LeadList){
             if(l.Giorni_Passati__c >= 90 && l.Societa_di_riferimento__c=='Warrant'){
             leadid.add(l.id);
             }
            }
         
        system.debug('EU mappa lead 90' + leadid.size());
        List<Event> mtpevent = [SELECT id, OwnerId,WhoId FROM Event WHERE WhoId IN:leadid AND OwnerId IN ( SELECT Id FROM User WHERE Societa__c = 'Warrant')];
        system.debug('EU eventi ' + mtpevent.size());

         for(String le:leadid){
             Boolean find = false;
             for(Event e:mtpevent){
              if(le == e.WhoId){
                   system.debug('EU dentro');
                   find = true;            
             }
             }
             if(!find){
                 system.debug('EU fuori ' + le);
                 mtpleadeventi.put(le,(Lead)associatedLead.get(le));
             }
                  }

       
            system.debug('EU lead senza eventi ' + mtpleadeventi);
         
         	leventi.addAll(mtpleadeventi.keyset());
            List <Segnalazioni__c> mtpsegn = [SELECT id,Stato_Segnalazione_Warrant__c,Note_KO__c FROM Segnalazioni__c WHERE Lead_Di_Riferimento__c IN:leventi];
         

             for(String key: mtpleadeventi.keyset()){
                mtpleadeventi.get(key).AccountSegnalatore__c = null;
                mtpleadeventi.get(key).Data_inserimento_segnalazione__c=null;
                mtpleadeventi.get(key).Cognome_Segnalatore__c=null;
                mtpleadeventi.get(key).Contact__c=null;
                mtpleadeventi.get(key).Filiale1__c=null;
                mtpleadeventi.get(key).Fonte_Segnalatore__c=null;
                mtpleadeventi.get(key).Nome_segnalatore__c=null;
                mtpleadeventi.get(key).Note_Aggiuntive__c=null;
                mtpleadeventi.get(key).Numero_S__c=null;
                mtpleadeventi.get(key).Ruolo_ricoperto__c=null;
                mtpleadeventi.get(key).Stato_Segnalazione_Warrant__c=null;
                mtpleadeventi.get(key).WAR_N_Ordine_Rif_Interno__c=null;
                }
         
			 for(Segnalazioni__c s:mtpsegn){
                     s.Stato_Segnalazione_Warrant__c = 'Negativo';
                     s.Note_KO__c = 'KO Timeout';
                     segnupdate.add(s);
                 }  
           
            update mtpleadeventi.values();
            update segnupdate;
         
           
     }
    
    global void finish(Database.BatchableContext BC){  
           
        list <Log__c> addLog= new list<Log__c>();
         set <Log__c> setlog = new set <Log__c>();
    
        list <Funzionalita__c> x =[SELECT id,Disabilita_Integrazione__c,Disabilita_tutti_i_process_builder__c,Disabilita_tutti_i_trigger__c FROM Funzionalita__c LIMIT 1];
        if(x.size()>0){
        x[0].Disabilita_Integrazione__c = false;
        x[0].Disabilita_tutti_i_process_builder__c= false;
        x[0].Disabilita_tutti_i_trigger__c = false;
        update x;     
        }
                                            
       Map<Id, AsyncApexJob > mtpBatchMap  = new Map<Id, AsyncApexJob>([SELECT Id, CreatedDate, CreatedById, JobType, ApexClassId, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset FROM AsyncApexJob WHERE Id =: BC.getJobId()]);

                
        for (id s:mtpBatchMap.keyset()){         
        If(mtpBatchMap.get(s).JobItemsProcessed != 0){
            Log__c Nuovo = new Log__c();
       		Nuovo.Nome_Classe__c='BatchTimeoutLeadSegnalazioni';
        	Nuovo.Data_Log__c=system.today();
        	Nuovo.Status__c = mtpBatchMap.get(s).Status;
        	Nuovo.Dettagli__c= mtpBatchMap.get(s).ExtendedStatus;
        	Nuovo.Numero__c=mtpBatchMap.get(s).JobItemsProcessed;
        	Nuovo.Numero_Errori__c=mtpBatchMap.get(s).NumberOfErrors;
           Nuovo.Societa__c= 'Warrant';
   
            setLog.add(Nuovo);
         
        }
                        
        }
        addLog.addall(setLog);
        upsert addLog; 
   
    }
}