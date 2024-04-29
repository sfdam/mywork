@isTest(SeeAllData=true)
public class InvocableEnableCPQ_Test {

    @isTest static void testinsert() {
        List<InvocableEnableCPQ.ActionRequest> arList = new List<InvocableEnableCPQ.ActionRequest>();
        InvocableEnableCPQ.ActionRequest arTest = new InvocableEnableCPQ.ActionRequest();

 
        
        arTest.Check = 'True';
       
        
        Test.startTest();
        List<String> res = InvocableEnableCPQ.AccensioneCPQ(arList);
        System.debug('Result: ' + res[0]);
        //System.assertEquals('Segnalazione inserita correttamente', res[0]);
        Test.stopTest();
    }
}