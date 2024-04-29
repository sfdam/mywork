global class Batch_OnAssignmentTriggerHandler implements Database.Batchable<sObject>,Database.stateful {
    global String eventType = null;
    global Set<Id> idMicroWalletOver1K = new Set<Id>();
    global Set<Id> idAssignment = new Set<Id>();
    global Map<Id,List<Assignment__c>> mPTFAssignment = new Map<Id,List<Assignment__c>>();
    global List<List<sObject>> ndgManagementMembers = new List<List<sObject>>();
    global List<List<sObject>> wallets = new List<List<sObject>>();
    /***
     * Batch
     ***/
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Database.QueryLocator locator;
        if ('onAfterInsert'.equals(eventType)) {
        	locator = Database.getQueryLocator([SELECT Id,Name,PTF_Portafoglio__c,CRM_NDG__c FROM Account WHERE PTF_Portafoglio__c!=null AND PTF_Portafoglio__c IN:idMicroWalletOver1K]);
        }
        if ('onAfterUpdate'.equals(eventType)) {
        	locator = Database.getQueryLocator([SELECT	Id,PTF_EndDate__c,PTF_EndDate_DT__c FROM NDGManagementMember__c WHERE Id_oggetto_sorgente__c!=null AND Id_oggetto_sorgente__c IN:idAssignment and PTF_EndDate__c=null]);
        }
        return locator; 
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<NDGManagementMember__c> storicoReferenti = new List<NDGManagementMember__c>();
        Id rectypeId= SV_Utilities.getRecordTypeByDeveloperName('NDGManagementMember__c', 'Standard');
        Id idRecTypePrimario = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Primario');
        Id idRecTypeBackup = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', 'Backup');
        List<Wallet__c> walletToUpdate = new List<Wallet__c>();
        Set<Id> idMicroWallet = new Set<Id>();
        if ('onAfterUpdate'.equals(eventType)) {
            onAssignmentTriggerHandler.updateStoricoNDGReferenti(scope);
            update scope;
        }
        if ('onAfterInsert'.equals(eventType)) {
        	for (sObject r : scope) { 
                Account acc = (Account)r;
                idMicroWallet.add(acc.PTF_Portafoglio__c);
            	List<Assignment__c> lAss = mPTFAssignment.get(acc.PTF_Portafoglio__c);
            	if (lAss!=null) {
                	storicoReferenti.addAll(OnAssignmentTriggerHandler.creaStoricoNDGReferenti(acc,lAss,rectypeId,idRecTypePrimario,idRecTypeBackup));
            	}
        	}
            //insert storico records
            if (!storicoReferenti.isEmpty()) {
                if (storicoReferenti.size()>10000) {
                    ndgManagementMembers.add(storicoReferenti);
                }
                else {
                    insert storicoReferenti;
                }
            }
            /* walletToUpdate.addAll(OnAssignmentTriggerHandler.impostaStatoWallet(idMicroWallet));
            if (!walletToUpdate.isEmpty()) {
                if (walletToUpdate.size()>10000) {
                    wallets.add(walletToUpdate);
                }
                else {
                    update walletToUpdate;
                }
            } */
        }
    }
    global void finish(Database.BatchableContext BC) {
        
        if ('onAfterInsert'.equals(eventType)) {
            if (ndgManagementMembers.size()>0) {
                for (List<sObject> o : ndgManagementMembers) {
                    invokeBatch(o,'insert','NDGManagementMember__c');
                }
            }
            
            if (wallets.size()>0) {
                for (List<sObject> o : wallets) {
                    invokeBatch(o,'update','Wallet__c');
                }
            }
        }
    }
    
    global static void invokeBatch(List<sObject> o, String operationType, String sObjectType) {
        Batch_TriggerOperation bto = new Batch_TriggerOperation();
        bto.sObjList = o;
        bto.operationType = operationType;
        bto.sObjectType = sObjectType;
        Database.executeBatch(bto,200);
    }
}