public with sharing class InvocableDeleteProspectPardot {

    public class ActionRequest {       
        @AuraEnabled @InvocableVariable
        public String Email;
        @AuraEnabled @InvocableVariable
        public String Key;
    }

    @InvocableMethod(label='Delete Prospect Pardot' callout=true)
    public static List<String> deleteProspectPardot(List<ActionRequest> parametri){
        Map<String,String> params = new Map<String,String>{
            'email' => parametri[0].Email,
            'id' => parametri[0].Key
        };
        
        String str = PardotIntegrationCtrl.deleteContact(params);
        return new List<String>{str};
    }
}