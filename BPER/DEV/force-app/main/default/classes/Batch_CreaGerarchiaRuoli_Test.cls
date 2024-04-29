@isTest
private class Batch_CreaGerarchiaRuoli_Test {
    
    @testSetup static void setup() {
        List<Struttura_Banca__c> sbs = new List<Struttura_Banca__c>();
        Struttura_Banca__c sb1 = new Struttura_Banca__c(
            IdCed__c='12347',
            Descrizione__c ='T12347',
            Stato__c='A'
        );
        Struttura_Banca__c sb2 = new Struttura_Banca__c(
            IdCed__c='12348',
            IDCed_Padre__c='12347',
            Descrizione__c ='T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348T12348',
            Stato__c='A'
        );
        sbs.add(sb1);
        sbs.add(sb2);
        
        insert sbs;
    }
    
    @isTest
    static void unitTest() {
        UserRole ur = new UserRole(
            Name = 'T12347',
            DeveloperName ='RIDCEDT12347'
        );
        insert ur;
        Test.startTest();
        Batch_CreaGerarchiaRuoli sgr = new Batch_CreaGerarchiaRuoli();
        sgr.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(sgr);
        Batch_CreaGerarchiaRuoli.findUserRoleByDevName(new Set<String>{'RIDCEDT12347'});
        Batch_CreaGerarchiaRuoli.createGroup(new List<UserRole>{ur},new Map<String,Set<String>>{'T12347'=>new Set<String>{'T12347'}});
        Test.stopTest();
    }
    
    @isTest
    static void unitTest1() {
        List<Struttura_Banca__c> sbs = [SELECT Id FROM Struttura_Banca__c];
        delete sbs;
        Test.startTest();
        Batch_CreaGerarchiaRuoli sgr = new Batch_CreaGerarchiaRuoli();
        sgr.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(sgr);
        Test.stopTest();
    }
}