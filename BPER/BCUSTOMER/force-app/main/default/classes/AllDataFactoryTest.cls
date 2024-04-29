@isTest
private class AllDataFactoryTest {
    
    @isTest
    static void testAllDataFactory() {
		Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
        Account banca = AllDataFactory.getAccount('01', 'Banca');
        Account personAccount = AllDataFactory.getAccount('02', 'PersonAccount');
        insert personAccount;
		Wallet__c microPortafoglio = AllDataFactory.getWallet('MicroWallet',  banca.Id, 'CORPORATE');
        Contact gestore = AllDataFactory.getContact('01', null, banca.Id);
        insert gestore;
		AllDataFactory.getAssignment('Primario', microPortafoglio.Id, gestore.Id);
		User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
		insert user;
		Account account = AllDataFactory.getPersonAccount('01');
        insert account;
        FinServ__FinancialAccount__c financialAccount = AllDataFactory.getFinancialAccount('BankingAccount', '01', account.Id);
        FinServ__FinancialAccountRole__c finAccountRole = AllDataFactory.getFinancialAccountRole('AccountRole',financialAccount.id, account.id,'Primary Owner');
		FinServ__FinancialAccountTransaction__c financialAccountTransaction = AllDataFactory.getFinancialAccountTransaction(financialAccount.Id,'Debit','Pending');
		Case cs = AllDataFactory.getCase();        
        String recordTypeTopDownMono = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Top-Down - Monostep').getRecordTypeId();
		Campaign campaign = AllDataFactory.getCampaign('01', user.Id, recordTypeTopDownMono);
		CampaignMember campaignMember = AllDataFactory.getCampaignMember('01', campaign.Id, gestore.Id, user.Id);
		Opportunity opp = AllDataFactory.getOpportunity('01', user.Id, Date.today().addDays(30));
    }
}