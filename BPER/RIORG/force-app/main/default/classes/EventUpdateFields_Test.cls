@isTest
public with sharing class EventUpdateFields_Test {
    
    static testMethod void test() {
        
        
        Case c1= new Case();
        c1.Origin='Web';
        c1.Subject='First';

        Case c2= new Case();
        c2.Origin='Web';
        c2.Subject='Second';

        Case c3= new Case();
        c3.Origin='Ufficio Reclami';
        c3.Subject='third';
        

        insert new List<Case>{c1,c2,c3};
       
        
        Account acct2 = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358');
        insert acct2;
        
        Account filiale = AllDataFactory.getAccount('01', 'FilialeDiRelazione');
        insert filiale;

        ServiceAppointment servApp = new ServiceAppointment();
        servApp.Subject='Appuntamento call 1';
        servApp.SchedStartTime=Datetime.now();
        servApp.status='Programmato';
        servApp.ParentRecordId=acct2.id;
        insert servApp;
        
        Contact cntct2 = new Contact();
        cntct2.FirstName = 'Giuseppe';
        cntct2.LastName = 'Scopece';
        cntct2.AccountId = acct2.Id;
        insert cntct2;

        Campaign cmpgn = new Campaign();
		cmpgn.Name = 'Testcampaign';
		cmpgn.IsActive = TRUE;
        insert cmpgn;
        
        String profileId = [SELECT id FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].id;

        User testUser = AllDataFactory.getUser('1123', profileId, 'Family');
        insert testUser;
        
        CampaignMember cmpMember = new CampaignMember();
		cmpMember.ContactId = cntct2.Id; 
		cmpMember.CampaignId = cmpgn.Id;
        cmpMember.CRM_Assegnatario__c = testUser.id;
        cmpMember.CRM_StatoAssegnazione__c = 'Assegnato';
        cmpMember.CRM_ServiceAppointment__c = servApp.id;
        insert cmpMember;
        
        
        Product2 product = new Product2();
        product.name= 'Test';
        insert product;

        FinServ__FinancialAccount__c  finservFinAcc = new FinServ__FinancialAccount__c();
        finservFinAcc.Name='Test';
        finservFinAcc.FinServ__ProductName__c = product.Id;
        finservFinAcc.FinServ__PrimaryOwner__c=acct2.id;
        insert finservFinAcc;

        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Test';
        opportunity.StageName = 'Discovery';
        opportunity.CloseDate = Date.today().addDays(20);
        opportunity.AccountId = filiale.Id;
        opportunity.RecordTypeId=SV_Utilities.getRecordTypeByDeveloperName('Opportunity', 'WalletShareOpportunity');
        opportunity.FinServ__FinancialAccount__c =finservFinAcc.id;
        opportunity.Amount =100;
        opportunity.Probability=20;
        opportunity.Type='New Businnes';
        opportunity.LeadSource='Other';
        opportunity.NextStep='next';
        opportunity.Description='description';
        opportunity.CRM_Bisogno__c='Assicurativo';
        opportunity.CRM_Canale__c	='Check-up';
        opportunity.CRM_EsitoContatto__c='Da contattare';	
        opportunity.CRM_ServiceAppointment__c = servApp.id;
        opportunity.CRM_Oggetto__c = 'TEST';

        insert opportunity;
        
      
        
          Date today = Date.today();
            FinServ__Alert__c finServAlert = new FinServ__Alert__c();
            finServAlert.RecordTypeId=SV_Utilities.getRecordTypeByDeveloperName('FinServ__Alert__c', 'Scadenziario_Portafoglio');
            finServAlert.CRM_CED__c='123';
            finServAlert.FinServ__Account__c=acct2.id;
            finServAlert.CRM_TipoDocumento__c='MAV';
            finServAlert.FinServ__Message__c='Scadenza';
            finServAlert.CRM_DataScadenza__c=today;
            finServAlert.CRM_EsitoContatto__c='Da ricontattare';
            finServAlert.CRM_Importo__c=100;
            finServAlert.CRM_ServiceAppointment__c = servApp.id;
            //finServAlert.CRM_Prodotto__r.Name = product.name;
            finServAlert.CRM_Prodotto__c = product.id;
           // finServAlert.RecordType.DeveloperName= 'Scadenziario_Anticipi';
            insert finServAlert;
        
        
          
            FinServ__Alert__c finServAlert2 = new FinServ__Alert__c();
            finServAlert2.RecordTypeId=SV_Utilities.getRecordTypeByDeveloperName('FinServ__Alert__c', 'Scadenziario_Anticipi');
            finServAlert2.CRM_CED__c='123';
            finServAlert2.FinServ__Account__c=acct2.id;
            finServAlert2.CRM_TipoDocumento__c='MAV';
            finServAlert2.FinServ__Message__c='Scadenza';
            finServAlert2.CRM_DataScadenza__c=today;
            finServAlert2.CRM_EsitoContatto__c='Da ricontattare';
            finServAlert2.CRM_Importo__c=100;
        
            finServAlert2.CRM_ServiceAppointment__c = servApp.id;
            finServAlert2.CRM_Prodotto__c = product.id;
            insert finServAlert2;
        
        
            
             FinServ__Alert__c finServAlert3 = new FinServ__Alert__c();
            finServAlert3.RecordTypeId=SV_Utilities.getRecordTypeByDeveloperName('FinServ__Alert__c', 'Scadenziario_Prodotti');
            finServAlert3.CRM_CED__c='123';
            finServAlert2.FinServ__Account__c=acct2.id;
            finServAlert3.CRM_TipoDocumento__c='MAV';
            finServAlert3.FinServ__Message__c='Scadenza';
            finServAlert3.CRM_DataScadenza__c=today;
            finServAlert3.CRM_EsitoContatto__c='Da ricontattare';
            finServAlert3.CRM_Importo__c=100;
        
            finServAlert3.CRM_ServiceAppointment__c = servApp.id;
            finServAlert3.CRM_Prodotto__c = product.id;
            insert finServAlert3;
        
         CRM_CustomerInterview__c crm = new CRM_CustomerInterview__c();
            crm.Name='Test';
            crm.CRM_Customer__c=acct2.id;
            //crm.CRM_CreatedDate__c=todayDate;
            //crm.CRM_FormulaNumeroTagliando__c='Tagliando N. 1';
            //crm.CRM_Idx__c='4';
            //crm.CRM_Autore__c=acc.Name;
            crm.CRM_BankCreditNotes__c='test';
            crm.CRM_AttendeesLocation__c='test';
            crm.PTF_CustomerInterviewNum__c=1;
            crm.CRM_GenericNotes__c='Tagliando effettuato';
            crm.CRM_Join_Meeting__c='Private';
            crm.CRM_DataUltimaCompilazione__c=today;
            crm.RecordTypeId=SV_Utilities.getRecordTypeByDeveloperName('CRM_CustomerInterview__c', 'Chiuso');
            crm.CRM_AdministeredSaving__c='Interessato a nuovo prodotto/servizio';
            crm.CRM_ContactStatus__c = 'Tagliando effettuato';
            crm.CRM_ServiceAppointment__c = servApp.id;

            insert crm;
        
                
        
        Event e = new Event();
      //  e.whatId= [SELECT Id FROM Case WHERE Subject='First'][0].Id;
        e.DurationInMinutes=20;
        e.ActivityDateTime= Datetime.now();
        e.CRM_EventStatus__c='Non risponde 1';
        e.Subject='Incontro Preliminare';
        e.WhatId = servApp.id;

        Event e1 = new Event();
       // e1.whatId= [SELECT Id FROM Case WHERE Subject='Second'][0].Id;
        e1.DurationInMinutes=20;
        e1.ActivityDateTime= Datetime.now();
        e1.CRM_EventStatus__c='Non risponde 1';
        e1.Subject='Incontro Preliminare';
        e1.WhatId = servApp.id;
       // e1.ServiceAppointmentId = servApp.Id;

       
        insert e;
        insert e1;
       system.debug('Stanpo i due Eventi e il SP:'+ e.WhatId + ' ' +e1.WhatId +' ' +servApp.id);
        system.debug('stampo gli id dei due eventi ' + e.id + ' secondo evento ' + e1.id);
        
        List<Event> listEvent = new List<Event>();
        listEvent.add(e);
        listEvent.add(e1);
        
        Test.startTest();
        system.debug('Stanpo la lista degli Eventi:'+ listEvent);
        EventUpdateFields.updateEvent(listEvent);
        
        Test.stopTest();
    }



}