public class WGC_PrivacyPersonaGiuridica {
    
    @AuraEnabled
    public static TestiPrivacy__mdt getText(){
        List<TestiPrivacy__mdt> lstTesti = new List<TestiPrivacy__mdt>();
        lstTesti = [
			SELECT Id, MasterLabel, DeveloperName, Sezione_1__c, Sezione_2__c, Sezione_3__c, Sezione_4__c, Sezione_5__c, Sezione_6__c 
			FROM TestiPrivacy__mdt 
			WHERE DeveloperName = 'ppg'
		];

        if(!lstTesti.isEmpty()){
            return lstTesti.get(0);
        }
        else{
            return null;
        }
    }
    
    @AuraEnabled
    public static Sobject getDefaultData(String recordId){

        Id objectId = (Id)recordId;
        String objectName = objectId.getSObjectType().getDescribe().getName();
        
        Sobject obj;
        if(objectName == 'Account'){
            obj = (SObject) Database.query(
                QueryBuilder.newInstance(objectName, new String[] {
                    'Id',
                    'Name',
                    'NDGGruppo__c',
                    'codiceIstituto3N__c',
                    'NaturaGiuridica__c',
                    'ConsensoAllaProfilazione__c',
                    'ConsensoProdottiBancaRicercheMercato__c',
                    'ConsensoProdottiSocietaTerze__c',
                    'ConsensoAttivitaPromozionaleTerzi__c',
                    'ConsensoAttivitaPromRicercheMercato__c',
                    'ConsensoSoloModalitaTradizionali__c',
                    'CF__c', 'PIVA__c', 'PIVACF__c', 'SAE__c', 'RAE__c',
                    'WGC_Esecutore_Firmatario_Privacy__c'
                    })
                    .beginFilter()
                        .add('Id', QBOp.QEQUAL, objectId)
                    .endFilter()
                .getQuery()
            );
        }
        else if(objectName == 'Contact'){
            obj = (SObject) Database.query(
                QueryBuilder.newInstance(objectName, new String[] {
                    'Id',
                    'Name',
                    'NDGGruppo__c',
                    'codiceIstituto3N__c',
                    'NaturaGiuridica__c',
                    'ConsensoAllaProfilazione__c',
                    'ConsensoProdottiBancaRicercheMercato__c',
                    'ConsensoProdottiSocietaTerze__c',
                    'ConsensoAttivitaPromozionaleTerzi__c',
                    'ConsensoAttivitaPromRicercheMercato__c',
                    'ConsensoSoloModalitaTradizionali__c',
                    'CF__c', 'SAE__c'
                    })
                    .beginFilter()
                        .add('Id', QBOp.QEQUAL, objectId)
                    .endFilter()
                .getQuery()
            );
        }


        /*
        Account a = [SELECT Id, NDGGruppo__c, Name, ConsensoAllaProfilazione__c,
        ConsensoProdottiBancaRicercheMercato__c, ConsensoProdottiSocietaTerze__c,
        ConsensoAttivitaPromozionaleTerzi__c, ConsensoAttivitaPromRicercheMercato__c,
        ConsensoSoloModalitaTradizionali__c, NaturaGiuridica__c, CF__c, PIVA__c, PIVACF__c, SAE__c, RAE__c 
        FROM Account WHERE Id=:recordId];
        */

        return obj;
    }

