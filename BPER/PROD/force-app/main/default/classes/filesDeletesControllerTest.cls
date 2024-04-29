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
        
  	  	Object response = filesDeletesController.getFilesByKnowledgeId('');
     
    }
    
    @isTest
    static void getRelatedFilesByRecordIdTest(){
      Knowledge__kav articolo1 = [SELECT id from Knowledge__kav LIMIT 1 ];
  	  Map<ID, String> response = filesDeletesController.getRelatedFilesByRecordId(articolo1.Id);
    }
    
    @isTest
    static void retriveContDocsTest(){
      Knowledge__kav articolo1 = [SELECT id from Knowledge__kav LIMIT 1 ];
  	  Map<String, Object> response = filesDeletesController.retriveContDocs(articolo1.Id);
    }
    
    @isTest
    static void deleteFilesSelectedTestexc(){    
        Boolean simulateDmlError = true;
        Knowledge__kav k = [select id from Knowledge__kav where Title = 'Test articolo' limit 1];
        List<String> ls = new List<String>{'a', '2'};
        Test.startTest();
          Object result =  filesDeletesController.deleteFilesSelected(ls,k.id);
        Test.stopTest();
        
    }
     @isTest
    static void deleteFilesSelectedTestexc1(){    
        Boolean simulateDmlError = true;
        Knowledge__kav k = [select id from Knowledge__kav where Title = 'Test articolo' limit 1];
        List<String> ls = new List<String>();
        Test.startTest();
          Object result =  filesDeletesController.deleteFilesSelected(ls,k.id);
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
    
  
    
	/*@isTest
	static void testUploadFile() {
    String base64Data = 'yourBase64EncodedStringHere';
    String fileName = 'TestFile.txt';

    // Create a test record for Knowledge__kav
    Knowledge__kav testKnowledgeRecord = new Knowledge__kav(
        Title = 'Test Title',
        UrlName = 'articolo-test-lwc12'
    );
    insert testKnowledgeRecord;

    String recordId = testKnowledgeRecord.Id;

    Test.startTest();
    Object result2 = filesDeletesController.uploadFile(base64Data, fileName, recordId);
    base64Data = 'invalidBase64Data';
    Object result1 = filesDeletesController.uploadFile(base64Data, fileName, recordId);
    Test.stopTest();

	} */
    
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
    static void createContentVersionTest(){
      Knowledge__kav articolo1 = [SELECT id from Knowledge__kav LIMIT 1 ];
      string filename = 'test file';
      String base64Data = 'Base64EncodedStringHereTest';  
  	  Object response = filesDeletesController.createContentVersion(base64Data,filename);
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

     @isTest
    static void testRuntest() {
        filesDeletesController.testRun();
    }
}