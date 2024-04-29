public with sharing class ApprovazioniController 
{
    @AuraEnabled//(cacheable=true)
    public static List<SObject> getApprovazioni(Id userID)
    {
        system.debug('user '+userID);
        /**
            * @description: il metodo esegue una query includendo in automatico tutti i campi dell'oggetto
            * @param objectApiName: nome API oggetto su cui eseguire la query
            * @return: lista di risultati di tipo "sObject" generico. È possibile fare il cast del risulta in una lista dell'oggetto specifico
            */ 
        //reperisco tutti i campi dell'oggetto
        Map<String, Schema.SObjectType> schemaMap1 = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap1 = schemaMap1.get('ProcessInstanceWorkitem').getDescribe().fields.getMap();
        list<string> list_field1 = new list<string>(fieldMap1.keyset());
        set<id> idSet = new set<id>();
    
        string qrSelect1 = 'select '+string.join(list_field1 , ',')+ ', ProcessInstance.TargetObjectId';//SELECT con tutti i campi dell'oggetto
        string qrFrom1 = ' from ProcessInstanceWorkitem';//FROM oggetto
        string qrWhere1 = ' where ActorId = \''+ userID + '\''; //WHERE filtri query
        string qrOrder1 = ' order by '; //ORDER BY ordinamento risultati query
        
        //creo una variabile di tipo "Tipo lista<Oggetto>"
        System.Type listType1 = System.Type.forName('List<ProcessInstanceWorkitem>');
        //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
        List<ProcessInstanceWorkitem> result1 = (List<ProcessInstanceWorkitem>)listType1.newInstance();
    
    
        //aggiungere where/order se correttamente valorizzati nelle variabili
        //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
        for(ProcessInstanceWorkitem obj : database.query(qrSelect1 + qrFrom1 + qrWhere1 /*+ qrOrder*/))
        {
            system.debug('id obj '+ obj.ProcessInstance.TargetObjectId);
            idSet.add(obj.ProcessInstance.TargetObjectId);
        }

        //reperisco tutti i campi dell'oggettoö
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Approvazioni__c').getDescribe().fields.getMap();
        list<string> list_field = new list<string>(fieldMap.keyset());
        
    
        string qrSelect = 'select '+string.join(list_field , ',')+ ', Condizione__r.id, Condizione_Opzionale__r.id, Pagamento__r.id, Quote__r.id, Quote_Line__r.id, Finanziamento__r.id,' +
                                                                        ' Quote__r.SBQQ__Account__c, Quote__r.SBQQ__Account__r.Name, Quote__r.Name, Quote_Line__r.Prodotto_Progetto__c' +
                                                                        ', Quote_Line__r.Name, Quote_Line__r.WRT_esercizio__c, Condizione__r.Name, Condizione_Opzionale__r.Name'+
                                                                        ', Pagamento__r.Name, Finanziamento__r.Name, Condizione__r.Min_garantito_WarrantCPQ__c, Quote__r.Foro_di_Competenza__c'+
                                                                        ', Quote__r.Foro_2__c, Quote_Line__r.SBQQ__Product__r.Name, Condizione__r.WRT_Tipologia_Finanziamento_FORM__c'+
                                                                        ', Pagamento__r.Condizione_WarrantCPQ__r.WRT_Tipologia_Finanziamento_FORM__c, Condizione_Opzionale__r.Tipologia_Finanziamento_WarrantCPQ__c';//SELECT con tutti i campi dell'oggetto
        string qrFrom = ' from Approvazioni__c';//FROM oggetto
        string qrWhere = ' where Approval_Step__c = \'In approvazione\' and (Quote__r.Id IN :idSet OR Quote_line__r.id IN :idSet)'; //WHERE filtri query
        string qrOrder = ' order by Createddate desc'; //ORDER BY ordinamento risultati query
        
        //creo una variabile di tipo "Tipo lista<Oggetto>"
        System.Type listType = System.Type.forName('List<Approvazioni__c>');
        //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
        List<SObject> result = (List<SObject>)listType.newInstance();
    
    
        //aggiungere where/order se correttamente valorizzati nelle variabili
        //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
        result = database.query(qrSelect + qrFrom + qrWhere + qrOrder);

        system.debug(result);
    
        return result;
    }

    @AuraEnabled
    public static string approvazioneRifiuto(List<SObject> approvList, string approvaRifiuta, string commento)
    {
        string result = '';
        set<id> sobjectId = new set<id>();
        map<id,Approvazioni__c> mapApp = new map<id,Approvazioni__c>();
        Approval.ProcessWorkitemRequest[] approvalRequests = new Approval.ProcessWorkitemRequest[]{};
        system.debug('approvList ' + approvList);
        for(Approvazioni__c app : (list<Approvazioni__c>) approvList)
        {
            sobjectId.add(app.Quote__r.Id);
            if (app.Quote_line__r.id != null) sobjectId.add(app.Quote_line__r.id);
            app.WRT_Commento_Richiesta_Approvazione__c = commento;
        }
        system.debug('sobjectid '+ sobjectId);
        for(approvazioni__c app : [select id, WRT_Commento_Richiesta_Approvazione__c 
                                    from approvazioni__c 
                                    where Approval_Step__c = 'In approvazione' and 
                                    (Quote__r.Id IN :sobjectId OR Quote_line__r.id IN :sobjectId)])
        {
            app.WRT_Commento_Richiesta_Approvazione__c = commento;
            mapApp.put(app.id, app);
        }
        //devo raggruppare per stessa approvazione i vari record

        /**
            * @description: il metodo esegue una query includendo in automatico tutti i campi dell'oggetto
            * @param objectApiName: nome API oggetto su cui eseguire la query
            * @return: lista di risultati di tipo "sObject" generico. È possibile fare il cast del risulta in una lista dell'oggetto specifico
            */ 
        //reperisco tutti i campi dell'oggetto
        Map<String, Schema.SObjectType> schemaMap1 = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap1 = schemaMap1.get('ProcessInstanceWorkitem').getDescribe().fields.getMap();
        list<string> list_field1 = new list<string>(fieldMap1.keyset());
        set<id> idSet = new set<id>();
    
        string qrSelect1 = 'select '+string.join(list_field1 , ',')+ ', ProcessInstance.TargetObjectId';//SELECT con tutti i campi dell'oggetto
        string qrFrom1 = ' from ProcessInstanceWorkitem';//FROM oggetto
        string qrWhere1 = ' where ProcessInstance.TargetObjectId in :sobjectId'; //WHERE filtri query
        string qrOrder1 = ' order by '; //ORDER BY ordinamento risultati query
        
        //creo una variabile di tipo "Tipo lista<Oggetto>"
        System.Type listType1 = System.Type.forName('List<ProcessInstanceWorkitem>');
        //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
        List<ProcessInstanceWorkitem> result1 = (List<ProcessInstanceWorkitem>)listType1.newInstance();
    
    
        //aggiungere where/order se correttamente valorizzati nelle variabili
        //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
        for(ProcessInstanceWorkitem obj : database.query(qrSelect1 + qrFrom1 + qrWhere1 /*+ qrOrder*/))
        {
            Approval.ProcessWorkitemRequest app = new Approval.ProcessWorkitemRequest();
            app.setAction(approvaRifiuta);
            app.setWorkitemId(obj.Id);
            app.setComments(commento);
            approvalRequests.add(app);
        }

        try 
        {
            Approval.ProcessResult[] results =  Approval.process(approvalRequests);
        
            for(Approval.ProcessResult res : results)
            {
                system.debug('isSuccess '+ res.isSuccess());
                if(res.isSuccess())
                {
                    update mapApp.values();
                    if(approvaRifiuta == 'Approve')
                    {
                        result = 'Approvata';
                    }
                    else if(approvaRifiuta == 'Reject')
                    {
                        result = 'Rifiutata';
                    }
                }
                else
                {
                    return result = 'Errore';
                }
            }
        } 
        catch (Exception e) 
        {
            system.debug(e);
            result = e.getMessage() + ' '+e.getLineNumber();
        }
        return result;
    }
}