@IsTest
public with sharing class LightningForgotPasswordControllerTest {

	@testSetup
	static void setupDati() {
		Account a = new Account(Name = 'TestAcc', BI_CodiceAccordo__c = '123');
		insert a;
		Contact c = new Contact(LastName = 'tastCont', AccountId = a.Id);
		insert c;
		Profile p = [SELECT Id FROM Profile WHERE Name = 'IFIS - Segnalatori'];
		User u = new User(Email = 'TestIFIS@testorg.com',
		                  EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		                  LocaleSidKey = 'en_US', ProfileId = p.Id,
		                  TimeZoneSidKey = 'America/Los_Angeles', UserName = 'TestIFIS.b1p3@testorg.com', Alias = '123', ContactId = c.Id);
		u.IsActive=true;
		insert u;
	}

	/* Verifies that ForgotPasswordController handles invalid usernames appropriately */
	/*
	  @IsTest
	  static void testLightningForgotPasswordControllerInvalidUserName() {
	  System.assertEquals(LightningForgotPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.Site.invalid_email);
	  System.assertEquals(LightningForgotPasswordController.forgotPassword(null, 'http://a.com'), Label.Site.invalid_email);
	  System.assertEquals(LightningForgotPasswordController.forgotPassword('a', '/home/home.jsp'), Label.Site.invalid_email);
	  }
	*/
	/* Verifies that null checkEmailRef url throws proper exception. */
	/*    
	  @IsTest
	  static void testLightningForgotPasswordControllerWithNullCheckEmailRef() {
	  System.assertEquals(LightningForgotPasswordController.forgotPassword('a', null), 'Argument 1 cannot be null');
	  System.assertEquals(LightningForgotPasswordController.forgotPassword('a@salesforce.com', null), 'Argument 1 cannot be null');
	  }
	*/
	/* Verifies that LightningForgotPasswordController object is instantiated correctly. */
	@IsTest
	static void LightningForgotPasswordControllerInstantiation() {
		System.assertEquals(LightningForgotPasswordController.forgotPassword('TestIFIS@testorg.com', 'http://a.com'), null);
	}
}