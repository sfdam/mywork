@isTest
public with sharing class WGC_PageLayoutRecordDisplay_Ctrl_Test {

    @isTest
    static void getPageLayoutMetadata_emptyPageLayoutName_expectEmptyPageLayoutTest() {
        WGC_PageLayoutRecordDisplay_Controller.PageLayout pageLayout =
                WGC_PageLayoutRecordDisplay_Controller.getPageLayoutMetadata('');
        
        assertEmptyPageLayout(pageLayout);
    }
    
    @isTest
    static void getPageLayoutMetadata_nonExistentPageLayout_expectEmptyPageLayoutTest() {
        String nonExistentPageLayout = 'asfdsdf1213120akdk';
        
        WGC_PageLayoutRecordDisplay_Controller.PageLayout pageLayout =
                WGC_PageLayoutRecordDisplay_Controller.getPageLayoutMetadata(nonExistentPageLayout);

        assertEmptyPageLayout(pageLayout);
    }
    
    @isTest
    static void getPageLayoutMetadata_existingPageLayout_expectNonEmptyPageLayoutTest() {
        String existentPageLayout = 'Account-Account Layout';
        
        WGC_PageLayoutRecordDisplay_Controller.PageLayout pageLayout =
                WGC_PageLayoutRecordDisplay_Controller.getPageLayoutMetadata(existentPageLayout);

        assertNonEmptyPageLayout(pageLayout);
    }
    
    static void assertEmptyPageLayout(WGC_PageLayoutRecordDisplay_Controller.PageLayout pageLayout) {
        system.assert(pageLayout != null, 'The page layout should not be null.');
        system.assert(pageLayout.Sections != null, 'The page layout\'s sections should not be null.');
        system.assertEquals(0, pageLayout.Sections.size(), 'The page layout\'s sections should be empty.');
    }

    static void assertNonEmptyPageLayout(WGC_PageLayoutRecordDisplay_Controller.PageLayout pageLayout) {
        system.assert(pageLayout != null, 'The page layout should not be null.');
        system.assert(pageLayout.Sections != null, 'The page layout\'s sections should not be null.');
        system.assert(pageLayout.Sections.size() > 0, 'The page layouts should have sections.');
    }

    @isTest
    public static void Test_getAccountLayoutNameAssigned(){
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> listAcc = WGC_AllDataFactory.createAccount(1,true);
        List<Contact> listcont = WGC_AllDataFactory.createContact(1,true);
        

        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_PageLayoutRecordDisplay_Controller.getAccountLayoutNameAssigned('Account',listAcc.get(0).Id);
        WGC_PageLayoutRecordDisplay_Controller.getAccountLayoutNameAssigned('Contact',listcont.get(0).Id);
        Test.stopTest();
    }

	@isTest
    public static void doesFieldExist() {
		boolean res = WGC_PageLayoutRecordDisplay_Controller.doesFieldExist('Account', 'Name');
		System.assertEquals(res, true);
	}

	@isTest
    public static void getselectOptions_Nazione() {
		Comune__c c = new Comune__c(Name='PADOVA',Cap__c='35100',CodiceCatastale__c='G224', Provincia__c='PD');
		insert c;
		Map<String, String> res = WGC_PageLayoutRecordDisplay_Controller.getselectOptions_Nazione(null, null, null);
		System.assertNotEquals(res, null);
		System.assertNotEquals('PADOVA', res.get('PADOVA'));
	}

	@isTest
    public static void getCCIAA_ATECO_Conf_Contact() {
		boolean res = WGC_PageLayoutRecordDisplay_Controller.getCCIAA_ATECO_Conf(null,null,null,'Contact');
		System.assertEquals(res, false);
	}

	@isTest
    public static void getCCIAA_ATECO_Conf_Account() {
		boolean res = WGC_PageLayoutRecordDisplay_Controller.getCCIAA_ATECO_Conf(null,null,null,'Account');
		System.assertEquals(res, false);
	}

	@isTest
    public static void getselectOptions_SAE() {
		Map<String, String> res = WGC_PageLayoutRecordDisplay_Controller.getselectOptions_SAE('Account');
		System.assertNotEquals(res, null);
	}

	@isTest
    public static void getselectOptions_ATECO() {
		Map<String, String> res = WGC_PageLayoutRecordDisplay_Controller.getselectOptions_ATECO();
		System.assertNotEquals(res, null);
	}

	@isTest
    public static void getCS_CedacriSleepTime() {
		Impostazioni__c res = WGC_PageLayoutRecordDisplay_Controller.getCS_CedacriSleepTime();
		System.assertNotEquals(res, null);
	}

	@isTest
    public static void getOverrideFieldValue() {
		List<String> lst = new List<String>();
		lst.add('SAE__c');
		List<Account> accs = WGC_AllDataFactory.createAccount(1, true);
		Map<String, Object> res = WGC_PageLayoutRecordDisplay_Controller.getOverrideFieldValue('Account', accs[0].Id, lst);
		System.assertNotEquals(res, null);
	}
}