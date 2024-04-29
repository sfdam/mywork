@isTest
public class ApprovazioniControllerTest 
{
	@testsetup
    private static void makeData()
    {
        //Funzionalita__c fun = DataFactoryNew.createCustomSettings();
        //fun.Disabilita_Trigger_WorkOrder__c = true;
        //fun.Disabilita_tutti_i_workflow__c = true;
        //fun.Disabilita_tutti_i_process_builder__c = true;
        //update fun;

		//processinstance procc = new processinstance();
        //ProcessInstanceWorkitem proc = new ProcessInstanceWorkitem(ProcessInstance.TargetObjectId,
                                                                  //processinstanceid);
                                                                  
        //account [] acc = DataFactoryNew.create_Account();
        //SBQQ__Quote__c quote =  DataFactoryNew.createquote(acc[0]);
        
        //Approvazioni__c app = new Approvazioni__c(Approval_Step__c = 'In approvazione',
                                                 //Quote__c = quote.id);
        //insert app;
    }
    
   @isTest
    private static void testApp()
    {
        //approvazioni__c app = [select id from approvazioni__c];
        // Create an approval request for the account
        //Approval.ProcessSubmitRequest req1 = 
        //new Approval.ProcessSubmitRequest();
        //req1.setComments('Submitting request for approval.');
        //req1.setObjectId(app.id);
        
        // Submit on behalf of a specific submitter
        //req1.setSubmitterId(user1.Id); 
        
        // Submit the record to specific process and skip the criteria evaluation
        //req1.setProcessDefinitionNameOrId('Approvazione_4_Livelli_COMM');
        //req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        //Approval.ProcessResult result = Approval.process(req1);
        
        sobject[] sov = ApprovazioniController.getApprovazioni(system.UserInfo.getUserId());
    }
}