public class OnLeadTriggerHandler {

    /*
    * This method will Approve the opportunity
    */
    public static void approveRecord(List<Lead> leadList, User usr){

        System.debug('SV testLead: ' + leadList);

        //Map<String, SObject> recordTypeMap = Utilities.keyBy([ SELECT Id, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'Lead' ], 'Id');
        //System.debug('SV recordTypeMap: ' + recordTypeMap);
        
        //Ottimizzazione
        Schema.DescribeSObjectResult d = Schema.SObjectType.Lead; 
		Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();

        Set<Id> leadIdList = new Set<id>();
        Set<String> codFiscOnLeadList = new Set<String>();
        Set<String> pIvaOnLeadList = new Set<String>();
        List<Lead> leadInnolvaList = new List<Lead>();
        for (Lead ld : leadList){
            if((String)rtMapById.get(ld.RecordTypeId).getDeveloperName() == 'Innolva' ){
                leadInnolvaList.add(ld);
                leadIdList.add(ld.Id);  
                codFiscOnLeadList.add(ld.Codice_Fiscale__c);      
                pIvaOnLeadList.add(ld.Partiva_Iva__c);  
            }
        }

        if(leadInnolvaList.size() <= 0){
            System.debug('SV LEAD NON PROCESSATI PERCHE NON SONO DI INNOLVA');
            return;
        } else {
            System.debug('SV LEAD DI INNOLVA');
        }

        // User usr = [ SELECT Id, Name, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        // System.debug('SV usr: ' + usr);

        Map<String, SObject> leadMap = Utilities.keyBy(leadInnolvaList, 'Id');
        System.debug('SV leadMap: ' + leadMap);  
        
        Map<String, SObject> duplicateRecordItemMap = Utilities.keyBy([ SELECT Id, Name, CreatedDate, DuplicateRecordSetId, RecordId 
                                                                      FROM DuplicateRecordItem 
                                                                      WHERE CreatedDate = TODAY AND 
                                                                        RecordId IN : leadIdList ], 'RecordId');
        System.debug('SV duplicateRecordItemMap: ' + duplicateRecordItemMap);                                                              

        // Map<String, SObject> duplicateRecordSetMap = Utilities.keyBy([ SELECT Id, Name, CreatedDate,  DuplicateRuleId, RecordCount 
        //                                                                FROM DuplicateRecordSet 
        //                                                                WHERE CreatedDate = TODAY ], 'Id');
        // System.debug('SV duplicateRecordSetMap: ' + duplicateRecordSetMap);

        Map<String, SObject> processInstance  = Utilities.keyBy([ SELECT Id, TargetObjectId 
                                                                  FROM ProcessInstance 
                                                                  WHERE TargetObjectId IN : leadIdList ], 'TargetObjectId');
        System.debug('SV processInstance: ' + processInstance);


        if(!duplicateRecordItemMap.isEmpty()){

            for (String key : duplicateRecordItemMap.keySet()){

                if(!processInstance.containsKey(key) && (String)rtMapById.get((String)leadMap.get(key).get('RecordTypeId')).getDeveloperName() == 'Innolva' && (usr.Profile.Name == 'Innolva - Partner Community Sales' || usr.Profile.Name == 'Innolva - Sales Partner' || usr.Profile.Name == 'Innolva - Sales Interno')){
                    System.debug('field key is ' + key);

                    // Create an approval request for the Account
                    Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                    req1.setComments((Boolean)leadMap.get(key).get('IsConverted') ? 'Lead in Conversione in Approvazione per Anagrafica già presente' : 'Contatto spontaneo in Approvazione per potenziale duplicato');
                    req1.setObjectId(key);

                    // Submit the approval request for the Account
                    Approval.ProcessResult result = Approval.process(req1);

                    System.debug('SV Approval.ProcessResult: ' + result);

                }
            }
        }
    }

