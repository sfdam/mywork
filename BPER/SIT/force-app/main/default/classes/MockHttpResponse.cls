@isTest
public class MockHttpResponse implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        System.debug('req: ' + req);
        if(req.getEndpoint().contains('AnagrafeClientiAPI')){

            res.setBody('{"warning":{"listaMalfuzionamenti":[{"layer":"BACKEND","messaggio":"SQL CODE: 010{ ANRCM018 - COD. IPA   - S3/DATO NON PRESENTE IN ANTBTAN1","codice":"02"},{"layer":"BACKEND","messaggio":"SQL CODE: 010{ ANRCM018 - COD. LEI   - S3/DATO NON PRESENTE IN ANTBTAN1","codice":"02"}],"numeroMalfunzionamenti":2,"codice":"04"},"portafogliazione":{"codiceSegmentoGestionale":"REDEP","nomeReferente":"Gianferrari Stefano","codice":"PTF-PE-05387-0055-000101","codiceModelloServizio":"05"},"infoFEA":{"adesione":true},"dettaglioAnagrafica":{"cabLuogo":"664706","dataOraUltimoAggiornamento":"2019-12-02T18:38:04.000","dataCensimento":"2011-07-03T18:38:04.000","dataPreaccensione":"1992-03-31T18:38:04.000","centroRischi":"187278154","infoDocumento":{"dataScadenza":"2024-04-03T18:38:04.000","luogoEmissione":"RUBIERA","enteEmissione":"COMUNE","dataEmissione":"2013-11-29T18:38:04.000 ","numero":"AS8213852","tipo":{"descrizione":"CARTA IDENTITA","codice":"001"}},"TIN3":{"nazione":"086","TIN":"MMMRSO61A41F240X0000"},"TIN2":{"nazione":"024","TIN":"12345678900000000000"},"TIN1":{"nazione":"086","TIN":"VCCSFN69D03H223Q"},"postale":null,"domicilio":{"CAP":"42048","nazione":{"descrizione":"Italia","codice":"086"},"provincia":{"codice":"RE"},"localita":"RUBIERA","indirizzo":"NAUCCU UBJIBAI VLUPKYA 2"},"residenzaSedeLegale":{"CAP":"42048","nazione":{"descrizione":"Italia","codice":"086"},"provincia":{"codice":"RE"},"localita":"RUBIERA","indirizzo":"NAUCCU VLUPKYA 2"},"contatti":{"pecUtente":"prova@gmail.com","emailOTP":"gekki@tin.it","email1":"stefanovecchi469@gmail.com","numeroHomeBanking":"05112345678","numeroOTP":"3356026456","fax":{"numero":"9876543","prefisso":"087"},"cellulare":{"numero":"1234567","prefisso":"086"},"telefonoFisso":null},"personaFisica":{"cittadinanza1":{"codice":"086"},"regimePatrimoniale":"SEPARAZIONE","titoloOnorifico":"02","statoCivile":"C","nazioneNascita":{"descrizione":"Italia","codice":"086"},"provinciaNascita":{"codice":"RE"},"luogoNascita":"REGGIO NELL\'EMILIA","dataNascita":"1969-04-03","sesso":"Maschio","nome":"KJOWUBI","cognome":"HOYYTA"},"anagrafica":{"particolaritaBloccoPolizze":{"particolarita":"ATTIVA_ONLINE","bloccoPolizze":false},"intestazioneRiga1":"HOYYTA KJOWUBI","microimpresa":false,"consenso":{"data":"2015-07-31","consenso3":true,"consenso2":true,"consenso1":true,"consenso":true},"CIAE":{"codice":"142"},"RAE":{"codice":"000"},"SAE":{"codice":"600"},"tipoCliente":{"codice":"3"},"codiceFiscale":"HYYKWB69D03H223B","stato":"C","codiceNDG":"001288023"}},"terminale":"cw2","operatore":"ANRCM018","filialePrincipale":"0055","banca":"05387"}');
        }else if(req.getEndpoint().contains('ContiCorrentiAPI')){

            res.setBody('{"listaRilevazioneSconfinamenti":{"rilevazioniSconfinamento":[{"totalePrenotazioneAvere":0.0,"totalePrenotazioneDare":0.0,"importo":11636.82},{"totalePrenotazioneAvere":0.0,"totalePrenotazioneDare":0.0,"importo":11636.82},{"totalePrenotazioneAvere":0.0,"totalePrenotazioneDare":0.0,"importo":11636.82},{"totalePrenotazioneAvere":0.0,"totalePrenotazioneDare":0.0,"importo":11636.82},{"totalePrenotazioneAvere":0.0,"totalePrenotazioneDare":0.0,"importo":11636.82}],"numeroElementiTotali":5},"interessiAvereNonLiquidati":0.0,"interessiDareNonLiquidati":0.0,"interessiNonEsigibili":0.0,"interessiAnniPrecedenti":0.0,"interessiUltimaLiquidazione":0.0,"matricolaReferentePortafoglio":"00000","rating":"","franchigia":0.0,"codiceNDG":"001722861","contoConSaldoVincolato":true,"saldoVincolato":0.0,"totalePartitaMaturazioneAvere":0.0,"totalePartitaMaturazioneDare":0.0,"disponibilitaSaldoBuonFine":0.0,"importoContoUnicoUnaTantum":0.0,"importoUltimoMovimentoAvere":0.0,"importoUltimoStipendio":0.0,"iban":"IT73L0538766470000000882095","fidoPromiscuo":0,"utilizzoMedio":0.0,"giacenzaMedia":0.0,"disponibilitaGGSucessivo":11636.82,"operatoreInserimentoSblocco":"0000000","operatoreInserimentoBlocco":"0000000","esistenzaFidoPromiscuo":false,"totalePartitaSospesaAvere":0.0,"totalePartitaSospesaDare":0.0,"importoPrenotazione":2268.0,"importoPartitaLiqInLavorazione":0.0,"importoContoUnicoSBF":0.0,"importoSILUnaTantum":0.0,"importoFidoSaldoBuonFine":0.0,"importoAssegniNonDisponibile":0.0,"totaleFidoAssegni":2500.0,"totaleFidoTemporaneo":0.0,"dataScadenzaFido":"2019-10-05T00:00:00.000+02:00","totaleFido":5000.0,"dataUltimoMovimento":"2019-03-25T00:00:00.000+01:00","dataPrimoMovimento":"1998-09-17T00:00:00.000+02:00","dataUltimaModifica":"2019-03-25T00:00:00.000+01:00","dataAttivazione":"1998-09-17T00:00:00.000+02:00","esisteBlocco":true,"esisteNota":false,"totalePartitaIndisponibileAvere":0.0,"totalePartitaDisponibileAvere":0.0,"totalePartitaDisponibileDare":0.0,"dataSaldi":"2020-07-31T00:00:00.000+02:00","saldoDisponibile":11636.82,"saldoLiquidita":6975.82,"saldoContabile":6636.82,"numeroAssegniPrenotati":0,"numeroAssegniResidui":0,"numeroAssegniBloccati":0,"numeroAssegni":13,"dataApertura":"1998-09-17T00:00:00.000+02:00","codiceGraz":"000000500","codiceTipoConto":"01001","numeroConto":"000000882095","descrizioneFiliale":"RUBIERA","codiceFiliale":"0055","abi":"05387"}');
        }else if(req.getEndpoint().contains('CallbackWSAPI')){

            res.setBody('{"customerDataList" : [ {"canone" : {"feeValue" : {"promo" : "0000000","regime" : "0000300","promoDuration" : "000"},"channelAggregationCode" : "PV_3000003"},"tipologiaProfilo" : {"productCode" : "PV_1000011","description" : "ALL IN BASIC"},"statoSCA" : "Active","alias" : "-","userId" : "2115726","codiceUtenza" : "92070103","dataAttivazione" : "2020-06-19T07:25:01.000+00:00","statoPassword" : "PWDNONATTIVO","statoCodiceUtente" : "LOGON","statoRapporto" : "ATTIVO"}, {"canone" : {"feeValue" : null,"channelAggregationCode" : "PV_3000003"},"tipologiaProfilo" : {"productCode" : "PV_1000002","description" : "DISPO+"},"statoSCA" : "Active","alias" : "-","userId" : "2115719","codiceUtenza" : "31649476","dataAttivazione" : "2020-05-19T15:45:50.000+00:00","statoPassword" : "PWDNONATTIVO","statoCodiceUtente" : "LOGON","statoRapporto" : "ESTINTO"}, {"canone" : {"feeValue" : null,"channelAggregationCode" : "PV_3000003"},"tipologiaProfilo" : {"productCode" : "PV_1000002","description" : "DISPO+"},"statoSCA" : "Active","alias" : "salvatore","userId" : "2115722","codiceUtenza" : "57340551","dataAttivazione" : "2020-05-29T16:03:30.000+00:00","statoPassword" : "PWDATTIVO","statoCodiceUtente" : "USERATTIVO","statoRapporto" : "ESTINTO"}, {"canone" : {"feeValue" : null,"channelAggregationCode" : "PV_3000003"},"tipologiaProfilo" : {"productCode" : "PV_1000002","description" : "DISPO+"},"statoSCA" : "Active","alias" : "-","userId" : "2115555","codiceUtenza" : "24964857","dataAttivazione" : "2019-11-07T15:42:58.000+00:00","statoPassword" : "PWDNONATTIVO","statoCodiceUtente" : "ESTINTO","statoRapporto" : "ESTINTO"}, {"canone" : {"feeValue" : null,"channelAggregationCode" : "PV_3000003"},"tipologiaProfilo" : {"productCode" : "PV_1000002","description" : "DISPO+"},"statoSCA" : "Active","alias" : "-","userId" : "2115557","codiceUtenza" : "62113936","dataAttivazione" : "2019-11-07T16:20:31.000+00:00","statoPassword" : "PWDNONATTIVO","statoCodiceUtente" : "ESTINTO","statoRapporto" : "ESTINTO"} ],"businessTierBindingInfo" : {"activeSupportedNavigation" : null,"serviceClient" : "tAccountExtended","serviceImplementationClass" : "it.bper.npv.services.crmcallback.CRMCallbackServiceImpl","fnName" : "","serviceName" : "searchSmartAccountExtended","fnCaller" : "tAccountExtended","sysCaller" : "crm","operationId" : "0u9784200001323711476374","sessionId" : "00000008765efdvtcybvugty","channel" : "PDV","correlationId" : "8765efdvtcybvugty.u9784200001323711476374","parentOperationId" : null},"serverSecurityPayload" : {"securityCheckExecutionDate" : "2020-08-21T09:22:54.000+00:00","securityCheckerClass" : "it.bper.npv.arch.beans.ServiceSkeletonInterceptor","securityCheckResult" : "PASSED"}}');
        }else if(req.getEndpoint().contains('CrmAPI')){

            res.setBody('{ "VariabileProcesso" : [ { "paramvalue" : "00", "paramname" : "COD_TECH_CRM" }, { "paramvalue" : "N", "paramname" : "IS_TECH_EXC" } ], "esito" : "00" }');
        }else if(req.getEndpoint().contains('profilo-carte-ndg')){

            res.setBody('{"infoCarteList" : [ {"tipologiaCliente" : "P","tipoTitolare" : null,"tipoProdotto" : null,"tipoIndirizzo" : null,"tipoCarta" : null,"timbro" : null,"statoCarta" : null,"speseMese" : null,"sottoTipo" : null,"segnoSaldoContabile" : null,"segnoDisponibilitaResidua" : null,"saldoUltimoEstrattoConto" : null,"saldoContabile" : null,"provincia" : null,"plafond" : null,"oraSblocco" : null,"oraBlocco" : null,"numeroPosizioneAziendale" : "","numeroCartaApplicazione" : null,"ndgTitolare" : null,"NDGDivisione" : null,"modalitaPagamento" : null,"minRicarica" : null,"maxRicarica" : null,"maxMMUtilizzato" : null,"maxMMResiduo" : null,"maxMMPagoBancomat" : null,"maxMMImpostato" : null,"maxMMCarta" : null,"maxMMBancomat" : null,"maxMMApplicazione" : null,"maxGGUtilizzato" : null,"maxGGResiduo" : null,"maxGGPagoBancomat" : null,"maxGGImpostato" : null,"maxGGCarta" : null,"maxGGBancomat" : null,"maxGGApplicazione" : null,"maxCLUtilizzato" : null,"maxCLResiduo" : null,"maxCLImpostato" : null,"localita" : null,"intestazione" : "LUSETTI ROBERTA","indirizzo" : null,"importoRata" : null,"gerarchia" : "","flagMultifunzione" : null,"flagAssicurazione" : null,"disponibilitaResidua" : null,"disponibilitaAttuale" : null,"descrizioneBlocco" : null,"dataUltimoEstrattoConto" : null,"dataUltimoAggiornamento" : null,"dataSblocco" : null,"dataRestituzione" : null,"dataNascitaIntestatario" : null,"dataConsegnaCarta" : null,"dataBlocco" : null,"dataApertura" : null,"contoDiAppoggio" : null,"codiceTitolare" : "","codiceStatoCarta" : "C","codiceBlocco" : null,"circuito" : null,"cap" : null,"agenzia" : null,"tipoCollegamento" : "I","statoRapporto" : null,"servizio" : "820","numeroRapporto" : "11902553","NDG" : "0000000003169702","IBAN" : "","filiale" : "00014","codiceProdotto" : "BPEUN511","categoria" : "0200","cab" : "67010","abi" : "05387","tipologiaCarta" : "DEBITO","numeroCartaMask" : "0000**********2553","numeroCarta" : "LC5MG5MBVEAI1AXRA1","nomeCarta" : "VPAY C-LESS NOMINATIVA","dataScadenzaCarta" : "2022-09-30T00:00:00+02:00","ndg" : "0000000003169702","iban" : ""}, {"tipologiaCliente" : "P","tipoTitolare" : null,"tipoProdotto" : null,"tipoIndirizzo" : null,"tipoCarta" : null,"timbro" : null,"statoCarta" : null,"speseMese" : null,"sottoTipo" : null,"segnoSaldoContabile" : null,"segnoDisponibilitaResidua" : null,"saldoUltimoEstrattoConto" : null,"saldoContabile" : null,"provincia" : null,"plafond" : null,"oraSblocco" : null,"oraBlocco" : null,"numeroPosizioneAziendale" : "","numeroCartaApplicazione" : null,"ndgTitolare" : null,"NDGDivisione" : null,"modalitaPagamento" : null,"minRicarica" : null,"maxRicarica" : null,"maxMMUtilizzato" : null,"maxMMResiduo" : null,"maxMMPagoBancomat" : null,"maxMMImpostato" : null,"maxMMCarta" : null,"maxMMBancomat" : null,"maxMMApplicazione" : null,"maxGGUtilizzato" : null,"maxGGResiduo" : null,"maxGGPagoBancomat" : null,"maxGGImpostato" : null,"maxGGCarta" : null,"maxGGBancomat" : null,"maxGGApplicazione" : null,"maxCLUtilizzato" : null,"maxCLResiduo" : null,"maxCLImpostato" : null,"localita" : null,"intestazione" : "LUSETTI ROBERTA","indirizzo" : null,"importoRata" : null,"gerarchia" : "","flagMultifunzione" : null,"flagAssicurazione" : null,"disponibilitaResidua" : null,"disponibilitaAttuale" : null,"descrizioneBlocco" : null,"dataUltimoEstrattoConto" : null,"dataUltimoAggiornamento" : null,"dataSblocco" : null,"dataRestituzione" : null,"dataNascitaIntestatario" : null,"dataConsegnaCarta" : null,"dataBlocco" : null,"dataApertura" : null,"contoDiAppoggio" : null,"codiceTitolare" : "","codiceStatoCarta" : "C","codiceBlocco" : null,"circuito" : null,"cap" : null,"agenzia" : null,"tipoCollegamento" : "I","statoRapporto" : null,"servizio" : "872","numeroRapporto" : "81888348","NDG" : "0000000003169702","IBAN" : "","filiale" : "00014","codiceProdotto" : "CSC00700","categoria" : "0086","cab" : "67010","abi" : "05387","tipologiaCarta" : "CREDITO","numeroCartaMask" : "411786******8348","numeroCarta" : "RTT8043GY9BGIAN671","nomeCarta" : "CLASSIC CLIENTI CANONE 50%","dataScadenzaCarta" : "2023-02-28T00:00:00+01:00","ndg" : "0000000003169702","iban" : ""} ]}');
        }else if(req.getEndpoint().contains('getInfoCarte')){

            res.setBody('{}');
        }else if(req.getEndpoint().contains('rapporti')){

            res.setBody('{}');
        }else if(req.getEndpoint().contains('piani')){

            res.setBody('{}');
        }else if(req.getEndpoint().contains('createQueues')){
            if(req.getMethod() == 'POST'){
    
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(req.getBody());
                List<Account> accountList = (List<Account>)JSON.deserialize(JSON.serialize(bodyMap.get('accountList')), List<Account>.class);
                User approver = [SELECT id FROM User WHERE Email = 'test10@test.com' LIMIT 1];
                String workOrderKey = SV_Utilities.generateRandomString(24);
                String queueName = 'Q_' + workOrderKey + '_false_1_1';
                Group queue = new Group();
                queue.Name = 'Approvers Step 1 Queue 1';
                queue.DeveloperName = queueName;
                queue.Type = 'Queue';
                insert queue;
                GroupMember member = new GroupMember();
                member.GroupId = queue.Id;
                member.UserOrGroupId = approver.Id;
                insert member;
                List<GroupMember> memeberList = new List<GroupMember> {member};
                Map<String, List<GroupMember>> membersToInsert = new Map<String, List<GroupMember>>();
                membersToInsert.put(queueName, memeberList);
                String responseBody = JSON.serialize(JSON.serialize(new Map<String, Object>{

                    'queuesToInsert' => new List<Group> {queue},
                    'membersToInsert' => membersToInsert,
                    'accountWorkOrderKeyMap' => new Map<String, String>{accountList[0].Id => workOrderKey},
                    'woStepMap' => new Map<String, String>{workOrderKey => 'STEP1(NEC_F.1), STEP2(NEC_T.4, NEC_T.4), STEP3(NEC_A.1)'}
                }));
                res.setBody(responseBody);
            }else if(req.getMethod() == 'PATCH'){
                
                res.setBody(JSON.serialize(JSON.serialize(new Map<String, Object>{
                    'workOrderIdSet' => 'id'
                })));
            }else if(req.getMethod() == 'PUT'){
                
                res.setBody(JSON.serialize(JSON.serialize(new Map<String, Object>())));
            }
        }else if(req.getEndpoint().contains('iterhandler')){

            if(req.getMethod() == 'POST'){
                res.setBody(JSON.serialize(JSON.serialize(new Map<String, Object>())));
            }else if(req.getMethod() == 'PATCH'){
                res.setBody(JSON.serialize(JSON.serialize(new Map<String, Object>())));
            }
        }else if(req.getEndpoint().contains('executeasunecapi')){
            res.setBody(JSON.serialize(JSON.serialize(new Map<String, Object>{
                'recordList' => new List<Account>{new Account()}
            })));
        }
        res.setStatusCode(200);
        return res;
    }
}