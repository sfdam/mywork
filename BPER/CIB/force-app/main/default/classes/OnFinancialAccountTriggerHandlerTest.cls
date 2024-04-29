@isTest
private class OnFinancialAccountTriggerHandlerTest {    
    @isTest
    static void testAfterInsertUpdateDelete() {

        Product2 product = new Product2(
            Name = 'Test'
        );
        insert product;
        String idCreditCard = SV_Utilities.getRecordTypeByDeveloperName('FinServ__FinancialAccount__c', 'CreditCard');
        String idCreditLine = SV_Utilities.getRecordTypeByDeveloperName('FinServ__FinancialAccount__c', 'Credit_Line');
        Account account = AllDataFactory.getPersonAccount('01');
        Account account2 = AllDataFactory.getPersonAccount('02');
        insert new List<Account>{account,account2};
        FinServ__FinancialAccount__c financialAccount = AllDataFactory.getFinancialAccount('BankingAccount', '01', account.Id);
        financialAccount.FinServ__ProductName__c = product.Id;
        FinServ__FinancialAccount__c financialAccount2 = AllDataFactory.getFinancialAccount('BankingAccount', '02', account2.Id);
        financialAccount2.FinServ__ProductName__c = product.Id;
        insert new List<FinServ__FinancialAccount__c>{financialAccount,financialAccount2};
        FinServ__FinancialAccount__c financialAccountCL = AllDataFactory.getFinancialAccount('Credit_Line', 'CL01', account.Id);
        financialAccountCL.CRM_BankDebitAccount__c = financialAccount.Id;
        financialAccountCL.FinServ__ProductName__c = product.Id;
        FinServ__FinancialAccount__c financialAccountCL2 = AllDataFactory.getFinancialAccount('Credit_Line', 'CL02', account.Id);
        financialAccountCL2.CRM_BankDebitAccount__c = financialAccount.Id;
        financialAccountCL2.FinServ__ProductName__c = product.Id;
        FinServ__FinancialAccount__c financialAccountCL3 = AllDataFactory.getFinancialAccount('Credit_Line', 'CL03', account.Id);
        financialAccountCL3.FinServ__ProductName__c = product.Id;
        financialAccountCL3.FinServ__Status__c = 'ESTINTO';
        financialAccountCL3.FinServ__CloseDate__c = Date.today();

        Test.startTest();
        	insert new List<FinServ__FinancialAccount__c>{financialAccountCL,financialAccountCL2,financialAccountCL3};
        	financialAccountCL.CRM_CreditLineAmount__c = 55;
        	financialAccountCL2.CRM_BankDebitAccount__c= financialAccount2.Id;
        	update new List<FinServ__FinancialAccount__c>{financialAccountCL,financialAccountCL2};
            financialAccountCL2.RecordTypeId = idCreditCard;
        	update financialAccountCL2;
        	financialAccountCL2.RecordTypeId = idCreditLine;
        	update financialAccountCL2;
        	delete financialAccountCL2;
        Test.stopTest();
    }
}