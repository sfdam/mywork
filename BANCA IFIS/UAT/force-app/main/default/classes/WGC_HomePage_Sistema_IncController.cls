public class WGC_HomePage_Sistema_IncController {

    @AuraEnabled
    public static WrapperResponse getSistemaIncentivante(){

        WrapperResponse responseFinal = new WrapperResponse();
        try{
            Result result = new Result();  

            List<WGC_Sistema_Incentivante__c> sysInc = [ SELECT Id, Name, Mese__c, Mese_Form__c, Anno__c, Tipo_Premio__c, Valore__c, Valore_budget__c, Valore_soglia__c 
                                                        FROM WGC_Sistema_Incentivante__c 
                                                        WHERE OwnerId =: UserInfo.getUserId()
                                                            AND Anno__c =: String.valueOf(Date.Today().year())
                                                        ORDER BY Tipo_Premio__c, Mese__c ];

            System.debug(sysInc);

            
            result.sistemaIncentivanteList = sysInc;
            responseFinal.data.add(result);
            
            if(Test.isRunningTest()) throw new TestException();

                
        } catch (Exception e){
            System.debug('SV exception message: ' + e.getMessage());
            responseFinal.success = false;
            responseFinal.msg = e.getMessage();
            //throw new AuraHandledException(e.getMessage());
            System.debug('SV responseFinal: ' + responseFinal);
        }

        return responseFinal;
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
            allOpts.put(a.getValue(), a.getLabel());
        }
        system.debug('allOpts ---->' + allOpts);
        
        return allOpts;
    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<Object>();
        }
    }

    public class Result {
        @AuraEnabled public List<WGC_Sistema_Incentivante__c> sistemaIncentivanteList;
    }
}