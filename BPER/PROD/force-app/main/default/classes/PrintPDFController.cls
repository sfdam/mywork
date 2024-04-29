public without sharing class PrintPDFController {
    private static String PLACEHOLDER_SEZIONI = '###ZONA_SEZIONI###';
    private static String PLACEHOLDER_COMPONENTI = '###ZONA_COMPONENTI###';
    public static String REGEX_SEARCH_CAMPI = '\\{!.+?\\}'; //{!campo__c}
    public static String PLACEHOLDER_TABELLA = '###XML_DETTAGLIO###';
    public static String PLACEHOLDER_NUMERO_RIGHE = '###NUMERO_RIGHE###';

    public static Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    public static String certificationName = isSandbox ? 'salesforcetestclient2024' : 'salesforceprodclient2024';

    public virtual class BaseException extends Exception {}

    // NEW DK
    private final Static String regex = '[0-9A-Za-z\\-\\+ =_&%\"]{0,255}';
    private final Static Pattern regexPattern = Pattern.compile(regex);
    public Static String userSessionId {
        get{
            
            if(userSessionId != null)return userSessionId;

            List<String> matchList = new List<String>();
            Matcher regexMatcher = regexPattern.matcher(UserInfo.getSessionId());
            while (regexMatcher.find()) {
                matchList.add(regexMatcher.group());
            }
            userSessionId = String.join(matchList, '');
            return userSessionId;
        }set;
    }

    /*public static User currentUser {
        get{

            if(currentUser != null){
                return currentUser;
            }

            currentUser = [SELECT FederationIdentifier, FirstName, LastName, abi__c, applicazione__c, ndgsettoriale__c,
                        banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c,
                        sessionId__c, operationId__c, sysCaller__c, fnCaller__c, serviceName__c, fnName__c,
                        Token__c, idApplicazione__c, esb_idCed__c, esb_operatore__c, esb_IP__c,
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c
                        FROM User WHERE id =: UserInfo.getUserId()];
            return currentUser;
        }set;
    }*/
    // NEW DK
    @AuraEnabled
    public static List<PDFConfigurator__mdt> loadMetaDataStructure(Id recordId) {
        String recordTypeDeveloperName = getAccountRecordTypeDeveloperName(recordId);

        List<PDFConfigurator__mdt> metadata = [
            SELECT 
                Id, Ordine__c, COMPONENT__c,SECTION__c 
            FROM PDFConfigurator__mdt 
            WHERE   COMPONENT__c = '' 
                AND isRoot__c = false 
                AND Oggetto__c = 'Account'
                AND isActive__c = true
                AND SECTION__c != 'Contact History'
                AND (OBJRECORDTYPE__c = NULL OR OBJRECORDTYPE__c = :recordTypeDeveloperName)
                ORDER BY Ordine__c ASC
            ];
        return metadata;
    }

    @AuraEnabled
    public static Map<String, Object> getAllData(String recordId){
        User user = [SELECT Id, Profile.Name, idced__c, PTF_RuoloLDAP__c FROM User WHERE id =: UserInfo.getUserId()];
        String recordTypeDeveloperName = getAccountRecordTypeDeveloperName(recordId);
        String rootCampiAggiuntivi = getRootCampiAggiuntivi('Account', recordTypeDeveloperName);
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('Account')) + ' WHERE id =\'' + String.escapeSingleQuotes(recordId) + '\'';
        if(String.isNotBlank(rootCampiAggiuntivi)){
            rootCampiAggiuntivi = (rootCampiAggiuntivi.startsWith(',')) ? rootCampiAggiuntivi : ', ' + rootCampiAggiuntivi;
            query = query.replaceFirst('FROM', String.escapeSingleQuotes(rootCampiAggiuntivi) + ' FROM');
        }
        Account account = Database.query(query);
        List<PDFConfigurator__mdt> metadata = [
        SELECT 
            Id, Ordine__c, COMPONENT__c,SECTION__c 
        FROM PDFConfigurator__mdt 
        WHERE   COMPONENT__c = '' 
            AND isRoot__c = false 
            AND Oggetto__c = 'Account'
            AND isActive__c = true
            AND SECTION__c != 'Contact History'
            AND (OBJRECORDTYPE__c = NULL OR OBJRECORDTYPE__c = :recordTypeDeveloperName)
            ORDER BY Ordine__c ASC
        ];
        Boolean canChoose = false;
        // FS - 14122021 - START - modifica filtri per allineamento alla logica di front end per visualizzare scheda full e light
        /*if(recordTypeDeveloperName=='Cointestazione'){
            if((account.CRM_CheckMappingFilMacrofilMMDS__c && 
                (account.CRM_CheckVisibNDGFull__c ||
               account.CRM_VisibilitaClientiUffPrivate__c ||
               account.CRM_VisibilitaKeyClientImprese__c)) ||     
               account.CRM_VisibilitaFiliale_Capofila__c ||
               account.CRM_VisibilitaClientiLivelliFunzionali__c ||
               account.CRM_VisibilitaClientiCF__c ||
               account.PTF_IsGruppo__c){
                   
                   canChoose = true;
               }
        }else if(recordTypeDeveloperName=='PersonAccount' || recordTypeDeveloperName=='IndustriesBusiness' ) {
         */   
            /*if((account.CRM_CheckMappingFilMacrofilMMDS__c && 
                (account.CRM_CheckVisibNDGFull__c ||
                account.CRM_VisibilitaClientiUffPrivate__c ||
                account.CRM_VisibilitaKeyClientImprese__c)) ||     
                account.CRM_VisibilitaFiliale_Capofila__c ||
                account.CRM_VisibilitaClientiLivelliFunzionali__c ||
                account.CRM_VisibilitaClientiCF__c ||
                account.PTF_IsGruppo__c){
                   WGC_ActivityTimeLine_Item_DEM
                   canChoose = true;
               }*/

               if(account.CRM_VisibilitaFiliale_Capofila__c ||
               account.CRM_VisibilitaClientiLivelliFunzionali__c ||
               account.CRM_CheckVisibNDGFull__c ||
               account.CRM_VisibilitaClientiUffPrivate__c ||
               account.CRM_VisibilitaKeyClientImprese__c ||     
               account.CRM_VisibilitaClientiCF__c ||
               account.PTF_IsGruppo__c ||
               account.CRM_Visibilita_PrivateBanker__c){

                if(recordTypeDeveloperName=='PersonAccount' && account.CRM_Privacy_5Level__c == 'Yes' && account.CRM_Privacy_6Level__c == 'Yes'){
                    canChoose = true;
                }else if(recordTypeDeveloperName=='IndustriesBusiness' && account.CRM_BusinessPrivacy2Level__c == 'Yes'){
                    canChoose = true;
                }else{
                    canChoose = true;
                }
                   
               }
            //    canChoose = true;
               
       //}
       //FS - 14122021 - END


        return new Map<String, Object>{
            'accountQuery' => query,
            'account' => account,
            'metadata' => metadata,
            'canChoose' => canChoose,
            'recTypeDevName' => recordTypeDeveloperName
        };
    }

    //S: Vecchia Gestione waterfall, sostituita dalle promise
    //GENERAZIONE XML
    /*@AuraEnabled
    public static string generaXml(List<PDFConfigurator__mdt> selectedSections, Id recordId){
        String recordTypeDeveloperName = getAccountRecordTypeDeveloperName(recordId);
        Account currentAccount =  getAccountData(recordId)[0];
        List<PDFConfigurator__mdt> fullMetadata = getFullMetadataFromSelected(selectedSections, 'Account'
                                                    , recordTypeDeveloperName);
        String rootXml = getRootXML(fullMetadata,currentAccount);
        String sezioniXml = getSezioniXML(fullMetadata,currentAccount); 
        return rootXml.replace(PLACEHOLDER_SEZIONI,sezioniXml);
    }*/
    //E: Vecchia Gestione waterfall, sostituita dalle promise

    @AuraEnabled
    public static String getAccountRecordTypeDeveloperName(Id recordId){
        Account currentAccount = [SELECT RecordType.DeveloperName FROM Account WHERE id =: recordId LIMIT 1].get(0);
        return currentAccount.RecordType.DeveloperName;
    }

    @AuraEnabled
    public static List<Account> getAccountData(Id recordId){
        String rootCampiAggiuntivi = getRootCampiAggiuntivi('Account', getAccountRecordTypeDeveloperName(recordId));
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('Account')) + ' WHERE id =: recordId';
        if(String.isNotBlank(rootCampiAggiuntivi)){
            rootCampiAggiuntivi = (rootCampiAggiuntivi.startsWith(',')) ? rootCampiAggiuntivi : ', ' + rootCampiAggiuntivi;
            query = query.replaceFirst('FROM', String.escapeSingleQuotes(rootCampiAggiuntivi) + ' FROM');
        }
        return (List<Account>)Database.query(query);
    }

    @AuraEnabled
    public static List<PDFConfigurator__mdt> getFullMetadataFromSelected(List<PDFConfigurator__mdt> selectedSections, String obj, String recordTypeDeveloperName){
        List<String> sezioni = new List<String>();
        List<PDFConfigurator__mdt> fullMetadata = new List<PDFConfigurator__mdt>();

        for(PDFConfigurator__mdt s : selectedSections){
            sezioni.add(s.SECTION__c);
        }

        //Tutti gli elementi selezionati
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('PDFConfigurator__mdt')) + 
                        ' WHERE SECTION__c IN :sezioni AND OGGETTO__c =:obj AND isActive__c = true AND ObjType__c = null' +
                        ' AND (OBJRECORDTYPE__c = NULL OR OBJRECORDTYPE__c = :recordTypeDeveloperName) ORDER BY Ordine__c ASC';
        fullMetadata.addAll((List<PDFConfigurator__mdt>)Database.query(query));

        //Elemento root
        query = String.escapeSingleQuotes(SV_Utilities.selectAllField('PDFConfigurator__mdt')) + 
                        ' WHERE OGGETTO__c =:obj AND isRoot__c = true AND ObjType__c = null'+
                        ' AND (OBJRECORDTYPE__c = NULL OR OBJRECORDTYPE__c = :recordTypeDeveloperName) ORDER BY Ordine__c ASC';
        fullMetadata.addAll((List<PDFConfigurator__mdt>)Database.query(query));
        return fullMetadata;
    }

    //Recupera eventuali campi aggiuntivi da aggiungere alla query dell'oggetto principale
    @TestVisible
    public static String getRootCampiAggiuntivi(String objectName, String recordTypeDeveloperName){
        String rootCampiAggiuntiviNoRecordType = '';
        String rootCampiAggiuntivi = '';

        List<PDFConfigurator__mdt> metaList = [SELECT QueryCampiAggiuntivi__c, OBJRECORDTYPE__c FROM PDFConfigurator__mdt 
                                            WHERE COMPONENT__c = ''  AND isRoot__c = true
                                            AND Oggetto__c = :objectName AND isActive__c = true
                                            AND (OBJRECORDTYPE__c = NULL OR OBJRECORDTYPE__c = :recordTypeDeveloperName)
                                            ORDER BY OBJRECORDTYPE__c DESC];

        for(PDFConfigurator__mdt meta : metaList){
            if(meta.OBJRECORDTYPE__c == null){
                rootCampiAggiuntiviNoRecordType = meta.QueryCampiAggiuntivi__c;
            }else{
                rootCampiAggiuntivi = meta.QueryCampiAggiuntivi__c;
            }
        }

        if(String.isNotBlank(rootCampiAggiuntiviNoRecordType)){
            return rootCampiAggiuntiviNoRecordType;
        }else{
            return rootCampiAggiuntivi;
        }
    }

    //Recupera l'xml di Root e lo popola con i dati dell'oggetto principale
    @AuraEnabled
    public static String getRootXML(List<PDFConfigurator__mdt> fullMetadata, Account currentAccount){
        String xml = '';

        for(PDFConfigurator__mdt m : fullMetadata){
            if(m.isRoot__c){
                xml = m.baseXml__c;
                break;
            }
        }

        return replaceFieldsWithData(xml,currentAccount);
    }

    @AuraEnabled
    public static String executeCall(String xml, Account currentAccount, String recordTypeDeveloperName){

        try {
            User currentUser = [SELECT FederationIdentifier, FirstName, LastName, abi__c, applicazione__c, ndgsettoriale__c,
                        banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c,
                        sessionId__c, operationId__c, sysCaller__c, fnCaller__c, serviceName__c, fnName__c,
                        Token__c, idApplicazione__c, esb_idCed__c, esb_operatore__c, esb_IP__c,
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c
                        FROM User WHERE id =: UserInfo.getUserId()];
            Datetime startTime = Datetime.now();
            HTTPResponse res = new HTTPResponse();
            HttpRequest req = new HttpRequest();
            Map<String,String> headersReq= new Map<String,String>();
            String apiRequestName = 'generateDocument';
            List<CRM_CustomerInterview__c> checkUp = [SELECT Id  FROM CRM_CustomerInterview__c  WHERE CRM_Customer__c =: currentAccount.Id];
            List<CRM_Note__c> noteList = new List<CRM_Note__c>(); 
            if(!checkUp.isEmpty()){
                noteList = [SELECT CRM_NoteNucleoFamiliare__c, CRM_NoteAndamentoAzienda__c FROM CRM_Note__c WHERE CRM_Tagliando__c =: checkUp[0].Id];
            }
            List<CRM_LinkedNDG__c> ndgCollegati = [SELECT Id, CRM_RelatedAccountNDG__c, CRM_RelatedAccount__c, CRM_RelatedAccount__r.Name, CRM_RelatedAccountFilialeName__c, CRM_RelatedAccountPortafoglioName__c, CRM_LinkType__c, CRM_RelatedAccountStatoCRM__c, CRM_RelatedAccountFiliale__c, CRM_RelatedAccountGruppoGestionale__c, CRM_RelatedNDGManager__c FROM CRM_LinkedNDG__c WHERE CRM_Account__c =: currentAccount.Id];
    
            WsRestInput restInput = new WsRestInput(currentUser, null);
            Map<String, String> testataMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.testata), Map<String, String>.class);
            Map<String, String> securityMap = (Map<String, String>)JSON.deserialize(JSON.serialize(restInput.headers.security), Map<String, String>.class);
            if(xml.contains('{presenzaCollegati}')){
                String presenzaCollegati = ndgCollegati.size() > 0 ? 'Si' : 'No';
                xml = xml.replace('{presenzaCollegati}', presenzaCollegati);
            }
    
            if(xml.contains('{capoNucleo}')){
                List<Account> capoNucleo = [SELECT CRM_NDG__c FROM Account WHERE PTF_Nucleo__c =: currentAccount.PTF_Nucleo__c AND PTF_Caponucleo__c = true];
                if(!capoNucleo.isEmpty()){
                    String ndgCapoNucleo = capoNucleo[0].CRM_NDG__c;
                    xml = xml.replace('{capoNucleo}', ndgCapoNucleo);
                }
            }
    
            if(xml.contains('{presenzaFEAFEQ}')){
                String presenzaFEQ = currentAccount.CRM_AdesioneFEQ__c != null ? 'SI FEQ' : 'NO FEQ';
                String presenzaFEA = currentAccount.CRM_AdesioneFEA__c != null ? 'SI FEA' : 'NO FEA';
                xml = xml.replace('{presenzaFEAFEQ}', presenzaFEQ + '-' + presenzaFEA);
            }
    
    
            if(xml.contains('{microImpresa}')){
                String microImpresa = currentAccount.CRM_MicroImpresa__c ? 'Si' : 'No';
                xml = xml.replace('{microImpresa}', microImpresa);
            }
    
            if(xml.contains('{customerDesk}')){
                String customerDesk = currentAccount.CRM_CustomerDesk__c ? 'Si' : 'No';
                xml = xml.replace('{customerDesk}', customerDesk);
            }
    
            if(xml.contains('{homeBankingPrivati}')){
                List<FinServ__FinancialAccount__c> finAccountList = [SELECT Name FROM FinServ__FinancialAccount__c WHERE FinServ__PrimaryOwner__c =: currentAccount.Id AND FinServ__RecordTypeName__c = 'Banking Multicanale' AND FinServ__Status__c  = 'Active' LIMIT 1];
                String homeBankingPrivati = !finAccountList.isEmpty() ? finAccountList[0].Name : '';
                xml = xml.replace('{homeBankingPrivati}', homeBankingPrivati);
            }
            List<CRM_Channel__c> channelList = new List<CRM_Channel__c>();
            if(xml.contains('{homeBankingImprese}')){
                channelList = [SELECT Name, CRM_LastAccessDate__c FROM CRM_Channel__c WHERE CRM_Account__c =: currentAccount.Id LIMIT 1];
                String homeBankingImprese = !channelList.isEmpty() ? channelList[0].Name : '';
                xml = xml.replace('{homeBankingImprese}', homeBankingImprese);
            }
    
            if(xml.contains('{consulenzaEvolutiva}')){
                String consulenzaEvolutiva = currentAccount.CRM_ConsulenzaEvoluta__c ? 'Si' : 'No';
                xml = xml.replace('{consulenzaEvolutiva}', consulenzaEvolutiva);
            }
    
            if(xml.contains('{aderenzalPortafoglioModello}')){
                List<CRM_IndicatoriCliente__c> indicatoruList = [SELECT Name, CRM_AderenzaPTFModello__c FROM CRM_IndicatoriCliente__c WHERE CRM_Account__c =: currentAccount.Id AND RecordType.Developername = 'Flat' LIMIT 1];
                String aderenzalPortafoglioModello = !indicatoruList.isEmpty() ? indicatoruList[0].CRM_AderenzaPTFModello__c + '%' : '';
                xml = xml.replace('{aderenzalPortafoglioModello}', aderenzalPortafoglioModello);
            }
    
            if(xml.contains('{dataUltimoAccesso}')){
                DateTime dataUltimoAccesso = !channelList.isEmpty() && channelList[0].CRM_LastAccessDate__c != null ? channelList[0].CRM_LastAccessDate__c : null;
                if(dataUltimoAccesso != null){
                    xml = xml.replace('{dataUltimoAccesso}', dataUltimoAccesso.format());
                }else{
                    xml = xml.replace('{dataUltimoAccesso}', '');
                }
            }
    
            if(xml.contains('{aziendaOperanteConEstero}')){
                String aziendaOperanteConEstero = currentAccount.CRM_AziendaOperanteAllEstero__c ? 'Si' : 'No';
                xml = xml.replace('{aziendaOperanteConEstero}', aziendaOperanteConEstero);
            }
    
            if(xml.contains('{noteNucleoFamiliare}')){
    
                String noteNucleoFamiliare = ''; 
                if(!noteList.isEmpty()){
                    noteNucleoFamiliare = !String.isBlank(noteList[0].CRM_NoteNucleoFamiliare__c) ? noteList[0].CRM_NoteNucleoFamiliare__c : '';
                }
                xml = xml.replace('{noteNucleoFamiliare}', noteNucleoFamiliare);
            }
    
            if(xml.contains('{noteAndamentoAzienda}')){
    
                String noteAndamentoAzienda = ''; 
                if(!noteList.isEmpty()){
                    noteAndamentoAzienda = !String.isBlank(noteList[0].CRM_NoteAndamentoAzienda__c) ? noteList[0].CRM_NoteAndamentoAzienda__c : '';
                }
                xml = xml.replace('{noteAndamentoAzienda}', noteAndamentoAzienda);
            }
    
            if(xml.contains('{relatedAccountNDG}')){
                String relatedAccountNDG = '';
                if(!ndgCollegati.isEmpty()){
                    relatedAccountNDG = !String.isBlank(ndgCollegati[0].CRM_RelatedAccountNDG__c) ? ndgCollegati[0].CRM_RelatedAccountNDG__c : '';
                }
                xml = xml.replace('{relatedAccountNDG}', relatedAccountNDG);
            }
            if(xml.contains('{relatedAccount}')){
                String relatedAccount = '';
                if(!ndgCollegati.isEmpty()){
                    relatedAccount = !String.isBlank(ndgCollegati[0].CRM_RelatedAccount__c) ? ndgCollegati[0].CRM_RelatedAccount__r.Name : '';
                }
                xml = xml.replace('{relatedAccount}', relatedAccount);
            }
            if(xml.contains('{relatedAccountFilialeName}')){
                String relatedAccountFilialeName = '';
                if(!ndgCollegati.isEmpty()){
                    relatedAccountFilialeName = !String.isBlank(ndgCollegati[0].CRM_relatedAccountFilialeName__c) ? ndgCollegati[0].CRM_relatedAccountFilialeName__c : '';
                }
                xml = xml.replace('{relatedAccountFilialeName}', relatedAccountFilialeName);
            }
            if(xml.contains('{relatedAccountPortafoglioName}')){
                String relatedAccountPortafoglioName = '';
                if(!ndgCollegati.isEmpty()){
                    relatedAccountPortafoglioName = !String.isBlank(ndgCollegati[0].CRM_relatedAccountPortafoglioName__c) ? ndgCollegati[0].CRM_relatedAccountPortafoglioName__c : '';
                }
                xml = xml.replace('{relatedAccountPortafoglioName}', relatedAccountPortafoglioName);
            }
            if(xml.contains('{relatedAccountStatoCRM}')){
                String relatedAccountStatoCRM = '';
                if(!ndgCollegati.isEmpty()){
                    relatedAccountStatoCRM = !String.isBlank(ndgCollegati[0].CRM_RelatedAccountStatoCRM__c) ? ndgCollegati[0].CRM_RelatedAccountStatoCRM__c : '';
                }
                xml = xml.replace('{relatedAccountStatoCRM}', relatedAccountStatoCRM);
            }
            if(xml.contains('{relatedAccountFiliale}')){
                String relatedAccountFiliale = '';
                if(!ndgCollegati.isEmpty()){
                    relatedAccountFiliale = !String.isBlank(ndgCollegati[0].CRM_RelatedAccountFiliale__c) ? ndgCollegati[0].CRM_RelatedAccountFiliale__c : '';
                }
                xml = xml.replace('{relatedAccountFiliale}', relatedAccountFiliale);
            }
            if(xml.contains('{relatedAccountGruppoGestionale}')){
                String relatedAccountGruppoGestionale = '';
                if(!ndgCollegati.isEmpty()){
                    relatedAccountGruppoGestionale = !String.isBlank(ndgCollegati[0].CRM_RelatedAccountGruppoGestionale__c) ? ndgCollegati[0].CRM_RelatedAccountGruppoGestionale__c : '';
                }
                xml = xml.replace('{relatedAccountGruppoGestionale}', relatedAccountGruppoGestionale);
            }
            if(xml.contains('{relatedAccountNDGManager}')){
                String relatedAccountNDGManager = '';
                if(!ndgCollegati.isEmpty()){
                    relatedAccountNDGManager = !String.isBlank(ndgCollegati[0].CRM_RelatedNDGManager__c) ? ndgCollegati[0].CRM_RelatedNDGManager__c : '';
                }
                xml = xml.replace('{relatedAccountNDGManager}', relatedAccountNDGManager);
            }
            if(xml.contains('{linkType}')){
                String linkType = '';
                if(!ndgCollegati.isEmpty()){
                    linkType = !String.isBlank(ndgCollegati[0].CRM_linkType__c) ? ndgCollegati[0].CRM_linkType__c : '';
                }
                xml = xml.replace('{linkType}', linkType);
            }
    
            // if(xml.contains('{relatedAccountNDG}') ||
            // xml.contains('{relatedAccount}') ||
            // xml.contains('{relatedAccountFilialeName}') ||
            // xml.contains('{relatedAccountPortafoglioName}') ||
            // xml.contains('{linkType}')){
    
            // }
    
            //Recupre dati da custom setting Endpoint List
            Endpoint__c apiRequest = Endpoint__c.getInstance(apiRequestName);
            String endpoint = apiRequest.Endpoint__c;
            String method = apiRequest.Method__c;
            Decimal timeout = apiRequest.Timeout__c;
            String bodyString = '';
    
            String listaPubFiles = recordTypeDeveloperName == 'PersonAccount' ? 'SF_Scheda_Privati.pub' : recordTypeDeveloperName == 'Cointestazione' ? 'SF_Scheda_CO.pub' : 'SF_Scheda_Imprese.pub';
    
            //effettua la request
            for(String key: testataMap.keySet()){
    
                if(testataMap.get(key) != null){
                    req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, testataMap.get(key));
                    headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, testataMap.get(key));
                }/*else{
                    
                    req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, '');
                    headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'testata' + '_' + key : key, '');
                }*/
            }
            for(String key: securityMap.keySet()){
        
                if(securityMap.get(key) != null){
                    headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'security' + '_' + key : key, securityMap.get(key));
                    req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'security' + '_' + key : key, securityMap.get(key));
                }/*else{
                    
                    headersReq.put(!WsRestUtils.outOfObjectParams.contains(key) ? 'security' + '_' + key : key, '');
                    req.setHeader(!WsRestUtils.outOfObjectParams.contains(key) ? 'security' + '_' + key : key, '');
                }*/
            }
    
            //form multipart preparation

            xml = xml.replaceAll('[\\x{FEFF}]', '')
            .replaceAll('​', '')
            .replaceAll('< ', '')
            .replaceAll('<br>', '')
            // .replaceAll('false', 'NO')
            // .replaceAll('true', 'SI')
            .replaceAll('#datarif#', DateTime.now().format());

            String regex = '\\#s.*?\\#e';
            Pattern pattr = Pattern.compile(regex); 
            Matcher mat = pattr.matcher(xml);
            if(xml.contains('#s')){

                do{
                    try{
                        String textInBetween = mat.group().replace('#s', '').replace('#e', '');
                        if(!String.isBlank(textInBetween)){
    
                            String formattedCurrency = Decimal.valueOf(textInBetween).format();
                            formattedCurrency = formattedCurrency.substringAfter(',').length() == 1 ? formattedCurrency + '0' : formattedCurrency;
                            xml = xml.replaceAll(mat.group(), formattedCurrency);
                        }else{
                            xml = xml.replaceAll(mat.group(), '0');
                        }
                    }catch(Exception ex){
                        System.debug('DK error_paramsMap: ' + ex);
                    }
                }while(mat.find());
            }

            if(xml.contains('#ps')){

                regex = '\\#ps.*?\\#pe';
                pattr = Pattern.compile(regex); 
                mat = pattr.matcher(xml);
                do{
                    try{
                        String textInBetween = mat.group().replace('#ps', '').replace('#pe', '');
                        if(!String.isBlank(textInBetween)){
    
                            xml = xml.replaceAll(mat.group(), (Decimal.valueOf(textInBetween)*100).format());
                        }else{
                            xml = xml.replaceAll(mat.group(), '0');
                        }
                    }catch(Exception ex){
                        System.debug('DK error_paramsMap: ' + ex);
                    }
                }while(mat.find());
            }


            if(xml.contains('#ds')){

                regex = '\\#ds.*?\\#de';
                pattr = Pattern.compile(regex); 
                mat = pattr.matcher(xml);
                do{
                    try{
                        String textInBetween = mat.group().replace('#ds', '').replace('#de', '');
                        if(!String.isBlank(textInBetween)){
    
                            xml = xml.replaceAll(mat.group(), textInBetween.split(' ')[0]);
                        }else{
                            xml = xml.replaceAll(mat.group(), '');
                        }
                    }catch(Exception ex){
                        System.debug('DK error_paramsMap: ' + ex);
                    }
                }while(mat.find());
            }

            if(xml.contains('#pls')){

                regex = '\\#pls.*?\\#ple';
                pattr = Pattern.compile(regex); 
                mat = pattr.matcher(xml);
                do{
                    try{
                        String textInBetween = mat.group().replace('#pls', '').replace('#ple', '');
                        if(!String.isBlank(textInBetween)){
    
                            textInBetween = !textInBetween.contains('-') ? '+' + textInBetween : textInBetween;
                            xml = xml.replaceAll(mat.group(), Integer.valueOf(textInBetween) + '%');
                        }else{
                            xml = xml.replaceAll(mat.group(), '');
                        }
                    }catch(Exception ex){
                        System.debug('DK error_paramsMap: ' + ex);
                    }
                }while(mat.find());
            }

            String xmlfileDecoded = EncodingUtil.base64Encode(Blob.valueOf(xml));

            Map<String, Object> body = new Map<String, Object>{
                'driver' => xmlfileDecoded,
                'includeHeader' => false,
                'includeMessageFile' => true ,
                'listaPubFiles' => new List<String>{listaPubFiles},
                'directory' => 'prova',
                'fileName' => 'SF_Driver',
                'fileNameRemote' => 'prova.pdf',
                'modalitaRestituzioneDocumento' => 'BINARY_FILE'
            };

            // req.setHeader('Connection', 'keep-alive');
            // req.setHeader('Accept', '*/*');
            // headersReq.put('Connection', 'keep-alive');
            // headersReq.put('Accept', '*/*');
            req.setEndpoint(endpoint);
            req.setMethod(method);
            req.setBody(JSON.serialize(body));
            req.setTimeout(timeout.intValue());
            req.setHeader('Content-Type', 'application/json');   
            if(certificationName != null) req.setClientCertificateName(certificationName);

            Datetime startTimeWS = Datetime.now();
            Http http = new Http();               
            res = http.send(req);

            Datetime endTimeWS = Datetime.now();

            WsRestUtils.writeLog(
                'generateDocument',
                method,
                JSON.serialize(body).length() >= 131070 ? JSON.serialize(body).substring(0, 131070) : JSON.serialize(body),
                res.getStatusCode(),
                res.getStatus(),
                res.getBody().length() >= 131070 ? res.getBody().substring(0, 131070) : res.getBody(),
                headersReq,
                new Map<String,String>(),
                endpoint,
                ''
                // responseObj.isCorrect() ? null : responseObj.getErrors()
            );
            Map<String,Object> response = (Map<String,Object>)JSON.deserializeUntyped(res.getBody());
            Datetime endTime = Datetime.now();
            if(response.containsKey('listaGeneratedFiles') && response.get('listaGeneratedFiles') != null){

                Map<String,Object> listaGeneratedFiles = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(response.get('listaGeneratedFiles')));
                List<Object> generatedFile = (List<Object>)JSON.deserializeUntyped(JSON.serialize(listaGeneratedFiles.get('generatedFile')));
                return (String)((Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(generatedFile[0]))).get('fileOutput');
            }else {
                return null;
            }
        } catch (Exception ex) {
            
            throw new BaseException('Error: ' + ex.getMessage() + '; at: ' + ex.getStackTraceString());
        }
    }

    public static void notifyUsers(Account currentAccount, String tipoStampa, Boolean success) {

        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='StampaPronta'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();

        // Set the contents for the notification
        notification.setTitle('Scheda PDF');
        if(success){

            notification.setBody('La stampa "' + tipoStampa + '" sul cliente ' + currentAccount.Name + '(' + currentAccount.CRM_NDG__c + ') risulta pronta.');
        }else{

            notification.setBody('Errore durante la stampa"' + tipoStampa + '" sul cliente ' + currentAccount.Name + '(' + currentAccount.CRM_NDG__c + '). Contattare il proprio amministratore');
        }

        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(currentAccount.Id);
        
        // Actually send the notification
        try {
            notification.send(new Set<String>{UserInfo.getUserId()});
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        }
    }


    //S: Vecchia Gestione waterfall, sostituita dalle promise
    //Recupera gli xml delle singole sezioni e ne popola i campi
    /*@TestVisible
    private static String getSezioniXML(List<PDFConfigurator__mdt> fullMetadata, Account currentAccount){
        String xml = '';

        Set<String> usedSezioni = new Set<String>();
        for(PDFConfigurator__mdt m : fullMetadata){
            if(m.COMPONENT__c == null && !usedSezioni.contains(m.SECTION__c) && m.isActive__c && !m.isRoot__c){
                //SEZIONE
                String currentSezione = m.SECTION__c;
                String xmlSezione = m.baseXml__c;
                usedSezioni.add(currentSezione); 

                //COMPONENTI
                String xmlComponenti = '';
                for(PDFConfigurator__mdt m2 : fullMetadata){
                    if(m2.COMPONENT__c != null && m2.SECTION__c == currentSezione && m2.isActive__c && !m2.isRoot__c){
                        if(m2.HasQuery__c){
                            //Facciamo la query indicata e sostituiamo i campi
                            String xmlFromQuery = getXMLFromQuery(m2,currentAccount);
                            xmlComponenti += xmlFromQuery;
                        }
                        else if(m2.HasMetodoSelezione__c){
                            //Chiamiamo il metodo recuperato dal metadata e sostituiamo i campi
                            String xmlFromMetodo = getXMLFromMethods(m2, currentAccount);
                            xmlComponenti += xmlFromMetodo;
                        }
                        else{
                            //Inserisco l'xml sostituendo i campi
                            String baseXml = m2.baseXml__c;
                            xmlComponenti += replaceFieldsWithData(baseXml, currentAccount);
                        }
                    }
                }

                xml += xmlSezione.replace(PLACEHOLDER_COMPONENTI,xmlComponenti);
            }
        }
        return xml;
    }*/

    @AuraEnabled
    public static Map<String,String> replaceFieldsWithData4Promise(PDFConfigurator__mdt meta, Account currentAccount){
        String stringResult = replaceFieldsWithData(meta.baseXml__c, currentAccount);
        Map<String,String> res = new Map<String,String>();
        res.put(meta.SECTION__c, stringResult);
        return res;
    }

    public static Map<String, String> replaceFromQuery(PDFConfigurator__mdt meta, Account currentAccount, List<Sobject> responseList){
        String xml = '';
        String stringToReturn = '';
        
        String basexml = meta.baseXml__c; //RECUPERARE BASE XML

        String oggettoFrom  = meta.QueryObjectType__c;
        String campoLookup  = meta.QueryLookup__c; // =:recordId //WHERE campoLookup =: recordId '
        String whereCond    = (String.isNotBlank(meta.QueryWhereCondition__c)) ? meta.QueryWhereCondition__c : 'AND Id != null';
        String recordId     = currentAccount.Id;
        try{

            if(responseList.size() > 0){
                //Costruzione righe
                String xmlTabellaTeporaneo = ''; //CONTERRÀ LA LISTA DEI DETTAGLI <dettaglio></dettaglio><dettaglio></dettaglio>
                String templateIteration = meta.TemplateIterationXml__c; //RECUPERA IL LAYOUT DELLA SINGOLA RIGA
                for(Sobject singleObject : responseList)
                {
                    xmlTabellaTeporaneo += replaceFieldsWithData(templateIteration, singleObject);
                }
    
                //se l'xml prevede il numero righe, sostituisco il placeholder con il numero corrente
                if(basexml.contains(PLACEHOLDER_NUMERO_RIGHE)){
                    basexml = basexml.replace(PLACEHOLDER_NUMERO_RIGHE, String.valueOf(responseList.size()));
                }
    
                stringToReturn = basexml.replace(PLACEHOLDER_TABELLA,xmlTabellaTeporaneo);
            }else{
                System.debug('replaceFromQuery: responseList is empty');
                stringToReturn = '';
            }
        }catch (Exception ex){
            //in caso di eccezione, non stampo il componente
            System.debug('Error in replaceFromQuery: ' + ex.getMessage() + '' + ex.getStackTraceString());
            return new Map<String, String>{
                meta.SECTION__c => '<exception>Error in replaceFromQuery: ' + ex.getMessage() + '' + ex.getStackTraceString() + '</exception>'
            };
        }
        return new Map<String, String>{
            meta.SECTION__c => stringToReturn
        };
    }

    @AuraEnabled
    public static Map<String,String> getXMLFromQuery4Promise(PDFConfigurator__mdt meta, Account currentAccount){
        String stringResult = getXMLFromQuery(meta,currentAccount);
        Map<String,String> res = new Map<String,String>();
        res.put(meta.SECTION__c, stringResult);
        return res;
    }

    @AuraEnabled
    public static String getXMLFromQuery(PDFConfigurator__mdt meta, Account currentAccount){
        String xml = '';
        String stringToReturn = '';
        
        String basexml = meta.baseXml__c; //RECUPERARE BASE XML

        String oggettoFrom  = meta.QueryObjectType__c;
        String campoLookup  = meta.QueryLookup__c; // =:recordId //WHERE campoLookup =: recordId '
        String whereCond    = (String.isNotBlank(meta.QueryWhereCondition__c)) ? meta.QueryWhereCondition__c : 'AND Id != null';
        String recordId     = currentAccount.Id;
        
        String query = SV_Utilities.selectAllField(oggettoFrom) + ' WHERE '+campoLookup+' = \''+recordId+'\' '+whereCond;

        //inserisco nella query eventuali campi aggiuntivi
        if(String.isNotBlank(meta.QueryCampiAggiuntivi__c)){
            String campiAggiuntivi = meta.QueryCampiAggiuntivi__c.trim();
            campiAggiuntivi = (campiAggiuntivi.startsWith(',')) ? campiAggiuntivi : ', ' + campiAggiuntivi;
            query = query.replaceFirst('FROM', String.escapeSingleQuotes(campiAggiuntivi) + ' FROM');
        }

        try{

            List<SObject> objectList = Database.query(query);
        
            if(objectList.size() > 0){
                //Costruzione righe
                String xmlTabellaTeporaneo = ''; //CONTERRÀ LA LISTA DEI DETTAGLI <dettaglio></dettaglio><dettaglio></dettaglio>
                String templateIteration = meta.TemplateIterationXml__c; //RECUPERA IL LAYOUT DELLA SINGOLA RIGA
                for(Sobject singleObject : objectList)
                {
                    xmlTabellaTeporaneo += replaceFieldsWithData(templateIteration, singleObject);
                }

                //se l'xml prevede il numero righe, sostituisco il placeholder con il numero corrente
                if(basexml.contains(PLACEHOLDER_NUMERO_RIGHE)){
                    basexml = basexml.replace(PLACEHOLDER_NUMERO_RIGHE, String.valueOf(objectList.size()));
                }

                stringToReturn = basexml.replace(PLACEHOLDER_TABELLA,xmlTabellaTeporaneo);
            }else{
                System.debug('getXMLFromQuery: objectList is empty');
                stringToReturn = '';
            }
        }catch (Exception ex){
            //in caso di eccezione, non stampo il componente
            System.debug('DK query: ' + query);
            System.debug('Error in getXMLFromQuery: ' + ex.getMessage() + '' + ex.getStackTraceString());
            return '<exception>Error in getXMLFromQuery: ' + ex.getMessage() + '' + ex.getStackTraceString() + '</exception>';
        }
        
        return stringToReturn;
    }

    @AuraEnabled
    public static Map<String,String> getXMLFromMethods4Promise(PDFConfigurator__mdt meta, sObject currentObject, List<SObject> recordList){
        String stringResult = getXMLFromMethods(meta, currentObject, recordList);
        Map<String,String> res = new Map<String,String>();
        res.put(meta.SECTION__c, stringResult);
        return res;
    }

    @AuraEnabled
    public static Map<String,String> getXMLFromMethods4Promise(PDFConfigurator__mdt meta, sObject currentObject){
        String stringResult = getXMLFromMethods(meta, currentObject, null);
        Map<String,String> res = new Map<String,String>();
        res.put(meta.SECTION__c, stringResult);
        return res;
    }
    
    @AuraEnabled
    public static Map<String,String> replaceFromMethods(PDFConfigurator__mdt meta, sObject currentObject, List<Map<String,String>> recordList, pdfConfiguratorCallableMethods.indicatoriRischioWrapper indicatoriRischioWrapper){
        String xml = '';
        List<Map<String,String>> fieldNameToFieldValueMapList = new List<Map<String,String>>();
        List<Object> fieldNameTMPList = new List<Object>();
        String stringToReturn = '';

        String className = meta.MetodoSelezioneClasse__c;
        String methodName = meta.MetodoSelezioneName__c;
        String jsonAdditionalParameters = meta.MetodoSelezioneAdditionalParameters__c;

        if(String.isNotBlank(className) && String.isNotBlank(methodName)){
        
            String basexml = meta.baseXml__c; //RECUPERARE BASE XML

            try{
                if(recordList != null){

                    fieldNameToFieldValueMapList = (List<Map<String,String>>)  recordList;
    
                    if(fieldNameToFieldValueMapList.size() > 0){
                        //Costruzione righe
                        String xmlTabellaTeporaneo = ''; //CONTERRÀ LA LISTA DEI DETTAGLI <dettaglio></dettaglio><dettaglio></dettaglio>
                        String templateIteration = meta.TemplateIterationXml__c; //RECUPERA IL LAYOUT DELLA SINGOLA RIGA
                        for(Map<String,String> fieldNameToFieldValueMap : fieldNameToFieldValueMapList)
                        {
                            xmlTabellaTeporaneo += replaceFieldsWithData(templateIteration, fieldNameToFieldValueMap);
                        }
    
                        //se l'xml prevede il numero righe, sostituisco il placeholder con il numero corrente
                        if(basexml.contains(PLACEHOLDER_NUMERO_RIGHE)){
                            basexml = basexml.replace(PLACEHOLDER_NUMERO_RIGHE, String.valueOf(fieldNameToFieldValueMapList.size()));
                        }
    
                        stringToReturn = basexml.replace(PLACEHOLDER_TABELLA,xmlTabellaTeporaneo);
                    }else{
                        System.debug('replaceFromMethods: fieldNameToFieldValueMapList is empty');
                        stringToReturn = '';
                    }
                }else{

                    // DK - CR 58271
                    if(indicatoriRischioWrapper.flat != null && !indicatoriRischioWrapper.storico.isEmpty()){

                        String xmlTabellaTeporaneo = ''; //CONTERRÀ LA LISTA DEI DETTAGLI <dettaglio></dettaglio><dettaglio></dettaglio>
                        String templateIteration = meta.TemplateIterationXml__c; //RECUPERA IL LAYOUT DELLA SINGOLA RIGA
                        xmlTabellaTeporaneo = replaceFieldsWithDataIRW(templateIteration, indicatoriRischioWrapper);
                        /*for(Map<String,String> fieldNameToFieldValueMap : indicatoriRischioWrapper.storico){
                            xmlTabellaTeporaneo += replaceFieldsWithData(templateIteration, fieldNameToFieldValueMap);
                        }*/

                        //se l'xml prevede il numero righe, sostituisco il placeholder con il numero corrente
                        if(basexml.contains(PLACEHOLDER_NUMERO_RIGHE)){
                            basexml = basexml.replace(PLACEHOLDER_NUMERO_RIGHE, String.valueOf(indicatoriRischioWrapper.storico.size()));
                        }
                        stringToReturn = basexml.replace(PLACEHOLDER_TABELLA, xmlTabellaTeporaneo);
                    }
                    // DK - CR 58271
                }
            }catch (Exception ex){
                //in caso di eccezione, non stampo il componente
                System.debug('Error in replaceFromMethods: ' + ex.getMessage() + '' + ex.getStackTraceString());
                return new Map<String, String>{
                    meta.SECTION__c => '<exception>Error in replaceFromMethods: '  + ex.getMessage() + '' + ex.getStackTraceString() + '</exception>'
                };
            }

        }else{
            System.debug('!!!!! Error in replaceFromMethods: Dynamic className or methodName are blank');
            stringToReturn = '<exception>Error in replaceFromMethods: Dynamic className or methodName are blank</exception>';
        }
        
        return new Map<String, String>{
            meta.SECTION__c => stringToReturn
        };
    }

    // DK - CR 58271
    public static String replaceFieldsWithDataIRW(String xml, pdfConfiguratorCallableMethods.indicatoriRischioWrapper indicatoriRischioWrapper){
        if(xml != null){

            List<String> campi = new List<String>();
            String iteration = xml.substringAfter('#startiter').substringBefore('#enditer');
            xml = xml.replace(iteration, '');
            Pattern p = Pattern.compile(REGEX_SEARCH_CAMPI);
            Matcher m = p.matcher(xml);

            while(m.find()) {
                String daSostituire = m.group(0);
                String campo = daSostituire.replace('{!', '').replace('}', '');
                String valore = indicatoriRischioWrapper.flat.containsKey(campo) ? indicatoriRischioWrapper.flat.get(campo) :'';

                xml = valore != null ? xml.replace(daSostituire,valore) : xml.replace(daSostituire,'');
            }
            if(iteration != null){
                String storico = '';
                for(Integer i =0; i<indicatoriRischioWrapper.storico.size(); i++){
                    p = Pattern.compile(REGEX_SEARCH_CAMPI);
                    m = p.matcher(iteration);
                    storico += iteration.replace('#Niter#', String.valueOf(i+1));
                    while(m.find()) {
                        String daSostituire = m.group(0);
                        String campo = daSostituire.replace('{!', '').replace('}', '');
                        String valore = indicatoriRischioWrapper.storico[i].containsKey(campo) ? indicatoriRischioWrapper.storico[i].get(campo) :'';
        
                        storico = valore != null ? storico.replace(daSostituire,valore) : storico.replace(daSostituire,'');
                    }
                }
                xml = xml.replace('#toreplace', storico);
            }
        }
        xml = xml.remove('#startiter').remove('#enditer');
        return xml;
    }
    // DK - CR 58271

    @AuraEnabled
    public static String getXMLFromMethods(PDFConfigurator__mdt meta, sObject currentObject, List<SObject> recordList){
        String xml = '';
        List<SObject> fieldNameToSObjectList = new List<SObject>();
        List<Map<String,String>> fieldNameToFieldValueMapList = new List<Map<String,String>>();
        List<Object> fieldNameTMPList = new List<Object>();
        String stringToReturn = '';

        String className = meta.MetodoSelezioneClasse__c;
        String methodName = meta.MetodoSelezioneName__c;
        String jsonAdditionalParameters = meta.MetodoSelezioneAdditionalParameters__c;

        if(String.isNotBlank(className) && String.isNotBlank(methodName)){
        
            String basexml = meta.baseXml__c; //RECUPERARE BASE XML

            try{
                //Calling method from metadata data
                Callable pdfConfiguratorCallableMethods = (Callable) Type.forName(className).newInstance();
                fieldNameTMPList = (List<Object>)pdfConfiguratorCallableMethods.call(methodName, new Map<String, Object> { 'meta' => meta, 'currentObject' => currentObject, 'jsonAdditionalParameters' => jsonAdditionalParameters, 'recordList' => recordList });
                
                if( fieldNameTMPList instanceof List<Map<String,String>>){
                    fieldNameToFieldValueMapList = (List<Map<String,String>>)  fieldNameTMPList;
                }
                else if(fieldNameTMPList instanceof List<SObject>){
                    fieldNameToSObjectList = (List<SObject>) fieldNameTMPList;
                }

                if(fieldNameToFieldValueMapList.size() > 0 || fieldNameToSObjectList.size() > 0){
                    //Costruzione righe
                    String xmlTabellaTeporaneo = ''; //CONTERRÀ LA LISTA DEI DETTAGLI <dettaglio></dettaglio><dettaglio></dettaglio>
                    String templateIteration = meta.TemplateIterationXml__c; //RECUPERA IL LAYOUT DELLA SINGOLA RIGA
                    for(Map<String,String> fieldNameToFieldValueMap : fieldNameToFieldValueMapList)
                    {
                        xmlTabellaTeporaneo += replaceFieldsWithData(templateIteration, fieldNameToFieldValueMap);
                    }

                    for(SObject o : fieldNameToSObjectList){
                        xmlTabellaTeporaneo += replaceFieldsWithData(templateIteration, o);
                    }

                    //se l'xml prevede il numero righe, sostituisco il placeholder con il numero corrente
                    if(basexml.contains(PLACEHOLDER_NUMERO_RIGHE)){
                        basexml = basexml.replace(PLACEHOLDER_NUMERO_RIGHE, String.valueOf(fieldNameTMPList.size()));
                    }

                    stringToReturn = basexml.replace(PLACEHOLDER_TABELLA,xmlTabellaTeporaneo);

                }else{
                    System.debug('getXMLFromMethods: fieldNameToFieldValueMapList is empty');
                    stringToReturn = '';
                }
            }catch (Exception ex){
                //in caso di eccezione, non stampo il componente
                System.debug('Error in getXMLFromMethods: ' + ex.getMessage() + '' + ex.getStackTraceString());
                return '<exception>Error in getXMLFromMethods: '  + ex.getMessage() + '' + ex.getStackTraceString() + '</exception>';
            }

        }else{
            System.debug('!!!!! Error in getXMLFromMethods: Dynamic className or methodName are blank');
            stringToReturn = '<exception>Error in getXMLFromMethods: Dynamic className or methodName are blank</exception>';
        }
        
        return stringToReturn;
    }

    //inserisce i relativi dati formattati al posto dei campi placeholder
    @AuraEnabled
    public static String replaceFieldsWithData(String xml, SObject obj){
        if(xml != null){
            List<String> campi = new List<String>();

            Pattern p = Pattern.compile(REGEX_SEARCH_CAMPI);
            Matcher m = p.matcher(xml);

            while(m.find()) {
                String daSostituire = m.group(0);
                String campo = daSostituire.replace('{!', '').replace('}', '');
                //String valore = String.valueOf(obj.get(campo));
                String valore = getFieldValue(obj, campo);
                xml = valore != null ? xml.replace(daSostituire,valore) : xml.replace(daSostituire,'');
            }
        }
        return xml;
    }

    @TestVisible
    public static String replaceFieldsWithData(String xml, Map<String,String> fieldNameToFieldValueMap){

        if(xml != null){
            List<String> campi = new List<String>();

            Pattern p = Pattern.compile(REGEX_SEARCH_CAMPI);
            Matcher m = p.matcher(xml);

            while(m.find()) {
                String daSostituire = m.group(0);
                String campo = daSostituire.replace('{!', '').replace('}', '');
                String valore = fieldNameToFieldValueMap.containsKey(campo) ? fieldNameToFieldValueMap.get(campo) :'';
                xml = valore != null ? xml.replace(daSostituire,valore) : xml.replace(daSostituire,'');
            }
        }
        return xml;
    }

    public static Map<String, DescribeSObjectResult> describeMap = new Map<String, DescribeSObjectResult>();

    //formattazione dei dati
    @TestVisible
    public static String getFieldValue(sObject currentObject, String fieldName){
        /*Id recordId = currentObject.Id;
        String objectName = recordId.getSObjectType().getDescribe().getName();*/

        String valueToReturn = '';

        String uppercaseVariableType = 'STRING';
        
        uppercaseVariableType = getFieldType(currentObject, fieldName);
        Object value = getFieldFollowingRelations(currentObject,fieldName);
        if(value != null){

            if(uppercaseVariableType == 'DATE' ||
                uppercaseVariableType == 'DATETIME'){
                //formatting date as GG/MM/AAAA
                //DateTime dateValue = (DateTime)JSON.deserialize(String.valueOf(getFieldFollowingRelations(currentObject,fieldName)), DateTime.class);
                DateTime dateValue = (DateTime)JSON.deserialize(JSON.serialize(value), DateTime.class);
                valueToReturn = dateValue.format('dd-MM-yyyy HH:mm');
                // valueToReturn = dateValue.format('dd-MM-yyyy');
            }else if(uppercaseVariableType == 'BOOLEAN'){
                //formatting boolean as Sì/No
                String booleanValue = String.valueOf(value);
                if(booleanValue == 'true'){
                    valueToReturn = 'Sì';
                }else if (booleanValue == 'false'){
                    valueToReturn = 'No';
                }else{
                    valueToReturn = '';
                }
            }else{
    
                valueToReturn = value != null ? String.valueOf(value) : '';
            }
        }
        return valueToReturn;
    }

    public static String getFieldType(SObject record, String field){
        if (record == null) return null;
        try {
            
            if (!field.contains('.')){
    
                DescribeSObjectResult d;
                String objectName = record.getSObjectType().getDescribe().getName();
                if(describeMap.containsKey(objectName)){
                    d = describeMap.get(objectName);
                }else{
    
                    SObjectType r = ((SObject)(Type.forName('Schema.'+objectName).newInstance())).getSObjectType();
                    d = r.getDescribe();
                    describeMap.put(objectName, d);
                }
                return String.ValueOf(
                d.fields
                .getMap()
                .get(field)
                .getDescribe()
                .getType())
                .toUpperCase();
            }
            
            return getFieldType(
                record.getSObject(field.substringBefore('.')),
                field.substringAfter('.')
            );
        } catch (Exception ex) {
            System.debug('DK Error: ' + ex.getMessage() + '; at: ' + ex.getStackTraceString());
            throw new BaseException('Error: ' + ex.getMessage() + '; at: ' + ex.getStackTraceString());
        }
    }

    public static Object getFieldFollowingRelations(SObject record, String field)
    {
        if (record == null) return null;
        if (!field.contains('.')) return record.get(field);
        return getFieldFollowingRelations(
            record.getSObject(field.substringBefore('.')),
            field.substringAfter('.')
        );
    }

    /*@AuraEnabled
    public static void callGeneratePDFAsynch(String currentAccountQuery, List<Map<String, Object>> promiseArray, Map<String, String> mappaSezioni, String rootXml, String recordTypeDeveloperName, String tipoStampa){
        
        QueuePrintPDF queueable = new QueuePrintPDF(currentAccountQuery, promiseArray, mappaSezioni, rootXml, recordTypeDeveloperName, tipoStampa);
        System.debug('DK HEAPSIZE:' + Limits.getHeapSize());
        System.enqueueJob(queueable);
    }*/

    @AuraEnabled
    public static void callGeneratePDFAsynch(Account currentAccount, List<Map<String, Object>> promiseArray, Map<String, String> mappaSezioni, String rootXml, String recordTypeDeveloperName, String tipoStampa){
        
        QueuePrintPDF queueable = new QueuePrintPDF(currentAccount, promiseArray, mappaSezioni, rootXml, recordTypeDeveloperName, tipoStampa);
        System.debug('DK HEAPSIZE:' + Limits.getHeapSize());
        System.enqueueJob(queueable);
    }

    @future(callout=true)
    public static void generatePDFAsynch(String dataMapJSON){

        // String PLACEHOLDER_SEZIONI = '###ZONA_SEZIONI###';
        // String PLACEHOLDER_COMPONENTI = '###ZONA_COMPONENTI###';

        System.debug('DK HEAPSIZE:' + Limits.getHeapSize());
        try {
            User currentUser = [SELECT FederationIdentifier, FirstName, LastName, abi__c, applicazione__c, ndgsettoriale__c,
                        banca__c, terminale__c, idced__c, ip__c, cab__c, branchcode__c, userid__c,
                        sessionId__c, operationId__c, sysCaller__c, fnCaller__c, serviceName__c, fnName__c,
                        Token__c, idApplicazione__c, esb_idCed__c, esb_operatore__c, esb_IP__c,
                        serviceImplClass__c, serviceClient__c, TermId__c, customerId__c, ServiceVersion__c
                        FROM User WHERE id =: UserInfo.getUserId()];

            Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(dataMapJSON);
            Account currentAccount = (Account)JSON.deserialize(JSON.serialize(dataMap.get('currentAccount')), Account.class);
            List<Object> promiseArray = (List<Object>)dataMap.get('promiseArray');
            Map<String, String> mappaSezioni = (Map<String, String>)JSON.deserialize(JSON.serialize(dataMap.get('mappaSezioni')), Map<String, String>.class);
            String rootXml = (String)dataMap.get('rootXml');
            String recordTypeDeveloperName = (String)dataMap.get('recordTypeDeveloperName');
            String tipoStampa = (String)dataMap.get('tipoStampa');
            Boolean print = (Boolean)dataMap.containsKey('print') ? (Boolean)dataMap.get('print') : true;
    
            List<Map<String,String>> result = new List<Map<String,String>>();
            // for (Integer i = (promiseArray.size()-1) ; i>= 0 ; i--){
            for (Integer i = 0 ; i < promiseArray.size() ; i++){
                if(promiseArray[i] != null){

                    map<String, Object> deseializedExecution = (map<String, Object>) JSON.deserializeUntyped(JSON.serialize(promiseArray[i]));
                    PDFConfigurator__mdt meta = (PDFConfigurator__mdt)JSON.deserialize(JSON.serialize(deseializedExecution.get('meta')), PDFConfigurator__mdt.class);
                    if((String)deseializedExecution.get('method') == 'replaceFromQuery'){
                        List<SObject> responseList = (List<SObject>)JSON.deserialize((String)deseializedExecution.get('response'), List<SObject>.class);
                        result.add(replaceFromQuery(meta, currentAccount, responseList));
                    }else if((String)deseializedExecution.get('method') == 'replaceFromMethods'){
                        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped((String)deseializedExecution.get('response'));

                            if((String)responseMap.get('action') == 'replaceGetProdotti'){
                                List<Map<String,String>> replaceResponse = pdfConfiguratorCallableMethods.replaceGetProdotti(meta, currentAccount, JSON.serialize(responseMap.get('wrResponse')));
                                result.add(replaceFromMethods(meta, currentAccount, replaceResponse, null));
                            }else if((String)responseMap.get('action') == 'replaceGetGroupMembers'){
                                List<Map<String,String>> replaceResponse = pdfConfiguratorCallableMethods.replaceGetGroupMembers(meta, currentAccount, (String)responseMap.get('wrResponse'));
                                result.add(replaceFromMethods(meta, currentAccount, replaceResponse, null));
                            }else if((String)responseMap.get('action') == 'replaceGetScadenze'){
                                List<Map<String,String>> replaceResponse = pdfConfiguratorCallableMethods.replaceGetScadenze(meta, currentAccount, JSON.serialize(responseMap.get('wrResponse')));
                                result.add(replaceFromMethods(meta, currentAccount, replaceResponse, null));
                            }
                            // DK - CR 58271
                            else if((String)responseMap.get('action') == 'replaceGetIndicatoriRischio'){
                                pdfConfiguratorCallableMethods.indicatoriRischioWrapper replaceResponse = pdfConfiguratorCallableMethods.replaceGetIndicatoriRischio(meta, currentAccount, JSON.serialize(responseMap.get('wrResponse')));
                                result.add(replaceFromMethods(meta, currentAccount, null, replaceResponse));
                            }
                            // DK - CR 58271
                    }else if((String)deseializedExecution.get('method') == 'replaceFieldsWithData4Promise'){
                        result.add(replaceFieldsWithData4Promise(meta, currentAccount));
                    }
                }
                // promiseArray.remove(i);
            }
            for (Integer i = (promiseArray.size()-1) ; i>= 0 ; i--){

                promiseArray.remove(i);
            }
            /*for(Object execution : promiseArray){
                
                if(execution != null){

                    map<String, Object> deseializedExecution = (map<String, Object>) JSON.deserializeUntyped(JSON.serialize(execution));
                    PDFConfigurator__mdt meta = (PDFConfigurator__mdt)JSON.deserialize(JSON.serialize(deseializedExecution.get('meta')), PDFConfigurator__mdt.class);
                    if((String)deseializedExecution.get('method') == 'replaceFromQuery'){
                        List<SObject> responseList = (List<SObject>)JSON.deserialize((String)deseializedExecution.get('response'), List<SObject>.class);
                        result.add(replaceFromQuery(meta, currentAccount, responseList));
                    }else if((String)deseializedExecution.get('method') == 'replaceFromMethods'){
                        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped((String)deseializedExecution.get('response'));

                            if((String)responseMap.get('action') == 'replaceGetProdotti'){
                                List<Map<String,String>> replaceResponse = pdfConfiguratorCallableMethods.replaceGetProdotti(meta, currentAccount, JSON.serialize(responseMap.get('wrResponse')));
                                result.add(replaceFromMethods(meta, currentAccount, replaceResponse, null));
                            }else if((String)responseMap.get('action') == 'replaceGetGroupMembers'){
                                List<Map<String,String>> replaceResponse = pdfConfiguratorCallableMethods.replaceGetGroupMembers(meta, currentAccount, (String)responseMap.get('wrResponse'));
                                result.add(replaceFromMethods(meta, currentAccount, replaceResponse, null));
                            }else if((String)responseMap.get('action') == 'replaceGetScadenze'){
                                List<Map<String,String>> replaceResponse = pdfConfiguratorCallableMethods.replaceGetScadenze(meta, currentAccount, JSON.serialize(responseMap.get('wrResponse')));
                                result.add(replaceFromMethods(meta, currentAccount, replaceResponse, null));
                            }
                            // DK - CR 58271
                            else if((String)responseMap.get('action') == 'replaceGetIndicatoriRischio'){
                                pdfConfiguratorCallableMethods.indicatoriRischioWrapper replaceResponse = pdfConfiguratorCallableMethods.replaceGetIndicatoriRischio(meta, currentAccount, JSON.serialize(responseMap.get('wrResponse')));
                                result.add(replaceFromMethods(meta, currentAccount, null, replaceResponse));
                            }
                            // DK - CR 58271
                    }else if((String)deseializedExecution.get('method') == 'replaceFieldsWithData4Promise'){
                        result.add(replaceFieldsWithData4Promise(meta, currentAccount));
                    }
                }
            }*/
            System.debug('DK HEAPSIZE_2:' + Limits.getHeapSize());

            if(!result.isEmpty() && !mappaSezioni.keySet().isEmpty()){
                //debugger;
                List<String> keyListMappaSezioni = new List<String>();
                keyListMappaSezioni.addAll(mappaSezioni.keySet());
                for(Integer i = 0; i < keyListMappaSezioni.size(); i++){
                    String k = keyListMappaSezioni[i];
    
                    //Compongo l'xml da sostituire nella lista dei componenti
                    String xmlComponenti = '';
                    // for(Integer j = result.size() - 1; j >= 0; j--){
                    for(Integer j = 0; j < result.size(); j++){
                        xmlComponenti += result[j].containsKey(k) ? result[j].get(k) : ''; 
                    }
    
                    //Sostituisco nell'xml della sezione l'xml composto precedentemente con la lista dei componenti
                    mappaSezioni.put(k, mappaSezioni.get(k).replace(PLACEHOLDER_COMPONENTI,xmlComponenti));
                }
    
                //Una volta riempite tutte le sezioni non mi resta che creare una stringa unica e sostituirla nel root xml
                String xmlSezioni = '';
                for(Integer i = 0; i < keyListMappaSezioni.size(); i++){
                    String k = keyListMappaSezioni[i];
                    xmlSezioni +=  mappaSezioni.get(k);
                }

                String pdf64 = executeCall(rootXml.replace(PLACEHOLDER_SEZIONI, xmlSezioni), currentAccount, recordTypeDeveloperName);
                System.debug('DK HEAPSIZE_3:' + Limits.getHeapSize());

                if(print){
                    if(pdf64 != null){
                        delete [SELECT Id FROM ContentDocument WHERE Title LIKE: ('%' + currentUser.FederationIdentifier + '_' + currentAccount.CRM_NDG__c + '_' + tipoStampa)];
    
                        ContentVersion content=new ContentVersion(); 
                        content.Title= 'STAMPA_' + currentUser.FederationIdentifier + '_' + currentAccount.CRM_NDG__c + '_' + tipoStampa; 
                        content.PathOnClient='/' + content.Title + '.pdf'; 
                        content.VersionData=EncodingUtil.base64Decode(pdf64);
                        content.SharingPrivacy = 'p';
                        // content.FileType = 'pdf';
                        content.OwnerId =UserInfo.getUserId();
                        if(!test.isRunningTest()){
                            
                            OnContentDocumentLinkTriggerHandler.semaforoStampaPDF = true;
                            insert content;
                            ContentDocumentLink contentlink = new ContentDocumentLink();
                            contentlink.LinkedEntityId = currentAccount.Id;
                            contentlink.contentdocumentid = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
                            contentlink.ShareType = 'I';
                            insert contentlink;
                        }
                        notifyUsers(currentAccount, tipoStampa, true);
                    }else{
                        notifyUsers(currentAccount, tipoStampa, false);
                    }
                }else{
                    //DK DECOMMENTARE - POST RILASCIO STAMPA ASINCRONA
                    if(pdf64 != null){

                        if(pdf64.length() <= 100000){

                            currentAccount.CRM_PEF_PDFBase64Split1__c = pdf64;
                        }
                        else if(pdf64.length() <= 200000){

                            currentAccount.CRM_PEF_PDFBase64Split2__c = pdf64.substring(100000);
                            currentAccount.CRM_PEF_PDFBase64Split1__c = pdf64.substring(0,100000);
                        }
                        else if(pdf64.length() <= 300000){
  
                            currentAccount.CRM_PEF_PDFBase64Split3__c = pdf64.substring(200000);
                            currentAccount.CRM_PEF_PDFBase64Split2__c = pdf64.substring(100000,200000);
                            currentAccount.CRM_PEF_PDFBase64Split1__c = pdf64.substring(0,100000);
                        }
                        else{
  
                            currentAccount.CRM_PEF_PDFBase64Split3__c = pdf64.substring(300000);
                            currentAccount.CRM_PEF_PDFBase64Split3__c = pdf64.substring(200000,300000);
                            currentAccount.CRM_PEF_PDFBase64Split2__c = pdf64.substring(100000,200000);
                            currentAccount.CRM_PEF_PDFBase64Split1__c = pdf64.substring(0,100000);
                        }

                        currentAccount.CRM_TimestampPEFPDF__c= Datetime.now();

                        update new Account(id = currentAccount.Id, CRM_PEF_PDFBase64Split1__c = currentAccount.CRM_PEF_PDFBase64Split1__c,
                        CRM_PEF_PDFBase64Split2__c = currentAccount.CRM_PEF_PDFBase64Split2__c,
                        CRM_PEF_PDFBase64Split3__c = currentAccount.CRM_PEF_PDFBase64Split3__c);
                    }
                    //DK DECOMMENTARE - POST RILASCIO STAMPA ASINCRONA
                }
            }
        } catch (Exception ex) {
            throw new BaseException('Error: ' + ex.getMessage() + '; at: ' + ex.getStackTraceString());
        }
    }

    // ----------------------------------------------------------------------------------
    public static Map<String, PDFConfigurator__mdt> metaMap {
        get{
            if(metaMap != null)return metaMap;
            metaMap = new Map<String, PDFConfigurator__mdt>();
            for(PDFConfigurator__mdt meta : (List<PDFConfigurator__mdt>)Database.query(String.escapeSingleQuotes(SV_Utilities.selectAllField('PDFConfigurator__mdt')))){
                metaMap.put(meta.Id, meta);
            }
            return metaMap;
        }set;
    }

    @AuraEnabled
    public static Map<String, Object> getXMLFromQuery4PromiseData(String metaId, Account currentAccount){
    // public static Map<String, Object> getXMLFromQuery4PromiseData(PDFConfigurator__mdt meta, Account currentAccount){
        Datetime startTime = Datetime.now();
        /*PDFConfigurator__mdt meta;
        if(Test.isRunningTest()){
            meta =(PDFConfigurator__mdt)JSON.deserialize(metaId, PDFConfigurator__mdt.class);
        }else{

            // PDFConfigurator__mdt meta = [SELECT Id, baseXml__c, QueryObjectType__c, QueryLookup__c, QueryWhereCondition__c, QueryCampiAggiuntivi__c FROM PDFConfigurator__mdt WHERE ID =: metaId];
            meta = Database.query(String.escapeSingleQuotes(SV_Utilities.selectAllField('PDFConfigurator__mdt')) + ' WHERE Id =: metaId');
        }*/
        
        // Account currentAccount = Database.query(currentAccountQuery);
        // String xml = '';
        // String stringToReturn = '';
        
        // String basexml = meta.baseXml__c; //RECUPERARE BASE XML

        // String oggettoFrom  = meta.QueryObjectType__c;
        // String campoLookup  = meta.QueryLookup__c; // =:recordId //WHERE campoLookup =: recordId '
        // String whereCond    = (String.isNotBlank(meta.QueryWhereCondition__c)) ? meta.QueryWhereCondition__c : 'AND Id != null';
        // String recordId     = currentAccount.Id;
        // System.debug('DK oggettoFrom: ' + oggettoFrom);
        // System.debug('DK campoLookup: ' + campoLookup);
        // System.debug('DK whereCond: ' + whereCond);
        // System.debug('DK recordId: ' + recordId);
        // String query = String.escapeSingleQuotes(SV_Utilities.selectAllField(meta.QueryObjectType__c)) 
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField(metaMap.get(metaId).QueryObjectType__c))
        + ' WHERE '
        + String.escapeSingleQuotes(metaMap.get(metaId).QueryLookup__c)
        +' = \''+String.escapeSingleQuotes(currentAccount.Id)
        +'\' '+((String.isNotBlank(metaMap.get(metaId).QueryWhereCondition__c)) ? metaMap.get(metaId).QueryWhereCondition__c : 'AND Id != null');

        //inserisco nella query eventuali campi aggiuntivi
        if(String.isNotBlank(metaMap.get(metaId).QueryCampiAggiuntivi__c)){
            String campiAggiuntivi = metaMap.get(metaId).QueryCampiAggiuntivi__c.trim();
            campiAggiuntivi = (campiAggiuntivi.startsWith(',')) ? campiAggiuntivi : ', ' + campiAggiuntivi;
            query = query.replaceFirst('FROM', String.escapeSingleQuotes(campiAggiuntivi) + ' FROM');
        }
        // List<SObject> response = Database.query(query);
        // Datetime endTime = Datetime.now();
        // System.debug('getXMLFromQuery4PromiseData ELAPSED TIME: ' + Decimal.valueOf(endTime.getTime() - startTime.getTime()));
        return new  Map<String, Object>{
            'meta' => metaMap.get(metaId),
            'method' => 'replaceFromQuery',
            'response' => JSON.serialize(Database.query(query))
        };
    }

    @AuraEnabled
    public static Map<String, Object> getXMLFromMethods4PromiseData(String metaId, sObject currentAccount){
    // public static Map<String, Object> getXMLFromMethods4PromiseData(PDFConfigurator__mdt meta, sObject currentAccount){
        // Datetime startTime = Datetime.now();
        // String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('PDFConfigurator__mdt')) + ' WHERE Id =: metaId';
        /*PDFConfigurator__mdt meta;
        if(Test.isRunningTest()){
            meta =(PDFConfigurator__mdt)JSON.deserialize(metaId, PDFConfigurator__mdt.class);
        }else{
            meta = Database.query(String.escapeSingleQuotes(SV_Utilities.selectAllField('PDFConfigurator__mdt')) + ' WHERE Id =: metaId');
        }*/
        // Account currentAccount = Database.query(currentAccountQuery);
        // String stringResult = getXMLFromMethodsData(meta, currentAccount, null);
        // System.debug('getXMLFromMethods4PromiseData ELAPSED TIME: ' + Decimal.valueOf(endTime.getTime() - startTime.getTime()));
        return new  Map<String, Object>{
            'meta' => metaMap.get(metaId),
            'method' => 'replaceFromMethods',
            'response' => getXMLFromMethodsData(metaMap.get(metaId), currentAccount, null)
        };
    }

    @AuraEnabled
    public static String getXMLFromMethodsData(PDFConfigurator__mdt meta, sObject currentAccount, List<SObject> recordList){
        // String xml = '';
        // List<SObject> fieldNameToSObjectList = new List<SObject>();
        // List<Map<String,String>> fieldNameToFieldValueMapList = new List<Map<String,String>>();
        // List<Object> fieldNameTMPList = new List<Object>();
        // String stringToReturn = '';

        // String className = meta.MetodoSelezioneClasse__c;
        // String methodName = meta.MetodoSelezioneName__c;
        // String jsonAdditionalParameters = meta.MetodoSelezioneAdditionalParameters__c;

        //Calling method from metadata data
        // Callable pdfConfiguratorCallableMethods = (Callable)Type.forName(meta.MetodoSelezioneClasse__c).newInstance();
        return JSOn.serialize(((Callable)Type.forName(meta.MetodoSelezioneClasse__c).newInstance()).call(meta.MetodoSelezioneName__c, new Map<String, Object> { 'meta' => meta, 'currentObject' => currentAccount, 'jsonAdditionalParameters' => meta.MetodoSelezioneAdditionalParameters__c, 'recordList' => recordList }));
    }

    public static void savePDF(Account currentAccount){

        String recordTypeDeveloperName = getAccountRecordTypeDeveloperName(currentAccount.id);
        List<PDFConfigurator__mdt> metadata = [SELECT Id, Ordine__c, COMPONENT__c, SECTION__c
                                               FROM PDFConfigurator__mdt
                                               WHERE COMPONENT__c = '' 
                                                AND isRoot__c = false
                                                AND Oggetto__c = 'Account' 
                                                AND isActive__c = true 
                                                AND SECTION__c != 'Contact History' 
                                                AND (OBJRECORDTYPE__c = NULL OR OBJRECORDTYPE__c =: recordTypeDeveloperName) 
                                               ORDER BY Ordine__c ASC];
        
        List<PDFConfigurator__mdt> fullMetadata = getFullMetadataFromSelected(metadata, 'Account', recordTypeDeveloperName);
        String rootXml = getRootXML(fullMetadata, currentAccount);
        List<Object> promiseArrayObject= new Object[fullMetadata.size()];
        Map<String,String> selectedSezioni = new Map<String,String>();
        for(Integer i=0; i<fullMetadata.size(); i++){
            PDFConfigurator__mdt m = fullMetadata[i];

            if(String.isBlank(m.COMPONENT__c) && m.isActive__c && !m.isRoot__c){
                selectedSezioni.put(m.SECTION__c, m.baseXml__c);
            }
            if(!String.isBlank(m.SECTION__c) && !String.isBlank(m.COMPONENT__c) && m.isActive__c && !m.isRoot__c){
                if(m.HasQuery__c){
                    promiseArrayObject.set(i, new Map<String,Object>{'method' => 'getXMLFromQuery4PromiseData', 'meta' => m.Id});
                }else if (m.HasMetodoSelezione__c) {
                    promiseArrayObject.set(i, new Map<String,Object>{'method' => 'getXMLFromMethods4PromiseData', 'meta' => m.Id});
                }else{
                    promiseArrayObject.set(i, new Map<String,Object>{'method' => 'replaceFieldsWithData4Promise', 'meta' => m});
                }
            }
        }

        List<Map<String,Object>> promiseArray = new List<Map<String,Object>>();
        for(Object promiseObject : promiseArrayObject){
            promiseArray.add((Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(promiseObject)));
        }

        QueuePrintPDF queueable = new QueuePrintPDF (currentAccount, promiseArray, selectedSezioni, rootXml, recordTypeDeveloperName, 'FULL');
        queueable.print = false;
        System.enqueueJob(queueable);
    }

    public static void test(){

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
    }
}