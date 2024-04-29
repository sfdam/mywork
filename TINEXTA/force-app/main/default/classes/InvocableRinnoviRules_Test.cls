@isTest
public class InvocableRinnoviRules_Test {
    
    @isTest static void testSuccess() {
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = true;
        insert x;
        
        List<InvocableRinnoviRules.ActionRequest> arList = new List<InvocableRinnoviRules.ActionRequest>();
        InvocableRinnoviRules.ActionRequest arTest = new InvocableRinnoviRules.ActionRequest();
        
        Id rtIdOpp = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        Id rtIdQLine = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__QuoteLine__c' LIMIT 1].id;
        
        Account[] acc = TestDataFactory.createAccounts(1);
        acc[0].Societa_di_riferimento__c='Warrant';
        
        insert acc;
        
        SBQQ__Quote__c NQuote = new SBQQ__Quote__c(SBQQ__Primary__c=true,
                                                   CloseDate__c=system.today()+100,
        											Opportunity_Name__c= 'Test',
                                                    StageName__c='Potenziali',
                                                    WH_Business_Area__c='FAA',
                                       				SBQQ__Account__c=acc[0].id,
                                      				RecordTypeId = rtIdQuote);
        
        Insert NQuote;
        
        
        Opportunity NOpportunity = new Opportunity(
            							AccountId=acc[0].id,
           								 Name = 'Test',
            							StageName='Potenziali',
            							CloseDate=system.today(),
                                      RecordTypeId = rtIdOpp);
        
        Insert NOpportunity;
        
        //Inserimento prodotti e pricebook
        Product2 pro = new product2 (name = 'Driver',
                                    IsActive =true);
        
        insert pro ;
       

        
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
        
        
        SBQQ__QuoteLine__c NQuoteLine = new SBQQ__QuoteLine__c(
            							Divisione_WarrantCPQ__c='FAA',
            							SBQQ__Product__c = pro.id,
            							SBQQ__Quote__c=NQuote.id,
                                      RecordTypeId = rtIdQLine);

        
        
        Insert NQuoteLine;
        
        
        arTest.tipoprogetto = 'Singolo';
        arTest.progetto = 'Test';
        arTest.mandato = 'Test';
        arTest.pickmandato = 'Test1';
        arTest.pickfattura='Test';
        arTest.pickprogetto='Test2';
        arTest.pickesercizio='2000';
        arTest.pickeofferta='Test2';
        arTest.PickAnnocompotenza='2000';
        arTest.MandatopOpp='Test3';
        arTest.PickGruppo='Test3';
        arTest.PickDomanda='Test3';
        
        
        
        arTest.QuoteObject = NQuote;
        //arTest.OpportunityObject = NOpportunity;
        arTest.QuoteLineObject = NQuoteLine;
        
        arList.add(arTest);
        
        x.Disabilita_tutti_i_trigger__c=false;
        update x;
        
        Test.startTest();
        List<String> res = InvocableRinnoviRules.UpdateRinnoviCheck(arList);
        //System.debug('Result: ' + res);
        //System.assertEquals('Rinnovo inserito correttamente', res);
        Test.stopTest();
    }
    

    
}