@isTest

private class OnQuoteShare_Test {
   // Test for the manualShareRead method
   static testMethod void testManualShareRead(){
      // Select users for the test.
      Id User1Id = [SELECT Id FROM User WHERE IsActive = true AND LastName= 'Catellani'].Id;
      Id User2Id = [SELECT Id FROM User WHERE IsActive = true AND LastName = 'Beriotto'].Id;
      Id User3Id = [SELECT Id FROM User WHERE IsActive = true AND LastName = 'Sberveglieri'].Id;
      
      //Id User1Id = users[0].Id;
      //Id User2Id = users[1].Id;
   

        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c = true;
        insert x;
        
         
        Id rtIdOpp = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        Id rtIdQLine = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__QuoteLine__c' LIMIT 1].id;
        
        
         Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant';
        insert acc;
       
        Opportunity NOpportunity = new Opportunity(
            								AccountId=acc[0].id,
           								 	Name = 'Test',
            								StageName='Potenziali',
            								CloseDate=system.today()+100,
                                      		RecordTypeId = rtIdOpp);
        
        Insert NOpportunity;
       
       OpportunityTeamMember team = new OpportunityTeamMember(
       										OpportunityId=NOpportunity.id,
       										UserId= User2Id,
       										OpportunityAccessLevel = 'Read',
       										TeamMemberRole='Accounting');
       
       Insert team;
       
       
       
       OpportunityTeamMember teamextra = new OpportunityTeamMember(
       										OpportunityId=NOpportunity.id,
       										UserId= User3Id,
       										OpportunityAccessLevel = 'Read',
       										TeamMemberRole='Accounting');
       
       Insert teamextra;
       
       x.Disabilita_tutti_i_trigger__c=false;
       update x;
       
       
        
         SBQQ__Quote__c q1 = new SBQQ__Quote__c(
            							SBQQ__Account__c=acc[0].id,
                                      	RecordTypeId = rtIdQuote,
                                      	SBQQ__Primary__c = true,
                                        WH_Business_Area__c = 'FAA',
         								OwnerId=User1Id,
         								SBQQ__Opportunity2__c = NOpportunity.Id);
       
       
       
         SBQQ__Quote__c q2 = new SBQQ__Quote__c(
            							SBQQ__Account__c=acc[0].id,
                                      	RecordTypeId = rtIdQuote,
                                      	SBQQ__Primary__c = true,
                                        WH_Business_Area__c = 'FAA',
         								OwnerId=User1Id);
      
      insert q1;
      insert q2;
       
       
       NOpportunity.Quote_Creazione__c=q1.Id;
       update NOpportunity;
       
     List<SBQQ__Quote__c> j= new List<SBQQ__Quote__c>();
     
     j.add(q1);
       
     List<User> u = [SELECT Id FROM User WHERE IsActive = true AND LastName = 'Sberveglieri'];
       
     
 
       
       
       boolean fin=false;
       boolean del=false;
      // Insert manual share for user who is not record owner.
      fin=OnQuoteShare.manualShareRead(j);
      del=OnQuoteShare.manualShareDelete(j,u);
   
      // Query job sharing records.
     // List<SBQQ__Quote__Share> jShrs = [SELECT Id, UserOrGroupId, AccessLevel, 
       //  RowCause FROM SBQQ__Quote__Share WHERE ParentId = :j AND UserOrGroupId= :user2Id];
      
      // Test for only one manual share on job.
      //System.assertEquals(jShrs.size(), 1, 'Set the object\'s sharing model to Private.');
      
      // Test attributes of manual share.
     // System.assertEquals(jShrs[0].AccessLevel, 'Read');
      //System.assertEquals(jShrs[0].RowCause, 'Manual');
      //System.assertEquals(jShrs[0].UserOrGroupId, user2Id);
      
      // Test invalid job Id.
      //delete j;   
   
      // Insert manual share for deleted job id. 
     // System.assertEquals(OnQuoteShare.manualShareRead(j), false);
   }  
}