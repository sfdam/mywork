@IsTest
public with sharing class OnCaseTriggerHandlerTest {
    @TestSetup
    static void setup(){

        Profile profile=[SELECT Id FROM Profile WHERE Name='Service Cloud User'];

        User oldOwner = new User();
        oldOwner.LastName='Old';
        oldOwner.ProfileId=profile.Id;
        oldOwner.TimeZoneSidKey='Europe/Rome';
        oldOwner.LocaleSidKey='it_IT';
        oldOwner.EmailEncodingKey='ISO-8859-1';
        oldOwner.LanguageLocaleKey ='it';
        oldOwner.Alias='Old';
        oldOwner.Email='old@fake.com';
        oldOwner.Username='old@fake.com';
        insert oldOwner;

        User newOwner = new User();
        newOwner.LastName='New';
        newOwner.ProfileId=profile.Id;
        newOwner.TimeZoneSidKey='Europe/Rome';
        newOwner.LocaleSidKey='it_IT';
        newOwner.EmailEncodingKey='ISO-8859-1';
        newOwner.LanguageLocaleKey ='it';
        newOwner.Alias='New';
        newOwner.Email='new@fake.com';
        newOwner.Username='new@fake.com';
        newOwner.CRM_Polo__c='';//alessandro di nardo @ten
        newOwner.CRM_Team__c='Modena';//alessandro di nardo @ten

        insert newOwner;

        User owner = new User();
        owner.LastName='TestCreateTeam';
        owner.ProfileId=profile.Id;
        owner.TimeZoneSidKey='Europe/Rome';
        owner.LocaleSidKey='it_IT';
        owner.EmailEncodingKey='ISO-8859-1';
        owner.LanguageLocaleKey ='it';
        owner.Alias='Test';
        owner.Email='test999@mail.com';
        owner.Username='new002@fake.com';
        insert owner;

        CaseTeamRole teamRole= new CaseTeamRole();
        teamRole.Name='testRole1';
        teamRole.AccessLevel='Edit';
        insert teamRole;

        CaseTeamTemplate oldTemplate = new CaseTeamTemplate();
        oldTemplate.Name='Old';
        insert oldTemplate;

        CaseTeamTemplate newTemplate = new CaseTeamTemplate();
        newTemplate.Name='New';
        insert newTemplate;

        CaseTeamTemplate teamTemplate = new CaseTeamTemplate();
        teamTemplate.Name='testTeam';
        insert teamTemplate;

        CaseTeamTemplateMember oldMember= new CaseTeamTemplateMember();
        oldMember.TeamRoleId=teamRole.Id;
        oldMember.TeamTemplateId=oldTemplate.Id;
        oldMember.MemberId=oldOwner.Id;
        insert oldMember;

        CaseTeamTemplateMember newMember= new CaseTeamTemplateMember();
        newMember.TeamRoleId=teamRole.Id;
        newMember.TeamTemplateId=newTemplate.Id;
        newMember.MemberId=newOwner.Id;
        insert newMember;

        CaseTeamTemplateMember member= new CaseTeamTemplateMember();
        member.TeamRoleId=teamRole.Id;
        member.TeamTemplateId=teamTemplate.Id;
        member.MemberId=owner.Id;
        insert member;

       
        
    }

    //alessandro di nardo @ten
    @isTest
    static void testIsChildUpdate(){

        List<Case> listCase = new List<Case>();
        Case parent= new Case();
        parent.Origin='Web';
        parent.Subject='Parent';
        parent.CRM_Area__c='Digital Services';
        //parent.CRM_Scope__c='Internet Banking';
        parent.CRM_Level1__c='Accesso e navigazione IB';
        parent.CRM_Level2__c='Credenziali IB';
        parent.CRM_Level3__c='User';
        parent.CRM_Scope__c='Internet Banking';
        parent.CRM_DigitalServices__c='Smart Web NPM';
        parent.CRM_TicketBhelp__c='TicketBhelp';
        parent.CRM_Hesitation__c='Ticket';
        listCase.add(parent);

        insert listCase;
        

        Case newCase = new Case();
        newCase.ParentId=listCase[0].Id;
        newCase.Subject='Child';
        newCase.Origin='Web';
        newCase.Status='Assegnato';
        newCase.CRM_Area__c='Digital Services';
        newCase.CRM_Level1__c='Accesso e navigazione IB';
        newCase.CRM_Level2__c='Credenziali IB';
        newCase.CRM_Level3__c='User';
        newCase.CRM_Scope__c='Internet Banking';
        newCase.CRM_DigitalServices__c='Smart Web NPM';
        insert newCase;

        parent.CRM_Area__c='Digital Services';
        parent.CRM_Scope__c='Area riservata e Smart BPERCard';
        parent.CRM_Level1__c='Accesso e navigazione';
        parent.CRM_Level2__c='Credenziali';
        parent.CRM_Level3__c='Password';
        parent.CRM_Scope__c='Area riservata e Smart BPERCard';
        parent.CRM_DigitalServices__c='Area riservata';
        parent.CRM_TicketBhelp__c='TicketBhelp';
        parent.CRM_Hesitation__c='Ticket';
        //update parent;
       
        Map<Id,Case> oldMap = new Map<Id,Case>();
        oldMap.put(parent.id,parent);


        Test.startTest();
        OnCaseTriggerHandler.isChildUpdate(listCase,oldMap,false);
        Test.stopTest();

    }

    @isTest
    static void testChildParent(){
        /*alessandro di nardo @ten 25/05/2023
        Case parent= new Case();
        parent.Origin='Web';
        parent.Subject='Parent';
        parent.CRM_Area__c='Digital Services';
        parent.CRM_Scope__c='Internet Banking';
        parent.CRM_Level1__c='Accesso e navigazione IB';
        parent.CRM_Level2__c='Credenziali IB';
        parent.CRM_Level3__c='User';
        parent.CRM_DigitalServices__c='Smart Web NPM';
        parent.CRM_TicketBhelp__c='TicketBhelp';
        parent.CRM_Hesitation__c='Ticket';

        insert parent;
        
        Case child = new Case();
        child.ParentId=parent.Id;
        child.Subject='Child';
        child.Origin='Web';
        Test.startTest();
        insert child;

        parent.CRM_Area__c='Digital Services';
        parent.CRM_Scope__c='Area riservata e Smart BPERCard';
        parent.CRM_Level1__c='Accesso e navigazione';
        parent.CRM_Level2__c='Credenziali';
        parent.CRM_Level3__c='Password';
        parent.CRM_DigitalServices__c='Area riservata';
        parent.CRM_TicketBhelp__c='TicketBhelp';
        parent.CRM_Hesitation__c='Ticket';
        update parent;
        Test.stopTest();*/
        
        Case parent= new Case();
        parent.Origin='Web';
        parent.Subject='Parent';
        parent.CRM_Area__c='Digital Services';
        //parent.CRM_Scope__c='Internet Banking';
        parent.CRM_Level1__c='Accesso e navigazione IB';
        parent.CRM_Level2__c='Credenziali IB';
        parent.CRM_Level3__c='User';
        parent.CRM_Scope__c='Internet Banking';
        parent.CRM_DigitalServices__c='Smart Web NPM';
        parent.CRM_TicketBhelp__c='TicketBhelp';
        parent.CRM_Hesitation__c='Ticket';
        
        insert parent;
        
        Case child = new Case();
        child.ParentId=parent.Id;
        child.Subject='Child';
        child.Origin='Web';
        child.Status='Assegnato';
        child.CRM_Area__c='Digital Services';
        child.CRM_Level1__c='Accesso e navigazione IB';
        child.CRM_Level2__c='Credenziali IB';
        child.CRM_Level3__c='User';
        child.CRM_Scope__c='Internet Banking';
        child.CRM_DigitalServices__c='Smart Web NPM';
        Test.startTest();
        insert child;
        
        parent.CRM_Area__c='Digital Services';
        parent.CRM_Scope__c='Area riservata e Smart BPERCard';
        parent.CRM_Level1__c='Accesso e navigazione';
        parent.CRM_Level2__c='Credenziali';
        parent.CRM_Level3__c='Password';
        parent.CRM_Scope__c='Area riservata e Smart BPERCard';
        parent.CRM_DigitalServices__c='Area riservata';
        parent.CRM_TicketBhelp__c='TicketBhelp';
        parent.CRM_Hesitation__c='Ticket';
        
        update parent;
        Test.stopTest();
    }
    //alessandro di nardo @ten 25/05/2023
    @isTest 
    static void testSwitchOwnerTeam(){
        
        User oldOwner=[SELECT Id FROM User WHERE Name='Old'];
        User newOwner=[SELECT Id FROM User WHERE Name='New'];
        List<Case> listCase = new List<Case>();
        Case parent= new Case();
        parent.Origin='Web';
        parent.Subject='Parent';
        parent.CRM_Area__c='Digital Services';
        //parent.CRM_Scope__c='Internet Banking';
        parent.CRM_Level1__c='Accesso e navigazione IB';
        parent.CRM_Level2__c='Credenziali IB';
        parent.CRM_Level3__c='User';
        parent.CRM_Scope__c='Internet Banking';
        parent.CRM_DigitalServices__c='Smart Web NPM';
        parent.CRM_TicketBhelp__c='TicketBhelp';
        parent.CRM_Hesitation__c='Ticket';
        parent.OwnerId=oldOwner.Id;

        listCase.add(parent);

        insert listCase;
        

        Case newCase = new Case();
        newCase.ParentId=listCase[0].Id;
        newCase.Subject='Child';
        newCase.Origin='Web';
        newCase.Status='Assegnato';
        newCase.CRM_Area__c='Digital Services';
        newCase.CRM_Level1__c='Accesso e navigazione IB';
        newCase.CRM_Level2__c='Credenziali IB';
        newCase.CRM_Level3__c='User';
        newCase.CRM_Scope__c='Internet Banking';
        newCase.CRM_DigitalServices__c='Smart Web NPM';
        newCase.OwnerId=newOwner.Id;
        newCase.CRM_OwnerPolo__c='';
        newCase.CRM_OwnerTeam__c='';

        insert newCase;



        Map<Id,Case> newMap = new Map<Id,Case>();
        newMap.put(parent.id,parent);
        //newMap.put(newCase.id,newCase);


        parent.CRM_Area__c='Digital Services';
        parent.CRM_Scope__c='Area riservata e Smart BPERCard';
        parent.CRM_Level1__c='Accesso e navigazione';
        parent.CRM_Level2__c='Credenziali';
        parent.CRM_Level3__c='Password';
        parent.CRM_Scope__c='Area riservata e Smart BPERCard';
        parent.CRM_DigitalServices__c='Area riservata';
        parent.CRM_TicketBhelp__c='TicketBhelp';
        parent.CRM_Hesitation__c='Ticket';
        //update parent;
       
        Map<Id,Case> oldMap = new Map<Id,Case>();
        oldMap.put(parent.id,parent);

        //controllo casistica :
        //if(oldMap.get(c.Id).OwnerId!=c.OwnerId && (oldOwner.startsWith('005') || newOwner.startsWith('005')) && userMap.containsKey(c.OwnerId)){
        System.debug('oldOwner parent.OwnerId : ' + parent.OwnerId);
        System.debug('newOwner newCase.OwnerId : ' + newCase.OwnerId);
        
        Set<String> ownerIdSet = SV_Utilities.keyBy(newMap.values(), 'OwnerId').keySet();
        Map<String, SObject> userMap = SV_Utilities.keyBy([SELECT Id, CRM_Team__c, CRM_Polo__c  FROM User WHERE Id = :ownerIdSet], 'Id') ;
        for(Case c: newMap.values() ){
            System.debug('Case c : ' + c);
            System.debug('Case userMap.containsKey : ' + userMap.containsKey(c.OwnerId));
        }
        

        Test.startTest();
        OnCaseTriggerHandler.switchOwnerTeam(newMap,oldMap);
        Test.stopTest();
    }

    //alessandro di nardo @ten 25/05/2023
    @isTest 
    static void testSetOwnerTeamPolo(){

        User newOwner=[SELECT Id FROM User WHERE Name='New'];
        List<Case> listCase = new List<Case>();
        Case parent= new Case();
        parent.Origin='Web';
        parent.Subject='Parent';
        parent.CRM_Area__c='Digital Services';
        //parent.CRM_Scope__c='Internet Banking';
        parent.CRM_Level1__c='Accesso e navigazione IB';
        parent.CRM_Level2__c='Credenziali IB';
        parent.CRM_Level3__c='User';
        parent.CRM_Scope__c='Internet Banking';
        parent.CRM_DigitalServices__c='Smart Web NPM';
        parent.CRM_TicketBhelp__c='TicketBhelp';
        parent.CRM_Hesitation__c='Ticket';
        parent.OwnerId=newOwner.Id;

        listCase.add(parent);

        insert listCase;
        

        Case newCase = new Case();
        newCase.ParentId=listCase[0].Id;
        newCase.Subject='Child';
        newCase.Origin='Web';
        newCase.Status='Assegnato';
        newCase.CRM_Area__c='Digital Services';
        newCase.CRM_Level1__c='Accesso e navigazione IB';
        newCase.CRM_Level2__c='Credenziali IB';
        newCase.CRM_Level3__c='User';
        newCase.CRM_Scope__c='Internet Banking';
        newCase.CRM_DigitalServices__c='Smart Web NPM';
        newCase.OwnerId=newOwner.Id;
        insert newCase;

        System.debug('newCase OwnerId ' + newCase.OwnerId);

        parent.CRM_Area__c='Digital Services';
        parent.CRM_Scope__c='Area riservata e Smart BPERCard';
        parent.CRM_Level1__c='Accesso e navigazione';
        parent.CRM_Level2__c='Credenziali';
        parent.CRM_Level3__c='Password';
        parent.CRM_Scope__c='Area riservata e Smart BPERCard';
        parent.CRM_DigitalServices__c='Area riservata';
        parent.CRM_TicketBhelp__c='TicketBhelp';
        parent.CRM_Hesitation__c='Ticket';
        //update parent;
       
        Map<Id,Case> oldMap = new Map<Id,Case>();
        oldMap.put(parent.id,parent);


        Test.startTest();
        OnCaseTriggerHandler.setOwnerTeamPolo(listCase,oldMap);
        Test.stopTest();

    }

    //alessandro di nardo @ten
    /* 
    @isTest
    static void testSendRequest(){
        User newOwner=[SELECT Id FROM User WHERE Name='New'];
        List<Case> listCase = new List<Case>();
        Case parent= new Case();
        parent.Origin='Web';
        parent.Subject='Parent';
        parent.CRM_Area__c='Digital Services';
        //parent.CRM_Scope__c='Internet Banking';
        parent.CRM_Level1__c='Accesso e navigazione IB';
        parent.CRM_Level2__c='Credenziali IB';
        parent.CRM_Level3__c='User';
        parent.CRM_Scope__c='Internet Banking';
        parent.CRM_DigitalServices__c='Smart Web NPM';
        parent.CRM_TicketBhelp__c='TicketBhelp';
        parent.CRM_Hesitation__c='Ticket';
        parent.OwnerId=newOwner.Id;

        insert parent;

        Test.startTest();
        OnCaseTriggerHandler.sendRequest(parent.id);
        Test.stopTest();
    }*/
    @isTest
    static void testCreateSwitchTeam(){
       
       Test.startTest();
       User oldOwner=[SELECT Id FROM User WHERE Name='Old'];
       User newOwner=[SELECT Id FROM User WHERE Name='Old'];
        Case c = new Case();
        c.Origin='Web';
       insert c;
       c.OwnerId=oldOwner.Id;
       update c;
       c.OwnerId=newOwner.Id;
       Test.stopTest();


    }
    @isTest
    static void testCheckProductRole(){
        try{
            Test.startTest();
            Account a = new Account();
            a.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            a.FirstName='test';
            a.LastName='test';
            insert a;

            FinServ__FinancialAccount__c prod= new FinServ__FinancialAccount__c();
            prod.RecordTypeId=Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('CreditCard').getRecordTypeId();
            prod.Name='test';
            prod.FinServ__Status__c='Active';
            prod.FinServ__PrimaryOwner__c=a.Id;
            insert prod;
            
            
            Case c= new Case();
            c.Origin='Web';
            c.FinServ__FinancialAccount__c=prod.Id;
            insert c;
            Test.stopTest();
        }
        catch(Exception e){

        }
    }
    @isTest
    static void testCheckProductRoleUpdate(){
        try{
            Test.startTest();
            Account a = new Account();
            a.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            a.FirstName='test';
            a.LastName='test';
            insert a;

            Account a2 = new Account();
            a2.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            a2.FirstName='test2';
            a2.LastName='test2';
            insert a2;

            FinServ__FinancialAccount__c prod= new FinServ__FinancialAccount__c();
            prod.RecordTypeId=Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('CreditCard').getRecordTypeId();
            prod.Name='test';
            prod.FinServ__Status__c='Active';
            prod.FinServ__PrimaryOwner__c=a.Id;
            insert prod;
            
            FinServ__FinancialAccount__c prod2= new FinServ__FinancialAccount__c();
            prod2.RecordTypeId=Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName().get('CreditCard').getRecordTypeId();
            prod2.Name='test';
            prod2.FinServ__Status__c='Active';
            prod2.FinServ__PrimaryOwner__c=a2.Id;
            insert prod2;

            FinServ__FinancialAccountRole__c role = new FinServ__FinancialAccountRole__c();
            role.FinServ__FinancialAccount__c= prod.Id;
            role.FinServ__RelatedAccount__c=a.Id;
            role.FinServ__Role__c='Primary Owner';
            insert role;
            Case c= new Case();
            c.Origin='Web';
            c.AccountId=a.Id;
            c.FinServ__FinancialAccount__c=prod.Id;
            insert c;

            c.FinServ__FinancialAccount__c=prod2.Id;
            update c;
            Test.stopTest();
        }
        catch(Exception e){

        }
    }
    @isTest 
    static void testCustomValidation(){
        Case c = new Case();
        c.Origin='Web';
        insert c;
        try{
            c.CRM_Area__c='Digital Services';
            c.CRM_Scope__c='Internet Banking';
            c.CRM_Hesitation__c='Ticket';
            OnCaseTriggerHandler.skipCustomValidation=false;
            System.runAs([SELECT Id FROM User WHERE Username='old@fake.com' LIMIT 1][0]){
                update c;
            }
        }
        catch(Exception e){

        }
    }
    @isTest
    static void testDelete(){
        Case c = new Case();
        c.Origin='Web';
        insert c;
        delete c;  
    }

    @isTest
    static void testCreateCaseTeam(){
        Test.startTest();
        User Owner=[SELECT Id FROM User WHERE LastName='TestCreateTeam'];

        User oldOwner=[SELECT Id FROM User WHERE Name='Old'];
        User newOwner=[SELECT Id FROM User WHERE Name='Old'];
        Case c = new Case();
        c.Origin='Web';
        insert c;
        c.OwnerId=oldOwner.Id;
        
        List<Case> listCases = new List<Case>();
        listCases.add(c);
        
        Case c3 = new Case();
        Map<Id,Case> oldMap = new Map<Id,Case>();
        oldMap.put(c3.id,c3);
        OnCaseTriggerHandler.createCaseTeam(listCases,oldMap);
        Test.stopTest();
    }

    @isTest
    static void testChatCase1(){
            Test.startTest();
            Account a = new Account();
            a.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            a.FirstName='test';
            a.LastName='test';
            insert a;
            
            
            Case c= new Case();
            c.Origin='Web';
            c.CRM_CasefromNewPrechatForm__c = 'SI';
            c.CRM_CryptoString__c = 'test';
            insert c;

            Test.stopTest();
    }

    @isTest
    static void testChatCase2(){
        ParametriEncryption__c cs = new ParametriEncryption__c();
        cs.ExampleIv__c = 'encryptionIntVec'; 
        cs.Key__c ='aesEncryptionKey'; 
        insert cs;

        Test.startTest();
        Account a = new Account();
        a.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        a.FirstName='testChat';
        a.LastName='test';
        a.CRM_StringBirthDate__c='01/01/2000';
        a.CRM_Cellulare_aziendale_Bpercard__c = '+393334567890';
        insert a;            
        
        Case c2= new Case();
        c2.Origin='Web';
        c2.CRM_CasefromNewPrechatForm__c = 'SI';
        c2.CRM_CodiceFiscalePartitaIva__c = 'test';
        c2.CRM_WebChannelName__c = 'testChat test';
        c2.Data_di_nascita__c = '01/01/2000';
        insert c2;

        Case c3= new Case();
        c3.Origin='Whatsapp';
        c3.CRM_TelefonoWhatsApp__c = '+393334567890';
        insert c3;
        Test.stopTest();

    }

    @isTest
    static void testChatCase3(){
        ParametriEncryption__c cs = new ParametriEncryption__c();
        cs.ExampleIv__c = 'encryptionIntVec'; 
        cs.Key__c ='aesEncryptionKey'; 
        insert cs;

        Test.startTest();
        Account a = new Account();
        a.RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        a.FirstName='testChat';
        a.LastName='test';
        a.CRM_StringBirthDate__c='01/01/2000';
        a.CRM_Cellulare_aziendale_Bpercard__c = '3334567890';
        a.Phone = '3334567890';
        insert a;    
        
        Id [] fixedSearchResults= new Id[1];
        fixedSearchResults[0] = a.Id;
        Test.setFixedSearchResults(fixedSearchResults);
    
        
        Case c2= new Case();
        c2.Origin='Web';
        c2.CRM_CasefromNewPrechatForm__c = 'SI';
        c2.CRM_CodiceFiscalePartitaIva__c = 'test';
        c2.CRM_WebChannelName__c = 'testChat test';
        c2.Data_di_nascita__c = '01/01/2000';
        insert c2;

        Case c3= new Case();
        c3.Origin='Whatsapp';
        c3.CRM_TelefonoWhatsApp__c = '3334567890';
        insert c3;
        Test.stopTest();

    }



}