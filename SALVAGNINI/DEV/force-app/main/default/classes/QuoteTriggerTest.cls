@isTest
public class QuoteTriggerTest {
    @isTest
    
    static void myTest()
    {
        Test.startTest();
        Account billingAccount = new Account
        (
            name='test',
            BillingCountry='Italy'
        );
        insert billingAccount;
        
        Address__c address = new Address__c
        (
            Account__c = billingAccount.Id
        );
        insert address;

        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Assistant']; 
        User u = new User(Alias = 'standt', Email='factorysimone@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='test1simonefactory@test.com');
        insert u;

        Opportunity testOpp = new Opportunity(Name = 'TEST', AccountId = billingAccount.Id, StageName = 'Qualification', CloseDate = system.today(), Projectmanager__c=u.id);
        insert testOpp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c
        (
        	SBQQ__Account__c = billingAccount.Id,
            SBQQ__QuoteLanguage__c = 'Italian',
            Address__c = address.Id,
            Installation_Address_Type__c = 'Other',
            Installation_Address__c = address.Id,
            SBQQ__Opportunity2__c = testOpp.Id,
            Billing_Address_Type__c = 'Other'
        );
        insert quote;
        Product2 p1 = new Product2(
            Name = 'Product1'
        );
        insert p1;
        
        Pricebook2 PB = new Pricebook2();
        PB.name='Test';
        PB.Type__c = 'IC';
        insert PB;
        
        SBQQ__LookupData__c lookupData = new SBQQ__LookupData__c
        (
            Active__c = true,
            Default__c = true,
            Price_Book__c = PB.Id,
            SVG_Country__c = 'Italy',
            Lookup_Data_Type__c = 'Price Book Assignment'
        );
        
        insert lookupData;
        
        QuoteTriggerHandler.skipTrigger = false;
        
    
        
        Address__c newAddress = new Address__c
        (
            Account__c = billingAccount.Id
        );
        insert newAddress;
        
        QuoteTriggerHandler.skipTrigger = false;
        quote.Billing_Address_Type__c = 'Main';
        quote.SBQQ__Status__c = 'Draft';
        update quote;
        
        QuoteTriggerHandler.skipTrigger = false;
        quote.Address__c = newAddress.Id;
        quote.Billing_Address_Type__c = 'Other';
        update quote;
        
        QuoteTriggerHandler.skipTrigger = false;
        quote.Shipping_Address_Type__c = 'Main';
        update quote;
        
        QuoteTriggerHandler.skipTrigger = false;
        quote.Shipping_Address__c = address.Id;
        quote.Shipping_Address_Type__c = 'Other';
        update quote;
        
        Test.stopTest();
    }
     
    @isTest 
    static void manageLanguageChange_Test() {
		List<SVG_Print_Language__c> printLangList = new List<SVG_Print_Language__c>();
		SVG_Print_Language__c lIT = new SVG_Print_Language__c(
            Language__c = 'Italian',
            PrefaceDescription__c = 'Preface_TEST',
            FirstPageQuotationLabel__c = 'FirstPageQ_TEST',
            FirstPageOrderConfirmation_Label__c = 'FirstPageO_TEST',
            FirstPageSalesProposalLabel__c = 'FirstPageSP_TEST'
        );
        printLangList.add(lIT);
        
        SVG_Print_Language__c lEN = new SVG_Print_Language__c(
            Language__c = 'English',
            PrefaceDescription__c = 'Preface_TEST',
            FirstPageQuotationLabel__c = 'FirstPageQ_TEST',
            FirstPageOrderConfirmation_Label__c = 'FirstPageO_TEST',
            FirstPageSalesProposalLabel__c = 'FirstPageSP_TEST'
        );
        printLangList.add(lEN);
        insert printLangList;
		List<SVG_Print_Label__c> printLabelList = new List<SVG_Print_Label__c>();       
        SVG_Print_Label__c pl1 = new SVG_Print_Label__c(
            Code__c = 'plTest1',
            Name = 'plTest1',
            Default__c = true,
            Category__c = 'TL'
        );
        printLabelList.add(pl1);
        
        SVG_Print_Label__c pl2 = new SVG_Print_Label__c(
            Code__c = 'plTest2',
            Name = 'plTest2',
            Default__c = true,
            Category__c = 'DL'
        );
        printLabelList.add(pl2);
        
        SVG_Print_Label__c pl3 = new SVG_Print_Label__c(
            Code__c = 'plTest3',
            Name = 'plTest3',
            Default__c = true,
            Category__c = 'FL'
        );
        printLabelList.add(pl3);
        
        SVG_Print_Label__c pl4 = new SVG_Print_Label__c(
            Code__c = 'plTest4',
            Name = 'plTest4',
            Default__c = true,
            Category__c = 'FQ'
        );
        printLabelList.add(pl4);
        
        SVG_Print_Label__c pl5 = new SVG_Print_Label__c(
            Code__c = 'plTest5',
            Name = 'plTest5',
            Default__c = true,
            Category__c = 'TQ'
        );
        printLabelList.add(pl5);
        insert printLabelList;
        List<SVG_Label_Translation__c> traslList = new List<SVG_Label_Translation__c>();
        SVG_Label_Translation__c ltIT1 = new SVG_Label_Translation__c(
            PrintLanguage__c = lIT.Id,
            Print_Label__c = pl1.Id
        );
        traslList.add(ltIT1);
        
        SVG_Label_Translation__c ltIT3 = new SVG_Label_Translation__c(
            PrintLanguage__c = lIT.Id,
            Print_Label__c = pl3.Id
        );
        traslList.add(ltIT3);
        
        SVG_Label_Translation__c ltIT4 = new SVG_Label_Translation__c(
            PrintLanguage__c = lIT.Id,
            Print_Label__c = pl4.Id
        );
        traslList.add(ltIT4);
        
        SVG_Label_Translation__c ltIT5 = new SVG_Label_Translation__c(
            PrintLanguage__c = lEN.Id,
            Print_Label__c = pl5.Id
        );
        traslList.add(ltIT5);
        
        SVG_Label_Translation__c ltEN1 = new SVG_Label_Translation__c(
            PrintLanguage__c = lEN.Id,
            Print_Label__c = pl2.Id
        );
        traslList.add(ltEN1);
        insert traslList;
        Account acc1 = new Account(
            Name = 'TestAccount01',
            BillingCountry = 'Italy'
        );
        insert acc1;
        
        Opportunity testOpp = new Opportunity(Name = 'TEST', AccountId = acc1.Id, StageName = 'Qualification', CloseDate = system.today());
        insert testOpp;
    
    	SBQQ__Quote__c q1 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'English',
            Quote_Secondary_Language__c = 'Italian',
        	SBQQ__Opportunity2__c = testOpp.Id,
            SVG_SecondaryPrintLanguage__c = len.Id,
            SVG_BundleLabelLk__c = pl2.Id,
            SVG_DiscountLabelLk__c = pl2.Id,
            SVG_DiscountBundleLabelLk__c = pl2.Id,
            SVG_DiscountTotalLabelLk__c = pl2.Id,
            SVG_TotalLabelLk__c = pl5.Id,
            SBQQ__Account__c = acc1.Id
        );
        insert q1;
        Map<Id,SBQQ__Quote__c> oldMap = new Map<Id,SBQQ__Quote__c>();
        test.startTest();
        QuoteTriggerhandler.manageLanguageChange(new List<SBQQ__Quote__c>{q1}, oldMap);
        
        test.stopTest();        
    }
    
