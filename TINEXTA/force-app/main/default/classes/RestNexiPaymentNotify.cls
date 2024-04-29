@RestResource(urlMapping='/v1.0/NexiPaymentNotify')
global without sharing class RestNexiPaymentNotify {
    
    // WS Esposto per ricevere notifica pagamento per flusso ecobonus WarrantHub
    
    @HttpPost
    global static void doPost(){

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
    
        try{
            System.debug('@@@ prova 3 ' + JSON.serialize(req.params));

            Map<String,String> params = req.params;
            if(!params.containsKey('paymentid')){
                //Errore: Chiamata sconosciuta
                throw new CalloutException('Errore: Chiamata sconosciuta');
            }

            //RESULT transazione può essere:
            /*  
            *   APPROVED = transazione autorizzata
            *   NOT APPROVED = transazione negata
            *   CAPTURED = transazione confermata
            *   CANCELED = il cardholder ha annullato la transazione.
            */

            Opportunity opp = [SELECT Id, Name, WRT_Id_pagamento_Nexi__c, StageName, Numero_offerta_Infostore__c FROM Opportunity WHERE WRT_Id_pagamento_Nexi__c =: params.get('paymentid') ];
            System.debug('@@@ opp ' + opp);

            WRT_Transazione__c transazione = new WRT_Transazione__c(
                PaymentId__c = params.get('paymentid'),
                Result__c = params.get('result'),
                Nome_del_Cliente__c = params.get('customfield') != null ? params.get('customfield').split('_')[0].split('\\|')[0] : null,
                Cognome_del_Cliente__c = params.get('customfield') != null ? params.get('customfield').split('_')[0].split('\\|')[1] : null,
                Email_del_Cliente__c = params.get('customfield') != null ? params.get('customfield').split('_')[1] : null,
                Opportunit__c = opp.Id
            );

            insert transazione;

            if(params.get('result') == 'CAPTURED' /*|| params.get('result') == 'APPROVED'*/){
                opp.StageName = 'Chiuse/Conseguite';
                opp.Probability = 100;
                opp.Stato_pagamento_dellopportunita_vinta__c = 'Pagato totalmente';
                opp.WRT_StatoFatturazioneOpportunita__c = 'Fatturata completamente';
                opp.Numero_offerta_Infostore__c = '0';

                update opp;
            }

        } catch (Exception e){
            System.debug('@@@ error ' + e.getMessage());
            Log__c l = new Log__c(
                Source__c = 'ErrorEcobonus',
                InputPayload__c = e.getStackTraceString() + ' -- ' + e.getMessage() + ' -- ' + e.getLineNumber()
            );
            insert l;
        }
    }
}