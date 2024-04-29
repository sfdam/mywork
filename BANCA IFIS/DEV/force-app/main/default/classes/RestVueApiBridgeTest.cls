/**
 * Created by ccardinale on 17/05/2017.
 */

@IsTest
private class RestVueApiBridgeTest {
  @isTest
  static void testAll() {
    RestVueApiBridge.RequestObject req = new RestVueApiBridge.RequestObject();
    req.methodName = 'test';
    req.params = new List<String>();
    System.assertEquals(null,RestVueApiBridge.doPost(req));
  }
}