    @isTest 
    static void manageStatusChange_Test() {
        Account acc1 = new Account(
            Name = 'TestAccount01',
            BillingCountry = 'Italy'
        );
        insert acc1;
        
        Opportunity testOpp = new Opportunity(Name = 'TEST', AccountId = acc1.Id, StageName = 'Qualification', CloseDate = system.today());
        insert testOpp;
    	test.startTest();
    	SBQQ__Quote__c q1 = new SBQQ__Quote__c(
            SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'English',
        	SBQQ__Opportunity2__c = testOpp.Id,
            SBQQ__Account__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        insert q1;
        
        q1.SBQQ__Status__c = 'Draft';
        q1.ApprovalStatus__c = 'Approved';
        update q1;
        
        test.stopTest();
    }
    
    @isTest
    static void manageOrderOCSignature_Test() {
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(
            Name = 'TestAccount01',
            BillingCountry = 'Italy'
        );
        insert acc1;
        
        Opportunity testOpp = new Opportunity(Name = 'TEST', AccountId = acc1.Id, StageName = 'Qualification', CloseDate = system.today());
        insert testOpp;
        
    	
    	SBQQ__Quote__c q1 = new SBQQ__Quote__c(
            SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'English',
        	SBQQ__Opportunity2__c = testOpp.Id,
            SBQQ__Account__c = acc1.Id,
            Total_Order_Price__c = 10,
            SBQQ__Type__c = 'Order Confirmation',
            Main_Contractor__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        insert q1;
       	Map<Id,SBQQ__Quote__c> oldQuote = new Map<Id,SBQQ__Quote__c>();
        
        SVG_OC_Signature__c sign = new SVG_OC_Signature__c(
            MainContractor__c = acc1.Id,
            ManagerJobTitle__c = 'CEO',
            ManagerName__c = 'test'
        );
        insert sign;
        Test.startTest();
        QuoteTriggerhandler.manageOrderOCSignature(new List<SBQQ__Quote__c>{q1}, oldQuote);
        Test.stopTest();
    }
    
    @isTest
    static void manageOrderOCSignature_Test2() {
        List<Account> accList = new List<Account>();
        Account acc1 = new Account(
            Name = 'TestAccount01',
            BillingCountry = 'Italy'
        );
        insert acc1;
        
        Opportunity testOpp = new Opportunity(Name = 'TEST', AccountId = acc1.Id, StageName = 'Qualification', CloseDate = system.today());
        insert testOpp;
        
    	
    	SBQQ__Quote__c q1 = new SBQQ__Quote__c(
            SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'English',
        	SBQQ__Opportunity2__c = testOpp.Id,
            SBQQ__Account__c = acc1.Id,
            Total_Order_Price__c = 10,
            SBQQ__Type__c = 'Order Confirmation',
            Main_Contractor__c = acc1.Id,
            ApprovalStatus__c = 'Pending'
        );
        insert q1;
       	Map<Id,SBQQ__Quote__c> oldQuote = new Map<Id,SBQQ__Quote__c>();
        
        SVG_OC_Signature__c sign = new SVG_OC_Signature__c(
            Type__c = 'Other',
            ManagerJobTitle__c = 'CEO',
            ManagerName__c = 'test'
        );
        insert sign;
        Test.startTest();
        QuoteTriggerhandler.manageOrderOCSignature(new List<SBQQ__Quote__c>{q1}, oldQuote);
        QuoteTriggerHandler.manageLegalInfo(new List<SBQQ__Quote__c>{q1}, oldQuote);
        Test.stopTest();
    }
}