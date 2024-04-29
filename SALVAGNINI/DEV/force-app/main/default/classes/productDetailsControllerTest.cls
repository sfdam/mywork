@isTest
    
public with sharing class productDetailsControllerTest {
    @isTest
    static void productDetailsControllerTest() {

        Product2 p1 = new Product2(
            Name = 'Product1',
            Special_Base_List_Price__c =2,
            Special_List_Price__c =1,
            Installation_Price__c=1,
            Prog_Training_days__c=1,
            Mnt_Training_Days__c =1,
            Transport_Price__c=1,
            isActive = true
        );
        insert p1;

        SBQQ__ProductOption__c PO = new SBQQ__ProductOption__c(
            
            SBQQ__OptionalSKU__c =p1.id,
            SBQQ__Number__c = 1
        );
        insert PO;

        String POid = (String) PO.id;
        Test.startTest();
        productDetailsController.getDescriptions(POid);

        Test.stopTest();
    }
}