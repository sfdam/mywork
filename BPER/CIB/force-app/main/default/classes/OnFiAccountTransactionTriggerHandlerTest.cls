@isTest
private class OnFiAccountTransactionTriggerHandlerTest {
    
    @isTest
    static void testAfterInsertUpdateDelete() {
        Product2 product = new Product2(
            Name = 'Test'
        );
        insert product;
        Account account = AllDataFactory.getPersonAccount('01');
        Account account2 = AllDataFactory.getPersonAccount('02');
        insert new List<Account>{account,account2};
        FinServ__FinancialAccount__c financialAccount = AllDataFactory.getFinancialAccount('BankingAccount', '01', account.Id);
        financialAccount.FinServ__ProductName__c = product.Id;
        FinServ__FinancialAccount__c financialAccount2 = AllDataFactory.getFinancialAccount('BankingAccount', '02', account2.Id);
        financialAccount2.FinServ__ProductName__c = product.Id;
        insert new List<FinServ__FinancialAccount__c>{financialAccount,financialAccount2};
        FinServ__FinancialAccountTransaction__c financialAccountTransaction = AllDataFactory.getFinancialAccountTransaction(financialAccount.Id,'Debit','Pending');
        FinServ__FinancialAccountTransaction__c financialAccountTransaction2 = AllDataFactory.getFinancialAccountTransaction(financialAccount.Id,'Credit','Pending');
        Test.startTest();
        	insert new List<FinServ__FinancialAccountTransaction__c>{financialAccountTransaction,financialAccountTransaction2};
            financialAccountTransaction.FinServ__TransactionType__c = 'Credit';
        	financialAccountTransaction2.FinServ__TransactionStatus__c = 'Posted';
        	update new List<FinServ__FinancialAccountTransaction__c>{financialAccountTransaction,financialAccountTransaction2};
            delete financialAccountTransaction;
        Test.stopTest();
    }
}