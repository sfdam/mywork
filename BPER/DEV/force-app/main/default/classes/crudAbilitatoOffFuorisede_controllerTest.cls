@isTest
private class crudAbilitatoOffFuorisede_controllerTest {

    @isTest
    static void testInitMethod() {

        User testUser = AllDataFactory.getUser('Test', '00e3X000001BtEMQA0', 'Residuale');
        insert testUser;

        Account testAccount = AllDataFactory.getAccount('Test', 'PersonAccount');
        insert testAccount;

        crudAbilitatoOffFuorisede_controller.MyWrapper result = crudAbilitatoOffFuorisede_controller.init(testUser.Id, testAccount.Id);

        System.assertEquals(testAccount.CRM_NDG__c, result.crmNdg, 'Expected CRM NDG to match');
        System.assertEquals(testAccount.FinServ__BankNumber__c, result.bankNumber, 'Expected Bank Number to match');
        System.assertEquals(testUser.FederationIdentifier, result.federationIdentifier, 'Expected Federation Identifier to match');
    }

}