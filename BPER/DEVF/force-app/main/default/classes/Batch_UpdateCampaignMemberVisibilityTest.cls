@isTest
public with sharing class Batch_UpdateCampaignMemberVisibilityTest {

    @TestSetup
    static void makeData(){

        ServiceModel__c personal = new ServiceModel__c(Name = 'Personal',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'WM');

        ServiceModel__c family = new ServiceModel__c(Name = 'Family',
        PTF_Division__c = 'PE',
        PTF_MacroDivision__c = 'EB');
        insert new List<ServiceModel__c>{personal, family};
        Account banca = AllDataFactory.getAccount('10', 'Banca');
        banca.FinServ__BankNumber__c = '05387';
        insert banca;
        Account dir = AllDataFactory.getAccount('09', 'DirezioneRegionale');
        dir.FinServ__BankNumber__c = '05387';
        dir.parentId = banca.Id;
        dir.PTF_Banca__c = banca.Id;
        insert dir;
        Account area = AllDataFactory.getAccount('08', 'Area');
        area.FinServ__BankNumber__c = '05387';
        area.parentId = dir.Id;
        area.PTF_Banca__c = banca.Id;
        area.PTF_DirezioneRegionale__c = dir.Id;
        insert area;
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.FinServ__BankNumber__c = '05387';
        filiale.parentId = area.Id;
        filiale.PTF_BranchTypology__c = 'A';
        filiale.PTF_Banca__c = banca.Id;
        filiale.PTF_DirezioneRegionale__c = dir.Id;
        filiale.PTF_Area__c = area.Id;
        insert new List<Account>{filiale};

        Wallet__c microPortafoglioFamily = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Family');
        Wallet__c microPortafoglioPersonal = AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'Personal');
        insert new List<Wallet__c>{microPortafoglioFamily, microPortafoglioPersonal};

        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];

        User titolare = AllDataFactory.getUser('14', profile.Id, 'CORPORATE');
        titolare.FederationIdentifier = '14';
        titolare.Profilo__c = 'NEC_F.1';
        insert titolare;

        String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
        
        Account acct = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358');
        acct.PTF_Portafoglio__c = microPortafoglioFamily.Id;
        insert acct;

        Contact cntct = new Contact();
        cntct.FirstName = 'Bruce';
        cntct.LastName = 'Wayne';
        cntct.AccountId = acct.Id;
        insert cntct;

        Campaign cmpgn = AllDataFactory.getCampaign('02', titolare.Id, recordTypeTopDownMono);
        cmpgn.CRM_NomeAttributo1__c =null;
        cmpgn.CRM_NomeAttributo2__c =null;
        insert cmpgn;

        CampaignMember cmpMember = new CampaignMember(Status = 'Da contattare');
        cmpMember.ContactId = cntct.id; 
        cmpMember.CampaignId = cmpgn.id;
        cmpMember.CRM_Assegnatario__c = UserInfo.getUserId();
        cmpMember.CRM_StatoAssegnazione__c = 'Assegnato';
        cmpMember.isActive__c = true;
        insert cmpMember;
    }
    
    @isTest
    static void unitTest() {
        Map<Id, Account> newMap = new Map<Id, Account>();
        Map<Id, Account> oldMap = new Map<Id, Account>();
        Account acc = [SELECT Id, PTF_Portafoglio__c FROM Account WHERE CRM_NDG__c = '112358' LIMIT 1];
        Account acc2 = new Account();
        acc2.Id = acc.Id;
        Wallet__c ptf = [SELECT Id FROM Wallet__c WHERE PTF_ModelloDiServizio__c = 'Personal' LIMIT 1];
        
        oldMap.put(acc.Id, acc);

        acc2.PTF_Portafoglio__c = ptf.Id;
        newMap.put(acc2.Id, acc2);

        Test.startTest();
        Batch_UpdateCampaignMemberVisibility ucmv = new Batch_UpdateCampaignMemberVisibility(newMap, oldMap, new Set<String>{acc.Id, acc2.Id});
        Database.executeBatch(ucmv);
        Test.stopTest();
    }
}