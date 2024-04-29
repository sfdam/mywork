/*
 * @Author        : Alessandro Di Nardo @ten
 * @Name		  : ART_DeleteAccountTeamBatchTest 
 * @CreateDate    : 2023-09-08
 * @Description   : 
 * 					
 * @ClassTest     : 
 */

@isTest
public without sharing class ART_DeleteAccountTeamBatchTest {
    
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

        insert salesAreaManager;

        cgcloud__Org_Unit__c parentOrgUnit = new cgcloud__Org_Unit__c(
            ART_OrgLevel__c = 'SalesRep',
            Name= 'WOP_01'
        );

        insert parentOrgUnit;

        cgcloud__Org_Unit_User__c orgUnitAreaManager = new cgcloud__Org_Unit_User__c(
            ART_RelationshipType__c = 'WORKPLACE_OWNER',
            cgcloud__Valid_From__c = Date.today().addDays(-10),
            cgcloud__Valid_Thru__c = Date.today().addDays(10),
            cgcloud__Org_Unit__c = parentOrgUnit.Id,
            cgcloud__User__c = salesAreaManager.id
        );
        insert orgUnitAreaManager;  
        
        Account acc = new Account
            (
                Name = 'test',
                THR_AccountsKey__c = String.valueOf(System.currentTimeMillis())
            );
            insert acc;
            
        cgcloud__Account_Manager__c accManager = new cgcloud__Account_Manager__c
            (
                cgcloud__Account__c = acc.Id,
                cgcloud__Active__c  = true,
                cgcloud__Management_Type__c = 'Sales' ,
                cgcloud__User__c=salesAreaManager.id
            );
            insert accManager;

            AccountTeamMember accTeam = new AccountTeamMember(

                AccountId = acc.Id,
                UserId	=salesAreaManager.id
            );
            insert accTeam;
    }
    @isTest
    static void myTestMethod() {        
        Test.startTest();
        ART_DeleteAccountTeamBatchSchedulable myClass = new ART_DeleteAccountTeamBatchSchedulable();  
        myClass.sobjectName = 'AccountTeamMember'; 
        String hour = String.valueOf(Datetime.now().hour());
        String min = String.valueOf(Datetime.now().minute() + 1);
        String ss = String.valueOf(Datetime.now().second());
        String chron = ss + ' ' + min + ' ' + hour + ' * * ?';
        
        //String chron = '0 0 * 1/1 * ? *';  
        //0 0 * * *    every day at midnight  
        System.schedule('Test ART_DeleteAccountTeamBatchSchedulable', chron, myClass);
        Test.stopTest();
   }
}