public class Invocable_TXTReminderOpportunity {

    
    /**
        * @description: il metodo esegue una query includendo in automatico tutti i campi dell'oggetto
        * @param 'Opportunity': nome API oggetto su cui eseguire la query
        * @return: lista di risultati di tipo "sObject" generico. È possibile fare il cast del risulta in una lista dell'oggetto specifico
        */ 
        @InvocableMethod(label='RecuperaOpportunityReminderTXT')
        public static List<List<User>> Invocable_TXTReminderOpportunity(List<string> Reminder) {
    
        //reperisco tutti i campi dell'oggetto
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('Opportunity').getDescribe().fields.getMap();
        list<string> list_field = new list<string>(fieldMap.keyset());
    
    
        string qrSelect = 'select '+string.join(list_field , ',')+', owner.email, owner.firstname, owner.Societa__c';//SELECT con tutti i campi dell'oggetto
        string qrFrom = ' from '+'Opportunity';//FROM oggetto
        string qrWhere = ' where '; //WHERE filtri query
        string qrOrder = ' order by '; //ORDER BY ordinamento risultati query
        
        //creo una variabile di tipo "Tipo lista<Oggetto>"
        System.Type listType = System.Type.forName('List<'+'Opportunity'+'>');
        //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
        List<SObject> result = (List<SObject>)listType.newInstance();

        if(Reminder[0] == 'InScadenza'){
            qrWhere = ' WHERE isClosed = false AND TXT_Opportunita_in_scadenza__c = true';
        }
        if(Reminder[0] == 'Scadute') {
            qrWhere = ' WHERE isClosed = false AND TXT_Opportunita_scaduta__c = true';
        }
        if(Reminder[0] == 'NonAggiornate'){ 
            qrWhere = ' WHERE isClosed = false AND TXT_Opportunita_non_aggiornata__c = true';
        }
    
        //aggiungere where/order se correttamente valorizzati nelle variabili
        //---(la lista funziona anche con un solo record: se non trova nulla non va in errore ma restituisce una lista vuota)---
        Set<User> userSet = new Set<User>();
        for(Opportunity opp :database.query(qrSelect + qrFrom + qrWhere /* + qrOrder*/)){
            userSet.add(opp.owner);            
        }
        
        List<User> usrList = new List<User>(userSet);
        List<List<User>> userList = new List<List<User>>{usrList};
        
        return userList;
    }
}