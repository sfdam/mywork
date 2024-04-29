/**
 * @description       : 
 * @author            : alessandro.dinardo@lutech.it
 * @group             : tengroup
 * @last modified on  : 26-01-2024
 * @last modified by  : alessandro.dinardo@lutech.it
 * description        : classe test di AggiornaMassivamenteTagQueueable
**/

@isTest
public   class AggiornaMassivamenteTagQueueableTest {
     
    @isTest
    public static void executeQueueable(){

         
		Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpAggiornaMassivamenteTagQueueable());
        System.enqueueJob(new AggiornaMassivamenteTagQueueable());
        Test.stopTest();
    }
    
   
}