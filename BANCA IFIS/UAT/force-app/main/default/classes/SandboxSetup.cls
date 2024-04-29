global class SandboxSetup implements SandboxPostCopy {
    
    global void runApexClass(SandboxContext context) {
        System.debug('Org ID: ' + context.organizationId());
        System.debug('Sandbox ID: ' + context.sandboxId());
        System.debug('Sandbox Name: ' + context.sandboxName());
        
        String sandboxUrl = System.Url.getSalesforceBaseURL().getHost();
        String[] sandboxUrlSections = sandboxUrl.split('\\.');
        String sandboxName = sandboxUrlSections[0].substringAfter('--');
        String sandboxInstance = sandboxUrlSections[1];
        
        // EndpointServizi
        EndpointServizi__c[] endpointServizi = [SELECT Id FROM EndpointServizi__c];
        for (EndpointServizi__c es : endpointServizi) {
            es.LAGKeyHeroku__c = 'B3DAF392-AF8C-4687-8387-48261E9A63FD';
            es.LAGKey__c = 'B3DAF392-AF8C-4687-8387-48261E9A63FD';
            es.URLAllineaKnet__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositeservice/setdatianagraficiifis';
            es.URLGetBilancioSinteticoRibes__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/bilanciosinteticocompositeservice/bilanciosintetico';
            es.URLGetEventiNegativiRibes__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/eventinegativiflags/get';
            es.URLGetInformazioniPGRibes__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/prodottopg/get';
            es.URLGetListaAziendeRibes__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/listaaziende/get';
            es.URLModificaDatiAggiuntiviQQ__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/modificadatiaggiuntiviqqcompositeservice/modificadatiaggiuntiviqq';
            es.UrlAggiornamentoStatoCartella__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/nvaggiornamentostatocartellacompositeservice/nvaggiornamentostatocartella';
            es.UrlCancellaOggetti__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/filenetaggiornamento/cancellaoggetti';
            es.UrlCheckStatoPef__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/checkstatopefcompositeservice/checkstatopef';
            es.UrlDatiBilancio__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositeservice/datibilancio';
            es.UrlDettaglioOggetto__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/dettagliooggettocompositeservice/dettagliooggetto';
            es.UrlEsistePef__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/checkesistenzapefcompositeservice/checkesistenzapef';
            es.UrlFileNet__c = 'http://filenetp8.collaudo.ced.it';
            es.UrlGestioneCollNdg__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/gestionecollndgcompositeservice/gestionecollndg';
            es.UrlGetDatiAnagraficiCedacri__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositeservice/getdatianagraficicedacri';
            es.UrlInfoCr__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/posizionerischio/primainformazionecrcompositeservice/primainformazionecr';
            es.UrlInterrogazioneBilanci__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/bilanci/interrogazionebilanci';
            es.UrlNvAggiornamentoInnescaVendita__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/nvaggiornamentoinnescavenditacompositeservice/nvaggiornamentoinnescavendita';
            es.UrlNvInquiryStatoCartella__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/nvinquirystatocartellacompositeservice/nvinquirystatocartella';
            es.UrlRenderPdf__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/adobecompositeservice/renderpdf';
            es.UrlRicercaAnagraficaCedacri__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/ricercaanagraficacedacricompositeservice/ricercaanagraficacedacri';
            es.UrlSearchDocument__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/ricercadocumenti/searchdocument';
            es.UrlSetAnagraficaCedacri__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/setanagraficacedacricompositeservice/setanagraficacedacri';
            es.UrlSetAnagraficaLight__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/setanagraficalightcompositeservice/setanagraficalight';
            es.UrlSetAnagraficaVariazione__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/anagrafevariazionecompositeservice/setanagraficavariazione';
            es.UrlSetRetianagraficheIfis__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositeservice/setretianagraficheifis';
            es.UrlCalcoloC138Debitore__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/knt/calcolocommissioneeffettiva';
            es.UserIdOverride__c = 'ext.crm';
            es.UrlLogger__c = 'https://' + sandboxUrl;
            es.UrlCertificazioneParser__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/factoring/crediticertificati/parsecertificazione';
            es.UrlDocumentiTaStatici__c = 'https://www.tianticipo.it/documenti';
            //adione-CRM20
            es.WGC_Url_Doc01__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/filenetaggiornamento/aggiungioggetti';
            es.WGC_Url_PEF41__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/rinnovopef';
            es.URL_Aggiorna_Campi_Prodotti_Posizione__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/posizione';
            es.WGC_Url_ANAG70__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/posizionerischio/relazioni/inserimento';
            es.UrlCalcoloC138Debitore__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/knt/calcolocommissioneeffettiva';
            es.WGC_Url_Dati_Bilancio__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/multibilanciosintetico/retrieve';
            es.WGC_Url_Dati_PEF__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/datipef';
            es.WGC_Url_Doc08__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/ricercadocumenti/ottienidocumentipdf';
            es.WGC_Url_Doc10__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/checklistdocuments/retrieve';
            es.WGC_Url_Doc11__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/documentcomposition/savepdf';
            es.WGC_Url_PEF38__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/parametricondizioni';
            es.WGC_Url_Ricerca_multipla_documenti__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/ricercadocumenti/multisearchdocument';
            es.WGC_Url_PEF40__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/canale';
            es.WGC_CalcoloCompensi__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/bankmanagement/fastfinance/calcolacompensi';
            es.WGC_CalcoloInteressi__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/bankmanagement/fastfinance/calcinteressi';
            es.WGC_CalcoloDIP__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/bankmanagement/fastfinance/calcdip';
            es.WGC_CalcoloIRR__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/bankmanagement/fastfinance/prospettoirr';
            es.WGC_CensimentoTratt__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/bankmanagement/fastfinance/instrattativa';
            es.WGC_ConfermaTratt__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/bankmanagement/fastfinance/apricommessa';
            es.WGC_Url_Dati_PEF_FF__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/clonedatipef';
            es.WGC_Url_PEF41_FF__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/pratica/lineacredito/rinnovopef';
            es.WGC_Url_Doc_61__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/routed/downloaddocument';
            es.WGC_Url_Doc62__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/routed/uploaddocument';
            es.WGC_Url_Anag11__c = 'https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositeservice/elencorapporti';
        }
        update endpointServizi;
        
        // Funzionalità
        Funzionalita__c[] funzionalita = [SELECT Id FROM Funzionalita__c];
        for (Funzionalita__c f : funzionalita) {
            f.DisabilitaInvioEmail__c = true;
        }
        update funzionalita;
        
        // Parametri TiAnticipo
        ParametriTiAnticipo__c[] parametriTiAnticipo = [SELECT Id FROM ParametriTiAnticipo__c];
        for (ParametriTiAnticipo__c pTa : parametriTiAnticipo) {
            pTa.UsernameSuffix__c = 'ta.' + sandboxName;
        }
        update parametriTiAnticipo;
    }
}