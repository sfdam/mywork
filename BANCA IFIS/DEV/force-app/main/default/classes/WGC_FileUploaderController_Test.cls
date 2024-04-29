@isTest
public with sharing class WGC_FileUploaderController_Test {
    @isTest
    public static void Test_WGC_FileUploaderController(){

        //WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createUtenzaDefault();

        WGC_AllDataFactory.creaImpServ();
        Opportunity o = WGC_AllDataFactory.createOpportunity(1,true).get(0);
        //ContentDocument cd = WGC_AllDataFactory.createContentDocument(1,true).get(0);
        ContentVersion cv = new ContentVersion(Title = 'nomeModuloTest', ContentUrl='test.it', PathOnClient='');
        ContentDocument cd = new ContentDocument();
        insert cv;
        ContentVersion cvQ =[SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId, VersionData FROM ContentVersion LIMIT 1];
        String contDocID = cvQ.ContentDocumentId; 
        
        WGC_FileUploaderController.OutputMultipart oMultipart = new WGC_FileUploaderController.OutputMultipart();
        WGC_FileUploaderController.OutputDatiDoc oDatiDoc = new WGC_FileUploaderController.OutputDatiDoc();
        WGC_FileUploaderController.OutputIndice oIndice = new WGC_FileUploaderController.OutputIndice();
        

       
        
        Test.startTest();
        //WGC_FileUploaderController.salvaNote(a.id,'nomeModuloTest');     
        WGC_FileUploaderController.getDocMetadata(false);
        WGC_FileUploaderController.getDocMetadata(true);
        
        WGC_FileUploaderController.WrapperResponse result = WGC_FileUploaderController.uploadDocMultipart(''+cvQ.Id, contDocID,o.Id,false);
        Test.stopTest();
    }

    @isTest
    public static void Test_DocMultipart(){

        
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();
        WGC_Nota_Documento__c nota = WGC_AllDataFactory.createNotaDocumento(1,true).get(0);
        
        Opportunity o = WGC_AllDataFactory.createOpportunity(1,true).get(0);
        Account a = [SELECT Id, Name FROM Account LIMIT 1];
        //ContentDocument cd = WGC_AllDataFactory.createContentDocument(1,true).get(0);
        List<ContentVersion> listCV = WGC_AllDataFactory.createContentVersion(2,true);
        WGC_FileUploaderController.DOC doc = new WGC_FileUploaderController.DOC();
        ContentVersion cv = [SELECT ContentDocumentId,Id,Title FROM ContentVersion LIMIT 1];
        Date d1 = Date.today();
        Date d2 = d1.addMonths(3);
        doc.docId=cv.ContentDocumentId;
        doc.dataProduzione = d1.format();
        doc.dataScadenza = d2.format();
        doc.famiglia = 'Identificazione clientela';
        doc.tipoDoc = 'EX0000181';
        
        String strDoc = JSON.serialize(doc);
        
        nota.Id_Univoco__c = 'SY0000004_'+nota.Id;
        update nota;

        System.debug('qua --> ' + strDoc);
        Test.startTest();
        //WGC_FileUploaderController.SaveDocument(a.id,,'nomeModuloTest');
        
        WGC_FileUploaderController.saveNote(nota.Id,'aaaa','SY0000004');

        WGC_FileUploaderController.handleNote(a.Id,'aaaa',strDoc,a.Id);
        WGC_FileUploaderController.handleNote(nota.Id,'aaaa','SY0000004',a.Id);

        WGC_FileUploaderController.uploadDocMultipart(a.Id,strDoc, o.Id,false);

        Test.stopTest();
    }

    @isTest
    public static void Test_Con_NDG_Linea(){

        WGC_AllDataFactory.createUtenzaDefault();

        WGC_AllDataFactory.creaImpServ();
        NDGLinea__c att = WGC_AllDataFactory.createAttori2(1,true).get(0);
        ContentVersion cv = new ContentVersion(Title = 'nomeModuloTest', ContentUrl='test.txt', PathOnClient='');
        ContentDocument cd = new ContentDocument();
        insert cv;
        ContentVersion cvQ =[SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileExtension, ContentDocument.LatestPublishedVersionId, VersionData FROM ContentVersion LIMIT 1];
        // String contDocID = cvQ.ContentDocumentId; 
        Account a = [SELECT Id FROM Account LIMIT 1];
        Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];

        WGC_FileUploaderController.DOC doc = new WGC_FileUploaderController.DOC();
        Date d1 = Date.today();
        Date d2 = d1.addMonths(3);
        doc.docId=cvQ.ContentDocumentId;
        doc.dataProduzione = d1.format();
        doc.dataScadenza = d2.format();
        doc.famiglia = 'Credito';
        doc.tipoDoc = '603';
        
        System.debug('@@@ docTest ' + doc);
        String strDoc = JSON.serialize(doc);

        Test.startTest();
        WGC_FileUploaderController.WrapperResponse result = WGC_FileUploaderController.uploadDocMultipart(att.Id, strDoc,o.Id,false);
        // WGC_FileUploaderController.WrapperResponse result2 = WGC_FileUploaderController.uploadDocMultipartOLD(att.Id, strDoc,o.Id,false);
        
        Test.stopTest();
    }

    @isTest
    public static void Test_uploadDocMultipart_Direct(){

        
        WGC_AllDataFactory.createUtenzaDefault();

        WGC_AllDataFactory.creaImpServ();
        WGC_AllDataFactory.createAttori2(1,true).get(0);
        
        List<Opportunity> opty =[SELECT AccountId,Id,IdCartella__c FROM Opportunity];

        WGC_Documenti_Controller.WrapperRicercaMAV mav = new WGC_Documenti_Controller.WrapperRicercaMAV();
        mav.oppId=opty.get(0).Id;
        
        Test.startTest();
        WGC_FileUploaderController.uploadDocMultipart_Direct(mav);
        Test.stopTest();
    }

    @isTest
    public static void test_multipartBigFile(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.creaImpServ();

        List<Account> accList = WGC_AllDataFactory.createAccount(1);
        Insert accList;

        List<Contact> cList = WGC_AllDataFactory.createContact(2);
        Insert cList;

        Test.startTest();
        WGC_FileUploaderController.multipartForBigFile('abc1','abc2','abc3', new String[]{}, 'abc6', '');
        WGC_FileUploaderController.getDatiCI(cList[0].Id);
        Test.stopTest();
    }


}