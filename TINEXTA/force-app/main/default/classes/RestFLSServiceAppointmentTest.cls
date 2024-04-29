@isTest
public class RestFLSServiceAppointmentTest 
{
	@TestSetup
    static void makeData()
    {
        //create opportunity/workorder e custom settings
        Funzionalita__c fun = DataFactoryNew.createCustomSettings();
        fun.Disabilita_Trigger_WorkOrder__c = true;
        fun.Disabilita_tutti_i_workflow__c = true;
        fun.Disabilita_tutti_i_process_builder__c = true;
        update fun;
        account[] accList = DataFactoryNew.createAccounts(1);
        opportunity[] opp = DataFactoryNew.createOpportunityWarrant(accList);
        workorder wok = DataFactoryNew.createWO(accList[0], opp[0]);
    }

    @isTest
    public static void testPost() 
    {
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        account[] acc = [select id from account];
        
        workorder[] wok = [select id from workorder];
        
        //Id rid= [SELECT Id from RecordType where Name = 'Driver' AND SObjectType = 'WorkOrder' LIMIT 1].Id;
        
        req.requestURI = '/v1.0/InserimentoServiceAppointment';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{'+
                                          '"ServiceAppointment":'+
                                            '{'+
                                                '"Subject": "Test",'+
                                                '"AccountId": "'+acc[0].Id+'",'+
                                                '"ParentRecordId": "'+wok[0].Id+'",'+
                                                '"DueDate": "2050-05-05T00:00:00.000+0000"'+
                                            '}'+
                                        '}');
        RestContext.request = req;
        RestContext.response = res; 

        Test.startTest();
            RestFLSServiceAppointment.doPost();
        Test.stopTest();
    }
    @isTest
    public static void testPostError() 
    {
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        
        account[] acc = [select id from account];
        
        workorder[] wok = [select id from workorder];
        
        //Id rid= [SELECT Id from RecordType where Name = 'Driver' AND SObjectType = 'WorkOrder' LIMIT 1].Id;
        
        req.requestURI = '/v1.0/InserimentoServiceAppointment';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{'+
                                          '"ServiceAppointment":'+
                                            '{'+
                                                '"Subject": "Test",'+
                                                '"AccountId": "'+acc[0].Id+'",'+
                                                '"ParentRecordId": "'+wok[0].Id+'",'+
                                                '"DueDate": "2020-05-05T00:00:00.000+0000"'+
                                            '}'+
                                        '}');
        RestContext.request = req;
        RestContext.response = res; 

        Test.startTest();
            RestFLSServiceAppointment.doPost();
        Test.stopTest();
    }
}