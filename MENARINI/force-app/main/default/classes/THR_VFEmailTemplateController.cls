/**
 * @description       : 
 * @author            : simone.viglianti@accenture.com
 * @group             : 
 * @last modified on  : 10-30-2020
 * @last modified by  : giulia.europa.pagano@accenture.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   08-27-2020   simone.viglianti@accenture.com   Initial Version
**/
global with sharing class THR_VFEmailTemplateController{
 
    Static Map<String,String> BillingCountryAccountpickListLabelValueMap;
    Static Map<String,String> BillingStateAccountpickListLabelValueMap;
 
//    global static Map<String,String> BillingCountryAccountpickListLabelValueMap = pickListLabelValueMapCreation('Account','BillingCountry',true);
    
//    global static Map<String,String> BillingStateAccountpickListLabelValueMap = pickListLabelValueMapCreation('Account','BillingState',true);
 
    global String caseRecordId{get;set;}
    
    global Case caseApproved{
        get {
          
          List<Case> caseList = [select id, THR_ClosureReason__c, CaseNumber, ClosedDate, ContactEmail, THR_Cutter_Ph_1__c, THR_Cutter_Ph_2__c, THR_Cutter__c,
                        AccountId, Account.Name, Account.THR_CustomerIdentificationCode__c, THR_CommercialDivision__c,THR_Type__c,
                        Account.BillingAddress,  Account.BillingStreet, Account.BillingPostalCode, 
                        Account.BillingCity, Account.BillingState, Account.BillingCountry,
                        TOLABEL(Account.BillingStateCode), TOLABEL(Account.BillingCountryCode),
                        TH_Deposit__r.BillingAddress, TH_Deposit__r.BillingStreet, TH_Deposit__r.BillingPostalCode, 
                        TH_Deposit__r.BillingCity, TH_Deposit__r.BillingState, TH_Deposit__r.BillingCountry,TH_Deposit__r.Name,
                        TOLABEL(TH_Deposit__r.BillingStateCode), TOLABEL(TH_Deposit__r.BillingCountryCode)
                        from Case 
                        where id =: caseRecordId];
            
            if(caseList != null && !caseList.isEmpty()){
          caseApproved = caseList[0];
            }else{
                caseApproved = new Case();
            }
            
            
          return caseApproved; }
       set;
    }
    global boolean isDiagnostics{
        get{
            Boolean dia = false;
            if('Menarini Diagnostics (MD)'.equalsIgnoreCase(caseApproved.THR_CommercialDivision__c) || 'MD Check Up'.equalsIgnoreCase(caseApproved.THR_CommercialDivision__c)){
                dia = true;
            }
            return dia;
        }
        set;
     }
    global boolean isSilicon{
        get{
            boolean sil = ('Silicon Bio System (MSB)'.equalsIgnoreCase(caseApproved.THR_CommercialDivision__c))?true:false;
            return sil;
        } 
        set;
    }
    global boolean isCodifi {
        get{
            boolean codifi = (!('Silicon Bio System (MSB)'.equalsIgnoreCase(caseApproved.THR_CommercialDivision__c))&&(!(('Menarini Diagnostics (MD)'.equalsIgnoreCase(caseApproved.THR_CommercialDivision__c)))))? true:false;
            return codifi;
        }
        set;
    }
    
    global  THR_VFEmailTemplateController(){
     system.debug('@@@@@@EC nel controller. caseApproved: ' + caseApproved);
       Map<String,String> BillingCountryAccountpickListLabelValueMap = pickListLabelValueMapCreation('Account','BillingCountryCode',true);
       Map<String,String> BillingStateAccountpickListLabelValueMap = pickListLabelValueMapCreation('Account','BillingStateCode',true);
        
        system.debug('Country Map  : ' + BillingCountryAccountpickListLabelValueMap);
        system.debug('State Map  : ' + BillingStateAccountpickListLabelValueMap);
        
    }
    
    
    global String depName{
        get{
          String dName = caseApproved.TH_Deposit__r.Name;
          return dName;
        }
        set;
    }
    
    global String codiceCliente{
        get{
          String codCl = caseApproved.Account.THR_CustomerIdentificationCode__c;
          return codCl;
        }
        set;
    }
    
    global String todayDate{
        get{
            String strDate;
            Date dt = date.today();
            Integer day = dt.day();
            Integer month = dt.month();
            Integer year = dt.year();
            strDate = day + '/' + month +'/' + year; 
            return strDate;
        }
        set;
    }
    
    global List<THR_Related_Object__c> caseItemRelatedToCaseApproved{
        get{        
          List<THR_Related_Object__c> caseItemList = [SELECT Id, THR_Batch__c, THR_Batch_Expire_Date__c, Name, 
                                         THR_Case_Related__c, CreatedById, THR_Invoice__c, 
                                         THR_Invoice_Date__c, LastModifiedById, THR_Order__c, 
                                         THR_Product__c, THR_Product_Code__c, THR_Product_Quantity__c, 
                                         RecordTypeId, THR_Related_Object__c,
                                         THR_Product__r.Name, THR_Case_Related__r.THR_ClosureReason__c, THR_Case_Related__r.Reason, 
                                         THR_Case_Related__r.THR_Type__c,THR_Description__c 
                                         FROM THR_Related_Object__c
                                         WHERE THR_Case_Related__c =: caseRecordId
                                         AND THR_Related_Object__c = 'Product'];
        return caseItemList;
        }
        set;
    }
    
    global String accBillingStreet{
        get{ 
            String accBillStr=  caseApproved.Account.BillingStreet; //string.valueOf(caseApproved.Account.BillingAddress);
            return accBillStr;
        }
        set;
    }
    
    global String accBillingPostCodeAndCity{
        get{ 
            String accBillPostCDCity=  caseApproved.Account.BillingPostalCode + ' ' + caseApproved.Account.BillingCity; //string.valueOf(caseApproved.Account.BillingAddress);
            return accBillPostCDCity;
        }
        set;
    }
    
    global String accBillingStateCode{
        get{ 
            /*
            Map<String,String> pickListLabelValueMapLoc = pickListLabelValueMapCreation('Account','BillingState',true);
            system.debug('@@@@@EC dentro accBillingStateCode pickListLabelValueMapLoc: ' + pickListLabelValueMapLoc);
            String accBillStateCd = pickListLabelValueMapLoc.get(caseApproved.Account.BillingState) ;
            system.debug('@@@@@EC dentro accBillingStateCode accBillStateCd: ' + accBillStateCd);
           //  Map<String,String> pickListLabelValueMapLoc = pickListLabelValueMapCreation('Account','BillingState',true);
           // pickListLabelValueMapLoc.get(caseApproved.Account.BillingState) ; 
          //  String accBillStateCd=  caseApproved.Account.BillingState ; //string.valueOf(caseApproved.Account.BillingAddress);
          //  */
          //  
            
            return pickListLabelValueMapCreation('Account','BillingStateCode',true).get(caseApproved.Account.BillingStateCode);
        }
        set;
    }
    
   
    global String accBillingAddress{
        get{ 
            
            return 'EUREKA';
        }
        set;
    }
   
    /*
    global String accBillingCountryCode{
        get{ 
            String accBillCountryCd=  caseApproved.Account.BillingCountry ; //string.valueOf(caseApproved.Account.BillingAddress);
            return accBillCountryCd;
        }
        set;
    }
    */
     global String accBillingCountryCode{
        get{
            
            //Map<String,String> BillingCountryAccountpickListLabelValueMap = pickListLabelValueMapCreation('Account','BillingCountry',true);
    
            //String accBillCountryCd = BillingCountryAccountpickListLabelValueMap.get(caseApproved.Account.BillingCountry) ; //string.valueOf(caseApproved.Account.BillingAddress);
            //system.debug('@@@@@EC dentro accBillingStateCode BillingCountryAccountpickListLabelValueMap: ' + BillingCountryAccountpickListLabelValueMap);
            //system.debug('@@@@@EC dentro accBillingCountryCode accBillCountryCd: ' + accBillCountryCd);
            // Map<String,String> pickListLabelValueMapLoc = pickListLabelValueMapCreation('Account','BillingCountry',true);
            //String accBillCountryCd=  pickListLabelValueMapLoc.get(caseApproved.Account.BillingCountry) ; //string.valueOf(caseApproved.Account.BillingAddress);
            //*/
            return pickListLabelValueMapCreation('Account','BillingCountryCode',false).get(caseApproved.Account.BillingCountryCode);
        }
        set;
    }
    
    global Static Map<String,String> pickListLabelValueMapCreation(String nameObjectVar, String FieldNameVar, Boolean desiredValueToGetIsLabel){
        system.debug('@@@@@EC dentro pickListLabelValueMapCreation');
        //Boolean   labelDesidered= desiredValueToGetIsLabel;
        Map<String,String> pickListLabelValueMap = new Map<String,String>();
        Schema.sObjectType objTypeVar = Schema.getGlobalDescribe().get(nameObjectVar);  // Contact.getSObjectType();
        Sobject genericObject = objTypeVar.newSObject();
        Schema.sObjectType objType = genericObject.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        List<Schema.PicklistEntry> values = fieldMap.get(FieldNameVar).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a : values){
  
                pickListLabelValueMap.put(a.getValue(),a.getLabel());
            
        }
        system.debug('MAP: '+pickListLabelValueMap);
        return pickListLabelValueMap;
    }
    
    public string getDocumentLogoUrl(String docName){
        String docNameTest = docName + 'A';
        docName = (test.isRunningTest()?docNameTest: docName);
        List<Document> lstDocument = [Select Id,Name,LastModifiedById 
                                      from Document 
                                      where Folder.DeveloperName =: 'THR_DocumentForLetterheads' 
                                      and DeveloperName =: docName limit 1];
        
        string strOrgId = UserInfo.getOrganizationId();
        string strDocUrl = 'https://'+ApexPages.currentPage().getHeaders().get('Host')+ '/servlet/servlet.ImageServer?id='+lstDocument[0].Id+'&oid=' + strOrgId;
        return strDocUrl;    
    }
    
    global String fCod {
        get{
            String fC = getDocumentLogoUrl('THR_FirmaCODIFI');
                //'https://grmenarini.my.salesforce.com/0155I0000007s1E';  //Sviluppo:'https://grmenarini--dev1.my.salesforce.com/0150E000000zCjC';
            return fC;
        }
        set;
    } 
    
    global String fDi {
        get{
            String fD = getDocumentLogoUrl('THR_FirmaDiagnostic');
                //'https://grmenarini.my.salesforce.com/0155I0000007s1J';  //Sviluppo: 'https://grmenarini--dev1.my.salesforce.com/0150E000000zCjH';
            return fD;
        }
        set;
    } 
    
    global String fSil {
        get{
            String fS = getDocumentLogoUrl('THR_FirmaSilicon');
                //'https://grmenarini.my.salesforce.com/0155I0000007s1O';  //'https://grmenarini--dev1.my.salesforce.com/0150E000000zCjR';
            return fS;
        }
        set;
    }
    
    global String LCod {
        get{ //https://grmenarini--c.documentforce.com/servlet/servlet.FileDownload?file=0F05I0000000w6q
            String lC = getDocumentLogoUrl('THR_LogoCODIFI');
                //'https://grmenarini--c.documentforce.com/servlet/servlet.FileDownload?file=0F05I0000000w6q'; //'https://grmenarini.my.salesforce.com/0155I0000007s0z';  //'https://grmenarini.my.salesforce.com/0155I0000007s0z';  
            return lC;
        }
        set;
    }
    
    global String LDi {
        get{
            String lDia =  getDocumentLogoUrl('THR_DiagnosticLogo');
                //'https://grmenarini.my.salesforce.com/0155I0000007s19';
            return lDia;
        }
        set;
    }
    
    global String LSil {
        get{
            String lS = getDocumentLogoUrl('THR_SiliconLogo1');
                //'https://grmenarini.my.salesforce.com/0155I0000007s1T';
            return lS;
        }
        set;
    }
    
     global String FooterCodifi {
        get{
            String lS = getDocumentLogoUrl('THR_CodifiFooter');
            return lS;
        }
        set;
    }

    global String FooterRelife {
        get{
            String rFooter = getDocumentLogoUrl('Relife_footer');
            return rFooter;
        }
        set;
    }

    global String depBillingAddress{
        get{
         
          String depBillAdd = caseApproved.TH_Deposit__r.BillingStreet + '\n' 
                        + caseApproved.TH_Deposit__r.BillingPostalCode + ' ' + caseApproved.TH_Deposit__r.BillingCity + '\n'
                        + caseApproved.TH_Deposit__r.BillingStateCode + '\n'
                        + caseApproved.TH_Deposit__r.BillingCountryCode + '\n' ;  //string.valueOf(caseApproved.TH_Deposit__r.BillingAddress);
          return depBillAdd;    
        }
        set;
    }
    
    global String  accName {
        get{
            String acName = caseApproved.Account.Name;
            return acName;
        }
        set;
    }
}



