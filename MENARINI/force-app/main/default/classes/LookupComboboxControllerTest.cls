@IsTest
public with sharing class LookupComboboxControllerTest {
    @IsTest
    public static void lookupComboboxControllerTest1() {
        Test.startTest();
        LookupComboboxController.getOptions('User', 'Name', UserInfo.getFirstName(), '10');
        Test.stopTest();
    }
}