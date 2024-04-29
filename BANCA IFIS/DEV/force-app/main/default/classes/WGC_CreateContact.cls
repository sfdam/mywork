public class WGC_CreateContact {

    @AuraEnabled
    public static WrapperResponse getInformationContact(String InputObjString) {
        System.debug('SV InputObjString: ' + InputObjString);
        
        WrapperRecords InputObj = (WrapperRecords)JSON.deserialize(InputObjString, WrapperRecords.class);
        System.debug('SV requestFields: ' + InputObj);
        
        WrapperResponse result = new WrapperResponse();
        List<Contact> result_sfdc = new List<Contact>();
        List<Contact> result_cedacri = new List<Contact>();
        List<Contact> result_ribes = new List<Contact>();
        
        try{
            if(InputObj.tipoDiRicerca == 'cFiscale'){
                InputObj.lastName = '';
                InputObj.firstName = '';
                if(InputObj.whoAreYou == 'filoDiretto'){
                    result_sfdc = CtrlWizardAccount.WGC_searchContattiSFDC_filoDiretto(InputObj.cf, InputObj.lastName, InputObj.firstName);
                } else {
                    result_sfdc = CtrlWizardAccount.searchContattiSFDC(InputObj.cf, InputObj.lastName, InputObj.firstName);
                }
                if(result_sfdc.size() <= 0){
                    // ANDG CEDACRI
                    result_cedacri = CtrlWizardAccount.searchContattiANDG(InputObj.cf, InputObj.lastName, InputObj.firstName);
                    if(result_cedacri.size() > 0){
                        result.data = result_cedacri;
                    }
                } else {
                    result.data = result_sfdc;
                }
            } else {
                InputObj.cf = '';
                // SFDC SALESFORCE
                if(InputObj.whoAreYou == 'filoDiretto'){
                    result_sfdc = CtrlWizardAccount.WGC_searchContattiSFDC_filoDiretto(InputObj.cf, InputObj.lastName, InputObj.firstName);
                } else {
                    result_sfdc = CtrlWizardAccount.searchContattiSFDC(InputObj.cf, InputObj.lastName, InputObj.firstName);
                }
                
                for(Contact sfdc : result_sfdc){
                    //adione SDHDFNZ-94034
                    if (sfdc.CF__c != null)
                    	sfdc.CF__c = sfdc.CF__c.toUpperCase().trim();                    
                    result.data.add(sfdc);
                }
                System.debug('SFDC COMPLETO: ' + result_sfdc);
                
                // ANDG CEDACRI
                result_cedacri = CtrlWizardAccount.searchContattiANDG(InputObj.cf, InputObj.lastName, InputObj.firstName);
                Boolean find = false;
                for(Contact cedacri : result_cedacri){
                    
                    for(Contact x : result_sfdc){
                        if(x.NDGGruppo__c == cedacri.NDGGruppo__c){
                            find = true;
                        }
                    }
                    if(!find){
                        result.data.add(cedacri);   
                    } else {
                        find = false;
                    }
                }
                System.debug('CEDACRI COMPLETO');

                // SET WRAPPER RESPONSE
                if(result.data.size() <= 0){
                    result.success = false;
                    result.msg = 'Nessun dato trovato';
                }
            }
            
            
        } catch(exception e){
            result.success = false; 
            result.msg = e.getMessage();
            return result;
        }
        
        return result;
        
    }

    @AuraEnabled
    public static Account getOriginAccount(String accountId) {
        System.debug('SV getInformationAccount: ' + accountId);

            Account acc = new Account();
            acc = [ SELECT Id, Name, Origine__c, CF__c, PIVA__c, NaturaGiuridica__c, StatoAnagrafica__c, RecordType.DeveloperName
                    FROM Account 
                    WHERE Id =: accountId ];
            
        
        return acc;
        
    }

    @AuraEnabled
    public static Opportunity getOriginOpportunity(String oppId) {
        System.debug('SV getInformationOpportunity: ' + oppId);

            Opportunity opp = [ SELECT Id, Assuntore__c,  RecordType.DeveloperName FROM Opportunity WHERE Id =: oppId ];
            
        
        return opp;
        
    }

    @AuraEnabled
    public static List<AccountContactRelation> getAccountConnectedWithContact(Contact contact) {
        System.debug('SV getAccountConnectedWithContact: ' + contact);
        List<AccountContactRelation> result = new List<AccountContactRelation>();
        
        return result;
        
    }

    @AuraEnabled
    public static WrapperResponse setInformationContact(Contact InputObj) {
        System.debug('SV set Account Information: ' + InputObj);
        WrapperResponse result = new WrapperResponse();
        try{

            Contact contact = CtrlWizardAccount.cwaFetchContact(InputObj);
            result.data.add(contact);

        } catch(Exception e){
            result.success = false;
            result.msg = e.getMessage();
        }

        return result;
        
    }

    @AuraEnabled
    public static WrapperResponse saveContact(Contact objObject, String AccountId, List<String> selectedRoles, String tipoCensimento, String whoAreYou, Opportunity opportunitySelected) {
        System.debug('SV Contact Information: ' + objObject);
        System.debug('SV Contact AccountId: ' + AccountId);
        System.debug('SV Contact selectedRoles: ' + selectedRoles);
        System.debug('SV tipoCensimento Information: ' + tipoCensimento);
        System.debug('SV whoAreYou: ' + whoAreYou);
        System.debug('SV opportunity Information: ' + opportunitySelected);
        
        WrapperResponse result = new WrapperResponse();
        List<AccountContactRelation> accContactRelationList = new List<AccountContactRelation>();
        List<AccountContactRelation> existingContactRelationList = new List<AccountContactRelation>();

        Account acc = [SELECT Id, NDGGruppo__c, NaturaGiuridica__c FROM Account WHERE Id =: AccountId LIMIT 1];
        
        // Map<String, SObject> mapTipo_Rete_NaturaGiuridica = U.keyBy([ SELECT Label, Descrizione__c, Tipo_Azienda__c, Societa_di_capitale__c, Rete_Esecutore__c FROM WGC_NaturaGiuridicaTipoRete__mdt ], 'Label');  
        // System.debug('SV mapTipo_Rete_NaturaGiuridica: ' + mapTipo_Rete_NaturaGiuridica);
        

        try{
            //adione SDHDFNZ-94034
            if(tipoCensimento != 'censimentoLead') { //per i lead mancano questi campi
                objObject.MailingCity = objObject.MailingCity.toUpperCase().trim();
                objObject.MailingStreetName__c = objObject.MailingStreetName__c.toUpperCase().trim();                
            }
            // SCHIFO DA RIVEDERE
            objObject.MailingCity__c = objObject.MailingCity;
            objObject.MailingCountry__c = objObject.MailingCountry;
            objObject.MailingPostalCode__c = objObject.MailingPostalCode;
            objObject.MailingState__c = objObject.MailingState;
            objObject.MailingStreet = objObject.MailingStreetType__c + ' ' + objObject.MailingStreetName__c + ' ' + objObject.MailingStreetNumber__c;

            objObject.NaturaGiuridica__c = 'PF';
            //adione SDHDFNZ-94034
            if(tipoCensimento != 'censimentoLead') { //per i lead mancano questi campi
                objObject.CF__c = objObject.CF__c.toUpperCase().trim();
                objObject.CI3N_CF__c = (objObject.CodiceIstituto3N__c + '-' + objObject.CF__c).toUpperCase().trim();
                objObject.FirstName = objObject.FirstName.toUpperCase().trim();
                objObject.LastName = objObject.LastName.toUpperCase().trim();
                objObject.LuogoNascita__c = objObject.LuogoNascita__c.toUpperCase().trim();
            }
            

            if(tipoCensimento == 'censimentoLead'){
                TrgContact.skipCheckCodiceFiscale = true;
                objObject.CodiceIstituto3N__c = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
                objObject.AccountId = AccountId;

                insert objObject;
                result.data.add(objObject);
            } else {
                if(String.IsNotBlank(objObject.LuogoNascita__c)){
                    Map<String, SObject> comuniMap = U.keyBy([SELECT
                        Id,
                        Name,
                        CodiceCatastale__c,
                        Cab__c
                        FROM Comune__c
                        WHERE Name =: objObject.LuogoNascita__c
                        ORDER BY FlagStorico__c
                    ], 'Name');

                    System.debug('SV comuniMap: ' + comuniMap);
                    System.debug('SV LuogoNascita__c: ' + objObject.LuogoNascita__c);

                    if(comuniMap.size() > 0){
                        objObject.CodCatastaleLocNascita__c = String.valueOf(comuniMap.get(objObject.LuogoNascita__c.toUpperCase()).get('CodiceCatastale__c'));
                        System.debug('SV CodCatastaleLocNascita__c: ' + objObject.CodCatastaleLocNascita__c);
                    }

                }

                objObject.CodiceIstituto3N__c = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
                objObject.CI3N_CF__c = objObject.CodiceIstituto3N__c + '-' + objObject.CF__c;

                System.debug('SV ID: ' + objObject.Id);
                if(String.IsNotBlank(objObject.Id)){
                    existingContactRelationList = [ SELECT Roles, AccountId, IsDirect, WGC_Ruolo__c FROM AccountContactRelation WHERE ContactId =: objObject.Id ];
                }       
                
                String stringRoles = '';
                for(String selectRole : selectedRoles){
                    stringRoles = stringRoles + selectRole + ';';
                }
                stringRoles = stringRoles.removeEnd(';');
                
                Boolean find = false;
                for(AccountContactRelation accCont : existingContactRelationList){
                    if(accCont.AccountId == AccountId) find = true;
                    AccountContactRelation accContactRelationX = new AccountContactRelation();
                    if(find){
                        accContactRelationX.WGC_Ruolo__c = stringRoles;
                    } else {
                        accContactRelationX.WGC_Ruolo__c = accCont.WGC_Ruolo__c;
                    }
                    accContactRelationX.AccountId = accCont.AccountId;
                    System.debug('SV accCont: ' + accCont);
                    accContactRelationList.add(accContactRelationX);
                }
                
                if(!find){
                    AccountContactRelation accContactRelation = new AccountContactRelation();
                    accContactRelation.WGC_Ruolo__c = stringRoles;
                    accContactRelation.AccountId = AccountId;
                    accContactRelationList.add(accContactRelation);
                }
                
                if(existingContactRelationList.size() <= 0) objObject.AccountId = AccountId;
                System.debug('SV accContactRelationList: ' + accContactRelationList);

                Id contactId = CtrlWizardAccount.WGC_upsertContact(objObject, acc, accContactRelationList, '', tipoCensimento);
                result.data.add(objObject);

                if(whoAreYou == 'Opportunity'){
                    List<NDGLinea__c> ndgList = [ SELECT Id, Name, Opportunita__c, Account__c, Contact__c FROM NDGLinea__c WHERE Opportunita__c =: opportunitySelected.Id AND Contact__c =: contactId ];
                    System.debug('SV ndgList.size(): ' + ndgList.size());
                    
                    if(ndgList.size() <= 0){
                        NDGLinea__c ndgLinea = new NDGLinea__c();
                        ndgLinea.Opportunita__c = opportunitySelected.Id;
                        ndgLinea.Contact__c = contactId;
                        // ADD FASTFINANCE
                        System.debug('SV NDGLinea__c objObject.StatoFastFinance__c: ' + objObject.StatoFastFinance__c);
                        if(String.IsNotBlank(objObject.StatoFastFinance__c) &&  objObject.StatoFastFinance__c == 'Professionista'){
                        ndgLinea.RecordTypeId = [ SELECT Id, DeveloperName  FROM RecordType WHERE DeveloperName = 'Professionista' AND SobjectType = 'NDGLinea__c' ].Id; 
                        }
                        insert ndgLinea;
                    }
                }
            }
        } catch(Exception e){
            result.success = false;
            result.msg = e.getMessage();
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

    @AuraEnabled
    public static WGC_CreateContact.WrapperRecords getPositionRecords() {
        
        WGC_CreateContact.WrapperRecords lstPositionRecords = 
		new WGC_CreateContact.WrapperRecords();
        
        
        
        return lstPositionRecords;

    }

    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

    @AuraEnabled
    public static Impostazioni__c getCS_CedacriSleepTime() {
        return Impostazioni__c.getInstance();
        
    }

    @AuraEnabled
    public static User getUserInfo() {
        return [ SELECT Id, Name, Qualifica_Utente__c, Profile.Name FROM User WHERE Id =: UserInfo.getUserId() ];
        
    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperRecords {
        
        @AuraEnabled public String cf;
    	@AuraEnabled public String firstName;
    	@AuraEnabled public String lastName;
    	@AuraEnabled public String tipoDiRicerca;
        @AuraEnabled public String whoAreYou;
        
        public WrapperRecords(){
            cf = '';
            firstName = '';
            lastName = '';
            tipoDiRicerca = 'cFiscale';
            whoAreYou = '';
        }
    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<sObject> data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<sObject>();
        }
    }

}