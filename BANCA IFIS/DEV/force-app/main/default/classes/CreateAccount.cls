public class CreateAccount {

    @AuraEnabled
    public static WrapperResponse getInformationAccount(String InputObjString) {
        System.debug('SV InputObjString: ' + InputObjString);
        
        WrapperRecords InputObj = (WrapperRecords)JSON.deserialize(InputObjString, WrapperRecords.class);
        System.debug('SV requestFields: ' + InputObj);
        
        WrapperResponse result = new WrapperResponse();
        List<Account> result_sfdc = new List<Account>();
        List<Account> result_cedacri = new List<Account>();
        List<Account> result_ribes = new List<Account>();
        
        try {
			//ricerca per p.iva su CRM, Cedacri, Ribes a scalare
            if (InputObj.tipoDiRicerca == 'piva') {
                CtrlWizardAccount.InputObj test = new CtrlWizardAccount.InputObj(InputObj.ndg, InputObj.pivaOrCf, InputObj.ragioneSociale, InputObj.provincia, InputObj.tipoDiRicerca, InputObj.estero);
                // SFDC 03978000374
                result_sfdc = CtrlWizardAccount.searchAnagrafica(test, 'SFDC');
                if (result_sfdc.size() <= 0) {
                    // ANDG CEDACRI
                    result_cedacri = CtrlWizardAccount.searchAnagrafica(test, 'ANDG');
                    if (result_cedacri.size() <= 0) {
                        // RIBES
						//A.M. Sostituzione Infoprovider RIBES -> CERVED
                        result_ribes = CtrlWizardAccount.searchAnagrafica(test, 'CERVED');
                        result.data = result_ribes;
                    } else {
                        result.data = result_cedacri;
                    }
                } else {
                    result.success = true;
                    result.data = result_sfdc;
                }
                System.debug('SV result: ' + result);

			//adione CRM ID 80
			//ricerca per NDG su CRM, Cedacri
			} else if (InputObj.tipoDiRicerca == 'ndg') { 
                CtrlWizardAccount.InputObj test = new CtrlWizardAccount.InputObj(InputObj.ndg, InputObj.pivaOrCf, InputObj.ragioneSociale, InputObj.provincia, InputObj.tipoDiRicerca, InputObj.estero);
				result_cedacri = CtrlWizardAccount.searchAnagrafica(test, 'CEDACRI');
                if (result_cedacri.size() <= 0) {
                    result.success = false;
                    result.msg = Label.WGC_Create_Account_Nessun_dato_trovato;
                } else {
					result.data = result_cedacri;
					result.success = true;
				}

			//ricerca per rag. soc. su CRM, Cedacri, Ribes a scalare
            } else {
                CtrlWizardAccount.InputObj test = new CtrlWizardAccount.InputObj(InputObj.ndg, InputObj.pivaOrCf, InputObj.ragioneSociale, InputObj.provincia, InputObj.tipoDiRicerca, InputObj.estero);
                // SFDC 03978000374
                result_sfdc = CtrlWizardAccount.searchAnagrafica(test, 'SFDC');
                for (Account sfdc : result_sfdc) {
                    result.data.add(sfdc);
                }
                System.debug('result_sfdc: ' + result_sfdc);
                System.debug('SFDC COMPLETO');
                
                // ANDG CEDACRI
                result_cedacri = CtrlWizardAccount.searchAnagrafica(test, 'ANDG');
                System.debug('result_cedacri: ' + result_cedacri);
                Boolean find = false;
                for (Account cedacri : result_cedacri) {
                    
                    for (Account x : result_sfdc) {
                        if (x.NDGGruppo__c == cedacri.NDGGruppo__c) {
                            find = true;
                        }
                    }
                    if (!find) {
                        result.data.add(cedacri); 
                    } else {
                        find = false;
                    }
                }
                System.debug('CEDACRI COMPLETO');
                
                // RIBES
                if (result.data.size() <= 0) {
				    //A.M. Sostituzione Infoprovider RIBES -> CERVED
                    result_ribes = CtrlWizardAccount.searchAnagrafica(test, 'CERVED');
                    System.debug('CERVED');
                    System.debug(result_ribes);
                    for (Account ribes : result_ribes) {
                        result.data.add(ribes);
                    }
                }
                
                // SET WRAPPER RESPONSE
                if (result.data.size() <= 0) {
                    result.success = false;
                    result.msg = Label.WGC_Create_Account_Nessun_dato_trovato;
                }
                System.debug('SV TEST: ' + result);
            }
            
        } catch(exception e) {
            result.success = false;
            result.msg = e.getMessage();
            return result;
        }
        
        return result;
        
    }
    
    @AuraEnabled
    public static WrapperResponse getInformationAccountFromRibes(String InputObjString, String AccountListString) {
        System.debug('SV InputObjString: ' + InputObjString);
        System.debug('SV AccountListString: ' + AccountListString);
        
        WrapperResponse result = new WrapperResponse();

        try{

            WrapperRecords InputObj = (WrapperRecords)JSON.deserialize(InputObjString, WrapperRecords.class);
            System.debug('SV requestFields: ' + InputObj);
            
            List<Account> AccountList = (List<Account>)JSON.deserialize(AccountListString, List<Account>.class);
            
            for(Account acc : AccountList){
                result.data.add(acc);
            }
            
            
            List<Account> result_ribes = new List<Account>();
            
            CtrlWizardAccount.InputObj test = new CtrlWizardAccount.InputObj(InputObj.ndg, InputObj.pivaOrCf, InputObj.ragioneSociale, InputObj.provincia, InputObj.tipoDiRicerca, InputObj.estero);
            
			System.debug('@@@A.M. CreateAccount.test: ' + test);
			//A.M. Sostituzione Infoprovider RIBES -> CERVED
            result_ribes = CtrlWizardAccount.searchAnagrafica(test, 'CERVED');
            for(Account ribes : result_ribes){
                if(ribes.StatoAnagrafica__c != 'INATTIVA'){
                    result.data.add(ribes);
                }
            }

        } catch(exception e) {
            result.success = false;
            result.msg = e.getMessage();
        }
        
        return result;
        
    }

    @AuraEnabled
    public static Account getOriginAccount(String accountId) {
        System.debug('SV getInformationAccount: ' + accountId);

			//A.M. SDHDFNZ-103890 ANOMALIA SOGGETTI COLLEGATI
            Account acc = new Account();
            acc = [SELECT Id, Name, Origine__c, CF__c, PIVA__c, NaturaGiuridica__c, StatoAnagrafica__c, NDGGruppo__c FROM Account WHERE Id =: accountId];      
        
        return acc;
        
    }
    
    @AuraEnabled
    public static WrapperResponse setInformationAccount(Account InputObj) {
        System.debug('SV set Account Information: ' + InputObj);

        WrapperResponse result = new WrapperResponse();

        try{

            Account acc = new Account();
            acc = CtrlWizardAccount.setupAccount(InputObj);

            result.data.add(acc);

        } catch(Exception e){
            result.success = false;
            result.msg = e.getMessage();
        }
        
        return result;
        
    }
    
    @AuraEnabled
    public static WrapperResponse saveAccount(Account objObject, String originAccount, String tipoRecord, String tipoCensimento, Contact contactDI) {
        System.debug('SV Account objObject: ' + objObject);
        System.debug('SV Account contactDI: ' + contactDI);
        System.debug('SV Account originAccount: ' + originAccount);
        System.debug('SV Account tipoRecord: ' + tipoRecord);
        System.debug('SV Account tipoCensimento: ' + tipoCensimento);
        String userId = UserInfo.getUserId();    
        System.debug('SV UserInfo: ' + userId);
        
        WrapperResponse result = new WrapperResponse();
        Boolean resultSoggettiCollegati = false;
        Id accountId;

        try{

            // SCHIFO DA RIVEDERE
            objObject.BillingCity__c = objObject.BillingCity;
            objObject.BillingCountry__c = objObject.BillingCountry;
            objObject.BillingPostalCode__c = objObject.BillingPostalCode;
            objObject.BillingState__c = objObject.BillingState;

            objObject.ShippingCity__c = objObject.ShippingCity;
            objObject.ShippingCountry__c = objObject.ShippingCountry;
            objObject.ShippingPostalCode__c = objObject.ShippingPostalCode;
            objObject.ShippingState__c = objObject.ShippingState;

            // User usr = [ SELECT Id, WGC_Canale_di_sviluppo__c FROM User WHERE Id =: userId ];
            objObject.RecordTypeId = U.getRecordTypes('Account').get('Cliente').Id;
            objObject.WGC_Qualifica_Corporate__c = 'Prospect';
            // objObject.RAE__c = '';
            objObject.WGC_Qualifica_Corporate_Data__c = System.Today();

            // if(usr.WGC_Canale_di_sviluppo__c != null && usr.WGC_Canale_di_sviluppo__c != '') {
            //     List<WGC_Originator__mdt> mdt_originator = [ SELECT Originator__c, Originator_dettaglio__c FROM WGC_Originator__mdt WHERE Canale_di_sviluppo__c =: usr.WGC_Canale_di_sviluppo__c ];

            //     objObject.WGC_Originator_dettaglio__c = mdt_originator[0].Originator_dettaglio__c;
            //     objObject.WGC_Originator__c = mdt_originator[0].Originator__c;
            // }

            accountId = CtrlWizardAccount.WGC_insertAccount(objObject, '', false, tipoCensimento, contactDI);
            System.debug('SV Account Information: ' + objObject);

            if(tipoRecord != ''){
                resultSoggettiCollegati = saveSoggettiCollegati(accountId, originAccount, tipoRecord);
            }



            result.data.add(objObject);
            
        } catch(Exception e){
            result.success = false;
            result.msg = e.getMessage();
            system.debug('eeeeeeeeeeeeeeeeee '+e);
            return result;
        }
        
        return result;
        
    }

    @AuraEnabled
    public static Boolean saveSoggettiCollegati(String accountId, String originAccount, String tipoRecord) {
        System.debug('SV Account accountId: ' + accountId);
        System.debug('SV Account originAccount: ' + originAccount);
        System.debug('SV Account tipoRecord: ' + tipoRecord);
        
        Boolean result; 

        try{

            if(tipoRecord != ''){
            
                if(tipoRecord == 'Fornitore'){
                    List<RecordType> rt = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Fornitore_Cliente']);
                    List<WGC_Soggetti_Collegati__c> sc = new List<WGC_Soggetti_Collegati__c>([ SELECT Id, Anagrafica__c, Anagrafica_Collegata__c, RecordType.DeveloperName, Key_Soggetti_Collegati__c FROM WGC_Soggetti_Collegati__c WHERE Anagrafica__c =: accountId AND Anagrafica_Collegata__c =: originAccount ]);
                    if(rt.size() > 0 && sc.size() <= 0){
                        WGC_Soggetti_Collegati__c soggetti_collegati = new WGC_Soggetti_Collegati__c();
                        soggetti_collegati.Anagrafica__c = accountId;
                        soggetti_collegati.Anagrafica_Collegata__c = originAccount;
                        soggetti_collegati.RecordTypeId = rt[0].Id;
						//A.M. SDHDFNZ-103890 ANOMALIA SOGGETTI COLLEGATI -> Inserimento chiave per match con processo batch per evitare duplicati
						Account acc = getOriginAccount(accountId);
						Account col = getOriginAccount(originAccount);
						soggetti_collegati.Key_Soggetti_Collegati__c = 'CED_DEB-' + acc.NDGGruppo__c + '-' + col.NDGGruppo__c;

                        insert soggetti_collegati;
                    }
                } else if(tipoRecord == 'Cliente'){
                    List<RecordType> rt = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Fornitore_Cliente']);
                    List<WGC_Soggetti_Collegati__c> sc = new List<WGC_Soggetti_Collegati__c>([ SELECT Id, Anagrafica__c, Anagrafica_Collegata__c, RecordType.DeveloperName, Key_Soggetti_Collegati__c FROM WGC_Soggetti_Collegati__c WHERE Anagrafica__c =: originAccount AND Anagrafica_Collegata__c =: accountId ]);
                    if(rt.size() > 0 && sc.size() <= 0){
                        WGC_Soggetti_Collegati__c soggetti_collegati = new WGC_Soggetti_Collegati__c();
                        soggetti_collegati.Anagrafica__c = originAccount;
                        soggetti_collegati.Anagrafica_Collegata__c = accountId;
                        soggetti_collegati.RecordTypeId = rt[0].Id;

						//A.M. SDHDFNZ-103890 ANOMALIA SOGGETTI COLLEGATI -> Inserimento chiave per match con processo batch per evitare duplicati
						Account acc = getOriginAccount(accountId);
						Account col = getOriginAccount(originAccount);
						soggetti_collegati.Key_Soggetti_Collegati__c = 'CED_DEB-' + col.NDGGruppo__c + '-' + acc.NDGGruppo__c;

                        insert soggetti_collegati;
                    }
                } else if(tipoRecord == 'Referral'){
                    List<RecordType> rt = new List<RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE DeveloperName = 'Referral']);
                    List<WGC_Soggetti_Collegati__c> sc = new List<WGC_Soggetti_Collegati__c>([ SELECT Id, Anagrafica__c, Anagrafica_Collegata__c, RecordType.DeveloperName FROM WGC_Soggetti_Collegati__c WHERE Anagrafica__c =: originAccount AND Anagrafica_Collegata__c =: accountId ]);
                    if(rt.size() > 0 && sc.size() <= 0){
                        WGC_Soggetti_Collegati__c soggetti_collegati = new WGC_Soggetti_Collegati__c();
                        soggetti_collegati.Anagrafica__c = originAccount;
                        soggetti_collegati.Anagrafica_Collegata__c = accountId;
                        soggetti_collegati.RecordTypeId = rt[0].Id;

                        insert soggetti_collegati;
                    }
                }
                
            }
            
            result = true;
        } catch(Exception e){
            result = false;
            return result;
        }
        
        return result;
        
    }
    
    @AuraEnabled
    public static Map < String, String > getselectOptions(sObject objObject, string fld) {
        system.debug('objObject --->' + objObject);
        system.debug('fld --->' + fld);
        Map < String, String > allOpts = new Map < String, String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get(fld).getDescribe().getPickListValues();
        
        system.debug('values --->' + values);
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.put(a.getLabel(), a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        
        return allOpts;
    }

    // @AuraEnabled
    // public static Map < String, String > getselectOptions_recordType(String objObject) {

    //     system.debug('SV objObject:' + objObject);
    //     Map < String, String > allOpts = new Map < String, String > ();
        
        
    //     // Get the list of picklist values for this field.
    //     list < RecordType > values = [SELECT Id, Name FROM RecordType WHERE sObjectType='Account'];
        
    //     system.debug('SV values: ' + values);
        
    //     // Add these values to the selectoption list.
    //     for (RecordType a: values) {
    //         allOpts.put(a.Name, a.Id);
    //     }
    //     system.debug('SV allOpts: ' + allOpts);
        
    //     return allOpts;
    // }

    @AuraEnabled
    public static Map < String, String > getselectOptions_Ateco(String rae) {

        system.debug('SV rae:' + rae);
        Map < String, String > allOpts = new Map < String, String > ();
        
        
        // Get the list of picklist values for this field.
        list < Ateco__c > values = [SELECT Cedacri__c, Descrizione__c FROM Ateco__c WHERE RAE__c =: rae];
        
        system.debug('SV values: ' + values);
        
        // Add these values to the selectoption list.
        for (Ateco__c a: values) {
            allOpts.put(a.Cedacri__c, a.Descrizione__c);
        }
        system.debug('SV allOpts: ' + allOpts);
        
        return allOpts;
    }

    @AuraEnabled
    public static Map < String, String > getselectOptions_Sae(String naturaGiuridica) {

        system.debug('SV naturaGiuridica:' + naturaGiuridica);
        Map < String, String > allOpts = new Map < String, String > ();
        
        
        List < NaturaGiuridicaSAE__mdt > val_mdt = [SELECT Id, Label, SAE__c, AtecoRichiesto__c, RaeRichiesto__c, SedeLegale__c FROM NaturaGiuridicaSAE__mdt  WHERE Label =: naturaGiuridica AND SedeLegale__c = 'IT'];
        
        system.debug('SV val_mdt: ' + val_mdt);

        Account objObject = new Account();

        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values =
            fieldMap.get('SAE__c').getDescribe().getPickListValues();
        
        system.debug('values --->' + values);
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            for(NaturaGiuridicaSAE__mdt x : val_mdt){
                if(x.SAE__c == a.getValue()){
                    allOpts.put(a.getLabel(), a.getValue());
                }
            }
        }
        system.debug('allOpts ---->' + allOpts);
        
       
        return allOpts;
    }

    @AuraEnabled
    public static Boolean getselectOptions_Rae(String naturaGiuridica, String sae) {

        system.debug('SV naturaGiuridica:' + naturaGiuridica);      
        system.debug('SV sae:' + sae);   
        
        List < NaturaGiuridicaSAE__mdt > val_mdt = [SELECT Id, Label, SAE__c, AtecoRichiesto__c, RaeRichiesto__c, SedeLegale__c FROM NaturaGiuridicaSAE__mdt  WHERE Label =: naturaGiuridica AND SAE__c =: sae AND SedeLegale__c = 'IT'];
        
        
       
        return val_mdt.size() > 0 ? val_mdt[0].RaeRichiesto__c : false;
    }

    @AuraEnabled
    public static Map < String, String > getselectOptions_Nazione (String objectName, String params, String condition) {

        system.debug('SV objectName:' + objectName);
        Map < String, String > allOpts = new Map < String, String > ();

        // Get the list of picklist values for this field.
        list < Comune__c > values = [SELECT Id, Name, GruppoSAE__c FROM Comune__c WHERE StatoEstero__c = TRUE AND FlagStorico__c = FALSE AND CodiceLingua__c = NULL ORDER BY Name];
        
        // Add these values to the selectoption list.
        for (Comune__c a: values) {
            allOpts.put(a.Name, a.Name);
        }
        
		// Get the list of picklist values for this field.     
        
        return allOpts;
    }

    @AuraEnabled
    public static List<Comune__c> getselectOptions_ComuniFromProvincia(String objObject, String provincia) {

        system.debug('SV objObject:' + objObject);

        List < Comune__c > values = [SELECT Name FROM Comune__c WHERE StatoEstero__c = false AND Provincia__c =: provincia ORDER BY Name];
        
        return values;
    }

	//adione CRM ID 211
    @AuraEnabled
    public static Boolean getCCIAA_ATECO_Conf(String naturaGiuridica, String sae, String recordId, String objType) {
		return BI_CRM_FrontEndUtils_CODE.getCCIAA_ATECO_Conf(naturaGiuridica, sae, recordId, objType);
	}
    
    @AuraEnabled
    public static CreateAccount.WrapperRecords getPositionRecords() {
        
        CreateAccount.WrapperRecords lstPositionRecords = 
		new CreateAccount.WrapperRecords();
        
        
        
        return lstPositionRecords;

    }

    @AuraEnabled
    public static Contact getContactFromDI(Account InputObj) {
        System.debug('SV Account objObject: ' + InputObj);
        
        Contact result = new Contact();
        result = CtrlWizardAccount.WGC_setupDIContact(InputObj);

        return result;
        
    }

    @AuraEnabled
    public static List<Ateco__c> getAtecoElement(String atecoCod){
        return [ SELECT Id, Name, Cedacri__c, Descrizione__c, SettoreAttivita__c, RAE__c, Mercato__c FROM Ateco__c WHERE Cedacri__c =: atecoCod LIMIT 1];
    }

    @AuraEnabled
    public static Impostazioni__c getCS_CedacriSleepTime() {
        return Impostazioni__c.getInstance();
        
    }

    @AuraEnabled
    public static User getUserInfo() {
        return [ SELECT Id, Name, Qualifica_Utente__c FROM User WHERE Id =: UserInfo.getUserId() ];
        
    }
    
    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperRecords {
        //adione CRM ID 80
        @AuraEnabled public String ndg;
		@AuraEnabled public String pivaOrCf;
    	@AuraEnabled public String ragioneSociale;
    	@AuraEnabled public String provincia;
    	@AuraEnabled public String tipoDiRicerca;
    	@AuraEnabled public Boolean estero;
        
        public WrapperRecords() {
			ndg = '';
            estero = false;
            pivaOrCf = '';
            ragioneSociale = '';
            provincia = '';
            tipoDiRicerca = 'piva';
        }
    }
    
    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Account> data;
        
        public WrapperResponse() {
            success = true;
            msg = '';
            data = new List<Account>();
        }
    }

}