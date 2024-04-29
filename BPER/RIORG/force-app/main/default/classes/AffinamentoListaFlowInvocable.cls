public  with sharing class AffinamentoListaFlowInvocable {
    
    public class FlowInputs {
        @InvocableVariable public String recordId;
        @InvocableVariable public Decimal percAffinamento;
    }

    /**
    * @description Classe per comunicare l'aggiornamento dell'esitazione tramite ws
    * @author simone.viglianti@tengroup.it | 10-15-2021 
    * @param paramenterList 
    * @return FlowOutputs[] 
    **/
    @InvocableMethod
    public static FlowOutputs[] aggiornaEsitazione(List<FlowInputs> paramenterList){
        System.debug(LoggingLevel.DEBUG,'*** START -- AffinamentoListaFlowInvocable Method ***');
        System.debug(LoggingLevel.DEBUG,'### recordId: '+paramenterList[0].recordId);
        System.debug(LoggingLevel.DEBUG,'### percAffinamento: '+paramenterList[0].percAffinamento);
        
        List<campaignMember__c> campaignMemberList = new List<campaignMember__c>();
        Integer numClientiInCampagna = 0;
        Integer numClientiAffinati = 0;
        Integer maxNumClientAff = 0;
        Boolean esito = false;
		Contact userMap = [SELECT id, PTF_ReferenteElegibile__c, PTF_RegistrationNumber__c, Name, PTF_IdCED__c, AccountId, PTF_User__c, PTF_ProfiloLDAP__c, PTF_IsVice__c, PTF_Ruolo__c, PTF_TipologiaRuolo__r.Name,PTF_User__r.CRM_HasLab__c, PTF_User__r.Profilo__c,PTF_User__r.PTF_RuoloLDAP__c FROM Contact WHERE PTF_User__c =: UserInfo.getUserId()];
            
        List<FlowOutputs> result = new List<FlowOutputs>();
        try{
            if (paramenterList[0].recordId !=null){               
                String query = 'SELECT Id, Status__c ' +
                ' FROM campaignMember__c ' +
                ' WHERE ' + 
                ' Campaign__c = \'' + paramenterList[0].recordId + '\' ';

                if(userMap.PTF_User__r.Profilo__c.contains('NEC_F') ||
                (userMap.PTF_User__r.Profilo__c == 'CRM - Utente di Rete' && userMap.PTF_ReferenteElegibile__c)){
                    query += ' AND CRM_Account__r.PTF_Filiale__c = \'' + userMap.AccountId + '\'';
                }
                if(userMap.PTF_IdCED__c =='6116' || userMap.PTF_IdCED__c =='21025'){
                     query += ' AND CRM_Account__r.ModelloDiServizio__c =\'Key Client Privati\' ';
                }
                if(userMap.PTF_User__r.PTF_RuoloLDAP__c =='069'){
                    String userMapUserId = userMap.PTF_User__c;
                     query += ' AND  PTF_Portafoglio__r.Referente_User__c=:userMapUserId';
                }
                
                query += ' LIMIT 45000 ';
                campaignMemberList = Database.query(query);
       		}
            
            for(campaignMember__c cmg : campaignMemberList){
                if(cmg.Status__c=='Eliminato')
                    numClientiAffinati++;  
            }
            numClientiInCampagna = campaignMemberList.size();
            maxNumClientAff = Integer.valueOf(((paramenterList[0].percAffinamento/100)*(numClientiInCampagna)).round(System.RoundingMode.UP));
                             
			
            if(maxNumClientAff - numClientiAffinati > 0)
                esito = true;
            else
                esito = false;
            
            System.debug(LoggingLevel.DEBUG,'### campaignMember: '+campaignMemberList);
            System.debug(LoggingLevel.DEBUG,'### esito: '+esito);
            System.debug(LoggingLevel.DEBUG,'### maxNumClientAff: '+maxNumClientAff);
            System.debug(LoggingLevel.DEBUG,'### numClientiAffinati: '+numClientiAffinati);
            
            FlowOutputs out = new FlowOutputs();
            out.esito = esito;
            out.maxNumClientAff = maxNumClientAff;
            
            result.add(out);

        }catch(Exception e){
            System.debug(LoggingLevel.ERROR,'### AffinamentoListaFlowInvocable: '+e.getMessage()+' al line: '+e.getLineNumber());
        }
        System.debug(LoggingLevel.DEBUG,'### result: '+result);
        System.debug(LoggingLevel.DEBUG,'*** END -- AffinamentoListaFlowInvocable Method ***');
        return result;
    }

    public class FlowOutputs{
        @InvocableVariable public Boolean esito;
        @InvocableVariable public Integer maxNumClientAff;
    }

}