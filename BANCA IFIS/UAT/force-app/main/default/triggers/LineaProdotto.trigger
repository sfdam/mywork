trigger LineaProdotto on WGC_Linea_Prodotto__c (after insert,after update) {
    if (Funzionalita__c.getInstance().DisabilitaTriggers__c) return;
    
    
    Set<Id> accId = new Set<Id>();
    Set<Id> oppId = new Set<Id>();
    for(WGC_Linea_Prodotto__c lp : Trigger.new){ 
        accId.add(lp.Anagrafica__c);
        oppId.add(lp.Opportunit__c);
    }

    
    Map<Id,Account> mapAcc = new Map<ID, Account>([SELECT Id,Ultima_opportunita_creata__c FROM Account WHERE Id IN :accID]);
    Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>([SELECT Id, StageName FROM Opportunity WHERE Id IN :oppID]);
    
    
    for(WGC_Linea_Prodotto__c lp :Trigger.new){
        if(lp.Opportunit__c!= null && lp.Qualifica_Prodotto__c == 'Cliente in avvio'){
            if(lp.Opportunit__r.StageName != 'Attivazione' || lp.Opportunit__r.StageName != 'Vinta'){
                //lp.Opportunit__r.StageName = 'Attivazione';
                mapOpp.get(lp.Opportunit__c).StageName = 'Attivazione';
            }
        }
        if(lp.Opportunit__c != null && lp.Qualifica_Prodotto__c == 'Cliente attivo'){
            if(lp.Opportunit__r.StageName != 'Vinta'){
                //lp.Opportunit__r.StageName = 'Vinta';
                mapOpp.get(lp.Opportunit__c).StageName = 'Vinta';
            }
            //lp.Anagrafica__r.Ultima_opportunità_creata__c = lp.Opportunit__r.Id;
            mapAcc.get(lp.Anagrafica__c).Ultima_opportunita_creata__c = lp.Opportunit__c;
        }
    }
    update mapAcc.values();
    update mapOpp.values();
    
}