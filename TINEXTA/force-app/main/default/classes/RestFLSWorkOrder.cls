@RestResource(urlMapping='/v1.0/InserimentoAggiornamentoWorkOrder')
global without sharing class RestFLSWorkOrder 
{
    @HttpPost
    global static ResponseWrapper doPost() 
    {
        ObjectResponseWrapper response = new ObjectResponseWrapper();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Boolean success = true;
        String msg = '';
        Integer statusCode = null;
        //String response = res;
        String jsonString = String.valueOf(req.requestBody.toString());
        string idRecordLog = '';

        map<string, Object> respMap = new map<string, object>();
        List<WorkOrderLineItem> woliInsert = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> woliUpdate = new List<WorkOrderLineItem>();
        List<WorkOrderLineItem> woliUpsert = new List<WorkOrderLineItem>();
        list<object> workOrderWoliAll = new list<object>();
        list<object> workOrderAll = new list<object>();
        try 
        {
            system.debug(res);
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());

            List<Map<String, Object>> test = new List<Map<String, Object>>();

            List<Object> workOrdersObjList = (List<Object>) body.get('WorkOrders');
            system.debug('body ' + body);
            system.debug('workOrdersObjList ' + workOrdersObjList);
            if(workOrdersObjList.size() > 0)
            {
                integer count = 0;
                for (object obj : workOrdersObjList) 
                {
                    list<object> workOrderLineItemAll = new list<object>();
                    
                    //system.debug(obj);
                    Map<String,Object> mapObj = (Map<String,Object>) obj;
                    system.debug(mapObj);

                    List<WorkOrderLineItem> woliList = (List<WorkOrderLineItem>)JSON.deserializeStrict(JSON.serialize(mapObj.remove('WorkOrderLineItems'), true), List<WorkOrderLineItem>.Class);
                    System.debug(woliList);

                    //system.debug(mapObj.remove('WorkOrderLineItems'));
                    //system.debug(mapObj);
                    /**
                     * gestione woli:
                     * - type per record type
                     */

                    //String accName = String.valueOf(mapObj.remove('AccountName'));

                    workorder wo = (workorder) JSON.deserializeStrict(JSON.serialize(mapObj, true), workorder.Class);
                    system.debug(wo);

                    /*workorder wok = new workorder();
                    wok.id = string.valueOf(mapObj.get('id'));
                    System.debug(wok);*/

                    //if id Salesforce != null Upsert
                    //id id Salesforce == null Insert
                    system.debug(wo.id);
                    if(wo.id != null && String.valueOf(wo.id) != '')
                    {
                        
                        if(woliList != null)
                        {
                            for(WorkOrderLineItem wol : woliList)
                            {
                                if(wol.ID_External_System__c != null && String.valueOf(wol.ID_External_System__c) != '')
                                {
                                    //wol.WorkOrderId = wo.id;
                                    woliUpsert.add(wol);
                                }
                                else if(wol.id != null && String.valueOf(wol.id) != '')
                                {
                                    woliUpdate.add(wol);
                                }
                                else if(wol.id == null || String.valueOf(wol.id) == '')
                                {
                                    wol.WorkOrderId = wo.id;
                                    woliInsert.add(wol);
                                }
                            }
                            insert woliInsert;
                            update woliUpdate;
                            upsert woliUpsert ID_External_System__c;
                        }
                        update wo;
                        /*for(WorkOrderLineItem woli : woliList) 
                        {
                            woli.WorkOrderId = wo.id;
                        }*/
                        idRecordLog += wo.id +',';
                        
                    }

                    if(wo.id == null || String.valueOf(wo.id) == '')
                    {
                        //wo.id = null;
                        insert wo;
                        mapObj.put('Id', wo.id);
                        idRecordLog += wo.id +',';

                        if(woliList != null)
                        {
                            for(WorkOrderLineItem wol : woliList)
                            {
                                if(wol.ID_External_System__c != null && String.valueOf(wol.ID_External_System__c) != '')
                                {
                                    //wol.WorkOrderId = wo.id;
                                    woliUpsert.add(wol);
                                }
                                else if(wol.id != null && String.valueOf(wol.id) != '')
                                {
                                    woliUpdate.add(wol);
                                }
                                else if(wol.id == null || String.valueOf(wol.id) == '')
                                {
                                    wol.WorkOrderId = wo.id;
                                    woliInsert.add(wol);
                                }
                            }
                            insert woliInsert;
                            update woliUpdate;
                            upsert woliUpsert ID_External_System__c;
                        }
                        
                    }
                    //reisnerire wo in list per aggiornre con id
                    System.debug('wo prinmt '+wo);
                    
                    mapObj.put('WorkOrderLineItems', woliList);
                }
                
                
                //inserire response con id workorder e woli creati
                response.data = new Map<String,Object>{
                    'WorkOrders' => workOrdersObjList
                };
            } 
            else if (workOrdersObjList.isEmpty())
            {
                success = false;
                throw new CalloutException('ERRORE - Lista WorkOrders vuota'); 
            } 
        } catch (CalloutException e) 
        {
            response.message = e.getMessage();
            response.success = false;
            success = false;
            System.debug(
                '@@@ error ' +
                e.getMessage() +
                ' - ' +
                e.getLineNumber()
            );
        } catch (Exception e) 
        {
            response.message =
                e.getMessage() +
                ' -- ' +
                e.getStackTraceString();
            response.success = false;
            success = false;
            System.debug(
                '@@@ error exc ' +
                e.getMessage() +
                ' - ' +
                e.getLineNumber()+
                ' '+e
            );
        }
        idRecordLog.removeEnd(',');
        insert new Log__c(
            Success__c = success,
            Societa__c = 'WarrantHub',
            Source__c = 'IntegrazioneHDR',
            Nome_Classe__c = 'RestFLSWorkOrder',
            ID_Record__c = idRecordLog,
            ErrorMessage__c = String.valueOf(response.message),
            InputPayload__c = jsonString,
            OutputPayload__c = String.valueOf(JSON.serializePretty(response,true))
        );

        return response;
    }
}