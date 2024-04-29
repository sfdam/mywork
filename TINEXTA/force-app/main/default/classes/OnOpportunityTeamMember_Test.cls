@isTest

public class OnOpportunityTeamMember_Test {
    
    
    
   @isTest 
    static void testManualShareRead(){
        
        
         Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c = true;
        x.Bypass_Validation_Rules__c=true;
        X.Prevent_manage_Lead_DM_esterno_Innolva__c=false;
        insert x;


        
        User u = TestDataFActory.create_User(UserInfo.getProfileId());
        u.Societa__c= 'Warrant';
        u.Escludi_da_Convalida__c=true;
        
        

        User uu = TestDataFActory.create_User(UserInfo.getProfileId());
        uu.Societa__c= 'Warrant';
        uu.Escludi_da_Convalida__c=false;
        uu.Username='Test@user2.invalid';
        uu.CommunityNickname='User2';
        uu.Email='Test@user2.invalid';
        
        
        System.runAs ( new User(Id = UserInfo.getUserId()) ) {
   			
        	insert uu;
            insert u;
		}

        Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].Id;
        Id rtIdOpp = [SELECT Id from RecordType where Name = 'WRT CPQ' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        

        
        /*

        Lead l = new Lead(LastName = 'Test Lead',
                              FirstName = 'Test',
                              Company = 'Centidel',
                              Partiva_Iva__c = '92381047561', 
                              Codice_Fiscale__c = '92381047561',
                              Societa_di_riferimento__c ='Warrant',
                              Status='Nuovo Lead',
                              RecordTypeId = rid,
                              Origine_Lead_Livello_1__c='Segnalazione Partner',
                          	  Origine_Lead_Livello_2__c = 'Segnalazione',
        					  Data_Origine__c=system.today(),
                          	  Forma_giuridica__c = 'S.R.L.'
                              );*/


 test.startTest();        
        system.runAs(u) {

        //insert l;

       
            /*Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(l.id);
            lc.setDoNotCreateOpportunity(false);
            
            LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true order by id LIMIT 1];
            lc.setConvertedStatus('Convertito');                
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());

            Account[] acc = [SELECT Id FROM Account WHERE Id =: l.ConvertedAccountId ];*/
        

            Opportunity NOpportunity = new Opportunity(
                //AccountId=acc[0].id,
                Name = 'TestTeamMemeber',
                StageName='Potenziali',
                CloseDate=system.today()+100,
                RecordTypeId = rtIdOpp,
                WH_Business_Area__c= 'FA AUTOMATICA',
                OwnerId=u.Id);
            
            Insert NOpportunity;
            
            system.debug('Owner Opp' + NOpportunity.OwnerId);
            
            SBQQ__Quote__c q1 = new SBQQ__Quote__c(
                //SBQQ__Account__c=acc[0].id,
                RecordTypeId = rtIdQuote,
                SBQQ__Primary__c = true,
                WH_Business_Area__c = 'FA AUTOMATICA',
                OwnerId=u.Id,
                SBQQ__Opportunity2__c = NOpportunity.Id,
                Opportunity_Name__c= 'TestTeamMemeber'
            );
            
            insert q1;
            system.debug('Quote Owner'+ q1.OwnerId);
            
            NOpportunity.Quote_Creazione__c=q1.Id;
            update NOpportunity;
            
            system.debug('Owner Opp' + NOpportunity.OwnerId);
        }
        
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        
        system.runAs(u) {
            
		Opportunity Opp=[SELECT Id FROM Opportunity WHERE Name='TestTeamMemeber'];
            
            OpportunityTeamMember team = new OpportunityTeamMember(
                OpportunityId=Opp.id,
                UserId= uu.Id,
                OpportunityAccessLevel = 'Read',
                TeamMemberRole='Accounting');

            Insert team;
            Delete team;

           
        }
         test.stopTest();
    }
}