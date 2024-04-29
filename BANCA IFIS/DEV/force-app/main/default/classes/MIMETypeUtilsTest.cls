/**
 * Created by ccardinale on 16/05/2017.
 */

@IsTest
private class MIMETypeUtilsTest {
  @isTest
  static void testAll() {
    System.assertEquals('text/x-script.zsh',MIMETypeUtils.getMIMETypeFromExtension('zsh'));
  }
}