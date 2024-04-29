@isTest
public with sharing class WGC_Header_News_Controller_Test {
    @isTest
    public static void Test_Metodi1(){
        WGC_News__c news = new WGC_News__c(Stato__c = 'Attiva');
        insert news;
        Test.startTest();
        WGC_Header_News_Controller.getNews();
        Test.stopTest();
    }

    @isTest
    public static void Test_Metodi2(){
        
        Test.startTest();
        WGC_Header_News_Controller.getNews();
        Test.stopTest();
    }

    
}