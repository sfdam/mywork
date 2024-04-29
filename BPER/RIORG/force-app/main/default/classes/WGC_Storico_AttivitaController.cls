public class WGC_Storico_AttivitaController {

    

    @AuraEnabled
    public static User getUserInfo() {
        return SV_Utilities.getUserInfo();
        
    }

    @AuraEnabled
    public static Object initStampa(String recordId){

        String recordTypeDeveloperName = PrintPDFController.getAccountRecordTypeDeveloperName(recordId);
        String rootCampiAggiuntivi = PrintPDFController.getRootCampiAggiuntivi('Account', recordTypeDeveloperName);
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField('Account')) + ' WHERE id =: recordId';
        if(String.isNotBlank(rootCampiAggiuntivi)){
            rootCampiAggiuntivi = (rootCampiAggiuntivi.startsWith(',')) ? rootCampiAggiuntivi : ', ' + rootCampiAggiuntivi;
            query = query.replaceFirst('FROM', String.escapeSingleQuotes(rootCampiAggiuntivi) + ' FROM');
        }
        Account account = Database.query(query);

        return new Map<String, Object>{
        'metadatiStampa' =>[SELECT 
            Id, Ordine__c, COMPONENT__c,SECTION__c 
        FROM PDFConfigurator__mdt 
        WHERE   COMPONENT__c = '' 
            AND isRoot__c = false 
            AND Oggetto__c = 'Account'
            AND isActive__c = true
            AND SECTION__c = 'Contact History'
            ORDER BY Ordine__c ASC],
        'accountData' => account,
        'recordTypeDeveloperName' => recordTypeDeveloperName
        };
    }

    @AuraEnabled
    public static String executeCall(String xml, Account currentAccount, String recordTypeDeveloperName){
        return PrintPDFController.executeCall(xml, currentAccount, recordTypeDeveloperName);
    }

    @AuraEnabled
    public static String getRootXML(List<PDFConfigurator__mdt> selectedSections, Account currentAccount){
        return PrintPDFController.getRootXML(selectedSections, currentAccount);
    }

    @AuraEnabled
    public static List<PDFConfigurator__mdt> getFullMetadataFromSelected(List<PDFConfigurator__mdt> selectedSections, String obj, String recordTypeDeveloperName){
        return PrintPDFController.getFullMetadataFromSelected(selectedSections, obj, recordTypeDeveloperName);
    }

    @AuraEnabled
    public static Map<String,String> getXMLFromQuery4Promise(PDFConfigurator__mdt meta, Account currentAccount){
        return PrintPDFController.getXMLFromQuery4Promise(meta, currentAccount);
    }
    

    @AuraEnabled
    public static Map<String,String> getXMLFromMethods4Promise(PDFConfigurator__mdt meta, sObject currentObject, List<SObject> recordList, Map<String, String> recordObjectTypeMap){
        String stringResult = getXMLFromMethods(meta, currentObject, recordList, recordObjectTypeMap);
        Map<String,String> res = new Map<String,String>();
        res.put(meta.SECTION__c, stringResult);
        return res;
    }

    @AuraEnabled
    public static String getXMLFromMethods(PDFConfigurator__mdt meta, sObject currentObject, List<SObject> recordList, Map<String, String> recordObjectTypeMap){
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
                fieldNameTMPList = (List<Object>)pdfConfiguratorCallableMethods.call(methodName, new Map<String, Object> { 'meta' => meta, 'currentObject' => currentObject, 'jsonAdditionalParameters' => jsonAdditionalParameters, 'recordList' => recordList, 'recordObjectTypeMap' =>  recordObjectTypeMap});
                
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
                        xmlTabellaTeporaneo += PrintPDFController.replaceFieldsWithData(templateIteration, fieldNameToFieldValueMap);
                    }

                    for(SObject o : fieldNameToSObjectList){
                        xmlTabellaTeporaneo += PrintPDFController.replaceFieldsWithData(templateIteration, o);
                    }

                    //se l'xml prevede il numero righe, sostituisco il placeholder con il numero corrente
                    if(basexml.contains(PrintPDFController.PLACEHOLDER_NUMERO_RIGHE)){
                        basexml = basexml.replace(PrintPDFController.PLACEHOLDER_NUMERO_RIGHE, String.valueOf(fieldNameTMPList.size()));
                    }

                    System.debug('DK xmlTabellaTeporaneo: ' + xmlTabellaTeporaneo);
                    stringToReturn = basexml.replace(PrintPDFController.PLACEHOLDER_TABELLA,xmlTabellaTeporaneo);
                    System.debug('DK stringToReturn START: ' + stringToReturn);

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
        System.debug('DK stringToReturn END: ' + stringToReturn);
        return stringToReturn;
    }

    @AuraEnabled
    public static Map<String,String> replaceFieldsWithData4Promise(PDFConfigurator__mdt meta, Account currentAccount){
        return PrintPDFController.replaceFieldsWithData4Promise(meta, currentAccount);
    } 

    
    @AuraEnabled
    public static WrapperResponse getAllData(String accId, String objType, String objRecordType, String referentProfile) {
                System.debug('SV accId: ' + accId);
                System.debug('SV objType: ' + objType);
                System.debug('SV objRecordType: ' + objRecordType);
                System.debug('SV referentProfile: ' + referentProfile);

        WrapperResponse result = new WrapperResponse();
        List<SObject> slist = new List<SObject>();

        // SULLA BASE DI OBJTYPE RECURO DA METADATO GLI ELEMENTI.
        List<WGC_Storico_Attivita__mdt> ObjMetadataList= [SELECT CAMPO_FILTRO_DATA__c, LOOK_UP_TO_RECORD__c,OBJECT_TYPE__c, TIMING_DI_VISUALIZZAZIONE__c,
                                                CHECK_CAMPO_ESITO__c,CAMPO_ESITO__c, FIELD_AGGIUNTIVI__c, FIELD_FORICON__c, OBJECT_SUPPORT__c,
                                                FIELDS_TO_SPLIT__c, CHECK_RECORD_SPLIT__c, CHECK_TRACKING_HISTORY__c,SOQL_WHERE_CONDITION__c,
                                                CHECK_COINTESTAZIONI__c, CAMPO_TRACKING_HISTORY__c
                                                            FROM WGC_Storico_Attivita__mdt 
                                                            WHERE OBJECT_TYPE__c=:objType]; 

        if(ObjMetadataList.size() <= 0){
            return result;
        }
        
        WGC_Storico_Attivita__mdt ObjMetadata = ObjMetadataList[0];                              
        System.debug('Query metadata: '+ObjMetadata);

        //Setto le variabili di ricerca del metadato
        String field_lookup = ObjMetadata.LOOK_UP_TO_RECORD__c;
        String timing_view = ObjMetadata.TIMING_DI_VISUALIZZAZIONE__c; 
        String data_filter = ObjMetadata.CAMPO_FILTRO_DATA__c; 
        String additional_Filters = ObjMetadata.SOQL_WHERE_CONDITION__c; 
        Boolean check_campo_esito = ObjMetadata.CHECK_CAMPO_ESITO__c; 
        String campo_esito = ObjMetadata.CAMPO_ESITO__c; 
        Boolean check_record_split = ObjMetadata.CHECK_RECORD_SPLIT__c; 
        List<String> campi_split = (ObjMetadata.FIELDS_TO_SPLIT__c != NULL) ? ObjMetadata.FIELDS_TO_SPLIT__c.split(',') : new List<String>(); 
        Boolean check_trackingHistory = ObjMetadata.CHECK_TRACKING_HISTORY__c; 
        String campo_trackingHistory = ObjMetadata.CAMPO_TRACKING_HISTORY__c; 
        String objSupport = ObjMetadata.OBJECT_SUPPORT__c; 
        Boolean check_cointestazioni = ObjMetadata.CHECK_COINTESTAZIONI__c; 

        Integer yearLess = 0;
        Integer monthLess = 0;
        if(Decimal.valueOf(timing_view) >= 1){
            yearLess = Integer.valueOf(timing_view);
        } else {
            monthLess = (timing_view == '0.25') ? 3 : (timing_view == '0.5') ? 6 : 9;
        }

        Integer year;
        Integer month;
        //Definisco range temporale sullo storico anni  (Data di oggi - tot anni)
        date latestYears = date.today();
        Integer diff;
        if(Decimal.valueOf(timing_view) >= 1){

             year = latestYears.year() - yearLess;
             month = latestYears.month() - monthLess;
         } else 
         {
            if(latestYears.month() - monthLess <=0)
            {
                diff=latestYears.month() - monthLess;
                month=12+diff;
                year= latestYears.year()-1;
            }
            else{

                 year = latestYears.year() - yearLess;
                 month = latestYears.month() - monthLess;
            }
        }
        Integer numberOfDays = Date.daysInMonth(year, month);
        Integer day = latestYears.day() <= numberOfDays ? latestYears.day() : numberOfDays;
        String stringDate = year + '-' + month + '-' + day;
     
        latestYears = date.valueOf(stringDate);
        Date today= date.today();

        today = today.addDays(1);

                System.debug('SV today: ' + today);
                System.debug('SV latestYears: ' + latestYears);
        
        
        try{

            User userInfo = SV_Utilities.getUserInfo();
            Set<String> lookupList = new Set<String>();
            lookupList.add(accId);
            if(check_cointestazioni){
                List <CRM_AccountAccountJointOwnershipRelation__c> cointestazioniId = new List <CRM_AccountAccountJointOwnershipRelation__c>();
                System.debug('GB - referentProfile ' + referentProfile);
                String profileId = (String)userInfo.ProfileId;
                String profileIdSub = profileId.substring(0,15);
                System.debug('GB - profileId ' + profileIdSub );
                if(referentProfile.contains(profileIdSub)){
                    System.debug('GB - insideIf ' + lookupList);
                    cointestazioniId = [ SELECT CRM_JointOwnership__c
                    FROM CRM_AccountAccountJointOwnershipRelation__c 
                    WHERE CRM_Account__c =: accId AND CRM_JointOwnership__r.User_Is_Referente_Portafoglio__c = TRUE ];
                    System.debug('GB - insideIf coi ' + cointestazioniId );
                } else {
                    System.debug('GB - insideElse ' + lookupList);
                    cointestazioniId = [ SELECT CRM_JointOwnership__c
                                        FROM CRM_AccountAccountJointOwnershipRelation__c 
                                        WHERE CRM_Account__c =: accId ];
                    System.debug('GB - insideElse coi ' + cointestazioniId );
                }

                for(CRM_AccountAccountJointOwnershipRelation__c c : cointestazioniId){
                    lookupList.add(c.CRM_JointOwnership__c);
                }
                System.debug('GB - lookupList ' + lookupList);
            }
            //IN : financialAccIds

            String query = String.escapeSingleQuotes(SV_Utilities.selectAllField(objType));
            String queryConditionLookup = field_lookup +  ' IN : lookupList';
            String additionalFilterQuery = additional_Filters != null ? additional_Filters : '';
            String recordTypeQuery = !String.isBlank(objRecordType) ? 'RecordType.DeveloperName = \'' + String.escapeSingleQuotes(objRecordType) + '\' AND ' : '';
            String queryDataFilter = !String.isBlank(data_filter) ? String.escapeSingleQuotes(data_filter) +  ' >=:  latestYears   and ' + String.escapeSingleQuotes(data_filter) +  ' <=: today ' : '';

            if(objType == 'Task'){
                queryConditionLookup += ' AND TaskSubtype != \'Email\'';
            } 

            if(objType == 'NDGManagementMember__c'){
                queryConditionLookup += ' AND RecTypeDevName__c = \'Primario\'';
            }

            if(objType == 'FinServ__Alert__c'){
                queryDataFilter = ' ((' + String.escapeSingleQuotes(data_filter) +  ' >=:  latestYears AND ' + String.escapeSingleQuotes(data_filter) +  ' <=: today) OR (' + String.escapeSingleQuotes(data_filter) +  ' > : today AND ' + String.escapeSingleQuotes(campo_esito) + ' != NULL AND ' + String.escapeSingleQuotes(campo_esito) + ' != \'Da Contattare\')) ';
            }

            if(!check_record_split){
                query += ' WHERE ' + queryConditionLookup + ' and ' + recordTypeQuery + queryDataFilter + additionalFilterQuery + ' ORDER BY '+ data_filter + ' DESC' ;
                System.debug('SV getObjectInfos query: '+' WHERE ' + queryConditionLookup + ' and ' + recordTypeQuery + queryDataFilter + additionalFilterQuery + ' ORDER BY '+ data_filter + ' DESC' );  //Aggiungere filtri

                query = query.replace('FROM', (ObjMetadata.FIELD_AGGIUNTIVI__c == null || ObjMetadata.FIELD_AGGIUNTIVI__c == '') ? 'FROM' :  String.escapeSingleQuotes(ObjMetadata.FIELD_AGGIUNTIVI__c) + ' FROM');


                System.debug('SV slist Object Type: '+slist.getSObjectType());
                System.debug('SV slist SIZE: '+slist.size());

                slist = Database.query(query);

            } else {
                if(objType == 'FinServ__FinancialAccount__c'){
                    System.debug('GB - lookupList FA ' + lookupList);
                    String profileId = (String)userInfo.ProfileId;
                    String profileIdSub = profileId.substring(0,15);
                    System.debug('GB - profileId ' + profileIdSub );
                    List<FinServ__FinancialAccountRole__c> financialAccountList = new List<FinServ__FinancialAccountRole__c>();
                    if(referentProfile.contains(profileIdSub)) {
                        financialAccountList = [ SELECT FinServ__FinancialAccount__c
                                                FROM FinServ__FinancialAccountRole__c 
                                                WHERE FinServ__RelatedAccount__c IN : lookupList AND CRM_Flagdelegato__c=false AND (FinServ__FinancialAccount__r.FinServ__JointOwner__c = null OR (FinServ__FinancialAccount__r.FinServ__JointOwner__c != null AND FinServ__FinancialAccount__r.FinServ__JointOwner__r.User_Is_Referente_Portafoglio__c = TRUE)) ];
                    } else {
                   
                        financialAccountList = [ SELECT FinServ__FinancialAccount__c
                                                FROM FinServ__FinancialAccountRole__c 
                                                WHERE FinServ__RelatedAccount__c IN : lookupList AND CRM_Flagdelegato__c=false ];
                    }
                    System.debug('GB - FA Role ' + financialAccountList );
                    Set<Id> financialAccIds = new Set<Id>();
                    for (FinServ__FinancialAccountRole__c el : financialAccountList) {
                        financialAccIds.add(el.FinServ__FinancialAccount__c);
                    }
                    
                    queryConditionLookup = 'Id IN : financialAccIds AND FinServ__Status__c != \'OBSOLETO\'';
                } 

                System.debug('DK query: ' + query);
                System.debug('DK campi_split: ' + JSON.serialize(campi_split));
                for(String s : campi_split){
                    System.debug('DK s: ' + s);
                    List<SObject> partial_list = new List<SObject>();
                    String partial_query = query;
                    // #50302
                    // if(objType == 'CRM_Memo__c'){
                        // queryDataFilter = '(('+ s + '!= NULL AND '+ s +  ' >=:  latestYears AND ' + s +  ' <=: today) OR ' + s + '= NULL) ';
                    // } else {
                        queryDataFilter = String.escapeSingleQuotes(s) + '!= NULL AND '+ String.escapeSingleQuotes(s) +  ' >=:  latestYears   and ' + String.escapeSingleQuotes(s) +  ' <=: today ';
                    // }
                    partial_query += ' WHERE ' + String.escapeSingleQuotes(s) + ' != NULL AND ' + queryConditionLookup + ' and ' + recordTypeQuery + queryDataFilter + additionalFilterQuery + ' ORDER BY '+ String.escapeSingleQuotes(s) + ' DESC' ; 
                    System.debug('SV getObjectInfos query: '+' WHERE ' + s + ' != NULL AND ' + field_lookup +  ' = \'' + accId + '\' and ' +recordTypeQuery + queryDataFilter + additionalFilterQuery + ' ORDER BY '+ s + ' DESC' );  //Aggiungere filtri

                    partial_query = partial_query.replace('FROM', (ObjMetadata.FIELD_AGGIUNTIVI__c == null || ObjMetadata.FIELD_AGGIUNTIVI__c == '') ? 'FROM' :  String.escapeSingleQuotes(ObjMetadata.FIELD_AGGIUNTIVI__c) + ' FROM');
                    System.debug('DK partial_query: ' + partial_query);
                    partial_list = Database.query(partial_query);
                    
                    //valerio.salvati gestione record split
                    for(SObject so: partial_list){
                        so.put('Id', ((String)so.get('Id'))+'-'+ s );
                    }

                    slist.addAll(partial_list);
                }
            }

            List<SObject> tracking_list = new List<SObject>();
            if(check_trackingHistory){
                List<String> campi_HTSplit = campo_trackingHistory.split(','); 
                Set<Id> trackingIds = new Set<Id>();
                for (SObject el : slist) {
                    trackingIds.add((Id)el.get('Id'));
                }
                String queryTracking = String.escapeSingleQuotes(SV_Utilities.selectAllField('TrackingHistory__c'));
                queryTracking += ' WHERE ParentObject__c IN : trackingIds AND CreatedDate >=: latestYears AND CreatedDate <=: today ORDER BY CreatedDate ASC' ;
                System.debug('SV queryTracking: ' + queryTracking);
                queryTracking = queryTracking.replace('FROM', ',Createdby.Name FROM');

                tracking_list = Database.query(queryTracking);
            }

            List<SObject> objSupport_list = new List<SObject>();
            if(objSupport != null){
                String queryObjSupport = String.escapeSingleQuotes(SV_Utilities.selectAllField(objSupport));
                queryObjSupport += ' WHERE CRM_Account__c IN : lookupList' + ' AND CreatedDate >=: latestYears AND CreatedDate <=: today ORDER BY CreatedDate DESC' ;
                objSupport_list = Database.query(queryObjSupport);

            }

            result.data = slist;
            result.query = query;
            result.trackingData = tracking_list;
            result.supportData = objSupport_list;
            result.obj = objType; 
            result.metadato = ObjMetadata; 
            if(check_campo_esito){
                SObject sObj = (SObject) Type.forName(objType).newInstance();
                result.listFiltroEsito = WGC_Storico_AttivitaController.getselectOptions(sObj, campo_esito, objType);
            }
            System.debug('slist -> '+ slist);
            System.debug('query  -> '+ query);
            System.debug('tracking_list -> '+ tracking_list);
            System.debug('objSupport_list -> '+ objSupport_list);
            


            System.debug('query lookupList -> '+ lookupList);
            System.debug('query finale obj -> '+ query.substringBefore('WHERE'));
            System.debug('query finale -> '+ query.substringAfter('WHERE'));
        } catch(Exception e){
            System.debug('Errore '+e.getMessage());
            result.success = false; 
            result.msg = e.getMessage();
            result.stackTrace = e.getStackTraceString();
            return result;
        }
        System.debug('Result -> '+ result);
        return result;        
    }

    @AuraEnabled
    public static WrapperResponse filterDataFunction(String accId, String objType, Date dateFrom, Date dateTo) {

        // SULLA BASE DI OBJTYPE RECURO DA METADATO GLI ELEMENTI.
        WGC_Storico_Attivita__mdt ObjMetadata= [SELECT CAMPO_FILTRO_DATA__c, LOOK_UP_TO_RECORD__c,OBJECT_TYPE__c, TIMING_DI_VISUALIZZAZIONE__c, SOQL_WHERE_CONDITION__c
                                                            FROM WGC_Storico_Attivita__mdt
                                                            WHERE OBJECT_TYPE__c=:objType]; 

        System.debug('Query metadata: '+ObjMetadata);

        //Setto le variabili di ricerca del metadato
        String field_lookup = ObjMetadata.LOOK_UP_TO_RECORD__c;
        String additionalFilters = ObjMetadata.SOQL_WHERE_CONDITION__c;
        String queryConditions = String.isNotEmpty(additionalFilters) ? (field_lookup +  ' = \'' + String.escapeSingleQuotes(accId) + '\' ' + additionalFilters) : (String.escapeSingleQuotes(field_lookup) +  ' = \'' + String.escapeSingleQuotes(accId)  + '\' ');
        String timing_view = ObjMetadata.TIMING_DI_VISUALIZZAZIONE__c; 
        String data_filter = ObjMetadata.CAMPO_FILTRO_DATA__c; 
        String query = String.escapeSingleQuotes(SV_Utilities.selectAllField(objType));
        query += ' WHERE ' + queryConditions ;
        //query += ' WHERE ' + field_lookup +  ' = \'' + accId + '\' and ' + data_filter +  ' >=:  dateFrom   and ' + data_filter +  ' <=: dateTo' ; 
        if(!String.isBlank(data_filter)){
            
            query += ' and ' + String.escapeSingleQuotes(data_filter) +  ' >=:  dateFrom   and ' + String.escapeSingleQuotes(data_filter) +  ' <=: dateTo' ; 
        }

        WrapperResponse result = new WrapperResponse();
        
        try{

            List<SObject> slist = Database.query(query);

            System.debug('SV slist Object Type: '+slist.getSObjectType());
            System.debug('SV slist SIZE: '+slist.size());
            
            result.data = slist;
            result.obj = objType; 
            
        } catch(Exception e){
            System.debug('Errore '+e.getMessage());
            result.success = false; 
            result.msg = e.getMessage();
            result.stackTrace = e.getStackTraceString();
            return result;
        }
        System.debug('Result -> '+ result);
        return result;        
    }

    @AuraEnabled
    public static List<WrapperPickList> getselectOptions(sObject objObject, string fld, String obj) {
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
        // for (Schema.PicklistEntry a: values) {
        //     allOpts.put(a.getLabel(), a.getValue());
        // }
        // system.debug('allOpts ---->' + allOpts);

        List<WrapperPickList> x = new List<WrapperPickList>();
        for (Schema.PicklistEntry a: values) {
            if(a.isActive()){
                WrapperPickList y = new WrapperPickList();
                y.label = a.getLabel();
                y.value = a.getValue();
                y.isActive = a.isActive();
                y.obj = obj;
                x.add(y);
            }
        }
        
        return x;
    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperPickList {

        @AuraEnabled public String label;
        @AuraEnabled public String value;
        @AuraEnabled public String obj;
        @AuraEnabled public Boolean isActive;

    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public Object metadato;
        @AuraEnabled public List<WrapperPickList> listFiltroEsito;
        @AuraEnabled public String msg;
        @AuraEnabled public String stackTrace;
        @AuraEnabled public String obj;
        @AuraEnabled public String query;
        @AuraEnabled public List<Object> data;
        @AuraEnabled public List<Object> supportData;
        @AuraEnabled public List<Object> trackingData;

        public WrapperResponse(){
            metadato=null;
            success = true;
            msg = '';
            obj = '';
            stackTrace ='';
            data = new List<Object>();
            supportData = new List<Object>();
            trackingData = new List<Object>();
            listFiltroEsito = new List<WrapperPickList>();            
        }
    }

}