@isTest
private class ConnectorEntityController_Test {
    
     static testMethod void myUnitTest() {
         User user = AllDataFactory.getUser('user',[SELECT id FROM Profile WHERE Name = 'System Administrator' LIMIT 1 ][0].id,'Family');
         insert user;
         
          Account account = AllDataFactory.getAccount( 'FirstName',  'IndustriesBusiness');
          insert account;
         
         Contact contact = AllDataFactory.getContact('contact',null,account.id);
         contact.AccountId = account.Id;
         contact.FirstName = 'FirstName';
         contact.LastName = 'LastName';
         contact.Email = 'abc@it.it';
         insert contact;
         
         Task a = new Task();
         a.Subject='test';
         a.CallType = 'Inbound';
         a.Status = 'Open';
         
         
         Case c = new Case();
         c.AccountId = account.Id;
         c.Subject ='test';     

         Test.startTest();   
         Task responseTask = ConnectorEntityController.createTask(a, 'Email', 'abc@it.it'); 
         Case responseCase = ConnectorEntityController.createCase(c, 'Email', 'abc@it.it'); 
         String ou = ConnectorEntityController.ERCOmniUtilsPath;
         String iwss = ConnectorEntityController.ERCiwsscriptomniPath;
         String su = ConnectorEntityController.ERCsyncUtilsPath;
         
         Test.stopTest();
         System.assertEquals(true,responseTask != null );
         System.assertEquals(true,responseCase != null );
         System.assertEquals(true,ou != null );
         System.assertEquals(true,iwss != null );
         System.assertEquals(true,su != null );
    }
    
    @isTest
    private static void testCustomActionWithoutAccount(){
        ConnectorEntityController.CustomActionRequestWrapper req= new ConnectorEntityController.CustomActionRequestWrapper();
        req.esigenza='ACCESSO_IB';
        req.autenticated='Cliente autenticato';
        req.phone='3346018783';
        req.transfer='Transfer';
        
        Test.startTest();
        ConnectorEntityController.CustomActionResponseWrapper response = ConnectorEntityController.customAction(req);
        Test.stopTest();
        System.assertEquals(true, response != null);
       
    }
  
    @isTest
    private static void testCustomActionWithAccount(){
        Account acc= new Account();
        acc.RecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Account', 'PersonAccount');
        acc.LastName='test';
        acc.CRM_Phone1__c='3343018783';
        insert acc;
        Id [] fixedSearchResults = new Id[1];  
        fixedSearchResults[0] = acc.Id;  
        Test.setFixedSearchResults( fixedSearchResults );
        ConnectorEntityController.CustomActionRequestWrapper req= new ConnectorEntityController.CustomActionRequestWrapper();
        req.esigenza='ACCESSO_IB';
        req.autenticated='Cliente autenticato';
        req.phone='3343018783';
        Test.startTest();
        ConnectorEntityController.CustomActionResponseWrapper response = ConnectorEntityController.customAction(req);
        Test.stopTest();
        System.assertEquals(true, response != null);
    }
    @isTest
    private static void testCustomActionWithNDGId(){
        Account acc= new Account();
        acc.RecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Account', 'PersonAccount');
        acc.LastName='test';
        acc.CRM_Phone1__c='3343018783';
        acc.CRM_NDG__c='123';
        insert acc;
        ConnectorEntityController.CustomActionRequestWrapper req= new ConnectorEntityController.CustomActionRequestWrapper();
        req.esigenza='ACCESSO_IB';
        req.autenticated='Cliente autenticato';
        req.phone='3343018783';
        req.ndgId='123';
        
        Test.startTest();
        ConnectorEntityController.CustomActionResponseWrapper response = ConnectorEntityController.customAction(req);
        Test.stopTest();
        System.assertEquals(true, response != null);
    }
    @isTest
    private static void testCustomActionWithoutNDGId(){
        Account acc= new Account();
        acc.RecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Account', 'PersonAccount');
        acc.LastName='test';
        acc.CRM_Phone1__c='3343018783';
        acc.CRM_NDG__c='123';
        acc.NDW_ExternalId__c='05387_123';
        insert acc;
        Test.startTest();
        ConnectorEntityController.CustomActionRequestWrapper req= new ConnectorEntityController.CustomActionRequestWrapper();
        req.esigenza='ACCESSO_IB';
        req.autenticated='Cliente autenticato';
        req.phone='3343018783';
        ConnectorEntityController.CustomActionResponseWrapper resp=ConnectorEntityController.customAction(req);
        ConnectorEntityController.updateCase(resp.caseId, 'Cliente autenticato', '123', '05387');
        req.caseId=resp.caseId;
        req.transfer='transfer';
        resp=ConnectorEntityController.customAction(req);
        Case c= new Case(Id=req.caseId, AccountId=acc.Id, Status='Closed',CRM_Hesitation__c='Fornite info');
        update c;
        resp=ConnectorEntityController.customAction(req);
        Test.stopTest();
        System.assertEquals(true, resp != null);
    }

