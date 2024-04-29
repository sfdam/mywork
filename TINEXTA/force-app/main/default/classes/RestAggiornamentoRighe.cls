@RestResource(urlMapping='/v1.0/AggiornamentoRigheOfferta')
global without sharing class RestAggiornamentoRighe {
    
    @HttpPost
    global static ResponseWrapper doPost(List<SObject> records){

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        ObjectResponseWrapper response = new ObjectResponseWrapper();
        String recordIDLog = '';
        try{

            if(records.isEmpty())
                throw new CalloutException('ERRORE - Lista vuota');
            if(records.size() >= 200)
                throw new CalloutException('ERRORE - Lista con troppi record');

            List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            List<SBQQ__QuoteLine__c> quotelineList = new List<SBQQ__QuoteLine__c>();
            List<Finanziamenti__c> finList = new List<Finanziamenti__c>();
            List<Condizioni__c> condizioniList = new List<Condizioni__c>();
            List<Condizione_Opzionale__c> condizioniOpzList = new List<Condizione_Opzionale__c>();
            List<Pagamenti__c> pagList = new List<Pagamenti__c>();

            for(SObject sobj : records){
                System.debug('@@@ sobj ' + JSON.serialize(sobj));
                System.debug('@@@ string ' + String.valueOf(sobj.getSObjectType()));
                if(String.valueOf(sobj.getSObjectType()) == 'SBQQ__Quote__c'){
                    quoteList.add((SBQQ__Quote__c)sobj);
                }
                if(String.valueOf(sobj.getSObjectType()) == 'SBQQ__QuoteLine__c'){
                    quotelineList.add((SBQQ__QuoteLine__c)sobj);
                }
                if(String.valueOf(sobj.getSObjectType()) == 'Finanziamenti__c'){
                    finList.add((Finanziamenti__c)sobj);
                }
                if(String.valueOf(sobj.getSObjectType()) == 'Condizioni__c'){
                    condizioniList.add((Condizioni__c)sobj);
                }
                if(String.valueOf(sobj.getSObjectType()) == 'Condizione_Opzionale__c'){
                    condizioniOpzList.add((Condizione_Opzionale__c)sobj);
                }
                if(String.valueOf(sobj.getSObjectType()) == 'Pagamenti__c'){
                    pagList.add((Pagamenti__c)sobj);
                }
            }

            Id recordId;
            recordIDLog = recordId;
            if(!quoteList.isEmpty())
                update quoteList;
            if(!quotelinelist.isEmpty())
                recordId = quotelineList[0].Id;
                update quotelineList;
            if(!finList.isEmpty()){
                if(recordId == null) recordId = [SELECT Id, Quote_Line__c FROM Finanziamenti__c WHERE Id =: finList[0].Id ].Quote_Line__c;
                update finList;
            }
            if(!condizioniList.isEmpty()){
                update condizioniList;
            }
            if(!condizioniOpzList.isEmpty()){
                if(recordId == null) recordId = [SELECT Id, CondizionePadre_WarrantCPQ__r.Quote_Line__c FROM Condizione_Opzionale__c WHERE Id =: condizioniOpzList[0].Id ].CondizionePadre_WarrantCPQ__r.Quote_Line__c;
                update condizioniOpzList;
            }

            // if(!finList.isEmpty())
            InvocableCalcoloCondizione.ActionRequest action = new InvocableCalcoloCondizione.ActionRequest();
            action.quoteline = recordId;
            System.debug('@@@ action ' + recordId);
            InvocableCalcoloCondizione.CalcoloCondizione(new List<InvocableCalcoloCondizione.ActionRequest>{action});

            if(!pagList.isEmpty()){
                if(recordId == null) recordId = [SELECT Id, Condizione_WarrantCPQ__r.Quote_Line__c FROM Pagamenti__c WHERE Id =: pagList[0].Id ].Condizione_WarrantCPQ__r.Quote_Line__c;
                update pagList;
            }
            
            // update records;
            response.data = new Map<String,Object>();
            response.data.put('records', records);

            System.debug('@@@ Limits heap ' + Limits.getHeapSize());
            System.debug('@@@ Limits cpu ' + Limits.getCpuTime());

        } catch(CalloutException e){
            response.message = e.getMessage();
            response.success = false;
            System.debug('@@@ error ' + e.getMessage() + ' - ' + e.getLineNumber());
        } catch(Exception e){
            response.message = e.getMessage() + ' -- ' + e.getStackTraceString();
            response.success = false;
            System.debug('@@@ error exc ' + e.getMessage() + ' - ' + e.getLineNumber());
        }
        String jsonString = String.valueOf(records.toString());
        insert new Log__c(
            Success__c = response.success,
            Societa__c = 'WarrantHub',
            Source__c = 'Infostore',
            Nome_Classe__c = 'RestAggiornamentoRighe',
            ID_Record__c = recordIDLog,
            ErrorMessage__c = String.valueOf(response.message),
            InputPayload__c = jsonString,
            OutputPayload__c = String.valueOf(JSON.serializePretty(response,true))
        );

        return response;
    }
}