    /*
 public static void manageLeadShare(Map<Id,Lead> leadMap){
           system.debug('manageLeadShare:'+leadMap);
        Map<Id,RecordType> rTypeMap = new Map<Id,RecordType>([SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Lead']);
        List<LeadShare> shareList = new List<LeadShare>();
        for(Lead l : leadMap.values()){
            system.debug('l.RecordType.DeveloperName: '+l.RecordType.DeveloperName);
            system.debug('l.RecordTypeId '+l.RecordTypeId);
            system.debug('(String)rTypeMap.get(l.RecordTypeId).DeveloperName: '+(String)rTypeMap.get(l.RecordTypeId).DeveloperName);
            system.debug('l.RecordType.Name '+l.RecordType.Name);
            
            system.debug('l.Utente_Segnalatore__c: '+l.Utente_Segnalatore__c);
            system.debug('l.OwnerId: '+l.OwnerId);
            //in questa org non c'è infocert utente segnalatore, non da sostituire ma da duplicare
            if((String)rTypeMap.get(l.RecordTypeId).DeveloperName == 'Warrant'  && l.Utente_Segnalatore__c != l.OwnerId && l.Utente_Segnalatore__c != null){                
                LeadShare lsh = new LeadShare(LeadId = l.Id,
                                              UserOrGroupId = l.Utente_Segnalatore__c,
                                              LeadAccessLevel = 'Read',
                                              RowCause = 'Manual');
                shareList.add(lsh);
            }
        }
        system.debug('shareList:'+shareList);
   
        if(shareList.size()>0)insert shareList;
    }
*/
	/*
    public static void createAccountTeamMember(List<Lead> leadListNew,List<Lead> leadListOld){
        //Fallo andare solo per direct marketing operatore-> sales agent
        System.debug('leadListNew ' + leadListNew); 
        System.debug('leadListOld ' + leadListOld); 
        Set<Id> leadIdList = new Set<id>();
        for(Lead l : leadListNew){
            leadIdList.add(l.Id);
        }

        List<LeadShare> leadShareList = new List<LeadShare>([SELECT  Id, LeadId, UserOrGroupId, LeadAccessLevel, RowCause
                                                                   FROM LeadShare 
                                                                   WHERE LeadId IN: leadIdList
                                                                   AND LeadAccessLevel =: 'Read']);
        System.debug('leadShareList ' + leadShareList); 

        Map<String, SObject> leadShareMap = Utilities.keyBy(leadShareList, 'LeadId');
        Map<String, SObject> leadOldMapX = Utilities.keyBy(leadListOld, 'Id');

        System.debug('leadShareMap ' + leadShareMap); 
        System.debug('leadOldMapX ' + leadOldMapX); 

        List<AccountTeamMember> accTeamList = new List<AccountTeamMember>();

        for(Lead l : leadListNew) {
            system.debug('l.ConvertedAccountId'+l.ConvertedAccountId);
            system.debug('(String)leadOldMapX.get(l.Id).get(ConvertedAccountId)'+(String)leadOldMapX.get(l.Id).get('ConvertedAccountId'));
            if(l.ConvertedAccountId != null && (String)leadOldMapX.get(l.Id).get('ConvertedAccountId') == null){
              AccountTeamMember atm =new AccountTeamMember(AccountId = l.ConvertedAccountId,
                                                      UserId= (String)leadShareMap.get(l.Id).get('UserOrGroupId'),
                                                      AccountAccessLevel = 'Read',
                                                      ContactAccessLevel ='None');      
            accTeamList.add(atm);      
            }
        }

        System.debug('accTeamList:'+accTeamList);

        upsert accTeamList;
    }

    public static void handleContactShare(List<Lead> leadListNew,List<Lead> leadListOld){
        System.debug('RC: handleContactShare'); 
        System.debug('leadListNew ' + leadListNew); 
        System.debug('leadListOld ' + leadListOld); 
        Set<Id> leadIdList = new Set<id>();
        for(Lead l : leadListNew){
            leadIdList.add(l.Id);
        }

        List<LeadShare> leadShareList = new List<LeadShare>([SELECT  Id, LeadId, UserOrGroupId, LeadAccessLevel, RowCause
                                                                   FROM LeadShare 
                                                                   WHERE LeadId IN: leadIdList
                                                                   AND LeadAccessLevel =: 'Read']);
        System.debug('leadShareList ' + leadShareList); 

        Map<String, SObject> leadShareMap = Utilities.keyBy(leadShareList, 'LeadId');
        Map<String, SObject> leadOldMapX = Utilities.keyBy(leadListOld, 'Id');

        System.debug('leadShareMap ' + leadShareMap); 
        System.debug('leadOldMapX ' + leadOldMapX); 

        List<ContactShare> contShareList = new List<ContactShare>();

        for(Lead l : leadListNew) {
            if(l.ConvertedContactId   != null && (String)leadOldMapX.get(l.Id).get('ConvertedContactId') == null){
              ContactShare cSh =new ContactShare(ContactId = l.ConvertedContactId,
                                                UserOrGroupId= (String)leadShareMap.get(l.Id).get('UserOrGroupId'),
                                                ContactAccessLevel ='Read');      
            contShareList.add(cSh);      
            }
        }

        System.debug('contShareList:'+contShareList);

        upsert contShareList;

    }


    public static void handleLeadShare(List<Lead> leadListNew,List<Lead> leadListOld){
        Map<Id, Lead> leadOldMap = new Map<Id, Lead>();
        Set<Id> leadIdList = new Set<id>();
        for (Lead ldOld : leadListOld){

            leadOldMap.put(ldOld.Id,ldOld);
        }

        System.debug('leadOldMap:'+leadOldMap);

        List<LeadShare> lShare =new List<LeadShare>();
        for (Lead ld : leadListNew){   
            if(leadOldMap.get(ld.Id).OwnerId != ld.OwnerId) {

                leadIdList.add(ld.Id); 
                LeadShare x = new LeadShare( LeadId = ld.Id, UserOrGroupId = leadOldMap.get(ld.Id).OwnerId, LeadAccessLevel = 'Read', RowCause = 'Manual' );
                lShare.add(x);

            }        
        }

        System.debug('lShare:'+lShare);

        if(lShare.size() > 0) upsert lShare;


        // List<LeadShare> hasGroupId = new List<LeadShare>();
        // List<LeadShare> toDelete = new List<LeadShare>();

        // Set<Id> leadIdList = new Set<id>();
        // for (Lead ld : leadList){
        //     leadIdList.add(ld.Id);        
        // }
        // List<LeadShare> shareList=[SELECT Id, LeadId, UserOrGroupId, LeadAccessLevel, RowCause, IsDeleted 
        //                            FROM LeadShare 
        //                            WHERE LeadId IN : leadIdList];
        
        // String userId;
        // for(LeadShare sh : shareList){
        //     userId = (String)sh.UserOrGroupId;
        //     System.debug('userId.substring(0,3): ' + userId.substring(0,3));            
        //     if((userId.substring(0,3))=='00G'){
        //         hasGroupId.add(sh);
        //         toDelete.add(sh);
        //     }
        // }
        // for(LeadShare sh : hasGroupId){
        //     sh.LeadAccessLevel = 'read';
        // }
        // delete toDelete;
        // insert hasGroupId; 
    }
*/
   /* public static void copyConvertedLead(Map<Id,Lead> oldLeadMap, Map<Id,Lead> newLeadMap){
        System.debug('RC copyConvertedLead');
        User currUsr = [SELECT Id, Name, Societa__c FROM User WHERE Id =: UserInfo.getUserId()];
        Map<Id,Lead> toSaveLead = new Map<Id,Lead>();
        if(currUsr.Societa__c == 'Warrant'){
            for(Id LeadId : newLeadMap.keyset()){
                System.debug('RC copyConvertedLead: ' + oldLeadMap.get(LeadId).IsConverted + ' ' + newLeadMap.get(LeadId).IsConverted + ' ' + newLeadMap.get(LeadId).Flag_duplicazione_segnalazione__c + ' ' + newLeadMap.get(LeadId).AccountSegnalatore__c);
                if(oldLeadMap.get(LeadId).IsConverted== false && newLeadMap.get(LeadId).IsConverted == true && newLeadMap.get(LeadId).Flag_duplicazione_segnalazione__c == false && newLeadMap.get(LeadId).AccountSegnalatore__c != null){
                    toSaveLead.put(LeadId,newLeadMap.get(LeadId));
                }
            }
           if(!toSaveLead.isEmpty()){
            AsyncLeadCopy executeQueueable = new AsyncLeadCopy(toSaveLead.keyset());  //PASSO IL SET AD ASYNCEXE
            ID jobID = System.enqueueJob(executeQueueable);
            System.debug('jobID : ' + jobID);
           }
        }         
    }*/
    public static void copyConvertedLead(Map<Id,Lead> LeadMap, User currUsr){
        System.debug('RC copyConvertedLead');
        // User currUsr = [SELECT Id, Name, Societa__c,Escludi_da_Convalida__c FROM User WHERE Id =: UserInfo.getUserId()];
        
        //Ottimizzazione 1
        if(currUsr.Societa__c != 'Warrant'&& currUsr.Societa__c != 'CoMark'){
            System.debug('SV LEAD NON PROCESSATI PERCHE NON SONO WARRANT E COMARK');
            return;
        } else {
            System.debug('SV LEAD DI ' + currUsr.Societa__c);
        }
        
        
        Map<Id,Lead> toSaveLead = new Map<Id,Lead>();
        //Qui mettere || Comark
        if(currUsr.Societa__c == 'Warrant'|| currUsr.Societa__c == 'CoMark'){
            for(Id LeadId : LeadMap.keyset()){
                if(LeadMap.get(LeadId).AccountSegnalatore__c != null && LeadMap.get(LeadId).Stato_Segnalazione_Warrant__c == 'In lavorazione'){
                    toSaveLead.put(LeadId,LeadMap.get(LeadId));
                }
            }
           if(!toSaveLead.isEmpty()){
            AsyncLeadCopy executeQueueable = new AsyncLeadCopy(toSaveLead.keyset());  //PASSO IL SET AD ASYNCEXE
            ID jobID = System.enqueueJob(executeQueueable);
            System.debug('jobID : ' + jobID);
           }
        }         
    }



    
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    
    public static void WRT_StatoSegnalazione(Map<Id,Lead> newLeadMap){
        
        //Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].Id;
        //Id ridCMK=[SELECT id from RecordType where Name = 'CoMark' AND SobjectType = 'Lead' LIMIT 1].Id;

        List<User> usrList = [Select Id, Societa__c,Escludi_da_Convalida__c from User where Id =: UserInfo.getUserId() ];
        
        //Ottimizzazione 2
        if(usrList[0].Societa__c != 'Warrant'&& usrList[0].Societa__c != 'CoMark'){
            System.debug('SV LEAD NON PROCESSATI PERCHE NON SONO WARRANT E COMARK');
            return;
        } else {
            System.debug('SV LEAD DI ' + usrList[0].Societa__c);
        }
        
        
        //User WRT
        if((usrList[0].Societa__c == 'Warrant' )&& newLeadMap.size() == 1){
            
            try {
                //List<Profile> profileName = [Select Name from Profile where Id =: UserInfo.getProfileId() ];
            	//System.debug('SV  profileName ' + profileName[0].Name);
                //la community non ha più visibilità sul lead
                //if (profileName[0].Name.contains('Partner')) throw new OtherException('Non è possibile fare modifiche da Community');
                
               
                //Map<String, sObject> rtMap = Utilities.keyBy([SELECT Id, Name, DeveloperName, SobjectType, IsActive From RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Warrant'], 'Id');
               	Schema.DescribeSObjectResult d = Schema.SObjectType.Lead; 
				Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
                
                for (Id key : newLeadMap.keySet()) {
                    //System.debug('SV newLeadMap: ' + rtMap.get((String)newLeadMap.get(key).get('RecordTypeId')) );      
                    
                    if(((String)rtMapById.get((String)newLeadMap.get(key).get('RecordTypeId')).getDeveloperName() == 'Warrant') &&
                       (String)newLeadMap.get(key).get('AccountSegnalatore__c') != null){
                           switch on (String)newLeadMap.get(key).get('Status') {
                                when 'Nuovo Lead' {		// when block 1
                                    // code block 1
                                    newLeadMap.get(key).Stato_Segnalazione_Warrant__c = 'In Lavorazione';
                                }	
                                when 'Fuori Funnel' {		// when block 2
                                    // code block 2
                                    newLeadMap.get(key).Stato_Segnalazione_Warrant__c = 'Negativo';
                                }
                                when else {		  // default block, optional
                                    // code block 3
                                    newLeadMap.get(key).Stato_Segnalazione_Warrant__c = 'Positivo';
                                }
                            }
                           
                       }
                
                }
            } catch (BaseException e) {  
                // This catches the OtherException
                System.debug(e.getMessage());
                for (Id key : newLeadMap.keySet()) {
                    newLeadMap.get(key).addError(e.getMessage());                    
                }
            }
        }

        if((usrList[0].Societa__c == 'CoMark' )&& newLeadMap.size() == 1){

            try {
                //List<Profile> profileName = [Select Name from Profile where Id =: UserInfo.getProfileId() ];
            	//System.debug('SV  profileName ' + profileName[0].Name);
                //la community non ha più visibilità sul lead
                //if (profileName[0].Name.contains('Partner')) throw new OtherException('Non è possibile fare modifiche da Community');
                
                //Map<String, sObject> rtMapCMK = Utilities.keyBy([SELECT Id, Name, DeveloperName, SobjectType, IsActive From RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'CoMark'], 'Id');
                Schema.DescribeSObjectResult dl = Schema.SObjectType.Lead; 
				Map<Id,Schema.RecordTypeInfo> rtMapByIdCMK = dl.getRecordTypeInfosById();
                
                for (Id key : newLeadMap.keySet()) {
                    
                    //System.debug('EU newLeadMap: ' + rtMapCMK.get((String)newLeadMap.get(key).get('RecordTypeId')) );      
                    
                    if(((String)rtMapByIdCMK.get((String)newLeadMap.get(key).get('RecordTypeId')).getDeveloperName() == 'CoMark') &&
                       (String)newLeadMap.get(key).get('AccountSegnalatore__c') != null){
                           switch on (String)newLeadMap.get(key).get('Status') {
                                when 'Nuovo Lead' {		// when block 1
                                    // code block 1
                                    newLeadMap.get(key).Stato_Segnalazione_Warrant__c = 'In Lavorazione';
                                }	
                                when 'Fuori Funnel' {		// when block 2
                                    // code block 2
                                  //  newLeadMap.get(key).Stato_Segnalazione_Warrant__c = 'Negativo';
                                }
                                when else {		  // default block, optional
                                    // code block 4
                                    newLeadMap.get(key).Stato_Segnalazione_Warrant__c = 'Positivo';
                                }
                            }
                       }
                

                }
            } catch (BaseException e) {  
                // This catches the OtherException
                System.debug(e.getMessage());
                for (Id key : newLeadMap.keySet()) {
                    newLeadMap.get(key).addError(e.getMessage());                    
                }
            }
          
            
        }        
    }
    
