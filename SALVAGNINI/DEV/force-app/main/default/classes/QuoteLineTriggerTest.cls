@isTest
public class QuoteLineTriggerTest {
    
    @isTest
    static void setup() {
        QuoteTriggerHandler.skipTrigger = true;
        Account acc1 = new Account(
            Name = 'TestAccount01',
            BillingCountry = 'Italy'
        );
        insert acc1;
       
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c q1 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'English',
            Quote_Secondary_Language__c = 'Italian',
            SBQQ__Account__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        quoteList.add(q1);
        SBQQ__Quote__c q2 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'Italian',
            Quote_Secondary_Language__c = 'English',
            SBQQ__Account__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        quoteList.add(q2);
        SBQQ__Quote__c q3 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'German',
            Quote_Secondary_Language__c = 'Spanish',
            SBQQ__Account__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        quoteList.add(q3);
        SBQQ__Quote__c q4 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'French',
            Quote_Secondary_Language__c = 'German',
            SBQQ__Account__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        quoteList.add(q4);

        SBQQ__Quote__c q5 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'Spanish',
            Quote_Secondary_Language__c = 'French',
            SBQQ__Account__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        quoteList.add(q5);

        SBQQ__Quote__c q6 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'Chinese',
            Quote_Secondary_Language__c = 'Russian',
            SBQQ__Account__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        quoteList.add(q6);

        SBQQ__Quote__c q7 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'Russian',
            Quote_Secondary_Language__c = 'Chinese',
            SBQQ__Account__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        quoteList.add(q7);
        
        SBQQ__Quote__c q8 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'Polish',
            Quote_Secondary_Language__c = 'Portuguese',
            SBQQ__Account__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        quoteList.add(q8);

        SBQQ__Quote__c q9 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'Portuguese',
            Quote_Secondary_Language__c = 'Polish',
            SBQQ__Account__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        quoteList.add(q9);
        insert quoteList;
        Product2 p1 = new Product2(
            Name = 'Product1'
        );
        insert p1;
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c qlReq = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = q1.Id,
            SBQQ__Product__c = p1.Id,
            SVG_Special_Item__c = false
        );
        quoteLineList.add(qlReq);
        
        SBQQ__QuoteLine__c qlReq2 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = q2.Id,
            SBQQ__Product__c = p1.Id,
            SVG_Special_Item__c = false
        );
        quoteLineList.add(qlReq2);

        SBQQ__QuoteLine__c qlReq3 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = q3.Id,
            SBQQ__Product__c = p1.Id,
            SVG_Special_Item__c = false
        );
        quoteLineList.add(qlReq3);

        SBQQ__QuoteLine__c qlReq4 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = q4.Id,
            SBQQ__Product__c = p1.Id,
            SVG_Special_Item__c = false
        );
        quoteLineList.add(qlReq4);

        SBQQ__QuoteLine__c qlReq5 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = q5.Id,
            SBQQ__Product__c = p1.Id,
            SVG_Special_Item__c = false
        );
        quoteLineList.add(qlReq5);

        SBQQ__QuoteLine__c qlReq6 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = q6.Id,
            SBQQ__Product__c = p1.Id,
            SVG_Special_Item__c = false
        );
        quoteLineList.add(qlReq6);

        SBQQ__QuoteLine__c qlReq7 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = q7.Id,
            SBQQ__Product__c = p1.Id,
            SVG_Special_Item__c = false
        );
        quoteLineList.add(qlReq7);

        SBQQ__QuoteLine__c qlReq8 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = q8.Id,
            SBQQ__Product__c = p1.Id,
            SVG_Special_Item__c = false
        );
        quoteLineList.add(qlReq8);

        SBQQ__QuoteLine__c qlReq9 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = q9.Id,
            SBQQ__Product__c = p1.Id,
            SVG_Special_Item__c = false
        );
        quoteLineList.add(qlReq9);
        
        SBQQ__QuoteLine__c ql1 = new SBQQ__QuoteLine__c(
            SBQQ__Quote__c = q1.Id,
            SBQQ__Product__c = p1.Id,
            Bundle_Name__c = 'test',
            SBQQ__RequiredBy__c = qlReq.Id,
            SVG_Special_Item__c = false
        );
        quoteLineList.add(ql1);
        insert quoteLineList;
    }
    
    /*@isTest
    
    static void myTest()
    {
        SBQQ__QuoteLine__c ql1 = [SELECT Id FROM SBQQ__QuoteLine__c limit 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Assistant'];
        
        Profile profileNotAdmin = [SELECT Id FROM Profile WHERE PermissionsModifyAllData = false LIMIT 1];
          
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = profileNotAdmin.Id, 
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
    }*/
}