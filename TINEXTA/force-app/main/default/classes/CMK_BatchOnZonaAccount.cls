global class CMK_BatchOnZonaAccount implements Database.Batchable<sObject> {
    
    global Database.queryLocator start(Database.BatchableContext bc){
        // Aggiungere Comune
        return Database.getQueryLocator('SELECT Id, agentezona_comark__c,zona_comark__c,CoMark_Agente__c FROM Account WHERE zona_comark__c IN (SELECT Id FROM Zona_CoMark__c WHERE LastModifiedDate  = TODAY )');
    }
    
    global void execute (Database.BatchableContext BC, List<Account> AccountList){
        
        Set <string> zonaSet = new Set<string>();
        Set <string> comune = new Set <string>();
        Set<Id> IdAcc = new Set<Id>();
        List <string> nomeagente=new List <string>();
        Map <ID, Account> addAccountMap= new Map<ID, Account>();
        
        
        for(Account a : AccountList){
            IdAcc.add(a.Id);
        }
        
        
        
        Map<Id,Sedi__c> mtpSedi = new Map <Id,Sedi__c>([SELECT Id,CAP__c,Citta__c, Account__r.agentezona_comark__c
                                                        FROM Sedi__c 
                                                        WHERE Tipo_indirizzo__c = 'Sede Operativa' AND
                                                        Societa_di_riferimento__c = 'CoMark' AND 
                                                        Account__c IN:IdAcc 
                                                        ORDER BY CreatedDate ASC
                                                        LIMIT 1]);
        
        
        for(Id ss : mtpSedi.keyset()){
            // Aggiungere Comune
            zonaSet.add(mtpSedi.get(ss).CAP__c);
            comune.add(mtpSedi.get(ss).Citta__c);
        }
        
        system.debug('prova zona' + zonaSet);
        // Aggiungere Comune
        Map<iD, Zona_CoMark__c> mtpZonaMap  = new Map<iD, Zona_CoMark__c >([SELECT Id,CAP_CoMark__c,Agente_Mandatario_CoMark__c,Comune_CoMark__c,Agente_Nome_CMK__c FROM Zona_CoMark__c where CAP_CoMark__c IN: zonaSet AND Comune_CoMark__c IN:comune]);
        
        
        
        system.debug('prova mappa' + mtpZonaMap);
        for(Account l : AccountList){
            for (id s:mtpZonaMap.keyset()){
                // Aggiungere Comune
                system.debug('EU Zone Account'+ l.zona_comark__c);
                system.debug('EU Zone Zone' + mtpZonaMap.get(s).id );
                system.debug('EU Agente Account'+l.agentezona_comark__c );
                system.debug('EU Agente Zone' + mtpZonaMap.get(s).Agente_Mandatario_CoMark__c );
                
                if(mtpZonaMap.get(s).Agente_Mandatario_CoMark__c!=l.agentezona_comark__c && mtpZonaMap.get(s).id == l.zona_comark__c){
                    system.debug('EU dentro if');
                    l.agentezona_comark__c=mtpZonaMap.get(s).Agente_Mandatario_CoMark__c;
                    l.CoMark_Agente__c=mtpZonaMap.get(s).Agente_Nome_CMK__c;
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
                Nuovo.Nome_Classe__c='BatchOnZonaCoMark - Account';
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