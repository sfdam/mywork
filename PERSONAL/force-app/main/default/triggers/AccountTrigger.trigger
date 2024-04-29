trigger AccountTrigger on Account (after update) {

    List<Id> accountToApproveList = new List<Id>();
    List<WorkOrder> woListToInsert = new List<WorkOrder>();
    List<WorkOrderLineItem> woliListToInsert = new List<WorkOrderLineItem>();
    Map<String, account> accountMap = new Map<String, account>();
    List<Id> oppToApproveList = new List<Id>();
    if(Trigger.isUpdate){

        if(Trigger.isAfter){

            for(account account : Trigger.new){

                if(Trigger.oldMap.get(account.Id).PTF_Portafoglio__c != account.PTF_Portafoglio__c &&
                    !String.isBlank(Trigger.oldMap.get(account.Id).PTF_Portafoglio__c) &&
                    !String.isBlank(account.PTF_Portafoglio__c)){


                    WorkOrder wo = new WorkOrder();
                    wo.OldWallet__c = Trigger.oldMap.get(account.Id).PTF_Portafoglio__c;
                    wo.NewWallet__c = account.PTF_Portafoglio__c;
                    wo.Status = 'Primo Step';
                    wo.OwnerId = UserInfo.getUserId();
                    accountMap.put(Trigger.oldMap.get(account.Id).PTF_Portafoglio__c + '_' + account.PTF_Portafoglio__c, account);
                    woListToInsert.add(wo);
                }
            }
            
            insert woListToInsert;

            for(WorkOrder wo : woListToInsert){

                if(accountMap.containsKey(wo.OldWallet__c + '_' + wo.NewWallet__c)){

                    WorkOrderLineItem woli = new WorkOrderLineItem();
                    woli.WorkOrderId = wo.Id;
                    woli.Account__c = accountMap.get(wo.OldWallet__c + '_' + wo.NewWallet__c).Id;
                    oppToApproveList.add(wo.Id);
                    woliListToInsert.add(woli);
                }
            }

            insert woliListToInsert;

            if(!oppToApproveList.isEmpty()){

                ApproverHandler.initApprovalProcess(oppToApproveList);
            }
        }
    }
}