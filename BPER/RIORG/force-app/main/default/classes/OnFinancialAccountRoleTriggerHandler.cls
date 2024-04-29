public class OnFinancialAccountRoleTriggerHandler {

    public static void setFields(List<FinServ__FinancialAccountRole__c> records){
        for(FinServ__FinancialAccountRole__c role: records){
            if(String.isBlank(role.NDW_ExternalId__c)){
                role.FinServ__Editable__c=true;
                if(!role.ParentUpdated__c){
                    role.FinServ__StartDate__c=role.ParentOpenDate__c;
                }
            } 
            /*if(role.CRM_ParentStatus__c == 'ESTINTO') {
            	role.FinServ__Active__c = false;
                role.FinServ__EndDate__c = role.CRM_ParentCloseDate__c;
            }*/
        }
    }

    
}