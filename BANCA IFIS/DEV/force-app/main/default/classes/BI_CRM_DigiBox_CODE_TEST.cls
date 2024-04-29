@isTest
private class BI_CRM_DigiBox_CODE_TEST {

	@isTest
	public static void testCreateAutomatic() {

		//WGC_AllDataFactory.disattivaTrigger();
		WGC_AllDataFactory.createUtenzaDefault();

		WGC_AllDataFactory.creaImpServ();
		Opportunity o = WGC_AllDataFactory.createOpportunity(1, true).get(0);
		//ContentDocument cd = WGC_AllDataFactory.createContentDocument(1,true).get(0);
		ContentVersion cv = new ContentVersion(Title = 'nomeModuloTest', ContentUrl = 'test.it', PathOnClient = '');
		ContentDocument cd = new ContentDocument();
		insert cv;
		ContentVersion cvQ = [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId, VersionData FROM ContentVersion LIMIT 1];
		String contDocID = cvQ.ContentDocumentId;
		List<WGC_FileUploaderController.IndiceInput> listaIndici = new List<WGC_FileUploaderController.IndiceInput> ();
		WGC_FileUploaderController.IndiceInput i = new WGC_FileUploaderController.IndiceInput();
		i.nome = 'alfa';
		i.valore = 'gamma';
		listaIndici.add(i);
		BI_CRM_DigiBox_CODE.DboxMetadatoDocumento d = new BI_CRM_DigiBox_CODE.DboxMetadatoDocumento();
		d.chiave = 'KEY-1';
		d.valore = 'VALUE-1';

		Test.startTest();
		WGC_FileUploaderController.WrapperResponse res = BI_CRM_DigiBox_CODE.createAutomatic(contDocID, o.AccountId + '', listaIndici, 'pippo.pdf', Blob.valueOf('aaaaaaaaaaa'));
		Contact c = new Contact(FirstName='Maria', LastName='Zago', AccountId=o.AccountId);
		insert c;
		res = BI_CRM_DigiBox_CODE.createAutomatic(contDocID,  + c.Id+'', listaIndici, 'pippo.pdf', Blob.valueOf('aaaaaaaaaaa'));
		Test.stopTest();
	}

	@isTest
	public static void testName() {
		List<String> listaBody = new List<String> ();
		listaBody.add('111');
		listaBody.add('222');
		listaBody.add('333');
		BI_CRM_DigiBox_CODE.multipartForBigFile('aaa', 'bbb', 'ccc', listaBody, 'ddd', 'xxxxxxxxxx');
	}
}