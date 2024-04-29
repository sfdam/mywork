@isTest
public class ClickToDial_ControllerTest {
 
    @isTest
    static void testUpdateUserRisoluzioneIndirizzi() {
        String profileId = [SELECT id FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].id;
        User testUser = AllDataFactory.getUser('1123', profileId, 'Family');
        insert testUser;

        Test.startTest();
        ClickToDial_Controller.updateUser(testUser);
        Test.stopTest();

        User updatedUser = [SELECT Id FROM User WHERE Id = :testUser.Id];
    }

    @isTest
    static void testGetOrgId() {
        String profileId = [SELECT id FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].id;
        User testUser = AllDataFactory.getUser('1123', profileId, 'Family');
        System.runAs(testUser) {
            Boolean result = ClickToDial_Controller.getOrgId();
        }
    }


    @isTest
    static void testGetPhoneNumbers() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Test.startTest();
        ClickToDial_Controller.getPhoneNumbers(testAccount.Id);
        Test.stopTest();
    }
}