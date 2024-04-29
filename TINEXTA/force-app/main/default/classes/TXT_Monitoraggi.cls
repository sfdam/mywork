public without sharing class TXT_Monitoraggi implements Queueable, Database.AllowsCallouts{

    // // TESTING FAKE RESPONSE
    // // public static String DummyMonitoring = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">   <soapenv:Body>      <ns:getListaMonitoraggiResponse xmlns:ns="urn:ws.ribes.it/BInformationV4">         <ns:return>            <WSRBS>               <TRANSAZIONE data="2021-08-12T09:56:11.728+02:00">                  <ESITO codice="0">OK</ESITO>                  <RICHIESTA>                     <PARAM nome="userID">TINEXTA-WS</PARAM>                     <PARAM nome="ticketID">31004</PARAM>                     <PARAM nome="tipoElenco">Monitoraggi</PARAM>                     <PARAM nome="pagina">0</PARAM>                  </RICHIESTA>                  <TICKETID>31004</TICKETID>                  <RISPOSTA>                     <Prodotto>                        <Lista>                           <ListaMonitoraggi numeroPosizioniTotali="6" idRicerca="31004">                              <Soggetto idBicSoggetto="139305">                                 <InfoImpresa codiceAziendaCliente="?">                                    <Denominazione>MERLONI HOLDING S.P.A.</Denominazione>                                    <KRea>                                       <Cciaa sigla="AN"/>                                       <NRea>156664</NRea>                                    </KRea>                                    <Sede>                                       <Provincia sigla="AN"/>                                       <Comune>FABRIANO</Comune>                                       <Indirizzo>VIALE A. MERLONI, 45 - 60044</Indirizzo>                                    </Sede>                                    <CodiceFiscale>11142780151</CodiceFiscale>                                 </InfoImpresa>                                 <ElencoProdotti>                                    <Prodotto codice="BIWKR" descrizione="Key Report">                                       <TipoRichiesta>RM</TipoRichiesta>                                       <DataRichiesta>2021-07-09</DataRichiesta>                                       <Monitoraggio monitID="80066" attivo="S" scadenza="2022-07-09" tipoMonitoraggio="A" tipoRinnovo="A"/>                                    </Prodotto>                                 </ElencoProdotti>                              </Soggetto>                              <Soggetto idBicSoggetto="139305">                                 <InfoImpresa codiceAziendaCliente="?">                                    <Denominazione>MERLONI HOLDING S.P.A.</Denominazione>                                    <KRea>                                       <Cciaa sigla="AN"/>                                       <NRea>156664</NRea>                                    </KRea>                                    <Sede>                                       <Provincia sigla="AN"/>                                       <Comune>FABRIANO</Comune>                                       <Indirizzo>VIALE A. MERLONI, 45 - 60044</Indirizzo>                                    </Sede>                                    <CodiceFiscale>11142780151</CodiceFiscale>                                 </InfoImpresa>                                 <ElencoProdotti>                                    <Prodotto codice="BIWKR" descrizione="Key Report">                                       <TipoRichiesta>RM</TipoRichiesta>                                       <DataRichiesta>2021-07-09</DataRichiesta>                                       <Monitoraggio monitID="80066" attivo="S" scadenza="2022-07-09" tipoMonitoraggio="A" tipoRinnovo="A"/>                                    </Prodotto>                                 </ElencoProdotti>                              </Soggetto>							  <Soggetto idBicSoggetto="139305">                                 <InfoImpresa codiceAziendaCliente="?">                                    <Denominazione>MERLONI HOLDING S.P.A.</Denominazione>                                    <KRea>                                       <Cciaa sigla="AN"/>                                       <NRea>156664</NRea>                                    </KRea>                                    <Sede>                                       <Provincia sigla="AN"/>                                       <Comune>FABRIANO</Comune>                                       <Indirizzo>VIALE A. MERLONI, 45 - 60044</Indirizzo>                                    </Sede>                                    <CodiceFiscale>11142780151</CodiceFiscale>                                 </InfoImpresa>                                 <ElencoProdotti>                                    <Prodotto codice="BIWKR" descrizione="Key Report">                                       <TipoRichiesta>RM</TipoRichiesta>                                       <DataRichiesta>2021-07-09</DataRichiesta>                                       <Monitoraggio monitID="80066" attivo="S" scadenza="2022-07-09" tipoMonitoraggio="A" tipoRinnovo="A"/>                                    </Prodotto>                                 </ElencoProdotti>                              </Soggetto>							  <Soggetto idBicSoggetto="139305">                                 <InfoImpresa codiceAziendaCliente="?">                                    <Denominazione>MERLONI HOLDING S.P.A.</Denominazione>                                    <KRea>                                       <Cciaa sigla="AN"/>                                       <NRea>156664</NRea>                                    </KRea>                                    <Sede>                                       <Provincia sigla="AN"/>                                       <Comune>FABRIANO</Comune>                                       <Indirizzo>VIALE A. MERLONI, 45 - 60044</Indirizzo>                                    </Sede>                                    <CodiceFiscale>11142780151</CodiceFiscale>                                 </InfoImpresa>                                 <ElencoProdotti>                                    <Prodotto codice="BIWKR" descrizione="Key Report">                                       <TipoRichiesta>RM</TipoRichiesta>                                       <DataRichiesta>2021-07-09</DataRichiesta>                                       <Monitoraggio monitID="80066" attivo="S" scadenza="2022-07-09" tipoMonitoraggio="A" tipoRinnovo="A"/>                                    </Prodotto>                                 </ElencoProdotti>                              </Soggetto>							  <Soggetto idBicSoggetto="139305">                                 <InfoImpresa codiceAziendaCliente="?">                                    <Denominazione>MERLONI HOLDING S.P.A.</Denominazione>                                    <KRea>                                       <Cciaa sigla="AN"/>                                       <NRea>156664</NRea>                                    </KRea>                                    <Sede>                                       <Provincia sigla="AN"/>                                       <Comune>FABRIANO</Comune>                                       <Indirizzo>VIALE A. MERLONI, 45 - 60044</Indirizzo>                                    </Sede>                                    <CodiceFiscale>11142780151</CodiceFiscale>                                 </InfoImpresa>                                 <ElencoProdotti>                                    <Prodotto codice="BIWKR" descrizione="Key Report">                                       <TipoRichiesta>RM</TipoRichiesta>                                       <DataRichiesta>2021-07-09</DataRichiesta>                                       <Monitoraggio monitID="80066" attivo="S" scadenza="2022-07-09" tipoMonitoraggio="A" tipoRinnovo="A"/>                                    </Prodotto>                                 </ElencoProdotti>                              </Soggetto>							  <Soggetto idBicSoggetto="139305">                                 <InfoImpresa codiceAziendaCliente="?">                                    <Denominazione>MERLONI HOLDING S.P.A.</Denominazione>                                    <KRea>                                       <Cciaa sigla="AN"/>                                       <NRea>156664</NRea>                                    </KRea>                                    <Sede>                                       <Provincia sigla="AN"/>                                       <Comune>FABRIANO</Comune>                                       <Indirizzo>VIALE A. MERLONI, 45 - 60044</Indirizzo>                                    </Sede>                                    <CodiceFiscale>11142780151</CodiceFiscale>                                 </InfoImpresa>                                 <ElencoProdotti>                                    <Prodotto codice="BIWKR" descrizione="Key Report">                                       <TipoRichiesta>RM</TipoRichiesta>                                       <DataRichiesta>2021-07-09</DataRichiesta>                                       <Monitoraggio monitID="80066" attivo="S" scadenza="2022-07-09" tipoMonitoraggio="A" tipoRinnovo="A"/>                                    </Prodotto>                                 </ElencoProdotti>                              </Soggetto>                           </ListaMonitoraggi>                        </Lista>                     </Prodotto>                  </RISPOSTA>               </TRANSAZIONE>            </WSRBS>         </ns:return>      </ns:getListaMonitoraggiResponse>   </soapenv:Body></soapenv:Envelope>';
    // public static String DummyMonitoring = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><ns:getListaNoteResponse xmlns:ns="urn:ws.ribes.it/BInformationV4"><ns:return><WSRBS><TRANSAZIONE data="2021-09-29T19:02:54.623+02:00"><ESITO codice="0">OK</ESITO><RICHIESTA><PARAM nome="userID">TINEXTA-WS</PARAM><PARAM nome="codiciProdotto">BIWKR</PARAM><PARAM nome="letto">T</PARAM><PARAM nome="archiviata">T</PARAM><PARAM nome="dataRichiestaDal">2021-09-28</PARAM><PARAM nome="dataRichiestaAl">2021-09-28</PARAM><PARAM nome="raggruppaSoggetti">N</PARAM></RICHIESTA><TICKETID>33314</TICKETID><RISPOSTA><Prodotto><Lista><ListaNote numeroPosizioniTotali="6" idRicerca="33314"><Soggetto idBicSoggetto="152617"><InfoImpresa><Denominazione>ACCENTURE TECHNOLOGY SOLUTIONS S.R.L.</Denominazione><KRea><Cciaa sigla="MI"/><NRea>1690901</NRea></KRea><Sede><Provincia sigla="MI"/><Comune>MILANO</Comune><Indirizzo>VIA PRIVATA NINO BONNET, 10 - 20154</Indirizzo></Sede><CodiceFiscale>03646450969</CodiceFiscale></InfoImpresa><ElencoNote><Nota filiale="CDTINEXTA-WS" cessata="N" trasferita="N"><Prodotto codice="BIWKR">Key Report</Prodotto><Monitoraggio tipoMonitoraggio="A" attivo="S" scadenza="2022-09-17" monitID="84402"/><DataNota>2021-09-28</DataNota><IDNota>35994</IDNota><Letta>N</Letta><Archiviata>N</Archiviata><ImportanzaNota>U</ImportanzaNota><PresenzaProdotto>S</PresenzaProdotto><ElencoVariazioniNota codici="035" descrizioniCodici="Nuova unità locale">Unita Locali</ElencoVariazioniNota><FormatiDisponibili>HTML,PDF</FormatiDisponibili></Nota></ElencoNote></Soggetto></ListaNote></Lista></Prodotto></RISPOSTA></TRANSAZIONE></WSRBS></ns:return></ns:getListaNoteResponse></soapenv:Body></soapenv:Envelope>';
    // public static String DummyPage = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">   <soapenv:Body>      <ns:getPaginaResponse xmlns:ns="urn:ws.ribes.it/BInformationV4">         <ns:return>            <WSRBS>               <TRANSAZIONE data="2021-08-12T09:56:11.728+02:00">                  <ESITO codice="0">OK</ESITO>                  <RICHIESTA>                     <PARAM nome="userID">TINEXTA-WS</PARAM>                     <PARAM nome="ticketID">31004</PARAM>                     <PARAM nome="tipoElenco">Monitoraggi</PARAM>                     <PARAM nome="pagina">0</PARAM>                  </RICHIESTA>                  <TICKETID>31004</TICKETID>                  <RISPOSTA>                     <Prodotto>                        <Lista>                           <ListaMonitoraggi numeroPosizioniTotali="99" idRicerca="31004">                              <Soggetto idBicSoggetto="139305">                                 <InfoImpresa codiceAziendaCliente="?">                                    <Denominazione>MERLONI HOLDING S.P.A.</Denominazione>                                    <KRea>                                       <Cciaa sigla="AN"/>                                       <NRea>156664</NRea>                                    </KRea>                                    <Sede>                                       <Provincia sigla="AN"/>                                       <Comune>FABRIANO</Comune>                                       <Indirizzo>VIALE A. MERLONI, 45 - 60044</Indirizzo>                                    </Sede>                                    <CodiceFiscale>11142780151</CodiceFiscale>                                 </InfoImpresa>                                 <ElencoProdotti>                                    <Prodotto codice="BIWKR" descrizione="Key Report">                                       <TipoRichiesta>RM</TipoRichiesta>                                       <DataRichiesta>2021-07-09</DataRichiesta>                                       <Monitoraggio monitID="80066" attivo="S" scadenza="2022-07-09" tipoMonitoraggio="A" tipoRinnovo="A"/>                                    </Prodotto>                                 </ElencoProdotti>                              </Soggetto>							  <Soggetto idBicSoggetto="139305">                                 <InfoImpresa codiceAziendaCliente="?">                                    <Denominazione>MERLONI HOLDING S.P.A.</Denominazione>                                    <KRea>                                       <Cciaa sigla="AN"/>                                       <NRea>156664</NRea>                                    </KRea>                                    <Sede>                                       <Provincia sigla="AN"/>                                       <Comune>FABRIANO</Comune>                                       <Indirizzo>VIALE A. MERLONI, 45 - 60044</Indirizzo>                                    </Sede>                                    <CodiceFiscale>11142780151</CodiceFiscale>                                 </InfoImpresa>                                 <ElencoProdotti>                                    <Prodotto codice="BIWKR" descrizione="Key Report">                                       <TipoRichiesta>RM</TipoRichiesta>                                       <DataRichiesta>2021-07-09</DataRichiesta>                                       <Monitoraggio monitID="80066" attivo="S" scadenza="2022-07-09" tipoMonitoraggio="A" tipoRinnovo="A"/>                                    </Prodotto>                                 </ElencoProdotti>                              </Soggetto>							  <Soggetto idBicSoggetto="139305">                                 <InfoImpresa codiceAziendaCliente="?">                                    <Denominazione>MERLONI HOLDING S.P.A.</Denominazione>                                    <KRea>                                       <Cciaa sigla="AN"/>                                       <NRea>156664</NRea>                                    </KRea>                                    <Sede>                                       <Provincia sigla="AN"/>                                       <Comune>FABRIANO</Comune>                                       <Indirizzo>VIALE A. MERLONI, 45 - 60044</Indirizzo>                                    </Sede>                                    <CodiceFiscale>11142780151</CodiceFiscale>                                 </InfoImpresa>                                 <ElencoProdotti>                                    <Prodotto codice="BIWKR" descrizione="Key Report">                                       <TipoRichiesta>RM</TipoRichiesta>                                       <DataRichiesta>2021-07-09</DataRichiesta>                                       <Monitoraggio monitID="80066" attivo="S" scadenza="2022-07-09" tipoMonitoraggio="A" tipoRinnovo="A"/>                                    </Prodotto>                                 </ElencoProdotti>                              </Soggetto>							  <Soggetto idBicSoggetto="139305">                                 <InfoImpresa codiceAziendaCliente="?">                                    <Denominazione>MERLONI HOLDING S.P.A.</Denominazione>                                    <KRea>                                       <Cciaa sigla="AN"/>                                       <NRea>156664</NRea>                                    </KRea>                                    <Sede>                                       <Provincia sigla="AN"/>                                       <Comune>FABRIANO</Comune>                                       <Indirizzo>VIALE A. MERLONI, 45 - 60044</Indirizzo>                                    </Sede>                                    <CodiceFiscale>11142780151</CodiceFiscale>                                 </InfoImpresa>                                 <ElencoProdotti>                                    <Prodotto codice="BIWKR" descrizione="Key Report">                                       <TipoRichiesta>RM</TipoRichiesta>                                       <DataRichiesta>2021-07-09</DataRichiesta>                                       <Monitoraggio monitID="80066" attivo="S" scadenza="2022-07-09" tipoMonitoraggio="A" tipoRinnovo="A"/>                                    </Prodotto>                                 </ElencoProdotti>                              </Soggetto>							  <Soggetto idBicSoggetto="139305">                                 <InfoImpresa codiceAziendaCliente="?">                                    <Denominazione>MERLONI HOLDING S.P.A.</Denominazione>                                    <KRea>                                       <Cciaa sigla="AN"/>                                       <NRea>156664</NRea>                                    </KRea>                                    <Sede>                                       <Provincia sigla="AN"/>                                       <Comune>FABRIANO</Comune>                                       <Indirizzo>VIALE A. MERLONI, 45 - 60044</Indirizzo>                                    </Sede>                                    <CodiceFiscale>11142780151</CodiceFiscale>                                 </InfoImpresa>                                 <ElencoProdotti>                                    <Prodotto codice="BIWKR" descrizione="Key Report">                                       <TipoRichiesta>RM</TipoRichiesta>                                       <DataRichiesta>2021-07-09</DataRichiesta>                                       <Monitoraggio monitID="80066" attivo="S" scadenza="2022-07-09" tipoMonitoraggio="A" tipoRinnovo="A"/>                                    </Prodotto>                                 </ElencoProdotti>                              </Soggetto>							  <Soggetto idBicSoggetto="139305">                                 <InfoImpresa codiceAziendaCliente="?">                                    <Denominazione>MERLONI HOLDING S.P.A.</Denominazione>                                    <KRea>                                       <Cciaa sigla="AN"/>                                       <NRea>156664</NRea>                                    </KRea>                                    <Sede>                                       <Provincia sigla="AN"/>                                       <Comune>FABRIANO</Comune>                                       <Indirizzo>VIALE A. MERLONI, 45 - 60044</Indirizzo>                                    </Sede>                                    <CodiceFiscale>11142780151</CodiceFiscale>                                 </InfoImpresa>                                 <ElencoProdotti>                                    <Prodotto codice="BIWKR" descrizione="Key Report">                                       <TipoRichiesta>RM</TipoRichiesta>                                       <DataRichiesta>2021-07-09</DataRichiesta>                                       <Monitoraggio monitID="80066" attivo="S" scadenza="2022-07-09" tipoMonitoraggio="A" tipoRinnovo="A"/>                                    </Prodotto>                                 </ElencoProdotti>                              </Soggetto>                           </ListaMonitoraggi>                        </Lista>                     </Prodotto>                  </RISPOSTA>               </TRANSAZIONE>            </WSRBS>         </ns:return>      </ns:getPaginaResponse>   </soapenv:Body></soapenv:Envelope>';

    public List<Map<String,String>> note_REA = new List<Map<String,String>>();
    public List<Map<String,String>> note_REA_Errors = new List<Map<String,String>>();
    public Map<String,String> settings = new Map<String,String>();
    public Integer nPag = 1;
    public String idTicket;

    public TXT_Monitoraggi(List<Map<String,String>> note_REA){
        this.note_REA = note_REA;
        this.settings = TXT_CustomSettings();
    }

    public TXT_Monitoraggi(List<Map<String,String>> note_REA, Integer nPag, String idTicket){
        this.note_REA = note_REA;
        this.nPag = nPag;
        this.idTicket = idTicket;
        this.settings = TXT_CustomSettings();
    }

    public void execute(QueueableContext context){
        // if(this.note_REA.isEmpty()){
        //     System.debug('@@@ nessuna nota');
        //     return;
        // }

        // this.settings = TXT_CustomSettings();

        // Map<String,String> wrapper = this.note_REA.remove(0);
        
        // getProdottoDaNota(wrapper);

        if(!this.note_REA.isEmpty()){
            Map<String,String> wrapper = this.note_REA.remove(0);
            getProdottoDaNota(wrapper);

            if(!Test.isRunningTest()){
                System.enqueueJob(new TXT_Monitoraggi(this.note_REA, this.nPag, this.idTicket));
            }
        } else if(this.note_REA.isEmpty() /*&& !Test.isRunningTest()*/){
            // if(this.nPag != 1) {
            this.nPag++;
            // }
            // if(this.nPag <= 2)
            getNext(this.nPag, this.idTicket);
        }
    }

    public void getNext(Integer nPag, String idTicket) {
        Database.executeBatch(new TXT_Monitoraggi_Helper(nPag, idTicket), 1);
        Database.executeBatch(new TXT_Monitoraggi_SchedulerDelete('SELECT Id, State, StartTime, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name LIKE \'%Innolva Monitoraggi - GetProdottoDaNota%\' AND State = \'DELETED\' ORDER BY CreatedDate ASC'), 10);
    }

    // @future(callout=true)
    // public static void getNextPagina(Integer nPag, String ticketId/*, Id jobToAbort*/) {
    //     System.debug('@@@ getPagina: ' + nPag);
    //     System.debug('@@@ ticketId: ' + ticketId);

    //     // String hour = String.valueOf(Datetime.now().hour());
    //     // String min = String.valueOf(Datetime.now().minute()); 
    //     // String ss = Datetime.now().second() + 5 > 59 ? '59' : Datetime.now().second() + 5 < 0 ? '0' : String.valueOf(Datetime.now().second() + 5);
    //     // //parse to cron expression
    //     // String schedulazione = ss + ' ' + min + ' ' + hour + ' * * ?';

    //     // System.schedule('Innolva Monitoraggi - Get Pagina ' + nPag, schedulazione, new TXT_Monitoraggi_GetPagina(nPag, ticketId));

    //     Log__c logArricchimento = new Log__c(Source__c = 'JOB MONITORAGGIO INNOLVA - GET PAGINA ' + nPag);
    //     List<Map<String,String>> note_REA = new List<Map<String,String>>();

    //     Map<String,String> settings = TXT_Monitoraggi.TXT_CustomSettings();

    //     try{
            
    //         HttpRequest req = new HttpRequest();
    //         req.setEndpoint(settings.get('endpoint'));
    //         req.setMethod('POST');
    //         req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
    //         req.setTimeout(120000);
    //         Dom.Document doc = new Dom.Document();
    //         doc.load('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4">'+
    //         '<soapenv:Header/>'+
    //         '<soapenv:Body>'+
    //             '<bin:getPagina>'+
    //                 '<bin:accountName>'+settings.get('username')+'</bin:accountName>'+
    //                 '<bin:accountPassword>'+settings.get('password')+'</bin:accountPassword>'+
    //                 '<bin:userID>'+settings.get('username')+'</bin:userID>'+
    //                 '<bin:tipoElenco>Note</bin:tipoElenco>'+
    //                 '<bin:ticketID>'+ticketId+'</bin:ticketID>'+
    //                 '<bin:pagina>'+String.valueOf(nPag)+'</bin:pagina>'+
    //                 '<!--Optional:-->'+
    //                 '<bin:campoOrdine></bin:campoOrdine>'+
    //                 '<!--Optional:-->'+
    //                 '<bin:versoOrdine></bin:versoOrdine>'+
    //             '</bin:getPagina>'+
    //         '</soapenv:Body>'+
    //         '</soapenv:Envelope>');

    //         req.setBodyDocument(doc);
    //         Http http = new Http();

    //         System.debug('@@@ DML2 ' + Limits.getDmlRows());
    //         System.debug('@@@ DML2 ' + Limits.getDmlStatements());
    //         System.debug('@@@ DML2 ' + Limits.getLimitDmlRows());
    //         System.debug('@@@ DML2 ' + Limits.getLimitDmlStatements());
    //         System.debug('@@@ DML2 ' + Limits.getQueueableJobs());
    //         System.debug('@@@ DML2 ' + Limits.getLimitQueueableJobs());

    //         HTTPResponse res = http.send(req);

    //         logArricchimento.InputPayload__c = doc.toXmlString();
    //         logArricchimento.OutputPayload__c = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody();

    //         if(res.getStatusCode() == 200){
    //             Dom.Document responseDoc = res.getBodyDocument();
    //             Dom.XMLNode root = responseDoc.getRootElement();

    //             // PARSO L'XML

    //             String nameSpace='http://schemas.xmlsoap.org/soap/envelope/';
    //             String namespace2 = 'urn:ws.ribes.it/BInformationV4';

    //             Dom.XMLNode RISPOSTA = root.getChildElement('Body',namespace).getChildElement('getPaginaResponse',namespace2).getChildElement('return',namespace2).getChildElement('WSRBS',null).getChildElement('TRANSAZIONE',null).getChildElement('RISPOSTA',null);

    //             if(RISPOSTA != null){
    //                 Dom.XmlNode lista = RISPOSTA.getChildElement('Prodotto', null).getChildElement('Lista', null);
    //                 Dom.XmlNode listaNote = lista.getChildElement('ListaNote', null);
    //                 if(Integer.valueOf(listaNote.getAttribute('numeroPosizioniTotali', null)) > 0){
    //                     for(Dom.XMLNode Soggetto : listaNote.getChildElements()){
    //                         String provincia = Soggetto.getChildElement('InfoImpresa', null).getChildElement('KRea',null).getChildElement('Cciaa',null).getAttribute('sigla',null);
    //                         String rea = Soggetto.getChildElement('InfoImpresa', null).getChildElement('KRea', null).getChildElement('NRea', null).getText();
    //                         String cf = Soggetto.getChildElement('InfoImpresa', null).getChildElement('CodiceFiscale', null).getText();
    //                         // String notaId;
    //                         List<String> noteIds = new List<String>();
    //                         List<Dom.XmlNode> listaNoteSoggetti = Soggetto.getChildElement('ElencoNote', null).getChildElements();
    //                         if(listaNoteSoggetti.size() > 0){
    //                             for(Dom.XmlNode nota : listaNoteSoggetti){
    //                                 noteIds.add(nota.getChildElement('IDNota', null).getText());
    //                             }
    //                             // notaId = listaNoteSoggetti[0].getChildElement('IDNota', null).getText();
    //                         }


    //                         // if(rea != null && notaId != null){
    //                         //     note_REA.add(new Map<String,String>{'rea' => rea, 'notaId' => notaId, 'cf' => cf});
    //                         // }
    //                         if(rea != null && !noteIds.isEmpty()){
    //                             for(String notaId : noteIds){
    //                                 note_REA.add(new Map<String,String>{'rea' => rea, 'provincia' => provincia, 'notaId' => notaId, 'cf' => cf});
    //                             }
    //                         }

    //                         if(!note_REA.isEmpty()){
    //                             // System.abortJob(jobToAbort);
    //                             TXT_Monitoraggi t = new TXT_Monitoraggi(note_REA, nPag, ticketId);
    //                             System.enqueueJob(t);
    //                         }
    //                     }
    //                 }
    //             }
    //         } else {
    //             System.debug('@@@ error chiamata ' + res.getBody());
    //             logArricchimento.ErrorMessage__c = String.valueOf(res.getStatusCode());
    //             logArricchimento.Success__c = false;
    //         }
    //     } catch (Exception e){
    //         System.debug('@@@ eccezione ' + e.getStackTraceString() + ' --- ' + e.getMessage());
    //         Map<String,String> tmp = new Map<String,String>();
    //         tmp.put('error', e.getStackTraceString() + ' --- ' + e.getMessage());
    //         // this.note_REA_Errors.add(tmp);

    //         logArricchimento.ErrorMessage__c = e.getStackTraceString() + ' --- ' + e.getMessage();
    //         logArricchimento.Success__c = false;
    //         // Log__c l = new Log__c(
    //         //     InputPayload__c = JSON.serializePretty(this.note_REA_Errors)
    //         // );
    
    //         // insert l;
    //     }

    //     insert logArricchimento;
    // }

    public static Map<String,String> TXT_CustomSettings() {
        Map<String,String> settings = new Map<String,String>();

        EndpointServizi__c endpoints = EndpointServizi__c.getInstance();
        UtenzeDefault__c credentials = UtenzeDefault__c.getInstance();

        settings.put('endpoint', endpoints.TXT_BusinessInformation__c);
        settings.put('username', credentials.TXT_Innolva_EndPoint_User__c);
        settings.put('password', credentials.TXT_Innolva_EndPoint_Password__c);

        return settings;
    }

    public void getProdottoDaNota(Map<String,String> nota_rea){
        System.debug('@@@ getProdottoDaNota: ' + nota_rea);

        Log__c logArricchimento = new Log__c(Source__c = 'JOB MONITORAGGIO INNOLVA');

        try{
            Account anagrafica = [SELECT Id, Name, BillingCountry, BillingState, BillingPostalCode, BillingStreet, BillingCity, 
                                    Codice_Fiscale__c, Email_Aziendale_Innolva__c, Data_ultimo_arricchimento__c,
                                    Partita_iva__c, Forma_giuridica__c, Acquisti_totali__c, AnnualRevenue, Risultato_Operativo_Lordo__c, 
                                    Utile_Perdita__c, Crediti_vs_Clienti__c, Totale_Patrimonio_Netto_Tinexta__c,
                                    Fatturato__c, Data_Bilancio__c, Data_Inizio_Attivita__c, Data_di_Iscrizione__c, Dipendenti__c, Anno_rilevazione_addetti__c,
                                    Livello_attenzione_negativita__c, Capitale_Sociale__c, Phone, Fax, Stato_Attivita__c, Rating__c, Codice_Ateco_Innolva__c, Descrizione_Ateco_Innolva__c 
                                FROM Account WHERE CCIAA_REA__c =: nota_rea.get('rea') AND CCIAA_CMK__c =: nota_rea.get('provincia')];

            System.debug('@@@ anagrafica ' + anagrafica);

            HttpRequest req = new HttpRequest();
            req.setEndpoint(this.settings.get('endpoint'));
            req.setMethod('POST');
            req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
            req.setTimeout(120000);
            Dom.Document doc = new Dom.Document();
            doc.load('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:bin="urn:ws.ribes.it/BInformationV4">'+
                '<soapenv:Header/>'+
                '<soapenv:Body>'+
                '<bin:getProdottoDaNota>'+
                    '<bin:accountName>'+this.settings.get('username')+'</bin:accountName>'+
                    '<bin:accountPassword>'+this.settings.get('password')+'</bin:accountPassword>'+
                    '<bin:userID>'+this.settings.get('username')+'</bin:userID>'+
                    '<bin:codiceProdotto>BIWKR</bin:codiceProdotto>'+
                    '<bin:tipo>PRD</bin:tipo>'+
                    '<bin:formato>XML</bin:formato>'+
                    '<bin:idBicNota>'+nota_rea.get('notaId')+'</bin:idBicNota>'+
                    '<!--Optional:-->'+
                    '<bin:riferimento></bin:riferimento>'+
                '</bin:getProdottoDaNota>'+
                '</soapenv:Body>'+
            '</soapenv:Envelope>');

            req.setBodyDocument(doc);
            Http http = new Http();
            HTTPResponse res = http.send(req);

            logArricchimento.InputPayload__c = doc.toXmlString();
            logArricchimento.OutputPayload__c = res.getBody().length() > 131072 ? res.getBody().substring(0,131072) : res.getBody();

            if(res.getStatusCode() == 200){
                Dom.Document responseDoc = res.getBodyDocument();
                Dom.XMLNode root = responseDoc.getRootElement();

                // PARSO L'XML

                String nameSpace='http://schemas.xmlsoap.org/soap/envelope/';
                String namespace2 = 'urn:ws.ribes.it/BInformationV4';

                Dom.XMLNode RISPOSTA = root.getChildElement('Body',namespace).getChildElement('getProdottoDaNotaResponse',namespace2).getChildElement('return',namespace2).getChildElement('WSRBS',null).getChildElement('TRANSAZIONE',null).getChildElement('RISPOSTA',null);

                if(RISPOSTA != null){

                    // Dom.XmlNode dati = RISPOSTA.getChildElement('Prodotto', null).getChildElement('ReportXML', null).getChildElement('Dati', null);


                    // IL PARSING CONTINUA NEL METODO Arricchimento()
                    anagrafica = Arricchimento(RISPOSTA, anagrafica);
                    update anagrafica;
                }
            } else {
                System.debug('@@@ error chiamata ' + res.getBody());
                logArricchimento.ErrorMessage__c = String.valueOf(res.getStatusCode());
                logArricchimento.Success__c = false;
            }
        } catch (Exception e){
            System.debug('@@@ eccezione ' + e.getStackTraceString() + ' --- ' + e.getMessage());
            Map<String,String> tmp = nota_rea;
            tmp.put('error', e.getStackTraceString() + ' --- ' + e.getMessage());
            this.note_REA_Errors.add(tmp);

            logArricchimento.ErrorMessage__c = e.getStackTraceString() + ' --- ' + e.getMessage();
            logArricchimento.Success__c = false;
            // Log__c l = new Log__c(
            //     InputPayload__c = JSON.serializePretty(this.note_REA_Errors)
            // );
    
            // insert l;
        }

        insertLogAsync(JSON.serialize(logArricchimento));
    }

    @future
    public static void insertLogAsync(String logJSON) {
        Log__c l = (Log__c)JSON.deserializeStrict(logJSON, Log__c.Class);
        insert l;
    }

    public static Account arricchimento(Dom.XMLNode risposta,Account acct){

        Integer day;
        Integer year;
        Integer month;

        //MAPPING MANCANTI:
        acct.Data_di_cessazione__c = null; //Non trovato
        acct.BillingCountry = 'ITALIA'; //Non trovato

        List<Dom.XMLNode> approfondimentoimprese = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('ApprofondimentiImprese',null).getChildElements(); //[1].getChildElement('BloccoBilanci',null).getChildElement('ElencoBilanci',null).getChildElement('Bilancio',null).getChildElement('ContoEconomico',null);
        //System.debug('APPROFONDIMENTI IMPRESE: '+approfondimentoimprese);

        Integer i = 0;
        if(approfondimentoimprese != null){
            System.debug('APPROFONDIMENTI IMPRESE: PRESENTE');
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoImpresa', null) != null){
                // acct.Name = infoImpresa.getChildElement('Denominazione',null).getText();
                Dom.XmlNode infoimpresa = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoImpresa', null);
                System.debug('@@@ xxx ' + infoimpresa);
                String name = infoImpresa.getChildElement('Denominazione',null).getText();
                acct.Name = name.length() > 255 ? name.substring(0,255) : name;

                acct.Data_ultimo_arricchimento__c = System.Today();

                Dom.XmlNode emailCertificataNode = infoimpresa.getChildElement('EmailCertificata', null);

                Dom.XMLNode sede = infoimpresa.getChildElement('Sede', null);
                acct.BillingPostalCode = sede.getChildElement('Indirizzo', null).getAttribute('cap', null).left(20);
                acct.BillingState = sede.getChildElement('Provincia', null).getAttribute('sigla', null);
                String via = sede.getChildElement('Indirizzo', null).getAttribute('toponimo', null) + ' ' + sede.getChildElement('Indirizzo', null).getAttribute('via', null) + ', ' + sede.getChildElement('Indirizzo', null).getAttribute('numeroCivico', null);
                acct.BillingStreet = via; 
                acct.BillingCity = sede.getChildElement('Comune', null).getText();

                // System.debug('@@@ emailCertificata ' + emailCertificataNode);
                try{
                    acct.Email_Aziendale_Innolva__c = emailCertificataNode.getText();
                }catch(Exception e){
                    System.debug('GPF Exception ' + e.getMessage());
                }
            }
            for(Dom.XMLNode impresa : approfondimentoimprese){
                //System.debug('IMPRESA: '+impresa);

                if(impresa!=null && impresa.getName()=='ApprofondimentoImpresa' && i == 0){
                    i++;
                    // Dom.XmlNode emailCertificataNode = impresa.getChildElement('InfoImpresa', null).getChildElement('EmailCertificata', null);

                    // Dom.XMLNode sede = impresa.getChildElement('InfoImpresa', null).getChildElement('Sede', null);
                    // acct.BillingPostalCode = sede.getChildElement('Indirizzo', null).getAttribute('cap', null);
                    // acct.BillingState = sede.getChildElement('Provincia', null).getAttribute('sigla', null);
                    // String via = sede.getChildElement('Indirizzo', null).getAttribute('toponimo', null) + ' ' + sede.getChildElement('Indirizzo', null).getAttribute('via', null) + ', ' + sede.getChildElement('Indirizzo', null).getAttribute('numeroCivico', null);
                    // acct.BillingStreet = via; 
                    // acct.BillingCity = sede.getChildElement('Comune', null).getText();

                    // // System.debug('@@@ emailCertificata ' + emailCertificataNode);
                    // try{
                    //     acct.Email_Aziendale_Innolva__c = emailCertificataNode.getText();
                    // }catch(Exception e){
                    //     System.debug('GPF Exception ' + e.getMessage());
                    // }
                    // acct.Data_ultimo_arricchimento__c = System.Today();


                    if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null) != null){
                        try{
                            Dom.XMLNode infoSede = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoSede',null);
                            acct.Partita_iva__c = infoSede.getChildElement('PartitaIva',null).getText();
                            System.debug('Partita_iva ' + acct.Partita_iva__c);
                        }catch(Exception e){
                            System.debug('GPF exception ' + e.getMessage() +' '+e.getLineNumber());
                        }
                    }
                    try{
                        if(impresa.getChildElement('InfoImpresa',null).getChildElement('NaturaGiuridica',null) != null){
                            acct.Forma_giuridica__c = impresa.getChildElement('InfoImpresa',null).getChildElement('NaturaGiuridica',null).getText();
                            System.debug('Forma Giuridica: '+acct.Forma_giuridica__c);
                        }
                    }catch(Exception e){
                        System.debug('GPF exception ' + e.getMessage() +' '+e.getLineNumber());
                    }
                    try{
                        if(impresa.getChildElement('InfoImpresa',null).getChildElement('CodiceFiscale',null) != null){
                            acct.Codice_fiscale__c = impresa.getChildElement('InfoImpresa',null).getChildElement('CodiceFiscale',null).getText();
                        }
                    }catch(Exception e){
                        System.debug('GPF exception ' + e.getMessage() +' '+e.getLineNumber());
                    }
                    Dom.XmlNode info = impresa.getChildElement('BloccoBilanci',null).getChildElement('InfoImpresaBilancio',null);
                    //System.debug('INFO: '+info);
                    //String Denominazione = info.getChildElement('Denominazione',null).getText();
                    //System.debug('DENOMINAZIONE IMPRESA: '+Denominazione);
                    /*
                    List<Dom.XmlNode> KReaTag = info.getChildElement('KRea',null).getChildElements();
                    for(Dom.XMLNode KRea : KReaTag){
                        if(KRea.getName()=='Cciaa'){
                            String CCIAA = KRea.getAttribute('sigla',null);
                            System.debug('CCIAA: '+CCIAA);
                        }else if(KRea.getName()=='NRea'){
                            String NRea = KRea.getText();
                            System.debug('NRea: '+NRea);
                        }
                    }
                    */
                    Dom.XmlNode infobilancio = null;
                    System.debug('INFO BILANCIO: ' + impresa.getChildElement('BloccoBilanci',null).getChildElement('ElencoBilanci',null));
                    try{
                        if(impresa.getChildElement('BloccoBilanci',null).getChildElement('ElencoBilanci',null) != null){
                            infobilancio = impresa.getChildElement('BloccoBilanci',null).getChildElement('ElencoBilanci',null).getChildElements()[0];
                        }
                    }catch(Exception e){
                        System.debug('GPF exception ' + e.getMessage());
                    }
                    
                    if(infobilancio != null){
                        Dom.XmlNode ContoEconomico = infobilancio.getChildElement('ContoEconomico', null);
                        for(Dom.XMLNode voce : ContoEconomico.getChildElements()){
                            //System.debug('CODICE VOCE: '+ voce);
                            if(voce != null){
                                if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'IC131' || voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'PL131'){
                                    //System.debug('VOCE: '+ voce.getChildElement('Valore',null).getAttribute('percentuale',null));
                                    acct.Acquisti_totali__c = double.valueof(voce.getChildElement('Valore',null).getText());
                                    System.debug('VOCE: Acquisti_totali__c: ' + acct.Acquisti_totali__c);
        
                                }else if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'IC124' || voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'PL124'){
                                    acct.AnnualRevenue = double.valueof(voce.getChildElement('Valore',null).getText());
                                    System.debug('VOCE: AnnualRevenue: ' + acct.AnnualRevenue);
                                    acct.Fatturato__c = TXT_ProcessiLeadAccountUtils.TXT_PickList_Fatturato(acct.AnnualRevenue);
        
                                }else if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'C_IC212' || voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'C_PL212'){
                                    acct.Risultato_Operativo_Lordo__c = double.valueof(voce.getChildElement('Valore',null).getText());
                                    System.debug('VOCE: Risultato_Operativo_Lordo__c: ' + acct.Risultato_Operativo_Lordo__c);
                                
                                }else if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'IC179' || voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'PL179'){
                                    acct.Utile_Perdita__c = double.valueof(voce.getChildElement('Valore',null).getText());
                                    System.debug('VOCE: Utile_Perdita__c: ' + acct.Utile_Perdita__c);
                                }
                            }
                        }
    
                        Dom.XmlNode StatoPatrimonialeAttivo = infobilancio.getChildElement('StatoPatrimoniale', null).getChildElement('StatoPatrimonialeAttivo', null);
                        for(Dom.XMLNode voce : StatoPatrimonialeAttivo.getChildElements()){
                            if(voce != null){
                                if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'C_IC201' || voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'C_PL201'){
                                    acct.Crediti_vs_Clienti__c = double.valueof(voce.getChildElement('Valore',null).getText());
                                    System.debug('VOCE: Crediti_vs_Clienti__c: ' + acct.Crediti_vs_Clienti__c);
                                }
                            }
                        }
    
                        Dom.XmlNode StatoPatrimonialePassivo = infobilancio.getChildElement('StatoPatrimoniale', null).getChildElement('StatoPatrimonialePassivo', null);
                        for(Dom.XMLNode voce : StatoPatrimonialePassivo.getChildElements()){
                            if(voce != null){
                                if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'C_IC221' || voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'C_PL221'){
                                    acct.Totale_Patrimonio_Netto_Tinexta__c = double.valueof(voce.getChildElement('Valore',null).getText());
                                    System.debug('VOCE: Totale_Patrimonio_Netto_Tinexta__c: ' + acct.Totale_Patrimonio_Netto_Tinexta__c);
                                }
                            }
                        }
    
                        // Dom.XmlNode IndiciRotazioneDurata = infobilancio.getChildElement('IndiciRotazioneDurata', null);
                        // for(Dom.XMLNode voce : IndiciRotazioneDurata.getChildElements()){
                        //     if(voce != null){
                        //         if(voce.getChildElement('Descrizione',null).getAttribute('codice',null) == 'IND109'){
                        //             String fatturato = TXT_ProcessiLeadAccountUtils.TXT_PickList_Fatturato(voce.getChildElement('Valore',null).getText() != null ? voce.getChildElement('Valore',null).getText() : '0.0');
                        //             // acct.Fatturato__c = voce.getChildElement('Valore',null).getText(); //MANCANTE
                        //             acct.Fatturato__c = fatturato;
                        //             System.debug('VOCE: Fatturato__c: ' + acct.Fatturato__c);
                        //         }
                        //     }
                        // }
    
                        Dom.XmlNode dataChiusuraBilancio = infobilancio.getChildElement('Testata', null).getChildElement('DataChiusura',null);
                        if(dataChiusuraBilancio != null){
                            year = Integer.valueof(dataChiusuraBilancio.getAttribute('anno',null));
                            month = Integer.valueof(dataChiusuraBilancio.getAttribute('mese',null));
                            day = Integer.valueof(dataChiusuraBilancio.getAttribute('giorno',null));
                            acct.Data_Bilancio__c = date.newInstance(year, month, day);
                        }
                    }
                }
                break;
            }
        }

        if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('DataInizioAttivita',null) != null){
            Dom.XMLNode dataInizioAttivita = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('DataInizioAttivita',null);
            year = Integer.valueof(dataInizioAttivita.getAttribute('anno',null));
            month = Integer.valueof(dataInizioAttivita.getAttribute('mese',null));
            day = Integer.valueof(dataInizioAttivita.getAttribute('giorno',null));
            acct.Data_Inizio_Attivita__c = date.newInstance(year, month, day);
        }

        try{
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('DataIscrizione',null) != null){
                Dom.XMLNode dataIscrizione = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('DataIscrizione',null);
                year = Integer.valueof(dataIscrizione.getAttribute('anno',null));
                month = Integer.valueof(dataIscrizione.getAttribute('mese',null));
                day = Integer.valueof(dataIscrizione.getAttribute('giorno',null));
                acct.Data_di_Iscrizione__c = date.newInstance(year, month, day);
            }
            
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('Addetti',null) != null){
                String dipendentiStr = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('Addetti',null).getText();
                Integer dipendenti = Integer.valueOf(dipendentiStr);
                if(dipendenti <= 9){
                    acct.Dipendenti__c = '1-9';
                } else if(dipendenti >= 10 && dipendenti <= 49){
                    acct.Dipendenti__c = '10-49';
                } else if(dipendenti >= 50 && dipendenti <= 249){
                    acct.Dipendenti__c = '50-249';
                } else if(dipendenti >= 250){
                    acct.Dipendenti__c = '250 e oltre';
                }
                // acct.Dipendenti_Innolva__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('Addetti',null).getText();
            }
            
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('Addetti',null) != null){
                acct.Anno_rilevazione_addetti__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('Sintesi',null).getChildElement('SintesiAttivita',null).getChildElement('Addetti',null).getAttribute('anno',null);
            }
            
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('RischioImpresa',null).getChildElement('IndiceEventiPregiudizievoli',null) != null){
                acct.Livello_attenzione_negativita__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('RischioImpresa',null).getChildElement('IndiceEventiPregiudizievoli',null).getText();
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }
        
        try{
            Dom.XMLNode capitaleSociale = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoPatrimonialiFinanziarie',null).getChildElement('CapitaleSociale',null);
            if(capitaleSociale != null){
                if(capitaleSociale.getChildElement('ImportiEuro',null).getChildElement('Deliberato',null) != null){
                    acct.Capitale_Sociale__c = Decimal.valueof(capitaleSociale.getChildElement('ImportiEuro',null).getChildElement('Deliberato',null).getText());
                }
            }
        }catch(Exception e){
            acct.Capitale_Sociale__c = null;
        }
        
        try{
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoSede',null).getChildElement('Telefono',null) != null){
                acct.Phone = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoSede',null).getChildElement('Telefono',null).getText();
            }
            
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoSede',null).getChildElement('Fax',null) != null){
                acct.Fax = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('DatiCameraliImpresa',null).getChildElement('InfoSede',null).getChildElement('Fax',null).getText();
            }
            
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('ApprofondimentiImprese',null).getChildElement('ApprofondimentoImpresa',null).getChildElement('InfoAttivitaImpresa',null).getChildElement('StatoAttivitaRettificato',null) != null){
                acct.Stato_Attivita__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('ApprofondimentiImprese',null).getChildElement('ApprofondimentoImpresa',null).getChildElement('InfoAttivitaImpresa',null).getChildElement('StatoAttivitaRettificato',null).getText();
            }
            
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('RischioImpresa',null).getChildElement('Classe',null) != null){
                acct.Rating__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null).getChildElement('RischioImpresa',null).getChildElement('Classe',null).getText();
            }
        }catch(Exception e){
            System.debug('GPF exception ' + e.getMessage());
        }

        try{
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('Sintesi',null)?.getChildElement('SintesiAttivita',null)?.getChildElement('Ateco', null) != null){
                acct.Codice_Ateco_Innolva__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('Sintesi',null)?.getChildElement('SintesiAttivita',null)?.getChildElement('Ateco', null).getAttribute('codice', null);
            }
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('Sintesi',null)?.getChildElement('SintesiAttivita',null)?.getChildElement('Ateco', null) != null){
                acct.Descrizione_Ateco_Innolva__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('Sintesi',null)?.getChildElement('SintesiAttivita',null)?.getChildElement('Ateco', null).getText();
            }
        } catch (Exception e){
            System.debug('GPF exception ' + e.getMessage() + ' -- ' + e.getStackTraceString());
        }

        // SM - Aggiunta campi TXT_Gruppo_IVA__c e TXT_Denominazione_Gruppo_IVA__c
        try {
            if(risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('DatiCameraliImpresa',null)?.getChildElement('InfoSede',null)?.getChildElement('GruppoIva', null) != null){
                acct.TXT_Gruppo_IVA__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('DatiCameraliImpresa',null)?.getChildElement('InfoSede',null)?.getChildElement('GruppoIva', null)?.getChildElement('PartitaIvaGruppo', null)?.getText();
                acct.TXT_Denominazione_Gruppo_IVA__c = risposta.getChildElement('Prodotto',null).getChildElement('ReportXML',null).getChildElement('Dati',null)?.getChildElement('DatiCameraliImpresa',null)?.getChildElement('InfoSede',null)?.getChildElement('GruppoIva', null)?.getAttributeValue('denominazione', null);
            }
        } catch (Exception e) {
            System.debug('@@@ gruppo iva not found');
        }
        
        return acct;
    }
}