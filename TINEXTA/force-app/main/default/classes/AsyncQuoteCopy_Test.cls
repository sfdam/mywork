@isTest
public class AsyncQuoteCopy_Test {

    @isTest static void testSuccess() {
        Funzionalita__c x = new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c=true;
        x.Disabilita_tutti_i_process_builder__c=true;
        insert x;
             
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                    IsActive =true);
        Product2 pro2 = new product2 (name = 'Driver2',
                                     IsActive =true
                                     );
        
        insert pro ;
        insert pro2 ;

        
        Id pricebookId = Test.getStandardPricebookId();
        
        PricebookEntry standardPrice = new PricebookEntry(
            Pricebook2Id = pricebookId, Product2Id = pro.Id,
            UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = pro.Id,
            UnitPrice = 12000, IsActive = true);
        insert customPrice;

        List <Account> acc= TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant'; 
        Insert acc;
        
        Test.startTest();
        
       Id rid= [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].Id;
       List<SBQQ__Quote__c>Listaquote= new List <SBQQ__Quote__c>();
        
        SBQQ__Quote__c Quote = new SBQQ__Quote__c(
                SBQQ__Account__c=acc[0].Id,
                Opportunity_Name__c= 'Test',
                StageName__c= 'Potenziali',
            	SBQQ__Primary__c=true,
                CloseDate__c=system.today() + 100,
                WH_Business_Area__c='FAA DRIVER',
               // ForecastCategoryName__c='Pipeline',
                RecordTypeId=rid
        );
                             
     
      
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        Listaquote.add(Quote);
        
        insert Listaquote;
        
        Set<Id> testQuoteIdSet = Utilities.getIdSet(Listaquote, 'Id');
        AsyncQuoteCopy executeQueueable = new AsyncQuoteCopy(testQuoteIdSet);
        Id jobId = System.enqueueJob(executeQueueable);
        //System.debug('Test Job ID: ' + jobId);
        //System.assertEquals('', '');
        Test.stopTest();
    }
    
}