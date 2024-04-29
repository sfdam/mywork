@isTest
private class TrgContentDocumentTest {
  @isTest
  static void testTrigger() {
    Allegato__c a = new Allegato__c(NomeFile__c = 'pastaAlTonno.txt', Tipo__c = 'MAVFirm');
    insert a;

    ContentVersion v = new ContentVersion(
      VersionData = Blob.valueOf('Y2lhbyBjb21lIHZh'),
      Title = 'Pasta al tonno',
      PathOnClient = '/pastaAlTonno.txt'
    );

    insert v;

    v = [SELECT ContentDocumentId FROM ContentVersion];

    ContentDocumentLink cl = new ContentDocumentLink(
      ContentDocumentId = v.ContentDocumentId,
      LinkedEntityId = a.Id,
      ShareType = 'I'
    );

    insert cl;

    delete new ContentDocument(Id = v.ContentDocumentId);

    System.assert([SELECT Id FROM Allegato__c].isEmpty());
  }
}