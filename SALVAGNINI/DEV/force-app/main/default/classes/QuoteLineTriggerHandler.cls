public with sharing class QuoteLineTriggerHandler {

    public static boolean hasAlreadyRan = false;


    @future
    public static void handleAlternatives(string QuoteId, string triggerOldMapString) {//
        hasAlreadyRan = true;
        CongaTermCreator.hasAlreadyRan = true;
        List<SBQQ__QuoteLineGroup__c> listQLG = new List<SBQQ__QuoteLineGroup__c> ();
        Map<Id,SBQQ__QuoteLine__c> triggerOldMap = triggerOldMapString != null ? (Map<Id,SBQQ__QuoteLine__c>)JSON.deserialize(triggerOldMapString, Map<Id,SBQQ__QuoteLine__c>.Class) : new Map<Id,SBQQ__QuoteLine__c>();
        //List<SBQQ__QuoteLine__c> allQuoteLines = [SELECT Id, SBQQ__Source__c, Alternative__c, Is_Deleted__c, SBQQ__Group__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :QuoteId];
        List<SBQQ__QuoteLineGroup__c> groupList = [SELECT Id,Alternative__c,Name, (SELECT Id,SBQQ__Product__c,SBQQ__Product__r.Name, SBQQ__Source__c,SBQQ__Source__r.SBQQ__Group__c, Alternative__c, Is_Deleted__c, SBQQ__Group__c FROM SBQQ__LineItems__r WHERE Id Not IN :triggerOldMap.keyset()) FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :QuoteId];
        Map<string, boolean> groupIdAlternative = new Map<string, boolean>();
        Map<string, List<SBQQ__QuoteLine__c>> groupIdToQLList = new Map<string, List<SBQQ__QuoteLine__c>>();
        Map<string, List<SBQQ__QuoteLine__c>> gruppiBase = new Map<string, List<SBQQ__QuoteLine__c>>();
        Map<string, List<SBQQ__QuoteLine__c>> gruppiAlternativi = new Map<string, List<SBQQ__QuoteLine__c>>();
        Map<Id, SBQQ__QuoteLineGroup__c> groupMap = new Map<Id, SBQQ__QuoteLineGroup__c>(groupList);
        for(SBQQ__QuoteLineGroup__c qlg : groupList){
            groupIdAlternative.put(qlg.Id , qlg.Alternative__c);
            groupIdToQLList.put(qlg.Id , qlg.SBQQ__LineItems__r);
            if(qlg.Alternative__c){
                system.debug('Gruppo Alternativo: '+qlg.Name);
                gruppiAlternativi.put(qlg.Id , qlg.SBQQ__LineItems__r);
            }
            else{
                gruppiBase.put(qlg.Id , qlg.SBQQ__LineItems__r);
            }
        }
        
        if(gruppiAlternativi.size() > 0){
            List<SBQQ__QuoteLine__c> linesAddedToUpdate = new List<SBQQ__QuoteLine__c>();
            
            for(string groupid : gruppiAlternativi.keySet()){
                string source = '';
                string linesDeleted = '';
                system.debug('Dimensione: '+gruppiAlternativi.get(groupid).size());
                for(SBQQ__QuoteLine__c singleQL : gruppiAlternativi.get(groupid)){
                    system.debug('Riga Alternativa: '+singleQL);
                    //Devo checkare anche se il prodotto della QL è diverso se la source è presente? (io mi aspetto che per aggiungere un prodotto si crei una riga in più)
                    if(singleQL.SBQQ__Source__c == null ){
                        system.debug('SBQQ__Source__c vuota per  '+singleQL.Id);
                        singleQL.Alternative__c = true;
                        linesAddedToUpdate.add(singleQL);  
                    }
                    else{
                        source = singleQL.SBQQ__Source__r.SBQQ__Group__c;
                        system.debug('source popolata per:  '+singleQL.Id+' '+source);
                    }
                }
                if(source != ''){
                    linesDeleted = checkDeletedLines(gruppiAlternativi.get(groupid), groupIdToQLList.get(source),groupid,QuoteId);
                } 
                if(linesDeleted != null && linesDeleted != ''){
                    SBQQ__QuoteLineGroup__c qlgToUpdate = groupMap.get(groupid);
                    qlgToUpdate.Righe_Elmininate__c = linesDeleted;
                    listQLG.add(qlgToUpdate);
                }  
            } 
            if(listQLG.size() > 0){
                //update linesAddedToUpdate;
                update listQLG;
            }  
        }
    }

    public static string checkDeletedLines (List<SBQQ__QuoteLine__c> lineeAlternative, List<SBQQ__QuoteLine__c> lineeBase, string alternativeGroupId, string quoteId){
        Map<String,SBQQ__QuoteLine__c> productToQuoteLineMap = new Map<String,SBQQ__QuoteLine__c>(); 
        for(SBQQ__QuoteLine__c singleQL : lineeBase){
            system.debug('singleQL.SBQQ__Product__c: '+singleQL.SBQQ__Product__c);
            productToQuoteLineMap.put(singleQL.SBQQ__Product__c, singleQL);
        }
        for(SBQQ__QuoteLine__c singleQLAlt : lineeAlternative){
            if(productToQuoteLineMap.containsKey(singleQLAlt.SBQQ__Product__c)){
                system.debug('Prodotto trovato:: '+singleQLAlt.SBQQ__Product__c);
                productToQuoteLineMap.remove(singleQLAlt.SBQQ__Product__c);
            }
        }
        system.debug('productToQuoteLineMap:: '+productToQuoteLineMap);
        if(productToQuoteLineMap.size() > 0){
            string righeEliminate = '';
            for(SBQQ__QuoteLine__c singleQL : productToQuoteLineMap.values()){
                righeEliminate += singleQL.SBQQ__Product__r.Name + ', '; 
                /*SBQQ__QuoteLine__c newQL = singleQL.clone(false, true);
                newQL.SBQQ__Quote__c = quoteId;
                newQL.SBQQ__Group__c = alternativeGroupId;
                newQL.Is_Deleted__c = true;
                quoteLinesToReturn.add(newQL);*/
                system.debug('righeEliminate:: '+righeEliminate);
            }   
            righeEliminate = righeEliminate.removeEnd(', ');
            return righeEliminate;
        }
        else return null;
    }

}