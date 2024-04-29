public class OnCoverageTeamTriggerHandler{

    public static Boolean disableUpdate = false;
    public static Boolean disableDelete = false;

 public static void UpdateFieldsToAccount(String triggerType, List <Coverage_Team_Member__c> ctmList){
        System.debug('RC UpdateFieldsToAccountS');
        Set<Id> accIdFromCTM = new Set<id>();
        Set<Id> usrIdFromCTM = new Set<id>();

        for (Coverage_Team_Member__c ctm : ctmList){
            accIdFromCTM.add(ctm.Account__c);       
            usrIdFromCTM.add(ctm.User__c);   
        }

        Map<String, SObject> associatedAccountMap = Utilities.keyBy([SELECT  Id, Name, Societa_su_CTM__c, INN_societa__c, REV_societa__c, Id_Esterni_CTM_User__c,Responsabile_WarrantHub__c,
                                                                        Responsabile_Sixtema__c, Responsabile_Infocert__c, Responsabile_Camerfirma__c, Responsabile_Luxtrust__c
                                                                     
                                                                     FROM Account 
                                                                     WHERE id 
                                                                     IN :accIdFromCTM ], 'Id');

        System.debug('RC associatedAccountMap : '+associatedAccountMap);

     
     	//Ottimizzazione Extra --> cmtMap si può joinare con quella prima
        Map<String, SObject> cmtMap = Utilities.keyBy([SELECT  Id, Account__c, User__c, Societa__c 
                                                                     FROM Coverage_Team_Member__c 
                                                                     WHERE Account__c 
                                                                     IN :accIdFromCTM], 'Id');
        
         List<String> ctmUsers = new List<String>();
         for(String key : cmtMap.keySet()){
             ctmUsers.add((String)cmtMap.get(key).get('User__c'));
         }

     	//Ottimizzazione --> 1 solo query e usare If per spezzare mappa
        Map<String, SObject> associatedUserMap = Utilities.keyBy([SELECT  Id, Name, Id_Esterno__c, Societa__c	 
                                                                     FROM User 
                                                                     WHERE id 
                                                                     IN :ctmUsers ], 'Id');

        Map<String, SObject> associatedUserMap2 = Utilities.keyBy([SELECT  Id, Name, Id_Esterno__c, Societa__c	 
                                                                     FROM User 
                                                                     WHERE id 
                                                                     IN :usrIdFromCTM ], 'Id');
        
        System.debug ('associatedAccountMap: '+associatedAccountMap);
        System.debug ('associatedUserMap: '+associatedUserMap);
        System.debug ('cmtMap: '+cmtMap);


        List<sObject> accList = new List<sObject>();
        if(triggerType == 'isUpsert'){

            sObject acc;
            sobject usr;
            String val;
            string valINN;
            string valRev;
            String idExt;
            String valExtToAdd;
            String valExtNow;



            for (Coverage_Team_Member__c ctm : ctmList){
                acc = associatedAccountMap.get(ctm.Account__c);
                usr = associatedUserMap.get(ctm.User__c);
                system.debug('RC Account:'+acc);
                system.debug('RC acc.get(Societa_su_CTM__c):'+ acc.get('Societa_su_CTM__c'));
                system.debug('RC ctm.Societa__c:'+ctm.Societa__c);
                system.debug('RC ctm:'+ctm);


                val = '';
                idExt='';
                valINN = '';
                valRev = '';
                // InsertSocConcat
                // InsertExternalIDConcat
                for (String key : cmtMap.keySet()){
                    if((String)cmtMap.get(key).get('Account__c') == (String)acc.get('Id')){
                        if(ctm.Societa__c != 'Innolva' || ctm.Societa__c != 'ReValuta' )
                        {
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') != 'Innolva' && !val.contains((String)cmtMap.get(key).get('Societa__c'))) val = val + (String)cmtMap.get(key).get('Societa__c') + ';';
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') == 'Innolva' && !valINN.contains('Innolva')) valINN = 'Innolva';
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') == 'ReValuta' && !valRev.contains('ReValuta')) valRev = 'ReValuta';
                            
                        }
                        if(ctm.Societa__c == 'Innolva')
                        {
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') != 'Innolva' && !val.contains((String)cmtMap.get(key).get('Societa__c'))) val = (String)cmtMap.get(key).get('Societa__c') + ';';
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') == 'Innolva' && !valINN.contains('Innolva')) valINN = 'Innolva';
                        }
                        if(ctm.Societa__c == 'ReValuta')
                        {
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') != 'ReValuta' && !val.contains((String)cmtMap.get(key).get('Societa__c'))) val = (String)cmtMap.get(key).get('Societa__c') + ';';
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') == 'ReValuta' && !valRev.contains('ReValuta')) valRev = 'ReValuta';
                        }
                        if((String)associatedUserMap.get((String)cmtMap.get(key).get('User__c')).get('Id_Esterno__c') != null && (!idExt.contains((String)associatedUserMap.get((String)cmtMap.get(key).get('User__c')).get('Id_Esterno__c')))) idExt = idExt + (String)associatedUserMap.get((String)cmtMap.get(key).get('User__c')).get('Id_Esterno__c')+';';
                    }
                }
                System.debug('RC val'+val);
                System.debug('RC idExt'+idExt);
                val = val.removeEnd(';');
                idExt=idExt.removeEnd(';');                
                associatedAccountMap.get(ctm.Account__c).put('Societa_su_CTM__c', val);   
                associatedAccountMap.get(ctm.Account__c).put('INN_societa__c', valINN);     
                associatedAccountMap.get(ctm.Account__c).put('REV_societa__c', valRev);     
                associatedAccountMap.get(ctm.Account__c).put('Id_Esterni_CTM_User__c', idExt); 

                

                // InsertExternalIDConcat
                // valExtToAdd = usr.get('Id_Esterno__c') == null ? '' : (String)usr.get('Id_Esterno__c');
                // valExtNow= acc.get('Id_Esterni_CTM_User__c') == null ? '' : (String)acc.get('Id_Esterni_CTM_User__c');
                system.debug('valExtToadd'+valExtToAdd);
                system.debug('valExtNow'+valExtNow);
                // associatedAccountMap.get(ctm.Account__c).put('Id_Esterni_CTM_User__c',  valExtNow=='' ? valExtToAdd : valExtNow + ';' + valExtToAdd);   

                // OVVERRIDE Del Responsabile IN ATTESA DI VERICA - PER ORA VIENE SOVRASCRITTO SEMPRE DALL'ULTIMO CTM
                // InsertResponsabileSixtema
                System.debug('SV Societa: ' + usr);
                System.debug('SV Societa: ' + (String)usr.get('Societa__c'));
                if((String)usr.get('Societa__c') == 'Sixtema'){
                    associatedAccountMap.get(ctm.Account__c).put('Responsabile_Sixtema__c', (String)usr.get('Id')); 
                } 
                if((String)usr.get('Societa__c') == 'Warrant' && ctm.Ruolo_Coverage_Team__c == 'Responsabile account'){
                    associatedAccountMap.get(ctm.Account__c).put('Responsabile_WarrantHub__c', (String)usr.get('Id')); 
                } 

                if(val.contains('Sixtema')){
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Sixtema__c', (Boolean)True); 
                    } else {
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Sixtema__c', (Boolean)False); 
                    }

                // InsertResponsabileInfocert
                if((String)usr.get('Societa__c') == 'Infocert'){
                    associatedAccountMap.get(ctm.Account__c).put('Responsabile_Infocert__c', (String)usr.get('Id')); 
                    
                }  

                if(val.contains('Infocert')){
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Infocert__c', (Boolean)True); 
                    } else {
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Infocert__c', (Boolean)False); 
                    } 

                // InsertResponsabileCamerfirma
                if((String)usr.get('Societa__c') == 'Camerfirma'){
                    associatedAccountMap.get(ctm.Account__c).put('Responsabile_Camerfirma__c', (String)usr.get('Id')); 
                    
                }

                if(val.contains('Camerfirma')){
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Camerfirma__c', (Boolean)True); 
                    } else {
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Camerfirma__c', (Boolean)False); 
                    }

                // InsertResponsabileLuxtrust
                if((String)usr.get('Societa__c') == 'Luxtrust'){
                    associatedAccountMap.get(ctm.Account__c).put('Responsabile_Luxtrust__c', (String)usr.get('Id')); 
                    
                }    
                if(val.contains('Luxtrust')){
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Luxtrust__c', (Boolean)True); 
                    } else {
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Luxtrust__c', (Boolean)False); 
                    }

                // InsertResponsabileWarrantHub
                    if(val.contains('Warrant')){
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_WarrantHub__c', (Boolean)True); 
                    } else {
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_WarrantHub__c', (Boolean)False); 
                    }

                // InsertResponsabileWarrantHub
                    if(val.contains('CoMark')){
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Co_Mark__c', (Boolean)True); 
                    } else {
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Co_Mark__c', (Boolean)False); 
                    }

                // InsertResponsabileInnolva
                    if(valINN.contains('Innolva')){
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Innolva__c', (Boolean)True); 
                    } else {
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Innolva__c', (Boolean)False); 
                    }

                    if(valRev.contains('ReValuta')){
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_ReValuta__c', (Boolean)true); 
                    } else {
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_ReValuta__c', (Boolean)false); 
                    }

                    if(val.contains('Corvallis')){
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Corvallis__c', (Boolean)true); 
                    } else {
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Corvallis__c', (Boolean)false); 
                    }

                    if(val.contains('Swascan')){
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Swascan__c', (Boolean)true); 
                    } else {
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Swascan__c', (Boolean)false); 
                    }

                    if(val.contains('Visura')){
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Visura__c', (Boolean)true); 
                    } else {
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Visura__c', (Boolean)false); 
                    }

                    if(val.contains('Yoroi')){
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Yoroi__c', (Boolean)true); 
                    } else {
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Yoroi__c', (Boolean)false); 
                    }
                
                accList.add(acc);
            }

        } else {
            //ToDO RICCARDO

            sObject acc;
            sobject usr;
            String val;
            string valINN;
            string valRev;
            String idExt;

           for (Coverage_Team_Member__c ctm : ctmList){
                acc = associatedAccountMap.get(ctm.Account__c);
                usr = associatedUserMap2.get(ctm.User__c);
                system.debug('RC Account:'+acc);
                system.debug('RC acc.get(Societa_su_CTM__c):'+ acc.get('Societa_su_CTM__c'));
                system.debug('RC ctm.Societa__c:'+ctm.Societa__c);
                system.debug('RC ctm:'+ctm);


                val = '';
                valINN = '';
                valRev = '';
                idExt='';
                // InsertSocConcat
                // InsertExternalIDConcat
                for (String key : cmtMap.keySet()){
                    System.debug('RC key: '+key);
                    // val = val + (String)cmtMap.get(key).get('Societa__c') + ';';
                    // if(!val.contains((String)cmtMap.get(key).get('Societa__c'))) val = val + (String)cmtMap.get(key).get('Societa__c') + ';';
                    if((String)cmtMap.get(key).get('Account__c') == (String)acc.get('Id')){
                        if(ctm.Societa__c != 'Innolva' || ctm.Societa__c != 'ReValuta')
                        {
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') != 'Innolva' && !val.contains((String)cmtMap.get(key).get('Societa__c'))) val = val + (String)cmtMap.get(key).get('Societa__c') + ';';
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') == 'Innolva' && !valINN.contains('Innolva')) valINN = 'Innolva';
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') == 'ReValuta' && !valRev.contains('ReValuta')) valRev = 'ReValuta';
                            
                        }
                        if(ctm.Societa__c == 'Innolva')
                        {
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') != 'Innolva' && !val.contains((String)cmtMap.get(key).get('Societa__c'))) val = (String)cmtMap.get(key).get('Societa__c') + ';';
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') == 'Innolva' && !valINN.contains('Innolva')) valINN = 'Innolva';
                        }
                        if(ctm.Societa__c == 'ReValuta')
                        {
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') != 'ReValuta' && !val.contains((String)cmtMap.get(key).get('Societa__c'))) val = (String)cmtMap.get(key).get('Societa__c') + ';';
                            if((String)cmtMap.get(key).get('Societa__c') != null && (String)cmtMap.get(key).get('Societa__c') == 'ReValuta' && !valRev.contains('ReValuta')) valRev = 'ReValuta';
                        }
                        system.debug('RC val:'+val);
                        system.debug('RC: (String)cmtMap.get(key).get(User__c):'+(String)cmtMap.get(key).get('User__c'));
                    

                        idExt = idExt + (String)associatedUserMap.get((String)cmtMap.get(key).get('User__c')).get('Id_Esterno__c')+';';
                        system.debug('idExt: '+idExt);
                    }
                }
                val = val.removeEnd(';');
                idExt=idExt.removeEnd(';');                
                associatedAccountMap.get(ctm.Account__c).put('Societa_su_CTM__c', val);  
                associatedAccountMap.get(ctm.Account__c).put('INN_societa__c', valINN);     
                associatedAccountMap.get(ctm.Account__c).put('REV_societa__c', valRev);     
                associatedAccountMap.get(ctm.Account__c).put('Id_Esterni_CTM_User__c', idExt); 

                

                System.debug('SV user delete: ' + (String)usr.get('Id'));
                System.debug('SV resp su acc: ' + (String)acc.get('Responsabile_Infocert__c'));
                String x_id = (String)usr.get('Id');
                // RemoveResponsabileSixtema
                if((String)usr.get('Societa__c') == 'Sixtema'){
                    if(x_id.equals((String)acc.get('Responsabile_Sixtema__c'))) associatedAccountMap.get(ctm.Account__c).put('Responsabile_Sixtema__c', ''); 
                    if(!val.contains('Sixtema')) associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Sixtema__c', (Boolean)False); 
                } 

                // RemoveResponsabileInfocert
                if((String)usr.get('Societa__c') == 'Infocert'){
                    if(x_id.equals((String)acc.get('Responsabile_Infocert__c'))) associatedAccountMap.get(ctm.Account__c).put('Responsabile_Infocert__c', ''); 
                    if(!val.contains('Infocert')) associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Infocert__c', (Boolean)False); 
                }   

                // RemoveResponsabileCamerfirma
                if((String)usr.get('Societa__c') == 'Camerfirma'){
                    if(x_id.equals((String)acc.get('Responsabile_Camerfirma__c'))) associatedAccountMap.get(ctm.Account__c).put('Responsabile_Camerfirma__c', ''); 
                    if(!val.contains('Camerfirma')) associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Camerfirma__c', (Boolean)False); 
                }

                // RemoveResponsabileLuxtrust
                if((String)usr.get('Societa__c') == 'Luxtrust'){
                    if(x_id.equals((String)acc.get('Responsabile_Luxtrust__c'))) associatedAccountMap.get(ctm.Account__c).put('Responsabile_Luxtrust__c', ''); 
                    if(!val.contains('Luxtrust')) associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Luxtrust__c', (Boolean)False); 
                }    

                // RemoveResponsabileWarrantHub
                if((String)usr.get('Societa__c') == 'Warrant'){
                    system.debug('ci sono');
                    if(x_id.equals((String)acc.get('Responsabile_WarrantHub__c'))) associatedAccountMap.get(ctm.Account__c).put('Responsabile_WarrantHub__c', ''); 
                    if(!val.contains('WarrantHub')) associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_WarrantHub__c', (Boolean)False); 
                }   

                // RemoveResponsabileWarrantHub
                if((String)usr.get('Societa__c') == 'CoMark'){
                    if(!val.contains('CoMark')) associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Co_Mark__c', (Boolean)False); 
                } 

                // RemoveResponsabileInnolva
                if((String)usr.get('Societa__c') == 'Innolva'){
                    if(!valINN.contains('Innolva')) associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Innolva__c', (Boolean)False); 
                }

                if((String)usr.get('Societa__c') == 'ReValuta'){
                    if(!valRev.contains('ReValuta')) associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_ReValuta__c', (Boolean)false); 
                }

                if((String)usr.get('Societa__c') == 'Corvallis'){
                    if(!val.contains('Corvallis')) 
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Corvallis__c', (Boolean)false); 
                }

                if((String)usr.get('Societa__c') == 'Swascan'){
                    if(!val.contains('Swascan')) 
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Swascan__c', (Boolean)false); 
                }

                if((String)usr.get('Societa__c') == 'Visura'){
                    if(!val.contains('Visura')) 
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Visura__c', (Boolean)false); 
                }

                if((String)usr.get('Societa__c') == 'Yoroi'){
                    if(!val.contains('Yoroi')) 
                        associatedAccountMap.get(ctm.Account__c).put('Coverage_Member_Yoroi__c', (Boolean)false); 
                }
            
                acclist.add(acc);
            }
        }

      

        System.debug('RC before Update Account: ' + accList);
        
        Database.DMLOptions dml = new Database.DMLOptions(); 
		dml.DuplicateRuleHeader.allowSave = true;
        Database.SaveResult[] sr = Database.update(associatedAccountMap.values(), dml);
    }

   
    public static void updateAccountTeamFromTopAcct(List <Coverage_Team_Member__c> ttAcctList) {
        System.debug('SV updateAccountTeamFromTopAcct: ' + ttAcctList);

        List<Coverage_Team_Member__c> ttUpdateList = new List<Coverage_Team_Member__c>(); // trigger list

        List<String> assignedUserIdsList = new List<String>(); // Ids from Assigned Top Account users

        List<String> accountList = new List<String>(); // accounts IDs affected by Top Account

        Map<String,String> roleMap = new Map<String,String>();

        for(Coverage_Team_Member__c ttAcc : ttAcctList){
            accountList.add(ttAcc.Account__c);
            assignedUserIdsList.add(ttAcc.User__c);
        }

        List<Account> affectedAccounts = [select Id from Account where Id in : accountList]; // list of all accounts affected by top account
        List<AccountTeamMember> accountTeamList = new List<AccountTeamMember>(); // list of AccountTeamMembers to insert    
        Map <String,AccountTeamMember> atmMap = new Map<String,AccountTeamMember>();

        for(Account acct : affectedAccounts){
            for(Coverage_Team_Member__c ttAcc : ttAcctList){
                AccountTeamMember acctTM = new AccountTeamMember();
                String key = '';
                acctTM.AccountId = acct.Id;
                if(ttAcc.Account__c == acct.Id){
                    key = acct.Id + '-' + ttAcc.User__c;
                    acctTM.UserId = ttAcc.User__c;
                    acctTM.TeamMemberRole = ttAcc.Ruolo_Coverage_Team__c;
                    // if(roleMap.get(usrId).equals('SpecialRole')){
                    //     acctTM.TeamMemberRole = 'Sales Rep';
                    //     accountTeamList.add(acctTM);
                    // }
                    accountTeamList.add(acctTM);
                    System.debug('RC KEY: '+key);                  
                    System.debug('RC ttAcc.User__c: '+ttAcc.User__c); 
                    System.debug('RC acctTM.UserID: '+acctTM.UserId);  
                    System.debug('RC atmMap PREPUT: '+atmMap);  
                    atmMap.put(key,acctTM);
                    System.debug('RC atmMap PostPUT: '+atmMap);  
                }
            }
        }
        
        System.debug('SV ATM LIST: ' + accountTeamList);
        System.debug('SV ATM MAP: ' + atmMap);

        upsert atmMap.values();

        System.debug('SV accountTeamList: ' + accountTeamList);

        List<AccountShare> affectedAcctShare = [select Id, AccountId, UserOrGroupId, RowCause, AccountAccessLevel, ContactAccessLevel, OpportunityAccessLevel from AccountShare where AccountId in :affectedAccounts and UserOrGroupId in :assignedUserIdsList and RowCause='Team' ];

        System.debug('SV affectedAcctShare: ' + affectedAcctShare);

        for (AccountShare share : affectedAcctShare ) {

            // Give view access to opportunities and edit access to contacts
            share.AccountAccessLevel = 'Edit';
        }

        update affectedAcctShare;

        for(Coverage_Team_Member__c ttAcc : ttAcctList){
            System.debug('SV scc: ' + ttAcc.Account__c + '-' + ttAcc.User__c);
            ttAcc.Account_Team_Member_Id__c = atmMap.get(ttAcc.Account__c + '-' + ttAcc.User__c).Id;
        }

    System.debug('SV affectedAcctShare: ' + affectedAcctShare);
}

public static void updateAccountOwner(List <Coverage_Team_Member__c> ttAcctList) {
        
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.DuplicateRuleHeader.AllowSave = true; 

    Id utenzaAccountOwner = UtenzeDefault__c.getInstance().Id_Utente_AccountOwner__c;
    
    //User usr = [SELECT id FROM User WHERE Name = 'TEN'];
    System.debug('SV updateAccountOwner: ' + ttAcctList);

    List<String> accountList = new List<String>(); // accounts IDs affected by Top Account
    List<Account> updateAccounts = new List<Account>();

    for(Coverage_Team_Member__c ttAcc : ttAcctList){
        accountList.add(ttAcc.Account__c);
    }

    List<Account> affectedAccounts = [select Id, OwnerId, RecordType.Name from Account where Id in : accountList]; // list of all accounts affected by top account

    for(Account acct : affectedAccounts){
        if( acct.RecordType.Name == 'Tinexta'){
            acct.OwnerId = utenzaAccountOwner;
            updateAccounts.add(acct);
        }
    }
    if(updateAccounts.size()>0){
        Database.SaveResult[] sr = Database.update(updateAccounts, dml); 
        System.debug('SV SR: ' + sr);
    }
}


    public static void DeleteAccountTeamMember(List<Coverage_Team_Member__c> oldTeam){
        System.debug('DeleteAccountTeamMember: ' + oldTeam);

        if(disableDelete == false){
            Map <String,String> oldIdMap=new Map<String,String>();
            for(Coverage_Team_Member__c ctm : oldTeam){
                oldIdMap.put(ctm.Account__c,ctm.User__c);
            }
            System.debug('RC idMap: '+oldIdMap);
            
            //Recupera i vecchi AccountTeamMember associati per poi eliminarli
            List<AccountTeamMember> oldAccountTeam = new List<AccountTeamMember>([SELECT  Id, AccountId, UserId 
                                                     FROM AccountTeamMember 
                                                     WHERE AccountId IN: oldIdMap.keySet() 
                                                     AND UserId IN: oldIdMap.values()]);
            delete oldAccountTeam;

            //Recupera i vecchi AccountShare associati per poi eliminarli
            List<AccountShare> oldAssociatedShareList = new List<AccountShare>([SELECT AccountAccessLevel,OpportunityAccessLevel,AccountId,UserOrGroupId, RowCause
                                                                       FROM AccountShare
                                                                       WHERE AccountId IN :oldIdMap.keySet() 
                                                                       AND UserOrGroupId IN :oldIdMap.values() 
                                                                       AND RowCause = 'Team' ]);
            System.debug('RC associatedShareList: ' + oldAssociatedShareList); 
            delete oldAssociatedShareList;
        }
    }

    public static void UpdateAccountTeamMember(List<Coverage_Team_Member__c> oldTeam, List<Coverage_Team_Member__c> newTeam){
        System.debug('RC UpdateAccountTeamMember: '+ newTeam);
        System.debug('RC disableUpdate: '+ disableUpdate);

        if(disableUpdate == false){
            Map <String,String> oldIdMap=new Map<String,String>();
            Map <String,String> newIdMap=new Map<String,String>();
            Map <String,AccountTeamMember> newAtmMap = new Map<String,AccountTeamMember>();
            AccountTeamMember atm;
            Set<String> UniqueId = new Set<String>();
            List<Id> ctmIdList = new List<Id>();
            String key;

            //Salva Id dei vecchi Account e User associati ai Coverage Team Member in una mappa
            for(Coverage_Team_Member__c ctm : oldTeam){
                oldIdMap.put(ctm.Account__c,ctm.User__c);
            }

            //Salva Id dei nuovi Account e User associati ai Coverage Team Member in una mappa
            for(Coverage_Team_Member__c ctm : newTeam){
                newIdMap.put(ctm.Account__c,ctm.User__c);
            } 
            System.debug('RC idMap: '+oldIdMap);
            
            //Recupera i vecchi AccountTeamMember associati per poi eliminarli
            List<AccountTeamMember> oldAccountTeam = new List<AccountTeamMember>([SELECT  Id, AccountId, UserId 
                                                     FROM AccountTeamMember 
                                                     WHERE AccountId IN: oldIdMap.keySet() 
                                                     AND UserId IN: oldIdMap.values()]);

            OnAccountTeamMemberTriggerHandler.disableOnAccountTeamMemberTrigger = true;
            delete oldAccountTeam;

            //Recupera i vecchi AccountShare associati per poi eliminarli
            List<AccountShare> oldAssociatedShareList = new List<AccountShare>([SELECT AccountAccessLevel,OpportunityAccessLevel,AccountId,UserOrGroupId, RowCause
                                                                       FROM AccountShare
                                                                       WHERE AccountId IN :oldIdMap.keySet() 
                                                                       AND UserOrGroupId IN :oldIdMap.values() 
                                                                       AND RowCause = 'Team' ]);
            System.debug('RC associatedShareList: ' + oldAssociatedShareList); 
            delete oldAssociatedShareList;

            //Crea una mappa con chiave unica dove inserisco i nuovi AccountTeamMember per evitare doppioni 
            for (Coverage_Team_Member__c ctm : newTeam){
                key = String.valueOf(ctm.Account__c) + String.valueOf(ctm.User__c);
                if(!UniqueId.contains(key)){
                    atm = new AccountTeamMember(AccountId = ctm.Account__c,
                                                UserId = ctm.User__c);
                    newAtmMap.put(key,atm);
                    //se qui ci fosse una lista di tipo CTM non ci sarebbe bisogno della query updCtm
                    ctmIdList.add(ctm.Id);
                }
            }

            //Inserisce i nuovi AccountTeamMember      
            insert newAtmMap.values();

            //Riprende lista di Coverage team Member 
            List<Coverage_Team_Member__c> updCtm =new List<Coverage_Team_Member__c>([SELECT Id,Account__c,User__c,Account_Team_Member_Id__c
                                                                                    FROM Coverage_Team_Member__c
                                                                                    WHERE Id 
                                                                                    IN :ctmIdList]);
            //Cambia il campo Account_Team_Member_id
            for (Coverage_Team_Member__c ctm : updCtm){
                key = String.valueOf(ctm.Account__c) + String.valueOf(ctm.User__c);
                ctm.Account_Team_Member_Id__c = newAtmMap.get(key).Id;
        }

            //Riprende la lista di AccountShare creati automaticamente con l'inserimento dei nuovi AccountTeamMember
            List<AccountShare> newAssociatedShareList = new List<AccountShare>([SELECT AccountAccessLevel,AccountId,UserOrGroupId, RowCause
                                                         FROM AccountShare
                                                         WHERE AccountId IN : newIdMap.keySet() 
                                                         AND UserOrGroupId IN :newIdMap.values() 
                                                         AND RowCause = 'Team'  ]);
            //Per ogni record ottenuto imposta l'AccountAccess a 'Edit'
            for(AccountShare accSh : newAssociatedShareList){
                accSh.AccountAccessLevel = 'Edit';
            }
            upsert newAssociatedShareList;
            disableUpdate= true;
            upsert updCtm;
        } else {
        System.debug('UpdateAccountTeamMember: NON FACCIO NULLA');
        }       

    }
    
    public static void ControlloWarrantInsert (List<Coverage_Team_Member__c> newTeam){
        Set<Id> Team = new Set <Id>();
        system.debug('EU newteam' + newTeam);
        
        for(Coverage_Team_Member__c c:newTeam){
            Team.add(c.Account__c);
        }
        
        system.debug('EU Account' + Team);
        
        Map<Id,Coverage_Team_Member__c> MapCTM = new Map <Id, Coverage_Team_Member__c>([SELECT Id, User__c, Account__c, Ruolo_Coverage_Team__c FROM Coverage_Team_Member__c WHERE Account__c IN:Team AND Ruolo_Coverage_Team__c = 'Responsabile account' AND Societa__c = 'Warrant']);
        system.debug('EU MapCTM' + MapCTM.values());
        
        If(!MapCTM.values().isempty()){
            for(Coverage_Team_Member__c t:newTeam){
                for(Coverage_Team_Member__c m:MapCTM.values()){
                 If(t.Societa__c == 'Warrant' && t.Ruolo_Coverage_Team__c == 'Responsabile account' && t.User__c != m.User__c){
                     system.debug('EU Error');
                    t.addError('Non è possibile inserire più di un responsabile account');
    
                }

            }
            }
        }
        
        
    }
    public static void ControlloWarrantUpdate (Map<Id,Coverage_Team_Member__c> newTeam, Map<Id,Coverage_Team_Member__c> oldTeam){
        Set<Id> Team = new Set <Id>();
        system.debug('EU newteam' + newTeam);
        
        for(Id c:newTeam.keyset()){
            Team.add(newteam.get(c).Account__c);
        }
        
        system.debug('Eu Account' + Team);
        
        Map<Id,Coverage_Team_Member__c> MapCTM = new Map <Id, Coverage_Team_Member__c>([SELECT Id, User__c FROM Coverage_Team_Member__c WHERE Account__c IN:Team AND Ruolo_Coverage_Team__c = 'Responsabile account' AND Societa__c = 'Warrant']);
        
        
        If(!MapCTM.values().isempty()){
            for(Id t:newTeam.keyset()){
                Coverage_Team_Member__c old = oldTeam.get(t);
                 If(newTeam.get(t).Societa__c == 'Warrant' && newTeam.get(t).Ruolo_Coverage_Team__c == 'Responsabile account' && newTeam.get(t).Ruolo_Coverage_Team__c != old.Ruolo_Coverage_Team__c){
                    newTeam.get(t).addError('Non è possibile inserire più di un responsabile account');
    
                }

            }
        }
        
        
    }
    

}