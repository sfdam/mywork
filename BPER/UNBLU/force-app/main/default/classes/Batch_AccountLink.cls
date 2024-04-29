global class Batch_AccountLink implements Database.Batchable<sObject>,Database.stateful,IRunner {

    global Map<Id,AccountWrapper> mWrapper = new Map<Id,AccountWrapper>();
    public static Boolean skipAccountTrigger=false;
    public static Boolean executeChangeStruttura=false;
    global List<ScheduledJob__c> sj = new List<ScheduledJob__c>();
    
    global void initRunner(List<ScheduledJob__c> schedules) {
        sj.addAll(schedules);
    }

    //NEW UFF PRIVATE
    public Set<String> uffPrivateIdCedSet = new Set<String>();
    public Map<String, String> uffPrivateMap {
        get{

            if(uffPrivateMap != null){

                return uffPrivateMap;
            }
            uffPrivateMap = new Map<String, String>();
            for(Account uffPrivate : [SELECT ID, PTF_IDCed__c FROM Account WHERE PTF_IDCed__c IN: uffPrivateIdCedSet]){
                uffPrivateMap.put(uffPrivate.PTF_IDCed__c, uffPrivate.Id);
            }
            return uffPrivateMap;
        }set;
    }
    //NEW UFF PRIVATE
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'SELECT Id, RecordType.DeveloperName, PTF_BranchTypology__c, ParentId, PTF_IDCEDUffPrivate__c, PTF_UffPrivate__c FROM Account WHERE RecordType.DeveloperName IN (\'FilialeDiRelazione\',\'Area\',\'DirezioneRegionale\',\'Banca\',\'AltraUnitaOrganizzativa\')';
        
        List<Account> accs = Database.query(query);
        Map<Id,Account> accMap= new Map<Id,Account>(accs); 
        for(Id accId: accMap.keySet()) {

            Account currentAccount = accMap.get(accId);
            //NEW UFF PRIVATE
            if(!String.isBlank(currentAccount.PTF_IDCEDUffPrivate__c)){
                uffPrivateIdCedSet.add(currentAccount.PTF_IDCEDUffPrivate__c);
            }
            //NEW UFF PRIVATE
            AccountWrapper wrap= new AccountWrapper();
            List<Account> parents= new List<Account>();
            wrap.id= currentAccount.Id;
            wrap.tipo= currentAccount.RecordType.DeveloperName;
            
            Boolean stop= false;
            Account accountToCheck= currentAccount;
            do{
                if(String.isNotBlank(accountToCheck.ParentId) && accMap.containsKey(accountToCheck.ParentId)){
                    parents.add(accMap.get(accountToCheck.ParentId));
                    accountToCheck= accMap.get(accountToCheck.ParentId);
                }
                else{
                    stop=true;
                }
            }
            while(!stop);
            wrap.parents=parents;
            mWrapper.put(wrap.id,wrap);
        }
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {
        List<Account> accountToUpdate = new List<Account>();
        for(Account scopeAcc: scope){

            Account acc = new Account();
            acc.Id=scopeAcc.id;
            acc.PTF_Capofila__c=null;
            acc.PTF_Area__c=null;
            acc.PTF_DirezioneRegionale__c=null;
            acc.PTF_Banca__c=null;

            if(mWrapper.get(acc.Id).tipo=='FilialeDiRelazione'){
                
                for(Integer i=0; i<mWrapper.get(acc.Id).parents.size(); i++){

                    if(mWrapper.get(acc.Id).parents[i].RecordType.DeveloperName=='FilialeDiRelazione'){
                        acc.PTF_Capofila__c=mWrapper.get(acc.Id).parents[i].Id;
                    }
                    else if(mWrapper.get(acc.Id).parents[i].RecordType.DeveloperName=='Area'){
                        acc.PTF_Area__c=mWrapper.get(acc.Id).parents[i].Id;
                    }
                    else if(mWrapper.get(acc.Id).parents[i].RecordType.DeveloperName=='DirezioneRegionale'){
                        acc.PTF_DirezioneRegionale__c=mWrapper.get(acc.Id).parents[i].Id;
                    }
                    else if(mWrapper.get(acc.Id).parents[i].RecordType.DeveloperName=='Banca'){
                        acc.PTF_Banca__c=mWrapper.get(acc.Id).parents[i].Id;
                    }
                }

                //NEW UFF PRIVATE
                if(uffPrivateMap.containsKey(scopeAcc.PTF_IDCEDUffPrivate__c)){
                    acc.PTF_UffPrivate__c = uffPrivateMap.get(scopeAcc.PTF_IDCEDUffPrivate__c);
                }
                //NEW UFF PRIVATE
                accountToUpdate.add(acc);   
            }

            else if(mWrapper.get(acc.Id).tipo=='Area'){
                for(Integer i=0; i<mWrapper.get(acc.Id).parents.size(); i++){
                    
                    if(mWrapper.get(acc.Id).parents[i].RecordType.DeveloperName=='DirezioneRegionale'){
                        acc.PTF_DirezioneRegionale__c=mWrapper.get(acc.Id).parents[i].Id;
                    }
                    else if(mWrapper.get(acc.Id).parents[i].RecordType.DeveloperName=='Banca'){
                        acc.PTF_Banca__c=mWrapper.get(acc.Id).parents[i].Id;
                    }

                    
                }
                accountToUpdate.add(acc);
            }

            else if(mWrapper.get(acc.Id).tipo=='DirezioneRegionale'){
                for(Integer i=0; i<mWrapper.get(acc.Id).parents.size(); i++){
                    
                   
                    if(mWrapper.get(acc.Id).parents[i].RecordType.DeveloperName=='Banca'){
                        acc.PTF_Banca__c=mWrapper.get(acc.Id).parents[i].Id;
                    }

                    
                }
                accountToUpdate.add(acc);
            }
            else if(mWrapper.get(acc.Id).tipo=='AltraUnitaOrganizzativa'){
                for(Integer i=0; i<mWrapper.get(acc.Id).parents.size(); i++){

                    if(mWrapper.get(acc.Id).parents[i].RecordType.DeveloperName=='Area'){
                        acc.PTF_Area__c=mWrapper.get(acc.Id).parents[i].Id;
                    }
                    else if(mWrapper.get(acc.Id).parents[i].RecordType.DeveloperName=='DirezioneRegionale'){
                        acc.PTF_DirezioneRegionale__c=mWrapper.get(acc.Id).parents[i].Id;
                    }
                    else if(mWrapper.get(acc.Id).parents[i].RecordType.DeveloperName=='Banca'){
                        acc.PTF_Banca__c=mWrapper.get(acc.Id).parents[i].Id;
                    }

                   
                }
                accountToUpdate.add(acc);
            }

        }
        if(accountToUpdate.size()>0){
            executeChangeStruttura=true;
            skipAccountTrigger=true;
            update accountToUpdate;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
        if (sj!=null && sj.size()>0) {
            JobRunner.executeNext(sj);
        }
    }
    
    
    public class AccountWrapper{
        String id;
        String tipo;
        List<Account> parents;
    }
    
}