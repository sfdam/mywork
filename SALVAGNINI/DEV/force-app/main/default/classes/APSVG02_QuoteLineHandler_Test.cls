@isTest
public class APSVG02_QuoteLineHandler_Test {
    
    @testSetup
    static void setup() {
        
        Account acc1 = new Account(
            Name = 'TestAccount01',
            BillingCountry = 'Italy'
        );
        insert acc1;
        
        SBQQ__Quote__c q1 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'English',
            SBQQ__Account__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        insert q1;
        
        Product2 p1 = new Product2(
            Name = 'Product1'
        );
        insert p1;
        
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = q1.Id,
            SBQQ__Product__c = p1.Id
        );
        insert ql1;
        
    }
    
    @isTest 
    static void lockRecordWhilePendingApproval_Test() {
        SBQQ__QuoteLine__c ql1 = [SELECT Id FROM SBQQ__QuoteLine__c limit 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Assistant']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='accounttrigger@test.com');
        insert u;
        
        test.startTest();
        
        System.runAs(u) {
            
            try {
                ql1.OptionalLine__c = true;
                update ql1;
            } catch(Exception e) {
                system.debug('Validation assert');
            }
            
        }
        
        test.stopTest();
    }
    
}