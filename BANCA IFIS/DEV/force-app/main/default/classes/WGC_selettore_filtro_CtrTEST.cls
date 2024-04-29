@isTest
private class WGC_selettore_filtro_CtrTEST {

    @TestSetup
    static void makeData(){
        List<User> testUserList = new List<User>();
        Profile testProifile = [SELECT Id FROM Profile WHERE Name='IFIS - Gestore Cliente'];
        UserRole testUserRole = new UserRole(DeveloperName = 'testDirezione', Name = 'testDirezione');
        insert testUserRole;
        Double randNumber = Math.Random();

        User testUserDirezione = new User(Alias = 'TestIFIS', Email = 'TestIFIS@testorg.com', 
        EmailEncodingKey ='UTF-8', LastName = 'Testing', FirstName = 'Test direzione',
        LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = testProifile.Id, 
        TimeZoneSidKey = 'America/Los_Angeles', Username = 'user'+randNumber+'@test.com',
        Qualifica_Utente__c = '', UserRoleId = testUserRole.Id,
        WGC_La_mia_filiale__c = '002;004');
        testUserList.add(testUserDirezione);

        randNumber = Math.Random();
        User testUserFiliale002 = new User(Alias = 'TestIFIS', Email='TestIFIS@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = testProifile.Id, 
        TimeZoneSidKey='America/Los_Angeles', Username = 'user'+randNumber+'@test.com',
        Qualifica_Utente__c= 'Sviluppo_Commerciale_Filiali', UserRoleId = testUserRole.Id,
        WGC_La_mia_filiale__c = '002');
        testUserList.add(testUserFiliale002);

        randNumber = Math.Random();
        User testUserFiliale004 = new User(Alias = 'TestIFIS', Email='TestIFIS@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = testProifile.Id, 
        TimeZoneSidKey='America/Los_Angeles', Username = 'user'+randNumber+'@test.com',
        Qualifica_Utente__c= 'Sviluppo_Commerciale_Filiali', UserRoleId = testUserRole.Id,
        WGC_La_mia_filiale__c = '004');
        testUserList.add(testUserFiliale004);

        insert testUserList;
    }

    @isTest
    private static void getUserWithFilialiTest(){
        Id userDirezioneId = [SELECT Id FROM User WHERE FirstName = 'Test direzione' LIMIT 1].get(0).Id;
        List<User> returnTest = new List<User>();

        Test.startTest();
            returnTest = WGC_selettore_filtro_Controller.getUserWithFiliali(userDirezioneId);
        Test.stopTest();

        System.assertEquals(false, returnTest.isEmpty(), 'getUserWithFilialiTest returnTest is empty');
    }

    @isTest
    private static void getCommercialiTest(){
        Id userDirezioneId = [SELECT Id FROM User WHERE FirstName = 'Test direzione' LIMIT 1].get(0).Id;
        List<User> returnTest = new List<User>();

        Test.startTest();
            returnTest = WGC_selettore_filtro_Controller.getCommerciali(userDirezioneId);
        Test.stopTest();

        System.assertEquals(false, returnTest.isEmpty(), 'getCommercialiTest returnTest is empty');
    }

    @isTest
    private static void getUserWithFilialiWithExceptionTest(){
        String userDirezioneId = '';
        List<User> returnTest = new List<User>();
        String exc = '';

        Test.startTest();
        try{
            returnTest = WGC_selettore_filtro_Controller.getUserWithFiliali(userDirezioneId);
        }catch(Exception e){
            exc = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();

        //System.debug('exc: ' + exc);
        System.assertEquals(true, String.isNotBlank(exc), 'getUserWithFilialiWithExceptionTest exception occurred');
        System.assertEquals(true, returnTest.isEmpty(), 'getUserWithFilialiWithExceptionTest returnTest is empty');
    }

    @isTest
    private static void getCommercialiWithExceptionTest(){
        String userDirezioneId = '';
        List<User> returnTest = new List<User>();
        String exc = '';

        Test.startTest();
        try{
            returnTest = WGC_selettore_filtro_Controller.getCommerciali(userDirezioneId);
        }catch(Exception e){
            exc = e.getMessage() + ' ' + e.getStackTraceString();
        }
        Test.stopTest();

        //System.debug('exc: ' + exc);
        System.assertEquals(true, String.isNotBlank(exc), 'getCommercialiWithExceptionTest exception occurred');
        System.assertEquals(true, returnTest.isEmpty(), 'getCommercialiWithExceptionTest returnTest is empty');
    }

}