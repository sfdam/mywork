@isTest
public class APSVG01_QuoteHandler_Test {
    
    @testSetup
    static void setup() {
        
        SVG_Print_Language__c lIT = new SVG_Print_Language__c(
            Language__c = 'Italian',
            PrefaceDescription__c = 'Preface_TEST',
            FirstPageQuotationLabel__c = 'FirstPageQ_TEST',
            FirstPageOrderConfirmation_Label__c = 'FirstPageO_TEST',
            FirstPageSalesProposalLabel__c = 'FirstPageSP_TEST'
        );
        insert lIT;
        
        SVG_Print_Language__c lEN = new SVG_Print_Language__c(
            Language__c = 'English',
            PrefaceDescription__c = 'Preface_TEST',
            FirstPageQuotationLabel__c = 'FirstPageQ_TEST',
            FirstPageOrderConfirmation_Label__c = 'FirstPageO_TEST',
            FirstPageSalesProposalLabel__c = 'FirstPageSP_TEST'
        );
        insert lEN;
        
        SVG_Print_Label__c pl1 = new SVG_Print_Label__c(
            Code__c = 'plTest1',
            Name = 'plTest1',
            Default__c = true,
            Category__c = 'TL'
        );
        insert pl1;
        
        SVG_Print_Label__c pl2 = new SVG_Print_Label__c(
            Code__c = 'plTest2',
            Name = 'plTest2',
            Default__c = true,
            Category__c = 'DL'
        );
        insert pl2;
        
        SVG_Print_Label__c pl3 = new SVG_Print_Label__c(
            Code__c = 'plTest3',
            Name = 'plTest3',
            Default__c = true,
            Category__c = 'FL'
        );
        insert pl3;
        
        SVG_Print_Label__c pl4 = new SVG_Print_Label__c(
            Code__c = 'plTest4',
            Name = 'plTest4',
            Default__c = true,
            Category__c = 'FQ'
        );
        insert pl4;
        
        SVG_Print_Label__c pl5 = new SVG_Print_Label__c(
            Code__c = 'plTest5',
            Name = 'plTest5',
            Default__c = true,
            Category__c = 'TQ'
        );
        insert pl5;
        
        SVG_Label_Translation__c ltIT1 = new SVG_Label_Translation__c(
            PrintLanguage__c = lIT.Id,
            Print_Label__c = pl1.Id
        );
        insert ltIT1;
        
        SVG_Label_Translation__c ltEN1 = new SVG_Label_Translation__c(
            PrintLanguage__c = lEN.Id,
            Print_Label__c = pl1.Id
        );
        insert ltEN1;
        
        Account acc1 = new Account(
            Name = 'TestAccount01',
            BillingCountry = 'Italy'
        );
        insert acc1;
        
        SBQQ__Quote__c q1 = new SBQQ__Quote__c(
            //SBQQ__Status__c = 'Draft',
            SBQQ__QuoteLanguage__c = 'English',
            SBQQ__Account__c = acc1.Id
        );
        insert q1;
    }
    
    @isTest 
    static void manageStatusChange_Test() {
        SBQQ__Quote__c q1 = [SELECT Id FROM SBQQ__Quote__c limit 1];
        
        test.startTest();
        
        q1.ApprovalStatus__c = 'Approved';
        update q1;
        
        q1.ApprovalStatus__c = 'Rejected';
        update q1;
        
        q1.ApprovalStatus__c = 'Pending';
        update q1;
        
        try {
            q1.SBQQ__Status__c = 'Presented';
            update q1;
        } catch(Exception e) {
            system.debug('Validation assert');
        }
        
        test.stopTest();
    }
    
    @isTest 
    static void lockRecordWhilePendingApproval_Test() {
        SBQQ__Quote__c q1 = [SELECT Id FROM SBQQ__Quote__c limit 1];
        
        q1.ApprovalStatus__c = 'Pending';
        update q1;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Sales Assistant']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='accounttrigger@test.com');
        insert u;
        
        test.startTest();
        
        System.runAs(u) {
            
            try {
                q1.SBQQ__Status__c = 'Presented';
                update q1;
            } catch(Exception e) {
                system.debug('Validation assert');
            }
            
        }
        
        test.stopTest();
    }
    
    @isTest 
    static void autoStartApprovalProcess_Test() {
        SBQQ__Quote__c q1 = [SELECT Id FROM SBQQ__Quote__c limit 1];
        
        test.startTest();
        
        q1.SBQQ__Status__c = 'Approval';
        update q1;
        
        test.stopTest();
    }
    
    @isTest 
    static void manageLanguageChange_Test() {
		SBQQ__Quote__c q1 = [SELECT Id FROM SBQQ__Quote__c limit 1];
        SVG_Print_Label__c pl1 = [SELECT Id FROM SVG_Print_Label__c limit 1];
        
        test.startTest();
        
        q1.SBQQ__QuoteLanguage__c = 'Italian';
        q1.Quote_Secondary_Language__c = 'English';
        q1.SVG_BundleLabelLk__c = pl1.Id;
        update q1;
        
        test.stopTest();        
    }
    
}