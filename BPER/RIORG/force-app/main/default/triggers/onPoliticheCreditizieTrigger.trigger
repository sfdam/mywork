// Trigger Apex per copiare il campo DescrizioneNACE__c da PoliticheCreditizie__c all'Account
trigger onPoliticheCreditizieTrigger on CRM_PoliticheCreditizie__c (after insert, after update) {
    // Raccogliamo gli ID di Account collegati ai record di PoliticheCreditizie__c
    Set<Id> accountIds = new Set<Id>();
    for (CRM_PoliticheCreditizie__c pc : Trigger.new) {
        if (pc.CRM_AccountId__c != null) {
            accountIds.add(pc.CRM_AccountId__c);
        }
    }
    
    // Se ci sono Account collegati, raccogliamo le descrizioni NACE
    if (accountIds.size() > 0) {
        Map<Id, String> naceMap = new Map<Id, String>();
        for (Account acc : [SELECT Id, CRM_DescrizioneNACE__c FROM Account WHERE Id IN :accountIds]) {
            naceMap.put(acc.Id, acc.CRM_DescrizioneNACE__c);
        }
        
        // Aggiorniamo gli Account con le descrizioni NACE
        List<Account> accountsToUpdate = new List<Account>();
        for (CRM_PoliticheCreditizie__c pc : Trigger.new) {
            if (pc.CRM_AccountId__c != null && naceMap.containsKey(pc.CRM_AccountId__c)) {
                Account acc = new Account(Id = pc.CRM_AccountId__c, CRM_DescrizioneNACE__c = pc.CRM_DescrizioneNACE__c);
                accountsToUpdate.add(acc);
            }
        }
        if (accountsToUpdate.size() > 0) {
            update accountsToUpdate;
        }
    }
}