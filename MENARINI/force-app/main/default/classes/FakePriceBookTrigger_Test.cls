@isTest
public class FakePriceBookTrigger_Test {
    
    @testSetup
    static void setup(){
        
        Account acc = new Account();
        acc.THR_AccountGroup__c='Generic Customers';
        acc.Name = 'TestAcctPharmaTest';
        acc.THR_VATNumber__c='VATTAP_000145';
        acc.THR_CustomerIdentificationCode__c='TAP_000156';
        acc.THR_AccountsKey__c = '1234ABCTest';
        acc.THR_MAIL__c='TestAcctPharmaedd@test.it';
        acc.BillingStreet='Via test, 33';
        acc.BillingPostalCode='00Test01';
        acc.BillingCity='Rome';
        acc.BillingState='Roma';
        acc.BillingStateCode='RM';
        acc.BillingCountry='Italy';
        acc.BillingCountryCode ='IT';
        acc.THR_Country__c ='IT';
        acc.phone='06232323434';
        insert acc;
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        Update standardPricebook;
        
        Product2 pdL = new Product2();
        pdL.IsActive = true;
        pdL.Name ='ProdTestName0001';
        pdL.ProductCode ='CodProd0001';
        pdL.THR_MaterialKey__c='MK_PT0001';
        insert pdL;
        
        Pricebook2 currPricebook = new Pricebook2();
        currPricebook.Name = 'currPricebookTestName';
        currPricebook.THR_PriceBookKey__c = 'PBKEY001';
        insert currPricebook;
        
    }
    
    
    @isTest
    public static void generatePriceBookEntryFromFakeTest(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Product2 pdL = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.startTest();
        FakePricebookEntry__c FPE = new FakePricebookEntry__c();
        FPE.Name = 'TestFakePricebookEntryName';
        FPE.IsActive__c = true;
        FPE.THR_Z1PC__c= 000111111;
        FPE.THR_PriceBookEntryKey__c = 'PBE00001';
        FPE.THR_PriceBookKey__c = 'PBKEY001';
        FPE.THR_AccountsrKey__c= acc.Id	;
        FPE.THR_Country__c= 'IT';
        FPE.THR_Currency__c= '000111111';
        FPE.THR_Division__c= 'FA';
        FPE.THR_EndingDate__c= Date.newInstance(2020, 08, 21);
        FPE.UnitPrice__c= 12000;
        FPE.THR_MaterialKey__c= pdL.Id;
        FPE.THR_PricingUnit__c= '8';
        FPE.Product2__c= pdL.Id;
        FPE.THR_SalesOrganization__c= 'SIL1';
        FPE.THR_StartingDate__c= Date.newInstance(2020, 07, 21);
        FPE.THR_UnitOfMeasure__c = 'MGM';
        FPE.UseStandardPrice__c= false;
		FPE.THR_ZPPU__c  = true;
     
        insert FPE;
        
        Test.stopTest();
        
    }
    
     @isTest
    public static void generatePriceBookEntryFromFakeTest2(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Product2 pdL = [SELECT Id FROM Product2 LIMIT 1];
        
        Test.startTest();
        FakePricebookEntry__c FPE = new FakePricebookEntry__c();
        FPE.Name = 'TestFakePricebookEntryName';
        FPE.IsActive__c = true;
        FPE.THR_Z1PC__c= 000111111;
        FPE.THR_PriceBookEntryKey__c = 'PBE00001';
        FPE.THR_PriceBookKey__c = 'PBKEY0012';
        FPE.THR_AccountsrKey__c= acc.Id	;
        FPE.THR_Country__c= 'IT';
        FPE.THR_Currency__c= '000111111';
        FPE.THR_Division__c= 'FA';
        FPE.THR_EndingDate__c= Date.newInstance(2020, 08, 21);
        FPE.UnitPrice__c= 12000;
        FPE.THR_MaterialKey__c= pdL.Id;
        FPE.THR_PricingUnit__c= '8';
        FPE.Product2__c= pdL.Id;
        FPE.THR_SalesOrganization__c= 'SIL1';
        FPE.THR_StartingDate__c= Date.newInstance(2020, 07, 21);
        FPE.THR_UnitOfMeasure__c = 'MGM';
        FPE.UseStandardPrice__c= false;
		FPE.THR_ZPPU__c  = true;
     
        insert FPE;
        
        Test.stopTest();
        
    }
    
    

}