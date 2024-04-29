@isTest
public class Batch_EliminaStampePronteTest {
    private static final String testBase64 = 'Qk06AAAAAAAAADYAAAAoAAAAAQAAAAEAAAABABgAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAA////AA==';
    private static final Blob b = Blob.valueOf(testBase64);
	
    @isTest 
    private static void test() {
        ContentVersion cv = new ContentVersion(); 
        cv.Title = 'STAMPA_Google.com';
		cv.PathOnClient = '/' + cv.Title;
        cv.VersionData = b;//EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body', 'UTF-8'));//b;
        cv.CreatedDate = Date.today().addDays(-1);
        ContentVersion cv1 = new ContentVersion();
        cv1.Title = '_Google.com';
		cv1.PathOnClient = '/' + cv1.Title;
        cv1.VersionData = b;//EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body', 'UTF-8'));
        cv1.CreatedDate = Date.today().addDays(-1);
        
        try {
            List<ContentVersion> cvs = new List<ContentVersion>{cv, cv1};
            insert cvs;
            List<ContentDocument> documents = [SELECT Id, Title FROM ContentDocument];
            /*           DA TESTARE
            Integer index = 0;
            for(ContentDocument cd : documents) {
                System.assertEquals(cd.Title, cvs.get(index).Title);
                index += 1;
            }
			*/
            System.debug('documents ' + documents);
            System.assertEquals(documents.size(), cvs.size());
        } catch(Exception e) {
            System.debug('Err');
        }
        
        Batch_EliminaStampePronte test_batch = new Batch_EliminaStampePronte();

        Test.startTest();
        Database.executeBatch(test_batch, 200);
        Test.stopTest();
    }
    
    @isTest 
    private static void testZeroDatas() {
        Batch_EliminaStampePronte test_batch = new Batch_EliminaStampePronte();

        Test.startTest();
        test_batch.initRunner(new List<ScheduledJob__c>());
        test_batch.execute(null);
        Database.executeBatch(test_batch, 200);
        Test.stopTest();
    }
}