public class ApprovalCointestazioniController {
    
    @AuraEnabled
    public static Map<String,Object> getAllData(Id recordId){

        System.debug('DK getAssignData recordId: ' + recordId);
        String sObjectType = recordId.getSObjectType().getDescribe().getName();
        Map<String, String> cointestazioniIdMap = new Map<String, String>();
        Map<String, List<Account>> cointestazioniMap = new Map<String, List<Account>>();
        List<Account> primari = new List<Account>();

        Map<String, SObject> lineItemMap = new Map<String, SObject>();
        if(sObjectType == 'WorkOrder'){

            lineItemMap = SV_Utilities.keyBy([ SELECT Id, AccountId__c
                                                FROM WorkOrderLineItem
                                                WHERE WorkOrderId =: recordId AND
                                                IsPrimario__c = true], 'AccountId__c');
        }else if(sObjectType == 'WorkOrderLineItem'){

            lineItemMap = SV_Utilities.keyBy([ SELECT Id, AccountId__c
                                                FROM WorkOrderLineItem
                                                WHERE Id =: recordId AND
                                                IsPrimario__c = true], 'AccountId__c');
        }
        System.debug('DK lineItemMap: ' + lineItemMap);

        primari = [SELECT Id, Name, CRM_NDG__c, PTF_Filiale__c, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_NaturaGiuridica__c,
                                PTF_CapoGruppo__c, PTF_Gruppo__c, AnnualRevenue, PTF_Accordato__c, PTF_Patrimonio__c, PTF_Utilizzato__c
                                FROM Account
                                WHERE id IN: lineItemMap.keySet()];

        Map<String, SObject> giunzioni = SV_Utilities.keyBy([SELECT id, CRM_Account__c, CRM_Active__c,
                                        CRM_PrimaryNDG__c, CRM_JointOwnership__c,
                                        CRM_JointOwnership__r.PTF_Portafoglio__c
                                        FROM CRM_AccountAccountJointOwnershipRelation__c 
                                        WHERE CRM_Account__c =: lineItemMap.keySet() AND 
                                        CRM_JointOwnership__r.PTF_Portafoglio__c != '' AND
                                        CRM_Active__c = true AND
                                        CRM_PrimaryNDG__c = true], 'Id');
        for(SObject giunzione : giunzioni.values()){

            cointestazioniIdMap.put((String)giunzione.get('CRM_JointOwnership__c'), (String)giunzione.get('CRM_Account__c'));
        }

        for(Account cointestazione : [SELECT Id, Name, CRM_NDG__c, PTF_Filiale__c, ModelloDiServizio__c, PTF_Portafoglio__c, PTF_NaturaGiuridica__c,
                                        PTF_CapoGruppo__c, PTF_Gruppo__c, AnnualRevenue, PTF_Accordato__c, PTF_Patrimonio__c, PTF_Utilizzato__c
                                        FROM Account
                                        WHERE id IN: cointestazioniIdMap.keySet()]){
            if(!cointestazioniMap.containsKey(cointestazioniIdMap.get(cointestazione.Id))){

                cointestazioniMap.put(cointestazioniIdMap.get(cointestazione.Id), new List<Account>());
            }
            cointestazioniMap.get(cointestazioniIdMap.get(cointestazione.Id)).add(cointestazione);
        }

        return new Map<String,Object> {

            'primari' => primari,
            'cointestazioniMap' => cointestazioniMap
        };
    }
}