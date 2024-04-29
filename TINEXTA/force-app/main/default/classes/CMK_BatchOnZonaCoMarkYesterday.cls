global class CMK_BatchOnZonaCoMarkYesterday implements Database.Batchable<sObject> {
 
      global Database.queryLocator start(Database.BatchableContext bc){
          
     return Database.getQueryLocator('SELECT Id,cap_sedeoperativa_comark__c,agentezona_comark__c FROM Lead WHERE zona_comark__c IN (SELECT Id FROM Zona_CoMark__c WHERE LastModifiedDate = YESTERDAY OR LastModifiedDate = TODAY ) ORDER BY cap_sedeoperativa_comark__c DESC');
    }
    
    global void execute (Database.BatchableContext BC, List<Lead> LeadList){
        
        Set <string> zonaSet = new Set<string>();
        Map <ID, Lead> addLeadMap= new Map<ID, Lead>();
        
         for(Lead a : LeadList){
             zonaSet.add(a.cap_sedeoperativa_comark__c);
            }
        
        system.debug('prova zona' + zonaSet);
            Map<iD, Zona_CoMark__c> mtpZonaMap  = new Map<iD, Zona_CoMark__c >([SELECT Id,CAP_CoMark__c,Agente_Mandatario_CoMark__c FROM Zona_CoMark__c where CAP_CoMark__c IN: zonaSet]);
       
        
          system.debug('prova mappa' + mtpZonaMap);
        for(Lead l : LeadList){
                
        for (id s:mtpZonaMap.keyset()){
            if(mtpZonaMap.get(s).Agente_Mandatario_CoMark__c!=l.agentezona_comark__c && mtpZonaMap.get(s).CAP_CoMark__c == l.cap_sedeoperativa_comark__c){
                        
                l.agentezona_comark__c=mtpZonaMap.get(s).Agente_Mandatario_CoMark__c;
                addLeadMap.put(l.Id, l);
                
                 
                
                            }
             
            }
          
        }
        
        system.debug('NEW ' + addLeadMap);
        if(!addLeadMap.isEmpty()){
            list <Lead> addl = new list<Lead>();
            for (id m:addLeadMap.keyset()){
                addl.add(addLeadMap.get(m));
            }
            update addl;
        }
      
        
    }
    
    global void finish(Database.BatchableContext BC){      
        
        List <Log__c> addLog= new List<Log__c>();
        set <Log__c> setlog = new set <Log__c>();
        
                                    
       Map<Id, AsyncApexJob > mtpBatchMap  = new Map<Id, AsyncApexJob>([SELECT Id,ApexClassId,CompletedDate,Status,JobItemsProcessed,NumberOfErrors,ExtendedStatus FROM AsyncApexJob WHERE Id =: BC.getJobId()]);
        
        
        
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