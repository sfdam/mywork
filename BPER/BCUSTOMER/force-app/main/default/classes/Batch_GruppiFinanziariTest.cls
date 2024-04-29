@IsTest
public class Batch_GruppiFinanziariTest {
    @TestSetup
    public static void setup(){
        // String personAccountRTId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        // String gruppoRTId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('GruppoFinanziario').getRecordTypeId();
        
        // Account gruppo= new Account();
        // gruppo.Name='TestCoint';
        // gruppo.RecordTypeId=gruppoRTId;
        // insert gruppo;
        // Account childAccount= new Account();
        // childAccount.LastName='TestChild';
        // childAccount.PTF_Gruppo__c=gruppo.Id;
        // childAccount.RecordTypeId=personAccountRTId;
        // insert childAccount;  

        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        filiale.PTF_BranchTypology__c = 'A';
        insert filiale;
        Wallet__c wal=AllDataFactory.getWallet('MicroWallet',  filiale.Id, 'CORPORATE');
        insert wal;
        // Gruppo
        Account gruppo = AllDataFactory.getAccount('05', 'GruppoFinanziario');
        gruppo.PTF_Filiale__c = filiale.Id;
        gruppo.PTF_NaturaGiuridica__c = 'GF';
        gruppo.PTF_PortafoglioAssegnato__c=true;

        Account gruppo2 = AllDataFactory.getAccount('05', 'GruppoFinanziario');
        gruppo2.PTF_Filiale__c = filiale.Id;
        gruppo2.PTF_NaturaGiuridica__c = 'GF';

        Account business = AllDataFactory.getAccount('06', 'IndustriesBusiness');
        business.PTF_Filiale__c = filiale.Id;

        Account business2 = AllDataFactory.getAccount('07', 'IndustriesBusiness');
        business2.PTF_Filiale__c = filiale.Id;
        business2.PTF_Portafoglio__c=wal.id;
        insert new List<Account>{gruppo, business, business2, gruppo2};
        
        CRM_LinkedNDG__c capoGruppo = new CRM_LinkedNDG__c(
            CRM_Account__c = gruppo.Id,
            CRM_RelatedAccount__c = business.Id,
            CRM_LinkCode__c = '113',
            CRM_Status__c = 'A',
            CRM_LinkType__c = 'CAPOGRUPPO'
        );
        CRM_LinkedNDG__c membroGruppo = new CRM_LinkedNDG__c(
            CRM_Account__c = gruppo2.Id,
            CRM_RelatedAccount__c = business2.Id,
            CRM_LinkCode__c = '113',
            CRM_Status__c = 'A',
            CRM_LinkType__c = 'CAPOGRUPPO'
        );
        insert new List<CRM_LinkedNDG__c>{capoGruppo, membroGruppo};
    }
   
    @isTest
    public static void testExecute(){
        Database.executeBatch(new Batch_GruppiFinanziari());
    }
}