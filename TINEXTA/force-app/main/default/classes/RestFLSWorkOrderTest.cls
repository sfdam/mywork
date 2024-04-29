@isTest
public class RestFLSWorkOrderTest 
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
        
        opportunity opp = [select id, probability from opportunity limit 1];
        opp.probability = 50;
        update opp;
        
        workorder[] wok = [select id from workorder];
        
        Id rid= [SELECT Id from RecordType where Name = 'Driver' AND SObjectType = 'WorkOrder' LIMIT 1].Id;
        
        req.requestURI = '/v1.0/InserimentoAggiornamentoWorkOrder';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('{"WorkOrders": [{"WRT_Gestione_numero_importante_fatture__c": 60,'+
                                       '"Id" : "'+wok[0].id+'",'+
                                       '"WRT_Numero_fornitori_extra_muros__c": 10,'+
                                       '"WRT_Numero_progetti_linee_sinottica__c": 10,'+
                                       '"WRT_Intragroup_Presence__c": true,'+
                                       '"Status": "New",'+
                                       '"WorkOrderLineItems":['+
                                               '{'+
                                               '"Status": "Nuovo"'+
                                               '}'+
                                           ']'+
                                       '}'+
                                       ','+
                                       '{"WRT_Automatically_created__c" : true,'+
                                            '"RecordTypeId" : "'+ rid +'",'+
                                           '"WRT_Intragroup_Presence__c": true,'+
                                           '"Status": "New",'+
                                           '"WorkOrderLineItems":['+
                                               '{'+
                                               '"Status": "Nuovo"'+
                                               '}'+
                                           ']'+
                                       '}'+
                                       ']'+
                                       '}');
        RestContext.request = req;
        RestContext.response = res; 

        Test.startTest();
            RestFLSWorkOrder.doPost();
        Test.stopTest();
    }
}