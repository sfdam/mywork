@isTest
public with sharing class HandleIterConfigurationsControllerTest {
    @testSetup
	static void setupTestData() {
        RecordType testRecordType = [SELECT Id,Name FROM RecordType WHERE SObjectType = 'Account' AND DeveloperName = 'FilialediRelazione' LIMIT 1];
        
        Account testUnitaOrganizzativa = new Account(
            Name = 'Test Unità Organizzativa',
            RecordTypeId = testRecordType.Id
        );
        insert testUnitaOrganizzativa;
    
        List<IterConfiguration__c> iterConfigs = new List<IterConfiguration__c>();
        	for (Integer i = 0; i < 3; i++) {
            	IterConfiguration__c iterConfig = new IterConfiguration__c(
                TipoSpostamento__c = 'Filiale',
                UnitaOrganizzativa__c = testUnitaOrganizzativa.Id
            	);
            	iterConfigs.add(iterConfig);
       			 }
        insert iterConfigs;
    }
    
    @isTest
    static void testController()
    {
        Test.startTest();
        HandleIterConfigurationsController.getIterConfigurations();
		Account unitaOrganizzativa = [SELECT Id,RecordTypeName__c FROM Account WHERE Name = 'Test Unità Organizzativa' LIMIT 1];    
        HandleIterConfigurationsController.createIterConfiguration(unitaOrganizzativa, 'MDS', 1);
        HandleIterConfigurationsController.createIterConfiguration(unitaOrganizzativa, 'Filiale', 1);
        
        IterConfiguration__c iterConfig = new IterConfiguration__c();
		insert iterConfig;
        HandleIterConfigurationsController.saveIterConfigurations(new List<IterConfiguration__c>{iterConfig});
        HandleIterConfigurationsController.deleteIterConfigurations(new List<IterConfiguration__c>{iterConfig});
        
        Test.stopTest();
    }
    

     @isTest
    static void testGetUsedTipiConfigurazione1() {
        Account testUnitaOrganizzativa = new Account(Name = 'Test Unità Organizzativa');
        insert testUnitaOrganizzativa;
        
        List<IterConfiguration__c> iterConfigs = new List<IterConfiguration__c>();
        for (Integer i = 0; i < 3; i++) {
            IterConfiguration__c iterConfig = new IterConfiguration__c(
                TipoSpostamento__c = 'Filiale',
                UnitaOrganizzativa__c = testUnitaOrganizzativa.Id
            );
            iterConfigs.add(iterConfig);
        }
        insert iterConfigs;
        
        List<String> usedTipi = HandleIterConfigurationsController.getUsedTipiConfigurazione(testUnitaOrganizzativa, true);
        List<String> usedTipi1 = HandleIterConfigurationsController.getUsedTipiConfigurazione(testUnitaOrganizzativa, false);

    }
    
    
}