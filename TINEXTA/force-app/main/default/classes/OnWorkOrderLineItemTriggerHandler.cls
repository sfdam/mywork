/*
 * @author: @Lutech
 * @Created Date: 18/05/2022
 * @uses:
 	*onWorkOrderTriger 
 * @history:
 	* Lutech - 18/05/2022: Task reopening management v1.0 
*/

public class OnWorkOrderLineItemTriggerHandler {
    
    //gestione ripetizione trigger
	public static Boolean disableWorkOrderLineItemTrigger = false;

    public static void checkForStatusUpdating(Map<Id, WorkOrderLineItem> newMap, Map<Id, WorkOrderLineItem> oldMap) {
		//variables        
        Map<Id, String> woToClose = new Map<Id, String>();
        map<id, double> woPositionTask = new map<id, double>();
        
        for(WorkOrderLineItem woItem : newMap.values()) {
            //checking for status changes
            if(woItem.Status != null &&
               woItem.Status != oldMap.get(woItem.Id).Status &&
               oldMap.get(woItem.Id).Status == 'Completato') {
                
            	//Status changed, so go ahead
            	//Se riapro il task, aggiorno il work order padre con lo status indicato sul task
            	woToClose.put(woItem.WorkOrderId, woItem.WRT_Work_Order_Status__c);
                if(woPositionTask.get(woItem.WorkOrderId) == null || woPositionTask.get(woItem.WorkOrderId) > woItem.WRT_Position__c) woPositionTask.put(woItem.WorkOrderId, woItem.WRT_Position__c);
        	}
        }
        if(woToClose.size() > 0) {
            reopenWorkOrdersAndTask(woToClose,woPositionTask);
        }
        //add riapertura task status successiva? rivedere codice e funzionamento
        
    } 
    
    public static void reopenWorkOrdersAndTask(Map<Id, String> woToClose, map<id, double> woPositionTask) {
        
        List<WorkOrder> workOrdersList = new List<WorkOrder>();
        List<WorkOrder> workOrdersListToUpdate = new List<WorkOrder>();
        map<string,list<string>> statusWok = new map<string,list<string>>();
        set<string> statusWOSet = new set<string>();

        Schema.DescribeFieldResult fieldResult = WorkOrder.Status.getDescribe();
        List<Schema.PicklistEntry> staus = fieldResult.getPicklistValues(); 
        system.debug(staus);
        list<string> pickList = new list<string>();
        for(Schema.PicklistEntry pik : staus)
        {
            pickList.add(pik.getValue());
        }

		for(WorkOrder workOrder : [SELECT ID, Status
                                    FROM WorkOrder
                                    WHERE ID in :woToClose.keySet()]) {
            statusWok.put(workorder.id, new list<string>{woToClose.get(workOrder.Id), workorder.status});
            workOrder.Status = woToClose.get(workOrder.Id);
            workOrdersListToUpdate.add(workOrder);
            //metto nel set i valori della lista da -1 a l'indice più piccolo degli stati del workorder
            
            for(string pik : pickList)
            {
                //system.debug('statusPick < '+statusWok[1]);
                if(pickList.indexOf(woToClose.get(workOrder.Id)) < pickList.indexOf(pik) && !statusWOSet.contains(pik))
                {
                    statusWOSet.add(pik);
                }
            }
        }

        /*if(statusWok.size()> 1)
        {
            for(string pik : pickList)
            {
                system.debug('statusPick < '+statusWok[1]);
                if(pickList.indexOf(statusWok[0]) <= pickList.indexOf(pik) && !statusWok.contains(pik))
                {
                    statusWok.add(pik);
                }
            }
        }*/

        Id woliRecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosbyDeveloperName().get('WRT_Task').getRecordTypeId();

        Map<String, WorkOrderLineItem> woliMap = new map<string, WorkOrderLineItem>([SELECT id, workorderid, 
                                                                    status, WRT_Work_Order_Status__c, WRT_Position__c
                                                                    FROM workorderlineitem 
                                                                    WHERE workorderid in :woToClose.keySet()
                                                                    and (status = 'Completato'
                                                                    or status = 'Chiuso'
                                                                    or status = 'Annullato'
                                                                    or status = 'Impossibile completare')
                                                                    and WRT_Required__c = true
                                                                    and recordtypeid = :woliRecordTypeId
                                                                    and WRT_Work_Order_Status__c in :statusWOSet]);
        System.debug(woliMap);
        
        if(workOrdersListToUpdate.size() > 0) {
            OnWorkOrderTriggerHandler.disableWorkOrderTrigger = true;
            Database.SaveResult[] results = Database.update(workOrdersListToUpdate, false);
            for(Database.SaveResult result : results) {
                if(result.isSuccess()) {
                    System.debug('This id was updated correctly: ' + result.getId());
                } else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : result.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Work Order field that affected this error: ' + err.getFields());
                    }
                }
            }
            for(WorkOrderLineItem wokLine : woliMap.values())
            {
                if(wokLine.WRT_Position__c > woPositionTask.get(wokLine.WorkOrderId))
                {
                    wokLine.Status = 'Nuovo';
                }
            }
            OnWorkOrderLineItemTriggerHandler.disableWorkOrderLineItemTrigger = true;
            update woliMap.values();
        }  
    }
}