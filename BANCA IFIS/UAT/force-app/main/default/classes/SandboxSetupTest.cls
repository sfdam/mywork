@isTest
class SandboxSetupTest {
    
    @isTest
    static void testSandboxSetup() {
        String endpointServiziName = 'ESTest';
        String usernameSuffix = 'UsernameSuffixTest';
        
        // preparo i dati di test
        insert new EndpointServizi__c(Name = endpointServiziName);
        
        Funzionalita__c f = Funzionalita__c.getInstance();
        f.DisabilitaInvioEmail__c = false;
        upsert f;
        
        ParametriTiAnticipo__c p = ParametriTiAnticipo__c.getInstance();
        p.UsernameSuffix__c = usernameSuffix;
        upsert p;
        
        // eseguo SanboxSetup
        Test.startTest();
        Test.testSandboxPostCopyScript(new SandboxSetup(), UserInfo.getOrganizationId(), UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        Test.stopTest();
        
        // controllo i dati
        String sandboxUrl = System.Url.getSalesforceBaseURL().getHost();
        String[] sandboxUrlSections = sandboxUrl.split('\\.');
        String sandboxName = sandboxUrlSections[0].substringAfter('--');
        String sandboxInstance = sandboxUrlSections[1];
        
        EndpointServizi__c es = [SELECT Id,
                                 Name,
                                 LAGKeyHeroku__c,
                                 LAGKey__c,
                                 URLAllineaKnet__c,
                                 URLGetBilancioSinteticoRibes__c,
                                 URLGetEventiNegativiRibes__c,
                                 URLGetInformazioniPGRibes__c,
                                 URLGetListaAziendeRibes__c,
                                 URLModificaDatiAggiuntiviQQ__c,
                                 UrlAggiornamentoStatoCartella__c,
                                 UrlCancellaOggetti__c,
                                 UrlCheckStatoPef__c,
                                 UrlDatiBilancio__c,
                                 UrlDettaglioOggetto__c,
                                 UrlEsistePef__c,
                                 UrlFileNet__c,
                                 UrlGestioneCollNdg__c,
                                 UrlGetDatiAnagraficiCedacri__c,
                                 UrlInfoCr__c,
                                 UrlInterrogazioneBilanci__c,
                                 UrlNvAggiornamentoInnescaVendita__c,
                                 UrlNvInquiryStatoCartella__c,
                                 UrlRenderPdf__c,
                                 UrlRicercaAnagraficaCedacri__c,
                                 UrlSearchDocument__c,
                                 UrlSetAnagraficaCedacri__c,
                                 UrlSetAnagraficaLight__c,
                                 UrlSetAnagraficaVariazione__c,
                                 UrlSetRetianagraficheIfis__c,
                                 UserIdOverride__c,
                                 UrlLogger__c,
                                 UrlCertificazioneParser__c,
                                 UrlDocumentiTaStatici__c
                                 FROM EndpointServizi__c
                                 WHERE Name = :endpointServiziName
                                ];
        
        System.assertEquals('ext.crm', es.UserIdOverride__c);
        System.assertEquals('B3DAF392-AF8C-4687-8387-48261E9A63FD', es.LAGKeyHeroku__c);
        System.assertEquals('B3DAF392-AF8C-4687-8387-48261E9A63FD', es.LAGKey__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositeservice/setdatianagraficiifis', es.URLAllineaKnet__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/pratica/bilanciosinteticocompositeservice/bilanciosintetico', es.URLGetBilancioSinteticoRibes__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/pratica/eventinegativiflags/get', es.URLGetEventiNegativiRibes__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/pratica/prodottopg/get', es.URLGetInformazioniPGRibes__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/pratica/listaaziende/get', es.URLGetListaAziendeRibes__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/modificadatiaggiuntiviqqcompositeservice/modificadatiaggiuntiviqq', es.URLModificaDatiAggiuntiviQQ__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/pratica/nvaggiornamentostatocartellacompositeservice/nvaggiornamentostatocartella', es.UrlAggiornamentoStatoCartella__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/filenetaggiornamento/cancellaoggetti', es.UrlCancellaOggetti__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/pratica/checkstatopefcompositeservice/checkstatopef', es.UrlCheckStatoPef__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositeservice/datibilancio', es.UrlDatiBilancio__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/dettagliooggettocompositeservice/dettagliooggetto', es.UrlDettaglioOggetto__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/pratica/checkesistenzapefcompositeservice/checkesistenzapef', es.UrlEsistePef__c);
        System.assertEquals('http://filenetp8.collaudo.ced.it', es.UrlFileNet__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/gestionecollndgcompositeservice/gestionecollndg', es.UrlGestioneCollNdg__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositeservice/getdatianagraficicedacri', es.UrlGetDatiAnagraficiCedacri__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/posizionerischio/primainformazionecrcompositeservice/primainformazionecr', es.UrlInfoCr__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/pratica/bilanci/interrogazionebilanci', es.UrlInterrogazioneBilanci__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/pratica/nvaggiornamentoinnescavenditacompositeservice/nvaggiornamentoinnescavendita', es.UrlNvAggiornamentoInnescaVendita__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/pratica/nvinquirystatocartellacompositeservice/nvinquirystatocartella', es.UrlNvInquiryStatoCartella__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/pratica/adobecompositeservice/renderpdf', es.UrlRenderPdf__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/ricercaanagraficacedacricompositeservice/ricercaanagraficacedacri', es.UrlRicercaAnagraficaCedacri__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/documentmanager/ricercadocumenti/searchdocument', es.UrlSearchDocument__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/setanagraficacedacricompositeservice/setanagraficacedacri', es.UrlSetAnagraficaCedacri__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/setanagraficalightcompositeservice/setanagraficalight', es.UrlSetAnagraficaLight__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/anagrafevariazionecompositeservice/setanagraficavariazione', es.UrlSetAnagraficaVariazione__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/anagrafica/anagraficacompositeservice/setretianagraficheifis', es.UrlSetRetianagraficheIfis__c);
        System.assertEquals('ext.crm', es.UserIdOverride__c);
        System.assertEquals('https://' + sandboxUrl, es.UrlLogger__c);
        System.assertEquals('https://uatservices.bancaifis.it/arch/lag/proxy/factoring/crediticertificati/parsecertificazione', es.UrlCertificazioneParser__c);
        System.assertEquals('https://www.tianticipo.it/documenti', es.UrlDocumentiTaStatici__c);
        
        f = Funzionalita__c.getInstance();
        System.assert(f.DisabilitaInvioEmail__c);
        
        // WIP
        // ParametriTiAnticipo__c[] parametriTiAnticipo = [SELECT Id, UsernameSuffix__c FROM ParametriTiAnticipo__c];
        // for (ParametriTiAnticipo__c pTa : parametriTiAnticipo) {
        //   System.assertEquals(sandboxName, pTa.UsernameSuffix__c);
        // }
    }
}