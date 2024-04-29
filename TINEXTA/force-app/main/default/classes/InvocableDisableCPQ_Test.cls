@isTest(SeeAllData=true)
public class InvocableDisableCPQ_Test {

    @isTest static void testinsert() {
        List<InvocableDisableCPQ.ActionRequest> arList = new List<InvocableDisableCPQ.ActionRequest>();
        InvocableDisableCPQ.ActionRequest arTest = new InvocableDisableCPQ.ActionRequest();

 
        
        arTest.Check = 'True';
       
        
        Test.startTest();
        List<String> res = InvocableDisableCPQ.SpegnimentoCPQ(arList);
        System.debug('Result: ' + res[0]);
        //System.assertEquals('Segnalazione inserita correttamente', res[0]);
        Test.stopTest();
    }
}