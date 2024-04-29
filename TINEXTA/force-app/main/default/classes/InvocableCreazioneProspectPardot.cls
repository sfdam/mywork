public with sharing class InvocableCreazioneProspectPardot {

    public class ActionRequest {       
        @AuraEnabled @InvocableVariable
        public String Nome;
        @AuraEnabled @InvocableVariable
        public String Cognome;
        @AuraEnabled @InvocableVariable
        public String Email;
        @AuraEnabled @InvocableVariable
        public String Telefono;
        @AuraEnabled @InvocableVariable
        public String Via;
        @AuraEnabled @InvocableVariable
        public String Citta;
        @AuraEnabled @InvocableVariable
        public String CAP;
        @AuraEnabled @InvocableVariable
        public String Provincia;
        @AuraEnabled @InvocableVariable
        public String Paese;
        @AuraEnabled @InvocableVariable
        public String WRT_TagListaDinamica;
        @AuraEnabled @InvocableVariable
        public String Ruolo;
        @AuraEnabled @InvocableVariable
        public String Privacy_Warrant_Hub;
        @AuraEnabled @InvocableVariable
        public String Consenso_Marketing_Terz;
        @AuraEnabled @InvocableVariable
        public String Privacy_Tinexta;
        @AuraEnabled @InvocableVariable
        public String Id;
    }


    @InvocableMethod(label='Creazione Pardot' callout=true)
    public static List<String> handlePardotCallout(List<ActionRequest> parametri){

        Map<String,String> params = new Map<String,String>{
            'first_name' => parametri[0].Nome,
            'last_name' => parametri[0].Cognome,
            'email' => parametri[0].Email,
            'phone' => parametri[0].Telefono,
            'address_one' => parametri[0].Via, //Chiedere mapping
            'city' => parametri[0].Citta,
            'zip' => parametri[0].CAP,
            'state' => parametri[0].Provincia,
            'country' => parametri[0].Paese,
            'Origine_Lead_Livello_1' => 'Sito Web WH',
            'Origine_Lead_Livello_2' => 'Green110',
            'Data_Origine' => String.valueOf(System.Today()),
            'WRT_TagListaDinamica' => parametri[0].WRT_TagListaDinamica,
            'Ruolo' => parametri[0].Ruolo,
            'Privacy_Warrant_Hub' => parametri[0].Privacy_Warrant_Hub,
            'Data_Contitolarit_dei_Dati' => String.valueOf(System.Today()),
            'Consenso_Marketing_Terz' => parametri[0].Consenso_Marketing_Terz,
            'Data_Consenso_Marketing_Terz' => String.valueOf(System.Today()),
            'Privacy_Tinexta' => parametri[0].Privacy_Tinexta,
            'Data_Consenso_Marketing_Contitolari' => String.valueOf(System.Today()),
            'WRT_Listapardotelaborata' => 'true',
            'campign_id' => UtenzeDefault__c.getOrgDefaults().WRT_Pardot_Campaign_Id__c
        };
        
        System.debug('@@@ parametri[0] ' + parametri[0].Id);
        if(String.isNotBlank(parametri[0].Id)){
            params.put('id', '19339382'); //TODO: Sostituire Id con flow variabile
        }


        System.debug('@@@ params ' + JSON.serialize(parametri[0]));
        String pardotId = PardotIntegrationCtrl.createContact(params);
        return new List<String>{pardotId};

    }
}