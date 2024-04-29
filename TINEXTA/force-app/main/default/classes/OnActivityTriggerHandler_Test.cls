@isTest
public class OnActivityTriggerHandler_Test {
     /* @testSetup static void setup() {
                            
        // Set<String> customerUserTypes = new Set<String> {'CSPLiteUser', 'PowerPartner', 'PowerCustomerSuccess',   'CustomerSuccess'};
        Id p = [SELECT Id FROM Profile WHERE Name='Innolva - Partner Community Sales'].Id;
        Id CMK_Profile = [SELECT Id FROM Profile WHERE Name = 'CoMark - Sales / Commerciali'].Id;
        Id WRT_Profile = [SELECT Id FROM Profile WHERE Name = 'Warrant Hub - System Administrator'].Id;
        User CMK_User = TestDataFactory.create_User(CMK_Profile);
        CMK_User.Societa__c = 'CoMark';
        insert CMK_User;
        User WRT_User = TestDataFactory.create_User(WRT_Profile);
        WRT_User.Username = 'testwarrant@invalid.i';
        WRT_User.CommunityNickname='WAR';
        WRT_User.Societa__c='Warrant';
        insert WRT_User;        
        
		
        // UserRole r = new UserRole(DeveloperName = 'AgenteTestUtentePartner', Name = 'Agente Test Utente Partner', PortalType = 'Partner');
        // insert r;

        
       
         User newUser = new User(
                Email = 'yourusername@gmail.com',
                UserName = 'yourusername1@gmail.com', 
                Alias = 'Test',
                profileid = p,
                IsActive =true,
                TimeZoneSidKey = 'America/New_York',
                EmailEncodingKey = 'ISO-8859-1',
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US',
                ContactId = '0031w000010NaF9AAK',
                PortalRole = 'Manager',
                FirstName = 'Firstname',
                LastName = 'Lastname',
                Societa__c = 'Innolva'
            );
       
        insert newUser;

        // User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ]
        
    }*/
    
	@isTest static void testValidateDelete(){
        
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = false;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
        User u = [SELECT Id FROM  User WHERE (Profile.Name = 'Innolva - Partner Community Sales' OR Profile.Name = 'Innolva - Sales Partner') AND IsActive = true LIMIT 1];

        System.runAs(u) {
            Account[] accY = TestDataFactory.create_Account();
            insert accY;     

            List<Task> tList = TestDataFactory.createTask(accY);
              System.debug('tList'+ tList);
         	insert tList;
            tList[0].Subject = 'Test3';
            update tList[0];
               List<Event> eList = TestDataFactory.createEvent(accY);
              System.debug('eList'+ eList);
         	insert eList;
             eList[0].Subject = 'Test4';
            update eList[0];

            Test.startTest();
            	Database.DeleteResult resultstsk = Database.delete(tList[0], true);
                Database.DeleteResult resultsevt = Database.delete(eList[0], true);             
        	Test.stopTest(); 
    	}
    }


