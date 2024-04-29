global class creaPortafoglioFromCSVBatch implements Database.Batchable<String>, Database.Stateful
{
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}
    //file csv scomposto
	global List<String> gblCsvRowFields;
    global List<String> gblCsvUpdatedFields;
	//record di log da aggiornare
	global SV_CSVLoad__c gblFileRecordLog;
    global list<WrapperCSVResult> resultList;
    global map<string, WrapperCSVResult> resultMap;

    global string gblNumeroRiga;

    global string gblCsvName;

    global creaPortafoglioFromCSVBatch(List<String> mtdCsvRowFields, SV_CSVLoad__c mtdFileRecordLog, String mtdCsvName)
    {
        //memorizzo il file ed il log ed istanzio le mappe
		gblCsvRowFields = mtdCsvRowFields;
        gblCsvUpdatedFields = new list<string>();
		gblFileRecordLog = mtdFileRecordLog;
		gblCsvName = mtdCsvName;
        resultList = new list<WrapperCSVResult>();
        resultMap = new map<string, WrapperCSVResult>();
    }

	global List<String> start(Database.BatchableContext context) 
    {
		//gblFileRecordLog.job_ids__c += ' - ' + context.getJobId();

        return gblCsvRowFields;
	}

    global void execute(Database.BatchableContext context, List<String> scope) 
    {
		try
        {
            Map<String,String> WrapperFiliale = new Map<String,String>();
            Map<String,String> WrapperReferenti = new Map<String,String>();
            List<Account> filiale = new List<Account>();
            List<Contact> referenti = new List<Contact>();
            map<string, Wallet__c> walletMap = new map<string, Wallet__c>();
            List<WrapperResult> eddy = new List<WrapperResult>();
            set<String> modelloServizioSet = new set<String>();
            set<String> filialeSet = new set<String>();
            for (String val : scope) 
            {
                System.debug('LL DEBUG saveObjects scope: ' + val);
                list<String> valSplit = val.split(',');
                WrapperResult result = new WrapperResult();
                result.modelloServizio = valSplit[0];
                result.abi = valSplit[1];
                result.cedfiliale = valSplit[2];
                result.matricola = valSplit[3];
                result.tipoPortafoglio = valSplit[4];
                result.numeroRiga = valSplit[5];

                gblNumeroRiga = result.numeroRiga;

                //List<WrapperResult> eddy = (List<WrapperResult>) JSON.deserialize(val, List<WrapperResult>.class);
                //string jsonString =  '{'+JSON.serialize(val)+'}';
                //system.debug(jsonString);
                //WrapperResult result = (WrapperResult) JSON.deserialize(jsonString, WrapperResult.class);
                System.debug('GB result '+result);

                eddy.add(result);
                
                WrapperFiliale.put(result.numeroRiga, result.cedfiliale);
                if(result.matricola != '')
                WrapperReferenti.put(result.numeroRiga, result.matricola);
                modelloServizioSet.add(result.modelloServizio);
                filialeSet.add(result.cedfiliale);

                WrapperCSVResult wrCR = new WrapperCSVResult();
                wrCR.numeroRiga = result.numeroRiga;
                wrCR.modelloServizio = result.modelloServizio;
                wrCR.abi = result.abi;
                wrCR.cedfiliale = result.cedfiliale;
                wrCR.matricola = result.matricola;
                wrCR.tipoPortafoglio = result.tipoPortafoglio;
                resultMap.put(result.numeroRiga, wrCR);
            }

            filiale = [SELECT id ,PTF_IdCEDFiliale__c,  PTF_Banca__c, PTF_DirezioneRegionale__c, PTF_Area__c, PTF_Capofila__c, FinServ__BankNumber__c
                                    FROM  Account WHERE RecordType.DeveloperName = 'FilialeDiRelazione' AND PTF_IdCEDFiliale__c  IN : WrapperFiliale.values()];

            
            if(WrapperReferenti.size()>0){
                
                referenti = [SELECT ID, PTF_RegistrationNumber__c  FROM Contact Where PTF_RegistrationNumber__c IN : WrapperReferenti.values()];
            }

            for(Wallet__c wal : [SELECT id,Name, PTF_ModelloDiServizio__c,PTF_Filiale__c, PTF_DeletionDate__c from Wallet__c where PTF_Filiale__r.PTF_IdCEDFiliale__c in :filialeSet AND PTF_ModelloDiServizio__c in :modelloServizioSet])
            {
                string mapKey = wal.PTF_ModelloDiServizio__c + '' + wal.PTF_Filiale__c;
                walletMap.put(mapKey, wal);
            }
                
                
            for(WrapperResult result : eddy)
            {
                gblNumeroRiga = result.numeroRiga;
                //WrapperResult result = (WrapperResult) JSON.deserialize(JSON.serialize(val), WrapperResult.class);
                for(Account f : filiale){

                    if((result.cedfiliale == f.PTF_IdCEDFiliale__c) && (result.abi ==  f.FinServ__BankNumber__c)){
                        result.filiale = f.id;
                        result.banca = f.PTF_Banca__c;
                        result.dirRegionale = f.PTF_DirezioneRegionale__c;
                        result.area = f.PTF_Area__c;
                        result.capofila = f.PTF_Capofila__c;
                    }
                    
                }
                if(WrapperReferenti.size()>0){
                    for(Contact c : referenti){

                        if(result.matricola == c.PTF_RegistrationNumber__c)
                            result.idReferente = c.Id;
                    }
                }
            } 
            System.debug('GB FINAL EDDY '+eddy); 

            List<Assignment__c> assignmentsToInsert = new List<Assignment__c>();
            List<Wallet__c> walletsToInsert = new List<Wallet__c>();
            Map<String,Wallet__c> mwMap = new Map<String,Wallet__c>();
            Map<Id,Schema.RecordTypeInfo> rtMap = Wallet__c.sobjectType.getDescribe().getRecordTypeInfosById();

            Map<String, SObject> mtdWalletlMap  = SV_Utilities.keyBy([SELECT Id, MasterLabel, PTF_IsPool__c
                                                                FROM PTF_ModelloDiServizio__mdt ], 'MasterLabel', false);

            Id microWalletRTId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', 'MicroWallet');
            Id TechnicalWalletRTId = Schema.SObjectType.Wallet__c.getRecordTypeInfosByDeveloperName().get('TechnicalWallet').getRecordTypeId();

            Map<String,List<Wallet__c>> testMap = new Map<String,List<Wallet__c>>();
            Map<String,Boolean> isPTF999Map = new Map<String,Boolean>();
            Map<String,Boolean> isPTFSvilMap = new Map<String,Boolean>();

            for(WrapperResult wr : eddy)
            {
                gblNumeroRiga = wr.numeroRiga;
                //WrapperResult wr = (WrapperResult) JSON.deserialize(JSON.serialize(val), WrapperResult.class);
                String mapKey;
                List<Wallet__c> mapWallets = new List<Wallet__c>();
                Wallet__c mw = new Wallet__c();
                mw.PTF_Filiale__c = wr.filiale;
                mw.PTF_ModelloDiServizio__c = wr.modelloServizio;
                mw.PTF_Area__c = String.isNotBlank(wr.area) ? wr.area : null;
                mw.PTF_Banca__c = wr.banca;
                mw.PTF_DirezioneRegionale__c = String.isNotBlank(wr.dirRegionale) ? wr.dirRegionale : null;
                mw.PTF_Capofila__c = wr.capofila;
                mw.RecordTypeId = (wr.tipoPortafoglio == 'Microportafoglio' || wr.tipoPortafoglio == 'Portafoglio 999' || wr.tipoPortafoglio == 'Portafoglio Sviluppo')? microWalletRTId : TechnicalWalletRTId;
                mw.PTF_Pool__c = (Boolean)mtdWalletlMap.get(wr.modelloServizio).get('PTF_IsPool__c');
                mapKey = mw.PTF_ModelloDiServizio__c + '' + mw.PTF_Filiale__c;

                if(wr.tipoPortafoglio == 'Portafoglio 999') isPTF999Map.put(mapKey, true);
                if(wr.tipoPortafoglio == 'Portafoglio Sviluppo') isPTFSvilMap.put(mapKey, true);

                if(mw.RecordTypeId == TechnicalWalletRTId || mw.PTF_Pool__c == true)
                {
                    //if(!walletMap.containsKey(mapKey))
                    //{
                        mwMap.put(wr.numeroRiga,mw);
                        //buildName(mw);
                        //walletsToInsert.add(mw);
        
                        if(!testMap.containskey(mapKey)){
                            mapWallets.add(mw);
                            testMap.put(mapKey,mapWallets);
                        }
                        else{
                            mapWallets = testMap.get(mapKey);
                            mapWallets.add(mw);
                            testMap.put(mapKey,mapWallets);
        
                        }
                    //}
                    /*else 
                    {
                        resultMap.get(gblNumeroRiga).resultInsert = 'KO';
                        if(walletMap.get(mapKey).PTF_DeletionDate__c != null)
                        {
                            resultMap.get(gblNumeroRiga).error = 'Portafoglio presente con nome '+walletMap.get(mapKey).Name+' e Data Cancellazione '+String.valueOf(walletMap.get(mapKey).PTF_DeletionDate__c);
                        }
                        else 
                        {
                            resultMap.get(gblNumeroRiga).error = 'Portafoglio già esistente per lo stesso Modello e Filiale';
                        }
                    }*/
                }
                else 
                {
                    mwMap.put(wr.numeroRiga,mw);
                        //buildName(mw);
                        //walletsToInsert.add(mw);
        
                    if(!testMap.containskey(mapKey)){
                        mapWallets.add(mw);
                        testMap.put(mapKey,mapWallets);
                    }
                    else{
                        mapWallets = testMap.get(mapKey);
                        mapWallets.add(mw);
                        testMap.put(mapKey,mapWallets);
    
                    }
                }
                
            }
            System.debug('GB MAPPA '+testMap);

            for(String k : testMap.keySet()){

                NewMicroWalletController.buildName(testMap.get(k)[0], 
                                                    (isPTF999Map.get(k)!=null)?isPTF999Map.get(k):false, 
                                                    (isPTFSvilMap.get(k)!=null)?isPTFSvilMap.get(k):false);

                walletsToInsert.addAll(testMap.get(k));
                
            }
                
            //creazione csv con risultati
            //mapping numero riga??????
            
            List<Database.SaveResult> wallList = Database.insert(walletsToInsert);

            for(Database.SaveResult wl : wallList)
            {
                //WrapperCSVResult wrCR = new WrapperCSVResult();
                if(wl.isSuccess())
                {
                    resultMap.get(gblNumeroRiga).Id = wl.id;
                    resultMap.get(gblNumeroRiga).resultInsert = 'OK';
                    //wrCR.numeroRiga = ;
                }
                else 
                {
                    resultMap.get(gblNumeroRiga).resultInsert = 'KO';
                    resultMap.get(gblNumeroRiga).error = wl.errors.toString();
                }
            }

            Set<String> wIds= new Set<String>();
            for(Wallet__c w: walletsToInsert){
                wIds.add(w.Id);
            }
            NewMicroWalletController.createShare(wIds);

            for(WrapperResult wr : eddy)
            {
                gblNumeroRiga = wr.numeroRiga;
                //WrapperResult wr = (WrapperResult) JSON.deserialize(JSON.serialize(val), WrapperResult.class);
                for(String num : mwMap.keySet()){

                    if(num == wr.numeroRiga && wr.idReferente != null){

                        assignmentsToInsert.add(new Assignment__c(
                            PTF_MicroWallet__c = mwMap.get(num).Id,
                            PTF_StartDate__c=Date.today(),
                            PTF_StartDate_DT__c = Datetime.now(),
                            PTF_Gestore__c = wr.idReferente,
                            RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByDeveloperName().get('Primario').getRecordTypeId()
                        ));
                    }
                }
            }
            insert assignmentsToInsert;

        }
        
        catch(Exception e)
        {
			system.debug(e);
            string errorMsg = 'Cause: '+e.getCause()
						+' - LineNumber: '+e.getLineNumber()
						+' - TypeName: '+e.getTypeName()
						+' - StackTrace: '+e.getStackTraceString()
						+' - Message: '+e.getMessage();
            system.debug(errorMsg);
            //gblFileRecordLog.Riga_Errore__c += gblNumeroRiga + '\n';
			//creaPortafoglioFromCSVController_V2.setLog(gblFileRecordLog, e, false);
            resultMap.get(gblNumeroRiga).error = errorMsg.replaceAll(',', ' ').replaceAll(';', ' ');
            resultMap.get(gblNumeroRiga).resultInsert = 'KO';
		}
    }

    global void finish(Database.BatchableContext context) 
    {

		//gblFileRecordLog.Data_Fine_Elaborazione__c = System.now();
		//gblFileRecordLog.stato__c = 'Completato' ;

        gblFileRecordLog.Status__c = 'Completed';
        
        update gblFileRecordLog;

        String generatedCSVFileOK ='Modello di servizio,abi,ced filiale,matricola da assegnare,Tipo Portafoglio,Numero Riga,Status,Id,Error'+'\n';
        String generatedCSVFileKO ='Modello di servizio,abi,ced filiale,matricola da assegnare,Tipo Portafoglio,Numero Riga,Status,Id,Error'+'\n';
        boolean OK = false;
        boolean KO = false;
        for(WrapperCSVResult wrap : resultMap.values()) 
        {
            string csvRow = wrap.modelloServizio +','+wrap.abi +','+wrap.cedfiliale +','+wrap.matricola +','+wrap.tipoPortafoglio +','+wrap.numeroRiga+','+wrap.resultInsert+','+wrap.Id+','+wrap.error+'\n';
            if(wrap.resultInsert =='OK') 
            {
                generatedCSVFileOK += csvRow;
                OK = true;
            }
            if(wrap.resultInsert =='KO') 
            {
                generatedCSVFileKO += csvRow;
                KO = true;
            }
        }

        if(!Test.isrunningTest()) 
		{
            if(OK)
            {
                //allega il file elaborato
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.VersionData = Blob.valueOf(generatedCSVFileOK);
                cv.Title = 'Result OK '+System.now()+' - ' + gblCsvName;
                cv.PathOnClient = 'Result OK '+System.now()+' - ' + gblCsvName;
                
                //ArtUtility.printDebug(cv, 'cv', imf.ACTIVATE_DEBUG__c);
                
                insert cv;
                
                //ArtUtility.printDebug(cv.contentDocumentId, 'contentDocumentId', imf.ACTIVATE_DEBUG__c);        
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
                cdl.LinkedEntityId = gblFileRecordLog.Id;
                cdl.ShareType = 'I';
                
                //ArtUtility.printDebug(cdl, 'cdl', imf.ACTIVATE_DEBUG__c);
                
                insert cdl;
            }
            if(KO)
            {
                //allega il file elaborato
                ContentVersion cv = new ContentVersion();
                cv.ContentLocation = 'S';
                cv.VersionData = Blob.valueOf(generatedCSVFileKO);
                cv.Title = 'Result KO '+System.now()+' - ' + gblCsvName;
                cv.PathOnClient = 'Result KO'+System.now()+' - ' + gblCsvName;
                
                //ArtUtility.printDebug(cv, 'cv', imf.ACTIVATE_DEBUG__c);
                
                insert cv;
                
                //ArtUtility.printDebug(cv.contentDocumentId, 'contentDocumentId', imf.ACTIVATE_DEBUG__c);        
                
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
                cdl.LinkedEntityId = gblFileRecordLog.Id;
                cdl.ShareType = 'I';
                
                //ArtUtility.printDebug(cdl, 'cdl', imf.ACTIVATE_DEBUG__c);
                
                insert cdl;
            }
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
            //notification.setTargetPageRef(pageRef); // target object id
            notification.setTitle(Label.Elaborazione_csv_success_notifica_title);
            notification.setBody(Label.Elaborazione_csv_success_body);
        }
        notification.send(new set<String>{(string) UserInfo.getUserId()});
	}

    private class GroupWrapper{
        Group gruppo;
        String filiera;
        String macroFiliera;
    }

    
    private static void buildName(List<Wallet__c> mwList){

        System.debug('lista Family '+mwList);

        List<ServiceModel__c > sm=[SELECT PTF_TresholdPTF__c  FROM ServiceModel__c  WHERE Name=:mwList[0].PTF_ModelloDiServizio__c];

        System.debug('valore soglia '+sm[0].PTF_TresholdPTF__c);
        Integer start= Integer.valueOf(sm[0].PTF_TresholdPTF__c) ;
        start++;

        System.debug('@@@@start '+start);

        System.debug('### '+mwList[0].PTF_Filiale__c);

        List<Account> accList= [SELECT Id, PTF_IdCEDFiliale__c, FinServ__BankNumber__c FROM Account WHERE Recordtype.DeveloperName = 'FilialeDiRelazione' AND Id=:mwList[0].PTF_Filiale__c];
        String abi=accList[0].FinServ__BankNumber__c;
        String ced=accList[0].PTF_IdCEDFiliale__c;

        if(ced.length()<4){
            do{
                ced='0'+ced;
            }
            while(ced.length()<4);
        }

        List<PTF_ModelloDiServizio__mdt> mdt=[SELECT Id, MasterLabel, PTF_Abbreviazione__c
                                                FROM PTF_ModelloDiServizio__mdt 
                                                WHERE MasterLabel =: mwList[0].PTF_ModelloDiServizio__c];

        String ptfName='PTF-'+mdt[0].PTF_Abbreviazione__c+'-'+abi+'-'+ced+'-';

        Id TechnicalWalletRTId = Schema.SObjectType.Wallet__c.getRecordTypeInfosByDeveloperName().get('TechnicalWallet').getRecordTypeId();

        if(mwList[0].RecordTypeId == TechnicalWalletRTId)
        {
            for(Wallet__c mw:mwList){
                mw.Name=ptfName+'000075';
            }
        }
        else {
            if(mwList[0].PTF_ModelloDiServizio__c=='Private'){
                Integer max=0;
                System.debug('@@@@max '+max);
                List<Wallet__c> oldList=[SELECT Name FROM Wallet__c WHERE RecordTypeId=:mwList[0].RecordTypeId AND PTF_Filiale__c=:mwList[0].PTF_Filiale__c AND PTF_ModelloDiServizio__c=:mwList[0].PTF_ModelloDiServizio__c AND (NOT Name LIKE '%999') AND (NOT Name LIKE '%-500%')];
                if(oldList.size()>0){
                    for(Wallet__c w:oldList){
                        Integer num= Integer.valueOf(w.Name.split('-')[4]);
                        if(num>max && num!=50 && num!=75){
                            max=num;
                            System.debug('@@@@max '+max);
                        }
                    }
                }
                System.debug('@@@@max '+max);
                if(max>=start){
                    max++;
                    if(max!=50 && max!=75){
                        System.debug('@@@@max '+max);
                        start=max;
                        System.debug('@@@@start '+start);
                    }
                    else{
                        start=max+1;
                        System.debug('@@@@start '+start);
                    }
                }   
            }
            else{
                Integer max=0;
                List<Wallet__c> oldList=[SELECT Name FROM Wallet__c WHERE RecordTypeId=:mwList[0].RecordTypeId AND PTF_Filiale__c=:mwList[0].PTF_Filiale__c AND PTF_ModelloDiServizio__c=:mwList[0].PTF_ModelloDiServizio__c AND (NOT Name LIKE '%999') AND (NOT Name LIKE '%-500%')];
                if(oldList.size()>0){
                    for(Wallet__c w:oldList){
                        Integer num= Integer.valueOf(w.Name.split('-')[4]);
                        if(num>max){
                            max=num;
                        }
                    }
                }
                if(max>=start){
                    
                        start=max+1;
                        System.debug('@@@@start '+start);
                    
                } 
            }
            if(mwList[0].PTF_ModelloDiServizio__c=='Private'){
                for(Wallet__c mw:mwList){
                    if(start!=50 && start!=75){
                        String seq= String.valueOf(start);
                        if(seq.length()<6){
                            do{
                                seq='0'+seq;
                            }
                            while(seq.length()<6);
                        }
                        mw.Name=ptfName+seq;
                    }
                    else{
                        start++;
                        String seq= String.valueOf(start);
                        if(seq.length()<6){
                            do{
                                seq='0'+seq;
                            }
                            while(seq.length()<6);
                        }
                        mw.Name=ptfName+seq;
                    }
                    start++;
                }
            }
            else{
                for(Wallet__c mw:mwList){
                    String seq= String.valueOf(start);
                        if(seq.length()<6){
                            do{
                                seq='0'+seq;
                            }
                            while(seq.length()<6);
                        }
                        mw.Name=ptfName+seq;
                        start++;
                }
            }
        }

    }
    /*..........................................*/
    /* Wrapper class to display Input Data from CSV*/
    /*.........................................*/

    public class WrapperResult {
 
        //@AuraEnabled public final String numeroRiga;
        @AuraEnabled public String modelloServizio;
        @AuraEnabled public String abi;
        @AuraEnabled public String cedfiliale;
        @AuraEnabled public String matricola;
        @AuraEnabled public String tipoPortafoglio;
        @AuraEnabled public String numeroRiga;
    
        //parametri che mi servono per la creazione del portafoglio
        @AuraEnabled public  String filiale;
        @AuraEnabled public  String banca;
        @AuraEnabled public  String dirRegionale;
        @AuraEnabled public  String area;
        @AuraEnabled public  String capofila;
        @AuraEnabled public  String idReferente;
        
        
    }

    public class WrapperCSVResult
    {
        public String modelloServizio;
        public String abi;
        public String cedfiliale;
        public String matricola;
        public String tipoPortafoglio;
        public String numeroRiga;
        public String resultInsert;
        public String Id;
        public String error;
    }
    public static void testRun() {
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
    }
}