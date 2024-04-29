@isTest
private class MetadataUtilityTest {

    @isTest static void testMeta() {
        Test.startTest();
        MetadataUtility.getAllByMetadataName('Profilo_BPER__mdt');
        MetadataUtility.getRecordByName('Profilo_BPER__mdt', 'NEC_CC');
        MetadataUtility.getRecordByPrefix('Profilo_BPER__mdt', 'NEC_');
        Test.StopTest();
    }
}