    @isTest static void testAlignOutcome(){
        
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
        User CMK_Usr = [SELECT Id FROM  User WHERE Profile.Name = 'CoMark - Sales / Commerciali' AND IsActive = true LIMIT 1];
  
        System.runAs(CMK_Usr) {


            Account[] accY = TestDataFactory.create_Account();
            insert accY; 
            
            Opportunity[] oppCMK = TestDataFactory.createOpportunity(accY);
            oppCMK[0].Manager_Manager__c = CMK_Usr.Id;
        	oppCMK[0].Name = 'TestOppCMK';
        	oppCMK[0].StageName = 'Chiuse/Perse';
        	oppCMK[0].Esito_Comark__c = 'Non interessato';
        	oppCMK[0].Causale_Esito_Comark__c = 'Esperienza negativa';
        	oppCMK[0].Note_esito_comark__c = 'Test';
            oppCMK[0].Amount=1000;
            oppCMK[0].AccountId=accY[0].id;
            
            insert oppCMK;
            
            Contact cc = TestDataFactory.create_Contact();
            insert cc;
            

            
            List<Task> tList = TestDataFactory.createTask(accY);
              System.debug('tList'+ tList);
         	insert tList;
               List<Event> eList = TestDataFactory.createEvent(accY);
              System.debug('eList'+ eList);
         	insert eList;

            Id rid= [SELECT Id from RecordType where Name = 'CoMark' AND SObjectType = 'Lead' LIMIT 1].Id;
            Lead[] leadY = TestDataFactory.createLeads(1);
            leadY[0].Origine_Lead_Livello_1__c='Referenza';
            leadY[0].Origine_Lead_Livello_2__c='Referenza';
            leadY[0].Data_Origine__c=system.today();
            leadY[0].RecordTypeId=rid;
            //leadY[0].Stato_Segnalazione_Warrant__c='In lavorazione';
            leadY[0].AccountSegnalatore__c=null;
            insert leadY;
        	

            
            x.Disabilita_tutti_i_trigger__c=false;
        	update x;
            
            Event testEv = new Event(WhoId = cc.id,
                                     StartDateTime = Date.today(),
                                     EndDateTime = Date.today()+1);
            
            

            
             Event testEvA = new Event(WhatId = accY[0].id,
                                     StartDateTime = Date.today(),
                                     EndDateTime = Date.today()+1);
            
             Event testEvO = new Event(WhatId = oppCMK[0].id,
                                     StartDateTime = Date.today(),
                                     EndDateTime = Date.today()+1);
            
            
            

            Task testTask = new Task(WhoId = cc.Id,
                                    Status = 'In corso');
            
             Event testEvL = new Event(WhoId = leadY[0].id,
                                       Lead__c=leadY[0].id,
                                     StartDateTime = Date.today(),
                                     EndDateTime = Date.today()+1);
          
                  

            Test.startTest();
            insert testEv;
            insert testEvA;
            insert testTask;
            //insert testEvO;
            Test.stopTest();

            insert testEvL;
            	             
    	}
    }
    
    
    @isTest static void testAutomapWRT(){
        
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
        User WRT_Usr = [SELECT Id FROM  User WHERE Profile.Name = 'Warrant Hub - System Administrator' And IsActive = true LIMIT 1];

        System.runAs(WRT_Usr) {


            Account[] accY = TestDataFactory.create_Account();
            insert accY;  
            
            Contact con = TestDataFactory.create_Contact();
        	con.AccountId = accY[0].Id;
        	insert con;
            
            
            Referenza__c r= new Referenza__c(Azienda_Referenziata__c=accY[0].Id,
                                             Stato_Referenza__c='Non gestita'
            								);
            //insert r;
            
            //accY[0].Referenza__c=r.id;
            //accY[0].Stato_Referenza__c='Non gestita';
            //update accY;
            
            Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].Id;
            List<Lead> testLeads = TestDataFactory.createWarrantLeads(1,rid);
    
            testLeads[0].Societa_di_riferimento__c='Warrant';
            testLeads[0].LastName= 'Test';
            testLeads[0].Company = 'Test';
            testLeads[0].Origine_Lead_Livello_1__c='Segnalazione Partner';
            testLeads[0].Origine_Lead_Livello_2__c = 'Segnalazione';
            testLeads[0].Data_Origine__c=system.today();

        
        	insert testLeads;
            
            Referenza__c rl= new Referenza__c(Referenza_indicata_da_Lead__c=testLeads[0].Id,
                                             Stato_Referenza__c='Non gestita'
            								);
            //insert rl;
            
            //testLeads[0].Referenza__c=r.id;
            testLeads[0].Stato_Referenza__c='Non gestita';
            update testLeads;
            
            x.Disabilita_tutti_i_trigger__c=false;
        	update x;
            
            List<Task> tList = TestDataFactory.createTask(accY);
              System.debug('tList'+ tList);
            tList[0].WhoId=con.id;
         	insert tList;
               List<Event> eList = TestDataFactory.createEvent(accY);
              System.debug('eList'+ eList);
            eList[0].WhatId= accY[0].id;
            eList[0].Account__c= accY[0].id;
            //eList[0].WhoId = con.id;
         	insert eList;
            
             Event testEvL = new Event(WhoId = testLeads[0].id,
                                       Lead__c=testLeads[0].id,
                                     StartDateTime = Date.today(),
                                     EndDateTime = Date.today()+1);
            insert testEvL;


           
    	}
    }
    
    


}