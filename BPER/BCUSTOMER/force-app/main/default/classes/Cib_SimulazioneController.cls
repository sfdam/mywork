public without sharing class Cib_SimulazioneController {
    @AuraEnabled
    public static Object init(String recordId, String opportunityId, String accountId){
        System.debug('DK START init');
        System.debug('DK init recordId' + recordId);
        System.debug('DK init opportunityId' + opportunityId);
        System.debug('DK init accountId' + accountId);
        try {
            Map<String, List<Object>> optionsMap = new Map<String, List<Object>>();
            optionsMap.put('Modello_di_Servizio__c', new List<Object>());
            optionsMap.put('Provincia__c', new List<Object>());
            optionsMap.put('Segmento_di_Rischio__c', new List<Object>());
            optionsMap.put('Segmento_Modello__c', new List<Object>());
            optionsMap.put('Classe_di_rating__c', new List<Object>());
            optionsMap.put('Giudizio_slotting_criteria__c', new List<Object>());
            optionsMap.put('Classe_di_merito_altre_variabili__c', new List<Object>());
            optionsMap.put('Soglia_fatturato_di_gruppo__c', new List<Object>());
            optionsMap.put('Natura_Giuridica__c', new List<Object>());

            // linee
            optionsMap.put('Formatecnica__c', new List<Object>());
            optionsMap.put('Tipo_di_ammortamento__c', new List<Object>());
            optionsMap.put('Tipo_funding__c', new List<Object>());
            optionsMap.put('Valuta__c', new List<Object>());
            optionsMap.put('Durata__c', new List<Object>());
            optionsMap.put('Periodicita_rata__c', new List<Object>());
            optionsMap.put('Preammortamento__c', new List<Object>{new Map<String, String>{'label' => '-- None --', 'value' => ''}});
            optionsMap.put('Tipo_garanzia__c', new List<Object>());
            optionsMap.put('Tipo_pegno__c', new List<Object>());
            optionsMap.put('Tipo_tasso__c', new List<Object>());
            optionsMap.put('Tipo_garanzia__c', new List<Object>());
            optionsMap.put('Sensitivity__c', new List<Object>());
            optionsMap.put('Indicizzazionetassovariabile__c', new List<Object>());
            optionsMap.put('Utilizzo__c', new List<Object>());

            //rataLinea
            optionsMap.put('Ratacorrispondentemodificatasso__c', new List<Object>());

            Schema.SObjectType simObjSobjectType = Schema.getGlobalDescribe().get('Simulazione__c');
            Schema.SObjectType lineaObjSobjectType = Schema.getGlobalDescribe().get('Linea__c');
            Schema.SObjectType rataLineaObjSobjectType = Schema.getGlobalDescribe().get('RataLinea__c');
            for(String field: optionsMap.keySet()){
                if(lineaObjSobjectType.getDescribe().fields.getMap().containsKey(field) && lineaObjSobjectType.getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues().size() > 0){

                    for(Schema.PicklistEntry picklistValue : lineaObjSobjectType.getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues()){
                        if(picklistValue.active){
                            optionsMap.get(field).add(new Map<String, String>{'label' => picklistValue.getLabel(), 'value' => picklistValue.getValue()});
                        }
                    }
                }else if(simObjSobjectType.getDescribe().fields.getMap().containsKey(field) && simObjSobjectType.getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues().size() > 0){

                    for(Schema.PicklistEntry picklistValue : simObjSobjectType.getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues()){
                        if(picklistValue.active){
                            optionsMap.get(field).add(new Map<String, String>{'label' => picklistValue.getLabel(), 'value' => picklistValue.getValue()});
                        }
                    }
                }else if(rataLineaObjSobjectType.getDescribe().fields.getMap().containsKey(field) && rataLineaObjSobjectType.getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues().size() > 0){

                    for(Schema.PicklistEntry picklistValue : rataLineaObjSobjectType.getDescribe().fields.getMap().get(field).getDescribe().getPicklistValues()){
                        if(picklistValue.active){
                            optionsMap.get(field).add(new Map<String, String>{'label' => picklistValue.getLabel(), 'value' => picklistValue.getValue()});
                        }
                    }
                }
            }
            Simulazione__c simulazione = recordId != null ? Database.query(SV_Utilities.selectAllField('Simulazione__c', false).replace('FROM', ',Opportunity__r.AccountId, Owner.Name, RecordType.Name, Nome_del_Gestore__r.Name, Nome_titolare_operazione__r.Name, (' + SV_Utilities.selectAllField('Linea__c', false).replace('Linea__c', 'Linee__r').replace('FROM', ',RecordType.Name FROM') + ' ORDER BY Number__c ASC) FROM') + ' WHERE Id =: recordId') : null;
            System.debug('Dk simulazione: ' + JSON.serialize(simulazione));
            Set<String> idLineaSet = simulazione != null && !simulazione.Linee__r.isEmpty() ? SV_Utilities.keyBy(simulazione.Linee__r, 'Id').keySet() : null;
            return new Map<String, Object>{
                'currentUser' => [SELECT ID, Name FROM User WHERE Id =: UserInfo.getUserId()],
                'account' => String.isNotBlank(accountId) ? Database.query(SV_Utilities.selectAllField('Account').replace('FROM', ',PTF_Portafoglio__r.CRM_ReferentePortafoglio__c, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_User__c, PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.Name FROM') + ' WHERE Id =: accountId') : null,
                'opportunity' => String.isNotBlank(opportunityId) ? Database.query(SV_Utilities.selectAllField('Opportunity').replace('FROM', ',Account.CRM_NDG__c, Account.NDG_Gruppo_Aziendale__c, Account.Name, Account.CRM_SegmentoRischioUfficiale__c, Account.CRM_NaturaGiuridica__c, Account.ModelloDiServizio__c, Account.CRM_NomeCognomeReferente__c, Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__c, Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.PTF_User__c, Account.PTF_Portafoglio__r.CRM_ReferentePortafoglio__r.Name, Account.CRM_ProvinciaIscrizioneCCIAA__c, Account.CRM_CreditRating__c FROM') + ' WHERE Id =: opportunityId') : null,
                'recordInfo' => simulazione,
                'query' => SV_Utilities.selectAllField('Simulazione__c', false).replace('FROM', ',Opportunity__r.AccountId, Owner.Name, RecordType.Name, Nome_del_Gestore__r.Name, Nome_titolare_operazione__r.Name, (' + SV_Utilities.selectAllField('Linea__c', false).replace('Linea__c', 'Linee__r').replace('FROM', ',RecordType.Name FROM') + ' ORDER BY Name ASC) FROM') + ' WHERE Id =: recordId',
                'rateLineaMap' => idLineaSet != null ? SV_Utilities.groupBy(Database.query(SV_Utilities.selectAllField('RataLinea__c') + ' WHERE Linea__c IN: idLineaSet ORDER BY Numerorata__c,Ratacorrispondentemodificatasso__c,ProgrPeriodo__c ASC'), 'Linea__c') : null,
                'optionsMap' => optionsMap
            };
        } catch (Exception ex) {
            System.debug('DK Exception: ' + ex.getMessage() + '; at:' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage() + '; at:' + ex.getStackTraceString());
        }
    }

    @AuraEnabled
    public static String save(Simulazione__c sim, List<Linea__c> simLinee, List<Map<String,Object>> rateLineeToUpsert, List<RataLinea__c> rateLineeToDelete){
        System.debug('Dk sim' + JSON.serialize(sim));
        System.debug('Dk simLinee' + JSON.serialize(simLinee));
        System.debug('Dk rateLineeToUpsert' + JSON.serialize(rateLineeToUpsert));
        Savepoint sp = Database.setSavepoint();
        try {
            System.debug('DK sim: ' + JSON.serialize(sim));
            upsert sim;
            for(Linea__c linea : simLinee){
                if(String.isBlank(linea.Simulazione__c)){
                    linea.Simulazione__c = sim.Id;
                }
            }
            
            upsert simLinee;
            System.debug('DK simLinee: ' + JSON.serialize(simLinee));
            Map<String, Sobject> lineeMap = SV_Utilities.keyBy(simLinee, 'Number__c');
            System.debug('DK lineeMap: ' + JSON.serialize(lineeMap));
            for(Map<String,Object> rataLinea : rateLineeToUpsert){
                if(String.isBlank((String)rataLinea.get('Linea__c'))){
                    System.debug('DK numeroLinea: ' + String.valueOf(Integer.valueOf((Decimal)rataLinea.get('numberLinea'))));
                    rataLinea.put('Linea__c', lineeMap.get(String.valueOf(Integer.valueOf((Decimal)rataLinea.get('numberLinea')))).get('Id'));
                }
            }
            System.debug('DK rateLineeToUpsert: ' + JSON.serialize(rateLineeToUpsert));
            List<RataLinea__c> rateLinee = (List<RataLinea__c>)JSON.deserialize(JSON.serialize(rateLineeToUpsert), List<RataLinea__c>.class);
            upsert rateLinee;
            delete rateLineeToDelete;
            // Database.rollback(sp);
            return sim.Id;
        } catch (Exception ex) {
            // Rollback to the previous null value
            Database.rollback(sp);
            System.debug('DK Exception: ' + ex.getMessage() + '; at:' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage() + '; at:' + ex.getStackTraceString());
        }
    }

    @AuraEnabled
    public static string clone(String recordId){
        Savepoint sp = Database.setSavepoint();
        try {
            List<Simulazione__c> originalSim = Database.query(SV_Utilities.selectAllField('Simulazione__c', false).replace('FROM', ',Owner.Name, RecordType.Name, Nome_del_Gestore__r.Name, Nome_titolare_operazione__r.Name, (' + SV_Utilities.selectAllField('Linea__c', false).replace('Linea__c', 'Linee__r').replace('FROM', ',RecordType.Name FROM') + ') FROM') + ' WHERE Id =: recordId');
            Set<String> idLineaSet = originalSim[0] != null && !originalSim[0].Linee__r.isEmpty() ? SV_Utilities.keyBy(originalSim[0].Linee__r, 'Id').keySet() : null;
            Map<String, List<SObject>> rateLineaMap = SV_Utilities.groupBy(Database.query(SV_Utilities.selectAllField('RataLinea__c') + ' WHERE Linea__c IN: idLineaSet AND Type__c != \'Piano Ammortamento Output\' ORDER BY Numerorata__c,Ratacorrispondentemodificatasso__c,ProgrPeriodo__c ASC'), 'Linea__c');
            String recTypeInputSim = SV_Utilities.getRecordTypeByDeveloperName('Simulazione__c', 'Input');
            String recTypeInputLinea = SV_Utilities.getRecordTypeByDeveloperName('Linea__c', 'Input');

            List<Simulazione__c> cloneSim = originalSim.deepClone(false, false, false);
            cloneSim[0].RecordTypeId = recTypeInputSim;
            cloneSim[0].Interessi_attivi_totali__c = null;
            cloneSim[0].Costo_del_funding_totale__c = null;
            cloneSim[0].Margine_di_interesse_totale__c = null;
            cloneSim[0].Commissioni_Up_Front_Totale__c = null;
            cloneSim[0].Commissioni_Running_Totale__c = null;
            cloneSim[0].Commissioni_Altro_Totale__c = null;
            cloneSim[0].Commissioni_Totali__c = null;
            cloneSim[0].Margine_di_intermediazione_Totale__c = null;
            cloneSim[0].Costo_del_Rischio_Lordo_Totale__c = null;
            cloneSim[0].Costo_del_capitale_totale__c = null;
            cloneSim[0].Costi_operativi_totali__c = null;
            cloneSim[0].Margine_operativo_netto_totale__c = null;
            cloneSim[0].SML_annuo_medio_totale__c = null;
            cloneSim[0].EAD_annua_media_totale__c = null;
            cloneSim[0].rwa_Rischio_Di_Credito_Annuo_Medio__c = null;
            cloneSim[0].RWA_rischio_operativo_annui_medio__c = null;
            cloneSim[0].rwaRischioDiCreditoAnnuoTotal__c = null;
            cloneSim[0].rwaRischioOperativoAnnuoTotal__c = null;
            cloneSim[0].RWA_totali_annui_medi_totale__c = null;
            cloneSim[0].capitaleAssorbitoMedio__c = null;
            cloneSim[0].RWA_totali_annui_max__c = null;
            cloneSim[0].Capitale_assorbito_max__c = null;
            cloneSim[0].RWA_Medio_perc__c = null;
            cloneSim[0].Present_NOPAT__c = null;
            cloneSim[0].Present_EVA__c = null;
            cloneSim[0].Present_RACE__c = null;
            cloneSim[0].Present_RARORAC__c = null;
            cloneSim[0].smlAttTotal__c = null;
            cloneSim[0].accordatoAttTotal__c = null;
            cloneSim[0].Sprad_EVA_neutral__c = null;
            cloneSim[0].Duration_finanziaria_in_anni__c = null;
            cloneSim[0].Interessi_attivi1__c = null;
            cloneSim[0].Costo_del_funding1__c = null;
            cloneSim[0].Margine_di_interesse1__c = null;
            cloneSim[0].Commissioni_up_front1__c = null;
            cloneSim[0].Commissioni_running1__c = null;
            cloneSim[0].Commissioni_altro1__c = null;
            cloneSim[0].Commissioni1__c = null;
            cloneSim[0].Margine_di_intermediazione1__c = null;
            cloneSim[0].Costo_del_rischio_lordo1__c = null;
            cloneSim[0].Costo_del_capitale1__c = null;
            cloneSim[0].Costi_operativi1__c = null;
            cloneSim[0].Margine_operativo_netto1__c = null;
            cloneSim[0].Erogato1__c = null;
            cloneSim[0].SML1__c = null;
            cloneSim[0].EAD1__c = null;
            cloneSim[0].RWA_rischio_di_credito1__c = null;
            cloneSim[0].RWA_rischio_operativo1__c = null;
            cloneSim[0].RWA_totale1__c = null;
            cloneSim[0].Capitale_Assorbito1__c = null;
            cloneSim[0].NOPAT_anno1__c = null;
            cloneSim[0].EVA1__c = null;
            cloneSim[0].RACE1__c = null;
            cloneSim[0].RARORAC1__c = null;
            cloneSim[0].Data_Invio_Pricing__c = null;
            insert cloneSim;

            List<Linea__c> cloneLinee = new List<Linea__c>();
            List<RataLinea__c> clonerateLinee = new List<RataLinea__c>();
            Map<Decimal, List<RataLinea__c>> oldLineaMap = new Map<Decimal, List<RataLinea__c>>();
            for(Linea__c linea : originalSim[0].Linee__r){
                Linea__c cloneLinea = linea.clone(false, false, false, false);
                cloneLinea.Simulazione__c = cloneSim[0].Id;
                cloneLinea.RecordTypeId = recTypeInputLinea;
                cloneLinea.idAmmortamentoLinea__c = null;
                cloneLinea.TIT_base_di_partenza__c = null;
                cloneLinea.TIT_base_medio__c = null;
                cloneLinea.Funding_spread__c = null;
                cloneLinea.TIT__c = null;
                cloneLinea.Costi_operativi_effettivi__c = null;
                cloneLinea.costiDelRischioEffettivo__c = null;
                cloneLinea.Costo_fiscale__c = null;
                cloneLinea.Costo_del_capitale_effettivo__c = null;
                cloneLinea.Tasso_di_break_even__c = null;
                cloneLinea.Differenza_tra_break_even_e_tasso_applic__c = null;
                cloneLinea.tassoFissoCommissioneTassoVariabile__c = null;
                cloneLinea.Tasso_variabile_medio_applicato__c = null;
                cloneLinea.Componente_commissionale_media_annua__c = null;
                cloneLinea.Add_on_commissionale_medio_annuo__c = null;
                cloneLinea.Tasso_all_in__c = null;
                cloneLinea.Interessi_attivi_1anno__c = null;
                cloneLinea.Costo_del_funding_1anno__c = null;
                cloneLinea.Margine_di_interesse_1anno__c = null;
                cloneLinea.Commissioni_up_front_1anno__c = null;
                cloneLinea.Commissioni_running_1anno__c = null;
                cloneLinea.Commissioni_altro_1anno__c = null;
                cloneLinea.CommissioniTotali1anno__c = null;
                cloneLinea.Margine_di_intermediazione_1anno__c = null;
                cloneLinea.Costo_del_rischio_lordo_1anno__c = null;
                cloneLinea.Costo_del_capitale_1anno__c = null;
                cloneLinea.Costi_operativi_1anno__c = null;
                cloneLinea.Margine_operativo_netto_1anno__c = null;
                cloneLinea.Erogato_1anno__c = null;
                cloneLinea.SML_1anno__c = null;
                cloneLinea.EAD__c = null;
                cloneLinea.RWA_rischio_di_credito_1anno__c = null;
                cloneLinea.RWA_rischio_operativo_1anno__c = null;
                cloneLinea.RWA_totale_1anno__c = null;
                cloneLinea.Capitale_Assorbito_1anno__c = null;
                cloneLinea.NOPAT_1anno__c = null;
                cloneLinea.RACE_1anno__c = null;
                cloneLinea.EVA__c = null;
                cloneLinea.RARORAC_1anno__c = null;
                cloneLinea.Interessi_attivi__c = null;
                cloneLinea.Costo_del_funding__c = null;
                cloneLinea.Margine_di_interesse__c = null;
                cloneLinea.Commissioni_up_front__c = null;
                cloneLinea.Commissioni_running__c = null;
                cloneLinea.Commissioni_altro__c = null;
                cloneLinea.Commissioni_Totali__c = null;
                cloneLinea.Margine_di_intermediazione__c = null;
                cloneLinea.Costo_del_rischio_lordo__c = null;
                cloneLinea.Costo_del_capitale__c = null;
                cloneLinea.Costi_operativi__c = null;
                cloneLinea.Margine_operativo_netto__c = null;
                cloneLinea.SML_annuo_medio__c = null;
                cloneLinea.EAD_annua_media__c = null;
                cloneLinea.RWA_rischio_di_credito_annui_medi__c = null;
                cloneLinea.RWA_rischio_operativo_annui_medi__c = null;
                cloneLinea.rwaRischioDiCreditoAnnuoTotal__c = null;
                cloneLinea.rwaRischioOperativoAnnuoTotal__c = null;
                cloneLinea.RWA_totali_annui_medi__c = null;
                cloneLinea.Capitale_assorbito_medio__c = null;
                cloneLinea.RWA_totali_annui_max__c = null;
                cloneLinea.Capitale_assorbito_max__c = null;
                cloneLinea.Present_NOPAT_vitaintera__c = null;
                cloneLinea.Present_EVA_vitaintera__c = null;
                cloneLinea.Present_RACE_vitaintera__c = null;
                cloneLinea.Present_RARORAC_vitaintera__c = null;
                cloneLinea.smlAttTotal__c = null;
                cloneLinea.accordatoAttTotal__c = null;
                cloneLinea.Sprad_EVA_neutral__c = null;
                cloneLinea.Duration_finanziaria_in_anni__c = null;
                cloneLinea.RWA_Medio__c = null;
                cloneLinea.Costo_del_capitale_sintesi__c = null;
                cloneLinea.Present_NOPAT__c = null;
                cloneLinea.Present_EVA__c = null;
                cloneLinea.Present_RACE__c = null;
                cloneLinea.Present_RARORAC__c = null;
                cloneLinea.SensitivityMargineRARORACPiu30__c = null;
                cloneLinea.SensitivityMargineRARORACPiu20__c = null;
                cloneLinea.SensitivityMargineRARORACPiu10__c = null;
                cloneLinea.SensitivityMargineRARORACMeno10__c = null;
                cloneLinea.SensitivityMargineRARORACMeno20__c = null;
                cloneLinea.SensitivityMargineRARORACMeno30__c = null;
                cloneLinea.SensitivityMargineRACEPiu30__c = null;
                cloneLinea.SensitivityMargineRACEPiu20__c = null;
                cloneLinea.SensitivityMargineRACEPiu10__c = null;
                cloneLinea.SensitivityMargineRACEMeno10__c = null;
                cloneLinea.SensitivityMargineRACEMeno20__c = null;
                cloneLinea.SensitivityMargineRACEMeno30__c = null;
                cloneLinea.SensitivityCMURARORACPiu30__c = null;
                cloneLinea.SensitivityCMURARORACPiu20__c = null;
                cloneLinea.SensitivityCMURARORACPiu10__c = null;
                cloneLinea.SensitivityCMURARORACMeno10__c = null;
                cloneLinea.SensitivityCMURARORACMeno20__c = null;
                cloneLinea.SensitivityCMURARORACMeno30__c = null;
                cloneLinea.SensitivityCMURACEPiu30__c = null;
                cloneLinea.SensitivityCMURACEPiu20__c = null;
                cloneLinea.SensitivityCMURACEPiu10__c = null;
                cloneLinea.SensitivityCMURACEMeno10__c = null;
                cloneLinea.SensitivityCMURACEMeno20__c = null;
                cloneLinea.SensitivityCMURACEMeno30__c = null;
                cloneLinea.SensitivityUPfrontRARORACPiu30__c = null;
                cloneLinea.SensitivityUPfrontRARORACPiu20__c = null;
                cloneLinea.SensitivityUPfrontRARORACPiu10__c = null;
                cloneLinea.SensitivityUPfrontRARORACMeno10__c = null;
                cloneLinea.SensitivityUPfrontRARORACMeno20__c = null;
                cloneLinea.SensitivityUPfrontRARORACMeno30__c = null;
                cloneLinea.SensitivityUpFrontRACEPiu30__c = null;
                cloneLinea.SensitivityUpFrontRACEPiu20__c = null;
                cloneLinea.SensitivityUpFrontRACEPiu10__c = null;
                cloneLinea.SensitivityUpFrontRACEMeno10__c = null;
                cloneLinea.SensitivityUpFrontRACEMeno20__c = null;
                cloneLinea.SensitivityUpFrontRACEMeno30__c = null;
                cloneLinea.Condizione_di_BE__c = null;
                cloneLinea.addOnCommissionaleEuro__c = null;
                cloneLinea.addOnCommissionalePercentuale__c = null;
                cloneLinea.commissioniUpFrontBpsMediLongLife__c = null;
                cloneLinea.commissioniRunningBpsMediLongLife__c = null;
                cloneLinea.commissioniAddOnEuroLongLife__c = null;
                cloneLinee.add(cloneLinea);
                if(rateLineaMap.containsKey(linea.Id)){
                    oldLineaMap.put(linea.Number__c, (List<RataLinea__c>)rateLineaMap.get(linea.Id));
                }
            }
            insert cloneLinee;
            
            for(Linea__c linea : cloneLinee){
                if(oldLineaMap.containsKey(linea.Number__c)){
                    for(RataLinea__c rata : oldLineaMap.get(linea.Number__c)){
                        RataLinea__c cloneRataLinea = rata.clone(false, false, false, false);
                        cloneRataLinea.Linea__c = linea.Id;
                        clonerateLinee.add(cloneRataLinea);
                    }
                }
            }
            insert clonerateLinee;
            return cloneSim[0].Id;
        } catch (Exception e) {
            // Rollback to the previous null value
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage() + '; at: ' + e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void calculateSim(Simulazione__c sim, List<Linea__c> simLinee){
        System.debug('DK sim: ' + JSON.serialize(sim));
        System.debug('DK simLinee: ' + JSON.serialize(simLinee));
        String recTypeOutputSim = SV_Utilities.getRecordTypeByDeveloperName('Simulazione__c', 'Output');
        String recTypeOutputLinea = SV_Utilities.getRecordTypeByDeveloperName('Linea__c', 'Output');
        Savepoint sp = Database.setSavepoint();
        try {
            sim.RecordTypeId = recTypeOutputSim;
            for(Linea__c linea : simLinee){
                System.debug('DK linea: ' + JSON.serialize(linea));
                linea.RecordTypeId = recTypeOutputLinea;
            }
            System.debug('DK sim FINAL: ' + JSON.serialize(sim));
            System.debug('DK simLinee FINAL: ' + JSON.serialize(simLinee));
            update sim;
            update simLinee;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteSim(String recordId){
        delete [SELECT Id FROM Simulazione__c WHERE ID =: recordId];
    }

    @AuraEnabled
    public static void deleteLinea(String recordId){
        delete [SELECT Id FROM Linea__c WHERE ID =: recordId];
    }
}