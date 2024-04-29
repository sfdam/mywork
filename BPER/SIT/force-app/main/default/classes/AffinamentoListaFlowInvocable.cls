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

        List<FlowOutputs> result = new List<FlowOutputs>();
        try{
            if (paramenterList[0].recordId !=null){               
                campaignMemberList = [SELECT Id, Status__c
                FROM campaignMember__c
                WHERE
                Campaign__c =:paramenterList[0].recordId
                LIMIT 45000];
       		}
            
            for(campaignMember__c cmg : campaignMemberList){
                if(cmg.Status__c=='Eliminato')
                    numClientiAffinati++;  
            }
            numClientiInCampagna = campaignMemberList.size();
            maxNumClientAff = Math.round((paramenterList[0].percAffinamento/100)*(numClientiInCampagna));
			
            if(maxNumClientAff - numClientiAffinati > 1)
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