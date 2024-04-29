@isTest public class OnOpportunityTriggerHandler_Test {
    /*@testSetup static void setup() {
// Create common test accounts
Funzionalita__c x = new Funzionalita__c();
x.Disabilita_tutti_i_process_builder__c= true;
x.Disabilita_tutti_i_trigger__c = true;
x.Disabilita_Integrazione__c = true;
insert x;
Account[] acc = TestDataFactory.createAccounts(1);
insert acc;

Opportunity[] opp = TestDataFactory.createOpportunity(acc);
insert opp;
x.Disabilita_tutti_i_trigger__c = false;
update x;
delete x;

System.debug('RC Test : ');
}*/
    
    
    @isTest static void testAlignOutcome(){
        
        
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
        //Id CMK_Profile = [SELECT Id FROM Profile WHERE Name = 'CoMark - Sales / Commerciali'].Id;
        //User CMK_User = TestDataFactory.create_User(CMK_Profile);
        //CMK_User.Societa__c = 'CoMark';
        
        
        User CMK_Usr = [SELECT Id FROM  User WHERE Profile.Name = 'CoMark - Sales / Commerciali' AND IsActive= true LIMIT 1];
        // insert CMK_Usr;
        
        System.runAs(CMK_Usr) {
            
            Account[] acct = TestDataFactory.createAccounts(1);
            acct[0].Name = 'testCMKacc';
            acct[0].Societa_su_CTM__c = 'CoMark';
            insert acct;
            Opportunity[] oppCMK = TestDataFactory.createOpportunity(acct);
            oppCMK[0].Manager_Manager__c = CMK_Usr.Id;
            oppCMK[0].Name = 'TestOppCMK';
            oppCMK[0].StageName = 'Chiuse/Perse';
            oppCMK[0].Esito_Comark__c = 'Non interessato';
            oppCMK[0].Causale_Esito_Comark__c = 'Esperienza negativa';
            oppCMK[0].Note_esito_comark__c = 'Test';
            oppCMK[0].Amount=1000;
            x.Disabilita_tutti_i_trigger__c=false;
            update x;
            insert oppCMK;
            
            
        }
        
    }
    
    @isTest static void testOpportunity(){
        /*   Opportunity[] oppWRT = TestDataFactory.createOpportunity(acct);
oppWRT[0].WH_Business_Area__c='FAA';
insert oppWRT;


Test.startTest();
Database.DeleteResult results = Database.delete(oppt, true);
Test.stopTest(); */
    }
    
    
    @isTest static void testAlignInfoCert(){
        
        id rId = [SELECT Id FROM RecordType WHERE SobjectType = 'Opportunity' AND 	DeveloperName = 'InfoCert' ].Id;
        
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_Integrazione__c=true;
        x.Disabilita_tutti_i_trigger__c = true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
        Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_su_CTM__c = 'Testing';
        insert acc;
        
        x.Disabilita_tutti_i_trigger__c = false;
        update x;
        Opportunity[] opp = TestDataFactory.createOpportunity(acc);
        opp[0].INF_Nome_Trattativa__c = 'Test Trattativa';
        opp[0].RecordTypeId=rId;
        insert opp;
        
        opp[0].Amount = 1000;
        opp[0].StageName = 'Chiuse/Conseguite';
        opp[0].Fatturazione_cliente_finale__c = true;
        
        update opp;
        
    }
    
    
    
    @isTest static void testChangeOwner(){
        
        
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        x.Bypass_Validation_Rules__c = true;
        x.Disabilita_Integrazione__c = true;
        X.Prevent_manage_Lead_DM_esterno_Innolva__c=false;
        insert x;
        
        Id WRT_Profile = [SELECT Id FROM Profile WHERE Name = 'Warrant - Support Marketing Alliance'].Id;
        Id WRT_RoleId = [Select Id From UserRole WHERE DeveloperName ='Warrant_Sales_Support'].Id;
        User WRT_User = TestDataFactory.create_User(WRT_Profile);
        WRT_User.Societa__c = 'Warrant';
        WRT_User.UserRoleId = WRT_RoleId;
        WRT_User.CommunityNickname = 'TestWRTUser';
        WRT_User.Username = 'TestWRTUser@test.test'; 
        WRT_User.Escludi_da_Convalida__c=true;
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
            insert WRT_User;
        }
        
        Id rtIdOpp = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].id;
        
        //User WRT_User = [SELECT Id FROM  User WHERE IsActive = true AND Profile.Name = 'Warrant - Support Marketing Alliance' LIMIT 1];
        
        //Lead[] WRTlead = TestDataFactory.createLeads(1);
        //WRTlead[0].Societa_di_riferimento__c = 'Warrant';
        //WRTlead[0].OwnerId =WRT_User.Id;
        //WRTlead[0].Company = 'WarrantLead';
        //WRTlead[0].Data_Origine__c=system.today();
        //WRTlead[0].Origine_Lead_Livello_2__c='Test';
        //WRTlead[0].Origine_Lead_Livello_1__c='Segnalazione';
        //WRTlead[0].Forma_giuridica__c='Associazione';
        //WRTLead[0].Partiva_IVA__c = '04776090288';
        //WRTLead[0].Codice_Fiscale__c = '04776090288';
        //WRTLead[0].Censimento_manuale__c = true;
        //WRTlead[0].YOR_Cliente_Estero__c = true;
        
        Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Name = 'testacc';
        acc[0].Societa_su_CTM__c = 'Warrant';
        acc[0].Responsabile_WarrantHub__c = WRT_User.Id;
        insert acc;
        
        
        
        test.startTest();
        System.runAs(WRT_User){
            
            Lead[] WRTlead = TestDataFactory.createLeads(1);
            WRTlead[0].Societa_di_riferimento__c = 'Warrant';
            //WRTlead[0].OwnerId =WRT_User.Id;
            WRTlead[0].Company = 'WarrantLead';
            WRTlead[0].Data_Origine__c=system.today();
            WRTlead[0].Origine_Lead_Livello_2__c='Test';
            WRTlead[0].Origine_Lead_Livello_1__c='Segnalazione';
            WRTlead[0].Forma_giuridica__c='Associazione';
            WRTLead[0].Partiva_IVA__c = '04776090288';
            WRTLead[0].Codice_Fiscale__c = '04776090288';
            WRTLead[0].Censimento_manuale__c = true;
            WRTlead[0].YOR_Cliente_Estero__c = true;
            
            insert WRTlead;
            
            
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(WRTlead[0].id);
            lc.setDoNotCreateOpportunity(true);
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true order by id LIMIT 1];
            lc.setConvertedStatus('Convertito');
            System.debug('@@@ WRT_User ' + WRT_User.Escludi_da_convalida__c);            
            
            //Database.LeadConvertResult lcr = Database.convertLead(lc);
            //System.assert(lcr.isSuccess());
            
        }
        
        x.Disabilita_tutti_i_trigger__c = false;
        update x;
        
        
        System.runAs(WRT_User){
            
            //Account[] acct = [SELECT Id FROM Account WHERE Name = 'testacc']; //testacc
            Account[] acct = TestDataFactory.createAccounts(1);
            acct[0].Name = 'testacc';
            acct[0].Societa_su_CTM__c = 'Warrant';
            acct[0].Responsabile_WarrantHub__c = WRT_User.Id;
            insert acct;
            
            Opportunity oppWRT = new Opportunity(
                AccountId=acct[0].id,
                Name = 'TestTeamMemeber',
                StageName='Potenziali',
                CloseDate=system.today()+100,
                RecordTypeId = rtIdOpp,
                WH_Business_Area__c= 'FA AUTOMATICA'
            );
            insert oppWRT;
            delete oppWRT;
            
        }
        
        //Account[] accl = [SELECT Id FROM Account WHERE Name = 'WarrantLead' ];
        Account[] accl = TestDataFactory.createAccounts(1);
        accl[0].Name = 'testacc';
        accl[0].Societa_su_CTM__c = 'Warrant';
        accl[0].Responsabile_WarrantHub__c = WRT_User.Id;
        insert accl;
        
        Opportunity opp = new Opportunity(
            AccountId=accl[0].id,
            Name = 'TestTeamMemeber',
            StageName='Potenziali',
            CloseDate=system.today()+100,
            RecordTypeId = rtIdOpp,
            WH_Business_Area__c= 'FA AUTOMATICA'
        );
        
        insert opp;
        opp.AccountId = acc[0].Id;
        opp.StageName = 'Chiuse/Perse';
        update opp;
        
        test.stopTest();
        // WRTlead[0] = TestDataFactory.convertLeads(WRTlead[0]);
        
        //	Account[] acct = [SELECT Id FROM Account WHERE Id =: WRTlead[0].ConvertedAccountId ];
        
        
        //  Opportunity[] oppWRT = TestDataFactory.createOpportunity(acct);
        //  oppWRT[0].WH_Business_Area__c='FAA';
        //  insert oppWRT;
        //  oppWRT[0].StageName='Chiuse/Conseguite';
        //  delete oppWRT;
        
    }
    
    /*@isTest static void testWarrantOpp(){
User WRT_Usr = [SELECT Id FROM  User WHERE UserRole.Name = 'Warrant Sales Support'];
Funzionalita__c x = new Funzionalita__c();
x.Disabilita_tutti_i_process_builder__c= true;
x.Disabilita_tutti_i_trigger__c = true;
x.Bypass_Validation_Rules__c = true;
insert x;

System.runAs(WRT_Usr) {
Lead[] WRTlead = TestDataFactory.createLeads(1);
WRTlead[0].Societa_di_riferimento__c = 'Warrant';
insert WRTlead;
WRTlead[0] = TestDataFactory.convertLeads(WRTlead[0]);

Account[] acct = [SELECT Id FROM Account WHERE Id =: WRTlead[0].ConvertedAccountId ];
Opportunity[] oppWRT = TestDataFactory.createOpportunity(acct);
x.Disabilita_tutti_i_trigger__c=false;
update x;
insert oppWRT;
delete oppWRT;
}
}*/
    
    
    
}