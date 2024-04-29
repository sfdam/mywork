public with sharing class AlertScadenzeController {
    
    @AuraEnabled
    public static List<FinServ__Alert__c> getAllData(String recordId){
        //MARCELLO SPADACCINI - AGGIUNTO CHECK SU USER "Consulenti Finanziari" 
        User currentUser = [SELECT Id, ProfileId, Profile.Name,name,PTF_RuoloLDAP__c, abi__c FROM User WHERE Id = :UserInfo.getUserId()];
        
        Account relAcc = [SELECT id, name, modellodiservizio__c from Account where id=:recordId];
        if (currentUser.Profile.Name == 'CRM - Consulenti Finanziari' )
        {
            return [SELECT id, name, CRM_CED__c,FinServ__FinancialAccount__r.CRM_DescrizioneNome__c, CRM_TipologiaScadenza__c,CRM_FormulaData__c, 
                    CRM_Importo__c, FinServ__FinancialAccount__r.Name, FinServ__FinancialAccount__r.id, CRM_EsitoContatto__c,CRM_ProdottoCommDS__c,
                    CRM_CodiceProdottoElementare__c, CRM_OwnershipType__c, FinServ__FinancialAccount__r.RecordType.DeveloperName, CRM_DataScadenza__c
                    FROM FinServ__Alert__c
                    WHERE CRM_IsVisible__c = true
                    AND ((CRM_EsitoContatto__c != 'Prodotto venduto' AND CRM_EsitoContatto__c != 'Cliente non interessato')
                        OR ((CRM_EsitoContatto__c = 'Prodotto venduto' OR CRM_EsitoContatto__c = 'Cliente non interessato') AND CRM_DataEsitazione__c = TODAY))
                    AND FinServ__FinancialAccount__c IN (select FinServ__FinancialAccount__c from FinServ__FinancialAccountRole__c where FinServ__RelatedAccount__c =:recordId
                        AND (FinServ__Role__c = 'Primary Owner' or FinServ__Role__c = 'Cointestatario') and FinServ__Active__c = true 
                        AND ((FinServ__FinancialAccount__r.RecordType.DeveloperName != 'Credit_Line' AND FinServ__FinancialAccount__r.FinServ__Status__c = 'ATTIVO') OR (FinServ__FinancialAccount__r.RecordType.DeveloperName = 'Credit_Line' AND FinServ__FinancialAccount__r.CRM_StatoFido__c = 'ATTIVO'))
                        AND (FinServ__FinancialAccount__r.FinServ__JointOwner__c = null OR (FinServ__FinancialAccount__r.FinServ__JointOwner__r.User_Is_Referente_Portafoglio__c = true 
                        AND FinServ__FinancialAccount__r.FinServ__JointOwner__c != null )))]; 
        }
        else if( relAcc.modellodiservizio__c=='Cesare Ponti' && currentUser.abi__c=='03084')
            {
                /*financialRoleMap = SV_Utilities.keyBy([ SELECT Id, Name, FinServ__RelatedAccount__c, FinServ__FinancialAccount__c,
                                                        FinServ__FinancialAccount__r.RecordType.DeveloperName, toLabel(FinServ__Role__c), FinServ__Active__c
                                                    FROM FinServ__FinancialAccountRole__c 
                                                    WHERE FinServ__RelatedAccount__c =: recordId AND CRM_Flagdelegato__c=false AND FinServ__Active__c = true AND 
                                                        FinServ__FinancialAccount__r.RecordType.DeveloperName IN : objRecordType AND (FinServ__FinancialAccount__r.FinServ__JointOwner__c = null OR ( FinServ__FinancialAccount__r.FinServ__JointOwner__c != null AND FinServ__FinancialAccount__r.FinServ__JointOwner__r.ModelloDiServizio__c = 'Cesare Ponti')) ], 'Id', false);
            */
            System.debug('debug: '+ relAcc.modellodiservizio__c + ' currentUser.abi__c ' + currentUser.abi__c);
            return [SELECT id, name, CRM_CED__c,FinServ__FinancialAccount__r.CRM_DescrizioneNome__c, CRM_TipologiaScadenza__c,CRM_FormulaData__c,
                    CRM_Importo__c, FinServ__FinancialAccount__r.Name, FinServ__FinancialAccount__r.id, CRM_EsitoContatto__c,CRM_ProdottoCommDS__c,
                    CRM_CodiceProdottoElementare__c, CRM_OwnershipType__c, FinServ__FinancialAccount__r.RecordType.DeveloperName, CRM_DataScadenza__c
                    FROM FinServ__Alert__c 
                    WHERE CRM_IsVisible__c = true 
                    AND ((CRM_EsitoContatto__c != 'Prodotto venduto' AND CRM_EsitoContatto__c != 'Cliente non interessato') 
                        OR ((CRM_EsitoContatto__c = 'Prodotto venduto' OR CRM_EsitoContatto__c = 'Cliente non interessato') AND CRM_DataEsitazione__c = TODAY))
                    AND FinServ__FinancialAccount__c IN (select FinServ__FinancialAccount__c from FinServ__FinancialAccountRole__c where FinServ__RelatedAccount__c =:recordId 
                        AND (FinServ__Role__c = 'Primary Owner' or (FinServ__Role__c = 'Cointestatario' AND FinServ__FinancialAccount__r.FinServ__JointOwner__c != null AND FinServ__FinancialAccount__r.FinServ__JointOwner__r.ModelloDiServizio__c = 'Cesare Ponti')) and FinServ__Active__c = true 
                        AND ((FinServ__FinancialAccount__r.RecordType.DeveloperName != 'Credit_Line' AND FinServ__FinancialAccount__r.FinServ__Status__c = 'ATTIVO') OR (FinServ__FinancialAccount__r.RecordType.DeveloperName = 'Credit_Line' AND FinServ__FinancialAccount__r.CRM_StatoFido__c = 'ATTIVO')))];
            
            
            }
        else
        {
            return [SELECT id, name, CRM_CED__c,FinServ__FinancialAccount__r.CRM_DescrizioneNome__c, CRM_TipologiaScadenza__c,CRM_FormulaData__c,
                    CRM_Importo__c, FinServ__FinancialAccount__r.Name, FinServ__FinancialAccount__r.id, CRM_EsitoContatto__c,CRM_ProdottoCommDS__c,
                    CRM_CodiceProdottoElementare__c, CRM_OwnershipType__c, FinServ__FinancialAccount__r.RecordType.DeveloperName, CRM_DataScadenza__c
                    FROM FinServ__Alert__c 
                    WHERE CRM_IsVisible__c = true 
                    AND ((CRM_EsitoContatto__c != 'Prodotto venduto' AND CRM_EsitoContatto__c != 'Cliente non interessato') 
                        OR ((CRM_EsitoContatto__c = 'Prodotto venduto' OR CRM_EsitoContatto__c = 'Cliente non interessato') AND CRM_DataEsitazione__c = TODAY))
                    AND FinServ__FinancialAccount__c IN (select FinServ__FinancialAccount__c from FinServ__FinancialAccountRole__c where FinServ__RelatedAccount__c =:recordId 
                        AND (FinServ__Role__c = 'Primary Owner' or FinServ__Role__c = 'Cointestatario') and FinServ__Active__c = true 
                        AND ((FinServ__FinancialAccount__r.RecordType.DeveloperName != 'Credit_Line' AND FinServ__FinancialAccount__r.FinServ__Status__c = 'ATTIVO') OR (FinServ__FinancialAccount__r.RecordType.DeveloperName = 'Credit_Line' AND FinServ__FinancialAccount__r.CRM_StatoFido__c = 'ATTIVO')))];
        }
    }
}