global class WRT_BatchOnCPQCalculate implements Database.Batchable<sObject> {
    
    global Database.queryLocator start(Database.BatchableContext bc){
        String Soc = 'WRT CPQ';
        return Database.getQueryLocator('SELECT Id,Societ_di_riferimento__c,SBQQ__QuoteLine__c,UnitPrice, OpportunityId FROM OpportunityLineItem WHERE Societ_di_riferimento__c=: Soc and SBQQ__QuoteLine__c != null');
    }
    
    global void execute (Database.BatchableContext BC, List<OpportunityLineItem> OppLineList){
        
        Funzionalita__c x = Funzionalita__c.getOrgDefaults();
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        update x;
        
         
        Map <ID, SBQQ__QuoteLine__c> addQuoteLineMap= new Map<ID, SBQQ__QuoteLine__c>();
        Set <Id> QuoteLineId = new Set<Id>();
        
        Map <Id, OpportunityLineItem> addOppLineMap = new Map <Id,OpportunityLineItem>([SELECT Id, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.Valore_del_pagamento_in_euro_Prodotto__c,
                                                                                        Opportunity.Amount,Opportunity.Valore_del_pagamento_in_euro__c, UnitPrice,
                                                                                        Opportunity.Valore_del_pagamento_in_euro_Stimato__c,
                                                                                        SBQQ__QuoteLine__r.Finanziamento_Stimato_Prodotto__c, SBQQ__QuoteLine__r.AllineaConImporto__c
                                                                                        FROM OpportunityLineItem
                                                                                        WHERE Id IN:OppLineList and SBQQ__QuoteLine__r.Finanziamento_Stimato_Prodotto__c != null 
                                                                                        and SBQQ__QuoteLine__r.Valore_del_pagamento_in_euro_Prodotto__c != null]);
        
        
        for(Id o: addOppLineMap.keyset()){
            if(addOppLineMap.get(o).SBQQ__QuoteLine__r.AllineaConImporto__c == true){
                if(addOppLineMap.get(o).Opportunity.Amount != addOppLineMap.get(o).SBQQ__QuoteLine__r.Valore_del_pagamento_in_euro_Prodotto__c){  
                    QuoteLineId.add(addOppLineMap.get(o).SBQQ__QuoteLine__c);
                    addOppLineMap.get(o).UnitPrice = addOppLineMap.get(o).SBQQ__QuoteLine__r.Valore_del_pagamento_in_euro_Prodotto__c;
                } 
            } else if(addOppLineMap.get(o).SBQQ__QuoteLine__r.AllineaConImporto__c == false){
                if(addOppLineMap.get(o).Opportunity.Amount != addOppLineMap.get(o).SBQQ__QuoteLine__r.Finanziamento_Stimato_Prodotto__c){
                    QuoteLineId.add(addOppLineMap.get(o).SBQQ__QuoteLine__c);
                    addOppLineMap.get(o).UnitPrice = addOppLineMap.get(o).SBQQ__QuoteLine__r.Finanziamento_Stimato_Prodotto__c;
                }
            }
        }
        system.debug('Opp line Items ---> '+addOppLineMap.values());
        
        system.debug('NEW ' + QuoteLineId);
        
        Map<Id,SBQQ__QuoteLine__c> LineaMap = new Map <Id,SBQQ__QuoteLine__c> ([SELECT Id, Valore_del_pagamento_in_euro_Prodotto__c, SBQQ__ListPrice__c, AllineaConImporto__c,
                                                                                Finanziamento_Stimato_Prodotto__c
                                                                                FROM SBQQ__QuoteLine__c
                                                                                WHERE Id IN:QuoteLineId and Finanziamento_Stimato_Prodotto__c != null 
                                                                                and Valore_del_pagamento_in_euro_Prodotto__c != null]);
        
        for(Id q:LineaMap.keyset()){
            if(LineaMap.get(q).AllineaConImporto__c == true){
                LineaMap.get(q).SBQQ__ListPrice__c = LineaMap.get(q).Valore_del_pagamento_in_euro_Prodotto__c;
            } else if(LineaMap.get(q).AllineaConImporto__c == false){
                LineaMap.get(q).SBQQ__ListPrice__c = LineaMap.get(q).Finanziamento_Stimato_Prodotto__c;
            }
        }
        
        if(!LineaMap.isEmpty()){
            list <SBQQ__QuoteLine__c> LineUp = new list<SBQQ__QuoteLine__c>();
            for (id m:LineaMap.keyset()){
                LineUp.add(LineaMap.get(m));
            }
            update LineUp;
            update addOppLineMap.values();
        }
        
        Funzionalita__c y = Funzionalita__c.getOrgDefaults();
        if(y != null){
            y.Disabilita_Integrazione__c = false;
            y.Disabilita_tutti_i_process_builder__c= false;
            y.Disabilita_tutti_i_trigger__c = false;
            update y;
        } 
        
    }
    
    global void finish(Database.BatchableContext BC){  
        
        list <Log__c> addLog= new list<Log__c>();
        set <Log__c> setlog = new set <Log__c>();
        
        Map<Id, AsyncApexJob > mtpBatchMap  = new Map<Id, AsyncApexJob>([SELECT Id, CreatedDate, CreatedById, JobType, ApexClassId, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset FROM AsyncApexJob WHERE Id =: BC.getJobId()]);
        
        
        
        
        for (id s:mtpBatchMap.keyset()){         
            If(mtpBatchMap.get(s).JobItemsProcessed != 0){
                Log__c Nuovo = new Log__c();
                Nuovo.Nome_Classe__c='BatchCPQCalculate';
                Nuovo.Data_Log__c=system.today();
                Nuovo.Status__c = mtpBatchMap.get(s).Status;
                Nuovo.Dettagli__c= mtpBatchMap.get(s).ExtendedStatus;
                Nuovo.Numero__c=mtpBatchMap.get(s).JobItemsProcessed;
                Nuovo.Numero_Errori__c=mtpBatchMap.get(s).NumberOfErrors;
                Nuovo.Societa__c='Warrant';
                
                
                
                setLog.add(Nuovo);
                
                
            }
            
        }
        addLog.addall(setLog);
        upsert addLog; 
        
        
    }
}