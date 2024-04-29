/**
 * @description       : 
 * @author            : simone.viglianti@accenture.com
 * @group             : 
 * @last modified on  : 08-28-2020
 * @last modified by  : simone.viglianti@accenture.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   08-28-2020   simone.viglianti@accenture.com   Initial Version
**/
global class THR_Utils {
    @testVisible private class SendForServiceMailException extends Exception{}
    
    public static String codVFDevName ='THR_VFLetteraResoCODIFI';
    public static String silVFDevName ='THR_VFLetteraResoSilicon';
    public static String DiaVFDevName ='THR_VFLetteraResoDiagnostics';
    public Static String CommDivDia='Menarini Diagnostics (MD)';
    public static String CommDivDia1 = 'MD Check Up';
    public Static String CommDivSil='Silicon Bio System (MSB)';
    
    public static Set<String> emailListFromRelatedContact (Id AccountDepositId){
        Set<String> emailList = new Set<String>();
        for(Contact depContact:[select id, Email from contact where AccountId=: AccountDepositId]){
            if(!String.isBlank(depContact.email)){
            emailList.add(depContact.email);
            }
        }
        return emailList;  
    }
    
    @InvocableMethod
    public static void sendEmailForService(List<Id> recordIDs) {

        System.debug('@@@@@@@EC nel metodo invocable. recordIDs: ' + recordIDs);
        List<String> vfDevNameList = new List<String>{codVFDevName, silVFDevName, DiaVFDevName};

        System.debug('@@@EC vfDevNameList:' + vfDevNameList);
        String eTfolderName ='THR_LettereAutorizzazioneReso';
        id recordId = recordIDs[0];
        system.debug('@@@@EC singolo id recordId: ' + recordId);
        Map<String,EmailTemplate> EmTempMap=new Map<String,EmailTemplate>();
        
        for(EmailTemplate el: [SELECT id, Name, subject, body, FolderId, Folder.Name, HTMLValue, DeveloperName 
                               FROM EmailTemplate 
                               WHERE DeveloperName =:vfDevNameList]){
                                   EmTempMap.put(el.DeveloperName,el);
                               }
        EmailTemplate emailTemplate = new EmailTemplate();
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        
        Case caseSelected = [SELECT id, THR_ClosureReason__c, CaseNumber, ClosedDate, ContactId, ContactEmail, 
                             THR_Cutter_Ph_1__c, THR_Cutter_Ph_2__c, THR_Cutter__c,
                             AccountId, Account.Name, Account.THR_CustomerIdentificationCode__c, THR_CommercialDivision__c,THR_Type__c,
                             Account.BillingAddress,  Account.BillingStreet, Account.BillingPostalCode, 
                             Account.BillingCity, Account.BillingState, Account.BillingCountry, TH_Deposit__c,
                             TH_Deposit__r.BillingAddress, TH_Deposit__r.BillingStreet, TH_Deposit__r.BillingPostalCode, 
                             TH_Deposit__r.BillingCity, TH_Deposit__r.BillingState, TH_Deposit__r.BillingCountry,
                             TH_Deposit__r.Name, TH_Deposit__r.THR_DepositEmail__c, TH_Deposit__r.THR_OtherDepositEmail__c
                             from CASE 
                             where id=: recordId Limit 1];
        
        system.debug('@@@@EC caseSelected: ' + caseSelected);
        
        String emailSubject ='';
        if(CommDivDia.equalsIgnoreCase(caseSelected.THR_CommercialDivision__c) || CommDivDia1.equalsIgnoreCase(caseSelected.THR_CommercialDivision__c)){
            emailTemplate =  EmTempMap.get(DiaVFDevName);
            emailSubject ='Lettera Autorizzazione Reso Diagnostics';
        }
        else if(CommDivSil.equalsIgnoreCase(caseSelected.THR_CommercialDivision__c)){
            emailTemplate =  EmTempMap.get(silVFDevName);
            emailSubject ='Lettera Autorizzazione Reso Silicon';
        }
        else{
            emailTemplate =  EmTempMap.get(codVFDevName); 
            emailSubject ='Lettera Autorizzazione Reso Codifi';
        }
		
		// To Addresses        
        List<String> StringEmail = new List<String>();
        system.debug('@@@@@@EC caseSelected.ContactEmail: ' + caseSelected.ContactEmail);
        StringEmail.add(caseSelected.ContactEmail);
        
        
        /* Ora la richiesta è di prendere gli indirizzi email dal Contact
        String otherDepEmailAdd = caseSelected.TH_Deposit__r.THR_OtherDepositEmail__c ;
       
        if(!String.isBlank(otherDepEmailAdd)){
            for(String emailDep: otherDepEmailAdd.split(';')){
                ccDepAddList.add(emailDep.trim());
            }
            system.debug('@@@@@EC ccDepAddList: ' + ccDepAddList);      
        }
        */
        
        // CC Addresses
        /*
        List<String> ccAddresses = new List <String>();
        
        String depMainEmail = caseSelected.TH_Deposit__r.THR_DepositEmail__c;
        if(!string.isBlank(depMainEmail)){
            ccAddresses.add(caseSelected.TH_Deposit__r.THR_DepositEmail__c);
        }  
        if(!ccDepAddList.isEmpty() && ccDepAddList.size()>0){
            
            ccAddresses.addAll(ccDepAddList);
        }
        */
        Set<String> ccDepAddList = emailListFromRelatedContact(caseSelected.TH_Deposit__c);
        List<String> ccAddresses = new List <String>();
        if(!ccDepAddList.isEmpty()){
        ccAddresses.addAll(ccDepAddList);
        }
        if(!test.isRunningTest()){
        message = Messaging.renderStoredEmailTemplate(emailTemplate.id, caseSelected.ContactId, recordId);
        }
        system.debug('@@@@@@@EC message.getHtmlBody dopo il renderStoreEmailTemplate.: ' + message.getHtmlBody());
        message.setSubject(emailSubject);
        message.setTemplateId(emailTemplate.id);
        System.debug('emailTemplate : ' + emailTemplate.id);
        message.setToAddresses(StringEmail);
     
        if(!ccAddresses.isEmpty()){
        	message.setccAddresses(ccAddresses);
        }
        message.setSaveAsActivity(true);
        message.setTargetObjectId(caseSelected.ContactId);
        message.setWhatId(recordId);
        system.debug('@@@@EC message: ' + message);
        
        // Organization Wide Adress
        /*
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'CarrefourNoReply'];
        if ( owea.size() > 0 ) {
        message.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        */
        List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>{message};
        system.debug('@@@@@EC msgListsize() ' + msgList.size());
        system.debug('@@@@@EC msgList ' + msgList);   
        if (!msgList.isEmpty()) {
            Messaging.SendEmailResult[] results = new Messaging.SendEmailResult[]{};
                results = Messaging.sendEmail(msgList, false);
            system.debug('@@@@@EC  results size: ' + results.size());
            system.debug('@@@@@EC  results: ' + results);
            if (!results.isEmpty()){
                if(results[0].success) {
                    System.debug('ForServicesSendEmail.sendEmailForService: email was sent successfully.');
                } else {
                    System.debug('@@@@EC ForServicesSendEmail.sendEmailForService: The email failed to send: ' + results[0].errors[0].message);
                    throw new SendForServiceMailException(results[0].errors[0].message);
                }      
            }
            else{
                system.debug('@@@@@EC results.isEmpty()? ' + results.isEmpty());
            }
        }
    }
  
    
}