/*global class THR_VFEmailTemplateController {
    
    global String caseRecordId {get;set;} 
   // List<THR_Related_Object__c> caseItemRelatedToCaseApproved;
   //   private final List<THR_Related_Object__c> caseItemListRelatedToCaseApproved;
    global List<THR_Related_Object__c> caseItemRelatedToCaseApproved {get;set;}
    global Account acc {get;set;}
    global Case caseApproved {get;set;}
    global string accName {get;set;}
    global string accBillingAddress {get;set;}
    global string depBillingAddress {get;set;}
    global String codiceCliente {get; set;}
    //global string motivoReso {get;set;}  //non serve, nella tabellina bisogna reiterare su caseItem
    global boolean isCodifi {get;set;}
    global boolean isDiagnostics {get;set;}
    global boolean isSilicon {get;set;}

    //(Order)stdController.getRecord();    
    global THR_VFEmailTemplateController() {
        String urlString =  ApexPages.currentPage().getUrl();
        
        //caseRecordId = urlString.substringBetween('Case/', '/view');
        system.debug('@@@@EC nel controller. dopo apexpage caseRecordId è: ' + caseRecordId);
        isCodifi = false;
        isDiagnostics = false;
        isSilicon = false;
        System.debug('@@@@EC nel controller THR_VFEmailTemplateController:  caseRecordId è ' + caseRecordId);
*/
       /* 
        if(string.isBlank(caseRecordId)){ //null == caseRecordId
            System.debug('@@@@EC nel controller non ha trovato caseRecordId, quindi ne assegniamo uno di default. Dovrebbe servire esclusivamente per la preview dell\'email template.');
           caseRecordId = [select THR_Case_Related__c from THR_Related_Object__c where THR_Related_Object__c = 'Product' order by THR_Case_Related__r.closedDate desc limit 1].THR_Case_Related__c;
        }
            */