    @isTest
    private static void updateQueue(){
        Account acc=AllDataFactory.getAccount('01', 'PersonAccount');
        insert acc;
        Account ac=[SELECT PersonContactId FROM Account WHERE Id=: acc.Id];

        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];

        User titolare = AllDataFactory.getUser('14', profile.Id, 'CORPORATE');
        titolare.FederationIdentifier = '14';
        titolare.Profilo__c = 'NEC_F.1';
        insert titolare;

        String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
        Campaign camp = AllDataFactory.getCampaign('01', titolare.Id, recordTypeTopDownMono);
        camp.IsActive = false;
        camp.CRM_NomeAttributo1__c =null;
        camp.CRM_NomeAttributo2__c =null;
        insert camp;
        CampaignMember member = new CampaignMember(
                ContactId = ac.PersonContactId,
                Status = 'Completed',
                CampaignId = camp.Id);
        insert member ;
        
        Account acct = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358');
        insert acct;

        Contact cntct = new Contact();
        cntct.FirstName = 'Bruce';
        cntct.LastName = 'Wayne';
        cntct.AccountId = acct.Id;
        insert cntct;

        Campaign cmpgn = AllDataFactory.getCampaign('02', titolare.Id, recordTypeTopDownMono);
        cmpgn.CRM_NomeAttributo1__c =null;
        cmpgn.CRM_NomeAttributo2__c =null;
        cmpgn.CRM_TipologiaOutboundContactCenter__c ='Progressive';
        insert cmpgn;

        CampaignMember cmpMember = new CampaignMember(Status = 'Da contattare');
        cmpMember.ContactId = cntct.id; 
        cmpMember.CampaignId = cmpgn.id;
        cmpMember.CRM_Assegnatario__c = UserInfo.getUserId();
        cmpMember.CRM_StatoAssegnazione__c = 'Assegnato';
        cmpMember.CRM_NumeroTentativi__c = 3;
        cmpMember.LastModifiedDate = Datetime.now().addMinutes(-60);
        cmpMember.CreatedDate = Datetime.now().addDays(-1);
        insert cmpMember;

