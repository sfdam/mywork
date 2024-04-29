@isTest
private class SingleSingOnProvisionigHandlerTest {
    @TestSetup
    public static void setup(){
        Contact c = new contact();
    	c.FirstName = 'Test';
    	c.LastName = 'Test';
    	c.PTF_RegistrationNumber__c = 'U28047';
    	insert c;
    }
    
    @isTest static void SingleSignOnTest() {
        Test.startTest();
        
        SingleSingOnProvisionigHandler handler = new SingleSingOnProvisionigHandler();
        String pid =[Select Id from Profile Where name ='Standard User'].Id ;
        Map<string,String> tempUser=  new Map<String, String> {
            'language' => 'it_IT' ,
         	'User.Username'=>'testaskdhjkasdj@sdjkfhsjd.com' ,
         	'User.FirstName'=>'testaskdhjkasdj',   
         	'User.LastName'=>'asdjhgasjhd',
         	'User.Email'=>'askdasgdhgas@sdjkfd.com',
         	'User.CommunityNickname'=>'asdjasgdjhahsdhasd',
         	'User.TimeZoneSidKey'=>'America/Los_Angeles',
         	'User.LocaleSidKey'=>'en_US',
         	'User.EmailEncodingKey'=>'UTF-8',
         	'User.ProfileId'=>pid,
         	'User.LanguageLocaleKey'=>'en_US',
        	//  'User.Profilo__c'=>'profiloTest',
         	'User.Profilo__c'=>'NEC_CC',
         	'User.abi__c'=>'0584',
         	'User.idced__c'=>'1234',
         	'User.banca__c'=>'1234',
         	'User.cab__c'=>'1234',
         	'User.ip__c'=>'10.10.10.10',
         	'User.ndgsettoriale__c'=>'1234',
         	'User.userid__c'=>'userid',
         	'User.branchcode__c'=>'123',
         	'User.terminale__c'=>'123',
         	'User.Phone'=>'1234',
         	'User.Fax'=>'1234',
         	'User.Department'=>'dep',
         	'User.Division'=>'division',
         	'User.MobilePhone'=>'1234',
         	'User.Country'=>'italy',
         	'User.Zip'=>'123',
         	'User.Title'=>'Mr',
         	'User.CompanyName'=>'BPER',
         	'User.AboutMe'=>'About Me',
         	'User.Street'=>'Street',
         	'User.State'=>'State',
         	'User.City'=>'City',
         	'User.ReceivesAdminInfoEmails'=>'1',
         	'User.ReceivesInfoEmails'=>'1',
         	'User.IsActive'=>'1',
         	'User.ForecastEnabled'=>'1',
         	'User.PTF_IdCEDAbilitati__c'=>'0011',
         	'User.ModelloDiServizio__c'=>'CORPORATE',
         	'User.Extension'=>'1234567890',
         	'User.FederationIdentifier'=>'28047'
        }; 
        User u = handler.createUser(null,null,null,'', tempUser ,null);
        insert u;
        handler.updateUser(u.Id,null,null,null, '', tempUser,null);
        //User updatedUser = [SELECT userName, email, firstName, lastName, alias FROM user WHERE id=:u.Id];
       Test.stopTest();
    }
}