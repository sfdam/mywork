@isTest
public class AsyncLeadCopy_Test {

    @isTest static void testSuccess() {
        Funzionalita__c x = new Funzionalita__c();
		x.Disabilita_tutti_i_trigger__c=true;
        insert x;
        
        
        Test.startTest();
        //List<Lead> testLeads = TestDataFactory.createWarrantLeads(5);
        //List<Lead> testLeads = new List<Lead>();
        List <Account> acc= TestDataFactory.createAccounts(2);
        for(Account a:acc){
        // a.IsPartner = true;
         a.Societa_di_riferimento__c='Warrant'; 
                  }
        Insert acc;
        
       Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Lead' LIMIT 1].Id;
        
        List<Lead> testLeads = TestDataFactory.createWarrantLeads(1,rid);
        List <Filiale__c> testfil=TestDataFactory.createWarrantFiliale(acc);
        
        for (Lead l:testLeads){
            l.IsConverted=true;
            l.ConvertedAccountId = acc[0].id;
            l.Filiale1__c=testfil[0].id;
            l.Cognome_Segnalatore__c='TestSegnalatore';
            l.Mail_personale_Warrant__c= 'testmail@mail.invalid';
            l.AccountSegnalatore__c = acc[1].id;
            l.Fonte_Segnalatore__c= 'Banca';
            l.Stato_Segnalazione_Warrant__c= 'In lavorazione';
            l.LastName='Test';
            l.Company='Test';
           
        }
                             
   //        testLeads.add(l);
   //        
      
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        insert testLeads;
        Set<Id> testLeadIdSet = Utilities.getIdSet(testLeads, 'Id');
        AsyncLeadCopy executeQueueable = new AsyncLeadCopy(testLeadIdSet);
        Id jobId = System.enqueueJob(executeQueueable);
        //System.debug('Test Job ID: ' + jobId);
        //System.assertEquals('', '');
        Test.stopTest();
    }
    
}