        Test.startTest();
        Boolean response = ConnectorEntityController.updateQueue(cmpMember.Id, 'Test','Test','0e67a386-10b0-474c-8853-3402865d6b96');
        Test.stopTest();
        System.assertEquals(true, response);

    }

    @IsTest
    private static void updateCaseOwner1(){
        Case c = new Case();
        c.Subject ='test';
        c.Status = 'Closed';
        insert c;
        Test.startTest();
        Boolean response =ConnectorEntityController.updateCaseOwner(c.Id, 'Test');
        Test.stopTest();
        //ConnectorEntityController.createCase(c, 'Email', 'abc@it.it');  
        //System.assertEquals(true, response);
    }

    @IsTest
    private static void updateCaseOwner2(){
        Case c = new Case();
        c.Subject ='test';
        c.Status = 'Pending';
        insert c;
        Test.startTest();
        Boolean response =ConnectorEntityController.updateCaseOwner(c.Id, 'Test');
        Test.stopTest();
        //ConnectorEntityController.createCase(c, 'Email', 'abc@it.it');  
        System.assertEquals(true, response);
    }
    
    @IsTest
    private static void updateCaseOwner3(){
        Case c = new Case();
        c.Subject ='test';
        c.Status = 'Assigned';
        insert c;
        Test.startTest();
        Boolean response =ConnectorEntityController.updateCaseOwner(c.Id, 'Test');
        Test.stopTest();
        //ConnectorEntityController.createCase(c, 'Email', 'abc@it.it');  
        System.assertEquals(true, response);
    }
    
    
    @isTest
    private static void findContact(){
        Account acc=AllDataFactory.getAccount('01', 'PersonAccount');
        insert acc;
        Account ac=[SELECT PersonContactId FROM Account WHERE Id=: acc.Id];

        Profile profile = [SELECT id FROM Profile WHERE  Name =: Label.System_Administrator LIMIT 1];

        User titolare = AllDataFactory.getUser('14', profile.Id, 'CORPORATE');
        titolare.FederationIdentifier = '14';
        titolare.Profilo__c = 'NEC_F.1';
        insert titolare;
        
        Account acct = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358');
        insert acct;

        Contact cntct = new Contact();
        cntct.FirstName = 'Bruce';
        cntct.LastName = 'Wayne';
        cntct.AccountId = acct.Id;
        insert cntct;


        Test.startTest();
        List<Contact> response = ConnectorEntityController.findContactId('FirstName', 'Bruce');
        Test.stopTest();
        System.assertEquals(true, response.size()>0);

    }
    
    @IsTest
    private static void createSobj(){
        Case c = new Case();
        c.Subject ='test';
        c.Status = 'Assigned';
        insert c;
        Test.startTest();
        SObject response = ConnectorEntityController.createSObject(c);
        Test.stopTest();
        System.assertEquals(false, response != null);

    }
    
    @IsTest
    private static void createConnectorEventTimeLog(){
        Map<String,Object> obj = new Map<String,Object>();
        
        Test.startTest();
        softphone_it__ConnectorEventTimeLog__c response = ConnectorEntityController.createConnectorEventTimeLog(obj);
        Test.stopTest();
        System.assertEquals(true, response != null);

    }    
    
    @IsTest
    private static void updateConnectorEventTimeLog(){
        Account acct = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358');
        insert acct;

        Contact cntct = new Contact();
        cntct.FirstName = 'Bruce';
        cntct.LastName = 'Wayne';
        cntct.AccountId = acct.Id;
        insert cntct;

        Case cp = new Case();
        cp.Subject ='test';
        cp.Status = 'Assigned';
        insert cp;

        Case c = new Case();
        c.Subject ='test';
        c.Status = 'Assigned';
        insert c;

        Map<String,Object> obj = new Map<String,Object>();
        obj.put('disposition','disposition');
        obj.put('parentId',cp.Id);
        obj.put('field','softphone_it__Released_Time__c');
        obj.put('state','answered');
        obj.put('caseId',c.Id);
        obj.put('contactId',cntct.Id);
        obj.put('callTime',10);
        obj.put('interactionDuration',1);
        obj.put('totalAcdDuration',1);
        obj.put('totalIvrDuration',1);
        obj.put('dispositionDuration',1);
        softphone_it__ConnectorEventTimeLog__c record = new softphone_it__ConnectorEventTimeLog__c();
        record.softphone_it__Interaction_Id__c = '123';
        insert record;
        obj.put('interactionId','123');

        Test.startTest();
        boolean response =  ConnectorEntityController.updateConnectorEventTimeLog(obj);
        Test.stopTest();
        System.assertEquals(true, response);

    }   
    
    @isTest
    private static void testCustomActionNewTest(){
        Account acc= new Account();
        acc.RecordTypeId= SV_Utilities.getRecordTypeByDeveloperName('Account', 'PersonAccount');
        acc.LastName='test';
        acc.CRM_Phone1__c='3343018783';
        acc.CRM_NDG__c='123';
        acc.NDW_ExternalId__c = '123_123';
        insert acc;
        test.startTest();
        ConnectorEntityController.CustomActionRequestWrapper req= new ConnectorEntityController.CustomActionRequestWrapper();
        req.esigenza='ACCESSO_IB';
        req.autenticated='Cliente autenticato';
        req.phone='3343018783';
        req.ndgId='123';
        req.abi='123';
        ConnectorEntityController.CustomActionResponseWrapper response = ConnectorEntityController.customAction(req);
        test.stopTest();
        System.assertEquals(true, response != null);
    }
    
    @IsTest
    private static void updateExternalRoutingBean(){
        External_Routing_Bean__c b = new External_Routing_Bean__c();
        b.interaction_Id__c ='test';
        insert b;
        Test.startTest();
        ConnectorEntityController.updateExternalRoutingBean('test','test');
        Test.stopTest();

    }

    @IsTest
    private static void testFindEvent(){
        Event e = new Event();
        e.CC_ABI_NDG__c='123';
        e.DurationInMinutes=30;
        e.ActivityDateTime= Datetime.now();
        e.CRM_EventStatus__c='Non risponde 1';
        e.Subject='Incontro Preliminare';
        insert e;
        Test.startTest();
        ConnectorEntityController.findEvent(e.Id);
        Test.stopTest();

    }
       

}