@isTest
public without sharing class ART_BatchActivatePrice_Test {

    
    @TestSetup
    public static void setup() {

       Account accToInsert = new Account(
                    THR_AccountGroup__c='Generic Customers',
                    Name = 'TestAcctPharmaTest',
                    THR_VATNumber__c='VATTAP_000145',
                    THR_CustomerIdentificationCode__c='TAP_000156',
                    THR_AccountsKey__c = '1234ABCTest',
                    THR_MAIL__c='TestAcctPharmaedd@test.it',
                    BillingStreet='Via test, 33',
                    BillingPostalCode='00Test01',
                    BillingCity='Rome',
                    BillingState='Roma',
                    BillingStateCode='RM',
                    BillingCountry='Italy',
                    BillingCountryCode ='IT',
                    THR_Country__c ='IT',
                    phone='06232323434'
       );
       
        
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        update standardPricebook;
        
        Product2 pdL = new Product2();
        pdL.IsActive = true;
        pdL.Name ='ProdTestName0001';
        pdL.ProductCode ='CodProd0001';
        pdL.THR_MaterialKey__c='MK_PT0001';
        insert pdL;
        
        insert new Pricebook2(Name = 'currPricebookTestName',THR_PriceBookKey__c = 'PBKEY001');
        insert new FakePricebookEntry__c(Name = 'TestFakePricebookEntryName',IsActive__c = true,THR_Z1PC__c= 000111111,THR_PriceBookEntryKey__c = 'PBE00001',THR_PriceBookKey__c = 'PBKEY001',
                                        THR_AccountsrKey__c= accToInsert.Id	,THR_Country__c= 'IT',THR_Currency__c= '000111111',THR_Division__c= 'FA',
                                        THR_EndingDate__c= Date.newInstance(2020, 08, 21),UnitPrice__c= 12000,THR_MaterialKey__c= pdL.Id,THR_PricingUnit__c= '8',Product2__c= pdL.Id,THR_SalesOrganization__c= 'SIL1',
                                        THR_StartingDate__c= Date.Today(),THR_UnitOfMeasure__c = 'MGM',UseStandardPrice__c= false,THR_ZPPU__c  = true);
    }
    
    @IsTest
    public static void launchBatch() {
        Test.startTest();
        Database.executeBatch(new ART_BatchActivatePriceFromStartingDate(), 200);
        Test.stopTest();
    }
}