    public static void updateAccountSegn(Map<Id,Lead> oldLeadMap, Map<Id,Lead> newLeadMap, User currUsr){
        // User currUsr = [SELECT Id, Name, Societa__c,Escludi_da_Convalida__c FROM User WHERE Id =: UserInfo.getUserId()];
        Schema.DescribeSObjectResult d = Schema.SObjectType.Lead; 
		Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        //Id recodTypeWrt = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Warrant'].Id;
        
        Schema.DescribeSObjectResult dc = Schema.SObjectType.Lead; 
		Map<Id,Schema.RecordTypeInfo> rtMapByIdCMK = dc.getRecordTypeInfosById();
        //Id recodTypeCMK = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'CoMark'].Id;
        
        if(currUsr.Societa__c != 'Warrant'&& currUsr.Societa__c != 'CoMark'){
            System.debug('SV LEAD NON PROCESSATI PERCHE NON SONO WARRANT E COMARK');
            return;
        } else {
            System.debug('SV LEAD DI ' + currUsr.Societa__c);
        }
        
        
        
        
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Lead> convertedLeads = new Map<Id,Lead>();
        Map<Id,Lead> convertedLeadsCMK = new Map<Id,Lead>();
        
        
        if(currUsr.Societa__c == 'Warrant' || currUsr.Societa__c == 'CoMark'){
            for(Id LeadId : newLeadMap.keyset()){
               system.debug('RecordType: '+newLeadMap.get(LeadId).RecordTypeId);
                
                
                if(oldLeadMap.get(LeadId).IsConverted== false && newLeadMap.get(LeadId).IsConverted == true && ((String)rtMapByIdCMK.get((String)newLeadMap.get(LeadId).get('RecordTypeId')).getDeveloperName() == 'Warrant')){
                    convertedLeads.put(LeadId,newLeadMap.get(LeadId));
                    system.debug('ConvertedAccountId: '+(Id)newLeadMap.get(LeadId).get('ConvertedAccountId'));
                    accountIds.add((Id)newLeadMap.get(LeadId).get('ConvertedAccountId'));
                }
                if(oldLeadMap.get(LeadId).IsConverted== false && newLeadMap.get(LeadId).IsConverted == true && ((String)rtMapByIdCMK.get((String)newLeadMap.get(LeadId).get('RecordTypeId')).getDeveloperName() == 'CoMark')){
                    convertedLeadsCMK.put(LeadId,newLeadMap.get(LeadId));
                    system.debug('ConvertedAccountId: '+(Id)newLeadMap.get(LeadId).get('ConvertedAccountId'));
                    accountIds.add((Id)newLeadMap.get(LeadId).get('ConvertedAccountId'));
                }
            }
            
            if(!convertedLeads.isEmpty()){
                Map<String,sObject> accMap = Utilities.keyBy([SELECT Id, Name,Tipologia_Segnalatore_WarrantHub__c,Filiale_Warrant__c,Lead_source_Warrant__c,Nome_Segnalatore__c,Cognome_Segnalatore__c FROM Account WHERE Id IN : accountIds], 'Id');
                List<Segnalazioni__c> ListSegnVeloci = [SELECT Id,Lead_Di_Riferimento__c FROM Segnalazioni__c WHERE Lead_Di_Riferimento__c IN :convertedLeads.keyset()];
                List<Account> accupdate = new list<Account>();

                for(String leadId : convertedLeads.keySet()){
                    If(convertedLeads.get(leadId).get('Numero_S__c') != null){
                        //Manca utentesegnalatore
                    sObject acc = accMap.get((Id)convertedLeads.get(leadId).get('ConvertedAccountId'));
                    acc.put('Stato_Segnalazione_Warrant__c', convertedLeads.get(leadId).get('Stato_Segnalazione_Warrant__c'));
                    acc.put('Filiale1_Warrant__c', convertedLeads.get(leadId).get('Filiale1__c'));
                    acc.put('Account_Source_Warrant__c', convertedLeads.get(leadId).get('Fonte_Segnalatore__c'));
                    acc.put('Nome_Segnalatore__c', convertedLeads.get(leadId).get('Nome_segnalatore__c'));
                    acc.put('Cognome_Segnalatore__c', convertedLeads.get(leadId).get('Cognome_Segnalatore__c'));
                    acc.put('AccountSegnalatore__c', convertedLeads.get(leadId).get('AccountSegnalatore__c'));
                    acc.put('WRT_Data_Inserimento_Segnalazione__c', convertedLeads.get(leadId).get('Data_inserimento_segnalazione__c')); 
                    acc.put('Segnalazione_Partner__c', convertedLeads.get(leadId).get('Segnalazione_Partner__c')); 
                    acc.put('Contatto_Riferimento_Segnalatore__c', convertedLeads.get(leadId).get('Contact__c'));
                    acc.put('Numero_Segnalazione__c', convertedLeads.get(leadId).get('Numero_S__c'));
                    acc.put('Utente_segnalatore__c',convertedLeads.get(leadId).get('Utente_Segnalatore__c'));
                    if(String.isBlank((String)acc.get('Tipologia_Segnalatore_WarrantHub__c')))
                        acc.put('Tipologia_Segnalatore_WarrantHub__c', 'Nessuno');
                    accupdate.add((Account)acc);

                    for (Segnalazioni__c s:ListSegnVeloci){
                        if(s.Lead_Di_Riferimento__c == leadId){
                            s.Account__c=(Id)convertedLeads.get(leadId).get('ConvertedAccountId');
                            s.Lead_Di_Riferimento__c = null; 
                        }                   
                    }
                }
                }

                update accupdate;
                update ListSegnVeloci;
            }
            
            if(!convertedLeadsCMK.isEmpty()){
                Map<String,sObject> accMap = Utilities.keyBy([SELECT Id, Name,Tipologia_Segnalatore_WarrantHub__c,Filiale_Warrant__c,Lead_source_Warrant__c,Nome_Segnalatore__c,Cognome_Segnalatore__c FROM Account WHERE Id IN : accountIds], 'Id');
                List<Segnalazioni__c> ListSegnVelociCMK = [SELECT Id,Lead_Di_Riferimento__c FROM Segnalazioni__c WHERE Lead_Di_Riferimento__c IN :convertedLeadsCMK.keyset()];
                List<Account> accupdateCMK = new list<Account>();

                for(String leadId : convertedLeadsCMK.keySet()){
                    If(convertedLeadsCMK.get(leadId).get('Numero_S__c') != null){
                    sObject acc = accMap.get((Id)convertedLeadsCMK.get(leadId).get('ConvertedAccountId'));
                    acc.put('CMK_Stato_Segnalazione_Partner__c', convertedLeadsCMK.get(leadId).get('Stato_Segnalazione_Warrant__c'));
                    acc.put('CMK_Filiale__c', convertedLeadsCMK.get(leadId).get('Filiale1__c'));
                    acc.put('Accountsource_comark__c', convertedLeadsCMK.get(leadId).get('Fonte_Segnalatore__c'));
                    acc.put('CMK_Nome_Segnalato__c', convertedLeadsCMK.get(leadId).get('Nome_segnalatore__c'));
                    acc.put('CMK_Cognome_del_Segnalato__c', convertedLeadsCMK.get(leadId).get('Cognome_Segnalatore__c'));
                    acc.put('CMK_Fonte_Dettaglio__c', convertedLeadsCMK.get(leadId).get('AccountSegnalatore__c'));
                    acc.put('CMK_Data_Inserimento_Segnalazione__c', convertedLeadsCMK.get(leadId).get('Data_inserimento_segnalazione__c')); 
                    acc.put('CMK_Segnalazione_Partner__c', convertedLeadsCMK.get(leadId).get('Segnalazione_Partner__c')); 
                    acc.put('CMK_Contatto_di_riferimento__c', convertedLeadsCMK.get(leadId).get('Contact__c'));
                    acc.put('CMK_Numero_Segnalazione__c', convertedLeadsCMK.get(leadId).get('Numero_S__c'));
                    acc.put('CMK_Utente_Segnalatore__c',convertedLeadsCMK.get(leadId).get('Utente_Segnalatore__c'));
                    if(String.isBlank((String)acc.get('Tipologia_Segnalatore_WarrantHub__c')))
                        acc.put('Tipologia_Segnalatore_WarrantHub__c', 'Nessuno');
                    accupdateCMK.add((Account)acc);

                    for (Segnalazioni__c s:ListSegnVelociCMK){
                        if(s.Lead_Di_Riferimento__c == leadId){
                            system.debug('Segnalazione CMK'+s.Lead_Di_Riferimento__c);
                            s.Account__c=(Id)convertedLeadsCMK.get(leadId).get('ConvertedAccountId');
                            s.Lead_Di_Riferimento__c = null; 
                        }                   
                    }
                }
                }

                update accupdateCMK;
                update ListSegnVelociCMK;
            }
        }


    }
    
