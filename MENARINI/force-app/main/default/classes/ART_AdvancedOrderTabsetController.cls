public without sharing class ART_AdvancedOrderTabsetController {
    @AuraEnabled 
    public static String getPdfFileAsBase64String(String idRecord) {
        PageReference pdfPage = Page.CopiaCommissioneDe;
        System.debug(idRecord);
        pdfPage.setRedirect(true);
        pdfPage.getParameters().put('id', idRecord);
        Blob pdfBlob;
        if (Test.isRunningTest()) { 
            pdfBlob = blob.valueOf('Unit.Test');
        }
        else {
            pdfBlob = pdfPage.getContent();
        }
        Attachment attach = new Attachment();
        attach.ParentId = idRecord;
        attach.Body = pdfBlob;
        attach.Name = idRecord+'.pdf';
        insert attach;
        return attach.Id;
    }
}