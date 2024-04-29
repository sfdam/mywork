@isTEst
public class CRM_NDGCollegatiPWTest {
@TestSetup
    static void setup(){
        
        Endpoint__c endPoint = new Endpoint__c();
        endPoint.Name = 'GestioneSpecchioV1';
        endPoint.Method__c = 'POST';
        endPoint.Timeout__c = 120000;
        endPoint.Endpoint__c = 'Test';
        insert endPoint;

        Account acct2 = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358', CRM_NDGGoverno__c='1234',FinServ__BankNumber__c='05387');
        insert acct2;
        Account acct3 = new Account (Name = 'ACE ChemicalsBCP', ModelloDiServizio__c = 'Private', CRM_NDG__c = '0033', CRM_NDGGoverno__c='1234',FinServ__BankNumber__c='03084');
        insert acct3;

        Contact cntct2 = new Contact();
        cntct2.FirstName = 'Giuseppe';
        cntct2.LastName = 'Scopece';
        cntct2.AccountId = acct2.Id;
        insert cntct2;

        

        String profileId = [SELECT id FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].id;

        User testUser = AllDataFactory.getUser('1123', profileId, 'Family');       

        insert testUser;

     
    }

    @isTest
    public static void test(){
        Account acc = [SELECT Id, CRM_NDGGoverno__c FROM Account LIMIT 1];
	

        CRM_NDGCollegatiPW.getAllData(acc.id, acc.CRM_NDGGoverno__c, '05387');
       
        
    }
}