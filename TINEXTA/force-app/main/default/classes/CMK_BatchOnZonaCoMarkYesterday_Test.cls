@isTest
private class CMK_BatchOnZonaCoMarkYesterday_Test {
    @testSetup 
    static void setup() {
        Profile testProfile = [SELECT Id, Name FROM Profile WHERE Name = 'CoMark - Sales / Commerciali'];
        User testUser = TestDataFactory.create_User(testProfile.Id);
        testUser.Societa__c = 'CoMark';        
        insert testUser;
        User testUser2 = new User(                                                                              
            LastName                    = 'Utente Test2',                                       
            CommunityNickname           = 'communitynicknameTest2',                             
            Alias                       = 'Test2',                                                                                                      
            ProfileId                   = testProfile.Id,                           
            Email                       = 'test2@test.com',                                                                                                         
            Username                    = 'test2.User@testr.name',                      
            EmailEncodingKey            = 'ISO-8859-1',                 
            TimeZoneSidKey              = 'Europe/Rome',                        
            LanguageLocaleKey           = 'it',                 
            LocaleSidKey                = 'it_IT',  
            Societa__c                  = 'CoMark'                      
        );
        insert testUser2;


        Zona_CoMark__c testZona = new Zona_CoMark__c(Agente_Mandatario_CoMark__c = testUser2.Id,
                                                     CAP_CoMark__c = '38123',
                                                     Comune_CoMark__c = 'TRENTO',
                                                     Name = 'TestZona');
        insert testZona;

        List<Lead> leads = TestDataFactory.createLeads(1);
        leads[0].cap_sedeoperativa_comark__c = '38123';
        leads[0].agentezona_comark__c = testUser.Id;
        leads[0].zona_comark__c = testZona.Id;
        insert leads;
        // find the account just inserted. add contact for each
 
    }
    static testmethod void test() {        
        Test.startTest();
        CMK_BatchOnZonaCoMarkYesterday bza = new CMK_BatchOnZonaCoMarkYesterday();
        Id batchId = Database.executeBatch(bza);
        Test.stopTest();
        // after the testing stops, assert records were updated properly

    }
    
}