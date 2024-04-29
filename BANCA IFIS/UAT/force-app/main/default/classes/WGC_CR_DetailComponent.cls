public class WGC_CR_DetailComponent {

    @AuraEnabled
    public static WrapperResponse getAllData(String accountId) {
        System.debug('SV accountId: ' + accountId);
        
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.WGC_Centrale_Rischi__c.fields.getMap();
        WrapperResponse result = new WrapperResponse();
        //M.N.
        //Date dataInizioMese = Date.newInstance(Date.today().year(),Date.today().month(),01);
		//Date dataInizioCR = dataInizioMese.addMonths(-12);
        
        try{
            List<sObject> crList = [ SELECT Id, Anno__c, Mese__c, 
                                                       Utilizzato_TOT_IFIS__c, Utilizzato_TOT_Sistema__c, Sconfino_TOT_IFIS__c, Sconfino_TOT_Sistema__c, 
                                                       Utilizzato_Autoliquidanti_IFIS__c, Utilizzato_Autoliquidanti_Sistema__c, Sconfino_Autoliquidanti_IFIS__c, 
                                                       Sconfino_Autoliquidanti_Sistema__c, Utilizzato_Scadenza_IFIS__c, Utilizzato_Scadenza_Sistema__c, 
                                                       Sconfino_Scadenza_IFIS__c, Sconfino_Scadenza_Sistema__c, Utilizzato_Revoca_IFIS__c, 
                                                       Utilizzato_Revoca_Sistema__c, Sconfino_Revoca_IFIS__c, Sconfino_Revoca_Sistema__c, 
                                                       Utilizzato_Firma_IFIS__c, Utilizzato_Firma_Sistema__c, Sconfino_Firma_IFIS__c, 
                                                       Sconfino_Firma_Sistema__c, Segnalanti__c, Nuovi_affidanti__c, Prima_Info__c, 
                                                       Sofferenze_Sistema_frm__c, Sofferenze_IFIS_frm__c, Accordato_TOT_IFIS__c, 
                                                       Accordato_TOT_Sistema__c, Accordato_Autoliquidanti_IFIS__c, Accordato_Autoliquidanti_Sistema__c,
                                                       Accordato_Scadenza_IFIS__c, Accordato_Scadenza_Sistema__c, Accordato_Revoca_IFIS__c, Accordato_Revoca_Sistema__c, 
                                                       Accordato_Firma_IFIS__c, Accordato_Firma_Sistema__c, Data_ultima_rilevazione__c, Check_presenza_segnalazioni__c
                                                FROM WGC_Centrale_Rischi__c
                                    			WHERE Anagrafica__c =: accountId AND Anno__c =: String.valueOf(System.today().year()) ORDER BY Mese__c];
                                    			//WHERE Anagrafica__c =: accountId AND Data_Riferimento__c >= :dataInizioCR ORDER BY Mese__c];
            System.debug('Prova crList ' + crList);
            Date dataultimaCR = Date.newInstance(1900, 1, 1);
            Date dataRichiestaCR;
            for (sObject cr : crList){
                System.debug('SV WGC_Centrale_Rischi__c XXX: ' + cr);

                if(dataultimaCR <= (Date)cr.get('Data_ultima_rilevazione__c')){
                    dataultimaCR =  (Date)cr.get('Data_ultima_rilevazione__c');
                }

                WrapperRecords wrapper = new WrapperRecords();
                Ifis ifis = new Ifis();
                Sistema sistema = new Sistema();
                for (String fieldName : schemaFieldMap.keySet()) {
                    if(cr.isSet(fieldName)){
                        if(fieldName.contains('ifis')){
                            if(fieldName.contains('utilizzato_tot_ifis')) ifis.Utilizzato_TOT_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('sconfino_tot_ifis')) ifis.Sconfino_TOT_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('utilizzato_autoliquidanti_ifis')) ifis.Utilizzato_Autoliquidanti_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('sconfino_autoliquidanti_ifis')) ifis.Sconfino_Autoliquidanti_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('utilizzato_scadenza_ifis')) ifis.Utilizzato_Scadenza_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('sconfino_scadenza_ifis')) ifis.Sconfino_Scadenza_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('utilizzato_revoca_ifis')) ifis.Utilizzato_Revoca_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('sconfino_revoca_ifis')) ifis.Sconfino_Revoca_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('utilizzato_firma_ifis')) ifis.Utilizzato_Firma_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('sconfino_firma_ifis')) ifis.Sconfino_Firma_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('accordato_tot_ifis')) ifis.Accordato_TOT_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('accordato_autoliquidanti_ifis')) ifis.Accordato_Autoliquidanti_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('accordato_scadenza_ifis')) ifis.Accordato_Scadenza_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('accordato_revoca_ifis')) ifis.Accordato_Revoca_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('accordato_firma_ifis')) ifis.Accordato_Firma_IFIS = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('sofferenze_ifis_frm')) ifis.Sofferenze_IFIS_frm = (String)cr.get(fieldName);

                        } else if(fieldName.contains('sistema')){
                            if(fieldName.contains('utilizzato_tot_sistema')) sistema.Utilizzato_TOT_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('sconfino_tot_sistema')) sistema.Sconfino_TOT_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('utilizzato_autoliquidanti_sistema')) sistema.Utilizzato_Autoliquidanti_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('sconfino_autoliquidanti_sistema')) sistema.Sconfino_Autoliquidanti_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('utilizzato_scadenza_sistema')) sistema.Utilizzato_Scadenza_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('sconfino_scadenza_sistema')) sistema.Sconfino_Scadenza_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('utilizzato_revoca_sistema')) sistema.Utilizzato_Revoca_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('sconfino_revoca_sistema')) sistema.Sconfino_Revoca_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('utilizzato_firma_sistema')) sistema.Utilizzato_Firma_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('sconfino_firma_sistema')) sistema.Sconfino_Firma_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('accordato_tot_sistema')) sistema.Accordato_TOT_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('accordato_autoliquidanti_sistema')) sistema.Accordato_Autoliquidanti_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('accordato_scadenza_sistema')) sistema.Accordato_Scadenza_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('accordato_revoca_sistema')) sistema.Accordato_Revoca_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('accordato_firma_sistema')) sistema.Accordato_Firma_Sistema = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('sofferenze_sistema_frm')) sistema.Sofferenze_Sistema_frm = (String)cr.get(fieldName);

                        } else {
                            if(fieldName.contains('prima_info')) wrapper.primaInfo = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('nuovi_affidanti')) wrapper.nuoviAffidanti = (Decimal)cr.get(fieldName);
                            if(fieldName.contains('segnalanti')) wrapper.segnalanti = (Decimal)cr.get(fieldName);

                            if(fieldName.contains('anno')) wrapper.anno = (String)cr.get(fieldName);
                            if(fieldName.contains('mese')) wrapper.mese = (String)cr.get(fieldName);

                            if(fieldName.contains('check_presenza_segnalazioni')) wrapper.presenza_segnalazioni = (Decimal)cr.get(fieldName);
                        }
                        // Passed in object has the field
                        System.debug('SV fieldName IN: ' + fieldName);
                        System.debug('SV ifis: ' + ifis);
                        System.debug('SV sistema: ' + sistema);
                        
                    } else {
                        System.debug('SV fieldName OUT: ' + fieldName);

                    }
                }

                wrapper.ifis = ifis;
                wrapper.sistema = sistema;
                wrapper.dataultimaCR = dataultimaCR;
                wrapper.dataRichiestaCR = dataRichiestaCR;
                
                result.data.add(wrapper);
            }
        
        if(Test.isRunningTest()) throw new TestException();

        } catch(exception e){
            result.success = false; 
            result.msg = e.getMessage();
            return result;
        }
        
        return result;
        
    }

    public class Ifis {
        @AuraEnabled public Decimal Utilizzato_TOT_IFIS;
        @AuraEnabled public Decimal Sconfino_TOT_IFIS;
        @AuraEnabled public Decimal Utilizzato_Autoliquidanti_IFIS;
        @AuraEnabled public Decimal Sconfino_Autoliquidanti_IFIS;
        @AuraEnabled public Decimal Utilizzato_Scadenza_IFIS;
        @AuraEnabled public Decimal Sconfino_Scadenza_IFIS;
        @AuraEnabled public Decimal Utilizzato_Revoca_IFIS;
        @AuraEnabled public Decimal Sconfino_Revoca_IFIS;
        @AuraEnabled public Decimal Utilizzato_Firma_IFIS;
        @AuraEnabled public Decimal Sconfino_Firma_IFIS;
        @AuraEnabled public Decimal Accordato_TOT_IFIS;
        @AuraEnabled public Decimal Accordato_Autoliquidanti_IFIS;
        @AuraEnabled public Decimal Accordato_Scadenza_IFIS;
        @AuraEnabled public Decimal Accordato_Revoca_IFIS;
        @AuraEnabled public Decimal Accordato_Firma_IFIS;
        @AuraEnabled public String Sofferenze_IFIS_frm;
    }

    public class Sistema {
        @AuraEnabled public Decimal Utilizzato_TOT_Sistema;
        @AuraEnabled public Decimal Sconfino_TOT_Sistema;
        @AuraEnabled public Decimal Utilizzato_Autoliquidanti_Sistema;
        @AuraEnabled public Decimal Sconfino_Autoliquidanti_Sistema;
        @AuraEnabled public Decimal Utilizzato_Scadenza_Sistema;
        @AuraEnabled public Decimal Sconfino_Scadenza_Sistema;
        @AuraEnabled public Decimal Utilizzato_Revoca_Sistema;
        @AuraEnabled public Decimal Sconfino_Revoca_Sistema;
        @AuraEnabled public Decimal Utilizzato_Firma_Sistema;
        @AuraEnabled public Decimal Sconfino_Firma_Sistema;
        @AuraEnabled public Decimal Accordato_TOT_Sistema;
        @AuraEnabled public Decimal Accordato_Autoliquidanti_Sistema;
        @AuraEnabled public Decimal Accordato_Scadenza_Sistema;
        @AuraEnabled public Decimal Accordato_Revoca_Sistema;
        @AuraEnabled public Decimal Accordato_Firma_Sistema;
        @AuraEnabled public String Sofferenze_Sistema_frm;
    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperRecords {
        
        @AuraEnabled public String id;

        @AuraEnabled public Decimal segnalanti;
        @AuraEnabled public Decimal nuoviAffidanti;
        @AuraEnabled public Decimal primaInfo;
        @AuraEnabled public Date dataultimaCR;
        @AuraEnabled public Date dataRichiestaCR;

        @AuraEnabled public Ifis ifis;
        @AuraEnabled public Sistema sistema;

        @AuraEnabled public String mese;
        @AuraEnabled public String anno;

        @AuraEnabled public Decimal presenza_segnalazioni;

    }

    //SM -19/04/2019
    //Funzione che recupera i dati da mostrare nella tabella in fondo al componente
    @AuraEnabled
    public static WrapperResponse getDataCR(String recordId){
        return getDataCR(recordId, null);
    }

    @AuraEnabled
    public static WrapperResponse getDataCR(String recordId, String opportunityId){
        WrapperResponse response = new WrapperResponse();

        try{
            
            if (String.isNotBlank(opportunityId)) {
                response.data.add(WizardOpportunityController.getCRData(opportunityId));
            } else {
                Account a = [SELECT Id, Name, Sconfini_a_revoca_Utilizzato_Accordato__c, Sconfini_a_revoca__c, 
                                    Sconfini_a_scadenza_Utilizzato_Accordato__c, Sconfini_a_scadenza__c, Impagato_50_Utilizzato_Autoliquidante__c,
                                    Sofferenze__c, WGC_DataRichiestaCR__c, WGC_Alert_KPI_Centrale_Rischi__c, WGC_Area__c, WGC_Flag_non_affidato__c, WGC_Data_Caricamento_BKIT__c
                            FROM Account WHERE Id =: recordId];

                response.data.add(a);
            }

            return response;
        }
        catch(Exception e){
            response.success = false;
            response.msg = e.getMessage();

            return response;
        }
    }

    // MB - TEN: TENAM-22 METODO PER IL RECUPERO DEL FLAG "SBLOCCO FACILE" DELLA CR; SE ALZATO, COMPLETA IL TAB CENTRALE RISCHI ANCHE SE CR NON DISPONIBILE
    @AuraEnabled
    public static Boolean getSbloccoFacileCR() {
        Funzionalita__c f = Funzionalita__c.getInstance();
        return f.WGC_Sblocco_Facile_CR__c;
    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<Object>();
        }
    }
}