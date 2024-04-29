public with sharing class WGC_Team_IFIS_KNET_Ctrl {

    @AuraEnabled
    public static Map<String,Object> getReferentiKNET(Id accountId){
        Map<String,Object> result = new Map<String,Object>{'success' => true, 'message' => ''};

        try {

            Account acc = [SELECT Id, 
                NDGGruppo__c, 
                WGC_Nome_Settorista_KNET__c,
                WGC_NDG_Settorista_KNET__c,
                WGC_Nome_Presentatore_KNET__c,
                WGC_NDG_Presentatore_KNET__c,
                WGC_Nome_Gestore_Cliente_KNET__c,
                WGC_NDG_Gestore_Cliente_KNET__c,
                WGC_Nome_Gestore_Debitore_KNET__c,
                WGC_NDG_Gestore_Debitore_KNET__c,
                WGC_Data_ultima_chiamata_Team_IFIS_KNET__c,
                WGC_Telefono_Gestore_Cliente_KNET__c,
                WGC_Telefono_Gestore_Debitore_KNET__c,
                WGC_Telefono_Settorista_KNET__c,
                WGC_Telefono_Presentatore_KNET__c
                FROM Account 
                WHERE Id =: accountId];

            //Una chiamata al giorno, se già effettuata mostro i dati presenti su account
            if(acc.WGC_Data_ultima_chiamata_Team_IFIS_KNET__c == Date.today()){
                result.put('data', mapFields(acc));
                return result;
            }

            InputPayload payload = new InputPayload(acc);

            ResponsePayload response = (ResponsePayload)WGC_WsRest.getTeamIFISKNET(payload);

            System.debug('@@@ response ' + response);

            if(!response.isCorrect()){
                result.put('success', false);
                result.put('message', 'errore nella chiamata a KNET');
                return result;
            }

            acc.WGC_Nome_Settorista_KNET__c = response.payload[0].nomeRefCommerc + ' ' + response.payload[0].cognomeRefCommerc == 'null null' ? null : response.payload[0].nomeRefCommerc + ' ' + response.payload[0].cognomeRefCommerc;
            acc.WGC_NDG_Settorista_KNET__c = String.valueOf(response.payload[0].ndgRefCommerc);
            acc.WGC_Telefono_Settorista_KNET__c = response.payload[0].telefRefCommerc != null ? response.payload[0].telefRefCommerc.trim() : null;
            acc.WGC_Nome_Presentatore_KNET__c = response.payload[0].nomePresentatore + ' ' + response.payload[0].cognomePresentatore == 'null null' ? null : response.payload[0].nomePresentatore + ' ' + response.payload[0].cognomePresentatore;
            acc.WGC_NDG_Presentatore_KNET__c = String.valueOf(response.payload[0].ndgPresentatore);
            acc.WGC_Telefono_Presentatore_KNET__c = response.payload[0].telefPresentatore != null ? response.payload[0].telefPresentatore.trim() : null;
            acc.WGC_Nome_Gestore_Cliente_KNET__c = response.payload[0].nomeGestCedente + ' ' + response.payload[0].cognomeGestCedente == 'null null' ? null : response.payload[0].nomeGestCedente + ' ' + response.payload[0].cognomeGestCedente;
            acc.WGC_NDG_Gestore_Cliente_KNET__c = String.valueOf(response.payload[0].ndgGestCedente);
            acc.WGC_Telefono_Gestore_Cliente_KNET__c = response.payload[0].telefGestCedente != null ? response.payload[0].telefGestCedente.trim() : null;
            acc.WGC_Nome_Gestore_Debitore_KNET__c = response.payload[0].nomeGestDebitore + ' ' + response.payload[0].cognomeGestDebitore == 'null null' ? null : response.payload[0].nomeGestDebitore + ' ' + response.payload[0].cognomeGestDebitore;
            acc.WGC_NDG_Gestore_Debitore_KNET__c = String.valueOf(response.payload[0].ndgGestDebitore);
            acc.WGC_Telefono_Gestore_Debitore_KNET__c = response.payload[0].telefGestDebitore != null ? response.payload[0].telefGestDebitore.trim() : null;
            acc.WGC_Data_ultima_chiamata_Team_IFIS_KNET__c = Date.Today();

            update acc;
            
            System.debug('@@@ response.payload[0] ' + response.payload[0]);
            result.put('data', mapFields(acc));

        } catch (Exception e) {
            result.put('success', false);
            result.put('message', e.getMessage());
            // throw new AuraHandledException(e.getMessage());
        }

        return result;
    }

    private static Map<String,Object> mapFields(Account acc){
        Map<String,Object> mapping = new Map<String,Object>{
            'ndgGestCedente' =>  acc.WGC_NDG_Gestore_Cliente_KNET__c != null ? acc.WGC_NDG_Gestore_Cliente_KNET__c : '',
            // 'cognomeGestCedente' => acc.WGC_Nome_Gestore_Cliente_KNET__c.split(' '),
            'cognomeGestCedente' => '',
            'nomeGestCedente' => acc.WGC_Nome_Gestore_Cliente_KNET__c != null ? acc.WGC_Nome_Gestore_Cliente_KNET__c : '',
            'telefGestCedente' => acc.WGC_Telefono_Gestore_Cliente_KNET__c != null ? acc.WGC_Telefono_Gestore_Cliente_KNET__c : '',
            'ndgGestDebitore' => acc.WGC_NDG_Gestore_Debitore_KNET__c != null ? acc.WGC_NDG_Gestore_Debitore_KNET__c : '',
            // 'cognomeGestDebitore' => acc.WGC_Nome_Gestore_Debitore_KNET__c.split(' '),
            'cognomeGestDebitore' => '',
            'nomeGestDebitore' => acc.WGC_Nome_Gestore_Debitore_KNET__c != null ? acc.WGC_Nome_Gestore_Debitore_KNET__c : '',
            'telefGestDebitore' => acc.WGC_Telefono_Gestore_Debitore_KNET__c != null ? acc.WGC_Telefono_Gestore_Debitore_KNET__c : '',
            'ndgRefCommerc' => acc.WGC_NDG_Settorista_KNET__c != null ? acc.WGC_NDG_Settorista_KNET__c : '',
            // 'cognomeRefCommerc' => acc.WGC_Nome_Settorista_KNET__c.split(' '),
            'cognomeRefCommerc' => '',
            'nomeRefCommerc' => acc.WGC_Nome_Settorista_KNET__c != null ? acc.WGC_Nome_Settorista_KNET__c : '',
            'telefRefCommerc' => acc.WGC_Telefono_Settorista_KNET__c != null ? acc.WGC_Telefono_Settorista_KNET__c : '',
            'ndgPresentatore' => acc.WGC_NDG_Presentatore_KNET__c != null ? acc.WGC_NDG_Presentatore_KNET__c : '',
            'cognomePresentatore' => '',
            'nomePresentatore' => acc.WGC_Nome_Presentatore_KNET__c != null ? acc.WGC_Nome_Presentatore_KNET__c : '',
            'telefPresentatore' => acc.WGC_Telefono_Presentatore_KNET__c != null ? acc.WGC_Telefono_Presentatore_KNET__c : ''
        };

        return mapping;
    }

    //ESEMPIO PAYLOAD INPUT

    public class InputPayload {
        public String socRiferimento;
        public Long ndgSoggetto;

        public InputPayload(Account account){
            this.socRiferimento = 'BI';
            this.ndgSoggetto = Long.valueOf(account.NDGGruppo__c);
        }
    }

    // "headers": { .......


    //ESEMPIO PAYLOAD OUTPUT
    
    
    public class ResponsePayload extends WsRestInput.CommonResponse{
        @AuraEnabled public CommercialeKNET[] payload;

        public override Boolean isCorrect(){
            return this.payload != null && this.payload.size() > 0;
        }
    }

    
    public class CommercialeKNET{
        @AuraEnabled public Long ndgSoggetto;
        @AuraEnabled public String codFiliale;
        @AuraEnabled public String descrFiliale;
        @AuraEnabled public String mailFiliale;
        @AuraEnabled public Long ndgGestCedente;
        @AuraEnabled public String cognomeGestCedente;
        @AuraEnabled public String nomeGestCedente;
        @AuraEnabled public String mailGestCedente;
        @AuraEnabled public String prTlfGestCedente;
        @AuraEnabled public String telefGestCedente;
        @AuraEnabled public String prCelGestCedente;
        @AuraEnabled public String cellGestCedente;
        @AuraEnabled public Long ndgGestDebitore;
        @AuraEnabled public String cognomeGestDebitore;
        @AuraEnabled public String nomeGestDebitore;
        @AuraEnabled public String mailGestDebitore;
        @AuraEnabled public String prTlfGestDebitore;
        @AuraEnabled public String telefGestDebitore;
        @AuraEnabled public String prCelGestDebitore;
        @AuraEnabled public String cellGestDebitore;
        @AuraEnabled public Long ndgRefCommerc;
        @AuraEnabled public String cognomeRefCommerc;
        @AuraEnabled public String nomeRefCommerc;
        @AuraEnabled public String mailRefCommerc;
        @AuraEnabled public String prTlfRefCommerc;
        @AuraEnabled public String telefRefCommerc;
        @AuraEnabled public Long ndgPresentatore;
        @AuraEnabled public String cognomePresentatore;
        @AuraEnabled public String nomePresentatore;
        @AuraEnabled public String mailPresentatore;
        @AuraEnabled public String prTlfPresentatore;
        @AuraEnabled public String telefPresentatore;
    }

}