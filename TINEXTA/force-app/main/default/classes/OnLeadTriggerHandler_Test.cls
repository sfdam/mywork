@isTest
 public class OnLeadTriggerHandler_Test {
   /* @testSetup static void setup() {
        Id ridlead= [SELECT Id from RecordType where Name = 'Innolva' AND SObjectType = 'Lead' LIMIT 1].Id;
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Bypass_Validation_Rules__c=true;
        x.Disabilita_tutti_i_process_builder__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        List<Lead> testLeads = TestDataFactory.createLeads(1);
        testLeads[0].Societa_di_riferimento__c = 'Innolva';
        testLeads[0].Testo_societa_di_riferimento__c = 'Innolva';
        testLeads[0].Partiva_iva__c = '87627384034';
        testLeads[0].Codice_Fiscale__c = '87627384034';
        testLeads[0].RecordTypeId = ridlead;
        insert testLeads;
        
        List<Account> testAcc = TestDataFactory.createAccounts(1);
        testAcc[0].Societa_di_riferimento__c = 'Innolva';
        testAcc[0].Testo_societa_di_riferimento__c = 'Innolva';
        testAcc[0].Partita_iva__c = '87627384034';
        testAcc[0].Codice_Fiscale__c = '87627384034';
        insert testAcc;
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        delete x;
        
    }*/

    @TestSetup
    static void makeData(){
        string profil = [Select Id FROM Profile WHERE Name = 'Innolva - Sales Interno'].id;
        User u = TestDataFActory.create_User(profil);
        u.Username += '.test1';
        u.CommunityNickname += '1';
        u.Alias = 'a';
        u.Societa__c = 'Innolva';
        u.Tinexta__c = false;
       system.debug('User' + u);
        insert u;

        // User u5 = TestDataFActory.create_User(UserInfo.getProfileId());
        // u5.Username += '.test2';
        // u5.Societa__c= 'Warrant';
        // u5.CommunityNickname += '2';
        // u5.Alias = 'b';
        // u5.Escludi_da_Convalida__c=false;
        // u5.IsActive = true;
        // insert u5;

        User u2 = TestDataFActory.create_User(UserInfo.getProfileId());
        u2.Username += '.test3';
        u2.CommunityNickname += '3';
        u2.Alias = 'c';
        u2.Societa__c= 'Warrant';
        u2.Escludi_da_Convalida__c=true;
        
        insert u2;

        // string profil2 = [Select Id FROM Profile WHERE Name = 'Partner Comm Sales - Warrant'].id;
        // User u3 = TestDataFActory.create_User(profil2);
        // // u3.ContactId=cont.id;
        // u3.Username += '.test4';
        // u3.CommunityNickname += '4';
        // u3.Alias = 'd';
        // u3.Societa__c= 'Warrant';
        // insert u3;

        User u4 = TestDataFActory.create_User(UserInfo.getProfileId());
        u4.Societa__c= 'CoMark';
        u4.Username += '.test5';
        u4.CommunityNickname += '5';
        u4.Alias = 'f';
        u4.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = 'Gestione_e_Marketing'].Id;
        u4.Escludi_da_Convalida__c=true;
        
        insert u4;

    }
    
   @isTest static void testapproveRecord(){
       system.debug('TEST Approva Record');
       
        Funzionalita__c y= new Funzionalita__c();
        y.Disabilita_tutti_i_trigger__c=true;
        y.Bypass_Validation_Rules__c=true;
        y.Disabilita_tutti_i_process_builder__c=true;
        y.Disabilita_Integrazione__c = true;
        insert y;

        Id ridlead= [SELECT Id from RecordType where Name = 'Innolva' AND SObjectType = 'Lead' LIMIT 1].Id;
        DuplicateRule dR = [select id from DuplicateRule where DeveloperName = 'Tinexta_Lead_Duplicate_Rule' LIMIT 1];
        DuplicateRecordSet dupRS = new DuplicateRecordSet(DuplicateRuleId = dR.id);
        insert dupRS;
        
    //     string profil = [Select Id FROM Profile WHERE Name = 'Innolva - Sales Interno'].id;
    //     User u = TestDataFActory.create_User(profil);
    //     u.Societa__c = 'Innolva';
    //    system.debug('User' + u);
    //     insert u;
        
        List<Lead> testLeads = TestDataFactory.createLeadsInnolva(1);
        testLeads[0].Societa_di_riferimento__c = 'Innolva';
        testLeads[0].Testo_societa_di_riferimento__c = 'Innolva';
        testLeads[0].Partiva_iva__c = '87627384034';
        testLeads[0].Codice_Fiscale__c = '87627384034';
        testLeads[0].RecordTypeId = ridlead;
        System.debug('SV Leads: ' + testLeads);
        
        y.Disabilita_tutti_i_trigger__c=true;
        update y;
        
        User u = [SELECT Id FROM User WHERE Societa__c = 'Innolva' ORDER BY CreatedDate DESC LIMIT 1];
        system.runAs(u){
            Test.startTest();
            insert testLeads;
            Database.DMLOptions insertDML = new Database.DMLOptions(); 
            insertDML.DuplicateRuleHeader.AllowSave = true; 
            Database.SaveResult sr = Database.insert(testLeads[0], insertDML);
            DuplicateRecordItem dup = new DuplicateRecordItem(DuplicateRecordSetId = dupRS.id, RecordId=testLeads[0].Id);
            insert dup;
            System.debug('dup: '+dup);
            update dup;
            Test.stopTest();
        }
    }
    
    @isTest static void testLeadBloccato(){
         Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Bypass_Validation_Rules__c=true;
        x.Disabilita_tutti_i_process_builder__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
        Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].Id;
        List<Lead> testLeads = TestDataFactory.createWarrantLeads(1,rid);
        testLeads[0].Societa_di_riferimento__c='Warrant';
        testLeads[0].LastName= 'Test';
        testLeads[0].Company = 'Test';
        testLeads[0].Origine_Lead_Livello_1__c='Segnalazione Partner';
        testLeads[0].Origine_Lead_Livello_2__c = 'Segnalazione';
        testLeads[0].Data_Origine__c=system.today();
        
        insert testLeads;

        // User u = TestDataFActory.create_User(UserInfo.getProfileId());
        // u.Societa__c= 'Warrant';
        // u.Escludi_da_Convalida__c=true;
        
        // insert u;


        List<Account> acc= TestDataFactory.createAccounts(1);
        acc[0].Societa_su_CTM__c = 'Warrant';
        insert acc;
        
        
        System.debug('SV Leads: ' + testLeads);
        x.Disabilita_tutti_i_trigger__c=false;
        update x;

        User u = [SELECT Id FROM User WHERE Societa__c = 'Warrant' ORDER BY CreatedDate DESC LIMIT 1];
        system.runAs(u){
        testLeads[0].AccountSegnalatore__c=acc[0].Id;
        testLeads[0].Status = 'Fuori Funnel';
        update testLeads;
        }
        // testLeads[0] =  TestDataFactory.convertLeads(testLeads[0]);
        update testLeads[0];
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(testLeads, false);
        Test.stopTest();     
    }
    
    @isTest static void testLeadLavorazione(){
         Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Bypass_Validation_Rules__c=true;
        x.Disabilita_tutti_i_process_builder__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
        Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].Id;
        List<Lead> testLeads = TestDataFactory.createWarrantLeads(1,rid);

        testLeads[0].Societa_di_riferimento__c='Warrant';
        testLeads[0].LastName= 'Test';
        testLeads[0].Company = 'Test';
        testLeads[0].Origine_Lead_Livello_1__c='Segnalazione Partner';
        testLeads[0].Origine_Lead_Livello_2__c = 'Segnalazione';
        testLeads[0].Data_Origine__c=system.today();
        
        insert testLeads;

        // User u = TestDataFActory.create_User(UserInfo.getProfileId());
        // u.Societa__c= 'Warrant';
        // u.Escludi_da_Convalida__c=true;
        
        // insert u;


        List<Account> acc= TestDataFactory.createAccounts(1);
        acc[0].Societa_su_CTM__c = 'Warrant';
        insert acc;


        
        System.debug('SV Leads: ' + testLeads);
        x.Disabilita_tutti_i_trigger__c=false;
        update x;

        User u = [SELECT Id FROM User WHERE Societa__c = 'Warrant' ORDER BY CreatedDate DESC LIMIT 1];
        system.runAs(u){
        testLeads[0].AccountSegnalatore__c=acc[0].Id;
        testLeads[0].Status = 'Nuovo Lead';
        update testLeads;
        }        
        //  testLeads[0] =  TestDataFactory.convertLeads(testLeads[0]);
        update testLeads[0];  
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(testLeads, false);
        Test.stopTest();     
    }
    
    @isTest static void testLeadQualificato(){
         Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Bypass_Validation_Rules__c=true;
        x.Disabilita_tutti_i_process_builder__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
        Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].Id;
        List<Lead> testLeads = TestDataFactory.createWarrantLeads(1,rid);
        testLeads[0].Societa_di_riferimento__c='Warrant';
        testLeads[0].LastName= 'Test';
        testLeads[0].Company = 'TesNO';
        testLeads[0].Origine_Lead_Livello_1__c='Segnalazione Partner';
        testLeads[0].Origine_Lead_Livello_2__c = 'Segnalazione';
        testLeads[0].Data_Origine__c=system.today();
        
        insert testLeads;

        // User u = TestDataFActory.create_User(UserInfo.getProfileId());
        // u.Societa__c= 'Warrant';
        // u.Escludi_da_Convalida__c=true;
        
        // insert u;


        List<Account> acc= TestDataFactory.createAccounts(1);
        acc[0].Societa_su_CTM__c = 'Warrant';
        insert acc;
        
        System.debug('SV Leads: ' + testLeads);
        x.Disabilita_tutti_i_trigger__c=false;
        update x;

        User u = [SELECT Id FROM User WHERE Societa__c = 'Warrant' ORDER BY CreatedDate DESC LIMIT 1];

        system.runAs(u){
        testLeads[0].Status = 'Qualificato';
        update testLeads;
        }

        
        //testLeads[0] =  TestDataFactory.convertLeads(testLeads[0]);
        //update testLeads[0];  
        Test.startTest();
               // Database.LeadConvert lc = new Database.LeadConvert();
            //lc.setLeadId(testLeads[0].id);
            
            //LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true order by id LIMIT 1];
            //lc.setConvertedStatus('Convertito');                
            //Database.LeadConvertResult lcr = Database.convertLead(lc);
            //System.assert(lcr.isSuccess());
        //Database.DeleteResult[] results = Database.delete(testLeads, false);
        Test.stopTest();     
    }
    
    
    // @isTest static void testLeadError(){
    //      Funzionalita__c x= new Funzionalita__c();
    //     x.Disabilita_tutti_i_trigger__c=true;
    //     x.Bypass_Validation_Rules__c=true;
    //     x.Disabilita_tutti_i_process_builder__c=true;
    //     x.Disabilita_Integrazione__c = true;
    //     insert  x;
    //     List<Account> acc= TestDataFactory.createAccounts(1);
    //     acc[0].Societa_su_CTM__c = 'Warrant';
    //     insert acc;
        
    //     Contact cont = TestDataFactory.create_Contact();
    //     cont.AccountId=acc[0].Id;
    //     insert cont;
        
    //     Test.startTest();
    //         string profil = [Select Id FROM Profile WHERE Name = 'Partner Comm Sales - Warrant'].id;
    //         User u = TestDataFActory.create_User(profil);
    //         u.ContactId=cont.id;
    //         u.Societa__c= 'Warrant';
    //         insert u;
    //     Test.stopTest();
        
    //     // User u = [SELECT Id FROM User WHERE Profile.Name = 'Partner Comm Sales - Warrant' ORDER BY CreatedDate DESC LIMIT 1];

    //     Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].Id;
        
    //     List<Lead> testLeads = TestDataFactory.createWarrantLeads(1,rid);
    //     testLeads[0].OwnerId= u.Id;
    //     testLeads[0].Company='Company';
    //     testLeads[0].LastName='Company';
    //     x.Disabilita_tutti_i_trigger__c=false;
    //     update x;
    //     insert testLeads;

    //     // system.runAs(u) {
    //     //     // update testLeads[0]; 
    //     // }
    //     // Test.startTest();
    //     Database.DeleteResult[] results = Database.delete(testLeads, false);
    //     // Test.stopTest();     
    // }
 



    @isTest static void testLeadBloccatoCMK(){
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Bypass_Validation_Rules__c=true;
        x.Disabilita_tutti_i_process_builder__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
        
        List<Lead> testLeads = TestDataFactory.createLeadsCoMark(1);

        // User u = TestDataFActory.create_User(UserInfo.getProfileId());
        // u.Societa__c= 'CoMark';
        // u.Escludi_da_Convalida__c=true;
        
        // insert u;


        List<Account> acc= TestDataFactory.createAccounts(1);
        acc[0].Societa_su_CTM__c = 'CoMark';
        insert acc;
        
        
        
        
        System.debug('SV Leads: ' + testLeads);
        x.Disabilita_tutti_i_trigger__c=false;
        update x;

        User u = [SELECT Id FROM User WHERE Societa__c = 'CoMark' ORDER BY CreatedDate DESC LIMIT 1];

        system.runAs(u) {
        testLeads[0].Status = 'Fuori Funnel';
        testLeads[0].LastName= 'Test Account';
        testLeads[0].Company = 'Test Account';
        testLeads[0].AccountSegnalatore__c=acc[0].Id;
        insert testLeads;
        }
        
        // testLeads[0] =  TestDataFactory.convertLeads(testLeads[0]);
        update testLeads[0];
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(testLeads, false);
        Test.stopTest();     
    }


       @isTest static void testLeadQualificaCMK(){
         Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Bypass_Validation_Rules__c=true;
        x.Disabilita_tutti_i_process_builder__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
        
        List<Lead> testLeads = TestDataFactory.createLeadsCoMark(1);

        // User u = TestDataFActory.create_User(UserInfo.getProfileId());
        // u.Societa__c= 'CoMark';
        // u.Escludi_da_Convalida__c=true;
        
        // insert u;


        List<Account> acc= TestDataFactory.createAccounts(1);
        acc[0].Societa_su_CTM__c = 'CoMark';
        insert acc;
        
        
        
        
        System.debug('SV Leads: ' + testLeads);
        x.Disabilita_tutti_i_trigger__c=false;
        update x;

        User u = [SELECT Id FROM User WHERE Societa__c = 'CoMark' ORDER BY CreatedDate DESC LIMIT 1];

        system.runAs(u) {
        testLeads[0].Status = 'Contattato';
        testLeads[0].LastName= 'Test Account';
        testLeads[0].Company = 'Test Account';
        testLeads[0].AccountSegnalatore__c=acc[0].Id;
        insert testLeads;
        }
        
        // testLeads[0] =  TestDataFactory.convertLeads(testLeads[0]);
        update testLeads[0];
        Test.startTest();
        Database.DeleteResult[] results = Database.delete(testLeads, false);
        Test.stopTest();     
    }
     
     /*
      @isTest static void testLeadcopyConvertedLeadwRT(){
        
        Referenza__c r = new Referenza__c ();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Funzionalita__c y= new Funzionalita__c();
            y.Disabilita_tutti_i_trigger__c=true;
            y.Bypass_Validation_Rules__c=true;
            y.Disabilita_tutti_i_process_builder__c=true;
            y.Disabilita_Integrazione__c = true;
            insert y;
            
            // User u = TestDataFActory.create_User(UserInfo.getProfileId());
            // u.Societa__c= 'Warrant';
            // u.Escludi_da_Convalida__c=false;
            
            // insert u;
            
            // List<Account> acc= TestDataFactory.createAccounts(1);
            // acc[0].Societa_su_CTM__c = 'Warrant';
            // insert acc;
            // system.debug('Account' + acc );            
            

            // Lead l = new Lead(LastName = 'Test Lead',
            //                       FirstName = 'Test',
            //                       Company = 'Centidel',
            //                       Partiva_Iva__c = '92381047561', 
            //                       Codice_Fiscale__c = '92381047561',
            //                       Societa_di_riferimento__c ='Warrant',
            //                       Status='Nuovo Lead',
            //                       AccountSegnalatore__c=acc[0].Id,
            //                       RecordTypeId = rid,
            //                       Mail_personale_Warrant__c = 'test@test.com',
            //                       Origine_Lead_Livello_1__c='Segnalazione Partner',
            //                   	  Origine_Lead_Livello_2__c = 'Segnalazione',
            // 					  Data_Origine__c=system.today(),
            //                   	  Forma_giuridica__c = 'S.R.L.'
            //                       );
            

            r = new Referenza__c ( Stato_Referenza__c = 'Non gestita',
                                                Articolo_Referenza__c = 'Articolo',
                                                Business_Area__c = 'FAA',
                                                Data_Referenza__c = system.today(),
                                                Note_Referenza__c='Note',
                                                Oggetto_Referenza__c = 'Oggetto');


            y.Disabilita_tutti_i_trigger__c= false;  
            update  y; 
        }

        Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].Id;
        
        // User u = [SELECT Id FROM User WHERE Societa__c = 'Warrant' AND Escludi_da_convalida__c = false LIMIT 1];
        User u5 = TestDataFActory.create_User(UserInfo.getProfileId());
        u5.Username += '.test22';
        u5.Societa__c= 'Warrant';
        u5.CommunityNickname += '2';
        u5.Alias = 'z';
        u5.Escludi_da_Convalida__c=false;
        u5.IsActive = true;
        insert u5;

        system.runAs(u5) {
            List<Account> acc= TestDataFactory.createAccounts(1);
            acc[0].Societa_su_CTM__c = 'Warrant';
            acc[0].VIS_Numero_Iscritti__c = 1;
            insert acc;
            system.debug('Account' + acc );

            Lead l = new Lead(LastName = 'Test Lead',
            FirstName = 'Test',
            Company = 'Centidel',
            Partiva_Iva__c = '00001230000', 
            Codice_Fiscale__c = 'VLLSVT84D14Z112N',
            Societa_di_riferimento__c ='Warrant',
            Status='Nuovo Lead',
            AccountSegnalatore__c=acc[0].Id,
            RecordTypeId = rid,
            Mail_personale_Warrant__c = 'test@test.com',
            Origine_Lead_Livello_1__c='Segnalazione Partner',
              Origine_Lead_Livello_2__c = 'Segnalazione',
            Data_Origine__c=system.today(),
              Forma_giuridica__c = 'S.R.L.'
              
            );
        insert l;

		r.Referenza_indicata_da_Lead__c=l.id;
        insert r;
            system.debug('Referenza' + r);

        l.Referenza__c = r.id;
        update l;
               
          system.debug('Lead' + l);

            List<Segnalazioni__c> segn = TestDataFactory.create_segnalazionipartnerLead(l);
            segn[0].AccountSegnalatore__c = acc[0].id;
            insert segn;
            //testLeads[0].Numero_S__c= null;
            //update testLeads;
             test.startTest();
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(l.id);
            lc.setDoNotCreateOpportunity(false);
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true order by id LIMIT 1];
            lc.setConvertedStatus('Convertito');                
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
            test.stopTest();
        }
    }
    
     @isTest static void testLeadcopyConvertedLeadCMK(){
        
        Funzionalita__c y= new Funzionalita__c();
        y.Disabilita_tutti_i_trigger__c=true;
        y.Bypass_Validation_Rules__c=true;
        y.Disabilita_tutti_i_process_builder__c=true;
        y.Disabilita_Integrazione__c = true;
        insert y;
        
        // User u = TestDataFActory.create_User(UserInfo.getProfileId());
        // u.Societa__c= 'CoMark';
        // u.Escludi_da_Convalida__c=true;
        
        // insert u;
        
        List<Account> acc= TestDataFactory.createAccounts(1);
        acc[0].Societa_su_CTM__c = 'CoMark';
        acc[0].Coverage_Member_Infocert__c = false;
        insert acc;
        
        Id rid= [SELECT Id from RecordType where Name = 'CoMark' AND SObjectType = 'Lead' LIMIT 1].Id;
        
        List<Lead> testLeads = TestDataFactory.createWarrantLeads(1,rid);
        testLeads[0].Societa_di_riferimento__c='CoMark';

        Lead l = new Lead(LastName = 'Test Lead',
                              FirstName = 'Test',
                              Company = 'Centidel',
                              Partiva_Iva__c = '00001230000', 
                              Codice_Fiscale__c = '00001230000',
                              Societa_di_riferimento__c ='CoMark',
                              Status='Nuovo Lead',
                              AccountSegnalatore__c=acc[0].Id,
                              RecordTypeId = rid,
                              Mail_personale_Warrant__c = 'test@test.com'                          	  
                              );
        
         y.Disabilita_tutti_i_trigger__c= false;  
        update  y; 
        
        User u = [SELECT Id FROM User WHERE SOcieta__c = 'CoMark' ORDER BY CreatedDAte DESC LIMIT 1];
        system.runAs(u) {
               
            insert testLeads; 

            List<Segnalazioni__c> segn = TestDataFactory.create_segnalazionipartnerLead(testLeads[0]);
            segn[0].AccountSegnalatore__c = acc[0].id;
            insert segn;
            //testLeads[0].Numero_S__c= null;
            //update testLeads;
            

            test.startTest();
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(testLeads[0].id);
            lc.setDoNotCreateOpportunity(false);
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true order by id LIMIT 1];
            lc.setConvertedStatus('Convertito');                
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());
             test.stopTest();
        }}
     */
     
    // 
    // Lead myLead = new Lead(LastName = 'Fry', Company='Fry And Sons');
    
    /* @isTest static void testLeadduplicateInnolva(){
Funzionalita__c x= new Funzionalita__c();
x.Disabilita_tutti_i_trigger__c=true;
x.Disabilita_Integrazione__c = true;
insert x;


List<Account> acc= TestDataFactory.createAccounts(1);
insert acc;


List<Lead> testLeads = TestDataFactory.createLeadsInnolva(1);

// system.runAs(u) {
x.Disabilita_tutti_i_trigger__c= false;
update x; 

insert testLeads;   

/*  Database.LeadConvert lc = new Database.LeadConvert();
lc.setLeadId(testLeads[0].id);

LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
lc.setConvertedStatus('Convertito');                
Database.LeadConvertResult lcr = Database.convertLead(lc);*/
    // }}*/
    
     @isTest static void validation75(){
         OnLeadTriggerHandler.testRun();
     }
    
}