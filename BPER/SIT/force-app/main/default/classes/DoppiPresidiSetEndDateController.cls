public class DoppiPresidiSetEndDateController {
    @AuraEnabled
    public static Boolean updateFlagDoppiPresidi (String recordId, String accountId) {

        try {

            NDGManagementMember__c element = [SELECT Id, PTF_EndDate__c, PTF_EndDate_DT__c, PTF_AutoDP__c FROM NDGManagementMember__c WHERE Id=: recordId];
            if(element.PTF_AutoDP__c){
                throw new AuraHandledException('Non è possibile eliminare un Doppio Presidio creato automaticamente');
            }
            element.PTF_EndDate__c = Date.today();
            element.PTF_EndDate_DT__c = Datetime.now();
            
            if(element != null) update element;

        } 
        catch(AuraHandledException e){
            throw new AuraHandledException('Non è possibile eliminare un Doppio Presidio creato automaticamente');
        }
        catch (Exception e) {  
            // This catches the OtherException
            System.debug('SV Exception ' + e);
            return false;

        } 
        
        return true;

    }
}