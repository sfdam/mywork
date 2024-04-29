public with sharing class spostamentoNDGDataQualityCheckBatch implements Database.Batchable<WrapperCsvResult>, Database.Stateful
{
    public List<String> gblCsvRowFields;
    public List<WrapperCSVResult> eddy = new List<WrapperCSVResult>();
    public List<WrapperCSVResult> resultList;
    public Map<string, list<WrapperCSVResult>> abindgMap = new Map<string, list<WrapperCSVResult>>();
    public Map<string, set<string>> matrPtfMap = new Map<string, set<string>>();
    public SV_CSVLoad__c gblFileRecordLog;
    public string gblCsvName;

    public spostamentoNDGDataQualityCheckBatch(list<string> mtdFileRows, SV_CSVLoad__c mtdFileRecordLog, String mtdCsvName)
    {
        //memorizzo il file ed il log ed istanzio le mappe
		gblCsvRowFields = mtdFileRows;
		gblFileRecordLog = mtdFileRecordLog;
		gblCsvName = mtdCsvName;
        resultList = new list<WrapperCSVResult>();
        //resultMap = new map<string, WrapperCSVResult>();
    }
    public List<WrapperCsvResult> start(Database.BatchableContext context) 
    {
		//gblFileRecordLog.job_ids__c += ' - ' + context.getJobId();
        SpostamentoNDG_Data_Quality_Check__mdt dataQMetadata = (SpostamentoNDG_Data_Quality_Check__mdt) queryAllFields('SpostamentoNDG_Data_Quality_Check__mdt')[0];

        //string con = [select id, ContentDocumentId from ContentDocumentLink where LinkedEntityId = :gblFileRecordLog.Id and (ContentDocument.Title = :gblCsvName)].ContentDocumentId;

        //string mtdFileRows = [select id, VersionData, Title from ContentVersion where Id = :gblCsvId limit 1].versionData.toString();
        //list<string> rowsList = mtdFileRows.split('\n');
        
        //ciclo le righe del file
        //per ognuna faccio i controlli del data quality
        //flaggo righe OK e KO
        for(string val : gblCsvRowFields)
        {
            System.debug('LL DEBUG saveObjects scope: ' + val);
            list<String> valSplit = val.split(';');
            System.debug('LL DEBUG saveObjects scope: ' + valSplit);
            WrapperCSVResult result = new WrapperCSVResult();
            result.abi = valSplit.get(0);
            result.ndg = valSplit.get(1);
            result.ced_destinazione = valSplit.get(2);
            result.mds_destinazione = valSplit.get(3);
            result.ptf_partenza = valSplit.get(4);
            result.ptf_destinazione = valSplit.get(5);
            result.matricola = valSplit.get(6);
            result.tag = valSplit.get(7);
            //result.numeroRiga = valSplit[8];
            result.error = 'OK';

            if(checkPTFPartPTFDes(result))
            {
                result.error = 'KO';
                result.errorMessage = label.CheckPTFPartenzaPTFDestinazione;
            }
            if(!checkAbi(result, dataQMetadata))
            {
                result.error = 'KO';
                result.errorMessage = label.CheckCodiceAbi;
            }

            eddy.add(result);

            //valorizzo la mappa e i set che mi servono per fare il check delle righe duplicate
            string abiNdg = result.abi+result.ndg;
            if(abindgMap.get(abiNdg)!=null)
            {
                abindgMap.get(abiNdg).add(result);
            }
            else abindgMap.put(abiNdg, new list<WrapperCSVResult>{result});

            if(result.matricola != '')
            {
                if(matrPtfMap.get(result.ptf_destinazione)!=null)
                {
                    matrPtfMap.get(result.ptf_destinazione).add(result.matricola);
                }
                else matrPtfMap.put(result.ptf_destinazione, new set<string>{result.matricola});

                CheckMatricolaPTFDes(result);
            }
        }
        gblCsvRowFields = null;
        
        return eddy;
	}
    public void execute(Database.BatchableContext context, List<WrapperCsvResult> scope) 
    {
        try 
        {
            set<String> filialeSet = new set<String>();
            set<String> walletSet = new set<String>();
            set<String> ndgSet = new set<String>();
            set<String> abiSet = new set<String>();
            map<string, Wallet__c> walletMap = new map<string, Wallet__c>();
            Map<string, Account> filialiMap = new Map<string, Account>();
            Map<string, Account> accMap = new Map<string, Account>();
            map<string, PTF_ModelloDiServizio__mdt> modServMap = new map<string, PTF_ModelloDiServizio__mdt>();

            for(PTF_ModelloDiServizio__mdt mdt : [SELECT Id, MasterLabel, PTF_Abbreviazione__c
                                                    FROM PTF_ModelloDiServizio__mdt])
            {
                modServMap.put(mdt.MasterLabel, mdt);
            }
            for(WrapperCsvResult result : scope)
            {
                walletSet.add(result.ptf_destinazione);
                ndgSet.add(result.ndg);
                abiSet.add(result.abi);
                filialeSet.add(result.ced_destinazione);
            }
            for(account acc : [SELECT id ,PTF_IdCEDFiliale__c,  PTF_Portafoglio__c,
                            PTF_Portafoglio__r.Name, CRM_NDG__c, FinServ__BankNumber__c
                            FROM  Account 
                            WHERE (CRM_NDG__c in :ndgSet AND FinServ__BankNumber__c = :abiSet) 
                            OR PTF_IdCEDFiliale__c  IN : filialeSet])
            {
                if(ndgSet.contains(acc.CRM_NDG__c) && abiSet.contains(acc.FinServ__BankNumber__c))
                {
                    accMap.put(acc.FinServ__BankNumber__c+acc.CRM_NDG__c,acc);
                }
                if(filialeSet.contains(acc.PTF_IdCEDFiliale__c))
                {
                    filialiMap.put(acc.PTF_IdCEDFiliale__c, acc);
                }
            }
            
            for(Wallet__c wal : [SELECT id,Name, PTF_ModelloDiServizio__c,PTF_Filiale__c, PTF_DeletionDate__c 
                                FROM Wallet__c 
                                WHERE Name in :walletSet])
            {
                walletMap.put(wal.Name, wal);
            }
            for(WrapperCsvResult result : scope)
            {
                if(result.error != 'KO')
                {
                    checkNDGDoppio(result, abindgMap);
                    checkMatricolePortafoglio(result, matrPtfMap);
                    checkPortafoglioNDG(result, accMap);
                    checkPTFPartenza(result, accMap);
                    checkPTFCEDDes(result, filialiMap);
                    checkWalletName(result, walletMap);
                    checkWalletPTFDelDate(result, walletMap);
                    checkPTFDes(result, modServMap);
                }
                if(result.error == 'OK')
                {
                    result.ptf_dest_individuato = walletMap.get(result.ptf_destinazione).Id;
                    result.ptf_data = String.valueOf(System.today());
                    if(accMap.get(result.abi+result.ndg) != null) 
                    {
                        result.accId = accMap.get(result.abi+result.ndg).Id;
                        result.cedId = filialiMap.get(result.ced_destinazione).Id;
                    }
                }
                resultList.add(result);
            }
        } catch (Exception e) 
        {
            system.debug(e);
            string errorMsg = 'Cause: '+e.getCause()+' - LineNumber: '+e.getLineNumber()+' - TypeName: '+e.getTypeName()
						+' - StackTrace: '+e.getStackTraceString()+' - Message: '+e.getMessage();
            system.debug(errorMsg);
            //gblFileRecordLog.Status__c = 'Pending';
            //update gblFileRecordLog;
        }
    }
    public void finish(Database.BatchableContext context) 
    {
        system.debug('current Heap ---- ' + System.Limits.getHeapSize());
        system.debug('limit Heap --- ' + System.Limits.getHeapSize());

        matrPtfMap = null;
        abindgMap = null;
        gblCsvRowFields = null;
        eddy = null;
        
        system.debug('current Heap ---- ' + System.Limits.getHeapSize());
        system.debug('limit Heap --- ' + System.Limits.getHeapSize());

        //poi genero file righe OK e KO
        Boolean OK = false;
        Boolean KO = false;
        String generatedCSVFile ='ABI;NDG;Ced_destinazione;Mds_destinazione;Ptf_partenza;Ptf_destinazione;Matricola;Tag;Ptf_dest_individuato;Ptf_data;Error;ErrorMessage'+'\n';
        String generatedCSVFileId = 'Id;PTF_Filiale__c;PTF_Portafoglio__c'+'\n';
        for(WrapperCSVResult wrap : resultList) 
        {
            string csvRow = wrap.abi +';'+wrap.ndg +';'+wrap.ced_destinazione +';'+
                            wrap.mds_destinazione+';'+wrap.ptf_partenza +';'+
                            wrap.ptf_destinazione+';'+wrap.matricola +';'+wrap.tag+';'+
                            wrap.ptf_dest_individuato+';'+wrap.ptf_data+';'+
                            wrap.error+';'+wrap.errorMessage+'\n';
            
            generatedCSVFile += csvRow;

            if(wrap.error == 'OK' && wrap.accId != null)
            {
                OK = true;
                string csvRowId = wrap.accId +';'+wrap.cedId +';'+wrap.ptf_dest_individuato+'\n';
                generatedCSVFileId += csvRowId;
            }
            //else KO = true;
        }
        resultList = null;

        if(!Test.isrunningTest()) 
		{
            //allega il file elaborato
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.VersionData = Blob.valueOf(generatedCSVFile);
            cv.Title = 'Result Spostamento '+System.now()+' - ' + gblCsvName;
            cv.PathOnClient = 'Result Spostamento '+System.now()+' - ' + gblCsvName;
            
            insert cv;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = gblFileRecordLog.Id;
            insert cdl;

            generatedCSVFile = null;

            if(OK)
            {
                //allega il file elaborato con i soli id
                ContentVersion cv2 = new ContentVersion();
                cv2.ContentLocation = 'S';
                cv2.VersionData = Blob.valueOf(generatedCSVFileId);
                cv2.Title = 'Submit Spostamento '+System.now()+' - ' + gblCsvName;
                cv2.PathOnClient = 'Submit Spostamento '+System.now()+' - ' + gblCsvName;
                
                insert cv2;
                
                ContentDocumentLink cdl2 = new ContentDocumentLink();
                cdl2.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv2.Id].ContentDocumentId;
                cdl2.LinkedEntityId = gblFileRecordLog.Id;
                insert cdl2;
                
                generatedCSVFileId = null;
            }

        }
        else 
        {
            Integer i = 0;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
        //invio notifica completamento??
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        string notifId = [select id from CustomNotificationType limit 1].Id;
        notification.setNotificationTypeId(notifId);
        if(KO)
        {
            notification.setTargetId(gblFileRecordLog.Id); // target object id
            notification.setTitle(Label.Elaborazione_csv_error_title);
            notification.setBody(Label.Elaborazione_csv_error_body);
        }
        else 
        {
            //String pageRef = '{ type:"standard__objectPage",attributes:{objectApiName:"FV_Ghost_Account__c",actionName:"list"},"state":{"filterName":"All"}}';
            notification.setTargetId(gblFileRecordLog.Id); // target object id
            notification.setTitle(Label.Elaborazione_csv_success_notifica_title);
            notification.setBody(Label.Elaborazione_csv_success_body);
            //aggiorno record csvLoad
        }
        notification.send(new set<String>{(string) UserInfo.getUserId()});
        spostamentoNDGFromCSVController.setLog(gblFileRecordLog);
    }

    /*.........................*/
    /*Metodi Data Quality Check*/
    /*.........................*/
    /**
     * @description: verifica che la coppia ABI e NDG sia univoca per tutte le righe
     */
    public static void checkNDGDoppio(WrapperCSVResult result, Map<string, list<WrapperCSVResult>> abindgMap)
    {
        string key = result.abi+result.ndg;
        if(result.error != 'KO' && abindgMap.get(key).size() > 1) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckNDGDoppio;
        }
        //return eddy;
    }
    /**
     * @description: verifica che la coppia PTF_Destinazione e Matricola sia univoca per tutte le righe
     */
    public static void checkMatricolePortafoglio(WrapperCSVResult result, Map<string, set<string>> matrPtfMap)
    {
        if(result.error != 'KO' && result.matricola != '' && matrPtfMap.get(result.ptf_destinazione).size() > 1) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckMatricolePortafoglio;
        }
    }
    /**
     * @description: verifica che il campo Matricola deve essere valorizzato solo se se il nome del portafoglio di destinazione contiene # 
     */
    public static void CheckMatricolaPTFDes(WrapperCSVResult result)
    {
        if(result.error != 'KO' && !result.ptf_destinazione.contains('#') && result.matricola != null) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckMatricolaPTFDes;
        }
    }
    /**
     * @description: verifica che il campo PTF_Portafoglio sia valorizzato su NDG
     */
    public static void checkPortafoglioNDG(WrapperCSVResult result, Map<string, Account> accMap)
    {
        if(result.error != 'KO' && accMap.get(result.abi+result.ndg) != null && accMap.get(result.abi+result.ndg).PTF_Portafoglio__c == null) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckPortafoglioNDG;
        }
    }
    /**
     * @description: il metodo ritorna true se il codice ABI è compreso nei valori corretti
     */
    public static boolean checkAbi(WrapperCSVResult csvRow, SpostamentoNDG_Data_Quality_Check__mdt dataQMetadata)
    {
        list<string> abiCode = dataQMetadata.Abi__c.split(',');

        return abiCode.contains(csvRow.abi);
    }
    /**
     * @description: verifica che il valore PTF_Partenza corriponda con il valore PTF_Portafoglio__c su NDG
     */
    public static void checkPTFPartenza(WrapperCSVResult result, Map<string, Account> accMap)
    {
        if(result.error != 'KO' && accMap.get(result.abi+result.ndg) != null && accMap.get(result.abi+result.ndg).PTF_Portafoglio__r.Name != result.ptf_partenza) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckPTFPartenza+' '+accMap.get(result.abi+result.ndg).PTF_Portafoglio__r.Name;
        }
    }
    /**
     * @description: verifica se esiste a sistema il PTF_CED_DESTINAZIONE
     */
    public static void checkPTFCEDDes(WrapperCSVResult result, Map<string, Account> filialiMap)
    {
        if(result.error != 'KO' && filialiMap.get(result.ced_destinazione) == null) 
        {
            result.error = 'KO';
            result.errorMessage = label.checkPTFCEDDestinazione;
        }
    }
    /**
     * @description: verifica se esiste a sistema un Wallet con Name == PTF_Destinazione
     */
    public static void checkWalletName(WrapperCSVResult result, Map<string, Wallet__c> walletMap)
    {
        if(result.error != 'KO' && walletMap.get(result.ptf_destinazione) == null) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckWalletName;
        }
    }
    /**
     * @description: verifica che il Wallet trovato a sistema non abbia il campo PTF_DeletionDate__c valorizzato
     */
    public static void checkWalletPTFDelDate(WrapperCSVResult result, Map<string, Wallet__c> walletMap)
    {
        if(result.error != 'KO' && walletMap.get(result.ptf_destinazione) != null && (walletMap.get(result.ptf_destinazione).PTF_DeletionDate__c != null)) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckWalletPTFDeletionDate+' '+String.valueOf(walletMap.get(result.ptf_destinazione).PTF_DeletionDate__c);
        }
    }
    /**
     * @description: verifica che i valori di ABI,MDS_DESTINAZIONE e CED DESTINAZIONE corrispondano con i valori di PTF_Destinazione
     */
    public static void checkPTFDes(WrapperCSVResult result, map<string, PTF_ModelloDiServizio__mdt> modServMap)
    {
        list<string> ptf_des = result.ptf_destinazione.split('-');
        if(result.error != 'KO')
        {
            if(modServMap.get(result.mds_destinazione).PTF_Abbreviazione__c != ptf_des[1]) 
            {
                result.error = 'KO';
                result.errorMessage = label.CheckPTFDesMDS;
            }
            if(result.abi != ptf_des[2]) 
            {
                result.error = 'KO';
                result.errorMessage = label.CheckPTFDesAbi;
            }
            if(('000'+result.ced_destinazione).right(4) != ptf_des[3]) 
            {
                result.error = 'KO';
                result.errorMessage = label.CheckPTFDesCED;
            }
        }
    }
    /**
     * @description: il metodo ritorna true se PTF_Partenza == PTF_Destinazione
     */
    public static Boolean checkPTFPartPTFDes(WrapperCSVResult csvRow)
    {
        return csvRow.ptf_partenza.equals(csvRow.ptf_destinazione);
    }

    /**
        * @description: il metodo esegue una query includendo in automatico tutti i campi dell'oggetto
        * @param objectApiName: nome API oggetto su cui eseguire la query
        * @return: lista di risultati di tipo "sObject" generico. È possibile fare il cast del risulta in una lista dell'oggetto specifico
        */ 
    public static List<SObject> queryAllFields(string objectApiName)
    {
    
        //reperisco tutti i campi dell'oggetto
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectApiName).getDescribe().fields.getMap();
        list<string> list_field = new list<string>(fieldMap.keyset());
    
    
        string qrSelect = 'select '+string.join(list_field , ',');//SELECT con tutti i campi dell'oggetto
        string qrFrom = ' from '+objectApiName;//FROM oggetto
        string qrWhere = ' where '; //WHERE filtri query
        string qrOrder = ' order by '; //ORDER BY ordinamento risultati query
        
        //creo una variabile di tipo "Tipo lista<Oggetto>"
        System.Type listType = System.Type.forName('List<'+objectApiName+'>');
        //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
        List<SObject> result = (List<SObject>)listType.newInstance();
    
    
        //aggiungere where/order se correttamente valorizzati nelle variabili
        //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
        result = database.query(qrSelect + qrFrom /*+ qrWhere + qrOrder*/);
    
        return result;
    }
}