    @AuraEnabled
    public static WrapperResponse SaveRecord (String recordId, String record) {

        Id objectId = (Id)recordId;
        String objectName = objectId.getSObjectType().getDescribe().getName();
        WrapperResponse wrap = new WrapperResponse();
        if(objectName == 'Account'){
            Account accOld = new Account();
            accOld = [SELECT Id, Name, NDG__c, NDGGruppo__c, NaturaGiuridica__c, SAE__c, REA__c, RAE__c, 
                    BillingAddress, BillingStreetName__c, BillingStreetType__c, Fatturato__c, DataFatturato__c,
                    BillingStreetNumber__c, BillingCity, BillingPostalCode, BillingCountry, BillingState,
                    ShippingCity, ShippingAddress, ShippingStreetNumber__c, ShippingStreetType__c, 
                    ShippingStreetName__c, ShippingPostalCode, ShippingCountry, ShippingState,
                    CF__c, PIVA__c, Email__c, TelefonoPrefisso__c, TelefonoNumero__c, Fax,
                    Ateco__c, TAECode__c, DataIscrizioneCCIAA__c,
                    ConsensoAllaProfilazione__c, ConsensoAttivitaPromRicercheMercato__c,
                    ConsensoAttivitaPromozionaleTerzi__c, ConsensoProdottiBancaRicercheMercato__c,
                    ConsensoProdottiSocietaTerze__c, ConsensoSoloModalitaTradizionali__c, 
                    DataInserimentoConsensi__c, PartecipazioneSocietaFiduciarie2__c, NumberOfEmployees FROM Account WHERE Id=:recordId];

            try{

                Account accNew = (Account)JSON.deserialize(record, Account.class);
                System.debug('parameter ' + accNew);
                System.debug('record old ' + accOld);


                //accNew.Id = recordId;

                accOld.DataInserimentoConsensi__c = System.Today();

                if(accNew.ConsensoAllaProfilazione__c != accOld.ConsensoAllaProfilazione__c){
                    System.debug('@@@ qui 1');
                    accOld.WGC_Data_censimento_consenso_privacy_01__c = System.Today();
                    accOld.DataInserimentoConsensi__c = System.Today();
                    accOld.ConsensoAllaProfilazione__c = accNew.ConsensoAllaProfilazione__c;
                }
                if(accNew.ConsensoProdottiBancaRicercheMercato__c != accOld.ConsensoProdottiBancaRicercheMercato__c){
                    System.debug('@@@ qui 2');
                    accOld.WGC_Data_censimento_consenso_privacy_02__c = System.Today();
                    accOld.DataInserimentoConsensi__c = System.Today();
                    accOld.ConsensoProdottiBancaRicercheMercato__c = accNew.ConsensoProdottiBancaRicercheMercato__c;
                }
                if(accNew.ConsensoProdottiSocietaTerze__c != accOld.ConsensoProdottiSocietaTerze__c){
                    System.debug('@@@ qui 3');
                    accOld.WGC_Data_censimento_consenso_privacy_03__c = System.Today();
                    accOld.DataInserimentoConsensi__c = System.Today();
                    accOld.ConsensoProdottiSocietaTerze__c = accNew.ConsensoProdottiSocietaTerze__c;
                }
                if(accNew.ConsensoAttivitaPromozionaleTerzi__c != accOld.ConsensoAttivitaPromozionaleTerzi__c){
                    System.debug('@@@ qui 4');
                    accOld.WGC_Data_censimento_consenso_privacy_04__c = System.Today();
                    accOld.DataInserimentoConsensi__c = System.Today();
                    accOld.ConsensoAttivitaPromozionaleTerzi__c = accNew.ConsensoAttivitaPromozionaleTerzi__c;
                }
                if(accNew.ConsensoAttivitaPromRicercheMercato__c != accOld.ConsensoAttivitaPromRicercheMercato__c){
                    System.debug('@@@ qui 5');
                    accOld.WGC_Data_censimento_consenso_privacy_05__c = System.Today();
                    accOld.DataInserimentoConsensi__c = System.Today();
                    accOld.ConsensoAttivitaPromRicercheMercato__c = accNew.ConsensoAttivitaPromRicercheMercato__c;
                }
                if(accNew.ConsensoSoloModalitaTradizionali__c != accOld.ConsensoSoloModalitaTradizionali__c){
                    System.debug('@@@ qui 6');
                    accOld.WGC_Data_censimento_consenso_privacy_06__c = System.Today();
                    accOld.DataInserimentoConsensi__c = System.Today();
                    accOld.ConsensoSoloModalitaTradizionali__c = accNew.ConsensoSoloModalitaTradizionali__c;
                }
                

                System.debug('@@@ newValue ' + accNew);
                System.debug('record final ' + accOld);

                String response = WsAnagrafeUtils.WGC_variazione(accOld, null);
                update accOld;

                System.debug('@@@ response ' + response);

                wrap.data.add(accOld);
                wrap.message = response;
                
            }
            catch(Exception e){
                System.debug('@@@ exception ' + e.getMessage());
                wrap.message = e.getMessage();
                wrap.success = false;
                
            }
        }
        else /*if(objectName == 'Contact')*/{
            Contact accOld = new Contact();
            accOld = [SELECT Id, FirstName, LastName, NDG__c, NDGGruppo__c, NaturaGiuridica__c, SAE__c, 
                    MailingAddress, MailingStreetName__c, MailingStreetType__c,
                    MailingStreetNumber__c, MailingCity, MailingPostalCode, MailingCountry, MailingState,
                    CF__c, Email, Sesso__c, Birthdate, LuogoNascita__c, ProvinciaNascita__c, CodCatastaleLocNascita__c,
                    TelefonoPrefisso__c, TelefonoNumero__c, Fax, MobilePhone, DataEmissioneDoc__c, EnteEmitettenteDocumento__c,
                    TAECode__c, TipoDocumentoId__c, NumeroDoc__c, DataScadenzaDoc__c,
                    ConsensoAllaProfilazione__c, ConsensoAttivitaPromRicercheMercato__c,
                    ConsensoAttivitaPromozionaleTerzi__c, ConsensoProdottiBancaRicercheMercato__c,
                    ConsensoProdottiSocietaTerze__c, ConsensoSoloModalitaTradizionali__c, 
                    DataInserimentoConsensi__c FROM Contact WHERE Id=:recordId];

            try{

                Contact accNew = (Contact)JSON.deserialize(record, Contact.class);
                System.debug('parameter ' + accNew);

                //accNew.Id = recordId;

                accOld.DataInserimentoConsensi__c = System.Today();

                if(accNew.ConsensoAllaProfilazione__c != accOld.ConsensoAllaProfilazione__c){
                    //accNew.WGC_Data_censimento_consenso_privacy_01__c = System.Today();
                    accOld.DataInserimentoConsensi__c = System.Today();
                    accOld.ConsensoAllaProfilazione__c = accNew.ConsensoAllaProfilazione__c;
                }
                if(accNew.ConsensoProdottiBancaRicercheMercato__c != accOld.ConsensoProdottiBancaRicercheMercato__c){
                    //accNew.WGC_Data_censimento_consenso_privacy_02__c = System.Today();
                    accOld.DataInserimentoConsensi__c = System.Today();
                    accOld.ConsensoProdottiBancaRicercheMercato__c = accNew.ConsensoProdottiBancaRicercheMercato__c;
                }
                if(accNew.ConsensoProdottiSocietaTerze__c != accOld.ConsensoProdottiSocietaTerze__c){
                    //accNew.WGC_Data_censimento_consenso_privacy_03__c = System.Today();
                    accOld.DataInserimentoConsensi__c = System.Today();
                    accOld.ConsensoProdottiSocietaTerze__c = accNew.ConsensoProdottiSocietaTerze__c;
                }
                if(accNew.ConsensoAttivitaPromozionaleTerzi__c != accOld.ConsensoAttivitaPromozionaleTerzi__c){
                    //accNew.WGC_Data_censimento_consenso_privacy_04__c = System.Today();
                    accOld.DataInserimentoConsensi__c = System.Today();
                    accOld.ConsensoAttivitaPromozionaleTerzi__c = accNew.ConsensoAttivitaPromozionaleTerzi__c;
                }
                if(accNew.ConsensoAttivitaPromRicercheMercato__c != accOld.ConsensoAttivitaPromRicercheMercato__c){
                    //accNew.WGC_Data_censimento_consenso_privacy_05__c = System.Today();
                    accOld.DataInserimentoConsensi__c = System.Today();
                    accOld.ConsensoAttivitaPromRicercheMercato__c = accNew.ConsensoAttivitaPromRicercheMercato__c;
                }
                if(accNew.ConsensoSoloModalitaTradizionali__c != accOld.ConsensoSoloModalitaTradizionali__c){
                    //accNew.WGC_Data_censimento_consenso_privacy_06__c = System.Today();
                    accOld.DataInserimentoConsensi__c = System.Today();
                    accOld.ConsensoSoloModalitaTradizionali__c = accNew.ConsensoSoloModalitaTradizionali__c;
                }

                System.debug('@@@ newValue ' + accNew);
                System.debug('record updated ' + accOld);

                String response = WsAnagrafeUtils.WGC_variazione(null, accOld);
                System.debug('@@@ response ' + response);

                update accOld;
                wrap.message = response;


                wrap.data.add(accOld);
                wrap.message = 'OK';
                
            }
            catch(Exception e){
                System.debug('@@@ exception ' + e.getMessage());
                wrap.message = e.getMessage();
                wrap.success = false;
                
            }
        }
        return wrap;
    }

