global class CMK_BatchOnAccountTimeout implements Database.Batchable<sObject> {

     global Database.queryLocator start(Database.BatchableContext bc){
     return Database.getQueryLocator('SELECT Id,CMK_Fonte_Dettaglio__c,CMK_Giorni_Passati__c  FROM Account WHERE CMK_Fonte_Dettaglio__c != null ');
    }
    
      global void execute (Database.BatchableContext BC, List<Account> AccList){
          
        Funzionalita__c x =[SELECT id,Disabilita_Integrazione__c,Disabilita_tutti_i_process_builder__c,Disabilita_tutti_i_trigger__c FROM Funzionalita__c LIMIT 1 ];
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        update x;
          
          Set <string> acc90= new set <String>();
          Set <string> acceventi= new set <String>();
          Set <string> accopp= new set <String>();
          List<Segnalazioni__c> segnupdate = new list<Segnalazioni__c>();
          
        Map <String, Account> mtpaccountopp = new Map<String, Account>();
        Map <String, Account> mtpacceventi = new Map<String, Account>();  
        Map<String, SObject> associatedAccount = Utilities.keyBy(AccList,'id');     
          
          for(Account a: AccList){
              if(a.CMK_Giorni_Passati__c >=90){
                  acc90.add(a.id);
                  
              }
          }
          system.debug('EU numero acc90   ' + acc90.size());
          
          List <Event> mtpevent = [SELECT Id,WhatId FROM Event WHERE WhatId IN:acc90 AND OwnerId IN ( SELECT Id FROM User WHERE Societa__c = 'CoMark')];
          system.debug('EU eventi  ' + mtpevent + mtpevent.size());
 
          for(String ac:acc90){
              Boolean find = false;
              for(Event e:mtpevent){
                  if(ac == e.WhatId){
                    system.debug('EU dentro evento');
                    find = true;
                  }
              }
              if(!find){
                  system.debug('EU fuori evento' + ac);
                    mtpacceventi.put(ac,(Account)associatedAccount.get(ac));
                  
              }

              }
          
          acceventi.addAll(mtpacceventi.keyset());
          
         
          system.debug('EU acc senza eventi ' + acceventi.size());
          
          List <Opportunity> mtpopp = [SELECT id,AccountId FROM Opportunity WHERE AccountId IN: acceventi AND Societariferimento_formula__c = 'CoMark'];
          system.debug('EU mappa opportunità' + mtpopp.size());
         
          for(String aec:acceventi){
              Boolean findopp = false;
              for(Opportunity o:mtpopp){
                  if(aec == o.AccountId){
                      system.debug('EU dentro opp');
                      findopp =true;
                  }
              }
              if(!findopp){
                      system.debug('EU fuori opp' + aec);
                  mtpaccountopp.put(aec,(Account)associatedAccount.get(aec));
                                  }
                      
                  }

          system.debug('EU acc senza eventi ed opportunità ' + mtpaccountopp);
          
          accopp.addAll(mtpaccountopp.keyset());
          List<Segnalazioni__c> mtpsegn = [SELECT id,Account__c,Societ_di_riferimento__c FROM Segnalazioni__c WHERE Account__c IN:accopp AND Stato_Segnalazione_Warrant__c != 'Negativo' AND Societ_di_riferimento__c = 'CoMark'];
          

          for(Segnalazioni__c s:mtpsegn){
                     s.Stato_Segnalazione_Warrant__c = 'Negativo';
                     s.Note_KO__c = 'KO Timeout';
                     segnupdate.add(s);                
                 } 

      
          
          for(String key: mtpaccountopp.keyset()){
                     system.debug('EU dentro for ');
                mtpaccountopp.get(key).CMK_Fonte_Dettaglio__c = null;
                mtpaccountopp.get(key).Accountsource_comark__c=null;
                mtpaccountopp.get(key).CMK_Cognome_del_Segnalato__c=null;
                mtpaccountopp.get(key).CMK_Contatto_di_riferimento__c=null;
                mtpaccountopp.get(key).CMK_Filiale__c=null;
                mtpaccountopp.get(key).CMK_Numero_Segnalazione__c=null;
                mtpaccountopp.get(key).CMK_Nome_Segnalato__c=null;
                mtpaccountopp.get(key).CMK_Data_Inserimento_Segnalazione__c=null;
                mtpaccountopp.get(key).CMK_Segnalazione_Partner__c =false;
                mtpaccountopp.get(key).CMK_Stato_Segnalazione_Partner__c= null;
               
                }
          
          
                update segnupdate;
			    update mtpaccountopp.values();
              
     
      }
    
    
    
    
    
    
    
        global void finish(Database.BatchableContext BC){  
           
        list <Log__c> addLog= new list<Log__c>();
         set <Log__c> setlog = new set <Log__c>();
      
            Funzionalita__c x =[SELECT id,Disabilita_Integrazione__c,Disabilita_tutti_i_process_builder__c,Disabilita_tutti_i_trigger__c FROM Funzionalita__c LIMIT 1 ];
            if(x != null){
        x.Disabilita_Integrazione__c = false;
        x.Disabilita_tutti_i_process_builder__c= false;
        x.Disabilita_tutti_i_trigger__c = false;
        update x;
            }  
                                            
       Map<Id, AsyncApexJob > mtpBatchMap  = new Map<Id, AsyncApexJob>([SELECT Id, CreatedDate, CreatedById, JobType, ApexClassId, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset FROM AsyncApexJob WHERE Id =: BC.getJobId()]);

        
       
                
        for (id s:mtpBatchMap.keyset()){         
        If(mtpBatchMap.get(s).JobItemsProcessed != 0){
            Log__c Nuovo = new Log__c();
        Nuovo.Nome_Classe__c='BatchTimeoutCoMarkAccount';
        Nuovo.Data_Log__c=system.today();
        Nuovo.Status__c = mtpBatchMap.get(s).Status;
        Nuovo.Dettagli__c= mtpBatchMap.get(s).ExtendedStatus;
        Nuovo.Numero__c=mtpBatchMap.get(s).JobItemsProcessed;
        Nuovo.Numero_Errori__c=mtpBatchMap.get(s).NumberOfErrors;
        Nuovo.Societa__c='CoMark';
            
            
           
            setLog.add(Nuovo);
             
                  
        }
                        
        }
        addLog.addall(setLog);
        upsert addLog; 


    }
}