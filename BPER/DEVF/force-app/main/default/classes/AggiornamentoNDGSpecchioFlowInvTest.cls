@isTest
public class AggiornamentoNDGSpecchioFlowInvTest {
@TestSetup
    static void setup(){
        
        Endpoint__c endPoint = new Endpoint__c();
        endPoint.Name = 'GestioneSpecchioV1';
        endPoint.Method__c = 'POST';
        endPoint.Timeout__c = 120000;
        endPoint.Endpoint__c = 'Test';
        insert endPoint;

        Account acct2 = new Account (Name = 'ACE Chemicals', ModelloDiServizio__c = 'Family', CRM_NDG__c = '112358');
        insert acct2;

        Contact cntct2 = new Contact();
        cntct2.FirstName = 'Giuseppe';
        cntct2.LastName = 'Scopece';
        cntct2.AccountId = acct2.Id;
        insert cntct2;

        

        String profileId = [SELECT id FROM Profile WHERE Id =: UserInfo.getProfileId() LIMIT 1].id;

        User testUser = AllDataFactory.getUser('1123', profileId, 'Family');       

        insert testUser;

     
    }

    @isTest
    public static void test(){
        Account acc = [SELECT Id FROM Account LIMIT 1];
		
        User testUser = new User();       
        
        testUser.Id=UserInfo.getUserId();
        testUser.abi__c='05387';
        testUser.applicazione__c='Salesforce';
        testUser.terminale__c='XXX';
        testUser.ip__c='test';
        testUser.FederationIdentifier='test';
        testUser.idced__c='test';
        update testUser;

        AggiornamentoNDGSpecchioFlowInvocable.FlowInputs inputs = new AggiornamentoNDGSpecchioFlowInvocable.FlowInputs();

        inputs.apiRequestName = 'GestioneSpecchioV1';
        inputs.certificationName = 'salesforceprodclient2024';
        inputs.disableLog = false;
        inputs.AccountIdBCP = 'Responded';
        inputs.AccountIdBPER = 'test';
        inputs.ndgBCP = '123';
        inputs.ndgBPER = '123';
        inputs.cedFil = '123';
		List<AggiornamentoNDGSpecchioFlowInvocable.FlowOutputs> outputs;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        System.runAs(testUser){
        	outputs = AggiornamentoNDGSpecchioFlowInvocable.aggiornaNDGSpecchio(new List<AggiornamentoNDGSpecchioFlowInvocable.FlowInputs>{inputs});
		}
        Test.stopTest();
        System.assertEquals(True, outputs[0].response);
       
        
    }
    
    
}