    @AuraEnabled
    public static WrapperResponse getReferentiEsecutori(String accountId){
        
        WrapperResponse response = new WrapperResponse();

        try{
            List<AccountContactRelation> listaACR = new List<AccountContactRelation>();
            listaACR = [SELECT Id, Contact.Name FROM AccountContactRelation WHERE AccountId =: accountId AND WGC_Tipologia_Esecutore__c != null ];

            for(AccountContactRelation acr : listaACR){
                response.data.add(acr);
            }
        }
        catch(Exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static WrapperResponse saveAccountPrivacy(String accountId, String record, String esecutore){
        WrapperResponse wrap = new WrapperResponse();

        Account accOld = new Account();
        accOld = [SELECT Id, Name, NDG__c, NDGGruppo__c, NaturaGiuridica__c, SAE__c, REA__c, RAE__c, 
                BillingAddress, BillingStreetName__c, BillingStreetType__c, Fatturato__c, DataFatturato__c,
                BillingStreetNumber__c, BillingCity, BillingPostalCode, BillingCountry, BillingState,
                ShippingCity, ShippingAddress, ShippingStreetNumber__c, ShippingStreetType__c, 
                ShippingStreetName__c, ShippingPostalCode, ShippingCountry, ShippingState,
                CF__c, PIVA__c, Email__c, TelefonoPrefisso__c, TelefonoNumero__c, Fax,
                Ateco__c, TAECode__c, DataIscrizioneCCIAA__c,
                ConsensoAllaProfilazione__c, ConsensoAttivitaPromRicercheMercato__c,
                ConsensoAttivitaPromozionaleTerzi__c, ConsensoProdottiBancaRicercheMercato__c,
                ConsensoProdottiSocietaTerze__c, ConsensoSoloModalitaTradizionali__c, 
                DataInserimentoConsensi__c, PartecipazioneSocietaFiduciarie2__c, 
                NumberOfEmployees, WGC_Esecutore_Firmatario_Privacy__c FROM Account WHERE Id=:accountId];

        

        try{

            Account accNew = (Account)JSON.deserialize(record, Account.class);
            System.debug('parameter ' + accNew);
            System.debug('record old ' + accOld);


            //accNew.Id = recordId;

            accOld.DataInserimentoConsensi__c = System.Today();

            //Setto l'esecutore della privacy sull'anagrafica
            accOld.WGC_Esecutore_Firmatario_Privacy__c = esecutore;

            if(accNew.ConsensoAllaProfilazione__c != accOld.ConsensoAllaProfilazione__c){
                System.debug('@@@ qui 1');
                accOld.WGC_Data_censimento_consenso_privacy_01__c = System.Today();
                accOld.DataInserimentoConsensi__c = System.Today();
                accOld.ConsensoAllaProfilazione__c = accNew.ConsensoAllaProfilazione__c;
            }
            if(accNew.ConsensoProdottiBancaRicercheMercato__c != accOld.ConsensoProdottiBancaRicercheMercato__c){
                System.debug('@@@ qui 2');
                accOld.WGC_Data_censimento_consenso_privacy_02__c = System.Today();
                accOld.DataInserimentoConsensi__c = System.Today();
                accOld.ConsensoProdottiBancaRicercheMercato__c = accNew.ConsensoProdottiBancaRicercheMercato__c;
            }
            if(accNew.ConsensoProdottiSocietaTerze__c != accOld.ConsensoProdottiSocietaTerze__c){
                System.debug('@@@ qui 3');
                accOld.WGC_Data_censimento_consenso_privacy_03__c = System.Today();
                accOld.DataInserimentoConsensi__c = System.Today();
                accOld.ConsensoProdottiSocietaTerze__c = accNew.ConsensoProdottiSocietaTerze__c;
            }
            if(accNew.ConsensoAttivitaPromozionaleTerzi__c != accOld.ConsensoAttivitaPromozionaleTerzi__c){
                System.debug('@@@ qui 4');
                accOld.WGC_Data_censimento_consenso_privacy_04__c = System.Today();
                accOld.DataInserimentoConsensi__c = System.Today();
                accOld.ConsensoAttivitaPromozionaleTerzi__c = accNew.ConsensoAttivitaPromozionaleTerzi__c;
            }
            if(accNew.ConsensoAttivitaPromRicercheMercato__c != accOld.ConsensoAttivitaPromRicercheMercato__c){
                System.debug('@@@ qui 5');
                accOld.WGC_Data_censimento_consenso_privacy_05__c = System.Today();
                accOld.DataInserimentoConsensi__c = System.Today();
                accOld.ConsensoAttivitaPromRicercheMercato__c = accNew.ConsensoAttivitaPromRicercheMercato__c;
            }
            if(accNew.ConsensoSoloModalitaTradizionali__c != accOld.ConsensoSoloModalitaTradizionali__c){
                System.debug('@@@ qui 6');
                accOld.WGC_Data_censimento_consenso_privacy_06__c = System.Today();
                accOld.DataInserimentoConsensi__c = System.Today();
                accOld.ConsensoSoloModalitaTradizionali__c = accNew.ConsensoSoloModalitaTradizionali__c;
            }
            

            System.debug('@@@ newValue ' + accNew);
            System.debug('record final ' + accOld);

            String response = WsAnagrafeUtils.WGC_variazione(accOld, null);
            update accOld;

            System.debug('@@@ response ' + response);

            wrap.data.add(accOld);
            wrap.message = response;
        }
        catch(Exception e){
            wrap.message = e.getMessage();
            wrap.success = false;
        }

        return wrap;
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