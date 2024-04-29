@isTest
private class Batch_EliminaVisibilitaGerarchia_Test {
    @testSetup static void setup() {
        List<Struttura_Banca__c> sbs = new List<Struttura_Banca__c>();
        Struttura_Banca__c sb1 = new Struttura_Banca__c(
            IdCed__c='12345T',
            Stato__c='D'
        );
        sbs.add(sb1);
        insert sbs;
        Account banca= AllDataFactory.getAccount('Banca','Banca');
        banca.FinServ__BankNumber__c='1234';
		banca.PTF_IdCED__c='1234';
        insert banca;
        Account a = new Account();
        a.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'AltraUnitaOrganizzativa');
        a.Name = 'UFF. Private test';
        a.PTF_IdCED__c = '998';
        insert a;
        Account b = new Account();
        b.RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'DirezioneRegionale');
        b.Name = 'Direzione Reg Test';
        b.PTF_IdCED__c = '991';
        insert b;
        ConfigUffPrivateDR__c c = new ConfigUffPrivateDR__c();
        c.Name = 'TEST';
        c.PTF_DR__c = b.Id;
        c.PTF_UffPrivate__c = a.Id;
        c.PTF_IdCP__c='CP1';
        Insert c;
        Account area = AllDataFactory.getAccount('Area','Area');
        area.PTF_DirezioneRegionale__c=b.Id;
        area.PTF_Banca__c=banca.Id;
        area.PTF_IdCED__c='123456';
        insert area;
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c='A';
        filiale.PTF_Area__c= area.Id;
        filiale.PTF_Banca__c=banca.Id;
        filiale.PTF_DirezioneRegionale__c=b.Id;
        filiale.PTF_IdCED__c='1238';
        filiale.PTF_IdCEDFiliale__c='1200';
        insert filiale;
        Wallet__c wal = new Wallet__c();
        wal.PTF_ModelloDiServizio__c='Private';
        wal.PTF_Filiale__c=filiale.Id;
        wal.PTF_Banca__c=banca.Id;
        wal.PTF_Capofila__c=filiale.Id;
        wal.PTF_Area__c=area.Id;
        wal.PTF_DirezioneRegionale__c=b.Id;
        insert wal;
        Group g = new Group();
        g.Name='T123';
        g.DeveloperName = 'RIDCEDT123';
        g.Type='Regular';
        insert g;
        Wallet__Share ws = new Wallet__Share();
        ws.parentId = wal.Id;
        ws.UserOrGroupId = g.Id;
        ws.AccessLevel='Edit';
        ws.RowCause='Manual';
        insert ws;
    }
    @isTest
    static void unitTest1() {
        Struttura_Banca__c sb2 = new Struttura_Banca__c(
            IdCed__c='T123',
            Stato__c='D'
        );
        insert sb2;
        Test.startTest();
        Batch_EliminaVisibilitaGerarchia sgr = new Batch_EliminaVisibilitaGerarchia();
        sgr.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(sgr,200);
        Test.stopTest();
    }
    
    @isTest
    static void unitTest2() {
        List<UserRole> urs = new List<UserRole>();
        UserRole ur1 = new UserRole(
            Name = '12345T',
            DeveloperName = 'RIDCED12345T'
        );
        urs.add(ur1);
        
        insert urs;
        Test.startTest();
        Batch_EliminaVisibilitaGerarchia sgr = new Batch_EliminaVisibilitaGerarchia();
        sgr.initRunner(new List<ScheduledJob__c>());
        sgr.sObjectToManage = new List<String>{'UserRoleAndGroups'};
        Database.executeBatch(sgr,200);
        Test.stopTest();
    }
}