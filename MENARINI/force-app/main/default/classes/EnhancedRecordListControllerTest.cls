@IsTest
public with sharing class EnhancedRecordListControllerTest {

    @TestSetup
    public static void setup() {
        insert new List<Account> {
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
                ),
                new Account(
                        Name = 'TestAcctPharma2',
                        THR_CustomerIdentificationCode__c = 'TAP_0002',
                        THR_AccountsKey__c = 'EXTTAPID_0002',
                        THR_MAIL__c = 'TestAcctPharma@test.it',
                        THR_VATNumber__c = 'VATTAP_0001',
                        BillingStreet = 'Via test, 33',
                        BillingPostalCode = '00Test01',
                        BillingCity = 'Rome',
                        BillingCountry = 'Italy',
                        THR_Country__c = 'IT',
                        THR_AccountGroup__c = 'Deposit',
                        THR_DepositDevName__c = 'THR_EMA'
                ),
                new Account(
                        Name = 'TestAcctPharma3',
                        THR_CustomerIdentificationCode__c = 'TAP_0003',
                        THR_AccountsKey__c = 'EXTTAPID_0003',
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
        result = EnhancedRecordListController.getTotalRecords('Account', new List<EnhancedRecordListController.FilterGroup>());
        Test.stopTest();

        System.assertEquals(3, result);
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

        EnhancedRecordListController.Filter filter2 = new EnhancedRecordListController.Filter();
        filter2.fieldName = 'Name';
        filter2.filterType = 'NOT_EQUAL';
        filter2.fieldValue = 'Invalid Account Name';

        EnhancedRecordListController.Filter filter3 = new EnhancedRecordListController.Filter();
        filter3.fieldName = 'Name';
        filter3.filterType = 'IN';
        filter3.fieldValue =  new List<String>{'TestAcctPharma1'};

        EnhancedRecordListController.Filter filter4 = new EnhancedRecordListController.Filter();
        filter4.fieldName = 'Name';
        filter4.filterType = 'IN';
        filter4.fieldValue =  new List<String>{'TestAcctPharma1', 'TestAcctPharma2', 'TestAcctPharma3'};

        EnhancedRecordListController.FilterGroup filterGroup = new EnhancedRecordListController.FilterGroup();
        filterGroup.logicalOperator = 'AND';
        filterGroup.filters = new List<EnhancedRecordListController.Filter>{filter1, filter2, filter3, filter4};

        Test.startTest();
        result = EnhancedRecordListController.getEnhancedRecordList('Account', targetFields, new  List<EnhancedRecordListController.FilterGroup>{filterGroup}, 'Id', 'Id', true, 10, new List<EnhancedRecordListController.Filter>(), new List<EnhancedRecordListController.Filter>(), true);
        Test.stopTest();

        System.assertEquals(filter1.fieldValue, result.rows[0].get('Name'));
    }

    @IsTest
    public static void getEnhancedRecordList_test2() {
        Test.startTest();

        try {
            EnhancedRecordListController.getEnhancedRecordList('Invalid Object Name', new List<EnhancedRecordListController.TargetField>(), new List<EnhancedRecordListController.FilterGroup>(), 'Id', 'Id', true, 10, new List<EnhancedRecordListController.Filter>(), new List<EnhancedRecordListController.Filter>(), true);
        }
        catch(EnhancedRecordListController.EnhancedRecordListControllerException ex) { }

        try {
            EnhancedRecordListController.TargetField targetField = new EnhancedRecordListController.TargetField();
            targetField.fieldName = 'Invalid Field Name';
            EnhancedRecordListController.getEnhancedRecordList('Account', new List<EnhancedRecordListController.TargetField>{targetField}, new List<EnhancedRecordListController.FilterGroup>(), 'Id', 'Id', true, 10, new List<EnhancedRecordListController.Filter>(), new List<EnhancedRecordListController.Filter>(), true);
        }
        catch(EnhancedRecordListController.EnhancedRecordListControllerException ex) { }

        try {
            EnhancedRecordListController.Filter filter = new EnhancedRecordListController.Filter();
            filter.fieldName = 'Invalid Field Name';
            EnhancedRecordListController.FilterGroup filterGroup = new EnhancedRecordListController.FilterGroup();
            filterGroup.logicalOperator = 'AND';
            filterGroup.filters = new List<EnhancedRecordListController.Filter>{filter};
            EnhancedRecordListController.getEnhancedRecordList('Account', new List<EnhancedRecordListController.TargetField>(), new List<EnhancedRecordListController.FilterGroup>{filterGroup}, 'Id', 'Id', true, 10, new List<EnhancedRecordListController.Filter>(), new List<EnhancedRecordListController.Filter>(), true);
        }
        catch(EnhancedRecordListController.EnhancedRecordListControllerException ex) { }

        try {
            EnhancedRecordListController.getEnhancedRecordList('Account', new List<EnhancedRecordListController.TargetField>(), new List<EnhancedRecordListController.FilterGroup>(),'Id', 'Invalid Field Name', true, 10, new List<EnhancedRecordListController.Filter>(), new List<EnhancedRecordListController.Filter>(), true);
        }
        catch(EnhancedRecordListController.EnhancedRecordListControllerException ex) { }

        try {
            EnhancedRecordListController.getEnhancedRecordList('Account', new List<EnhancedRecordListController.TargetField>(), new List<EnhancedRecordListController.FilterGroup>(),'Invalid Field Name', 'Id', true, 10, new List<EnhancedRecordListController.Filter>(), new List<EnhancedRecordListController.Filter>(), true);
        }
        catch(EnhancedRecordListController.EnhancedRecordListControllerException ex) { }

        try {
            EnhancedRecordListController.Filter filter = new EnhancedRecordListController.Filter();
            filter.fieldName = 'Invalid Field Name';
            EnhancedRecordListController.getEnhancedRecordList('Account', new List<EnhancedRecordListController.TargetField>(), new List<EnhancedRecordListController.FilterGroup>(), 'Id', 'Id', true, 10, new List<EnhancedRecordListController.Filter>{filter}, new List<EnhancedRecordListController.Filter>(), true);
        }
        catch(EnhancedRecordListController.EnhancedRecordListControllerException ex) { }

        try {
            EnhancedRecordListController.Filter filter = new EnhancedRecordListController.Filter();
            filter.fieldName = 'Invalid Field Name';
            EnhancedRecordListController.getEnhancedRecordList('Account', new List<EnhancedRecordListController.TargetField>(), new List<EnhancedRecordListController.FilterGroup>(), 'Id', 'Id', true, 10, new List<EnhancedRecordListController.Filter>(), new List<EnhancedRecordListController.Filter>{filter}, true);
        }
        catch(EnhancedRecordListController.EnhancedRecordListControllerException ex) { }

        Test.stopTest();
    }

    @IsTest
    public static void getEnhancedRecordList_test3() {
        EnhancedRecordListController.EnhancedRecordList result;
        List<Account> accounts = [SELECT Id, Name FROM Account ORDER BY Name];

        EnhancedRecordListController.TargetField targetField = new EnhancedRecordListController.TargetField();
        targetField.fieldName = 'Name';
        targetField.customLabel = 'Name';
        List<EnhancedRecordListController.TargetField> targetFields = new List<EnhancedRecordListController.TargetField>{targetField};

        EnhancedRecordListController.Filter idFilter = new EnhancedRecordListController.Filter();
        idFilter.fieldName = 'Id';
        idFilter.fieldValue = accounts[1].Id;

        EnhancedRecordListController.Filter nameFilter = new EnhancedRecordListController.Filter();
        nameFilter.fieldName = 'Name';
        nameFilter.fieldValue = accounts[1].Name;

        Test.startTest();
        result = EnhancedRecordListController.getEnhancedRecordList('Account', targetFields, new List<EnhancedRecordListController.FilterGroup>(), 'Id', 'Name', true, 1, new List<EnhancedRecordListController.Filter>(), new List<EnhancedRecordListController.Filter>{idFilter, nameFilter}, true);
        Test.stopTest();

        System.assertEquals(accounts[2].Name, result.rows[0].get('Name'));
    }

    @IsTest
    public static void getEnhancedRecordList_test4() {
        EnhancedRecordListController.EnhancedRecordList result;
        List<Account> accounts = [SELECT Name FROM Account ORDER BY Name];

        EnhancedRecordListController.TargetField targetField = new EnhancedRecordListController.TargetField();
        targetField.fieldName = 'Name';
        targetField.customLabel = 'Name';
        List<EnhancedRecordListController.TargetField> targetFields = new List<EnhancedRecordListController.TargetField>{targetField};

        EnhancedRecordListController.Filter idFilter = new EnhancedRecordListController.Filter();
        idFilter.fieldName = 'Id';
        idFilter.fieldValue = accounts[1].Id;

        EnhancedRecordListController.Filter nameFilter = new EnhancedRecordListController.Filter();
        nameFilter.fieldName = 'Name';
        nameFilter.fieldValue = accounts[1].Name;

        Test.startTest();
        result = EnhancedRecordListController.getEnhancedRecordList('Account', targetFields, new List<EnhancedRecordListController.FilterGroup>(), 'Id', 'Name', true, 1, new List<EnhancedRecordListController.Filter>{idFilter, nameFilter}, new List<EnhancedRecordListController.Filter>(), true);
        Test.stopTest();

        System.assertEquals(accounts[0].Name, result.rows[0].get('Name'));
    }

    @IsTest
    public static void getType_test1() {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType AccountSObjectType = schemaMap.get('Account');
        DescribeSObjectResult AccountDescribeSObjectResult = AccountSObjectType.getDescribe();
        SObjectType ContactSObjectType = schemaMap.get('Contact');
        DescribeSObjectResult ContactDescribeSObjectResult = ContactSObjectType.getDescribe();
        SObjectType OpportunitySObjectType = schemaMap.get('Opportunity');
        DescribeSObjectResult OpportunityDescribeSObjectResult = OpportunitySObjectType.getDescribe();

        Test.startTest();
        EnhancedRecordListController.getType(AccountDescribeSObjectResult.fields.getMap().get('Name').getDescribe());
        EnhancedRecordListController.getType(AccountDescribeSObjectResult.fields.getMap().get('IsDeleted').getDescribe());
        EnhancedRecordListController.getType(OpportunityDescribeSObjectResult.fields.getMap().get('Probability').getDescribe());
        EnhancedRecordListController.getType(AccountDescribeSObjectResult.fields.getMap().get('BillingLatitude').getDescribe());
        EnhancedRecordListController.getType(AccountDescribeSObjectResult.fields.getMap().get('AnnualRevenue').getDescribe());
        EnhancedRecordListController.getType(AccountDescribeSObjectResult.fields.getMap().get('LastActivityDate').getDescribe());
        EnhancedRecordListController.getType(AccountDescribeSObjectResult.fields.getMap().get('CreatedDate').getDescribe());
        EnhancedRecordListController.getType(AccountDescribeSObjectResult.fields.getMap().get('Phone').getDescribe());
        EnhancedRecordListController.getType(AccountDescribeSObjectResult.fields.getMap().get('Website').getDescribe());
        EnhancedRecordListController.getType(ContactDescribeSObjectResult.fields.getMap().get('Email').getDescribe());
        EnhancedRecordListController.getType(null);
        Test.stopTest();
    }

    @IsTest
    public static void getFilterOperator_test1() {
        Test.startTest();
        try {
            EnhancedRecordListController.getFilterOperator('EQUAL');
            EnhancedRecordListController.getFilterOperator('NOT_EQUAL');
            EnhancedRecordListController.getFilterOperator('IN');
            EnhancedRecordListController.getFilterOperator('LIKE');
            EnhancedRecordListController.getFilterOperator(null);
        }
        catch(EnhancedRecordListController.EnhancedRecordListControllerException ex) { }
        Test.stopTest();
    }

    @IsTest
    public static void getQueryFilter_test1() {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        SObjectType AccountSObjectType = schemaMap.get('Account');
        DescribeSObjectResult AccountDescribeSObjectResult = AccountSObjectType.getDescribe();

        Test.startTest();
        EnhancedRecordListController.Filter filter = new EnhancedRecordListController.Filter();

        filter.fieldName = 'Name';
        filter.filterType = 'EQUAL';
        filter.fieldValue = 'Test';
        EnhancedRecordListController.getQueryFilter(AccountDescribeSObjectResult.fields.getMap().get('Name').getDescribe(), filter);

        filter.fieldName = 'Name';
        filter.filterType = 'IN';
        filter.fieldValue = new List<String>{'Test1', 'Test2'};
        EnhancedRecordListController.getQueryFilter(AccountDescribeSObjectResult.fields.getMap().get('Name').getDescribe(), filter);

        filter.fieldName = 'Name';
        filter.filterType = 'LIKE';
        filter.fieldValue = 'Test';
        EnhancedRecordListController.getQueryFilter(AccountDescribeSObjectResult.fields.getMap().get('Name').getDescribe(), filter);

        try {
            filter.fieldName = 'Name';
            filter.filterType = 'Invalid filter';
            filter.fieldValue = 'Test';
            EnhancedRecordListController.getQueryFilter(AccountDescribeSObjectResult.fields.getMap().get('Name').getDescribe(), filter);
        }
        catch(EnhancedRecordListController.EnhancedRecordListControllerException ex) { }

        filter.fieldName = 'IsDeleted';
        filter.filterType = 'EQUAL';
        filter.fieldValue = true;
        EnhancedRecordListController.getQueryFilter(AccountDescribeSObjectResult.fields.getMap().get('IsDeleted').getDescribe(), filter);

        filter.fieldName = 'IsDeleted';
        filter.filterType = 'IN';
        filter.fieldValue = new List<Boolean>{true, false};
        EnhancedRecordListController.getQueryFilter(AccountDescribeSObjectResult.fields.getMap().get('IsDeleted').getDescribe(), filter);

        try {
            filter.fieldName = 'IsDeleted';
            filter.filterType = 'Invalid filter';
            filter.fieldValue = true;
            EnhancedRecordListController.getQueryFilter(AccountDescribeSObjectResult.fields.getMap().get('IsDeleted').getDescribe(), filter);
        }
        catch(EnhancedRecordListController.EnhancedRecordListControllerException ex) { }

        filter.fieldName = 'CreatedDate';
        filter.filterType = 'EQUAL';
        filter.fieldValue = System.now();
        EnhancedRecordListController.getQueryFilter(AccountDescribeSObjectResult.fields.getMap().get('CreatedDate').getDescribe(), filter);

        filter.fieldName = 'IsDeleted';
        filter.filterType = 'IN';
        filter.fieldValue = new List<Datetime>{System.now(), System.now()};
        EnhancedRecordListController.getQueryFilter(AccountDescribeSObjectResult.fields.getMap().get('CreatedDate').getDescribe(), filter);

        try {
            filter.fieldName = 'CreatedDate';
            filter.filterType = 'Invalid filter';
            filter.fieldValue = System.now();
            EnhancedRecordListController.getQueryFilter(AccountDescribeSObjectResult.fields.getMap().get('CreatedDate').getDescribe(), filter);
        }
        catch(EnhancedRecordListController.EnhancedRecordListControllerException ex) { }

        try {
            EnhancedRecordListController.getQueryFilter(null, filter);
        }
        catch(EnhancedRecordListController.EnhancedRecordListControllerException ex) { }

        Test.stopTest();
    }
}