public with sharing class CRM_AffinamentoRollbackActionCtrl {
    

    @AuraEnabled
    public static boolean setRollback(String recordIdCM){
        System.debug('setRollback Start: '+recordIdCM);
        try{

            List<CampaignMember> cm = [SELECT Contact.Account.PTF_ABICED__c, CRM_AccNDG__c, Campaign.Codice_Campagna__c,
            Campaign.Codice_Azione_Utente__c, Campaign.CRM_EndDateFormula__c, Motivo_Affinamento__c, 
            Name, Status, CRM_Esito__c, description, CRM_Assegnatario__r.FederationIdentifier, Campaign.RecordTypeId, 
            CRM_Assegnatario__r.LastName, CRM_Assegnatario__r.FirstName, CRM_AccMDS__c, CRM_AccPTF__c,Campaign.Status,
             Campaign.Name, Campaign.CRM_TipologiaCampagna__c,Campaign.CRM_SottotipologiaCampagna__c, Campaign.CRM_Channel__c, 
             Campaign.CRM_Progressivo__c,Campaign.Data_FineFormula__c, Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.Name,  
             Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c,Campaign.CRM_OwnerSystem__c, 
             Campaign.CRM_TipologiaCampagnaStep__c,Campaign.CRM_StatoFormula__c,Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName,
             Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName,CRM_NominativoUtente__c, CRM_DataEsclusione__c,CRM_NoteAffinamento__c,
             campaign.CRM_PrevistoAffinamento__c, Campaign.CRM_DataFineAffinamento__c,CRM_Note__c
            FROM CampaignMember WHERE id=:recordIdCM];

            TrackingHistory__c thItem = [SELECT id, NewValue__c, OldValue__c FROM TrackingHistory__c WHERE ParentObject__c = :recordIdCM order by createdDate desc LIMIT 1];
            
            if(cm.get(0).campaign.CRM_PrevistoAffinamento__c && Date.today()<=cm.get(0).Campaign.CRM_DataFineAffinamento__c){
                if(thItem!=null && thItem.OldValue__c !=null ){
                    
                    List<String> listStatus = thItem.OldValue__c.Split(';');
                    System.debug('Old Status: '+listStatus);
                    cm.get(0).Status = 'Da contattare';
                }else{
                    cm.get(0).Status = 'Da contattare';
                }                   
                
                cm.get(0).Motivo_Affinamento__c ='';
                cm.get(0).CRM_NominativoUtente__c='';
                cm.get(0).CRM_NoteAffinamento__c='';
                cm.get(0).CRM_Note__c='';

                Boolean esito = true;//  AggiornamentoEsitazioneInvocaWS.makeResponse('salvaEsitazioneAzioniNec',cm, cm.get(0).Status, '', 'salesforcetestclient2024',false, null, false, true);
                System.debug('SV setCampaignMember cmList: ' + cm);
                if(esito){
                    update cm.get(0);
                }

                return esito;
  
            }else{
                return false;
                
            }
            

        }catch (Exception ex){
            System.debug('Exception: '+ex.getMessage());
            return false;
        }
        
    }
}