//caseRecordId='5000E00000D4ehqQAB';
/*
caseItemRelatedToCaseApproved = [select THR_Batch__c, THR_Batch_Expire_Date__c, Name, 
                                         THR_Case_Related__c, CreatedById, THR_Invoice__c, 
                                         THR_Invoice_Date__c, LastModifiedById, THR_Order__c, 
                                         THR_Product__c, THR_Product_Code__c, THR_Product_Quantity__c, 
                                         RecordTypeId, THR_Related_Object__c,
                                         THR_Product__r.Name, THR_Case_Related__r.THR_ClosureReason__c
                                         from THR_Related_Object__c 
                                         where THR_Case_Related__c =: caseRecordId
                                         AND THR_Related_Object__c = 'Product'];
        System.debug('@@@@EC in  THR_VFEmailTemplateController caseItemRelatedToCaseApproved size è: '+ caseItemRelatedToCaseApproved.size());
      
        caseApproved = [select id, THR_ClosureReason__c, CaseNumber, ClosedDate, ContactEmail, THR_Cutter_Ph_1__c, THR_Cutter_Ph_2__c, THR_Cutter__c,
                        AccountId, Account.Name, Account.THR_CustomerIdentificationCode__c, THR_CommercialDivision__c,
                        Account.BillingAddress,  Account.BillingStreet, Account.BillingPostalCode, 
                        Account.BillingCity, Account.BillingState, Account.BillingCountry,
                        TH_Deposit__r.BillingAddress, TH_Deposit__r.BillingStreet, TH_Deposit__r.BillingPostalCode, 
                        TH_Deposit__r.BillingCity, TH_Deposit__r.BillingState, TH_Deposit__r.BillingCountry
                        from Case 
                        where Id =: caseRecordId];
        
        
        if('Menarini Diagnostics (MD)'.equalsIgnoreCase(caseApproved.THR_CommercialDivision__c)){
            isDiagnostics= true;
        }
        else if('Silicon Bio System (MSB)'.equalsIgnoreCase(caseApproved.THR_CommercialDivision__c)){
            isSilicon = true;
        }
        else {
            isCodifi = true;
        }
            //usiamo i boolean per renderizzare solo un logo differente, tutte il resto del template dovrebbe essere uguale.
        system.debug('@@@@@EC quale boolean sarà vero? isDiagnostics: ' + isDiagnostics + ', isSilicon: ' + isSilicon + ', isCodifi: ' + isCodifi);
        accName = caseApproved.Account.Name;
        accBillingAddress =  caseApproved.Account.BillingStreet + '\n' 
                            + caseApproved.Account.BillingPostalCode + '\n'
                            + caseApproved.Account.BillingCity + '\n'
                            + caseApproved.Account.BillingState + '\n'
                            + caseApproved.Account.BillingCountry + '\n' ; //string.valueOf(caseApproved.Account.BillingAddress);
        depBillingAddress  = caseApproved.TH_Deposit__r.BillingStreet + '\n' 
                            + caseApproved.TH_Deposit__r.BillingPostalCode + '\n'
                            + caseApproved.TH_Deposit__r.BillingCity + '\n'
                            + caseApproved.TH_Deposit__r.BillingState + '\n'
                            + caseApproved.TH_Deposit__r.BillingCountry + '\n' ;  //string.valueOf(caseApproved.TH_Deposit__r.BillingAddress);
        codiceCliente = caseApproved.Account.THR_CustomerIdentificationCode__c;
       // motivoReso = caseApproved.THR_ClosureReason__c;
    }    
    
    global void Donothing(){
        
        
    }
}
*/