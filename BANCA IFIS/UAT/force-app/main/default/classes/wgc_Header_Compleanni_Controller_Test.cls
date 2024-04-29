@isTest
public with sharing class wgc_Header_Compleanni_Controller_Test {
    public wgc_Header_Compleanni_Controller_Test() {

    }
    @isTest
    public static void test_method(){
        
        Test.startTest();
        wgc_Header_Compleanni_Controller.countCompleanni();
        Test.stopTest();
    }
}