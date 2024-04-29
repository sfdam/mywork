@IsTest
public with sharing class EnhancedRecordListControllerWithSTest {

    @TestSetup
    public static void setup() {
        insert new List<Account>{
                new Account(
                        Name = 'TestAcctPharma1',
                        THR_CustomerIdentificationCode__c = 'TAP_0001',
                        THR_AccountsKey__c = 'EXTTAPID_0001',
                        THR_MAIL__c = 'TestAcctPharma@test.it',
                        THR_VATNumber__c = 'VATTAP_0001',
                        BillingStreet = 'Via test, 33',
                        BillingPostalCode = '00Test01',
                        BillingCity = 'Rome',
                        BillingCountry = 'Italy',
                        THR_Country__c = 'IT',
                        THR_AccountGroup__c = 'Deposit',
                        THR_DepositDevName__c = 'THR_EMA'
                )
        };
    }

    @IsTest
    public static void getTotalRecords_test1() {
        Integer result;

        Test.startTest();
        result = EnhancedRecordListControllerWithS.getTotalRecords('Account', new List<EnhancedRecordListController.FilterGroup>());
        Test.stopTest();

        System.assertEquals(1, result);
    }

    @IsTest
    public static void getEnhancedRecordList_test1() {
        EnhancedRecordListController.EnhancedRecordList result;

        EnhancedRecordListController.TargetField targetField = new EnhancedRecordListController.TargetField();
        targetField.fieldName = 'Name';
        targetField.customLabel = 'Name';
        List<EnhancedRecordListController.TargetField> targetFields = new List<EnhancedRecordListController.TargetField>{targetField};

        EnhancedRecordListController.Filter filter1 = new EnhancedRecordListController.Filter();
        filter1.fieldName = 'Name';
        filter1.filterType = 'EQUAL';
        filter1.fieldValue = 'TestAcctPharma1';

        EnhancedRecordListController.FilterGroup filterGroup = new EnhancedRecordListController.FilterGroup();
        filterGroup.logicalOperator = 'AND';
        filterGroup.filters = new List<EnhancedRecordListController.Filter>{filter1};

        Test.startTest();
        result = EnhancedRecordListControllerWithS.getEnhancedRecordList('Account', targetFields, new  List<EnhancedRecordListController.FilterGroup>{filterGroup}, 'Id', 'Id', true, 10, new List<EnhancedRecordListController.Filter>(), new List<EnhancedRecordListController.Filter>(), true);
        Test.stopTest();

        System.assertEquals(filter1.fieldValue, result.rows[0].get('Name'));
    }
}