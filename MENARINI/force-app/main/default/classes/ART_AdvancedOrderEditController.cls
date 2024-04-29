/**
 * Name     :   ART_AdvancedOrderEditController
 * Date     :   2023-01-17
 * Creator  :   Ezio Dal Bo @TEN
 */

// LV 06-10-2023 DE-036
public with sharing class ART_AdvancedOrderEditController {
    public class AdvancedOderException extends Exception {}

    @AuraEnabled
    public static SObject getRecord(String recordId) {
        SObject record;
        try {
            record = [
                SELECT  Id,
                        Name,
                        ART_Order_Type__c,
                        CreatedBy.Name,
                        cgcloud__Payer__r.ART_PaymentCondition_Farma__c,
                        cgcloud__Payer__r.ART_PaymentCondition_Derma__c,
                        cgcloud__Payer__r.ART_PaymentCondition_OTC__c,
                        cgcloud__Order_Template__c,
                        cgcloud__Order_Template__r.Name,
                        cgcloud__Order_Account__c,
                        cgcloud__Order_Account__r.Name,
                        cgcloud__Order_Account__r.ART_Rural__c,
                        cgcloud__Order_Account__r.THR_AccountGroup__c,
                        cgcloud__Order_Account__r.THR_CustomerSubcategory__c,
                        ART_Customer_identification_code__c,
                        cgcloud__Order_Account__r.ART_Customer_SubCategory_Description__c,
                        cgcloud__Phase__c,
                        cgcloud__Gross_Total_Value__c,
                        cgcloud__Value__c,
                        cgcloud__Order_Date__c,
                        cgcloud__Delivery_Date__c,
                        cgcloud__Order_Id__c,
                        ART_CIG_Code__c,
                        ART_OrderItemRowsCount__c,
                        ART_Class_C__c,
                        cgcloud__Customer_Order_Id__c,
                        cgcloud__Delivery_Recipient__r.Name,
                        cgcloud__Payer__r.Name,
                        cgcloud__Payer__r.THR_CUU__c,
                        ART_Order_send_block__c,
                        ART_Delay_days__c,
                        cgcloud__Wholesaler__c,
                        cgcloud__Wholesaler__r.Name,
                        cgcloud__Invoice_Note__c,
                        cgcloud__Delivery_Note__c,
                        ART_Payment_Code__c,
                        // DE-082 Michele Barile - 07/06/2023
                        cgcloud__Order_Account__r.THR_CustomerIdentificationCode__c,
                        cgcloud__Payer__r.THR_CustomerIdentificationCode__c,
                        cgcloud__Wholesaler__r.THR_CustomerIdentificationCode__c,
                        cgcloud__Delivery_Recipient__r.THR_CustomerIdentificationCode__c,
                        // end
                        // LV 06-10-2023 DE-036 start 
                        ART_Delivery_note__c,
                        ART_Customer_Service_Note__c,
                        ART_Riferimento_Contatto__c,
                        ART_Data_inizio__c,
                        ART_Data_fine__c,
                        ART_Data_inizio_consegna__c,
                        ART_Data_fine_consegna__c,
                        ART_Orario_inizio__c,
                        ART_Orario_fine__c,
                        ART_Giorno_Settimanale__c,
                        ART_total_quantity__c,
                        // LV 06-10-2023 DE-036 end
                        // DK 22-04-2024 DE-116 start
                        cgcloud__Order_Account__r.ART_Attribute1__c,
                        ART_Note__c
                        // DK 22-04-2024 DE-116 end
                FROM cgcloud__Order__c
                WHERE Id =: recordId
            ];
        }
        catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return record;
    }

    @AuraEnabled
    public static Object getPickListOptions(){

        Map<String, List<Object>> optionsMap = new Map<String, List<Object>>();
        optionsMap.put('art_delivery_note__c', new List<Object>());

        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get('cgcloud__Order__c');
        for(String field: optionsMap.keySet()){
            for(Schema.PicklistEntry picklistValue : objSobjectType.getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues()){
                if(picklistValue.active){
                    optionsMap.get(field).add(new Map<String, String>{'label' => picklistValue.getLabel(), 'value' => picklistValue.getValue()});
                }
            }
        }
        return optionsMap;
    }

    @AuraEnabled
    public static sObject saveRecord(sObject record) {
        ART_FollowUpWork.setIsFromDesktop(); // LV DE-035 - AP-027
        try {
            update record;
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return record;
    }

    @AuraEnabled
    public static sObject submitForApproval(sObject record) {
        ART_FollowUpWork.setIsFromDesktop(); // LV DE-035 - AP-027
        Approval.ProcessResult result;
        try {
            update record;
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(record.Id);
            req1.setSubmitterId(UserInfo.getUserId());
            result = Approval.process(req1);
            if (!result.isSuccess()) {
                List<Database.Error> errors = result.getErrors();
                Database.Error error = errors[0];
                String errorMessage = error.getMessage();
                throw new AdvancedOderException(errorMessage);
            }
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return record;
    }
}