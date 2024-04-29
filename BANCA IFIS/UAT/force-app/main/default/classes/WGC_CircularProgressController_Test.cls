@isTest
public class WGC_CircularProgressController_Test {
    @isTest
    public static void Test_computePercentage(){
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> acc = WGC_AllDataFactory.createAccount(1,true);
        acc.get(0).CostiDelPersonale__c=100.0;
        acc.get(0).CostiPerServizi__c= 50.0;
        update acc;
        Test.startTest();
        WGC_CircularProgressController.computePercentage('Account', acc.get(0).Id, 'CostiDelPersonale__c','CostiPerServizi__c');
        Test.stopTest();
    }


    @isTest
    public static void Test_computePercentage2(){
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> acc = WGC_AllDataFactory.createAccount(1,true);
        acc.get(0).CostiDelPersonale__c=100.0;
        acc.get(0).CostiPerServizi__c= 50.0;
        update acc;
        Test.startTest();
        WGC_CircularProgressController.computePercentage('Account', acc.get(0).Id, null,'CostiPerServizi__c');
        Test.stopTest();
    }

        @isTest
    public static void Test_computePercentage3(){
        WGC_AllDataFactory.disattivaTrigger();
        List<Account> acc = WGC_AllDataFactory.createAccount(1,true);
        acc.get(0).CostiDelPersonale__c=100.0;
        acc.get(0).CostiPerServizi__c= 50.0;
        update acc;
        Test.startTest();
        WGC_CircularProgressController.computePercentage(null, acc.get(0).Id, null,'CostiPerServizi__c');
        Test.stopTest();
    }   

}