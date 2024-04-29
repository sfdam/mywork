public class WGC_ModuloTecnicheComunicazione {
    
    @AuraEnabled
    public static Account getAccountData(String recordId){
        Account acc = [SELECT Name, BillingAddress, ShippingAddress, Fax, Phone, EmailPEC__c, Email__c, CodiceDestinatario__c, TelefonoPrefisso__c FROM Account WHERE Id=:recordId];
        
        return acc;
    }

    @AuraEnabled
    public static AdeguataVerifica__c getMAV(String recordId){
        List<AdeguataVerifica__c> mavs = new List<AdeguataVerifica__c>();

        mavs = [SELECT Id, CorrispondenzaCountry__c, CorrispondenzaState__c, CorrispondenzaCity__c, 
        CorrispondenzaStreetType__c, CorrispondenzaStreetName__c, CorrispondenzaStreetNumber__c, CorrispondenzaCAP__c
        FROM AdeguataVerifica__c WHERE Account__c =: recordId AND (CorrispondenzaCountry__c != null OR CorrispondenzaState__c != null OR CorrispondenzaCity__c != null OR 
        CorrispondenzaStreetType__c != null OR CorrispondenzaStreetName__c != null OR CorrispondenzaStreetNumber__c != null OR CorrispondenzaCAP__c != null) ORDER BY CreatedDate DESC];

        if(mavs.isEmpty()){
            return null;
        }
        else{
            return mavs.get(0);
        }
    }
	
    @AuraEnabled
    public static WrapperResponse SaveRecord(String recordId, String recordMod, String recordAcc){

        WrapperResponse wrap = new WrapperResponse();

        try{
            Account acc = (Account) JSON.deserialize(recordAcc, Account.Class);
            acc.Id = recordId;
            System.debug('@@@ acc ' + acc);
            

            Account accVariazione = [SELECT Id, Name, NDGGruppo__c, NaturaGiuridica__c, CF__c, PIVA__c, PIVACF__c, SAE__c, RAE__c, REA__c,
                                    BillingAddress, BillingCity, BillingPostalCode, BillingStreetName__c, BillingStreetType__c, BillingStreetNumber__c, BillingCountry, BillingState,
                                    ShippingAddress, ShippingCity, ShippingStreetName__c, ShippingStreetType__c, ShippingStreetNumber__c, ShippingPostalCode, ShippingCountry, ShippingState,
                                    TelefonoPrefisso__c, TelefonoNumero__c, NumberOfEmployees, Fax, Phone, EmailPECFatturaElettronica__c, EmailPEC__c, Email__c, Ateco__c, TAECode__c, DataIscrizioneCCIAA__c,
                                    ConsensoAllaProfilazione__c, ConsensoAttivitaPromRicercheMercato__c,
                                    ConsensoAttivitaPromozionaleTerzi__c, ConsensoProdottiBancaRicercheMercato__c,
                                    ConsensoProdottiSocietaTerze__c, ConsensoSoloModalitaTradizionali__c, 
                                    DataInserimentoConsensi__c, PartecipazioneSocietaFiduciarie2__c, Fatturato__c, DataFatturato__c
                                    FROM Account
                                    WHERE Id=:recordId];
            
            if(acc.IndirizzoPerInvioCorrispondenza__c == 'Sede legale'){
                accVariazione.BillingCity = acc.BillingCity;
                accVariazione.BillingPostalCode = acc.BillingPostalCode;
                accVariazione.BillingStreetName__c = acc.BillingStreetName__c;
                accVariazione.BillingStreetType__c = acc.BillingStreetType__c;
                accVariazione.BillingStreetNumber__c = acc.BillingStreetNumber__c;
                accVariazione.BillingCountry = acc.BillingCountry;
                accVariazione.BillingState = acc.BillingState;
            }
            else if(acc.IndirizzoPerInvioCorrispondenza__c == 'Sede amministrativa'){
                accVariazione.ShippingCity = acc.ShippingCity; 
                accVariazione.ShippingPostalCode = acc.ShippingPostalCode; 
                accVariazione.ShippingStreetName__c = acc.ShippingStreetName__c; 
                accVariazione.ShippingStreetType__c = acc.ShippingStreetType__c; 
                accVariazione.ShippingStreetNumber__c = acc.ShippingStreetNumber__c; 
                accVariazione.ShippingCountry = acc.ShippingCountry; 
                accVariazione.ShippingState = acc.ShippingState;
            }

            accVariazione.IndirizzoPerInvioCorrispondenza__c = acc.IndirizzoPerInvioCorrispondenza__c;
            accVariazione.Email__c = acc.Email__c;
            accVariazione.EmailPEC__c = acc.EmailPEC__c;
            accVariazione.codiceDestinatario__c = acc.codiceDestinatario__c;
            accVariazione.Phone = acc.Phone;
            accVariazione.TelefonoNumero__c = acc.Phone;
            accVariazione.Fax = acc.Fax;
            accVariazione.EmailPECFatturaElettronica__c = acc.EmailPECFatturaElettronica__c;
            // else if(acc.IndirizzoPerInvioCorrispondenza__c == 'Altro'){

            // }


            
            //Chiamata variazione
            String response = WsAnagrafeUtils.WGC_variazione(accVariazione, null);
            System.debug('@@@ response variazione ' + response);
            update acc;

            AdeguataVerifica__c mav = (AdeguataVerifica__c) JSON.deserialize(recordMod, AdeguataVerifica__c.Class);
            mav.Account__c = (Id)recordId;
            System.debug('@@@ mav ' + mav);
            System.debug('@@@ mav id ' + mav.Id);
            if(mav.Id != null){
                update mav;
            }
            else{
                insert mav;
            }
            
            System.debug('@@@ mav saved ' + mav);
            
            wrap.data.add(acc);
            wrap.message = 'OK';
            return wrap;
        }
        catch(Exception e){
            System.debug('@@@ exc ' + e.getMessage() + ' - ' + e.getCause() + ' - ' + e.getLineNumber());
            wrap.message = e.getMessage();
            wrap.success = false;
            return wrap;
        }
    }

    public class WrapperResponse{
        @AuraEnabled
        public List<Object> data;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = '';
            this.success = true;
        }
    }
}