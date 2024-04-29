global with sharing class WRT_BatchInterconnesioneTardiva implements Database.Batchable<sObject>
{
    global Database.queryLocator start(Database.BatchableContext bc)
    {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('WorkOrder').getDescribe().fields.getMap();
        list<string> list_field = new list<string>(fieldMap.keyset());
    
    
        string qrSelect = 'select '+string.join(list_field , ',');//SELECT con tutti i campi dell'oggetto
        string qrFrom = ' from WorkOrder';//FROM oggetto
        string qrWhere = ' where WRT_Check_Interconnessione__c > 0'; //WHERE filtri query
        string qrOrder = ' order by '; //ORDER BY ordinamento risultati query
        
        //creo una variabile di tipo "Tipo lista<Oggetto>"
        System.Type listType = System.Type.forName('List<WorkOrder>');
        //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
        List<SObject> result = (List<SObject>)listType.newInstance();
    
    
        //aggiungere where/order se correttamente valorizzati nelle variabili
        //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
        return database.getQueryLocator(qrSelect + qrFrom + qrWhere /*+ qrOrder*/);
    }

    global void execute (Database.BatchableContext BC, List<workorder> woList)
    {

    }
    
    global void finish(Database.BatchableContext BC)
    {

    }
}