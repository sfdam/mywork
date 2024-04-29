@isTest
public class ART_BatchRefreshEvents_Test {
    
    @testSetup
    static void setup(){
        
              Account acc = new Account();
        acc.THR_AccountGroup__c='Generic Customers';
        acc.Name = 'TestAcctPharmaTest';
        acc.THR_VATNumber__c='VATTAP_000145';
        acc.THR_CustomerIdentificationCode__c='TAP_000156';
        acc.THR_AccountsKey__c = '1234ABCTest';
        acc.THR_MAIL__c='TestAcctPharmaedd@test.it';
        acc.BillingStreet='Via test, 33';
        acc.BillingPostalCode='00Test01';
        acc.BillingCity='Rome';
        acc.BillingState='Roma';
        acc.BillingStateCode='RM';
        acc.BillingCountry='Italy';
        acc.BillingCountryCode ='IT';
        acc.phone='06232323434';
        acc.Min_Event_Date__c = System.today()-60;
        System.debug('@' + acc.Min_Event_Date__c);
        insert acc;
          Account acc2 = new Account();
        acc2.THR_AccountGroup__c='Generic Customers';
        acc2.Name = 'TestAcctPharmaTesst';
        acc2.THR_VATNumber__c='VATTAP_000145';
        acc2.THR_CustomerIdentificationCode__c='TAP_000156';
        acc2.THR_AccountsKey__c = '1234ABCssTest';
        acc2.THR_MAIL__c='TestAcctPharmaedd@test.it';
        acc2.BillingStreet='Via test, 33';
        acc2.BillingPostalCode='00Test01';
        acc2.BillingCity='Rome';
        acc2.BillingState='Roma';
        acc2.BillingStateCode='RM';
        acc2.BillingCountry='Italy';
        acc2.BillingCountryCode ='IT';
        acc2.phone='06232323434';
        acc2.Min_Event_Date__c = Date.today() - 60;
        System.debug('@' + acc2.Min_Event_Date__c);
        insert acc2;
        Contact cntct = new Contact ();
        cntct.FirstName= 'NomeContatto';
        cntct.LastName='CognomeContatto';
        cntct.AccountId=acc.id;
        cntct.Email='nomeContatto@test.it';
        insert cntct;
		Contact cntct_2 = new Contact ();
        cntct_2.FirstName= 'NomeContatto';
        cntct_2.LastName='CognomeContatto';
        cntct_2.AccountId=acc2.id;
        cntct_2.Email='nomeContatto@test.it';
        insert cntct_2;
         List<Event> evtToInsert = new List<Event>();
        Event eventToDelay = new Event();
		eventToDelay.WhatId = acc.Id;
        eventToDelay.Trigger_Event__c = false;
        eventToDelay.StartDateTime = System.now() + 30;
        eventToDelay.DurationInMinutes = 2;
        eventToDelay.WhoId = cntct.Id;
        evtToInsert.add(eventToDelay);
        Event eventToDelay_sec = new Event();
		eventToDelay_sec.WhatId = acc.Id;
        eventToDelay_sec.Trigger_Event__c = false;
        eventToDelay_sec.StartDateTime = System.now() + 30;
		eventToDelay_sec.DurationInMinutes = 2;
		eventToDelay_sec.WhoId = cntct.Id;
		evtToInsert.add(eventToDelay_sec);
        Event eventToDelay_trd = new Event();
        eventToDelay_trd.WhatId = acc2.Id;
        eventToDelay_trd.Trigger_Event__c = false;
        eventToDelay_trd.StartDateTime = System.now() + 30;
		eventToDelay_trd.DurationInMinutes = 2;
		eventToDelay_trd.WhoId = cntct_2.Id;
		evtToInsert.add(eventToDelay_trd);
        insert evtToInsert;
        acc2.Min_Event_Date__c = System.today() -30;
        update acc2;
        
        
    }
    
    
    @isTest
    public static void launchBatch(){
		Test.startTest();  
        Database.executeBatch(new ART_BatchRefreshEvents(), 200);
        Test.stopTest();
    }
    
    

}