@isTest
public class ART_CustomMetadataUtilityTest {

    @isTest 
    static void test() {
        Test.startTest();
        
        Account acc = new Account(
        	Name='test',
            THR_AccountsKey__c = String.valueOf(System.currentTimeMillis())
        );
        Insert acc;
        
        String metadataName = 'Account';
        String whereCondition = 'test';
        List<String> queryFields = new List<String>{'a', 'b', 'c'};
        String recordName = 'Account';
        String prefix = 'test';
        String key = 'test';
        
        try {ART_CustomMetadataUtility.makeQueryWithFields(metadataName, whereCondition, queryFields);}catch(Exception exc) {}
		try {ART_CustomMetadataUtility.makeQuery(metadataName, whereCondition);}catch(Exception exc) {}
		try {ART_CustomMetadataUtility.getAllByMetadataName(metadataName);}catch(Exception exc) {}
		try {ART_CustomMetadataUtility.getMapByMetadataName(metadataName);}catch(Exception exc) {}
		try {ART_CustomMetadataUtility.getMapByMetadataNameKey(metadataName, key);}catch(Exception exc) {}
		try {ART_CustomMetadataUtility.getRecordByName(metadataName, recordName);}catch(Exception exc) {}
		try {ART_CustomMetadataUtility.getRecordByPrefix(metadataName, prefix);}catch(Exception exc) {}
        Test.stopTest();
    }        
}