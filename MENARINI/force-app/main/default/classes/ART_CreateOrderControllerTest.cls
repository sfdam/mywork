@isTest
public class ART_CreateOrderControllerTest {

    @TestSetup
    static void makeData(){
        
        User salesAreaManager = new User(
            Alias = 'test123',
            Email = 'test1234Prod@noemail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'CGCloud_Sales_Area_Manager' LIMIT 1].Id,
            Country = 'Italy',
            IsActive = true,
            // ContactId = contact.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testerProd@test123@noemail.com'
        );

        User cloudAreaManager = new User(
            Alias = 'test12',
            Email = 'test12@noemail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'CGCloud_Area_Manager' LIMIT 1].Id,
            Country = 'Italy',
            IsActive = true,
            // ContactId = contact.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'test12Prod@noemail.com'
        );

        User contactCenterOperator = new User(
            Alias = 'test1',
            Email = 'test1@noemail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Contact Center Operator' LIMIT 1].Id,
            Country = 'Italy',
            IsActive = true,
            // ContactId = contact.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'test1Prod@noemail.com'
        );

        User contactCenterOperator2 = new User(
            Alias = 'test1_2',
            Email = 'test1_2@noemail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Contact Center Operator' LIMIT 1].Id,
            Country = 'Italy',
            IsActive = true,
            // ContactId = contact.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'testerProd@test1_2@noemail.com'
        );

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

        User userProfile = new User(
            Alias = 'test31',
            Email = 'test3@noemail.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'CGCloud_User_Profile' LIMIT 1].Id,
            Country = 'Italy',
            IsActive = true,
            // ContactId = contact.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'test3Prod@noemail.com'
        );
        insert new List<User>{salesAreaManager, cloudAreaManager, contactCenterOperator, contactCenterOperator2, areaManager, userProfile};

        cgcloud__Org_Unit__c parentOrgUnit = new cgcloud__Org_Unit__c(
            ART_OrgLevel__c = 'SalesRep',
            Name= 'WOP_01'
        );
        cgcloud__Org_Unit__c childOrgUnit = new cgcloud__Org_Unit__c(
            ART_OrgLevel__c = 'SalesRep',
            Name= 'WOP_02'
        );
        insert new List<cgcloud__Org_Unit__c>{parentOrgUnit, childOrgUnit};

        cgcloud__Org_Unit_Hierarchy__c orhUnitHierarchy = new cgcloud__Org_Unit_Hierarchy__c(

            cgcloud__Parent_Org_Unit__c = parentOrgUnit.Id,
            cgcloud__Child_Org_Unit__c = childOrgUnit.Id
        );
        insert orhUnitHierarchy;

        cgcloud__Org_Unit_User__c orgUnitAreaManager = new cgcloud__Org_Unit_User__c(
            ART_RelationshipType__c = 'WORKPLACE_OWNER',
            cgcloud__User__c = areaManager.Id,
            cgcloud__Valid_From__c = Date.today().addDays(-10),
            cgcloud__Valid_Thru__c = Date.today().addDays(10),
            cgcloud__Org_Unit__c = parentOrgUnit.Id
        );

        cgcloud__Org_Unit_User__c orgUnitUserProfile = new cgcloud__Org_Unit_User__c(
            ART_RelationshipType__c = 'WORKPLACE_OWNER',
            cgcloud__User__c = userProfile.Id,
            cgcloud__Valid_From__c = Date.today().addDays(-10),
            cgcloud__Valid_Thru__c = Date.today().addDays(10),
            cgcloud__Org_Unit__c = childOrgUnit.Id
        );

        cgcloud__Org_Unit_User__c orgUnitContactCenterOperator = new cgcloud__Org_Unit_User__c(
            ART_RelationshipType__c = 'WORKPLACE_OWNER',
            cgcloud__User__c = contactCenterOperator2.Id,
            cgcloud__Valid_From__c = Date.today().addDays(-10),
            cgcloud__Valid_Thru__c = Date.today().addDays(10),
            cgcloud__Org_Unit__c = childOrgUnit.Id
        );        

        insert new List<cgcloud__Org_Unit_User__c>{orgUnitAreaManager, orgUnitUserProfile, orgUnitContactCenterOperator};

    }
    @isTest 
    static void test() {
        
        Test.startTest();
        Map<String, User> userMap = new Map<String, User>();
        for(User user: [SELECT id, Profile.Name FROM User WHERE Profile.Name IN ('CGCloud_Sales_Area_Manager', 'CGCloud_Area_Manager', 'Contact Center Operator')]){
            userMap.put(user.Profile.Name, user);
        }
        Account acc = new Account
        (
			Name = 'test',
            THR_AccountsKey__c = String.valueOf(System.currentTimeMillis())
        );
        Insert Acc;
        
        cgcloud__Account_Manager__c accManager = new cgcloud__Account_Manager__c
        (
			cgcloud__Account__c = acc.Id,
            cgcloud__Active__c  = true,
            cgcloud__Management_Type__c = 'Sales' 
        );
        Insert accManager;
        
        cgcloud__Account_Extension__c accExtension = new cgcloud__Account_Extension__c
        (
            cgcloud__Account__c = acc.Id,
			cgcloud__Order_Role_Valid_From__c = System.today(),
            cgcloud__Order_Role_Valid_Thru__c = System.today()
        );
        Insert accExtension;
        
        cgcloud__Order_Template__c orderTemplate = new cgcloud__Order_Template__c
		(
        
        );
        Insert orderTemplate;
        
        cgcloud__Order__c order = new cgcloud__Order__c
        (
            cgcloud__Order_Template__c = orderTemplate.Id
        );
        Insert order;
        System.runAs(userMap.get('CGCloud_Sales_Area_Manager')){
            ART_CreateOrderController.init();
        }

        System.runAs(userMap.get('CGCloud_Area_Manager')){
            ART_CreateOrderController.init();
        }

        System.runAs(userMap.get('Contact Center Operator')){
            ART_CreateOrderController.init();
        }
        ART_CreateOrderController.getAccIdFromManager();
        ART_CreateOrderController.getOrderTemplatePicklist(acc.Id);
        ART_CreateOrderController.insertOrderTemplate(acc.Id, orderTemplate.Id, userMap.get('Contact Center Operator').Id);
        ART_CreateOrderController.getAccountInfo(acc.Id);
        Test.stopTest();
	}
}