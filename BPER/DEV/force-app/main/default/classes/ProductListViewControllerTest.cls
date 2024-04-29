@isTest
public with sharing class ProductListViewControllerTest {
    
    @TestSetup
    public static void setup(){

        Account account = AllDataFactory.getAccount('01', 'Banca');
        Account account2 = AllDataFactory.getAccount('02', 'FilialeDiRelazione');
        Account account3 = AllDataFactory.getAccount('03', 'Banca');
        insert new List<Account>{account, account2, account3};

        Product2 product = new Product2();
        product.Name = 'TestProduct';
        product.ProductCode = 'PV_1000002';
        insert product;

        FinServ__FinancialAccount__c financialAccount = AllDataFactory.getFinancialAccount('BankingAccount', '01', account3.Id);
        financialAccount.FinServ__Status__c = 'ATTIVO';
        financialAccount.CRM_StatoFido__c = 'ATTIVO';
        financialAccount.FinServ__ProductName__c = product.Id;
        insert financialAccount;

        FinServ__FinancialAccountRole__c financialAccountRole = AllDataFactory.getFinancialAccountRole('AccountRole', financialAccount.Id, account2.Id, 'BankingAccount');
        insert financialAccountRole;
    }

    @isTest
    public static void testGetAllData() {

        Account account = [SELECT id, Name FROM Account WHERE Name = 'Account02' LIMIT 1];
        test.startTest();
        ProductListViewController.WrapperObj response1 = ProductListViewController.getAllData(new List<String>{'BankingAccount'}, 'ATTIVO', account.Id, '{"elements":[{"field":"FinServ__Status__c","type":"text"},{"field":"CRM_FormulaHolderType__c","type":"image"},{"field":"Name","type":"lookup","c_object":"FinServ__FinancialAccount__c","objectFields":["CRM_ProductCategory__c","CRM_ProductMacroGroup__c","CRM_ProductSubGroup__c","CRM_ProductGroup__c"]},{"field":"CRM_Channel__c","type":"url","c_object":"CRM_Channel__c","objectFields":["Name"]},{"field":"FinServ__OpenDate__c","type":"text"},{"field":"CRM_ProfileTypology__c","type":"text"},{"field":"CRM_UserCodeStatus__c","type":"text"}]}', 'Operatore di Contact Center', 'ATTIVO');
        ProductListViewController.WrapperObj response2 = ProductListViewController.getAllData(new List<String>{'BankingAccount'}, 'ESTINTO', account.Id, '{"elements":[{"field":"FinServ__Status__c","type":"text"},{"field":"CRM_FormulaHolderType__c","type":"image"},{"field":"Name","type":"lookup","c_object":"FinServ__FinancialAccount__c","objectFields":["CRM_ProductCategory__c","CRM_ProductMacroGroup__c","CRM_ProductSubGroup__c","CRM_ProductGroup__c"]},{"field":"CRM_Channel__c","type":"url","c_object":"CRM_Channel__c","objectFields":["Name"]},{"field":"FinServ__OpenDate__c","type":"text"},{"field":"CRM_ProfileTypology__c","type":"text"},{"field":"CRM_UserCodeStatus__c","type":"text"}]}', 'Operatore di Contact Center', 'ATTIVO');
        ProductListViewController.WrapperObj response3 = ProductListViewController.getAllData(new List<String>{'BankingAccount'}, '', account.Id, '{"elements":[{"field":"FinServ__Status__c","type":"text"},{"field":"CRM_FormulaHolderType__c","type":"image"},{"field":"Name","type":"lookup","c_object":"FinServ__FinancialAccount__c","objectFields":["CRM_ProductCategory__c","CRM_ProductMacroGroup__c","CRM_ProductSubGroup__c","CRM_ProductGroup__c"]},{"field":"CRM_Channel__c","type":"url","c_object":"CRM_Channel__c","objectFields":["Name"]},{"field":"FinServ__OpenDate__c","type":"text"},{"field":"CRM_ProfileTypology__c","type":"text"},{"field":"CRM_UserCodeStatus__c","type":"text"}]}', 'System Administrator', 'ATTIVO');
    	test.stopTest();
        System.assertEquals(true, response1 != null);
        System.assertEquals(true, response2 != null);
        System.assertEquals(true, response3 != null);


           
    }

    @isTest
    public static void testGetObjColumns(){
		test.startTest();
        Map<String, SObject> response = ProductListViewController.getObjColumns(new List<String>{'InsurancePolicy'});
        test.stopTest();
        System.assertEquals(true, response.size()>0);
    }
}