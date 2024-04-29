public class OnOpportunityTriggerHandler {
    
    //public static Boolean disableOppUpdate = false;
    public static void countOpportunityOnAccount(List<Opportunity> oppList){
        System.debug('SV countOpportunityOnAccount: ' + oppList);
        Set<Id> accIdInOppList = new Set<id>();
        Decimal NumeroOPPCPQAperte = 0;
        Decimal NumeroOPPVinte = 0;
        Decimal NumeroOppWRTOpen=0;
        Decimal NumeroOppWRTVinte=0;
        Decimal NumeroTotaleAperte=0;
        Decimal NumeroTotaleVinte=0;
        
        
        for (Opportunity opp : oppList){
            accIdInOppList.add(opp.AccountId);        
        }
        
        System.debug('SV accIdInOppList: ' + accIdInOppList);
        
        
        Map<String, SObject> oppTot_Count = new Map<String, SObject>();
        Map<String, SObject> associatedAccountMap = new map<string, sobject>();
        if(accIdInOppList.size() > 0){
            
            oppTot_Count = Utilities.keyBy([ SELECT AccountId,RecordType.DeveloperName,isClosed,isWon,count(Id) 
                                            FROM Opportunity  
                                            WHERE  AccountId IN : accIdInOppList 
                                            GROUP BY AccountId,RecordType.DeveloperName,isClosed,isWon ], '{AccountId}.{DeveloperName}.{isClosed}.{isWon}', true);
            System.debug('RC opptCount: '+ oppTot_Count);                                                                                                                     
            
            associatedAccountMap = Utilities.keyBy([SELECT  Id, Name, 
                                                                     Opportunita_Tinexta_Aperte__c, Opportunita_Tinexta_Vinte__c, 
                                                                     Opportunita_InfoCert_Aperte__c, Opportunita_InfoCert_Vinte__c,
                                                                     Opportunita_Sixtema_Aperte__c, Opportunita_Sixtema_Vinte__c,
                                                                     Opportunita_Warrant_Aperte__c, Opportunita_Warrant_Vinte__c,
                                                                     Opportunita_CoMark_Aperte__c, Opportunita_CoMark_Vinte__c,
                                                                     Opportunita_Innolva_Aperte__c, Opportunita_Innolva_Vinte__c,
                                                                     Opportunita_Camerfirma_Aperte__c, Opportunita_Camerfirma_Vinte__c,
                                                                     Opportunita_Luxtrust_Aperte__c, Opportunita_Luxtrust_Vinte__c
                                                                     FROM Account 
                                                                     WHERE id IN : accIdInOppList ], 'Id');
        
        System.debug('SV associatedAccountMap: ' + associatedAccountMap);
        
        }
        
        
        for(String key : associatedAccountMap.keySet()){
            associatedAccountMap.get(key).put('Opportunita_Tinexta_Aperte__c',oppTot_Count.get(key+'.Tinexta.false.false') != null ? (Integer)oppTot_Count.get(key+'.Tinexta.false.false').get('expr0') : 0); 
            associatedAccountMap.get(key).put('Opportunita_Tinexta_Vinte__c', oppTot_Count.get(key+'.Tinexta.true.true') != null ? (Integer)oppTot_Count.get(key+'.Tinexta.true.true').get('expr0') : 0);
            
            
            
            
            associatedAccountMap.get(key).put('Opportunita_InfoCert_Aperte__c', oppTot_Count.get(key+'.InfoCert.false.false') != null ? (Integer)oppTot_Count.get(key+'.InfoCert.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_InfoCert_Vinte__c', oppTot_Count.get(key+'.InfoCert.true.true') != null ? (Integer)oppTot_Count.get(key+'.InfoCert.true.true').get('expr0') : 0);
            
            associatedAccountMap.get(key).put('Opportunita_Sixtema_Aperte__c', oppTot_Count.get(key+'.Sixtema.false.false') != null ? (Integer)oppTot_Count.get(key+'.Sixtema.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_Sixtema_Vinte__c', oppTot_Count.get(key+'.Sixtema.true.true') != null ? (Integer)oppTot_Count.get(key+'.Sixtema.true.true').get('expr0') : 0);
            
            //Righe Nuove per CPQ
            
            associatedAccountMap.get(key).put('Opportunita_Warrant_Aperte__c', oppTot_Count.get(key+'.WRT_CPQ.false.false') != null ? (Integer)oppTot_Count.get(key+'.WRT_CPQ.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_Warrant_Vinte__c', oppTot_Count.get(key+'.WRT_CPQ.true.true') != null ? (Integer)oppTot_Count.get(key+'.WRT_CPQ.true.true').get('expr0') : 0);
            
            IF((Decimal) associatedAccountMap.get(key).get('Opportunita_Warrant_Aperte__c')!= null){
                NumeroOPPCPQAperte=(Decimal) associatedAccountMap.get(key).get('Opportunita_Warrant_Aperte__c');}
            else{
                NumeroOPPCPQAperte=0;
            }
            If((Decimal) associatedAccountMap.get(key).get('Opportunita_Warrant_Vinte__c') != null){
                NumeroOPPVinte=(Decimal) associatedAccountMap.get(key).get('Opportunita_Warrant_Vinte__c');
            }
            else{
                NumeroOPPVinte=0;
            }
            system.debug('Conto '+ NumeroOPPCPQAperte + '' + NumeroOPPVinte);
            
            associatedAccountMap.get(key).put('Opportunita_Warrant_Aperte__c', oppTot_Count.get(key+'.Warrant.false.false') != null ? (Integer)oppTot_Count.get(key+'.Warrant.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_Warrant_Vinte__c', oppTot_Count.get(key+'.Warrant.true.true') != null ? (Integer)oppTot_Count.get(key+'.Warrant.true.true').get('expr0') : 0);
            
            //rgihe nuove per CPQ
            
            If((Decimal)associatedAccountMap.get(key).get('Opportunita_Warrant_Aperte__c') != null){
                NumeroOppWRTOpen= (Decimal)associatedAccountMap.get(key).get('Opportunita_Warrant_Aperte__c');
            }
            else{
                NumeroOppWRTOpen=0;
            }
            If((Decimal)associatedAccountMap.get(key).get('Opportunita_Warrant_Vinte__c') != null){
                NumeroOppWRTVinte=(Decimal)associatedAccountMap.get(key).get('Opportunita_Warrant_Vinte__c');
            }
            else{
                NumeroOppWRTVinte=0;
            }
            system.debug('Warrant '+NumeroOppWRTOpen + '' +NumeroOppWRTVinte);
            
            NumeroTotaleAperte= NumeroOPPCPQAperte + NumeroOppWRTOpen;
            NumeroTotaleVinte=NumeroOPPVinte + NumeroOppWRTVinte;
            
            
            system.debug('Totale Apert' +NumeroTotaleAperte);
            system.debug('Totale Vinete ' + NumeroTotaleVinte);
            associatedAccountMap.get(key).put('Opportunita_Warrant_Aperte__c', NumeroTotaleAperte);
            associatedAccountMap.get(key).put('Opportunita_Warrant_Vinte__c', NumeroTotaleVinte);
            
            associatedAccountMap.get(key).put('Opportunita_CoMark_Aperte__c',oppTot_Count.get(key+'.Co_Mark.false.false') != null ? (Integer)oppTot_Count.get(key+'.Co_Mark.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_CoMark_Vinte__c', oppTot_Count.get(key+'.Co_Mark.true.true') != null ? (Integer)oppTot_Count.get(key+'.Co_Mark.true.true').get('expr0') : 0);
            
            associatedAccountMap.get(key).put('Opportunita_Innolva_Aperte__c', oppTot_Count.get(key+'.Innolva_SAGEX3.false.false') != null ? (Integer)oppTot_Count.get(key+'.Innolva_SAGEX3.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_Innolva_Vinte__c', oppTot_Count.get(key+'.Innolva_SAGEX3.true.true') != null ? (Integer)oppTot_Count.get(key+'.Innolva_SAGEX3.true.true').get('expr0') : 0);
            
            associatedAccountMap.get(key).put('Opportunita_Camerfirma_Aperte__c', oppTot_Count.get(key+'.Camerfirma.false.false') != null ? (Integer)oppTot_Count.get(key+'.Camerfirma.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_Camerfirma_Vinte__c', oppTot_Count.get(key+'.Camerfirma.true.true') != null ? (Integer)oppTot_Count.get(key+'.Camerfirma.true.true').get('expr0') : 0);
            
            associatedAccountMap.get(key).put('Opportunita_Luxtrust_Aperte__c', oppTot_Count.get(key+'.Luxtrust.false.false') != null ? (Integer)oppTot_Count.get(key+'.Luxtrust.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_Luxtrust_Vinte__c', oppTot_Count.get(key+'.Luxtrust.true.true') != null ? (Integer)oppTot_Count.get(key+'.Luxtrust.true.true').get('expr0') : 0);
        }
        
        
        
        update associatedAccountMap.values();
        
        
    }
    
    
    public static void countOpportunityOnAccountUPDATE(Map<Id,Opportunity> newOpp, Map<Id, Opportunity> oldOpp){
        System.debug('SV countOpportunityOnAccount: ' + newOpp);
        System.debug('EU Old' + OldOpp);
        
        Set<Id> accIdInOppList = new Set<id>();
        Decimal NumeroOPPCPQAperte = 0;
        Decimal NumeroOPPVinte = 0;
        Decimal NumeroOppWRTOpen=0;
        Decimal NumeroOppWRTVinte=0;
        Decimal NumeroTotaleAperte=0;
        Decimal NumeroTotaleVinte=0;
        
        
        for (Id opp : newOpp.keyset()){
            Opportunity oldinput = oldOpp.get(newOpp.get(opp).Id);
            If(newOpp.get(opp).StageName != oldinput.StageName && newOpp.get(opp).StageName == 'Chiuse/Conseguite'){
                accIdInOppList.add(newOpp.get(opp).AccountId);        
            }
        }
        
        System.debug('SV accIdInOppList: ' + accIdInOppList);
        Map<String, SObject> associatedAccountMap = new Map<String, SObject>();
        
        
        Map<String, SObject> oppTot_Count = new Map<String, SObject>();
        
        if(accIdInOppList.size() > 0){
            
            oppTot_Count = Utilities.keyBy([ SELECT AccountId,RecordType.DeveloperName,isClosed,isWon,count(Id) 
                                            FROM Opportunity  
                                            WHERE  AccountId IN : accIdInOppList 
                                            GROUP BY AccountId,RecordType.DeveloperName,isClosed,isWon ], '{AccountId}.{DeveloperName}.{isClosed}.{isWon}', true);
            System.debug('RC opptCount: '+ oppTot_Count);                                                                                                                     
            
            associatedAccountMap = Utilities.keyBy([SELECT  Id, Name, 
                                                                     Opportunita_Tinexta_Aperte__c, Opportunita_Tinexta_Vinte__c, 
                                                                     Opportunita_InfoCert_Aperte__c, Opportunita_InfoCert_Vinte__c,
                                                                     Opportunita_Sixtema_Aperte__c, Opportunita_Sixtema_Vinte__c,
                                                                     Opportunita_Warrant_Aperte__c, Opportunita_Warrant_Vinte__c,
                                                                     Opportunita_CoMark_Aperte__c, Opportunita_CoMark_Vinte__c,
                                                                     Opportunita_Innolva_Aperte__c, Opportunita_Innolva_Vinte__c,
                                                                     Opportunita_Camerfirma_Aperte__c, Opportunita_Camerfirma_Vinte__c,
                                                                     Opportunita_Luxtrust_Aperte__c, Opportunita_Luxtrust_Vinte__c
                                                                     FROM Account 
                                                                     WHERE id IN : accIdInOppList ], 'Id');
        
        System.debug('SV associatedAccountMap: ' + associatedAccountMap);

        }
        
        
        for(String key : associatedAccountMap.keySet()){
            associatedAccountMap.get(key).put('Opportunita_Tinexta_Aperte__c',oppTot_Count.get(key+'.Tinexta.false.false') != null ? (Integer)oppTot_Count.get(key+'.Tinexta.false.false').get('expr0') : 0); 
            associatedAccountMap.get(key).put('Opportunita_Tinexta_Vinte__c', oppTot_Count.get(key+'.Tinexta.true.true') != null ? (Integer)oppTot_Count.get(key+'.Tinexta.true.true').get('expr0') : 0);
            
            
            
            
            associatedAccountMap.get(key).put('Opportunita_InfoCert_Aperte__c', oppTot_Count.get(key+'.InfoCert.false.false') != null ? (Integer)oppTot_Count.get(key+'.InfoCert.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_InfoCert_Vinte__c', oppTot_Count.get(key+'.InfoCert.true.true') != null ? (Integer)oppTot_Count.get(key+'.InfoCert.true.true').get('expr0') : 0);
            
            associatedAccountMap.get(key).put('Opportunita_Sixtema_Aperte__c', oppTot_Count.get(key+'.Sixtema.false.false') != null ? (Integer)oppTot_Count.get(key+'.Sixtema.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_Sixtema_Vinte__c', oppTot_Count.get(key+'.Sixtema.true.true') != null ? (Integer)oppTot_Count.get(key+'.Sixtema.true.true').get('expr0') : 0);
            
            //Righe Nuove per CPQ
            
            associatedAccountMap.get(key).put('Opportunita_Warrant_Aperte__c', oppTot_Count.get(key+'.WRT_CPQ.false.false') != null ? (Integer)oppTot_Count.get(key+'.WRT_CPQ.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_Warrant_Vinte__c', oppTot_Count.get(key+'.WRT_CPQ.true.true') != null ? (Integer)oppTot_Count.get(key+'.WRT_CPQ.true.true').get('expr0') : 0);
            
            IF((Decimal) associatedAccountMap.get(key).get('Opportunita_Warrant_Aperte__c')!= null){
                NumeroOPPCPQAperte=(Decimal) associatedAccountMap.get(key).get('Opportunita_Warrant_Aperte__c');}
            else{
                NumeroOPPCPQAperte=0;
            }
            If((Decimal) associatedAccountMap.get(key).get('Opportunita_Warrant_Vinte__c') != null){
                NumeroOPPVinte=(Decimal) associatedAccountMap.get(key).get('Opportunita_Warrant_Vinte__c');
            }
            else{
                NumeroOPPVinte=0;
            }
            system.debug('Conto '+ NumeroOPPCPQAperte + '' + NumeroOPPVinte);
            
            associatedAccountMap.get(key).put('Opportunita_Warrant_Aperte__c', oppTot_Count.get(key+'.Warrant.false.false') != null ? (Integer)oppTot_Count.get(key+'.Warrant.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_Warrant_Vinte__c', oppTot_Count.get(key+'.Warrant.true.true') != null ? (Integer)oppTot_Count.get(key+'.Warrant.true.true').get('expr0') : 0);
            
            //rgihe nuove per CPQ
            
            If((Decimal)associatedAccountMap.get(key).get('Opportunita_Warrant_Aperte__c') != null){
                NumeroOppWRTOpen= (Decimal)associatedAccountMap.get(key).get('Opportunita_Warrant_Aperte__c');
            }
            else{
                NumeroOppWRTOpen=0;
            }
            If((Decimal)associatedAccountMap.get(key).get('Opportunita_Warrant_Vinte__c') != null){
                NumeroOppWRTVinte=(Decimal)associatedAccountMap.get(key).get('Opportunita_Warrant_Vinte__c');
            }
            else{
                NumeroOppWRTVinte=0;
            }
            system.debug('Warrant '+NumeroOppWRTOpen + '' +NumeroOppWRTVinte);
            
            NumeroTotaleAperte= NumeroOPPCPQAperte + NumeroOppWRTOpen;
            NumeroTotaleVinte=NumeroOPPVinte + NumeroOppWRTVinte;
            
            
            system.debug('Totale Apert' +NumeroTotaleAperte);
            system.debug('Totale Vinete ' + NumeroTotaleVinte);
            associatedAccountMap.get(key).put('Opportunita_Warrant_Aperte__c', NumeroTotaleAperte);
            associatedAccountMap.get(key).put('Opportunita_Warrant_Vinte__c', NumeroTotaleVinte);
            
            associatedAccountMap.get(key).put('Opportunita_CoMark_Aperte__c',oppTot_Count.get(key+'.Co_Mark.false.false') != null ? (Integer)oppTot_Count.get(key+'.Co_Mark.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_CoMark_Vinte__c', oppTot_Count.get(key+'.Co_Mark.true.true') != null ? (Integer)oppTot_Count.get(key+'.Co_Mark.true.true').get('expr0') : 0);
            
            associatedAccountMap.get(key).put('Opportunita_Innolva_Aperte__c', oppTot_Count.get(key+'.Innolva_SAGEX3.false.false') != null ? (Integer)oppTot_Count.get(key+'.Innolva_SAGEX3.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_Innolva_Vinte__c', oppTot_Count.get(key+'.Innolva_SAGEX3.true.true') != null ? (Integer)oppTot_Count.get(key+'.Innolva_SAGEX3.true.true').get('expr0') : 0);
            
            associatedAccountMap.get(key).put('Opportunita_Camerfirma_Aperte__c', oppTot_Count.get(key+'.Camerfirma.false.false') != null ? (Integer)oppTot_Count.get(key+'.Camerfirma.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_Camerfirma_Vinte__c', oppTot_Count.get(key+'.Camerfirma.true.true') != null ? (Integer)oppTot_Count.get(key+'.Camerfirma.true.true').get('expr0') : 0);
            
            associatedAccountMap.get(key).put('Opportunita_Luxtrust_Aperte__c', oppTot_Count.get(key+'.Luxtrust.false.false') != null ? (Integer)oppTot_Count.get(key+'.Luxtrust.false.false').get('expr0') : 0);
            associatedAccountMap.get(key).put('Opportunita_Luxtrust_Vinte__c', oppTot_Count.get(key+'.Luxtrust.true.true') != null ? (Integer)oppTot_Count.get(key+'.Luxtrust.true.true').get('expr0') : 0);
        }
        
        
        
        update associatedAccountMap.values();
        
        
    }
    
    public static void alignOutcome(Map<Id,sObject> optMap, User currUser){
        //   User currUser = [ SELECT Id, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
        
        if(currUser.Societa__c == 'CoMark'){
            Map<Id,Id> AccountIds = new Map<Id,Id>();
            for(sObject opt : optMap.values()){
                if(opt.get('AccountId')!= null){
                    AccountIds.put((Id)opt.get('Id'),(Id)opt.get('AccountId'));
                }
            }
            Map<String,sObject> accMap = Utilities.keyBy([SELECT Id,Name, Esito_Comark__c,Causale_Esito_Comark__c,Note_esito_comark__c, Data_ultimo_esito_comark__c FROM Account WHERE Id IN: AccountIds.values()],'Id');    
            for(Id optId : AccountIds.keySet()){
                if(optMap.get(optId).get('Esito_Comark__c')!= null){
                    accMap.get((String)AccountIds.get(optId)).put('Esito_Comark__c',(String)optMap.get(optId).get('Esito_Comark__c'));
                    accMap.get((String)AccountIds.get(optId)).put('Data_ultimo_esito_comark__c',Date.today());
                }          
                if(optMap.get(optId).get('Causale_Esito_Comark__c')!= null)  accMap.get((String)AccountIds.get(optId)).put('Causale_Esito_Comark__c',(String)optMap.get(optId).get('Causale_Esito_Comark__c'));
                if(optMap.get(optId).get('Note_esito_comark__c')!= null || optMap.get(optId).get('Note_esito_comark__c')== null )     accMap.get((String)AccountIds.get(optId)).put('Note_esito_comark__c',(String)optMap.get(optId).get('Note_esito_comark__c'));
            }
            
            update accmap.values();
        }
    }
    
    public static void makeCallOpportunity(Map<Id,sObject> oldOptMap, Map<Id,sObject> newOptMap, User currUser){
        // if(disableOppUpdate)return;
        // User currUser = [ SELECT Id, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
        if(currUser.Societa__c == 'Warrant' || currUser.Name == 'Automated Process'){
            
            Set<String> oppCallList = new Set<String>();
            Map<String,sObject> opptStage = Utilities.keyBy([SELECT  Id, MasterLabel, ApiName, DefaultProbability FROM OpportunityStage], 'ApiName');
            
            //Map<String,sObject> oppRecType = Utilities.keyBy([SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Opportunity' and IsActive = true ], 'Id');
            
            System.debug('opptStage : '+ opptStage);
            for (Id oppId : newOptMap.keyset()){
                System.debug('(String)newOptMap.get(oppId).get(StageName) : '+(String)newOptMap.get(oppId).get('StageName'));
                System.debug('opptStage.get((String)newOptMap.get(oppId).get(StageName)) : '+opptStage.get((String)newOptMap.get(oppId).get('StageName')));
                
                System.debug('(Decimal)opptStage.get((String)newOptMap.get(oppId).get(StageName)).get(DefaultProbability) : '+(Decimal)opptStage.get((String)newOptMap.get(oppId).get('StageName')).get('DefaultProbability'));
                System.debug('(Integer)opptStage.get((String)oldOptMap.get(oppId).get(StageName)).get(DefaultProbability) : '+(Decimal)opptStage.get((String)newOptMap.get(oppId).get('StageName')).get('DefaultProbability'));
                //System.debug('(String)newOptMap.get(oppId).get(RecordType.Name)'+ (String)newOptMap.get(oppId).get('RecordType.Name'));
                if(((Decimal)opptStage.get((String)newOptMap.get(oppId).get('StageName')).get('DefaultProbability')!= null) &&
                   ((Decimal)opptStage.get((String)newOptMap.get(oppId).get('StageName')).get('DefaultProbability') >= 50.00 || (Decimal)opptStage.get((String)newOptMap.get(oppId).get('StageName')).get('DefaultProbability') == 0) &&
                   ((String)newOptMap.get(oppId).get('Societariferimento_formula__c') =='Warrant') && 
                   !System.isFuture() && newOptMap.get(oppId).get('RecordTypeId') == Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Warrant').getRecordTypeId()){
                       oppCallList.add(newOptMap.get(oppId).Id);
                   }
            }
            if(oppCallList.size()>0) WRT_IntegrazioneController.opportunityIntegration(oppCallList);
            // disableOppUpdate = true;     
            
        }
    }
    
    public static void ereditaCampiFromObject (List<Opportunity> optList, User currUser){
        System.debug('SV optList: ' + optList);
        //   User currUser = [ SELECT Id, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
        if(currUser.Societa__c == 'Warrant'){
            Set<Id> accIdInOppList = new Set<id>();
            for(Opportunity opt : optList){
                if(opt.AccountId != null && opt.Escludi_da_template__c == false){
                    accIdInOppList.add(opt.AccountId);
                }
            }
            System.debug('SV accIdInOppList: ' + accIdInOppList);
            Map<String, SObject> associatedAccountMap = new Map<String, SObject>();
            if(accIdInOppList.size() > 0) associatedAccountMap = Utilities.keyBy([SELECT  Id, Name, WRT_Modalita_pagamento__c
                                                                         FROM Account 
                                                                         WHERE id IN : accIdInOppList ], 'Id');  
            
            if(associatedAccountMap.size()>0){
                for(Opportunity opt : optList){
                    if(opt.AccountId != null){
                        opt.WRT_Modalita_pagamento__c = (String)associatedAccountMap.get(opt.AccountId).get('WRT_Modalita_pagamento__c');  
                    }       
                } 
            }
            
        }
        
    }
    
    public static void AggiornaOppInfocert (List<Opportunity> oppList){
        
        List <Opportunity> nopp = new List <Opportunity>();
        
        //id rid = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND   DeveloperName = 'InfoCert' ].Id;
        
        //TESTARE
        id rid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('InfoCert').getRecordTypeId();
        
        
        for(Opportunity opp : oppList){
            system.debug('TESTEU ' + opp.RecordTypeId + opp.INF_Nome_Trattativa__c);
            if(opp.RecordTypeId == rid && opp.INF_Nome_Trattativa__c != null){
                
                opp.Name = opp.INF_Nome_Trattativa__c;
                
                if(opp.Fatturazione_cliente_finale__c == false){
                    opp.Referral_Partner_InfoCert__c = opp.Account_Partner_InfoCert__c; 
                    
                }  
                if(opp.Fatturazione_cliente_finale__c == true){
                    opp.Reseller_Partner__c = opp.Account_Partner_InfoCert__c;  
                }
                
                nopp.add(opp);
            }
        }           
    }
    
    public static void blockDelete(Map<Id,Opportunity> oppMap){
        User currUser = [ SELECT Id, Societa__c, UserRole.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        system.debug('currUser.UserRole.Name: '+ currUser.UserRole.Name);
        
        if(currUser.Societa__c == 'Warrant' && (currUser.UserRole.Name == 'Warrant Sales Support' || currUser.UserRole.Name == 'Warrant Operatore Marketing' || currUser.UserRole.Name == 'Warrant Alliance Manager')){
            //Map<String,sObject> oppRecTypeMap = Utilities.keyBy([SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Opportunity' and IsActive = true ], 'Id');
            
            Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity; 
            Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById(); 
            
            Map<String,sObject> opptStage = Utilities.keyBy([SELECT  Id, MasterLabel, ApiName, DefaultProbability FROM OpportunityStage WHERE IsActive = true], 'ApiName');
            Map<String,sObject> itemMap =Utilities.keyBy([SELECT  Id, OpportunityId FROM OpportunityLineItem WHERE OpportunityId IN: oppMap.values()], 'OpportunityId');
            for(Opportunity opp : oppMap.values()){
                system.debug('prob: '+(Decimal)opptStage.get(opp.StageName).get('DefaultProbability'));
                if(rtMapById.get(opp.RecordTypeId).getDeveloperName() == 'Warrant' || rtMapById.get(opp.RecordTypeId).getDeveloperName() == 'WRT_CPQ'){
                    if(itemMap.get(opp.Id) != null){
                        opp.addError(System.Label.OpportunityError_Products);
                    }
                    if(opp.Numero_offerta_Infostore__c != null && opp.Numero_offerta_Infostore__c != ''){
                        opp.addError(System.Label.OpportunityError_Infostore);
                    }
                    if ((Decimal)opptStage.get(opp.StageName).get('DefaultProbability') >= 50.00 || (Decimal)opptStage.get(opp.StageName).get('DefaultProbability') == 0){
                        opp.addError(System.Label.OpportunityError_Probability);
                    }
                }
            }
        }
    }
    
    public static void changeOwner(List<Opportunity> oppList, User currUser){
        system.debug('RC changeOwner');
        //   User currUser = [ SELECT Id, Societa__c, UserRole.Name, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        system.debug('currUser.Societa__c: '+currUser.Societa__c);
        
        //Escludo il caso CPQ --> ci pensa la Quote a fare questa Operazione
        
        Map<Id,Schema.RecordTypeInfo> rtMap = Opportunity.sobjectType.getDescribe().getRecordTypeInfosById(); 
        system.debug('RT: '+ rtMap);
        
        if(currUser.Societa__c == 'Warrant' && currUser.Profile.Name != 'Warrant - Integration Profile'){
            Set<Id> AccountIds = new Set<Id>();
            for(Opportunity oppl : oppList){
                if(rtMap.get(oppl.RecordTypeId).getDeveloperName() == 'Warrant'){ 
                    AccountIds.add(oppl.AccountId);
                }
                Map<String,sObject> accMap = new Map<String,sObject> ();
                if(AccountIds.size() > 0) accMap = Utilities.keyBy([SELECT Id, Responsabile_WarrantHub__c FROM Account WHERE Id IN : AccountIds],'Id');
                system.debug('accMap: '+accMap);
                
                
                If(accMap.size()>0){    
                    for(Opportunity opp : oppList){
                        system.debug('opp.OwnerId: '+opp.OwnerId);
                        if(currUser.Id == opp.OwnerId){           
                            if(accMap.get(opp.AccountId).get('Responsabile_WarrantHub__c')!= null){
                                opp.OwnerId = (Id)accMap.get(opp.AccountId).get('Responsabile_WarrantHub__c');        
                            } 
                        }
                        
                    }
                }
            }
        }
        
    }		
    
    public static void setFilds(List<Opportunity> oppList){
        Map<Id,Schema.RecordTypeInfo> rtMap = Opportunity.sobjectType.getDescribe().getRecordTypeInfosById();
        
        for(Opportunity opp : oppList){
            System.debug('Record type for Opportunity ' + opp.Name 
                         + ' has developer name ' + rtMap.get(opp.RecordTypeId).getDeveloperName());
            if(rtMap.get(opp.RecordTypeId).getDeveloperName() == 'Warrant'){
                if(opp.IsClosed){
                    if(opp.StageName == 'Chiuse/Perse'){
                        if(opp.Data_respinta__c == null) opp.Data_respinta__c = Date.today();
                        opp.WRT_DataOrdine__c = null;
                    }
                    
                    if(opp.StageName == 'Chiuse/Conseguite'){
                        if(opp.WRT_DataOrdine__c == null) opp.WRT_DataOrdine__c = Date.today();
                        opp.Data_respinta__c = null;
                    }
                    
                } else {
                    opp.WRT_DataOrdine__c = null;
                    opp.Data_respinta__c = null;
                }
            }
        }
    }

    //AMS 001083
    /**
     * controllo per impedire di mettere in chiusa persa un'opportunità se c'è un work order in lavorazione
     */
    public static void checkWOChiusaPersa(map<id,Opportunity> newMap, map<id, opportunity> oldMap)
    {
        //if user profile contains administrator
        User usr = [SELECT profile.Name, userRole.Name FROM User WHERE id = :System.UserInfo.getUserId()];
        String profileName = usr.profile.Name;
        String roleName = usr.userRole.Name;            
        Map<Id,Schema.RecordTypeInfo> rtMap = Opportunity.sobjectType.getDescribe().getRecordTypeInfosById();
        map<id, list<workorder>> mapOppWo = new map<id, list<workorder>>();
        for(Opportunity opp : newMap.values())
        {
            system.debug(opp.StageName + ' '+ oldMap.get(opp.id).StageName +' '+rtMap.get(opp.RecordTypeId).getDeveloperName());
            if(opp.StageName == 'Chiuse/Perse' && oldMap.get(opp.id).StageName != 'Chiuse/Perse' &&
              (rtMap.get(opp.RecordTypeId).getName() == 'Warrant' 
              || rtMap.get(opp.RecordTypeId).getName() == 'WRT CPQ') &&
              (!profileName.toLowerCase().contains('administrator') || !profileName.toLowerCase().contains('amministratore') || !roleName.toLowerCase().contains('sales support')))
            {
                mapOppWo.put(opp.id, null);
            }
        }
        if(mapOppWo.keyset().size() > 0)
        {
            for(workorder wok : [select id, WRT_Opportunity__c from workorder where status != 'New' and WRT_Opportunity__c in :mapOppWo.keyset()])
            {
                if(mapOppWo.get(wok.WRT_Opportunity__c) != null)
                {
                    mapOppWo.get(wok.WRT_Opportunity__c).add(wok);
                }
                else
                {
                    mapOppWo.put(wok.WRT_Opportunity__c, new list<workorder>{wok});
                }
            }
            for(Opportunity opp : newMap.values())
            {
                if(mapOppWo.get(opp.id) != null)
                {
                    opp.addError(System.Label.WRT_Opp_Error_ClosedLost);
                }
            }
        }
    }
        
    public static void AggiornoEsercizio(Map<Id,Opportunity> newinput, Map <Id,Opportunity> oldinput){
        
        Set<String> OppId = new Set<String>();  
        
        //solo per RT Warrant OLD
        Map<Id,Schema.RecordTypeInfo> rtMap = Opportunity.sobjectType.getDescribe().getRecordTypeInfosById();
        
        
        for (Id o : newinput.keyset()){
            If(rtMap.get(newinput.get(o).RecordTypeId).getDeveloperName() == 'Warrant'){
                Opportunity oldopp= oldinput.get(newinput.get(o).Id);
                if(newinput.get(o).Anno_di_competenza__c != oldopp.Anno_di_competenza__c){
                    OppId.add(newinput.get(o).Id);          
                }
            }
        }
        
        if(OppId.size() > 0)
        {
            map<String, OpportunityLineItem> mtpOPPLineMap  = new map <String, OpportunityLineItem>([SELECT Id, WRT_esercizio__c, OpportunityId
                                                                                                     FROM OpportunityLineItem 
                                                                                                     WHERE OpportunityId IN : OppId
                                                                                                    ]);
            for(Id o:newinput.keyset()){
                for(Id oli:mtpOPPLineMap.keyset()){
                    if(newinput.get(o).Id == mtpOPPLineMap.get(oli).OpportunityId){
                        If(newinput.get(o).Anno_di_competenza__c != mtpOPPLineMap.get(oli).WRT_esercizio__c ){
                            mtpOPPLineMap.get(oli).WRT_esercizio__c = newinput.get(o).Anno_di_competenza__c;
                        }
                    }
                }
            }
            If(mtpOPPLineMap.size() >0){
                update mtpOPPLineMap.values();
            }
        }
    }
    
    public static void ChangeAccount (Map<Id,Opportunity> newinput, Map <Id,Opportunity> oldinput){
        
        Set<String> OppId = new Set<String>();  
        
        
        for (Id o : newinput.keyset()){
            If(newinput.get(o).Societariferimento_formula__c == 'Warrant' || newinput.get(o).Societariferimento_formula__c == 'WRT CPQ'){
                Opportunity oldopp= oldinput.get(newinput.get(o).Id);
                if(newinput.get(o).AccountId != oldopp.AccountId){
                    OppId.add(newinput.get(o).Id);          
                }
            }
        }
        
        if(OppId.size() > 0)
        {
            map<String, OpportunityLineItem> mtpOPPLineMap  = new map <String, OpportunityLineItem>([SELECT Id, WRT_Account__c, OpportunityId
                                                                                                     FROM OpportunityLineItem 
                                                                                                     WHERE OpportunityId IN : OppId
                                                                                                    ]);
            for(Id o:newinput.keyset()){
                for(Id oli:mtpOPPLineMap.keyset()){
                    if(newinput.get(o).Id == mtpOPPLineMap.get(oli).OpportunityId){
                        If(newinput.get(o).AccountId != mtpOPPLineMap.get(oli).WRT_Account__c ){
                            mtpOPPLineMap.get(oli).WRT_Account__c = newinput.get(o).AccountId;
                        }
                    }
                }
            }
            If(mtpOPPLineMap.size() >0){
                update mtpOPPLineMap.values();
            }
        }
    }
    
    
    public static void sharepointCMK(List<Opportunity> opportunitys, Map<Id,Opportunity> oldOpportunitys) {
        List<Id> optySharepoint = new List<Id>();
        Id cmk_rtId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Co_Mark').getRecordTypeId();
        
        for(Opportunity opp : opportunitys) {
            if(opp.RecordTypeId == cmk_rtId && 
               opp.StageName == 'Chiuse/Conseguite' && 
               oldOpportunitys.get(opp.Id).StageName != opp.StageName && 
               opp.CMK_Url_Sharepoint__c == null) {
                   optySharepoint.add(opp.Id);
               }
        }
        
        if(!optySharepoint.isEmpty()) {
            System.enqueueJob(new CMK_SharepointIntegrationCtrl(optySharepoint));
        }
    }
}