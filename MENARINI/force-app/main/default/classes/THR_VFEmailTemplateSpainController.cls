/**
 * @description       : 
 * @author            : a.zecchinelli@accenture.com
 * @group             : 
 * @last modified on  : 11-16-2020
 * @last modified by  : 
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   08-27-2020   a.zecchinelli@accenture.com   Initial Version
**/
global with sharing class THR_VFEmailTemplateSpainController{
 
    global String caseRecordId{get;set;}
    global String createdDate{get;set;}
    
    global  THR_VFEmailTemplateSpainController(){
       system.debug('@@@@@@THR_VFEmailTemplateSpainController');
    }
    
    global Case caseApproved{
        get {
          
          List<Case> caseList = [SELECT Id, 
                                        CaseNumber,
                                        CreatedDate,
                                        Priority,
                                        Description,    
                                        Owner.Name, 
                                        ClosedDate, 
                                        ContactEmail,
                                        THR_CommercialDivision__c,
                                        TOLABEL(THR_Type__c),
                                        THR_FO_Feedback__c,
                                        THR_DDTNumber__c,
                                        THR_CustomerIdentificationCode__c,
                                        THR_AccountingDocumentDate__c,
                                        THR_InvoiceExpiryDate__c,
                                        THR_GrossValue__c,
                                        THR_DocumentNumberSD__c,
                                        THR_Regulatory_Feedback__c,
                                        Account.THR_CustomerIdentificationCode__c,
                                        Account.THR_AccountGroup__c,
                                        Account.Name,
                                        Account.AccountNumber,
                                        Account.BillingPostalCode, 
                                        Account.BillingAddress, 
                                        Account.BillingStreet,
                                        Account.BillingCity,
                                        TOLABEL(Account.BillingCountryCode),
                                        Account.BillingState,
                                        TOLABEL(Account.BillingStateCode),
                                        ContactId, 
                                        Contact.Name, 
                                        Contact.FirstName, 
                                        Contact.LastName, 
                                        Contact.THR_IdentificationCode__c, 
                                        Contact.Phone, 
                                        Contact.Email, 
                                        Contact.MailingCity,
                                        TOLABEL(Contact.MailingStateCode),
                                        Contact.MailingPostalCode,
                                        Contact.MailingAddress,
                                        Contact.MailingStreet,
                                        TOLABEL(Contact.MailingCountryCode)
                                FROM Case 
                                WHERE Id =: caseRecordId];
             system.debug('@@@@caseList is '+caseList);

            if(caseList != null && !caseList.isEmpty()){
                caseApproved = caseList[0];
                system.debug('@@@@createdDate is '+caseList[0].CreatedDate);
                createdDate = caseList[0].CreatedDate.format('dd-MM-yyyy');
            }else{
                caseApproved = new Case();
            }
            
            
          return caseApproved; }
       set;
    }
 
    
    global List<THR_Related_Object__c> caseItemRelatedToCaseApproved{
        get{        
          List<THR_Related_Object__c> caseItemList = [SELECT Id, Name, CreatedById, LastModifiedById, RecordTypeId, 
                                                              THR_Batch__c, 
                                                              THR_Batch_Expire_Date__c, 
                                                              THR_Case_Related__c, 
                                                              THR_Invoice__c, 
                                                              THR_Invoice__r.THR_DocumentNumberSD__c, 
                                                              THR_Invoice__r.THR_Date__c, 
                                                              THR_Invoice__r.THR_OrderNumber__c, 
                                                              THR_Invoice__r.THR_GrossValue__c, 
                                                              THR_Invoice_Date__c, 
                                                              THR_Order__c, 
                                                              THR_Product__c, 
                                                              THR_Product_Code__c, 
                                                              THR_Product_Quantity__c, 
                                                              THR_Related_Object__c,
                                                              THR_Product__r.Name, 
                                                              THR_Case_Related__r.THR_ClosureReason__c, 
                                                              THR_Case_Related__r.Reason, 
                                                              THR_Case_Related__r.THR_Type__c,
                                                              THR_Description__c 
                                                      FROM THR_Related_Object__c
                                                      WHERE THR_Case_Related__c =: caseRecordId];
        return caseItemList;
        }
        set;
    }
    
    
    global String accBillingAddress{
        get{ 
            
            return (caseApproved.Account.BillingStreet != null ? caseApproved.Account.BillingStreet : '') + ' ' 
                 + (caseApproved.Account.BillingPostalCode != null ? caseApproved.Account.BillingPostalCode : '') + ' ' 
                 + (caseApproved.Account.BillingCity != null ? caseApproved.Account.BillingCity : '') + ' ' 
                 + (caseApproved.Account.BillingStateCode != null ? caseApproved.Account.BillingStateCode : '') + ' ' 
                 + (caseApproved.Account.BillingCountryCode != null ? caseApproved.Account.BillingCountryCode : '');
        }
        set;
    }
    
    global String contactMailingAddress{
        get{ 
             
            
            return  (caseApproved.Contact.MailingStreet != null ? caseApproved.Contact.MailingStreet : '') + ' ' 
                  + (caseApproved.Contact.MailingPostalCode != null ? caseApproved.Contact.MailingPostalCode : '') + ' '
                  + (caseApproved.Contact.MailingCity != null ? caseApproved.Contact.MailingCity : '') + ' ' 
                  + (caseApproved.Contact.MailingStateCode != null ? caseApproved.Contact.MailingStateCode : '') +  ' '
                  + (caseApproved.Contact.MailingCountryCode != null ? caseApproved.Contact.MailingCountryCode : '');
        }
        set;       
    }
    
     global String createdDateCase{
        get{ 
             
            
            return createdDate;
        }
        set;       
    }
            
}