global class Batch_AlignNdgHierarchy implements Database.Batchable<sObject>,Database.stateful{

    global Set<String> walletsIdSet{get;set;}
    public static Boolean skipAccountTrigger=false;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator('SELECT Id, PTF_Banca__c, PTF_DirezioneRegionale__c, PTF_Area__c, PTF_Capofila__c, PTF_Portafoglio__r.PTF_Banca__c, PTF_Portafoglio__r.PTF_DirezioneRegionale__c, PTF_Portafoglio__r.PTF_Area__c, PTF_Portafoglio__r.PTF_Capofila__c FROM Account WHERE PTF_Portafoglio__c IN: walletsIdSet');
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Account> ndgtoUpdate = new List<Account>();
        for(Account ndg : scope){
            if(ndg.PTF_Capofila__c != ndg.PTF_Portafoglio__r.PTF_Capofila__c ||
            ndg.PTF_Area__c != ndg.PTF_Portafoglio__r.PTF_Area__c ||
            ndg.PTF_DirezioneRegionale__c != ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__c ||
            ndg.PTF_Banca__c != ndg.PTF_Portafoglio__r.PTF_Banca__c){

                ndg.PTF_Capofila__c = ndg.PTF_Portafoglio__r.PTF_Capofila__c;
                ndg.PTF_Area__c = ndg.PTF_Portafoglio__r.PTF_Area__c;
                ndg.PTF_DirezioneRegionale__c = ndg.PTF_Portafoglio__r.PTF_DirezioneRegionale__c;
                ndg.PTF_Banca__c = ndg.PTF_Portafoglio__r.PTF_Banca__c;
                ndgtoUpdate.add(ndg);
            }
        }

        if(!ndgtoUpdate.isEmpty()){
            skipAccountTrigger=true;
            update ndgtoUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}