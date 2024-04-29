global class CMK_BatchOnZonaAccountYesterday implements Database.Batchable<sObject> {
 
      global Database.queryLocator start(Database.BatchableContext bc){
          
     return Database.getQueryLocator('SELECT Id,CAP_Sede_Operativa_comark__c, agentezona_comark__c FROM Account WHERE zona_comark__c IN (SELECT Id FROM Zona_CoMark__c WHERE LastModifiedDate  = YESTERDAY OR LastModifiedDate  = TODAY )');
    }
    
    global void execute (Database.BatchableContext BC, List<Account> AccountList){
        
        Set <string> zonaSet = new Set<string>();
        Map <ID, Account> addAccountMap= new Map<ID, Account>();
        
        
         for(Account a : AccountList){
             zonaSet.add(a.CAP_Sede_Operativa_comark__c);
            }
        
        system.debug('prova zona' + zonaSet);
            Map<iD, Zona_CoMark__c> mtpZonaMap  = new Map<iD, Zona_CoMark__c >([SELECT Id,CAP_CoMark__c,Agente_Mandatario_CoMark__c FROM Zona_CoMark__c where CAP_CoMark__c IN: zonaSet]);
       
        
          system.debug('prova mappa' + mtpZonaMap);
        for(Account l : AccountList){
        for (id s:mtpZonaMap.keyset()){
            if(mtpZonaMap.get(s).Agente_Mandatario_CoMark__c!=l.agentezona_comark__c && mtpZonaMap.get(s).CAP_CoMark__c == l.CAP_Sede_Operativa_comark__c){
                
                l.agentezona_comark__c=mtpZonaMap.get(s).Agente_Mandatario_CoMark__c;
                addAccountMap.put(l.Id, l);              
                            }
             
            }
          
        }
           system.debug('NEW ' + addAccountMap);
        if(!addAccountMap.isEmpty()){
            list <Account> adda = new list<Account>();
            for (id m:addAccountMap.keyset()){
                adda.add(addAccountMap.get(m));
            }
            update adda;
        }
      
        
    }
    
    global void finish(Database.BatchableContext BC){      
        
        list <Log__c> addLog= new list<Log__c>();
         set <Log__c> setlog = new set <Log__c>();
    
        
                                            
       Map<Id, AsyncApexJob > mtpBatchMap  = new Map<Id, AsyncApexJob>([SELECT Id, CreatedDate, CreatedById, JobType, ApexClassId, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset FROM AsyncApexJob WHERE Id =: BC.getJobId()]);

        
       
                
        for (id s:mtpBatchMap.keyset()){         
        If(mtpBatchMap.get(s).JobItemsProcessed != 0){
            Log__c Nuovo = new Log__c();
        Nuovo.Nome_Classe__c='BatchOnZonaCoMark';
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