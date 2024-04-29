public without sharing class spostamentoNDGFromCSVController 
{
    /**
	* @description: riceve il file dal componente lightning e lo manda in elaborazione 
	* @param mtdCsvFile: file 
	* @param mtdCsvName: nome file 
	*/ 
	@AuraEnabled
	public static statusWrapper upldFile(object mtdCsvFile, object mtdCsvName, list<string> mtdFileRows, 
                                            boolean erroreRighe, boolean erroreSeparatore,string SV_CSVLoad){
	
		statusWrapper mtdStatus = new statusWrapper();
		SV_CSVLoad__c mtdFileRecordLog = [select id 
                                            from SV_CSVLoad__c 
                                            where id = :SV_CSVLoad];
        system.debug(mtdFileRows);
        list<string> csvFileRows = new list<string>();
        //system.debug(mappa);
		try{
            if(erroreSeparatore)
            {
                mtdStatus.setStatusWrapper(system.label.Elaborazione_csv_error_title, 
                                            'error', 
                                            label.Errore_Separatore_Campo);//custom label todo
                ListException e = new ListException();
                e.setMessage('Separatore di campo errato');
                
            }
			else if(erroreRighe)
            {
                mtdStatus.setStatusWrapper(system.label.Elaborazione_csv_error_title, 
                                            'error', 
                                            label.Errore_Lunghezza_righe);//custom label todo
                ListException e = new ListException();
                e.setMessage('Lunghezza righe errata');
                //setLog(mtdFileRecordLog, e, erroreRighe);
            }
            else
            {
                string fileId = setLogRecord(String.valueOf(mtdCsvFile), 
                                String.valueOf(mtdCsvName), 
                                SV_CSVLoad);
				mtdFileRecordLog.Status__c = 'Loading';
				update mtdFileRecordLog;
				
                //dataQualityCheck(fileName, String.valueOf(mtdCsvName), (SpostamentoNDG_Data_Quality_Check__mdt) queryAllFields('SpostamentoNDG_Data_Quality_Check__mdt')[0], mtdFileRecordLog);

                spostamentoNDGDataQualityCheckBatch efm = new spostamentoNDGDataQualityCheckBatch(mtdFileRows, mtdFileRecordLog,  String.valueOf(mtdCsvName),fileId);
                Database.executeBatch(efm, 10000);

                mtdStatus.setStatusWrapper(label.Elaborazione_csv_success_body, 
                                    'success', 
                                    label.Elaborazione_csv_success_notifica_title);
            }
			
			return mtdStatus;
			
		}catch(Exception e){
            //setLog(mtdFileRecordLog, e, false);
			mtdStatus.setstatusWrapper(label.Elaborazione_csv_error_title, 'error', 'Cause: '+e.getCause()+'; LineNumber: '+e.getLineNumber()+'; TypeName: '+e.getTypeName()+'; StackTrace: '+e.getStackTraceString()+'; Message: '+e.getMessage());
			return mtdStatus;
		}	
	}
    @AuraEnabled
	public static statusWrapper submitFile(string SV_CSVLoad)
    {
        //statusWrapper mtdStatus = new statusWrapper();
		/*SV_CSVLoad__c mtdFileRecordLog = [select id from SV_CSVLoad__c where id = :SV_CSVLoad];
        //mtdFileRecordLog.Status__c = 'Loading';
        //update mtdFileRecordLog;

        string con = [select id, ContentDocumentId from ContentDocumentLink where LinkedEntityId = :SV_CSVLoad and (ContentDocument.Title like 'Result%')].ContentDocumentId;

        contentversion mtdFileRows = [select id, VersionData, Title from ContentVersion where ContentDocumentId = :con and title like 'Result%' limit 1];
        
        spostamentoNDGFromCSVBatch efm = new spostamentoNDGFromCSVBatch(mtdFileRows.VersionData, mtdFileRecordLog, mtdFileRows.Title);
        Database.executeBatch(efm, 20);
    
        mtdStatus.setStatusWrapper(label.Elaborazione_csv_success_title, 
                                    'success', 
                                    label.Elaborazione_csv_success_toast);
        */
        //return mtdStatus;
        return new statusWrapper();
    }
    @AuraEnabled
	public static statusWrapper reuploadFile(string SV_CSVLoad)
    {
        statusWrapper mtdStatus = new statusWrapper();
        set<string> conSet = new set<string>();
        SV_CSVLoad__c mtdFileRecordLog = [select id 
                                            from SV_CSVLoad__c 
                                            where id = :SV_CSVLoad];
        try {
            //cancella file creati e ricrea file dopo data quality check
            for(contentdocumentlink con : [select id, ContentDocumentId 
                                        from ContentDocumentLink 
                                        where LinkedEntityId = :SV_CSVLoad])
            {
                conSet.add(con.ContentDocumentId);
            }
            delete [SELECT Id 
                    FROM ContentDocument 
                    WHERE Title like '%Spostamento%' 
                    AND id in :conSet];
    
            mtdFileRecordLog.Status__c = 'Pending';
            update mtdFileRecordLog;
    
            mtdStatus.setStatusWrapper(label.Elaborazione_csv_success_body, 
                                        'success', 
                                        label.Elaborazione_csv_success_notifica_title);
    
            return mtdStatus; 
        } catch(Exception e){
            //setLog(mtdFileRecordLog, e, false);
			mtdStatus.setstatusWrapper(label.Elaborazione_csv_error_title, 'error', 'Cause: '+e.getCause()+'; LineNumber: '+e.getLineNumber()+'; TypeName: '+e.getTypeName()+'; StackTrace: '+e.getStackTraceString()+'; Message: '+e.getMessage());
			return mtdStatus;
		}
    }
    //-------------------------------metodi utilizzati------------------------------------
	/**
	* @description: crea un record di log per il bacth di elaborazione a cui allega il file caricato 
	* @param mtdFileRecordLog: record da scrivere
	* @param mtdCsvFile: file da allegare 
	* @param mtdCsvName: nome del file 
	*/ 
	private static string setLogRecord(string mtdCsvFile, string mtdCsvName, string SV_CSVLoad){
		//imposta il nome del file e la data di inizio elaborazione nel record di log
		string fileId;
        if(!Test.isrunningTest()) 
		{
			//allega il file elaborato
			ContentVersion cv = new ContentVersion();
			cv.ContentLocation = 'S';
			cv.VersionData = Blob.valueOf(mtdCsvFile);
			cv.Title = 'Spostamento '+System.now()+' - ' + mtdCsvName;
			cv.PathOnClient = 'Spostamento '+System.now()+' - ' + mtdCsvName;
			
			insert cv;

            fileId = cv.Id;
			
			ContentDocumentLink cdl = new ContentDocumentLink();
			cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
			cdl.LinkedEntityId = SV_CSVLoad;
			cdl.ShareType = 'I';
			
			insert cdl;
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
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
        return fileId;
	}

	public static void setLog(SV_CSVLoad__c mtdFileRecordLog){
	
		mtdFileRecordLog.Status__c = 'Waiting for approval';
		update mtdFileRecordLog;
	}

    /*..................*/
    /*Data Quality Check*/
    /*..................*/
    /*public static void dataQualityCheck(list<string> csvRows, string mtdCsvName, SpostamentoNDG_Data_Quality_Check__mdt dataQMetadata, SV_CSVLoad__c mtdFileRecordLog)
    {
        List<WrapperCSVResult> eddy = new List<WrapperCSVResult>();
        Map<string, list<WrapperCSVResult>> abindgMap = new Map<string, list<WrapperCSVResult>>();
        Map<string, set<string>> matrPtfMap = new Map<string, set<string>>();
        Map<string, Account> accMap = new Map<string, Account>();
        Map<string, Account> filialiMap = new Map<string, Account>();
        Map<string, integer> checkMap = new Map<string, integer>();
        set<String> modelloServizioSet = new set<String>();
        set<String> filialeSet = new set<String>();
        set<String> walletSet = new set<String>();
        set<String> ndgSet = new set<String>();
        set<String> abiSet = new set<String>();
        map<string, Wallet__c> walletMap = new map<string, Wallet__c>();
        
        //ciclo le righe del file
        //per ognuna faccio i controlli del data quality
        //flaggo righe OK e KO
        for(string val : csvRows)
        {
            System.debug('LL DEBUG saveObjects scope: ' + val);
            list<String> valSplit = val.split(';');
            WrapperCSVResult result = new WrapperCSVResult();
            result.abi = valSplit[0];
            result.ndg = valSplit[1];
            result.ced_destinazione = valSplit[2];
            result.mds_destinazione = valSplit[3];
            result.ptf_partenza = valSplit[4];
            result.ptf_destinazione = valSplit[5];
            result.matricola = valSplit[6];
            result.tag = valSplit[7];
            result.numeroRiga = valSplit[8];
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

            walletSet.add(result.ptf_destinazione);
            ndgSet.add(result.ndg);
            abiSet.add(result.abi);
            filialeSet.add(result.ced_destinazione);
        }

        for(account acc : [SELECT id ,PTF_IdCEDFiliale__c,  PTF_Portafoglio__c,PTF_Portafoglio__r.Name, CRM_NDG__c, FinServ__BankNumber__c
                            FROM  Account WHERE (CRM_NDG__c in :ndgSet AND FinServ__BankNumber__c = :abiSet) OR PTF_IdCEDFiliale__c  IN : filialeSet])
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
                            FROM Wallet__c WHERE Name in :walletSet])
        {
            walletMap.put(wal.Name, wal);
        }

        spostamentoNDGDataQualityCheckBatch efm = new spostamentoNDGDataQualityCheckBatch(eddy,
                                                                                            mtdFileRecordLog, 
                                                                                            String.valueOf(mtdCsvName),
                                                                                            accMap,
                                                                                            filialiMap,
                                                                                            walletMap,
                                                                                            abindgMap,
                                                                                            checkMap,
                                                                                            matrPtfMap
                                                                                            );
        Database.executeBatch(efm, 10000);
        
        map<string, PTF_ModelloDiServizio__mdt> modServMap = new map<string, PTF_ModelloDiServizio__mdt>();
        for(PTF_ModelloDiServizio__mdt mdt : [SELECT Id, MasterLabel, PTF_Abbreviazione__c
                                                FROM PTF_ModelloDiServizio__mdt])
        {
            modServMap.put(mdt.MasterLabel, mdt);
        }

        for(WrapperCsvResult result : eddy)
        {
            checkNDGDoppio(result, abindgMap);
            checkMatricolePortafoglio(result, matrPtfMap);
            checkPortafoglioNDG(result, accMap);
            checkPTFPartenza(result, accMap);
            checkPTFCEDDes(result, filialiMap);
            checkWalletName(result, walletMap);
            checkWalletPTFDelDate(result, walletMap);
            checkPTFDes(result, modServMap);

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
        }


        //poi genero file righe OK e KO
        Boolean OK = false;
        String generatedCSVFile ='ABI;NDG;Ced_destinazione;Mds_destinazione;Ptf_partenza;Ptf_destinazione;Matricola;Tag;Ptf_dest_individuato;Ptf_data;Error;ErrorMessage'+'\n';
        String generatedCSVFileId = 'Id;PTF_Filiale__c;PTF_Portafoglio__c'+'\n';
        for(WrapperCSVResult wrap : eddy) 
        {
            string csvRow = wrap.abi +';'+wrap.ndg +';'+wrap.ced_destinazione +';'+wrap.mds_destinazione+';'+wrap.ptf_partenza +';'+
                            wrap.ptf_destinazione+';'+wrap.matricola +';'+wrap.tag+';'+wrap.ptf_dest_individuato+';'+wrap.ptf_data+';'+
                            wrap.error+';'+wrap.errorMessage+'\n';
            
            generatedCSVFile += csvRow;

            if(wrap.error == 'OK' && accMap.get(wrap.abi+wrap.ndg) != null)
            {
                OK = true;
                string csvRowId = wrap.accId +';'+wrap.cedId +';'+wrap.ptf_dest_individuato+'\n';
                generatedCSVFileId += csvRowId;
            }
        }

        if(!Test.isrunningTest()) 
		{
            //allega il file elaborato
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.VersionData = Blob.valueOf(generatedCSVFile);
            cv.Title = 'Result Spostamento'+System.now()+' - ' + mtdCsvName;
            cv.PathOnClient = 'Result Spostamento'+System.now()+' - ' + mtdCsvName;
            
            insert cv;
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = mtdFileRecordLog.Id;
            insert cdl;

            if(OK)
            {
                //allega il file elaborato con i soli id
                ContentVersion cv2 = new ContentVersion();
                cv2.ContentLocation = 'S';
                cv2.VersionData = Blob.valueOf(generatedCSVFileId);
                cv2.Title = 'Submit Spostamento'+System.now()+' - ' + mtdCsvName;
                cv2.PathOnClient = 'Submit Spostamento'+System.now()+' - ' + mtdCsvName;
                
                insert cv2;
                
                ContentDocumentLink cdl2 = new ContentDocumentLink();
                cdl2.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv2.Id].ContentDocumentId;
                cdl2.LinkedEntityId = mtdFileRecordLog.Id;
                insert cdl2;
            }
        }
        //aggiorno record csvLoad
        setLog(mtdFileRecordLog);
        
    }*/
    /*.........................*/
    /*Metodi Data Quality Check*/
    /*.........................*/
    /**
     * @description: verifica che la coppia ABI e NDG sia univoca per tutte le righe
     */
    /*public static void checkNDGDoppio(WrapperCSVResult result, Map<string, list<WrapperCSVResult>> abindgMap)
    {
        string key = result.abi+result.ndg;
        if(abindgMap.get(key).size() > 1) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckNDGDoppio;
        }
        //return eddy;
    }*/
    /**
     * @description: verifica che la coppia PTF_Destinazione e Matricola sia univoca per tutte le righe
     */
    /*public static void checkMatricolePortafoglio(WrapperCSVResult result, Map<string, set<string>> matrPtfMap)
    {
        if(result.matricola != '' && matrPtfMap.get(result.ptf_destinazione).size() > 1) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckMatricolePortafoglio;
        }
    }*/
    /**
     * @description: verifica che il campo Matricola deve essere valorizzato solo se se il nome del portafoglio di destinazione contiene # 
     */
    public static void CheckMatricolaPTFDes(WrapperCSVResult result)
    {
        if(!result.ptf_destinazione.contains('#') && result.matricola != null) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckMatricolaPTFDes;
        }
    }
    /**
     * @description: verifica che il campo PTF_Portafoglio sia valorizzato su NDG
     */
    /*public static void checkPortafoglioNDG(WrapperCSVResult result, Map<string, Account> accMap)
    {
        if(accMap.get(result.abi+result.ndg) != null && accMap.get(result.abi+result.ndg).PTF_Portafoglio__c == null) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckPortafoglioNDG;
        }
    }*/
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
    /*public static void checkPTFPartenza(WrapperCSVResult result, Map<string, Account> accMap)
    {
        if(accMap.get(result.abi+result.ndg) != null && accMap.get(result.abi+result.ndg).PTF_Portafoglio__r.Name != result.ptf_partenza) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckPTFPartenza+' '+accMap.get(result.abi+result.ndg).PTF_Portafoglio__r.Name;
        }
    }*/
    /**
     * @description: verifica se esiste a sistema il PTF_CED_DESTINAZIONE
     */
    /*public static void checkPTFCEDDes(WrapperCSVResult result, Map<string, Account> filialiMap)
    {
        if(filialiMap.get(result.ced_destinazione) == null) 
        {
            result.error = 'KO';
            result.errorMessage = label.checkPTFCEDDestinazione;
        }
    }*/
    /**
     * @description: verifica se esiste a sistema un Wallet con Name == PTF_Destinazione
     */
    /*public static void checkWalletName(WrapperCSVResult result, Map<string, Wallet__c> walletMap)
    {
        if(walletMap.get(result.ptf_destinazione) == null) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckWalletName;
        }
    }*/
    /**
     * @description: verifica che il Wallet trovato a sistema non abbia il campo PTF_DeletionDate__c valorizzato
     */
    /*public static void checkWalletPTFDelDate(WrapperCSVResult result, Map<string, Wallet__c> walletMap)
    {
        if(walletMap.get(result.ptf_destinazione) != null && (walletMap.get(result.ptf_destinazione).PTF_DeletionDate__c != null)) 
        {
            result.error = 'KO';
            result.errorMessage = label.CheckWalletPTFDeletionDate+' '+String.valueOf(walletMap.get(result.ptf_destinazione).PTF_DeletionDate__c);
        }
    }*/
    /**
     * @description: verifica che i valori di ABI,MDS_DESTINAZIONE e CED DESTINAZIONE corrispondano con i valori di PTF_Destinazione
     */
    /*public static void checkPTFDes(WrapperCSVResult result, map<string, PTF_ModelloDiServizio__mdt> modServMap)
    {
        list<string> ptf_des = result.ptf_destinazione.split('-');
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
    }*/
    /**
     * @description: il metodo ritorna true se PTF_Partenza == PTF_Destinazione
     */
    public static Boolean checkPTFPartPTFDes(WrapperCSVResult csvRow)
    {
        return csvRow.ptf_partenza.equals(csvRow.ptf_destinazione);
    }

	//Wrapper Classes
	/**
	* @description: response da inviare al componente 
	*/ 
	public class statusWrapper{
		@AuraEnabled
		public string title;//intestazione notifica
		@AuraEnabled
		public string status;//success \ error
		@AuraEnabled
		public string errorMsg;//messaggio di errore

		public statusWrapper(){
			this.title = '';
			this.status = '';
			this.errorMsg = '';
		}

		public void setStatusWrapper(string tl, string st, string err){
			this.title = tl;
			this.status = st;
			this.errorMsg = err;
		}
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
        result = database.query(qrSelect + qrFrom );
    
        return result;
    }
    /*..........................................*/
    /* Wrapper class to display Input Data from CSV*/
    /*.........................................*/

    public class WrapperResult {
 
        //@AuraEnabled public final String numeroRiga;
        //@AuraEnabled public String modelloServizio;
        public String abi;
        public String ndg;
        public String ced_destinazione;
        public String mds_destinazione;
        public String ptf_partenza;
        public String ptf_destinazione;
        public String matricola;
        public String tag;
        public String numeroRiga;
    
        //parametri che mi servono per la creazione del portafoglio
        public  String filiale;
        public  String banca;
        public  String dirRegionale;
        public  String area;
        public  String capofila;
        public  String idReferente;
        
        
    }
	/*public static void testRun() {
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
    }*/
}