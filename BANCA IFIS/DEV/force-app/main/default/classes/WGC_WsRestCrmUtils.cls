public class WGC_WsRestCrmUtils {

    // METHOD TO ADD PARAMETERS TO INPUT PAYLOAD FOR "INVIO NV"
    public static WsRestCrm.NvAggiornamentoInnescaVenditaInput addNewParameters(WsRestCrm.NvAggiornamentoInnescaVenditaInput input, Id oppId) {
        String flagConsolidamento = 'N';
        // String flagRinnovo = 'N';

        try {
            List<Opportunity> opp = [SELECT Id, WGC_FlagConsolidamento__c, WGC_FlagRinnovo__c FROM Opportunity WHERE Id = :oppId];

            if (opp.size() > 0) {
                flagConsolidamento = (opp[0].WGC_FlagConsolidamento__c == true ? 'S' : 'N');
                // flagRinnovo = (opp[0].WGC_FlagRinnovo__c == true ? 'S' : 'N');
            }
        } catch (Exception e) {
            System.debug('@@@@ TEN - WGC_WsRestCrmUtils.exception: ' + e.getMessage());
        }

        input.flagConsolidamento = flagConsolidamento;
        // input.flagRinnovo = flagRinnovo;

        return input;
    }


}