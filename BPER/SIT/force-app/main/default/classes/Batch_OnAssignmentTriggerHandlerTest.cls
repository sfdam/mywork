@isTest
private class Batch_OnAssignmentTriggerHandlerTest {

    @isTest
    static void unitTest1() {
        Account banca = AllDataFactory.getAccount('01', 'Banca');
        Account direzioneRegionale = AllDataFactory.getAccount('02', 'DirezioneRegionale');
        Account area = AllDataFactory.getAccount('03', 'Area');
        Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c = 'A';
        insert new List<Account>{banca, direzioneRegionale, area, filiale};
        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'CORPORATE');
        insert microPortafoglio;
        filiale.PTF_Portafoglio__c=microPortafoglio.Id;
        update filiale;
        Contact gestore = AllDataFactory.getContact('01', null, filiale.Id);
        insert gestore;
        Assignment__c assignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, gestore.Id);
        insert assignment;
        Test.startTest();
        Batch_OnAssignmentTriggerHandler b = new Batch_OnAssignmentTriggerHandler();
        b.eventType='onAfterUpdate';
        b.idAssignment = new Set<Id>{assignment.Id};
        Database.executeBatch(b,200);
        Test.stopTest();
    }
    
    @isTest
    static void unitTest2() {
        Account banca = AllDataFactory.getAccount('01', 'Banca');
        Account direzioneRegionale = AllDataFactory.getAccount('02', 'DirezioneRegionale');
        Account area = AllDataFactory.getAccount('03', 'Area');
        Account filiale = AllDataFactory.getAccount('04', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c = 'A';
        insert new List<Account>{banca, direzioneRegionale, area, filiale};
        Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet', filiale.Id, 'CORPORATE');
        insert microPortafoglio;
        Contact gestore = AllDataFactory.getContact('01', null, filiale.Id);
        insert gestore;
        Assignment__c assignment = AllDataFactory.getAssignment('Primario', microPortafoglio.Id, gestore.Id);
        insert assignment;
        List<Account> ndgs = new List<Account>();
        for (Integer i=1;i<=10;i++) {
        	Account ndg = AllDataFactory.getAccount('05', 'IndustriesBusiness');
            ndg.PTF_Portafoglio__c=microportafoglio.Id;
            ndgs.add(ndg);
        }
        insert ndgs;
        Map<Id,List<Assignment__c>> m = new Map<Id,List<Assignment__c>>();
        m.put(microPortafoglio.Id,new List<Assignment__c>{assignment});    
        Test.startTest();    
        Batch_OnAssignmentTriggerHandler b = new Batch_OnAssignmentTriggerHandler();
        b.eventType='onAfterInsert';
        b.idMicroWalletOver1K = new Set<Id>{microPortafoglio.Id};
        b.mPTFAssignment = m;
        Database.executeBatch(b,200);
        Batch_OnAssignmentTriggerHandler.invokeBatch(new List<sObject>(),'insert','test');
        
        Test.stopTest();
    }
}