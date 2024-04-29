@isTest
public class GoogleMapViewController_Test {
	static testMethod void testController() {
        Account req = new Account(Name='Test Account',
                                   Partita_iva__c = '0000000000',
                                   Codice_fiscale__c = '0000000000',                                   
                                   Industry = 'Altro',
                                   Societa_di_riferimento__c = 'Innolva'
                                   );
		ApexPages.StandardController stdc1 = new ApexPages.StandardController(req);
       	GoogleMapViewController ctl1 = new GoogleMapViewController(stdc1);
	}
}