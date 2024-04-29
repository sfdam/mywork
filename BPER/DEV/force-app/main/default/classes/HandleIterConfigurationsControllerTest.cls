@isTest
public with sharing class HandleIterConfigurationsControllerTest {

    @isTest
    static void testController()
    {
        Test.startTest();
        HandleIterConfigurationsController.getIterConfigurations();
        Account unitaOrganizzativa = new Account
        (
            name = 'test'
        );
        HandleIterConfigurationsController.createIterConfiguration(unitaOrganizzativa, 'MDS', 1);

        IterConfiguration__c iterConfig = new IterConfiguration__c();
		insert iterConfig;
        HandleIterConfigurationsController.saveIterConfigurations(new List<IterConfiguration__c>{iterConfig});
        HandleIterConfigurationsController.getUsedTipiConfigurazione(unitaOrganizzativa);
        HandleIterConfigurationsController.deleteIterConfigurations(new List<IterConfiguration__c>{iterConfig});
        Test.stopTest();
    }
}