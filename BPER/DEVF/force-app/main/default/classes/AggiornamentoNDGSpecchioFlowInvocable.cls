public class AggiornamentoNDGSpecchioFlowInvocable {
	
    public class FlowInputs {
        @InvocableVariable public String AccountIdBCP;
        @InvocableVariable public String AccountIdBPER;
        @InvocableVariable public String ndgBCP;
        @InvocableVariable public String ndgBPER;
        @InvocableVariable public String cedFil;
        @InvocableVariable public String certificationName;
        @InvocableVariable public Boolean disableLog;
        @InvocableVariable public String apiRequestName;
    }

    @InvocableMethod
    public static FlowOutputs[] aggiornaNDGSpecchio(List<FlowInputs> paramenterList){
        System.debug(LoggingLevel.DEBUG,'*** START -- aggiornaEsitazione Method ***');
        System.debug(LoggingLevel.DEBUG,'### AccountIdBCP: '+paramenterList[0].AccountIdBCP);
        System.debug(LoggingLevel.DEBUG,'### AccountIdBPER: '+paramenterList[0].AccountIdBPER);
        System.debug(LoggingLevel.DEBUG,'### certificationName: '+paramenterList[0].certificationName);
        System.debug(LoggingLevel.DEBUG,'### disableLog: '+paramenterList[0].disableLog);
		Boolean esito = false;
        String ndgNew;
        List<FlowOutputs> result = new List<FlowOutputs>();
        FlowOutputs out = new FlowOutputs();
        
        Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String certificationName = isSandbox ? 'salesforcetestclient2024' : 'salesforceprodclient2024';
        ndgNew = AggiornaNDGSpecchioInvocaWS.makeResponse('GestioneSpecchioV1', paramenterList[0].AccountIdBCP, paramenterList[0].AccountIdBPER, certificationName, false, null, paramenterList[0].ndgBCP, paramenterList[0].ndgBPER, paramenterList[0].cedFil);
       	if(ndgNew!= null)
        	out.response = true;
        else
            out.response = false;
        
        out.newAccountId = ndgNew;
        result.add(out);

        System.debug(LoggingLevel.DEBUG,'### result: '+result);
        System.debug(LoggingLevel.DEBUG,'*** END -- aggiornaEsitazione Method ***');
        return result;
    }

    public class FlowOutputs{
        @InvocableVariable public Boolean response;
        @InvocableVariable public String newAccountId;
    }

}