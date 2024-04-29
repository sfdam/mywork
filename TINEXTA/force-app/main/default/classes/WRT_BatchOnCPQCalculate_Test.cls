@isTest
private class WRT_BatchOnCPQCalculate_Test  {
    
    @testSetup 
    static void setup() {
        
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_Integrazione__c = true;
        x.Disabilita_tutti_i_process_builder__c= true;
        x.Disabilita_tutti_i_trigger__c = true;
        insert x;
         
        Id rtIdOpp = [SELECT Id from RecordType where Name = 'WRT CPQ' AND SObjectType = 'Opportunity' LIMIT 1].id;
        Id rtIdQuote = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__Quote__c' LIMIT 1].id;
        Id rtIdQLine = [SELECT Id from RecordType where Name = 'Warrant' AND SObjectType = 'SBQQ__QuoteLine__c' LIMIT 1].id;
        Id rtContact = [SELECT Id FROM RecordType WHERE Name = 'Warrant' AND SObjectType = 'Contact'].id;
        
        List <Account> acc = TestDataFactory.createAccounts(1);
        insert acc;
        
        Contact cc = TestDataFactory.create_Contact();
        cc.RecordTypeId = rtContact;
        cc.AccountId= acc[0].Id;
        insert cc;

        SBQQ__Quote__c NQuote = new SBQQ__Quote__c(
            SBQQ__Account__c=acc[0].id,
            RecordTypeId = rtIdQuote,
            SBQQ__Primary__c = true,
            WH_Business_Area__c = 'FAA DRIVER',
            WRT_Referente_Amministrativo__c = cc.Id);
        
        Insert NQuote;
       
        
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
       
        
        Opportunity NOpportunity = new Opportunity(
            AccountId=acc[0].id,
            Name = 'Test',
            StageName='Potenziali',
            CloseDate=system.today(),
            Quote_Creazione__c=NQuote.id,
            Creato_da_Quote__c=true,
            Pricebook2Id=customPB.Id,
            RecordTypeId = rtIdOpp);
        
        Insert NOpportunity;
        
        SBQQ__QuoteLine__c NQuoteLine = new SBQQ__QuoteLine__c(
            SBQQ__Product__c = pro.id,
            SBQQ__Quote__c=NQuote.id,
            RecordTypeId = rtIdQLine,
            Divisione_WarrantCPQ__c  = 'FAA DRIVER'   );
        
    	Insert NQuoteLine;
        
        OpportunityLineItem Newline = new OpportunityLineItem(
        Product2Id = pro.id,
        UnitPrice = 1000,
        OpportunityId = NOpportunity.Id,
        SBQQ__QuoteLine__c = NQuoteLine.id,
        Quantity = 1);
        
        Insert Newline;
        
       x.Disabilita_tutti_i_trigger__c=false;
       update x;        
        
        
        
    }
    
    static testmethod void test() {
        
		SBQQ.TriggerControl.disable();        
        Test.startTest();        
        WRT_BatchOnCPQCalculate  bza = new WRT_BatchOnCPQCalculate (); 
        Id batchId = Database.executeBatch(bza);        
        Test.stopTest();
        SBQQ.TriggerControl.enable();
        // after the testing stops, assert records were updated properly

    }

}