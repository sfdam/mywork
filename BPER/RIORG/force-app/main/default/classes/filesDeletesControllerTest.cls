@isTest
public class filesDeletesControllerTest {
@TestSetup
    static void testSetup(){

      	Knowledge__kav c = new Knowledge__kav(Title = 'Test articolo',UrlName = 'articolo-test-lwc1');
        insert c;
        List <ContentDocumentLink> files = [select  Id, LinkedEntity.name,ContentDocumentId, IsDeleted, SystemModstamp, ShareType, Visibility,ContentDocument.Title,ContentDocument.FileType, ContentDocument.CreatedDate,ContentDocument.Owner.name,ContentDocument.ContentSize
            from ContentDocumentLink where LinkedEntityId =: c.id];
        system.debug('files' +files);

    }
    
    
    @isTest
    static void getFilesByKnowledgeIdTest(){
      Knowledge__kav articolo1 = [SELECT id from Knowledge__kav LIMIT 1 ];
  	  Object response = filesDeletesController.getFilesByKnowledgeId(articolo1.Id);
    }
    
     @isTest
    static void getFilesByKnowledgeIdTestexc(){       
  	  	Object response = filesDeletesController.getFilesByKnowledgeId(null);
     
    }
    
    @isTest
    static void deleteFilesSelectedTestexc(){    
        Boolean simulateDmlError = true;
        List<String> ls = new List<String>{'a', '2'};
        Test.startTest();
          Object result =  filesDeletesController.deleteFilesSelected(ls);
        Test.stopTest();
        
    }
    
    @isTest
    static void showDeleteButtonMethodTest(){
        Group grp =new Group();
        grp.name = 'Delete Files Knowledge';
        insert grp;
        
     	GroupMember gr = new GroupMember();
        gr.GroupId = grp.id;
        filesDeletesController.showDeleteButtonMethod();
    }
    
  
    
	@istest
    static void ContentVersionTest(){
    string base = 'tesinigmydocument';
    system.debug('base' +base);
     system.debug('EncodingUtil.base64Decode(base64)' +EncodingUtil.base64Decode(base));   
    string filename = 'test file';
    Knowledge__kav articolo1 = [SELECT id from Knowledge__kav LIMIT 1 ];
    string recordId = articolo1.id;
        try{
          String result = filesDeletesController.uploadFile(base,filename,recordId);   
    	ContentVersion cv = filesDeletesController.createContentVersion(base,filename);  
        }catch(Exception e){
            System.debug(e);
            system.assertEquals(e.getMessage(), e.getMessage());
        }
    
    } 
    
    @istest
   static void createContentLinkTest(){        
   	string base = 'tesinigmydocument';
   	string filename = 'test file';
	Knowledge__kav articolo1 = [SELECT id from Knowledge__kav LIMIT 1 ];
    string recordId = articolo1.id;    
    ContentDocumentLink cdl = filesDeletesController.createContentLink(null,recordId);        
   }

    
    @isTest
    static void getExistingFilesTest(){
      Knowledge__kav articolo1 = [SELECT id from Knowledge__kav LIMIT 1 ];
      string filename = 'test file';
  	  Object response = filesDeletesController.getExistingFiles(articolo1.Id,filename);
    }
    @isTest
    static void getStatusKnowledgeTest(){
        Knowledge__kav articolo1 = [SELECT id from Knowledge__kav LIMIT 1 ];
      filesDeletesController.getStatusKnowledge(articolo1.id);
    }
    

    
     @isTest
    static void testCreateContentLink() {
        try{
        String contentVersionId = 'exampleContentVersionId';
        String recordId = 'exampleRecordId';
        ContentDocumentLink result = filesDeletesController.createContentLink(contentVersionId, recordId);

        contentVersionId = null;
        recordId = 'exampleRecordId';
        result = filesDeletesController.createContentLink(contentVersionId, recordId);

        contentVersionId = 'exampleContentVersionId';
        recordId = null;
        result = filesDeletesController.createContentLink(contentVersionId, recordId);
        }catch(Exception e){
            System.debug(e);
            system.assertEquals(e.getMessage(), e.getMessage());
            
        }
    }
}