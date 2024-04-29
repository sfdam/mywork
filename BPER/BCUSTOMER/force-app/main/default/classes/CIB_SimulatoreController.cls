public class CIB_SimulatoreController {
    @AuraEnabled
    public static Map<String, Object> init(){
        System.debug('DK START init');
        try {
            Map<String, Object> response = new Map<String, Object>{
                'simulazioni' => Database.query(SV_Utilities.selectAllField('Simulazione__c').replace('FROM', ', Owner.Name, Opportunity__r.Account.Name, Account__r.Name FROM') + ' WHERE OwnerId = \'' + UserInfo.getUserId() + '\' ORDER BY Name ASC')
            };
            return response;
        } catch (Exception ex) {
            System.debug('DK Exception: ' + ex.getMessage() + '; at:' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage() + '; at:' + ex.getStackTraceString());
        }
    }
}