@isTest
private class UDateTest {
  @isTest
  static void getDatetimeValueTest() {
    Datetime dt = UDate.getDatetimeValue(0);
    System.assert(dt.isSameDay(Datetime.newInstance(1970, 1, 1, 0, 0, 0)));
  }

  @isTest
  static void getDateValueTest() {
    Date d = UDate.getDateValue(0);
    System.assert(d.isSameDay(Date.newInstance(1970, 1, 1)));
  }

  @isTest
  static void getLongValueTest() {
    Date d = Date.newInstance(1970, 1, 1);
    Long dl = UDate.getLongValue(d);
    Datetime dt = Datetime.newInstance(dl);
    System.assert(dt.date().isSameDay(d));
  }

  @isTest
  static void parseDateYYYYMMDDTest() {
    Date d = Date.newInstance(1970, 1, 30);
    Date d2 = UDate.parseDateYYYYMMDD('19700130');
    System.assert(d.isSameDay(d2));
  }

  @isTest
  static void getStringDateDDMMYYYTest() {
    Date d = Date.newInstance(1970, 1, 30);
    String dS = UDate.getStringDateDDMMYYY(d);
    System.assert(dS ==  '30011970');
  }
}