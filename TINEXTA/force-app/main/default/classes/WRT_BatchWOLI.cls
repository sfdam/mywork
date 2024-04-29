global class WRT_BatchWOLI implements Database.Batchable<sObject>, Database.Stateful
{
    public map<string, Work_Order_Line_Items_Template__mdt> metadataIperMap;
    public map<string, Work_Order_Line_Items_Template__mdt> metadataDriverMap;
    public map<string, Work_Order_Line_Items_Template__mdt> metadataTaxAssessmentMap;
    global static map<string, list<WorkOrderLineItem>> mapWOWOLI = new map<string, list<WorkOrderLineItem>>();
    global set<string> wokId = new set<string>();
    global map<string, WorkOrderLineItem> mapWOLIFound = new map<string, WorkOrderLineItem>();
    global set<string> setWOLIFound = new set<string>();

    global WRT_BatchWOLI()
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
        metadataIperMap = new map<string, Work_Order_Line_Items_Template__mdt>();
        metadataDriverMap = new map<string, Work_Order_Line_Items_Template__mdt>();
        metadataTaxAssessmentMap = new map<string, Work_Order_Line_Items_Template__mdt>();
        //mapWOWOLI = 
        //mapWOLIFound = new map<string, WorkOrderLineItem>();

        for(Work_Order_Line_Items_Template__mdt woliMtd : [ SELECT id,Active__c, Close_Type__c, DeveloperName, 
                                                            Document_Name__c, Label, Language, MasterLabel, 
                                                            NamespacePrefix, Position__c, QualifiedApiName, 
                                                            RecordType__c, Required__c, Returned__c, Sent__c, 
                                                            Subject__c, Tag_External_System__c, WO_RecordType__c, 
                                                            WO_Status__c, WRT_Next_Work_Order_Status__c, 
                                                            WRT_Society__c, WRT_Task_Name__c, Year_of_Exercise__c
                                                            FROM Work_Order_Line_Items_Template__mdt 
                                                            where WO_RecordType__c = 'Driver'
                                                            ORDER BY Position__c ASC])
        {
            /*if(woliMtd.WO_RecordType__c == 'Iper')
            {
                metadataIperMap.put(woliMtd.Subject__c,woliMtd);
            }
            else */if(woliMtd.WO_RecordType__c == 'Driver')
            {
                metadataDriverMap.put(woliMtd.Subject__c,woliMtd);
            }
            //else if(woliMtd.WO_RecordType__c == 'Tax Assessment')
            //{
                //metadataTaxAssessmentMap.put(woliMtd.Subject__c,woliMtd);
            //}
        }

        //system.debug(metadataDriverMap);
    }

    global Database.queryLocator start(Database.BatchableContext bc)
    {
        WRT_Warrant_FSL_Settings__c imp = WRT_Warrant_FSL_Settings__c.getOrgDefaults();

        /**
            * @description: il metodo esegue una query includendo in automatico tutti i campi dell'oggetto
            * @param objectApiName: nome API oggetto su cui eseguire la query
            * @return: lista di risultati di tipo "sObject" generico. È possibile fare il cast del risulta in una lista dell'oggetto specifico
            */ 
        //reperisco tutti i campi dell'oggetto
        //Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        //Map<String, Schema.SObjectField> fieldMap = schemaMap.get('WorkOrderLineItem').getDescribe().fields.getMap();
        //list<string> list_field = new list<string>(fieldMap.keyset());
    
        string qrSelect = 'select Subject, WRT_Position__c, WRT_Required__c, Tag_External_System__c, recordtypeid,'+
                        ' WRT_Work_Order_Status_Pick__c, WRT_Society__c, WRT_Close_Type__c, WRT_Next_Work_Order_Status__c,'+
                        ' WRT_Work_Order_Status__c, WRT_Record_Type_Name__c, WRT_Subject__c, WorkOrderId';//+string.join(list_field , ',');//SELECT con tutti i campi dell'oggetto
        string qrFrom = ' from WorkOrderLineItem';//FROM oggetto
        string qrWhere = ' where '+imp.Where_query_batch_WOLI__c;//WRT_Record_Type_Name__c = \'Driver\''; //WHERE filtri query
        string qrOrder = ' order by '; //ORDER BY ordinamento risultati query
        
        //creo una variabile di tipo "Tipo lista<Oggetto>"
        System.Type listType = System.Type.forName('List<WorkOrderLineItem>');
        //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
        List<SObject> result = (List<SObject>)listType.newInstance();
    
        //aggiungere where/order se correttamente valorizzati nelle variabili
        //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
        //result = database.queryLocator(qrSelect + qrFrom /*+ qrWhere + qrOrder*/);
    
        return database.getQueryLocator(qrSelect + qrFrom + qrWhere /*+ qrOrder*/);
    }
    global void execute (Database.BatchableContext BC, List<workorderlineitem> scope)
    {
        Id woliRecordTypeIdDriver = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosbyDeveloperName().get('WRT_Task').getRecordTypeId();
        Id woliRecordTypeIdDoc = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosbyDeveloperName().get('WRT_Document').getRecordTypeId();
        Id woliRecordTypeIdSched = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosbyDeveloperName().get('WRT_Scheduling').getRecordTypeId();
        for(WorkOrderLineItem woli : scope)
        {
            //ciclo woli e controllo se ci sta un woli che matcha con i metadati (filtro per recordtype)
            //aggiungo poi a mappa di lista wo-woli per upsert
            boolean found = false;
            map<string, Work_Order_Line_Items_Template__mdt> mapMetadati;
            string woliSub = woli.WRT_Subject__c;
                
            switch on woli.WRT_Record_Type_Name__c
            {
                when  'Iper'
                {
                    //system.debug('iper '+ metadataIperMap);
                    if(metadataIperMap.get(woliSub) != null)
                    {
                        //found = true;

                        mapMetadati = metadataIperMap;
                    }
                }
                when 'Driver'
                {
                    //system.debug('Driver '+ metadataDriverMap);
                    if(metadataDriverMap.get(woliSub) != null)
                    {
                        found = true;

                        mapMetadati = metadataDriverMap;
                    }
                }
            }
            if(found)
            {
                woli.Subject = mapMetadati.get(woliSub).Subject__c;
                woli.WRT_Required__c = mapMetadati.get(woliSub).Required__c;
                woli.Tag_External_System__c = mapMetadati.get(woliSub).Tag_External_System__c;
                woli.recordtypeid = (mapMetadati.get(woliSub).RecordType__c == 'Task')? woliRecordTypeIdDriver : ((mapMetadati.get(woliSub).RecordType__c == 'Document')? woliRecordTypeIdDoc : woliRecordTypeIdSched);
                woli.WRT_Position__c = mapMetadati.get(woliSub).Position__c;
                woli.WRT_Work_Order_Status_Pick__c = mapMetadati.get(woliSub).WO_Status__c;
                woli.WRT_Society__c = mapMetadati.get(woliSub).WRT_Society__c;
                woli.WRT_Close_Type__c = mapMetadati.get(woliSub).Close_Type__c;
                woli.WRT_Next_Work_Order_Status__c = mapMetadati.get(woliSub).WRT_Next_Work_Order_Status__c;
                woli.WRT_Work_Order_Status__c = mapMetadati.get(woliSub).WO_Status__c;
                woli.WRT_Record_Type_Name__c = mapMetadati.get(woliSub).WO_RecordType__c;

                woli.WRT_Subject__c = mapMetadati.get(woliSub).Subject__c;

                if(mapWOWOLI.get(woli.workOrderId) == null) mapWOWOLI.put(woli.workOrderId, new list<workorderlineitem>{woli});
                else mapWOWOLI.get(woli.workOrderId).add(woli);

                //mapWOLIFound.put(mapMetadati.get(woliSub).WO_RecordType__c+'_'+mapMetadati.get(woliSub).Subject__c+'_'+woli.workOrderId, woli);
                setWOLIFound.add(mapMetadati.get(woliSub).WO_RecordType__c+'_'+mapMetadati.get(woliSub).Subject__c+'_'+woli.workOrderId);
                //system.debug('test '+setWOLIFound.size());
            }
        }

        //system.debug('ddd '+mapWOWOLI.values().size());
        List<WorkOrderLineItem> listUpdate = new List<WorkOrderLineItem>();
        for(List<WorkOrderLineItem> lis : mapWOWOLI.values())
        {
            listUpdate.addAll(lis);
        }
        wokId.addAll(mapWOWOLI.keyset());
        system.debug('listupdate sixe '+listUpdate.size());
        if(!listUpdate.isEmpty()) update listUpdate;
    }
    global void finish(Database.BatchableContext BC)
    {  
        /*(system.debug('ddd '+mapWOWOLI.values().size());
        List<WorkOrderLineItem> listUpdate = new List<WorkOrderLineItem>();
        for(List<WorkOrderLineItem> lis : mapWOWOLI.values())
        {
            listUpdate.addAll(lis);
        }
        if(!listUpdate.isEmpty()) update listUpdate;*/

        map <id, Log__c> addLog= new map <id, Log__c>();
        
        Map<Id, AsyncApexJob > mtpBatchMap  = new Map<Id, AsyncApexJob>([SELECT Id, CreatedDate, CreatedById, JobType, ApexClassId, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset FROM AsyncApexJob WHERE Id =: BC.getJobId()]);

        for (id s:mtpBatchMap.keyset())
        {         
            If(mtpBatchMap.get(s).JobItemsProcessed != 0)
            {
                Log__c Nuovo = new Log__c();
                Nuovo.Nome_Classe__c='WRT_BatchWOLI';
                Nuovo.Data_Log__c=system.today();
                Nuovo.Status__c = mtpBatchMap.get(s).Status;
                Nuovo.Dettagli__c= mtpBatchMap.get(s).ExtendedStatus;
                Nuovo.Numero__c=mtpBatchMap.get(s).JobItemsProcessed;
                Nuovo.Numero_Errori__c=mtpBatchMap.get(s).NumberOfErrors;
                Nuovo.Societa__c= 'WarrantHub';
                Nuovo.Success__c = true;
                Nuovo.Societa__c = 'WarrantHub';
                Nuovo.Source__c = 'WRT_BatchWOLI';
    
                addLog.put(s, Nuovo);
            }                
        }
        upsert addLog.values(); 

        //creazione woli da template
        //EDIT - DK 26012023
        WRT_BatchWO btcWO = new WRT_BatchWO(wokId, setWOLIFound);
        database.executebatch(btcWO, 10);
        //EDIT - DK 26012023
    }
}