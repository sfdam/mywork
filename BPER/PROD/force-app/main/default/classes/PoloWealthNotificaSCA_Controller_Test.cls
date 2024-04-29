@IsTest
public class PoloWealthNotificaSCA_Controller_Test {
    @TestSetup
    static void setup(){
        Endpoint__c endPoint = new Endpoint__c();
        endPoint.Name = 'cifraDati';
        endPoint.Method__c = 'POST';
        endPoint.Timeout__c = 120000;
        endpoint.CertificateName__c='salesforcetestclient2024';
        endPoint.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/ScaAPI/v1/utenti/{username}/dati/cifratura';

        Endpoint__c endPoint1 = new Endpoint__c();
        endPoint1.Name = 'inviaNotificaPush';
        endPoint1.Method__c = 'POST';
        endPoint1.Timeout__c = 120000;
        endpoint1.CertificateName__c='salesforcetestclient2024';
        endPoint1.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/NotificheAPI/v1/sendPush/notifiche/api/v1/notifiche';


        Endpoint__c endPoint2 = new Endpoint__c();
        endPoint2.Name = 'inserisciOperazione';
        endPoint2.Method__c = 'POST';
        endPoint2.Timeout__c = 120000;
        endpoint2.CertificateName__c='salesforcetestclient2024';
        endPoint2.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/MulticscaAPI/v1/operazioni/{idOperazione}/stato';

        Endpoint__c endPoint3 = new Endpoint__c();
        endPoint3.Name = 'recuperaStatoOperazione';
        endPoint3.Method__c = 'GET';
        endPoint3.Timeout__c = 120000;
        endpoint3.CertificateName__c='salesforcetestclient2024';
        endPoint3.Endpoint__c = 'https://apigw-test.bper.it:443/gateway/MulticscaAPI/v1/operazioni/{idOperazione}/stato';
        insert new List<Endpoint__c>{endPoint,endPoint1, endPoint2, endPoint3};

        Account a = new Account ();
        a.Name='TestName';
        a.finserv__banknumber__c='05387';
        insert a;

        

        CRM_Channel__c ch= new CRM_Channel__c();
        ch.CRM_Account__c=a.Id;
        ch.CRM_UserCodeStatus__c='Active';
        ch.CRM_UserId__c='Test';
        ch.RecordTypeId=SV_Utilities.getRecordTypeByDeveloperName('CRM_Channel__c', 'Internet_Banking');
        
        insert ch;

        Case c1= new Case();
        c1.Origin='Web';
        c1.Subject='First';
        c1.accountId=a.Id;

        insert c1;

        User u=new User();
        u.Id=UserInfo.getUserId();
        u.abi__c='05387';
        u.applicazione__c='Salesforce';
        u.terminale__c='XXX';
        u.ip__c='test';
        u.FederationIdentifier='test';
        u.idced__c='test';
        update u;

    }

    @isTest
    static void test1(){

    List<Case>  csList= [SELECT Id, AccountId, CC_notificationId__c, CRM_CustomerAuthenticationType__c, Account.finserv__banknumber__c FROM Case];
    Case cs= csList[0];

    List<CRM_Channel__c>  channels= [select Id, CRM_Account__r.Name, CRM_UserCodeStatus__c, CRM_UserId__c, RecordType.DeveloperName  from CRM_Channel__c];  
    CRM_Channel__c ch= channels[0];

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
    PoloWealthNotificaSCA_Controller.getRecord(cs.Id);
    PoloWealthNotificaSCA_Controller.getFieldsAndRecords(cs.AccountId);
    Object response = PoloWealthNotificaSCA_Controller.cifraDati(ch.CRM_UserId__c, '05387');
    

    Test.stopTest();

    }

    @isTest
    static void test2(){

    List<Case>  csList= [SELECT Id, AccountId, CC_notificationId__c, CRM_CustomerAuthenticationType__c, Account.finserv__banknumber__c FROM Case];
    Case cs= csList[0];

    List<CRM_Channel__c>  channels= [select Id, CRM_Account__r.Name, CRM_UserCodeStatus__c, CRM_UserId__c, RecordType.DeveloperName  from CRM_Channel__c];  
    CRM_Channel__c ch= channels[0];

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
    String notId = PoloWealthNotificaSCA_Controller.sendPush(ch.CRM_UserId__c, '123', cs.Account.finserv__banknumber__c);

    Test.stopTest();

    }

    @isTest
    static void test3(){

    List<Case>  csList= [SELECT Id, AccountId, CC_notificationId__c, CRM_CustomerAuthenticationType__c, Account.finserv__banknumber__c FROM Case];
    Case cs= csList[0];

    List<CRM_Channel__c>  channels= [select Id, CRM_Account__r.Name, CRM_UserCodeStatus__c, CRM_UserId__c, RecordType.DeveloperName  from CRM_Channel__c];  
    CRM_Channel__c ch= channels[0];

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
    PoloWealthNotificaSCA_Controller.inserisciOperazione(ch.CRM_UserId__c, '123', cs.Id, '');

    Test.stopTest();

    }

    @isTest
    static void test4(){

    List<Case>  csList= [SELECT Id, AccountId, CC_notificationId__c, CRM_CustomerAuthenticationType__c, Account.finserv__banknumber__c FROM Case];
    Case cs= csList[0];

    List<CRM_Channel__c>  channels= [select Id, CRM_Account__r.Name, CRM_UserCodeStatus__c, CRM_UserId__c, RecordType.DeveloperName  from CRM_Channel__c];  
    CRM_Channel__c ch= channels[0];

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

    PoloWealthNotificaSCA_Controller.recuperaStatoOperazione('123', cs.Id, '');

    Test.stopTest();

    }
    
    @isTest
    public static void testTest(){

        PoloWealthNotificaSCA_Controller.test();
    }
}