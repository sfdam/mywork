trigger AsyncLog on AsyncLog__e (after insert) {

    for (AsyncLog__e event : Trigger.New) {
        Log__c l = new Log__c(
            Account__c = event.Account__c,
            ClientIP__c = event.ClientIP__c,
            CodiceApplicazione__c = event.CodiceApplicazione__c,
            CodiceCliente__c = event.CodiceCliente__c,
            CodiceFunzione__c = event.CodiceFunzione__c,
            CodiceOperatore__c = event.CodiceOperatore__c,
            CodiceRapporto__c = event.CodiceRapporto__c,
            Contact__c = event.Contact__c,
            ErorrMessage__c = event.ErrorMessage__c,
            InputPayload__c = event.InputPayload__c,
            NDG__c = event.NDG__c,
            Opportunity__c = event.Opportunity__c,
            OUNum__c = event.OUNum__c,
            OutputPayload__c = event.OutputPayload__c,
            Query__c = event.Query__c,
            Source__c = event.Source__c,
            Tipo__c	= event.Tipo__c,
            TipoCodiceCliente__c = event.TipoCodiceCliente__c
        );
        insert l;
    }  
}