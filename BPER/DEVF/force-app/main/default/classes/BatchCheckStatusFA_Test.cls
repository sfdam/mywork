@isTest
private class BatchCheckStatusFA_Test {
    
    private static Account getAccount(String suffix, String recordTypeDeveloperName){
        
        Account account = new Account(
            RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', recordTypeDeveloperName)
            );
        
        if(recordTypeDeveloperName == 'PersonAccount'){
            
            account.FirstName = 'FirstName' + suffix;
            account.LastName = 'LastName' + suffix;
        }else{
            
            account.Name = 'Account' + suffix;
        }
        return account;
    }
    
    public static FinServ__FinancialAccount__c getFinancialAccount(String recordTypeDeveloperName, String suffix, String accountId){

        return new FinServ__FinancialAccount__c(
            Name = 'FinancialAccount' + suffix,
            FinServ__PrimaryOwner__c = accountId,
            RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('FinServ__FinancialAccount__c', recordTypeDeveloperName)
        );
    }
    
    private static FinServ__FinancialAccountRole__c getFinancialAccountRole(String recordTypeDeveloperName, String financialAccountId, String relatedlAccountId, String role){
        
        return new FinServ__FinancialAccountRole__c(
            FinServ__FinancialAccount__c = financialAccountId,
            FinServ__RelatedAccount__c = relatedlAccountId,
            FinServ__Role__c = role,
            RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('FinServ__FinancialAccountRole__c', recordTypeDeveloperName)
        );
    }
    
    @isTest
    static void unitTest() {
        Account account = getAccount('01', 'Banca');
        Account account2 = getAccount('02', 'FilialeDiRelazione');
        Account account3 = getAccount('03', 'Banca');
        insert new List<Account>{account, account2, account3};

        FinServ__FinancialAccount__c financialAccount = getFinancialAccount('BankingAccount', '01', account3.Id);
        financialAccount.FinServ__Status__c = 'ATTIVO';
        financialAccount.CRM_Provenienza__c = 'Titolo';
        insert financialAccount;
        FinServ__FinancialAccountRole__c financialAccountRole = getFinancialAccountRole('AccountRole', financialAccount.Id, account2.Id, 'BankingAccount');
        insert financialAccountRole;
        financialAccount.FinServ__Status__c = 'ESTINTO';
        financialAccount.FinServ__CloseDate__c = date.today();
        update financialAccount;
        Test.startTest();
        Batch_CheckStatusFinancialAccount batch = new Batch_CheckStatusFinancialAccount();
        batch.initRunner(new List<ScheduledJob__c>());
        Database.executeBatch(batch);
        Test.stopTest();
    }
}