public class TreeGridNucleiController {
    public virtual class BaseException extends Exception {}
    public class OtherException extends BaseException {}

    @AuraEnabled
    public static WrapperObj getAllData(String recordId){

        System.debug('DK getAssignData recordId: ' + recordId);
        WrapperObj response = new WrapperObj();

        Map<String, SObject> accMap = new Map<String, SObject>();
        Map<String, SObject> accInNucleiMap = new Map<String, SObject>();
        Map<String, SObject> nucleiMap = new Map<String, SObject>();
        Set<Id> nucleiSet = new Set<Id>();

        try{
            
            accMap = SV_Utilities.keyBy([ SELECT Id, Name, PTF_Nucleo__c, PTF_CapoNucleo__c, PTF_Portafoglio__c, PTF_CoerenzaGruge__c, CRM_NDG__c, CRM_VAT__c,
                                                    PTF_NaturaGiuridica__c, PTF_GruppoGestionale__c,PTF_GruppoComportamentale__c, PTF_OFS__c,PTF_RiportafogliazioneTAG__c,PTF_MiniPortafoglio__c,PTF_MiniPortafoglio__r.PTF_SL__r.Name
                                                FROM Account
                                                WHERE PTF_Portafoglio__c =: recordId ], 'Id', false);
            System.debug('DK AssignAccMap: ' + accMap);

            response.accMap = accMap;
            for (Id accId : accMap.keySet()) {
                if((Id)accMap.get(accId).get('PTF_Nucleo__c') != null) nucleiSet.add((Id)accMap.get(accId).get('PTF_Nucleo__c'));
            }

            nucleiMap = SV_Utilities.keyBy([ SELECT Id, Name
                                                FROM Nucleo__c
                                                WHERE Id IN : nucleiSet ], 'Id', false);
            System.debug('DK nucleiMap: ' + nucleiMap);           
            response.nucleiMap = nucleiMap;

            accInNucleiMap = SV_Utilities.keyBy([ SELECT Id, Name, PTF_Nucleo__c, PTF_CapoNucleo__c, PTF_Portafoglio__c, PTF_CoerenzaGruge__c, CRM_NDG__c, CRM_VAT__c,
                                                    PTF_NaturaGiuridica__c, PTF_GruppoGestionale__c,PTF_GruppoComportamentale__c, PTF_OFS__c,PTF_RiportafogliazioneTAG__c,PTF_MiniPortafoglio__c,PTF_MiniPortafoglio__r.PTF_SL__r.name
                                                FROM Account
                                                WHERE PTF_Nucleo__c IN : nucleiSet AND PTF_Portafoglio__c =: recordId ], 'Id', false);
            System.debug('DK accInNucleiMap: ' + accInNucleiMap);           
            response.accInNucleiMap = accInNucleiMap;
                          
        }

        catch(System.CalloutException e){

            System.debug('DK CalloutException ' + e);

        }

        catch(BaseException e){

            System.debug('DK BaseException ' + e);

        }

        return response;
    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperObj {

        @AuraEnabled public Map<String, SObject> accMap;
        @AuraEnabled public Map<String, SObject> accInNucleiMap;
        @AuraEnabled public Map<String, SObject> nucleiMap;

    }
}