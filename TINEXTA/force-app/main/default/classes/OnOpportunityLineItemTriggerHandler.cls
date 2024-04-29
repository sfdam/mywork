public with sharing class OnOpportunityLineItemTriggerHandler {
    
    public static void makeOpportunityLineItem(Map<Id, OpportunityLineItem> opportunityLineItemNewMap, Map<Id, OpportunityLineItem> opportunityLineItemOldMap){
        System.debug('SV OpportunityLineItem New: ' + opportunityLineItemNewMap);
        System.debug('SV OpportunityLineItem Old: ' + opportunityLineItemOldMap);
        Map<Id,Schema.RecordTypeInfo> rtMap = Opportunity.sobjectType.getDescribe().getRecordTypeInfosById();
        
        List<String> oppIdList = new List<String>();
        for(String key : opportunityLineItemNewMap.keySet()){
            if(opportunityLineItemNewMap.get(key).Description != opportunityLineItemOldMap.get(key).Description ||
               opportunityLineItemNewMap.get(key).WH_Sottoprogetto__c != opportunityLineItemOldMap.get(key).WH_Sottoprogetto__c){
                   oppIdList.add(opportunityLineItemNewMap.get(key).OpportunityId);
               }
        }
        
        Map<String, SObject> oppMap = Utilities.keyBy([SELECT Id, Name, RecordType.DeveloperName
                                                       FROM Opportunity 
                                                       WHERE id IN : oppIdList AND 
                                                       RecordType.DeveloperName = 'Warrant' ], 'Id');
        
        Set<String> oppIdFinalList = new Set<String>();
        oppIdFinalList = oppMap.keySet();
        
        System.debug('SV oppIdFinalList: ' + oppIdFinalList);
        if(oppIdFinalList.size()>0) WRT_IntegrazioneController.opportunityIntegration(oppIdFinalList);
        
    }
    
    
    /*public static void verifynumberOLI(List<OpportunityLineItem> newlineitem){

List<String> Opp = new List<String>(); 

for (OpportunityLineItem o : newlineitem){
Opp.add(o.OpportunityId);          
}


System.debug('EU +  oli size' + Opp.size());

map<String, SObject> mtpOLIMap  = Utilities.keyBy([SELECT Id,OpportunityId
FROM OpportunityLineItem 
WHERE OpportunityId IN : Opp
], 'Id');

map<String, Opportunity> mtpOPPMap  = new map <String, Opportunity>([SELECT Id,Societariferimento_formula__c
FROM Opportunity 
WHERE Id IN : Opp
]);



System.debug('EU + query oli size' + mtpOLIMap.size());

for(OpportunityLineItem oli:newlineitem){    
if(mtpOLIMap.size()>0 || Opp.size()>1){
for(id op:mtpOPPMap.keyset()){
if(mtpOPPMap.get(op).Societariferimento_formula__c == 'Warrant'){
oli.addError('Non è possibile inserire più di un articolo');    
}
}
}
}
}*/
    
    public static void AggiornoEsercizio(List<OpportunityLineItem> newlineitem){
        
        List<String> Opp = new List<String>(); 
        
        for (OpportunityLineItem o : newlineitem){
            Opp.add(o.OpportunityId);          
        }
        
        
        System.debug('EU +  oli size' + Opp.size());
        
        
        map<String, Opportunity> mtpOPPMap  = new map <String, Opportunity>([SELECT Id,Societariferimento_formula__c, Anno_di_competenza__c
                                                                             FROM Opportunity 
                                                                             WHERE Id IN : Opp
                                                                            ]);
        
        
        
        
        for(OpportunityLineItem oli:newlineitem){
            for(Id o:mtpOPPMap.keyset()){
                if(oli.OpportunityId == mtpOPPMap.get(o).Id){
                    If(mtpOPPMap.get(o).Societariferimento_formula__c == 'Warrant'){
                        oli.WRT_esercizio__c = mtpOPPMap.get(o).Anno_di_competenza__c;
                    }
                }
            }
        }
        
    }
    
    
   /* public static void AggiornoQuote(List<OpportunityLineItem> newlineitem){
        
        List<String> Line = new List<String>(); 
        
        for (OpportunityLineItem o : newlineitem){
            Line.add(o.SBQQ__QuoteLine__c);          
        }
        
        system.debug('Line' + Line );
        
        
        
        map<String, SBQQ__QuoteLine__c> mtpQuoteLine  = new map <String, SBQQ__QuoteLine__c>([SELECT Id,SBQQ__Quote__c
                                                                                              FROM SBQQ__QuoteLine__c 
                                                                                              WHERE Id IN : Line
                                                                                             ]);
        
        
        system.debug('QuoteLineMap' + mtpQuoteLine);
        
        for(OpportunityLineItem oli:newlineitem){
            for(Id o:mtpQuoteLine.keyset()){
                if(oli.SBQQ__QuoteLine__c == mtpQuoteLine.get(o).Id){
                    system.debug('primo if');
                    If(oli.SBQQ_Quote__c != mtpQuoteLine.get(o).SBQQ__Quote__c ){
                        system.debug('secondo if');
                        oli.SBQQ_Quote__c = mtpQuoteLine.get(o).SBQQ__Quote__c;
                    }
                }
            }
        }
    }*/
    
}