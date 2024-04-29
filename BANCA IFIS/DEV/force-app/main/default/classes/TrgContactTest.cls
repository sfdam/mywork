@isTest
private class TrgContactTest {
  @isTest
  static void testValidazioneCF() {
    Funzionalita__c f = Funzionalita__c.getInstance();
    f.ControlloCodiceFiscale__c = true;
    upsert f;

    Contact c = new Contact(LastName = 'rossi', CF__c = 'pippo');

    Boolean exceptionThrown = false;

    try {
      insert c;
    } catch(DmlException e) {
      System.assertEquals(Contact.FirstName, e.getDmlFields(0)[0]);
      exceptionThrown = true;
    }

    System.assert(exceptionThrown);

    exceptionThrown = false;
    c.FirstName = 'mario';

    try {
      insert c;
    } catch(DmlException e) {
      System.assertEquals(Contact.Birthdate, e.getDmlFields(0)[0]);
      exceptionThrown = true;
    }

    System.assert(exceptionThrown);

    exceptionThrown = false;
    c.Birthdate = Date.newInstance(1970, 1, 1);

    try {
      insert c;
    } catch(DmlException e) {
      System.assertEquals(Contact.Sesso__c, e.getDmlFields(0)[0]);
      exceptionThrown = true;
    }

    System.assert(exceptionThrown);

    exceptionThrown = false;
    c.Sesso__c = 'M';

    try {
      insert c;
    } catch(DmlException e) {
      System.assertEquals(Contact.LuogoNascita__c, e.getDmlFields(0)[0]);
      exceptionThrown = true;
    }

    System.assert(exceptionThrown);

    c.CodCatastaleLocNascita__c = 'C623';

    try {
      insert c;
    } catch(DmlException e) {
      System.assertEquals(Contact.CF__c, e.getDmlFields(0)[0]);
      exceptionThrown = true;
    }

    System.assert(exceptionThrown);

    c.CF__c = 'RSSMRA70A01C623Y';
    insert c;
  }
}