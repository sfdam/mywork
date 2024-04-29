@isTest
public class WGC_MultiSelectController_Test {
    @isTest
    public static void test_WGC_MultiSelectController(){
        Test.startTest();
        WGC_MultiSelectController a = new WGC_MultiSelectController('TestValue1', 'TestLabel1', true);
        WGC_MultiSelectController b = new WGC_MultiSelectController('TestValue2', 'TestLabel2');
        Test.stopTest();
    }
}