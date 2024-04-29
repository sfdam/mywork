@IsTest
private class Test_OnContentDocumentLinkTrigger {
    
    static testMethod void test_1() {
        DmlException ex;
        
        try{
            Test.startTest();
            Campaign c = new Campaign(Name = 'campaign test');
            
            ContentVersion content=new ContentVersion(); 
            content.Title='Header_Picture1'; 
            content.PathOnClient='/' + content.Title + '.jpg'; 
            Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
            content.VersionData=bodyBlob; 
            content.origin = 'H';
            insert content;
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = c.id;
            contentlink.contentdocumentid = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
            contentlink.ShareType = 'I';
            contentlink.Visibility = 'AllUsers'; 
            
            insert contentlink;
            
            Test.stopTest();
        }catch(DmlException e){
            ex = e;
        }
        
        System.assertNotEquals(null, ex);        
    }
    
}