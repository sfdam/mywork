/**
 * @description       : 
 * @author            : simone.viglianti@tengroup.it
 * @group             : 
 * @last modified on  : 11-19-2021
 * @last modified by  : simone.viglianti@tengroup.it
**/
public with sharing class AggiornamentoEsitazioneFlowInvocable {

    public class FlowInputs {
        @InvocableVariable public String stato;
        @InvocableVariable public String note;
        @InvocableVariable public String recordId;
        @InvocableVariable public String certificationName;
        @InvocableVariable public Boolean disableLog;
        @InvocableVariable public String apiRequestName;
        @InvocableVariable public String motivoEliminazioneFlow;
        @InvocableVariable public Boolean affinamentoFlow = false;
        @InvocableVariable public Boolean ingaggioAgenteFlow = false;
    }

    /**
    * @description Classe per comunicare l'aggiornamento dell'esitazione tramite ws
    * @author simone.viglianti@tengroup.it | 10-15-2021 
    * @param paramenterList 
    * @return FlowOutputs[] 
    **/
    @InvocableMethod
    public static FlowOutputs[] aggiornaEsitazione(List<FlowInputs> paramenterList){
        System.debug(LoggingLevel.DEBUG,'*** START -- aggiornaEsitazione Method ***');
        System.debug(LoggingLevel.DEBUG,'### Stato: '+paramenterList[0].stato);
        System.debug(LoggingLevel.DEBUG,'### Note: '+paramenterList[0].note);
        System.debug(LoggingLevel.DEBUG,'### recordId: '+paramenterList[0].recordId);
        System.debug(LoggingLevel.DEBUG,'### certificationName: '+paramenterList[0].certificationName);
        System.debug(LoggingLevel.DEBUG,'### disableLog: '+paramenterList[0].disableLog);
        System.debug(LoggingLevel.DEBUG,'### apiRequestName: '+paramenterList[0].apiRequestName);
        System.debug(LoggingLevel.DEBUG,'### ingaggioAgenteFlow: '+paramenterList[0].ingaggioAgenteFlow);

        Boolean esito = false;

        List<FlowOutputs> result = new List<FlowOutputs>();
        try{
            if(paramenterList[0].ingaggioAgenteFlow){
                List<Account> AccountList = [SELECT FinServ__BankNumber__c, CRM_NDG__c,ModelloDiServizio__c,PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c,PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName,
                                             PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName,PTF_Portafoglio__r.Name
                                                          FROM Account 
                                                          WHERE Id = :paramenterList[0].recordId];
    
                System.debug(LoggingLevel.DEBUG,'### AccountList: '+AccountList);
                esito = AggiornamentoEsitazioneInvocaWS.makeResponseIngaggioAgente(paramenterList[0].apiRequestName,AccountList.get(0), paramenterList[0].stato, paramenterList[0].note, paramenterList[0].certificationName, paramenterList[0].disableLog, null, false, false,paramenterList[0].motivoEliminazioneFlow);
                         
            }else{
                List<CampaignMember> campaignMemberList = [SELECT Contact.Account.PTF_ABICED__c, CRM_AccNDG__c, Campaign.Codice_Campagna__c,
                                                                  Campaign.Codice_Azione_Utente__c, Campaign.CRM_EndDateFormula__c, Motivo_Affinamento__c, 
                                                                  Name, Status, CRM_Esito__c, description, CRM_Assegnatario__r.FederationIdentifier, Campaign.RecordTypeId, 
                                                                  CRM_Assegnatario__r.LastName, CRM_Assegnatario__r.FirstName, CRM_AccMDS__c, CRM_AccPTF__c,Campaign.Status,
                                                                   Campaign.Name, Campaign.CRM_TipologiaCampagna__c,Campaign.CRM_SottotipologiaCampagna__c, Campaign.CRM_Channel__c, 
                                                                   Campaign.CRM_Progressivo__c,Campaign.Data_FineFormula__c, Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.Name,  
                                                                   Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_RegistrationNumber__c,Campaign.CRM_OwnerSystem__c, 
                                                                   Campaign.CRM_TipologiaCampagnaStep__c,Campaign.CRM_StatoFormula__c,Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.LastName,
                                                                   Contact.Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.FirstName,CRM_NominativoUtente__c, CRM_DataEsclusione__c,CRM_NoteAffinamento__c
                                                          FROM CampaignMember 
                                                          WHERE Id = :paramenterList[0].recordId];
    
                System.debug(LoggingLevel.DEBUG,'### campaignMember: '+campaignMemberList);
                System.debug(LoggingLevel.DEBUG,'### campaignMember: '+paramenterList[0].motivoEliminazioneFlow);
                System.debug(LoggingLevel.DEBUG,'### campaignMember: '+String.isNotBlank(paramenterList[0].motivoEliminazioneFlow) + String.isEmpty(paramenterList[0].motivoEliminazioneFlow));
                if(paramenterList[0].affinamentoFlow || String.isNotBlank(paramenterList[0].motivoEliminazioneFlow)){
                    for(CampaignMember cm : campaignMemberList){
                        cm.Motivo_Affinamento__c = paramenterList[0].motivoEliminazioneFlow;
                    }
                    esito = AggiornamentoEsitazioneInvocaWS.makeResponse(paramenterList[0].apiRequestName,campaignMemberList, paramenterList[0].stato, paramenterList[0].note, paramenterList[0].certificationName, paramenterList[0].disableLog, null, paramenterList[0].affinamentoFlow, false);
                }else
                    esito = AggiornamentoEsitazioneInvocaWS.makeResponse(paramenterList[0].apiRequestName,campaignMemberList, paramenterList[0].stato, paramenterList[0].note, paramenterList[0].certificationName, paramenterList[0].disableLog, null, paramenterList[0].affinamentoFlow, false);
                         
            }

            FlowOutputs out = new FlowOutputs();
            out.response = esito;
            result.add(out);
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'### AggiornamentoEsistazioneFlowInvocable.aggiornaEsitazione exception: '+e.getMessage()+' al line: '+e.getLineNumber());
        }
        System.debug(LoggingLevel.DEBUG,'### result: '+result);
        System.debug(LoggingLevel.DEBUG,'*** END -- aggiornaEsitazione Method ***');
        return result;
    }

    public class FlowOutputs{
        @InvocableVariable public Boolean response;
    }
}