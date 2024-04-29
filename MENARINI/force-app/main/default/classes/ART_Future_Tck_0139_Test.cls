@IsTest
public class ART_Future_Tck_0139_Test {
    
    @TestSetup
    static void makeData(){
        // source: ART_CreateOrderControllerTest
        User areaManager = new User(
            Alias = 'test2',
            Email = 'test2@noemail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'CGCloud_Area_Manager' LIMIT 1].Id,
            Country = 'Italy',
            IsActive = true,
            // ContactId = contact.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'test2Prod@noemail.com'
        );
        insert areaManager;

        cgcloud__Org_Unit__c parentOrgUnit = new cgcloud__Org_Unit__c(
            ART_OrgLevel__c = 'SalesRep',
            Name= 'WOP_01'
        );
        insert parentOrgUnit;

        cgcloud__Org_Unit_User__c orgUnitAreaManager = new cgcloud__Org_Unit_User__c(
            cgcloud__Org_Unit__c = parentOrgUnit.Id,
            cgcloud__User__c = areaManager.Id,
            ART_RelationshipType__c = 'WORKPLACE_OWNER',
            cgcloud__Valid_From__c = Date.today().addDays(-10),
            cgcloud__Valid_Thru__c = Date.today().addDays(10)
        );
        insert orgUnitAreaManager;

        Account acc = new Account(
			Name = 'test',
            THR_AccountsKey__c = String.valueOf(System.currentTimeMillis())
        );
        insert Acc;

        cgcloud__Account_Org_Unit__c customer = new cgcloud__Account_Org_Unit__c(
            cgcloud__Org_Unit__c = parentOrgUnit.Id,
            cgcloud__Account__c = acc.Id
        );
        insert customer;
    }

    @IsTest
    static void methodName(){
        Test.startTest();
        cgcloud__Org_Unit_User__c orgUnitAreaManager = [SELECT Id FROM cgcloud__Org_Unit_User__c];
        cgcloud__Account_Org_Unit__c customer = [SELECT Id FROM cgcloud__Account_Org_Unit__c];
        customer.ART_Org_Unit_User__c = orgUnitAreaManager.Id;
        
        List<cgcloud__Account_Org_Unit__c> appList_0 = new List<cgcloud__Account_Org_Unit__c>();
        appList_0.add(customer);
        ART_Future_Tck_0139.doUpdate(JSON.serialize(appList_0));
        
        customer = [SELECT Id, ART_Org_Unit_User__c FROM cgcloud__Account_Org_Unit__c];
        System.assertEquals(orgUnitAreaManager.Id, customer.ART_Org_Unit_User__c);

        Test.stopTest();
    }

}