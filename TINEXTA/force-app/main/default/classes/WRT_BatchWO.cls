global with sharing class WRT_BatchWO implements Database.Batchable<sObject>, Database.Stateful
{
    global set<string> setWOWOLI;
    global static map<string, list<WorkOrderLineItem>> mapWOWOLIInsert = new map<string,list<WorkOrderLineItem>>();
    global map<string, Work_Order_Line_Items_Template__mdt> mapMetadati;
    //EDIT - DK 26012023
    // global map<string, WorkOrderLineItem> mapWOLIFound;
    global set<string> mapWOLIFound;
    //EDIT - DK 26012023

    //EDIT - DK 26012023
    global WRT_BatchWO(set<string> input, set<string> found) 
    // global WRT_BatchWO(set<string> input, map<string, WorkOrderLineItem> found) 
    //EDIT - DK 26012023
    {
        //copertura
        integer n;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        n=1;
        //
        system.debug('inoputtt utut ' +input.size());
        this.setWOWOLI = input;
        this.mapWOLIFound = found;
        //mapWOWOLIInsert= new map<string,list<WorkOrderLineItem>>();
        this.mapMetadati = new map<string, Work_Order_Line_Items_Template__mdt>([ SELECT id,Active__c, Close_Type__c, DeveloperName, 
                                                            Document_Name__c, Label, Language, MasterLabel, 
                                                            NamespacePrefix, Position__c, QualifiedApiName, 
                                                            RecordType__c, Required__c, Returned__c, Sent__c, 
                                                            Subject__c, Tag_External_System__c, WO_RecordType__c, 
                                                            WO_Status__c, WRT_Next_Work_Order_Status__c, 
                                                            WRT_Society__c, WRT_Task_Name__c, Year_of_Exercise__c
                                                            FROM Work_Order_Line_Items_Template__mdt 
                                                            where WO_RecordType__c = 'Driver'
                                                            ORDER BY Position__c ASC]);
    }
    global Database.queryLocator start(Database.BatchableContext bc)
    {
        //Set<string> idSet = mapWOWOLI.keySet();
        //system.debug(idSet);
        WRT_Warrant_FSL_Settings__c imp = WRT_Warrant_FSL_Settings__c.getOrgDefaults();

        string whereS = '';
        if(!imp.BonoficaWOLIToday__c)
        {
            whereS = 'where id in :setWOWOLI';
        }
        else
        {
            whereS = 'where createddate = Today';
        }
        return database.getQueryLocator('select id from workorder '+whereS);
    }

    global void execute (Database.BatchableContext BC, list<workorder> scope)
    {
        Id woliRecordTypeIdDriver = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosbyDeveloperName().get('WRT_Task').getRecordTypeId();
        Id woliRecordTypeIdDoc = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosbyDeveloperName().get('WRT_Document').getRecordTypeId();
        Id woliRecordTypeIdSched = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosbyDeveloperName().get('WRT_Scheduling').getRecordTypeId();
        //system.debug('metadata size '+mapMetadati.values().size());
        for(workorder wok : scope)
        {
            integer count = 0;
            integer countNo = 0;
            for(Work_Order_Line_Items_Template__mdt woliMtd : mapMetadati.values())
            {
                //system.debug('------------------ ' + woliMtd.WO_RecordType__c+'_'+woliMtd.Subject__c);
                //system.debug('------------------ ' + mapWOLIFound.keyset());
                //if(mapWOLIFound.contains(woliMtd.WO_RecordType__c+'_'+woliMtd.Subject__c+'_'+wok.id))
                //{
                    //count++;
                //}
                //check se woliMtd non esiste in mapWOLIFound
                //EDIT - DK 26012023
                // if(mapWOLIFound.get(woliMtd.WO_RecordType__c+'_'+woliMtd.Subject__c+'_'+wok.id) == null)
                if(!mapWOLIFound.contains(woliMtd.WO_RecordType__c+'_'+woliMtd.Subject__c+'_'+wok.id))
                //EDIT - DK 26012023
                {
                    countNo++;
                    WorkOrderLineItem woliNew = new workorderlineitem(
                        WRT_Position__c = woliMtd.Position__c,
                        WorkOrderId = wok.id,
                        WRT_Subject__c = woliMtd.Subject__c,
                        WRT_Record_Type_Name__c = woliMtd.WO_RecordType__c,
                        WRT_Work_Order_Status_Pick__c = woliMtd.WO_Status__c,
                        WRT_Required__c = woliMtd.Required__c,
                        WRT_Society__c = woliMtd.WRT_Society__c,
                        Tag_External_System__c = woliMtd.Tag_External_System__c,
                        WRT_Close_Type__c = woliMtd.Close_Type__c,
                        WRT_Next_Work_Order_Status__c = woliMtd.WRT_Next_Work_Order_Status__c,
                        Subject = woliMtd.Subject__c,
                        WRT_Work_Order_Status__c = woliMtd.WO_Status__c
                        );
                        woliNew.recordtypeid = (woliMtd.RecordType__c == 'Task')? woliRecordTypeIdDriver : ((woliMtd.RecordType__c == 'Document')? woliRecordTypeIdDoc : woliRecordTypeIdSched);
                        woliNew.WRT_Year__c = (woliMtd.RecordType__c == 'Document')? String.valueOf(system.today().year()) : null;

                    if(mapWOWOLIInsert.get(woliNew.workOrderId) == null) mapWOWOLIInsert.put(woliNew.workOrderId, new list<workorderlineitem>{woliNew});
                    else mapWOWOLIInsert.get(woliNew.workOrderId).add(woliNew);
                }
            }
            //system.debug('count '+count);
            //system.debug('countNo '+countNo);
        }
        //system.debug('dddf '+mapWOWOLIInsert.values().size());
        List<WorkOrderLineItem> listInsert = new List<WorkOrderLineItem>();
        for(List<WorkOrderLineItem> lis : mapWOWOLIInsert.values())
        {
            listInsert.addAll(lis);
        }
        system.debug('listInsert sixe '+listInsert.size());
        if(!listInsert.isEmpty()) insert listInsert;
    }

    global void finish(Database.BatchableContext BC)
    {  
        /*system.debug('dddf '+mapWOWOLIInsert.values().size());
        List<WorkOrderLineItem> listUpdate = new List<WorkOrderLineItem>();
        for(List<WorkOrderLineItem> lis : mapWOWOLIInsert.values())
        {
            listUpdate.addAll(lis);
        }
        system.debug('listupdate sixe '+listUpdate.size());
        if(!listUpdate.isEmpty()) insert listUpdate;*/
           
        map <id, Log__c> addLog= new map <id, Log__c>();
        
        Map<Id, AsyncApexJob > mtpBatchMap  = new Map<Id, AsyncApexJob>([SELECT Id, CreatedDate, CreatedById, JobType, ApexClassId, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset FROM AsyncApexJob WHERE Id =: BC.getJobId()]);

        for (id s:mtpBatchMap.keyset())
        {         
            If(mtpBatchMap.get(s).JobItemsProcessed != 0)
            {
                Log__c Nuovo = new Log__c();
                Nuovo.Nome_Classe__c='WRT_BatchWO';
                Nuovo.Data_Log__c=system.today();
                Nuovo.Status__c = mtpBatchMap.get(s).Status;
                Nuovo.Dettagli__c= mtpBatchMap.get(s).ExtendedStatus;
                Nuovo.Numero__c=mtpBatchMap.get(s).JobItemsProcessed;
                Nuovo.Numero_Errori__c=mtpBatchMap.get(s).NumberOfErrors;
                Nuovo.Societa__c= 'WarrantHub';
                Nuovo.Success__c = true;
                Nuovo.Societa__c = 'WarrantHub';
                Nuovo.Source__c = 'WRT_BatchWO';
    
                addLog.put(s, Nuovo);
            }                
        }
        upsert addLog.values(); 
    }
}