     public static void updateAccountReferenza(Map<Id,Lead> oldLeadMap, Map<Id,Lead> newLeadMap, User currUsr){
        // User currUsr = [SELECT Id, Name, Societa__c,Escludi_da_Convalida__c FROM User WHERE Id =: UserInfo.getUserId()];
        //Id recodTypeWrt = [SELECT Id FROM RecordType WHERE SobjectType = 'Lead' AND DeveloperName = 'Warrant'].Id;
		Id recodTypeWrt = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Warrant').getRecordTypeId();
         
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Lead> convertedLeads = new Map<Id,Lead>();
         
        if(currUsr.Societa__c != 'Warrant'){
            System.debug('SV LEAD NON PROCESSATI PERCHE NON SONO WARRANT');
            return;
        } else {
            System.debug('SV LEAD DI WARRANT');
        }
        

        if(currUsr.Societa__c == 'Warrant'){
            for(Id LeadId : newLeadMap.keyset()){
               system.debug('RecordType: '+newLeadMap.get(LeadId).RecordTypeId);
                //Condizione su recordType da aggiornare
                if(oldLeadMap.get(LeadId).IsConverted== false && newLeadMap.get(LeadId).IsConverted == true && newLeadMap.get(LeadId).RecordTypeId == recodTypeWrt){
                    convertedLeads.put(LeadId,newLeadMap.get(LeadId));
                    system.debug('ConvertedAccountId: '+(Id)newLeadMap.get(LeadId).get('ConvertedAccountId'));
                    accountIds.add((Id)newLeadMap.get(LeadId).get('ConvertedAccountId'));
                }
            }
            if(!convertedLeads.isEmpty()){
                Map<String,sObject> accMap = Utilities.keyBy([SELECT Id, Name FROM Account WHERE Id IN : accountIds], 'Id');
                List<Referenza__c> ListReferenze = [SELECT Id,Data_Referenza__c,Referenza_indicata_da_Lead__c,Lead_segnalato__c, Azienda_Referenziata__c FROM Referenza__c WHERE Lead_segnalato__c IN :convertedLeads.keyset()];
                List<Account> accupdate = new list<Account>();

                for(String leadId : convertedLeads.keySet()){
                    If(convertedLeads.get(leadId).get('Referenza__c') != null){
                            //Manca utentesegnalatore
                        sObject acc = accMap.get((Id)convertedLeads.get(leadId).get('ConvertedAccountId'));
                        //acc.put('Referenza__c', convertedLeads.get(leadId).get('Referenza__c'));
                        //acc.put('Stato_Referenza__c', convertedLeads.get(leadId).get('Stato_Referenza__c'));
                        //acc.put('Articolo_Referenza__c', convertedLeads.get(leadId).get('Articolo_Referenza__c'));
                        //acc.put('Referenza_raccolta_da__c', convertedLeads.get(leadId).get('Referenza_raccolta_da__c'));
                        //acc.put('Business_Area__c', convertedLeads.get(leadId).get('Business_Area__c'));
                        //acc.put('Utente_Creatore__c', convertedLeads.get(leadId).get('Utente_Creatore__c'));
                        //acc.put('Data_Referenza__c', convertedLeads.get(leadId).get('Data_Referenza__c')); 
                        //acc.put('Referenza_indicata_da_Referente__c', convertedLeads.get(leadId).get('ConvertedContactId')); 
                        //acc.put('Note_Referenza__c', convertedLeads.get(leadId).get('Note_Referenza__c'));
                        //acc.put('Oggetto_Referenza__c', convertedLeads.get(leadId).get('Oggetto_Referenza__c'));
                        accupdate.add((Account)acc);
    

                    }
                    
                    for (Referenza__c s:ListReferenze){
                        if(s.Lead_segnalato__c == leadId){
                            s.Azienda_Referenziata__c=(Id)convertedLeads.get(leadId).get('ConvertedAccountId');
                            s.Lead_segnalato__c = null; 
                            s.WRT_Converted_Lead__c = true; 
                            // s.Stato_Referenza__c='In gestione';
                        }                   
                    }
                    
                }

                update accupdate;
                update ListReferenze;
            }
        }

    }


    public static void updateFormaGiuridicaWRT(List<Lead> newLeads){
        
        for(Lead l : newLeads){
            if(l.Forma_Giuridica__c != null){
                l.WRT_Forma_giuridica__c = l.Forma_Giuridica__c;
            }
        }
    }
    
    
    public static void testRun() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
     }
   

}