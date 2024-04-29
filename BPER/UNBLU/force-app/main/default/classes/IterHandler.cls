@RestResource(urlMapping='/iterhandler')
global class IterHandler {
    
    @HttpPost
    global static String annullater(){

        List<String> listIdIterAnnullati = new  List<String>();
        List<WorkOrder> listWorkOrder = new  List<WorkOrder>();
        System.debug('GB START iterhandler Annullato');
        RestRequest req = RestContext.request;
        System.debug('GB BODY: ' + (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString()));
        Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        Savepoint sp = Database.setSavepoint();

        for(String i: bodyMap.keySet()){
            listIdIterAnnullati.add(i);
        }
           
        if(listIdIterAnnullati.size()>0)
        {
            System.debug('GB Update su lista workorder');
            for(String i:listIdIterAnnullati)
            {
                System.debug('ID class Iterhandler ' +i);
                WorkOrder wo = new WorkOrder();
                wo.id=i;
                wo.status='Annullato';
                listWorkOrder.add(wo);
            }
            try
            {
                
                update listWorkOrder;
                return JSON.serialize(new Map<String, Object>());
            }catch (Exception ex) {
                Database.rollback(sp);
                System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
                return JSON.serialize(new Map<String, Object>{'errorMessage' => ex.getMessage()});
            }
        }
        
        return JSON.serialize(new Map<String, Object>());

       /* String recordId = (String) bodyMap.get('recordId');
        Savepoint sp = Database.setSavepoint();
        try {
            
            update new WorkOrder(Id = recordId, Status = 'Annullato');
            return JSON.serialize(new Map<String, Object>());
        } catch (Exception ex) {
            
            Database.rollback(sp);
            System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
            return JSON.serialize(new Map<String, Object>{'errorMessage' => ex.getMessage()});
        }*/
         
    }

    @HttpPatch
    global static String closeIter(){

        System.debug('DK START iterhandler');
        RestRequest req = RestContext.request;
        System.debug('DK req.requestBody.toString(): ' + req.requestBody);
        Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(req.requestBody.toString());
        String recordId = (String) bodyMap.get('recordId');
        String status = bodyMap.containsKey('status') ? (String) bodyMap.get('status') : 'Removed';
        String queueId = bodyMap.containsKey('queueId') ? (String) bodyMap.get('queueId') : '';
        Savepoint sp = Database.setSavepoint();
        try {
            List<Approval.ProcessWorkitemRequest> pwirList = new List<Approval.ProcessWorkitemRequest>();
            System.debug('ID ProcessInstance'+ ProcessInstance.Status);
            System.debug('ProcessInstance.TargetObjectId'+  ProcessInstance.TargetObjectId);
            System.debug('ProcessInstance.Status'+ ProcessInstance.Status);
            System.debug('ProcessInstance.TargetObjectId'+ ProcessInstance.TargetObjectId);

            for(ProcessInstanceWorkitem p: [SELECT Id, ProcessInstance.TargetObjectId, ActorId
                                                    FROM ProcessInstanceWorkitem
                                                    WHERE ProcessInstance.Status='Pending' AND ProcessInstance.TargetObjectId =: recordId]){

                if(String.isBlank(queueId) || (!String.isBlank(queueId) && queueId == p.ActorId)){

                    Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
                    result.setAction(status);          
                    result.setWorkitemId(p.Id);
                    pwirList.add(result);
                }                                     
            }

            Approval.process(pwirList);
            return JSON.serialize(new Map<String, Object>());
        } catch (Exception ex) {
            Database.rollback(sp);
            System.debug('DK Exception: ' + ex  + '; Stacktrace: ' + ex.getStackTraceString());
            return JSON.serialize(new Map<String, Object>{'errorMessage' => ex.getMessage()});
        }
    }
}