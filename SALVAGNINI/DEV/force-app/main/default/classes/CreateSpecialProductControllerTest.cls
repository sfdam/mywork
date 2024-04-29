@isTest
public with sharing class CreateSpecialProductControllerTest {
    
    @isTest 
    static void SpecialProductTest(){
        Account acc1 = new Account(
            Name = 'TestAccount01',
            BillingCountry = 'Italy'
        );
        insert acc1;   

        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Assistant']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='MAtteoaccounttriggerNewTest@test.com');
        insert u;

        Opportunity testOpp = new Opportunity(Name = 'TEST', AccountId = acc1.Id, StageName = 'Qualification', CloseDate = system.today(), Projectmanager__c=u.id);
        insert testOpp;

        Product2 p1 = new Product2(
            Name = 'Product2',
            Special_Base_List_Price__c =2,
            Special_List_Price__c =1,
            Installation_Price__c=1,
            Prog_Training_days__c=1,
            Mnt_Training_Days__c =1,
            Transport_Price__c=1,
            isActive = true
        );
        insert p1;
        
        

        Id pricebookIdstd = Test.getStandardPricebookId();
        
        Pricebook2 PBS = new Pricebook2(
        Id = pricebookIdstd,
        IsActive = true,
        Markup__c=0.1
        );
        update PBS;

        Pricebook2 PB = new Pricebook2();
            PB.name='Test';
            PB.Markup__c=0.1;
            PB.IsActive = true;
         //PB.isStandard=true;
         insert PB; 

         Pricebook2 ProceB = [select id, name, Markup__c from Pricebook2 where id=:PB.id];

        system.debug('@@@ il markUp è: '+ ProceB.Markup__c);
        system.debug('@@@ IsStandard: '+ PB.IsStandard);

        SBQQ__Quote__c q1 = new SBQQ__Quote__c(
        //SBQQ__Status__c = 'Draft',
        SBQQ__QuoteLanguage__c = 'English',
        SBQQ__Account__c = acc1.Id,
        Change_for_List_Area_Price__c= 3,
        SBQQ__PriceBook__c=PB.id,
        SBQQ__Opportunity2__c= testOpp.id
        );
        insert q1;

        SBQQ__Quote__c SBQT = [Select id,SBQQ__PriceBook__r.Markup__c from SBQQ__Quote__c where id=:q1.id];
        system.debug('@@@ il mark up dalla quote è: '+ SBQT.SBQQ__PriceBook__r.Markup__c);

        // SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(
        //     SBQQ__Quote__c = q1.Id,
        //     SBQQ__Product__c = p1.Id
        // );
        // insert ql1;

        // SBQQ__QuoteLine__c ql2 = new SBQQ__QuoteLine__c(
        //     SBQQ__Quote__c = q1.Id,
        //     SBQQ__Product__c = p1.Id
        // );
        // insert ql2;
        

    String QuoteId = (String)q1.id;
    String RecType= CreateSpecialProductController.getPricebookId(QuoteId);

    String ProductId =(String)p1.id;
    String PriceBookid = (String) PB.id;
    String result = CreateSpecialProductController.insertAdditionalLines(ProductId,PriceBookid,QuoteId);
    }
}