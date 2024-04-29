@RestResource(urlMapping='/v1.0/InserimentoPagamenti')
global without sharing class RestInserimentoPagamenti {


    @HttpPost
    global static ResponseWrapper doPost(List<SObject> Pagamenti){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        ObjectResponseWrapper response = new ObjectResponseWrapper();

        Savepoint sp = Database.SetSavepoint();

        try{

            SBQQ.TriggerControl.disable();
            Boolean checkCondizioni = false;
            Boolean checkQuoteLine = false;
            List<Pagamenti__c> pagamentiList = (List<Pagamenti__c>) pagamenti; 

            for(Pagamenti__c p : pagamentiList){
                if(String.isBlank(p.Condizione_WarrantCPQ__c)){
                    checkCondizioni = true;
                    break;
                } else if(String.isBlank(p.Quote_Line__c)){
                    checkQuoteLine = true;
                    break;
                }
            }

            if(checkCondizioni){
                response.success = false;
                response.message = 'Campo obbligatorio Condizioni_WarrantCPQ__c mancante in uno o più record';
            }

            if(checkQuoteLine){
                response.success = false;
                response.message = 'Campo obbligatorio Quote_Line__c mancante in uno o più record';
            }

            if(checkCondizioni || checkQuoteLine){
                return response;
            }

            insert pagamentiList;
            SBQQ.TriggerControl.enable();

            update pagamentiList[pagamentiList.size()-1];

            response.data = new Map<String,Object>{'Pagamenti' => pagamentiList};

        } catch(Exception e){
            response.message = e.getMessage() + ' -- ' + e.getStackTraceString();
            response.success = false;
            System.debug('@@@ errore ' + e.getMessage() + ' -- ' + e.getStackTraceString());
            Database.rollback(sp);
        }

        String jsonString = (Pagamenti != null)? String.valueOf(Pagamenti.toString()) : '';
        insert new Log__c(
            Success__c = response.success,
            Societa__c = 'WarrantHub',
            Source__c = 'Infostore',
            Nome_Classe__c = 'RestInserimentoPagamenti',
            //ID_Record__c = recordIDLog,
            ErrorMessage__c = String.valueOf(response.message),
            InputPayload__c = jsonString,
            OutputPayload__c = String.valueOf(JSON.serializePretty(response,true))
        );

        return response;
    } 
}