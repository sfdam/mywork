public class WGC_PageLayoutRecordDisplay_Controller {

    /* GESTIONE LAYOUT */
    @AuraEnabled
    public static String getAccountLayoutNameAssigned(String typeObject, String objectId){

        List<RecordType> rts = [SELECT Id 
							      FROM RecordType 
								 WHERE SObjectType =: typeObject ];

        String recordTypeId = '';
        if (rts.size() > 0) {
            // MyObject__c has record types
            String soqlQuery = 'SELECT RecordTypeId FROM ' + typeObject + ' WHERE Id = \'' + objectId + '\' LIMIT 1';
            System.debug('SV soqlQuery: ' + soqlQuery);
            sObject obj = database.query(soqlQuery);
            recordTypeId = (String)obj.get('RecordTypeId');
        }

        String profileId = UserInfo.getProfileId();

        HTTP h = new HTTP();
        HTTPRequest req = new HTTPRequest();
        HttpResponse resp = new HttpResponse();
        req.setMethod('GET');
        if(recordTypeId == ''){
            req.setEndpoint('callout:TestNamedCredential/services/data/v42.0/tooling/query?q=select+Layout.Name+from+ProfileLayout+where+Layout.TableEnumOrId=\'' + typeObject + '\'+and+ProfileId=\'' + profileId + '\'&format=json');
        } else {
            req.setEndpoint('callout:TestNamedCredential/services/data/v42.0/tooling/query?q=select+Layout.Name+from+ProfileLayout+where+ProfileId=\''+profileId+'\'+and+recordtypeid=\''+recordTypeId+'\'&format=json');
        }
        resp = h.send(req);
        System.debug('@@@@ response ' + resp.getBody());
        String response = resp.getBody();
        
        return response;
    }

    @AuraEnabled
    public static PageLayout getPageLayoutMetadata(String pageLayoutName) {
        List<String> componentNameList = new List<String>{pageLayoutName};
        System.debug('SV getPageLayoutMetadata: ' + pageLayoutName);
        if (String.isBlank(pageLayoutName)) {
            return new PageLayout();
        }

        List<Metadata.Metadata> layouts =  
            Metadata.Operations.retrieve(Metadata.MetadataType.Layout, componentNameList);

        if (layouts.size() == 1) {
            return new PageLayout((Metadata.Layout) layouts[0]);
        }

        return new PageLayout();
    }

    public class PageLayout {
        @AuraEnabled
        public List<PageLayoutSection> Sections { get; set; }

        public PageLayout() {
            Sections = new List<PageLayoutSection>();
        }
        
        public PageLayout(Metadata.Layout layout) {
            this();

            for (Metadata.LayoutSection section : layout.layoutSections) {
                if (section.style != Metadata.LayoutSectionStyle.CustomLinks && section.label != 'System Information') { // filter System Information section
                    Sections.add(new PageLayoutSection(section));
                }
            }
        }
    }

    public class PageLayoutSection {
        @AuraEnabled
        public List<PageLayoutSectionColumn> Columns { get; set; }

        @AuraEnabled
        public String Label { get; set; }

        public PageLayoutSection(Metadata.LayoutSection section) {
            Columns = new List<PageLayoutSectionColumn>();

            Label = section.label;
            
            for (Metadata.LayoutColumn column : section.layoutColumns) {
                Columns.add(new PageLayoutSectionColumn(column));
            }
        }
    }

    public class PageLayoutSectionColumn {
        @AuraEnabled
        public List<PageLayoutField> Fields { get; set; }

        public PageLayoutSectionColumn(Metadata.LayoutColumn column) {
            Fields = new List<PageLayoutField>();

            if (column.layoutItems == null) {
                return;
            }

            for (Metadata.LayoutItem item : column.layoutItems) {
                Fields.add(new PageLayoutField(item));
            }
        }
    }
    
    public class PageLayoutField {
        @AuraEnabled
        public String APIName { get; set; }
        @AuraEnabled
        public String Behavior { get; set; }

        public PageLayoutField(Metadata.LayoutItem item) {
            APIName = item.field;
            Behavior = String.valueOf(item.behavior);
        }
    }

    /* GESTIONE LAYOUT */
    @AuraEnabled
    public static Map<String, Object> getOverrideFieldValue(String typeObject, String idObject, List<String> elementOverrideList) {

        Boolean verifyField = doesFieldExist(typeObject, elementOverrideList[0]);
        
        System.debug('SV typeObject: ' + typeObject);
        System.debug('SV elementOverrideList: ' + elementOverrideList);
        System.debug('SV verifyField: ' + verifyField);

        String soql = 'SELECT ';

        for(String sqlField : elementOverrideList){
            if(doesFieldExist(typeObject, sqlField)){
                soql = soql + sqlField + ',';
            }
        }

        soql = soql.removeEnd(',');

        soql = soql + ' FROM ' + typeObject + ' WHERE Id = \'' + idObject + '\'';

        sObject objX = Database.query(soql);

        Map<String, Object> obj = new Map<String, Object>();
        // obj.put('action', 'anAction');
        // obj.put('aLoop', 10);
        // obj.put('ids', new List<Integer>{10, 12, 15});

        for(String sqlField : elementOverrideList) {
            if(doesFieldExist(typeObject, sqlField)) {
                Map<String, String> theObj = new Map<String, String>();
                theObj.put('value', (String)objX.get(sqlField));
                theObj.put('label', Schema.getGlobalDescribe().get(typeObject).getDescribe().fields.getMap().get(sqlField).getDescribe().getLabel());
                obj.put(sqlField, theObj);
            }
        }

        System.debug(JSON.Serialize(obj));
        return obj;
    }

    /**
    * check if an Sobject has a field
    */
    public static boolean doesFieldExist(String objName, string fieldName) {
        try {
            SObject so = Schema.getGlobalDescribe().get(objName).newSObject();
            return so.getSobjectType().getDescribe().fields.getMap().containsKey(fieldName);
        } catch(Exception ex) {
		}
         
        return false;
    }

    @AuraEnabled
    public static Map<String, String> getselectOptions_Nazione(String objectName, String params, String condition) {
        system.debug('SV objectName:' + objectName);
        Map<String, String> allOpts = new Map<String, String>();

        // Get the list of picklist values for this field.
        List<Comune__c> values = [
			SELECT Id, Name, GruppoSAE__c 
			FROM Comune__c 
			WHERE StatoEstero__c = TRUE 
			  AND FlagStorico__c = FALSE 
			  AND CodiceLingua__c = NULL 
			ORDER BY Name
			];
        
        // Add these values to the selectoption list.
        for (Comune__c a: values) {
            allOpts.put(a.Name, a.Name);
        }
        
		// Get the list of picklist values for this field.     
        return allOpts;
    }

	//adione CRM ID 211
    @AuraEnabled
    public static Boolean getCCIAA_ATECO_Conf(String naturaGiuridica, String sae, String recordId, String objType) {
		return BI_CRM_FrontEndUtils_CODE.getCCIAA_ATECO_Conf(naturaGiuridica, sae, recordId, objType);
	}

	//adione CRM ID 207 
    @AuraEnabled
    public static Map<String, String> getselectOptions_SAE(String objectType) {
		return BI_CRM_FrontEndUtils_CODE.getselectOptions_SAE(objectType);
	}

    //adione CRM ID 323
    @AuraEnabled
    public static Map<String, String> getselectOptions_ATECO() {
		Map<String, String> allOpts = new Map<String, String>();
        List<ATECO__c> aa = [
			SELECT
			  Cedacri__c,
			  Descrizione__c,
			  RAE__c
			  FROM Ateco__c
			  ORDER BY Cedacri__c
			];
        if (aa != null && !aa.isEmpty()) {
            for (Ateco__c a:aa) {
				allOpts.put(a.Cedacri__c + ' - ' + a.Descrizione__c, a.Cedacri__c);
            }
        }
        return allOpts;
    }
    
    /* END - GESTIONE LAYOUT */

    @AuraEnabled
    public static Impostazioni__c getCS_CedacriSleepTime() {
        return Impostazioni__c.getInstance();
    }

}