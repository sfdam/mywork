@isTest
private class RelatedListProdottiAssociatiC_TEST {
    @isTest
    private static void RelatedListProdottiAssociatiC_TEST() {
        Test.startTest();

        Account acct = new Account (Name = 'Acme, Inc.', ModelloDiServizio__c = 'Family');
        insert acct;

        Contact cntct = new Contact();
        cntct.FirstName = 'Mario';
        cntct.LastName = 'Rossi';
        cntct.AccountId = acct.Id;
        insert cntct;

        Campaign cmpgn = new Campaign();
		cmpgn.Name = 'Testcampaign';
		cmpgn.IsActive = TRUE;
        cmpgn.CRM_OwnerSystem__c = 'Siebel';
        insert cmpgn;

        CampaignMember cmpMember = new CampaignMember();
		cmpMember.ContactId = cntct.Id; 
		cmpMember.CampaignId = cmpgn.Id;
        insert cmpMember;

        Product2 product = new Product2();
        product.CRM_MacroGroupCode__c = 'MG_129';
        product.Name = 'test';
        insert product;

        CRM_AssociazioneProdottiCampagna__c junct = new CRM_AssociazioneProdottiCampagna__c(CRM_Campagna__c = Id.valueOf(cmpgn.Id), CRM_Prodotto__c = Id.valueOf(product.Id));
        insert junct;


        List<RelatedListProdottiAssociatiController.productCampaign> p2result = RelatedListProdottiAssociatiController.getProdottiAssociati(cmpgn.Id);
        System.assertEquals(p2result.size(),1);
		List<Product2> productList = new List<Product2>();
        List<Product2> p2presult = RelatedListProdottiAssociatiController.getProdottiAssociabili(cmpgn.Id, '', '', '', '', '', '', productList);
        System.assertEquals(p2presult.size(),1);

        Boolean result = RelatedListProdottiAssociatiController.removeProdotto(cmpgn.Id, product.Id);
        System.assertEquals(result,true);

        List<String> products = new List<String>();
        products.add(product.Id);
        products.add(product.Id);
        result = RelatedListProdottiAssociatiController.associateProducts(cmpgn.Id, products);
        System.assertEquals(result,true);


        try {
            Id fakeid = Id.valueOf('a138E000000N9dr');

            p2result = RelatedListProdottiAssociatiController.getProdottiAssociati(fakeid);
            System.assertEquals(p2result.size(),0);

            p2presult = RelatedListProdottiAssociatiController.getProdottiAssociabili(fakeid, 'a', 'a', 'a', 'a', 'a', 'a', productList);
            System.assertEquals(p2result.size(),0);

            result = RelatedListProdottiAssociatiController.removeProdotto(fakeid, fakeid);
            System.assertEquals(result,true);

            
            List<String> tproducts = new List<String>();
            tproducts.add(fakeid);
            tproducts.add(fakeid);
            result = RelatedListProdottiAssociatiController.associateProducts(fakeid, tproducts);
            System.assertEquals(result,false);
            

        } catch (Exception e) {

        }
        Test.stopTest();

    }
}