public with sharing class artAdvancedOrderTabsetController {
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
        /*String base64Pdf = EncodingUtil.base64Encode(pdfBlob);
        return base64Pdf;*/
        //Pagereference pdf = new Pagereference('/apex/CopiaCommissioneDe?id=' + idRecord); // VF Page
            
        //return pdf.getContentAsPDF();
        /*Pagereference pdf = new Pagereference('/apex/CopiaCommissioneDe?id=' + idRecord); // VF Page
        Blob blobPdf = pdf.getContentAsPDF();
        String base64Pdf = EncodingUtil.base64Encode(blobPdf);
        Attachment attach = new Attachment();
        attach.ParentId = idRecord;
        attach.Body = blobPdf;
        attach.Name = idRecord+'.pdf';
        insert attach;
        return attach.Id;*/
    }
}