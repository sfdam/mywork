/* AL 2024-02-28 -- Uso di liste per costruire la query e aggiunta campi Simulazione__r.Interessi_attivi1__c,Simulazione__r.Costo_del_funding1__c,Sensitivity__c,Commissioni_Totali__c
        e far tornare il valore di Periodicita_rata__c*/
public with sharing class CIB_SintesiSimulazioneController {

    @AuraEnabled(cacheable=true)
    public static WrapperResults getLinee(Id recordId, String objName){
        WrapperResults wResult = new WrapperResults();
        System.debug('AAA '+recordId);
        System.debug('AAA '+objName);
        // AL 2024-02-28 -- Uso di liste per costruire la query e aggiunta campi Simulazione__r.Interessi_attivi1__c,Simulazione__r.Costo_del_funding1__c,Sensitivity__c,Commissioni_Totali__c
        // e far tornare il valore di Periodicita_rata__c
        List<String> lineaFields = new List<String>{'Id','Name','Formatecnica__c','toLabel(Tipo_di_ammortamento__c)' ,'Importo__c',
            'Tipo_funding__c','Valuta__c','UtilizzoPercentuale__c','toLabel(Durata__c)','Duration_finanziaria_in_anni__c',
            'toLabel(Periodicita_rata__c)','PresenzaPreammortamento__c','Periodi_di_preammortamento__c','baloonFinalePercentuale__c','SAL__c','toLabel(Tipo_tasso__c)',
            'Indicizzazionetassovariabile__c','Capvalore__c','Floorvalore__c','Intereststep__c','TIT_base_di_partenza__c',
            'Up_Front_perc__c','Up_Front__c','CMUannuale__c','Commissione_running_annuale_perc__c','Commissione_running_annuale__c',
            'Add_on_commissionale_medio_annuo__c','Garanzia__c','Tipo_garanzia__c','Valore_del_bene_ipotecato__c',
            'Valore_del_pegno_SACE__c','commissioneDiFirma__c','Commissioni_up_front__c','Commissioni_running__c',
            'Interessi_attivi__c','Costo_del_funding__c','Margine_di_interesse__c','Commissioni_altro__c','Commissioni__c',
            'Margine_di_intermediazione__c','Costo_del_rischio_lordo__c','Costo_del_capitale__c','Costi_operativi__c',
            'Margine_operativo_netto__c','SML_annuo_medio__c','EAD_annua_media__c','RWA_Medio__c','Present_NOPAT__c',
            'Present_EVA__c','Present_RACE__c','Present_RARORAC__c','RWA_rischio_di_credito_annui_medi__c','RWA_rischio_operativo_annui_medi__c',
            'RWA_totali_annui_medi__c','Capitale_assorbito_medio__c','Numero_periodi_di_erogazione__c','Spread_TassoFisso_Commdifirma__c',
            'Valore_del_PegnoSACE_Perc__c','Interessi_attivi_1anno__c','Costo_del_funding_1anno__c','Margine_di_interesse_1anno__c','Commissioni_up_front_1anno__c',
            'Commissioni_running_1anno__c','Commissioni_altro_1anno__c','Commissioni_1anno__c','Margine_di_intermediazione_1anno__c',
            'Costo_del_rischio_lordo_1anno__c','Costo_del_capitale_1anno__c','Costi_operativi_1anno__c','Margine_operativo_netto_1anno__c','Erogato_1anno__c','SML_1anno__c','EAD__c',
            'RWA_rischio_di_credito_1anno__c','RWA_rischio_operativo_1anno__c','RWA_totale_1anno__c','Capitale_Assorbito_1anno__c','NOPAT_1anno__c','EVA__c','RACE_1anno__c','RARORAC_1anno__c',
            'Condizione_di_BE__c','RWA_totali_annui_max__c','Capitale_assorbito_max__c','commissioniUpFrontBpsMediLongLife__c','commissioniRunningBpsMediLongLife__c',
            'commissioniAddOnEuroLongLife__c','SensitivityMargineRARORACPiu30__c','SensitivityMargineRARORACPiu20__c','SensitivityMargineRARORACPiu10__c',
            'SensitivityMargineRARORACMeno10__c','SensitivityMargineRARORACMeno20__c','SensitivityMargineRARORACMeno30__c','SensitivityCMURARORACPiu30__c','SensitivityCMURARORACPiu20__c','SensitivityCMURARORACPiu10__c',
            'SensitivityCMURARORACMeno10__c','SensitivityCMURARORACMeno20__c','SensitivityCMURARORACMeno30__c','SensitivityUPfrontRARORACPiu30__c','SensitivityUPfrontRARORACPiu20__c',
            'SensitivityUPfrontRARORACPiu10__c','SensitivityUPfrontRARORACMeno10__c','SensitivityUPfrontRARORACMeno20__c','SensitivityUPfrontRARORACMeno30__c','SensitivityMargineRACEPiu30__c',
            'SensitivityMargineRACEPiu20__c','SensitivityMargineRACEPiu10__c','SensitivityMargineRACEMeno10__c','SensitivityMargineRACEMeno20__c','SensitivityMargineRACEMeno30__c','SensitivityCMURACEPiu30__c',
            'SensitivityCMURACEPiu20__c','SensitivityCMURACEPiu10__c','SensitivityCMURACEMeno10__c','SensitivityCMURACEMeno20__c','SensitivityCMURACEMeno30__c','SensitivityUpFrontRACEPiu30__c','SensitivityUpFrontRACEPiu20__c',
            'SensitivityUpFrontRACEPiu10__c','SensitivityUpFrontRACEMeno10__c','SensitivityUpFrontRACEMeno20__c','SensitivityUpFrontRACEMeno30__c','Simulazione__c','Sensitivity__c','Commissioni_Totali__c','toLabel(Utilizzo__c)',
            'CommissioniTotali1anno__c','Altroesderivato__c','Altro_es_derivato_perc__c'
            };
            List<String> simulazioneFields = new List<String>{
                'Simulazione__r.Costo_del_funding_totale__c','Simulazione__r.Margine_di_interesse_totale__c','Simulazione__r.Commissioni_Up_Front_Totale__c',
                'Simulazione__r.Commissioni_Running_Totale__c','Simulazione__r.Commissioni_Altro_Totale__c','Simulazione__r.Commissioni_Totali__c',
                'Simulazione__r.Margine_di_intermediazione_Totale__c','Simulazione__r.Costo_del_Rischio_Lordo_Totale__c','Simulazione__r.Costo_del_capitale_totale__c',
                'Simulazione__r.Costi_operativi_totali__c','Simulazione__r.Margine_operativo_netto_totale__c','Simulazione__r.SML_annuo_medio_totale__c',
                'Simulazione__r.EAD_annua_media_totale__c','Simulazione__r.rwa_Rischio_Di_Credito_Annuo_Medio__c','Simulazione__r.RWA_rischio_operativo_annui_medio__c',
                'Simulazione__r.RWA_totali_annui_medi_totale__c','Simulazione__r.capitaleAssorbitoMedio__c','Simulazione__r.Present_NOPAT__c','Simulazione__r.Present_EVA__c',
                'Simulazione__r.Present_RACE__c','Simulazione__r.Present_RARORAC__c','Simulazione__r.Margine_di_interesse1__c','Simulazione__r.Commissioni_up_front1__c',
                'Simulazione__r.Commissioni_running1__c','Simulazione__r.Commissioni_altro1__c','Simulazione__r.Commissioni1__c','Simulazione__r.Margine_di_intermediazione1__c',
                'Simulazione__r.Costo_del_rischio_lordo1__c','Simulazione__r.Costo_del_capitale1__c','Simulazione__r.Costi_operativi1__c','Simulazione__r.Margine_operativo_netto1__c',
                'Simulazione__r.Erogato1__c','Simulazione__r.SML1__c','Simulazione__r.EAD1__c','Simulazione__r.RWA_rischio_di_credito1__c','Simulazione__r.RWA_rischio_operativo1__c',
                'Simulazione__r.RWA_totale1__c','Simulazione__r.Capitale_Assorbito1__c','Simulazione__r.NOPAT_anno1__c','Simulazione__r.EVA1__c','Simulazione__r.RACE1__c',
                'Simulazione__r.RARORAC1__c','Simulazione__r.RWA_Medio_perc__c','Simulazione__r.RWA_totali_annui_max__c','Simulazione__r.Capitale_assorbito_max__c',
                'Simulazione__r.Interessi_attivi1__c','Simulazione__r.Costo_del_funding1__c','Simulazione__r.Interessi_attivi_totali__c'
            };
        try {
            String query ='SELECT ' + String.join(lineaFields,',')+','+String.join(simulazioneFields,',');
            // AL 2024-02-28 -- Fine
            query += ' FROM Linea__c';
            if(objName == 'Simulazione__c'){
                query += ' WHERE Simulazione__c =\'' + recordId + '\'';
            }else if(objName == 'Linea__c'){
                query += ' WHERE Id =\'' + recordId + '\'';
            }
            query += ' ORDER BY Name LIMIT 5';
            System.debug('AAA ' + query);
            wResult.lineas = Database.query(query);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('AAA '+wResult);
        return wResult;
    }

    public class WrapperResults {
        @AuraEnabled public List<Linea__c> lineas    {get; set;}

        public WrapperResults() {
            lineas = new List<Linea__c>();
        }
    }
}