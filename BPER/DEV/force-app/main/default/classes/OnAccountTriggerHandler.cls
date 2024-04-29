/**
* @description       : 
* @author            : ChangeMeIn@UserSettingsUnder.SFDoc
* @group             : 
* @last modified on  : 10-07-2020
* @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
* Modifications Log 
* Ver   Date         Author                               Modification
* 1.0   07-31-2020   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

/****
* Auhtor        :   Alessandro Lumaca
* Label         :   CR NEC #57552
* Modify Date   :   2022-12-05
* Modify        :   PORTAFOGLIO RESIDUALE - INTEGRAZIONE CR NEC 
*                         A seguito dell'integrazione di Batch_SvuotaResiduale
***/

public without sharing class OnAccountTriggerHandler {
    
    /*public static void emptyTW(List<Account> accs) {
        for (Account acc : accs) {
            if (acc.PTF_TechnicalWallet__c != null && acc.PTF_MicroWallet__c != null) {
                acc.PTF_TechnicalWallet__c = null;
            }
        }
    }*/

    public static void setPTF_Assente(List<Account> accs, Map<Id,Account> oldAccMap) {

                System.debug('SV setPTF_Assente: ' + accs);
                Id recTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'Assente');
                Id recTypeIdAccountGF = SV_Utilities.getRecordTypeByDeveloperName('Account', 'GruppoFinanziario');

                Set<Id> filiali = new Set<Id>();
                Map<String,Account> accMap= new Map<String,Account>();
                for (Account acc : accs) {
                    if(acc.recordTypeId != recTypeIdAccountGF){
                        if (String.isBlank(acc.PTF_Portafoglio__c) && String.isNotBlank(acc.PTF_Filiale__c)) {
                            filiali.add(acc.PTF_Filiale__c);
                            accMap.put(acc.Id,acc);
                        }
                        else if(String.isNotBlank(acc.PTF_Filiale__c) && oldAccMap.get(acc.Id).PTF_Filiale__c!=acc.PTF_Filiale__c && oldAccMap.get(acc.Id).PTF_Portafoglio__c==acc.PTF_Portafoglio__c){
                            filiali.add(acc.PTF_Filiale__c);
                            accMap.put(acc.Id,acc);
                        }
                        else if(acc.STG_X_Update_TS__c != null && acc.STG_X_Update_TS__c.date()==Date.today() && acc.ModelloDiServizio__c=='Residuale'){
                            filiali.add(acc.PTF_Filiale__c);
                            accMap.put(acc.Id,acc);
                        }
                    }
                    
                }

                if(filiali.size()>0){
                    Map<String, SObject> ptfMap = SV_Utilities.keyBy([
                            SELECT Id, PTF_Filiale__c
                            FROM Wallet__c
                            WHERE PTF_Filiale__c IN : filiali AND RecordTypeId =: recTypeId AND PTF_DeletionDate__c=null
                        ], 'PTF_Filiale__c', false);
                    
                    for(Account acc : accs) {
                            if(accMap.containsKey(acc.Id) && ptfMap.containsKey(acc.PTF_Filiale__c)){
                                acc.PTF_Portafoglio__c = (Id)ptfMap.get(acc.PTF_Filiale__c).get('Id');
                                acc.ModelloDiServizio__c='Assente';
                                if(oldAccMap.get(acc.Id).ModelloDiServizio__c=='Residuale' || String.isBlank(oldAccMap.get(acc.Id).PTF_Portafoglio__c)) acc.PTF_ActivationDate__c=Date.today();
                                acc.PTF_DeactivationDate__c=null;
                            }
                    }
                }
    }
    
    // MS 08-11-2023 - inizio
    @future
    public static void aggiornaPortafogliazione(List<Id> accIds, List<Id> oldAccIds)
    {
        List<Account> accs =
        [
            SELECT
            Id,
			FinServ__BankNumber__c,
			PTF_Filiale__r.PTF_IdCEDFiliale__c,
			CRM_NDG__c,
			Name,
			PTF_NaturaGiuridica__c,
			PTF_GruppoComportamentale__c,
			Modellodiservizio__c,
			PTF_Caponucleo__c,
			PTF_Portafoglio__r.Name,
			PTF_Portafoglio__r.CRM_MatricolaReferente__c,
			CRM_ReferenteNameFormula__c,
			PTF_IndiceGruco__c,
			CRM_ServiceModelCode__c,
			PTF_SegmentoComportamentale__c
            FROM
            Account
            WHERE
            Id IN :accIds
        ];

        List<Account> oldAccs =
        [
            SELECT
            Id,
            PTF_Portafoglio__c
            FROM Account
            WHERE
            Id IN :oldAccIds
        ];
        
        Map<Id, Account> oldAccMap = new Map<Id, Account>();
        for(Account acc : accs)
		{
			for(Account oldAcc : oldAccs)
			{
                if(acc.Id == oldAcc.Id)
                {
                    oldAccMap.put(acc.Id, oldAcc);
                    break;
                }
            }
		}
        
        set<Id> nucleiIds = new set<Id>();
		for(Account acc : accs)
		{
			nucleiIds.add(acc.PTF_Nucleo__c);
		}
        
		List<Account> capoNuclei = [SELECT Id, PTF_Nucleo__c FROM Account where PTF_Nucleo__c IN :nucleiIds AND PTF_Caponucleo__c = true];
		
		Map<Id, Account> capoNucleiMap = new Map<Id, Account>();
		for(Account acc :capoNuclei)
		{
			capoNucleiMap.put(acc.PTF_Nucleo__c, acc);
		}
        
        for (Account acc :accs)
        {
            if(acc.PTF_Portafoglio__c != oldAccMap.get(acc.Id).PTF_Portafoglio__c)
            {
				Http http = new Http();
				
				Map<String, Object> body = new map<string, object>();
				body.put('abi', acc.FinServ__BankNumber__c);
				body.put('filiale', acc.PTF_Filiale__r.PTF_IdCEDFiliale__c);
				body.put('ndg', acc.CRM_NDG__c);
				body.put('nominativo', acc.Name);
				body.put('tipoNdg', acc.PTF_NaturaGiuridica__c);
				body.put('gruco', acc.PTF_GruppoComportamentale__c);
				body.put('mds', acc.Modellodiservizio__c);
		
				String caponucleo = '';
				if (acc.PTF_Caponucleo__c == true)
				{
					caponucleo = acc.CRM_NDG__c;
				}
				else
				{
					caponucleo = capoNucleiMap.get(acc.PTF_Nucleo__c).CRM_NDG__c;
				}
		
				body.put('caponucleo', caponucleo);
				body.put('nomePrtf', acc.PTF_Portafoglio__r.Name);
				body.put('matricola', acc.PTF_Portafoglio__r.CRM_MatricolaReferente__c);
				body.put('nomeReferente', acc.CRM_ReferenteNameFormula__c);
				body.put('codGruco', acc.PTF_IndiceGruco__c);
				body.put('codMds', acc.CRM_ServiceModelCode__c);
				body.put('segmentoComportamentale', acc.PTF_SegmentoComportamentale__c);
				
				HttpRequest request = new HttpRequest();
				//request.setEndpoint(apiRequest.Endpoint__c);
				request.setMethod('PUT');
				//request.setHeader('Authorization', 'Basic ' + aut);
				request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
				request.setBody(JSON.serialize(body));
				
				HttpResponse response = http.send(request);
				System.debug('@@@@@AggiornaPortafogliazione '+response.getBody());
            }
    	}
    }
	// MS 08-11-2023 - fine

    public static void updateCampaignMember(Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        Set<String> accountIdSet = new Set<String>();
        for(String accountId : newMap.keySet()){
            if(newMap.get(accountId).PTF_Portafoglio__c != oldMap.get(accountId).PTF_Portafoglio__c){
                accountIdSet.add(accountId);
            }
        }
        // CR 57552 - inizio
        if(!accountIdSet.isEmpty() && !Test.isRunningTest()){
            System.enqueueJob(new UpdateCampaignMemberVisibilityQueue(newMap, oldMap, accountIdSet));
            /*Batch_UpdateCampaignMemberVisibility ucmv = new Batch_UpdateCampaignMemberVisibility(newMap, oldMap, accountIdSet);
            database.executeBatch(ucmv);*/
        }
        // CR 57552 - fine
    }
    
    public static void populateHierarchy(List<Account> accounts, Map<Id, Account> oldAccountMap) {
                
                Id recTypeIdAccountGF = SV_Utilities.getRecordTypeByDeveloperName('Account', 'GruppoFinanziario');
                Map<String,String> accToFiliale = new Map<String,String>();
                
                for(Account a: accounts){
                    // if(acc.recordTypeId != recTypeIdAccountGF){
                        if(String.isNotBlank(a.PTF_Filiale__c) && oldAccountMap.get(a.Id).PTF_Filiale__c!=a.PTF_Filiale__c){
                            accToFiliale.put(a.Id, a.PTF_Filiale__c);
                        }
                        /* VECCHIO
                        else if(String.isNotBlank(a.PTF_Filiale__c) && (String.isBlank(a.PTF_Capofila__c) || String.isBlank(a.PTF_Banca__c) || String.isBlank(a.PTF_DirezioneRegionale__c) || String.isBlank(a.PTF_Area__c))){
                            accToFiliale.put(a.Id, a.PTF_Filiale__c);
                        }  
                        */
                        // NUOVO
                        else if(String.isNotBlank(a.PTF_Filiale__c) && ((String.isBlank(a.PTF_Capofila__c) || !a.PTF_CongruenzaCapofila__c) || (String.isBlank(a.PTF_Banca__c) || !a.PTF_CongruenzaBanca__c) || (String.isBlank(a.PTF_DirezioneRegionale__c) || !a.PTF_CongruenzaDirezioneRegionale__c) || (String.isBlank(a.PTF_Area__c) || !a.PTF_CongruenzaArea__c))){
                            accToFiliale.put(a.Id, a.PTF_Filiale__c);
                        }
                    // }
                }
                    
                if(accToFiliale.keySet().size()>0){
                    Map<String,SObject> filialiMap= SV_Utilities.keyBy([SELECT Id, PTF_Capofila__c, PTF_Area__c, PTF_DirezioneRegionale__c, PTF_Banca__c  FROM Account WHERE Id IN:accToFiliale.values()], 'Id');
                    for(Account a: accounts){
                        if(accToFiliale.containsKey(a.Id)){
                            a.PTF_Capofila__c= !String.isBlank((String)filialiMap.get(a.PTF_Filiale__c).get('PTF_Capofila__c')) ? (String) filialiMap.get(a.PTF_Filiale__c).get('PTF_Capofila__c') : (String) filialiMap.get(a.PTF_Filiale__c).get('Id');
                            a.PTF_Area__c= (String) filialiMap.get(a.PTF_Filiale__c).get('PTF_Area__c');
                            a.PTF_DirezioneRegionale__c= (String) filialiMap.get(a.PTF_Filiale__c).get('PTF_DirezioneRegionale__c');
                            a.PTF_Banca__c= (String) filialiMap.get(a.PTF_Filiale__c).get('PTF_Banca__c');
                        }
                            
                    }
                }
            
    }
    
    public static void updatePTFOnWallet(Map<Id,Account> newAccountMap, Map<Id,Account> oldAccountMap) {

            System.debug('updatePTFOnWallet newAccountMap: ' + newAccountMap);
            System.debug('updatePTFOnWallet oldAccountMap: ' + oldAccountMap);            
            Id recTypeIdAccountGF = SV_Utilities.getRecordTypeByDeveloperName('Account', 'GruppoFinanziario');
            Set<Id> mwIds = new Set<Id>();

            for(String key : newAccountMap.keySet()){
                if((Id)newAccountMap.get(key).get('recordTypeId') != recTypeIdAccountGF){

                    if(newAccountMap.get(key).get('PTF_Portafoglio__c') != oldAccountMap.get(key).get('PTF_Portafoglio__c')){
                        if(String.isNotBlank((String)newAccountMap.get(key).get('PTF_Portafoglio__c'))){
                            mwIds.add((Id)newAccountMap.get(key).get('PTF_Portafoglio__c'));
                        }
                        if(String.isNotBlank((String)oldAccountMap.get(key).get('PTF_Portafoglio__c'))){
                            mwIds.add((Id)oldAccountMap.get(key).get('PTF_Portafoglio__c'));
                        }
                            
                    }
                    if( 
                        (newAccountMap.get(key).get('PTF_Accordato__c') != oldAccountMap.get(key).get('PTF_Accordato__c')
                        || newAccountMap.get(key).get('AnnualRevenue') != oldAccountMap.get(key).get('AnnualRevenue') 
                        || newAccountMap.get(key).get('PTF_Utilizzato__c') != oldAccountMap.get(key).get('PTF_Utilizzato__c') 
                        || newAccountMap.get(key).get('PTF_Patrimonio__c') != oldAccountMap.get(key).get('PTF_Patrimonio__c'))){
                            mwIds.add((Id)newAccountMap.get(key).get('PTF_Portafoglio__c'));
                    }
                }
            }
                    
            AggregateResult[] groupedResults =[SELECT PTF_Portafoglio__c, sum(PTF_Accordato__c) accordato, sum(PTF_Utilizzato__c) utilizzato, sum(PTF_Patrimonio__c) patrimonio, sum(AnnualRevenue) fatturato, Count(Id) numNDG FROM Account WHERE PTF_Portafoglio__c IN:mwIds group by PTF_Portafoglio__c];
                    
            Map<Id,AggregateResult> mGroup= new Map<Id,AggregateResult>();
            for(AggregateResult ar:groupedResults){
                mGroup.put((Id)ar.get('PTF_Portafoglio__c'),ar);
            }
                    
            Map<Id,Wallet__c> mwMap = new Map<Id,Wallet__c>();
            for(Id mwId : mwIds){
                if(mGroup.containsKey(mwId)){
                    Wallet__c x = new Wallet__c(
                        Id=mwId, 
                        PTF_Fatturato__c=(Double)mGroup.get(mwId).get('fatturato'),
                        PTF_Accordato__c=(Double)mGroup.get(mwId).get('accordato'),
                        PTF_Utilizzato__c=(Double)mGroup.get(mwId).get('utilizzato'),
                        PTF_Patrimonio__c=(Double)mGroup.get(mwId).get('patrimonio'),
                        CRM_numNDG__c=(Integer)mGroup.get(mwId).get('numNDG')
                    );
                    mwMap.put(x.Id,x);
                } else {
                    Wallet__c x = new Wallet__c(
                        Id=mwId, 
                        PTF_Fatturato__c=null,
                        PTF_Accordato__c=null,
                        PTF_Utilizzato__c=null,
                        PTF_Patrimonio__c=null,
                        CRM_numNDG__c=0
                    );
                    mwMap.put(x.Id,x);
                }
                    
            }

            if(mwMap.keySet().size() > 0){
                update mwMap.values();
            }
    }
    
    /**
* Name         :   createBookMember
* Create Date  :   2020-07-31
* Author       :   Ezio Dal Bo @TEN
* Input        :   newRecods (List<Account>)
* -------------
* Modify date   : 2020-09-23
* Author        : Ezio Dal Bo @TEN
* Modify        : added logic to populate PTF_WorkOrder__c
*/
    public static void createBookMember(List<Account> newRecords, Map<Id,Account> oldRecords) {
        
                List<BookMember__c> books = new List<BookMember__c>();
                // EDB 2020-09-23 - start
                Map<Id,WorkOrderLineItem> mAccWoli = new Map<Id,WorkOrderLineItem>();
                // DK START referenteDa
                Map<String, String> oldPTFRefMap = new Map<String, String>();
                // DK END referenteDa
                if (oldRecords!=null) {
                    
                    Set<Id> newPTF = new Set<Id>();
                    Set<Id> oldPTF = new Set<Id>();
                    for (Account acc : newRecords) {
                        
                        Account oldAcc = oldRecords.get(acc.Id);
                        if (acc.PTF_Portafoglio__c != oldAcc.PTF_Portafoglio__c &&
                            !String.isBlank(acc.PTF_Portafoglio__c) &&
                            !String.isBlank(oldAcc.PTF_Portafoglio__c)) {

                            newPTF.add(acc.PTF_Portafoglio__c);
                            oldPTF.add(oldAcc.PTF_Portafoglio__c);
                        }
                    }

                    System.debug('DK newPTF: ' + JSON.serialize(newPTF));
                    System.debug('DK oldPTF: ' + JSON.serialize(oldPTF));
                    if (!oldPTF.isEmpty()) {
                        
                        List<WorkOrderLineItem> wolis = [
                            SELECT  Id,
                                    AccountId__c,
                                    WorkOrderId, 
                                    WorkOrder.Status,
                                    WorkOrder.EndDate,
                                    WorkOrder.PTF_Origine__c,
                                    WorkOrder.PTF_Destinazione__c
                            FROM WorkOrderLineItem
                            WHERE AccountId__c IN: oldRecords.keySet()
                            AND WorkOrder.Status = 'Approvato'
                            AND WorkOrder.EndDate = TODAY
                            AND WorkOrder.PTF_Origine__c IN:oldPTF
                            AND WorkOrder.PTF_Destinazione__c IN:newPTF
                            ORDER BY EndDate DESC
                        ];
                        System.debug('DK wolis: ' + JSON.serialize(wolis));
                        if (!wolis.isEmpty()) {
                            
                            for (WorkOrderLineItem woli : wolis) {

                                if(!mAccWoli.containsKey(woli.AccountId__c)){

                                    mAccWoli.put(woli.AccountId__c,woli);
                                }
                            }
                        }

                        // DK START referenteDa
                        for(Wallet__c oldWallet : [SELECT Id, CRM_ReferentePortafoglio__c, CRM_ReferenteFormula__c, CRM_ReferentePortafoglio__r.Name FROM Wallet__c WHERE Id IN: oldPTF]){
                            if(oldWallet.CRM_ReferentePortafoglio__c != null) {
                                oldPTFRefMap.put(oldWallet.Id, oldWallet.CRM_ReferentePortafoglio__r.Name);
                            } else {
                                oldPTFRefMap.put(oldWallet.Id, oldWallet.CRM_ReferenteFormula__c);
                            }
                        }
                        // DK END referenteDa
                    }
                }

                System.debug('DK mAccWoli: ' + JSON.serialize(mAccWoli));
                // EDB 2020-09-23 - end
                for (Account acc : newRecords) {
                    Account oldAcc = oldRecords.get(acc.Id);
                    if (!String.isBlank(acc.PTF_Portafoglio__c)) {
                        
                        BookMember__c bm = new BookMember__c();
                        bm.PTF_StartDate__c = Date.today();
                        bm.PTF_NDG__c = acc.Id;
                        bm.PTF_MicroWallet__c = acc.PTF_Portafoglio__c;
                        bm.CRM_ReferentePortafoglio__c = acc.CRM_ReferenteIdFormula__c;
                        // DK START referenteDa
                        bm.CRM_ReferenteDa__c = oldPTFRefMap.containsKey(oldRecords.get(acc.Id).PTF_Portafoglio__c) ? oldPTFRefMap.get(oldRecords.get(acc.Id).PTF_Portafoglio__c) : null;
                        // DK END referenteDa
                        if(acc.SpostamentoUltimaRichiesta__c != null)
                            bm.SpostamentoUltimaRichiesta__c = acc.SpostamentoUltimaRichiesta__c;
                        bm.PTF_CodicePortafoglio__c = acc.PTF_MicroWallet_Name__c;
                        bm.PTF_NomeNDG__c = acc.Name;
                        // EDB 2020-09-23 - start
                        if (mAccWoli.containsKey(acc.Id)) {
                            
                            bm.PTF_WorkOrder__c = mAccWoli.get(acc.Id).WorkOrderId;
                        }
                        // EDB 2020-09-23 - end
                        // EDB 2020-10-07 - start
                        if (oldRecords!=null) {

                            bm.PTF_PreviousMicroWallet__c = oldRecords.get(acc.Id).PTF_Portafoglio__c;
                        }
                        // EDB 2020-10-07 - end
                        books.add(bm);
                    }
                }
                
                if (!books.isEmpty()) {
                    
                    insert books;
                }
    }
    
    /**
* Name         :   updateBookAndManagementMember
* Create Date  :   2020-09-18
* Author       :   Ezio Dal Bo @TEN
* Input        :   newRecods (List<Account>), oldRecords (Map<Id,Account>)
*/
    public static void updateBookAndManagementMember(List<Account> newRecords,Map<Id,Account> oldRecords) {

                Id recTypeIdAccountGF = SV_Utilities.getRecordTypeByDeveloperName('Account', 'GruppoFinanziario');

                List<Account> movedAccounts = new List<Account>();
                List<Id> movedAccountsId = new List<Id>();
                List<BookMember__c> bookMemberToUpdate = new List<BookMember__c>();
                // EDB 2020-09-23 - start
                Map<Id,Account> oldAccount = new Map<Id,Account>();
                // EDB 2020-09-23 - end
                

                for (Account acc : newRecords) {
                    if(acc.recordTypeId != recTypeIdAccountGF){

                        Account oldAcc = oldRecords.get(acc.Id);
                        if (acc.PTF_Portafoglio__c!=oldAcc.PTF_Portafoglio__c) {
                            movedAccounts.add(acc);
                            movedAccountsId.add(acc.Id);
                            oldAccount.put(acc.Id,oldAcc);
                                
                        }
                    }
                }
                Map<String,SObject> bookMembers = SV_Utilities.keyBy([ 
                    SELECT  Id,
                    PTF_EndDate__c,
                    PTF_NDG__c,
                    PTF_MicroWallet__c
                    FROM BookMember__c
                    WHERE PTF_EndDate__c=NULL AND PTF_NDG__c IN:movedAccountsId],
                                                                    '{PTF_NDG__c}_{PTF_MicroWallet__c}',true);
                if (movedAccounts.size()>0) {
                    createBookMember(movedAccounts,oldAccount);
                    updateManagementMembers(movedAccounts, oldAccount);
                }

                for(Id accId:oldAccount.keySet()){
                    Account oldAcc=oldAccount.get(accId);
                    String oldKey = oldAcc.Id+'_'+oldAcc.PTF_Portafoglio__c;
                        if (bookMembers.containsKey(oldKey)) {
                            BookMember__c bm = (BookMember__c)bookMembers.get(oldKey);
                            bm.PTF_EndDate__c = Date.today();
                            bookMemberToUpdate.add(bm);
                        }
                }
                
                if (bookMemberToUpdate.size()>0) {
                    update bookMemberToUpdate;
                }
    }

    public static void updateManagementMembers(List<Account> accountList, Map<id, Account> oldAccountMap){
                System.debug('RC accountList: '+accountList);
                System.debug('RC oldAccountMap: '+oldAccountMap);

                Id recTypeId = SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'Standard');
                List<NDGManagementMember__c> oldManagementMemberList = [SELECT id, PTF_EndDate__c, PTF_EndDate_DT__c, PTF_Gestore__c, PTF_NDG__c, RecordTypeId FROM NDGManagementMember__c WHERE PTF_NDG__c IN: oldAccountMap.keySet() AND PTF_EndDate__c = null AND RecordTypeId =: recTypeId];
                System.debug('RC oldManagementMemberList: '+oldManagementMemberList);
                for(NDGManagementMember__c managementMember : oldManagementMemberList){

                    managementMember.PTF_EndDate__c = Date.Today();
                    managementMember.PTF_EndDate_DT__c = Datetime.now();
                }

                if(!oldManagementMemberList.isEmpty()){

                    update oldManagementMemberList;
                }
                List<Account> accList = new List<Account>();

                for(Account acc: accountList){
                    accList.add(acc);
                }
                Map<String, Object> accountPTFMap = SV_Utilities.keyBy(accList, 'PTF_Portafoglio__c');
                System.debug('RC accountPTFMap: '+accountPTFMap);
                Map<String, List<Assignment__c>> assignmentMap = new Map<String, List<Assignment__c>>();
                for(Assignment__c assignment: [SELECT Id, PTF_Gestore__c, PTF_MicroWallet__c, RecordTypeId ,RecordType.DeveloperName FROM Assignment__c WHERE PTF_MicroWallet__c IN: accountPTFMap.keySet() AND PTF_EndDate__c = null]){
                    System.debug('RC assignment: '+assignment);

                    if(!assignmentMap.containsKey(assignment.PTF_MicroWallet__c)){

                        assignmentMap.put(assignment.PTF_MicroWallet__c, new List<Assignment__c>());
                    }
                    assignmentMap.get(assignment.PTF_MicroWallet__c).add(assignment);
                }
                System.debug('RC assignmentMap: '+assignmentMap);

                List<NDGManagementMember__c> managementMembersToInsert = new List<NDGManagementMember__c>();
                for(Account account : accountList){

                    if(assignmentMap.containsKey(account.PTF_Portafoglio__c)){
                        
                        for(Assignment__c assignment : assignmentMap.get(account.PTF_Portafoglio__c)){
                            System.debug('RC assignment 2: '+assignment);

                            NDGManagementMember__c managementMember = new NDGManagementMember__c();
                            /*02-09-2021 fix GB START */
                            managementMember.Id_oggetto_sorgente__c = assignment.Id;
                            /*02-09-2021 fix GB END */
                            managementMember.PTF_Gestore__c = assignment.PTF_Gestore__c;
                            managementMember.PTF_NDG__c = account.Id;
                            managementMember.RecordTypeId = recTypeId;
                            managementMember.RecTypeId__c = assignment.RecordTypeId;
                            managementMember.RecTypeDevName__c = assignment.RecordType.DeveloperName;
                            managementMembersToInsert.add(managementMember);
                        }
                    }
                }
                System.debug('RC managementMembersToInsert: '+managementMembersToInsert);

                if(!managementMembersToInsert.isEmpty()){

                    insert managementMembersToInsert;
                }
    }
    
    
    
    public static void createNucleo(List<Account> newAccount) {

                Id recTypeIdAccountGF = SV_Utilities.getRecordTypeByDeveloperName('Account', 'GruppoFinanziario');
                Id recordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                List<Integer> accountToUpdate = new List<Integer>();
                List<Nucleo__c> nuclei = new List<Nucleo__c>();
                for (Integer i= 0; i<newAccount.size(); i++) {
                    
                        Account acc = newAccount.get(i);
                        if(acc.recordTypeId != recTypeIdAccountGF){
                        if (!String.isBlank(acc.PTF_Portafoglio__c) && acc.RecordTypeId==recordTypeId && String.isBlank(acc.PTF_Nucleo__c)) {
                            
                            Nucleo__c nucleo = new Nucleo__c();
                            nuclei.add(nucleo);
                            accountToUpdate.add(i);
                        }
                    }
                }
                if (nuclei.size()>0) {
                    insert nuclei;
                    for (Integer i=0; i<nuclei.size(); i++) {
                        Integer pos = accountToUpdate.get(i);
                        newAccount[pos].PTF_Nucleo__c = nuclei.get(i).Id;
                        newAccount[pos].PTF_Caponucleo__c = true;
                    }
                }
    }
    public static void deleteDoppioPresidio(List<Account> newAccount, Map<Id,Account> oldAccount){
                
                Id recTypeIdAccountGF = SV_Utilities.getRecordTypeByDeveloperName('Account', 'GruppoFinanziario');

                List<Id> ndgsToDeletePresidio= new List<Id>();
                for(Account acc: newAccount){
                    if(acc.recordTypeId != recTypeIdAccountGF){
                        Account oldAcc= oldAccount.get(acc.Id);
                        //se la filiale cambia devo cancellare il doppio presidio
                        if(acc.PTF_Filiale__c!=null && acc.PTF_Filiale__c!=oldAcc.PTF_Filiale__c){
                            ndgsToDeletePresidio.add(acc.Id);
                        }
                        //se la filiale non cambia e il modello di servizio passa a non private devo ancellare il doppio presidio
                        if(acc.PTF_Filiale__c!=null && acc.PTF_Filiale__c==oldAcc.PTF_Filiale__c && acc.ModelloDiServizio__c!='Private' && oldAcc.ModelloDiServizio__c=='Private' ){
                            ndgsToDeletePresidio.add(acc.Id);
                        }
                    }
                }
                if(ndgsToDeletePresidio.size()>0){
                    List<NDGManagementMember__c> oldDoppiPresidi = [
                    SELECT  Id,
                    PTF_Gestore__c,
                    PTF_NDG__c,
                    PTF_EndDate__c,
                    PTF_EndDate_DT__c,
                    RecordType.DeveloperName
                    FROM NDGManagementMember__c
                    WHERE PTF_NDG__c IN: ndgsToDeletePresidio
                    AND PTF_EndDate__c = NULL
                    AND RecordType.DeveloperName = 'DoppioPresidio'
                    AND PTF_AutoDP__c=true
                    ];
                    for(NDGManagementMember__c dp:oldDoppiPresidi){
                        dp.PTF_EndDate__c=Date.today();
                        dp.PTF_EndDate_DT__c = Datetime.now();
                    }
                    if(oldDoppiPresidi.size()>0){
                        update oldDoppiPresidi;
                    }
                }
    }
    public static void createDoppioPresidio(List<Account> newAccount, Map<Id,Account> oldAccount,String action) {

                Map<Id,List<Account>> mFilialeNdg = new Map<Id,List<Account>>();
                Id recTypeId = SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'DoppioPresidio');
                Id recTypeIdAccountGF = SV_Utilities.getRecordTypeByDeveloperName('Account', 'GruppoFinanziario');

                if ('OnAfterUpdate'.equals(action)) {
                    
                    for (Account acc : newAccount) {
                        if(acc.recordTypeId != recTypeIdAccountGF){

                            Account oldAcc= oldAccount.get(acc.Id);                   
                            //se la filiale cambia e il modello di servizio è private devo creare un nuovo doppio presidio
                            if(acc.PTF_Filiale__c!=null && acc.PTF_Filiale__c!=oldAcc.PTF_Filiale__c && acc.ModelloDiServizio__c=='Private'){
                                if(!mFilialeNdg.containsKey(acc.PTF_Filiale__c)){
                                    mFilialeNdg.put(acc.PTF_Filiale__c,new List<Account>());
                                }
                                mFilialeNdg.get(acc.PTF_Filiale__c).add(acc);
                            }
                            //se la filiale resta la stessa e il modello di servizio diventa private devo creare un doppio presidio
                            if(acc.PTF_Filiale__c!=null && acc.PTF_Filiale__c==oldAcc.PTF_Filiale__c && acc.ModelloDiServizio__c=='Private' && oldAcc.ModelloDiServizio__c!='Private'){
                                if(!mFilialeNdg.containsKey(acc.PTF_Filiale__c)){
                                    mFilialeNdg.put(acc.PTF_Filiale__c,new List<Account>());
                                }
                                mFilialeNdg.get(acc.PTF_Filiale__c).add(acc);
                            }
                        }
                        
                    }
                    
                    if (!mFilialeNdg.isEmpty()) {
                        List<Account> filiali = [
                            SELECT  Id, PTF_BranchTypeDesc__c,
                            OwnerId,
                            Owner.FirstName,
                            Owner.LastName,
                            (SELECT Id FROM Contacts WHERE PTF_Ruolo__c='100' and PTF_Closed_Date_Referente__c =NULL)
                            FROM Account
                            WHERE Id IN:mFilialeNdg.keySet()
                        ];
                        List<NDGManagementMember__c> newPresidi = new List<NDGManagementMember__c>();
                        if (filiali!=null && filiali.size()>0) {
                            for (Account fil : filiali) {
                                if(fil.Contacts.size()>0){
                                    if (mFilialeNdg.containsKey(fil.Id)) {
                                        List<Account> accs = mFilialeNdg.get(fil.Id);
                                        for (Account acc : accs) {
                                            NDGManagementMember__c doppioPresidio = new NDGManagementMember__c();
                                            doppioPresidio.PTF_Gestore__c = fil.Contacts[0].Id;
                                            doppioPresidio.PTF_NDG__c = acc.Id;
                                            doppioPresidio.RecordTypeId = recTypeId;
                                            doppioPresidio.PTF_StartDate__c = Date.today();
                                            doppioPresidio.PTF_StartDate_DT__c = Datetime.now();
                                            newPresidi.add(doppioPresidio);
                                        }
                                    }
                                }
                                
                            }
                        }
                        if (newPresidi.size()>0) {
                            insert newPresidi;
                        }
                    }
                
                    
                }
        
    }
    

    public static void setTechnicalWallet(List<Account> newRecords){
                Id recTypeIdAccountGF = SV_Utilities.getRecordTypeByDeveloperName('Account', 'GruppoFinanziario');
                Set<Id> filialiId = new Set<Id>();
                Map<String,Set<String>> filialeModello = new Map<String,Set<String>>();
                List<Account> accList = new List<Account>();
                Id recordTypeId= Schema.SObjectType.Wallet__c.getRecordTypeInfosByDeveloperName().get('TechnicalWallet').getRecordTypeId();
                for(Account a:newRecords){
                    if(a.recordTypeId != recTypeIdAccountGF){
                        if(String.isNotBlank(a.ModelloDiServizioCaricamento__c) && String.isNotBlank(a.PTF_Filiale__c)){
                            filialiId.add(a.PTF_Filiale__c);
                            if(!filialeModello.containsKey(a.PTF_Filiale__c)){
                                filialeModello.put(a.PTF_Filiale__c,new Set<String>());
                            }
                            filialeModello.get(a.PTF_Filiale__c).add(a.PTF_Filiale__c+'_'+a.ModelloDiServizioCaricamento__c);
                            a.ModelloDiServizioCaricamento__c = '';

                            accList.add(a);
                        }
                    }
                        
                }
                Map<String, SObject> ptfMap = SV_Utilities.keyBy([
                                                SELECT Id, PTF_Filiale__c, PTF_ModelloDiServizio__c
                                                FROM Wallet__c
                                                WHERE PTF_Filiale__c IN : filialiId AND RecordTypeId =: recordTypeId AND PTF_DeletionDate__c=null
                                            ], '{PTF_Filiale__c}_{PTF_ModelloDiServizio__c}', true);
                List<Wallet__c> portToCreate= new List<Wallet__c>();
                system.debug('@@@@@ sonoqui:'+JSON.serialize(filialeModello));
                system.debug('@@@@@ filialiId:'+JSON.serialize(filialiId));
                List<Account> filiali= [SELECT Id, PTF_BranchTypology__c, Name, PTF_Capofila__c, PTF_Area__c, PTF_DirezioneRegionale__c, PTF_Banca__c  FROM Account WHERE Id IN:filialiId];
                system.debug('@@@@@ sonoqui:'+JSON.serialize(filiali));
                /*List<User> unassignedGestoreIdList = [SELECT Id FROM User WHERE Profile.Name = 'TechnicalProfilePortafogliazione' LIMIT 1];
                String unassignedGestoreId;
                if(unassignedGestoreIdList.size()>0){
                    unassignedGestoreId=unassignedGestoreIdList[0].Id;
                }*/
                for(Account filiale:filiali){
                    for(String key : filialeModello.get(filiale.id)){
                        if(!ptfMap.containsKey(key)){
                            system.debug('@@@@@ sonoqui:'+JSON.serialize(filialeModello));
                            Wallet__c wal= new Wallet__c();
                            wal.Name= 'Portafoglio Tecnico - '+filiale.Name+' - '+key.split('_')[1];
                            wal.RecordTypeId=recordTypeId;
                            //wal.OwnerId=unassignedGestoreId;
                            wal.PTF_ModelloDiServizio__c=key.split('_')[1];
                            wal.PTF_Filiale__c=filiale.Id;
                            if(String.isNotBlank(filiale.PTF_Capofila__c)){
                                wal.PTF_Capofila__c=filiale.PTF_Capofila__c;
                            }
                            else{
                                wal.PTF_Capofila__c=filiale.Id;
                            }
                            wal.PTF_Area__c=filiale.PTF_Area__c;
                            wal.PTF_DirezioneRegionale__c=filiale.PTF_DirezioneRegionale__c;
                            wal.PTF_Banca__c=filiale.PTF_Banca__c;
                            /*
                            if(filiale.PTF_BranchTypology__c=='A' || filiale.PTF_BranchTypology__c=='F'){
                                system.debug('@@@@ A o F ' +JSON.serialize(filiale) );
                                wal.PTF_Capofila__c=filiale.Id;
                                wal.PTF_Area__c=filiale.ParentId;
                                wal.PTF_DirezioneRegionale__c=filiale.Parent.ParentId;
                                wal.PTF_Banca__c=filiale.Parent.Parent.ParentId;
                            }
                            else{
                                system.debug('@@@@ else capofila' +JSON.serialize(filiale.ParentId) );
                                system.debug('@@@@ else area' +JSON.serialize(filiale.Parent.ParentId) );
                                system.debug('@@@@ else direzione' +JSON.serialize(filiale.Parent.Parent.ParentId) );
                                system.debug('@@@@ else banca' +JSON.serialize(filiale.Parent.Parent.Parent.ParentId) );
                                wal.PTF_Capofila__c=filiale.ParentId;
                                wal.PTF_Area__c=filiale.Parent.ParentId;
                                wal.PTF_DirezioneRegionale__c=filiale.Parent.Parent.ParentId;
                                wal.PTF_Banca__c=filiale.Parent.Parent.Parent.ParentId;
                            }
                            */
                            system.debug('@@@@  capofila' +JSON.serialize(wal.PTF_Capofila__c) );
                            system.debug('@@@@  area' +JSON.serialize(wal.PTF_Area__c) );
                            system.debug('@@@@  direzione' +JSON.serialize(wal.PTF_DirezioneRegionale__c) );
                            system.debug('@@@@  banca' +JSON.serialize(wal.PTF_Banca__c) );
                            portToCreate.add(wal);
                        }
                    }
                    
                }
                insert portToCreate;

                
                system.debug('@@@@@ sonoqui:'+JSON.serialize(portToCreate));
                Map<String, SObject> newPtfMap = SV_Utilities.keyBy([
                                                SELECT Id, PTF_Filiale__c, PTF_ModelloDiServizio__c
                                                FROM Wallet__c
                                                WHERE PTF_Filiale__c IN : filialiId AND RecordTypeId =: recordTypeId AND PTF_DeletionDate__c=null
                                            ], '{PTF_Filiale__c}_{PTF_ModelloDiServizio__c}', true);
                system.debug('@@@@@ sonoqui:'+JSON.serialize(newPtfMap));                           
                for(Account a:accList){
                    String key= a.PTF_Filiale__c+'_'+a.ModelloDiServizioCaricamento__c;
                    a.PTF_Portafoglio__c= newPtfMap.get(key).Id;
                    a.ModelloDiServizio__c=a.ModelloDiServizioCaricamento__c;
                    a.ModelloDiServizioCaricamento__c=null;
                }
    }
    public static void setModelloDiServizio(List<Account> newRecords, Map<Id,Account> oldMap, Boolean isUpdate){
        
                        Id recTypeIdAccountGF = SV_Utilities.getRecordTypeByDeveloperName('Account', 'GruppoFinanziario');

                    Map<Id,String> accToPort= new Map<Id,String>();
                    Set<Id> portIdSet= new Set<Id>();
                    for(Account acc:newRecords){
                        if(acc.recordTypeId != recTypeIdAccountGF){

                            if( acc.PTF_Portafoglio__c!=oldMap.get(acc.Id).PTF_Portafoglio__c){
                                if(String.isNotBlank(acc.PTF_Portafoglio__c)){
                                    accToPort.put(acc.Id,(String)acc.PTF_Portafoglio__c);
                                    portIdSet.add(acc.PTF_Portafoglio__c);
                                }
                                else{
                                    acc.ModelloDiServizio__c='Non Portafogliati';
                                }
                            }    
                        }            
                    }
                    Map<String, SObject> newPtfMap = SV_Utilities.keyBy([
                                                SELECT Id, PTF_Filiale__c, PTF_ModelloDiServizio__c
                                                FROM Wallet__c
                                                WHERE Id IN:portIdSet
                                            ], 'Id', false);
                    for(Account acc:newRecords) {

                        if(accToPort.containsKey(acc.Id)){
                            acc.ModelloDiServizio__c=(String)newPtfMap.get(accToPort.get(acc.Id)).get('PTF_ModelloDiServizio__c');
                        }            
                    } 
        
    }

    public static void UpdateBranch(List<Account> newRecords,Map<Id,Account> oldRecords) {
                Id recTypeIdAccountGF = SV_Utilities.getRecordTypeByDeveloperName('Account', 'GruppoFinanziario');

                List<Account> updatedAccountList = new List<Account>();
                for(Account account : newRecords){
                    if(account.recordTypeId != recTypeIdAccountGF){

                        if(String.isNotBlank(account.PTF_Portafoglio__c) && account.PTF_Filiale__c != oldRecords.get(account.Id).PTF_Filiale__c &&
                            !String.IsBlank(account.PTF_Filiale__c)){

                            updatedAccountList.add(account);
                        }
                    }
                }

                if(!updatedAccountList.isEmpty()){

                    sendRequest(JSON.serialize(updatedAccountList));
                }
    }

    @future(callout=true)
    public static void sendRequest(String updatedAccountListJSON){

        Map<String, Map<String, Object>> fieldsMap = new Map<String, Map<String, Object>>();
        Map<String, Map<String, String>> conditionMap = new Map<String, Map<String, String>>();
        List<Account> updatedAccountList = (List<Account>)JSON.deserialize(updatedAccountListJSON, List<Account>.class);
        StaticResource staticResource = [select id,body from StaticResource Where Name = 'jsonWrapper'];
        String jsonWrapper = staticResource.body.toString();
        Map<String,Object> parsedJsonWrapper = (Map<String,Object>)JSON.deserializeUntyped(jsonWrapper);
        Map<String,Object> parsedJsonElement = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonWrapper.get('aggiornaFilialeDiRelazione')));
        Map<String, Object> parsedJsonElementFields = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('fields')));
        for(String fieldName : parsedJsonElementFields.keySet()){

            fieldsMap.put(fieldName, (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementFields.get(fieldName))));
        }
        
        if(parsedJsonElement.containsKey('conditionList')){
            
            Map<String, Object> parsedJsonElementCondiions = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElement.get('conditionList')));
            for(String conditionName : parsedJsonElementCondiions.keySet()){
    
                conditionMap.put(conditionName, (Map<String, String>)JSON.deserializeUntyped(JSON.serialize(parsedJsonElementCondiions.get(conditionName))));
            }
        }


        List<SV_FailedRequest__c> requestsToInsert = new List<SV_FailedRequest__c>();
        for(Account account : updatedAccountList){
            
            Map<String, Object> response = (Map<String, Object>)JSON.deserializeUntyped(MakeRequestController.makeRequest('aggiornaFilialeDiRelazione', account.id, fieldsMap, conditionMap, 'salesforceprodclient2024', '', false));
            System.debug('DK response: ' + response);
            if((String)response.get('statusCode') != '204'){

                requestsToInsert.add( new SV_FailedRequest__c(RequestName__c = 'aggiornaFilialeDiRelazione',
                                    RecordId__c = account.id,
                                    FieldsMap__c = JSON.serialize(fieldsMap),
                                    CertificationName__c = 'salesforceprodclient2024'));
            }
        }
        if(!requestsToInsert.isEmpty()){

            insert requestsToInsert;
        }
    }
    public static void setPortafoglioAssegnato(List<Account> newRecords, Map<Id,Account> oldMap, Boolean isUpdate){

        
                for(Account a:newRecords){
                    if(String.isNotBlank(a.PTF_Portafoglio__c)){
                        a.PTF_PortafoglioAssegnato__c=true;
                    }
                    if(String.isNotBlank(a.PTF_Portafoglio__c) && String.isNotBlank(oldMap.get(a.Id).PTF_Portafoglio__c) && oldMap.get(a.Id).PTF_Portafoglio__c!=a.PTF_Portafoglio__c){
                        a.PTF_OldPortafoglioId__c=oldMap.get(a.Id).PTF_Portafoglio__c;
                    }
                    if(String.isBlank(a.PTF_Portafoglio__c)){
                        a.PTF_PortafoglioAssegnato__c=false;
                    }

                }
    }

    public static void setResiduale(List<Account> newRecords, Map<Id,Account> oldMap){

                Id recordTypeId= Schema.SObjectType.Wallet__c.getRecordTypeInfosByDeveloperName().get('Residuale').getRecordTypeId();
                Map<String,String> idToFiliale= new Map<String,String>();
                for(Account acc:newRecords){
                    //if((acc.PTF_StatoSofferenza__c ==true || acc.FinServ__Status__c=='Estinto') && acc.ModelloDiServizio__c!='Residuale' && String.isNotBlank(acc.PTF_Filiale__c)){
                    if(acc.PTF_StatoSofferenza__c ==true && acc.ModelloDiServizio__c!='Residuale' && String.isNotBlank(acc.PTF_Filiale__c)){
                            idToFiliale.put(acc.Id, acc.PTF_Filiale__c);
                    }
                }
                if(idToFiliale.keySet().size()>0){
                    Map<String, SObject> ptfMap = SV_Utilities.keyBy([
                                                SELECT Id, PTF_Filiale__c, PTF_ModelloDiServizio__c
                                                FROM Wallet__c
                                                WHERE PTF_Filiale__c IN : idToFiliale.values() AND RecordTypeId =: recordTypeId AND PTF_DeletionDate__c=null
                                            ], '{PTF_Filiale__c}', true);
                    for(Account acc:newRecords){
                        if(idToFiliale.containsKey(acc.Id)){
                            if(ptfMap.containsKey(idToFiliale.get(acc.Id)) ){
                                acc.PTF_Portafoglio__c=(Id) ptfMap.get(idToFiliale.get(acc.Id)).get('Id');
                                acc.ModelloDiServizio__c='Residuale';
                                acc.PTF_ActivationDate__c=null;
                                acc.PTF_DeactivationDate__c=Date.today();
                            }
                        }
                    }
                }

    }

    public static void changeStruttura(List<Account> newRecords, Map<Id,Account> oldMap){
        Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('FilialeDiRelazione').getRecordTypeId();
        Map<String,Account> filialiMap= new Map<String,Account>();
        for(Account acc: newRecords){
            if(acc.RecordTypeId==recordTypeId){
                if(acc.PTF_Capofila__c!=oldMap.get(acc.Id).PTF_Capofila__c || acc.PTF_Area__c!=oldMap.get(acc.Id).PTF_Area__c || acc.PTF_DirezioneRegionale__c!=oldMap.get(acc.Id).PTF_DirezioneRegionale__c || acc.PTF_Banca__c!=oldMap.get(acc.Id).PTF_Banca__c){
                    filialiMap.put(acc.Id,acc);
                }
            }
        }
        List<Wallet__c> walToUpdate=[SELECT Id, PTF_Filiale__c, PTF_Capofila__c, PTF_Area__c , PTF_DirezioneRegionale__c, PTF_Banca__c FROM Wallet__c WHERE PTF_Filiale__c IN:filialiMap.keySet()];
        
        
        for(Wallet__c wallet:walToUpdate){
            if(String.isNotBlank( filialiMap.get(wallet.PTF_Filiale__c).PTF_Capofila__c)){
                wallet.PTF_Capofila__c=filialiMap.get(wallet.PTF_Filiale__c).PTF_Capofila__c;
            }
            else{
                wallet.PTF_Capofila__c=wallet.PTF_Filiale__c;
            }
            wallet.PTF_Area__c = filialiMap.get(wallet.PTF_Filiale__c).PTF_Area__c;
            wallet.PTF_DirezioneRegionale__c = filialiMap.get(wallet.PTF_Filiale__c).PTF_DirezioneRegionale__c;
            wallet.PTF_Banca__c = filialiMap.get(wallet.PTF_Filiale__c).PTF_Banca__c;
        }
        if(walToUpdate.size()>0){
            update walToUpdate;
            System.enqueueJob(new AlignNdgHierarchyQueue(SV_Utilities.keyBy(walToUpdate, 'Id').keySet()));
        }
        
    } 

    //GPF S:43039 - Sportelli Leggeri
    
    public static void resetMiniWalletLookup(List<Account> newRecords, Map<Id,Account> oldRecords){
        if (Trigger.isBefore && Trigger.isUpdate) {
            for(Account a:newRecords){
                if(a.PTF_Portafoglio__c != oldRecords.get(a.Id).PTF_Portafoglio__c){
                     a.PTF_MiniPortafoglio__c = null;
                }
           }
        }
    }
    //GPF E:43039 - Sportelli Leggeri

    
}