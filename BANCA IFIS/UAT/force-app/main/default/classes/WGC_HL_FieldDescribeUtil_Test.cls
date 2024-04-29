@isTest
public class WGC_HL_FieldDescribeUtil_Test {
	@isTest
    public static void Test_WGC_HL_FieldDescribeUtil(){
        Schema.DescribeFieldResult a = Account.ContactStrategyEF__c.getDescribe();
        Schema.SObjectField aa = a.getSObjectField();

        Schema.DescribeFieldResult b = Account.ContactStrategyTR__c.getDescribe();
        Schema.SObjectField bb = b.getSObjectField();

        String s = 'gAAA';
        Test.startTest();

        WGC_HL_FieldDescribeUtil.getDependentOptionsImpl(aa, bb);
        String bits1 = WGC_HL_FieldDescribeUtil.decimalToBinary(23);
        String bits2 = WGC_HL_FieldDescribeUtil.base64ToBits(s);

        Test.stopTest();
        
        System.assertEquals('10111',bits1);
        System.assertEquals('100000000000000000000000',bits2);
    }
}