@IsTest
public class OnEventTriggerHandlerTest {

    @isTest
    static void testBehaviour(){
        Case c1= new Case();
        c1.Origin='Web';
        c1.Subject='First';

        Case c2= new Case();
        c2.Origin='Web';
        c2.Subject='Second';

        Case c3= new Case();
        c3.Origin='Ufficio Reclami';
        c3.Subject='third';
        

        //insert new List<Case>{c1,c2,c3};
        Account a = new Account ();
        a.Name='TestName';
        insert a;

        Event e = new Event();
        e.whatId= c1.Id;
        e.DurationInMinutes=20;
        e.ActivityDateTime= Datetime.now();
        e.CRM_EventStatus__c='Non risponde 1';
        e.Subject='Incontro Preliminare';

        Event e1 = new Event();
        e1.whatId= c2.Id;
        e1.DurationInMinutes=20;
        e1.ActivityDateTime= Datetime.now();
        e1.CRM_EventStatus__c='Non risponde 1';
        e1.Subject='Incontro Preliminare';

        Test.startTest();
        insert e;
        insert e1;
        e.whatId=c2.Id;
        update e;
        e1.whatId=c3.Id;
        update e1;
        e1.whatId=c1.Id;
        update e1;

        delete e;
        Test.stopTest();
    }


    @isTest
    static void testCheckSlot() {

        Case c1= new Case();
        c1.Origin='Web';
        c1.Subject='First';
        
        Case c2= new Case();
        c2.Origin='Web';
        c2.Subject='Second';

        insert new List<Case>{c1,c2};
        
        Event e1 = new Event();
        e1.whatId= c2.Id;
        e1.DurationInMinutes=20;
        e1.ActivityDateTime= Datetime.now();
        e1.CRM_EventStatus__c='Non risponde 1';
        e1.Subject='Incontro Preliminare';
        
        insert e1;
        
        PA_Calendario__c pc= new PA_Calendario__c();
        pc.CC_NumMaxChiamate__c = '4';
        pc.CC_IdCalendario__c = e1.OwnerId;
        
        insert pc;
        
        GenesysSetting__c gs = new GenesysSetting__c();
        gs.Name = 'Presa Appuntamento';
        gs.CC_Limite_Max__c = 2;
        gs.CC_Minuti_Ricontatto__c = 30;
        
        insert gs;

        Test.startTest();
        Datetime result = OnEventTriggerHandler.checkSlot(e1);
        e1.whatId=c1.Id;
        update e1;
        Test.stopTest();
    }

    
     @isTest
    static void testAfterDelete() {
        
        Case c1= new Case();
        c1.Origin='Web';
        c1.Subject='First';
        
        Case c2= new Case();
        c2.Origin='Web';
        c2.Subject='Second';

        insert new List<Case>{c1,c2};
            
        List<Event> evs = new List<Event>();
        
        Event e = new Event();
        e.whatId= c1.Id;
        e.DurationInMinutes=20;
        e.ActivityDateTime= Datetime.now();
        e.CRM_EventStatus__c='Non risponde 1';
        e.Subject='Incontro Preliminare';
        evs.add(e);
        
        Event e1 = new Event();
        e1.whatId= c2.Id;
        e1.DurationInMinutes=20;
        e1.ActivityDateTime= Datetime.now();
        e1.CRM_EventStatus__c='Non risponde 1';
        e1.Subject='Incontro Preliminare';
        evs.add(e1);
        
        insert evs;
        
        PA_Calendario__c pc= new PA_Calendario__c();
        pc.CC_NumMaxChiamate__c = '4';
        pc.CC_IdCalendario__c = e1.OwnerId;
        
        insert pc;
        
        GenesysSetting__c gs = new GenesysSetting__c();
        gs.Name = 'Presa Appuntamento';
        gs.CC_Limite_Max__c = 2;
        gs.CC_Minuti_Ricontatto__c = 30;
        
        insert gs;

        Test.startTest();
        OnEventTriggerHandler.afterDelete(evs);
        Test.stopTest();
    }
    
     /* @isTest
    static void testAfterUpdate() {
        
        Case c = new Case();
        c.Subject ='test';
        c.Status = 'Closed';
        insert c;
        
        System.debug('GR TEST CASE ID: '+ c);
        
     	Case c1 = new Case();
        c1.Subject ='test1';
        c1.Status = 'Closed';
        insert c1;
        
        Case c2 = new Case();
        c2.Subject ='test2';
        c2.Status = 'Closed';
        insert c2;
        
       Event e = new Event();
        e.whatId= c.Id;
        e.DurationInMinutes=20;
        e.ActivityDateTime= Datetime.now();
        e.CRM_EventStatus__c='Non risponde 1';
        e.Subject='Incontro Preliminare';
        insert e;
        
        Event e1 = new Event();
        e1.whatId= c1.Id;
        e1.DurationInMinutes=20;
        e1.ActivityDateTime= Datetime.now();
        e1.CRM_EventStatus__c='Non risponde 1';
        e1.Subject='Incontro Preliminare';
        insert e1;

        e1.WhatId = c2.Id; 
        update e1;
       
        Test.startTest();
        OnEventTriggerHandler.afterUpdate(new List<Event>{e1}, new Map<Id, Event>{e.Id => e});
        Test.stopTest();
    }*/

    @isTest(SeeAllData=true)
    static void testGenesys(){
        Account a = new Account ();
        a.Name='TestName';
        a.NDW_ExternalId__c='123';
        a.CRM_SmartWebMobilePhone__c='33418122121';
        insert a;
        Calendar c=[SELECT Id FROM Calendar Where Type='Public' LIMIT 1];
        PA_Calendario__c pc= new PA_Calendario__c(CC_IdCalendario__c=c.Id,CC_IdCoda__c='123',CC_Prodotto__c='Carte di Credito',CC_NumMaxChiamate__c='3',CC_Priority__c ='100');
        insert pc;
        Id recTypeId=Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName().get('AppuntamentoCC').getRecordTypeId();
        Event e = new Event();
        e.CC_ABI_NDG__c='123';
        e.OwnerId=c.Id;
        e.DurationInMinutes=30;
        e.ActivityDateTime= Datetime.now();
        e.CRM_EventStatus__c='';
        e.RecordTypeId=recTypeId;
        e.Subject='Incontro Preliminare';

        Event e1 = new Event();
        e1.CC_Phone__c='33418122121';
        e1.OwnerId=c.Id;
        e1.DurationInMinutes=20;
        e1.ActivityDateTime= Datetime.now();
        e1.CRM_EventStatus__c='Non risponde 1';
        e1.RecordTypeId=recTypeId;
        e1.Subject='Incontro Preliminare';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        insert e;
        insert e1;
        e.CRM_EventStatus__c='Da Ricontattare';
        update e;
        e.CRM_EventStatus__c='Non risponde 1';
        //update e;
        Test.stopTest();
    }
}