public without sharing class OnAccountTriggerHandler {

    public static Boolean disableUpdate = false;

    public static void manageAccountBeforeInsert(List<Account> newAccount){

        // Set<Id> accIdList = new Set<id>();
        // Set<String> codFiscOnAccountList = new Set<String>();
        // Set<String> pIvaOnAccountList = new Set<String>();
        // for (Account acc : newAccount){
        //     accIdList.add(acc.Id);
        //     // codFiscOnAccountList.add(acc.Codice_Fiscale__c);      
        //     // pIvaOnAccountList.add(acc.Partita_Iva__c);  
        // }

        //Map<String, SObject> leadList  = Utilities.keyBy([SELECT Label,Codice__c FROM Gestore_Societa__mdt], 'Label');
        User usr = [ SELECT Id, Name, Profile.Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId() ];
        
        
        //Map<String, Gestore_Societa__mdt> mtdSocietMap  = Utilities.keyBy(Gestore_Societa__mdt.getAll().values(), 'Label');
        Map<String, SObject> mtdSocietMap  = Utilities.keyBy(Gestore_Societa__mdt.getAll().values(), 'Label');

        String cs;

        for(Account acc : newAccount){
          if(acc.Societa_su_CTM__c == null && (usr.Societa__c != 'Innolva' || usr.Societa__c != 'ReValuta')) acc.Societa_su_CTM__c = usr.Societa__c;
          if(acc.Inn_societa__c == null && usr.Societa__c == 'Innolva') acc.INN_societa__c = usr.Societa__c;
          if(acc.REV_societa__c == null && usr.Societa__c == 'ReValuta') acc.REV_societa__c = usr.Societa__c;
          
                //acc.Societ__c = acc.Societ__c.toLowerCase();
                system.debug('acc.Societa_su_CTM__c : ' + acc.Societa_su_CTM__c);
                //Qui come fare?
                cs = (usr.Societa__c == 'Innolva')? (String)mtdSocietMap.get(acc.INN_societa__c).get('Codice__c') : ((usr.Societa__c == 'ReValuta')? (String)mtdSocietMap.get(acc.REV_societa__c).get('Codice__c') : (String)mtdSocietMap.get(acc.Societa_su_CTM__c).get('Codice__c'));
                if(cs != null){
                    acc.cod_soc__c = cs;
                }
          
            //SM - Gestione Rating Infocert
            //if(acc.Rating__c != 'ND' && acc.Rating__c != null)
              //  acc.RatingInfocert__c = acc.Rating__c;
        }        
    } 

public static void manageAccountBeforeUpdate(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap){
        system.debug('Riccardo');

        Map<String, SObject> mtdSocietMap  = Utilities.keyBy(Gestore_Societa__mdt.getAll().values(), 'Label');
        String cs;

        for(Account accNew : newAccountMap.values()){
            System.debug('accNew.Societa_su_CTM__c: '+accNew.Societa_su_CTM__c);
            System.debug('oldAccountMap.get(accNew.Id).Societa_su_CTM__c '+oldAccountMap.get(accNew.Id).Societa_su_CTM__c );
            if(accNew.Societa_su_CTM__c != null && oldAccountMap.get(accNew.Id).Societa_su_CTM__c != accNew.Societa_su_CTM__c){
                //accNew.Societ__c = accNew.Societ__c.toLowerCase();
                system.debug('acc.Societa_su_CTM__c : ' + accNew.Societa_su_CTM__c);
                List<String> str = accNew.Societa_su_CTM__c.split(';');
                system.debug('str TEST' + str);
                //Qui come fare?
                cs='';
                for(String s : str){
                    cs += (String)mtdSocietMap.get(s).get('Codice__c');
                }
                cs = cs.substringBeforeLast(';');
                /*if(cs.containsAny('null')){
                cs = cs.remove('null');
                }*/
                
                if(cs != null){
                    accNew.cod_soc__c = cs;
                }
            }
        }
        
    } 

    public static void updateAccountAsyncAndCreateSlaveData(List<Account> newAccount){
        Set<Id> accIds = new Set<Id>();  //CREO SET DI ID   
        for(Account acc : newAccount){   //PER OGNI NUOVO ACCOUNT CONTROLLO CHE NON SIA GIA' STATO CLONATO
            if(!acc.Escludi_da_Deduplica__c){
                accIds.add(acc.Id);  //SE NON LO E' LO AGGIUNGO AL SET
            }
        }
        if(accIds.size()>0){
            AsyncExecutionOnAccount executeQueueable = new AsyncExecutionOnAccount(accIds);  //PASSO IL SET AD ASYNCEXE
            ID jobID = System.enqueueJob(executeQueueable);
            system.debug('jobID : ' + jobID);
        }
    }

    // TODO: SOLO PER DEDUP Clouding - Da Eliminare
    // public static void updateAccountAsyncAndCreateSlaveData_Dedup(List<Account> newAccount, Map<Id,Account> oldAccount){
    //     Set<Id> accIds = new Set<Id>();  //CREO SET DI ID   
    //     for(Account acc : newAccount){   //PER OGNI NUOVO ACCOUNT CONTROLLO CHE NON SIA GIA' STATO CLONATO
    //         // if(!acc.Escludi_da_Deduplica__c){
    //             // accIds.add(acc.Id);  //SE NON LO E' LO AGGIUNGO AL SET
    //         // }

    //         if(acc.FatturatoFascia_Innolva__c != null && acc.FatturatoFascia_Innolva__c.contains('SLAVE') && ((oldAccount.get(acc.Id).FatturatoFascia_Innolva__c != null && !oldAccount.get(acc.Id).FatturatoFascia_Innolva__c.contains('SLAVE')) || oldAccount.get(acc.Id).FatturatoFascia_Innolva__c == null) && !acc.Escludi_Da_Deduplica__c ){
    //             accIds.add(acc.Id);
    //         }
    //     }
    //     if(accIds.size()>0){
    //         AsyncExecutionOnAccount executeQueueable = new AsyncExecutionOnAccount(accIds);  //PASSO IL SET AD ASYNCEXE
    //         ID jobID = System.enqueueJob(executeQueueable);
    //         system.debug('jobID : ' + jobID);
    //     }   
    // }
    
    public static void CreateMapSlave(list<Account> newAccount){
        system.debug('CreateMapSlave : ' );
        list<Map_Slave__c> ListMapSlave  = new list<Map_Slave__c>();    //Creo lista di oggetti map slave
        
        for(Account a:newAccount){
            // creo per ogni nuova anagrafica il corrispettivo record 
            // Map_Slave__c che verrà utilizzato a fronte di una deduplica
            Map_Slave__c ms    = new Map_Slave__c();
            ms.Name            = a.Id; 
            ms.Account__c      = a.Id;
            ms.Id_Account__c   = a.Id;
            
            ListMapSlave.add(ms);
            
        }
        
        if(ListMapSlave.size()>0){      //SE HO CREATO QUALCHE SLAVE INSERISCO LA LISTA
            insert ListMapSlave;
            
            System.debug('AK LIST: ' + ListMapSlave);
        }
        
    }

    public static void VerifyDuplicatedCTM(list<Account> newAccount){
        System.debug('SV VerifyDuplicatedCTM: ' + newAccount);
        Set <Id> accIdFromCTM = new Set<id>();

        for (Account a : newAccount){
            accIdFromCTM.add(a.Id);        
        }
        
        Map<String, SObject> cmtMap = Utilities.keyBy([SELECT  Id, Account__c, User__c 
                                                                     FROM Coverage_Team_Member__c 
                                                                     WHERE Account__c 
                                                                     IN : accIdFromCTM ], '{Id}-{Account__c}-{User__c}', true);

        System.debug('SV cmtMap: ' + cmtMap);

        List<String> accUserList = new List<String>();
        List<Coverage_Team_Member__c> actmDeleteList = new List<Coverage_Team_Member__c>();
        for (String key : cmtMap.keySet()){
            String[] arrTest = key.split('-');
            Boolean find = false;
            for(String x : accUserList){
                if(x == arrTest[1]+'-'+arrTest[2]) find = true;
            }

            if(find){
                actmDeleteList.add((Coverage_Team_Member__c)cmtMap.get(key));
            } else {
                accUserList.add(arrTest[1]+'-'+arrTest[2]);
            }
        }

        if (actmDeleteList.size()>0){
            OnCoverageTeamTriggerHandler.disableDelete = true;
            delete actmDeleteList;
        }
    }

   // INTEGRAZIONE
    public static void makeCallAccount(Map<Id,sObject> newObjMap){

        List<Id> objIdList = new List<Id>();
        
        User currentUser = [SELECT Id, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];

        for (Id key : newObjMap.keySet()) {
            // The "key" variable is also available inside the loop
            // System.debug('SV RecordType: ' + newObjMap.get(key).get('Societa_su_CTM__c'));
            // System.debug('@@@ controllo 1 ' + newObjMap.get(key).get('Coverage_Member_WarrantHub__c'));
            // System.debug('@@@ controllo 2 ' + newObjMap.get(key).get('Link_warrant__c'));
            // System.debug('@@@ controllo 3 ' + System.isFuture());
            // System.debug('@@@ controllo 4 ' + System.isBatch());

            // if(newObjMap.get(key).get('Coverage_Member_WarrantHub__c') == true &&
            if(currentUser.Societa__c == 'Warrant' &&
                newObjMap.get(key).get('Link_warrant__c') == null &&
                !System.isFuture() && !System.isBatch()){
                objIdList.add(key);
            }
        }
        
        if(objIdList.size()>0) WRT_IntegrazioneController.accountIntegration(objIdList);
        
        
    }

    /*public static void updateSlave (List<Account> accList){    

        String utenzeCloudingo = UtenzeDefault__c.getInstance().Utenze_Cloudingo__c;
        System.debug('SV utenzeCloudingo: ' + utenzeCloudingo);
        System.debug('SV utenzeCloudingo: ' + utenzeCloudingo.contains(UserInfo.getUserId()));

        if(!utenzeCloudingo.contains(UserInfo.getUserId()) && !disableUpdate)UpdateSlaveDataFromAccount.UpdateSlaveData(accList);
    
    }*/

    public static void checkAccountPartnerInfocert(Map<Id,Account> newMap, Map<Id,Account> oldMap){
        User usr = [SELECT profile.Name FROM User WHERE id = :System.UserInfo.getUserId()];
        String profileName = usr.profile.Name;
        Set<Id> idSet = new Set<Id>();
        Map<Id, List<Account>> mapAcc = new Map<Id, List<Account>>();

        if(!profileName.toLowerCase().contains('infocert – amministratore')){
            for(Id accId :newMap.keyset()){
                if(newMap.get(accId).Type != oldMap.get(accId).Type){
                    mapAcc.put(accId,null);
                }
            }        
            for(Account acc :[SELECT id, INF_Partner_Account__c  FROM Account WHERE INF_Partner_Account__c IN :mapAcc.keyset()]){
                if(mapAcc.get(acc.INF_Partner_Account__c) != null){
                    mapAcc.get(acc.INF_Partner_Account__c).add(acc);
                } else mapAcc.put(acc.INF_Partner_Account__c, new list<Account>{acc});                
            }
            for(Account acc :newMap.values()){
                if(mapAcc.get(acc.Id) != null){
                    acc.type.addError(system.label.INF_BlockTypeOnPartnerAccount);
                }
            }
        }       
    }        
}