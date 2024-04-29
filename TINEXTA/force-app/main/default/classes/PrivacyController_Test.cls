@isTest
public class PrivacyController_Test {

    @TestSetup
    static void makeData(){
        List<Lead> l = TestDataFactory.createLeads(1);
        l[0].Company = 'Test123';
        l[0].LastName = 'Test123';
        l[0].Email = 'test@test.it.invalid';
        insert l;
    }

    @isTest static void getDataTest(){
        Funzionalita__c f = new Funzionalita__c();
        f.Disabilita_tutti_i_trigger__c=true;
        f.Disabilita_tutti_i_process_builder__c=true;
        f.Disabilita_Integrazione__c=true;
        insert f;
        
        Account[] accts1 = TestDataFactory.createAccounts(1);
        insert accts1;
        Contact con = TestDataFactory.create_Contact();
        con.AccountId=accts1[0].id;
        // insert con;

        Contact con2 = TestDataFactory.create_Contact();
        con2.AccountId=accts1[0].id;
        con2.Contitolarita_dati_TXT__c = 'SI';
        // insert con2;
        
        List<Contact> cList = new List<Contact>{con,con2};
        insert cList;

        clist[1].Contitolarita_dati_TXT__c = 'NO';
        update cList[1];

        Lead l = [SELECT Id FROM Lead LIMIT 1];
                
        Map<String, SObject> contactResult = PrivacyController.getData((String)con.Id);
        Boolean savePrivacyResult = PrivacyController.savePrivacy((String)con.Id, true, true, '2');
        Boolean savePrivacyResult2 = PrivacyController.savePrivacy((String)con.Id, true, true, '1');
        Boolean savePrivacyResult3 = PrivacyController.savePrivacy((String)l.Id, true, true, '1');
        // Boolean sendEmailRes = PrivacyController.sendRecapEmail(con.Id, 'INN', 'https://communityurl.com');
        // Boolean sendEmailRes2 = PrivacyController.sendRecapEmail(l.Id, 'INN', 'https://communityurl.com');
        // Boolean sendEmailRes3 = PrivacyController.sendRecapEmail(null, 'INN', 'https://communityurl.com');
    }

}