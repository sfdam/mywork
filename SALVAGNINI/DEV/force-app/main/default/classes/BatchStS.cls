global class BatchStS implements Database.Batchable<Sobject>, Database.Stateful{
    
    String query = 'Select Id From Account WHERE Sent_To_ITSM__c = true and Primary_industry__c != NULL';
    List<Account> listToUpdate = new List<Account>();
    
    global BatchStS(){
        listToUpdate = new List<Account>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        List<Account> AccList = Database.query(query);
        return  Database.getQueryLocator(query);
        
        
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope){ 
        listToUpdate = new List<Account>();
        System.debug('scope: '+scope);
        string networkId = [select Id, ConnectionStatus, ConnectionName from PartnerNetworkConnection
                            where ConnectionStatus = 'Accepted' LIMIT 1]?.Id;
        List<PartnerNetworkRecordConnection> PNRecordList = new List<PartnerNetworkRecordConnection>();
        for(account singleAccount  : listToUpdate){
            PartnerNetworkRecordConnection newrecord = new PartnerNetworkRecordConnection();
            
            newrecord.ConnectionId = networkId;
            newrecord.LocalRecordId = singleAccount.Id;
            newrecord.RelatedRecords = 'Contact';
            newrecord.SendClosedTasks = true;
            newrecord.SendOpenTasks = true;
            PNRecordList.add(newrecord);
            singleAccount.Sent_TO_ITSM__c = false;
        }
        insert PNRecordList;
        update listToUpdate;
    } 
    
    global void finish(Database.BatchableContext BC){ 
        
        System.debug('updateListFC::: '+listToUpdate);
        System.debug('updateListFC.size::: '+listToUpdate.size());
        
    }   
    
}