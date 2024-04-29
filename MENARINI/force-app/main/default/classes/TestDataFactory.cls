/*
 * @Group         	: TEN Technology
 * @CreatedDate     : 2023-03-17
 * @Description     : Data Factory per la realizzazione di oggetti utilizzati nelle classi di test.
 */
@isTest
public class TestDataFactory {
    /*
    * - Profile findProfileByName(userName)
    * - UserRole findUserRoleByDeveloperName(userRoleDevName)
    * - UserRole createUserRole(developerName, name)
    * - User createUser(userRoleId, alias, email, lastName, profileId)
    * - Account createEasyAccount(nameAcc)
    * - cgcloud__Order_Template__c createOrderTemplate(name)
    * - Cgcloud__Order__c createMobilityReleaseOrder(tmplId)
    * - Cgcloud__Order__Item__c createOrderItem(orderId, product2Id) 
    */

    public static Profile findProfileByName(String userName) {
        return findProfileByNameInOrg(userName);
    }
    
    private static Profile findProfileByNameInOrg(String userName) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :userName LIMIT 1];
        return p;
    }
    
    public static UserRole findUserRoleByDeveloperName(String userRoleDevName) {
        return findUserRoleByDeveloperNameInOrg(userRoleDevName);
    }
    
    private static UserRole findUserRoleByDeveloperNameInOrg(String userRoleDevName) {
        UserRole us = [SELECT Id FROM UserRole WHERE DeveloperName = :userRoleDevName LIMIT 1];
        return us;
    }    
    
    public static UserRole createUserRole(String developerName, String name) {
        return new UserRole(DeveloperName = developerName, Name = name);
    }
    
    public static User createUser(Id userRoleId, String alias, String email, String lastName, Id profileId)  {
        
		string randomName = string.valueof(Datetime.now()).replace('-','').replace(':','').replace(' ','');
		
        return new User(
            UserRoleId = userRoleId,
            Alias = alias,
            Email = email,
            EmailEncodingKey = 'UTF-8',
            LastName = lastName + randomName,
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profileId,
            Country = 'Italy',
            IsActive = true,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = email
        );
    }

    public static Account createEasyAccount(String nameAcc)  {
        return new Account(Name = nameAcc);
    }

    public static cgcloud__Order_Template__c createOrderTemplate(String name) {
        return new cgcloud__Order_Template__c(Name = name);
    }
    
    public static Cgcloud__Order__c createMobilityReleaseOrder(String tmplId) {
        return new Cgcloud__Order__c(cgcloud__Order_Template__c = tmplId, cgcloud__Mobility_Release__c = true);
    }
    
    public static cgcloud__Order_Item__c createOrderItem(String orderId, String product2Id) {
        return new cgcloud__Order_Item__c(cgcloud__Order__c = orderId, cgcloud__Product__c = product2Id); 
    }
}