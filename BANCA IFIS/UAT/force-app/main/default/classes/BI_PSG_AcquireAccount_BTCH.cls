global class BI_PSG_AcquireAccount_BTCH implements Database.Batchable<WorkflowSGA__c>, Database.AllowsCallouts{
	
	global BI_PSG_AcquireAccount_BTCH() {
		
	}
	
	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global List<WorkflowSGA__c> start(Database.BatchableContext context) {

		String F_Stato = 'PRE_VALUTAZIONE_CLIENTE';
		String F_IDAccount = null;
		String F_ErroriTecnici = null;
        
		List<WorkflowSGA__c> actualWorkflows = new List<WorkflowSGA__c> ();
            
        actualWorkflows = [SELECT id, Stato__c, Name, Ragione_Sociale__c, PartitaIVA__c, DataInvioIfis__c, IDAccount__c FROM WorkflowSGA__c where Stato__c =:F_Stato and IDAccount__c =:F_IDAccount and Errori_Tecnici__c =:F_ErroriTecnici];
  
		return actualWorkflows;
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<WorkflowSGA__c> scope) {	

		for (WorkflowSGA__c actualWorkflow : scope) {

			bifis_crm_c_SGACommonCtrl.censisciAccount(actualWorkflow);

		}

	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		
	}
}