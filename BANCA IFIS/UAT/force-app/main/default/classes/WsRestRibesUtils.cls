public without sharing class WsRestRibesUtils {
  private WsRestRibes.GetInformazioniPGResponse informazioniPg;

  public Account updateDatiAnagraficiRibesPg(Account accToUpdate) {
    System.debug('@@@ updateDatiAnagraficiRibesPg Account: ' + accToUpdate);
    try {
      informazioniPg = WsRestRibes.getInformazioniPG(accToUpdate.REA__c, accToUpdate.ProvinciaCCIAA__c);
      return doRibesAccountMapping(accToUpdate, informazioniPg.getImpresa());
    } catch (Exception e) {
      throw new Ex.RibesException('Errore richiesta integration layer (ribes): ' + e.getMessage(), e);
    }
  }


  public static Account doRibesAccountMapping(Account a, WsRestRibes.AziendaFull impresa) {
    System.debug('SV doRibesAccountMapping Account: ' + a);
    System.debug('SV doRibesAccountMapping impresa: ' + impresa);
    if (a != null && impresa != null) {

      //TODO: missing fields?
      //if (impresa.telefono != null) {
      //  a.Phone = impresa.telefono.getNumeroCompleto();
      //  a.TelefonoPrefisso__c = impresa.telefono.prefisso;
      //  a.TelefonoNumero__c = impresa.telefono.numero;
      //}
      //a.Email__c = impresa.email;
      //a.BillingCountry = impresa.nazione;
      //a.CCIAA__c = impresa.infoCCIAA.numeroIscrizioneLegale == null ? null : String.valueOf(impresa.infoCCIAA.numeroIscrizioneLegale);
      //a.DataIscrizioneCCIAA__c = UDate.getDateValue(impresa.infoCCIAA.dataIscrizioneLegale);
      //a.StatoAnagrafica__c = impresa.BusinessStatus;

      a.StatoCensimento__c = CtrlCensimento.INFOPROVIDER_OK;
      a.DettaglioCensimento__c = '';
      if (UtilAnagrafiche.isOK(impresa.getAteco())) a.Ateco__c = impresa.getAteco();

      if (impresa.infoImpresa != null) {
        if (UtilAnagrafiche.isOK(impresa.infoImpresa.denominazione)) a.Name = impresa.infoImpresa.denominazione;
        if (impresa.infoImpresa.kRea != null && UtilAnagrafiche.isOK(impresa.infoImpresa.kRea.nRea) && impresa.infoImpresa.kRea.nRea != '0') {
          a.REA__c = impresa.infoImpresa.kRea.nRea;
        }

        if (impresa.infoImpresa.DataIscrizioneREA != null ) {
          a.DataIscrizioneCCIAA__c = (impresa.infoImpresa.DataIscrizioneREA.anno != null && impresa.infoImpresa.DataIscrizioneREA.mese != null && impresa.infoImpresa.DataIscrizioneREA.giorno != null) ? date.newinstance(Integer.ValueOf(impresa.infoImpresa.DataIscrizioneREA.anno), Integer.ValueOf(impresa.infoImpresa.DataIscrizioneREA.mese), Integer.ValueOf(impresa.infoImpresa.DataIscrizioneREA.giorno)) : null;
		}

        if (impresa.infoImpresa.sede != null) {
          if (impresa.infoImpresa.sede.indirizzo != null) {
            if (UtilAnagrafiche.isOK(impresa.infoImpresa.sede.indirizzo.via)) a.BillingStreetName__c = impresa.infoImpresa.sede.indirizzo.via;
            if (UtilAnagrafiche.isOK(impresa.infoImpresa.sede.indirizzo.numeroCivico)) a.BillingStreetNumber__c = impresa.infoImpresa.sede.indirizzo.numeroCivico;
            if (UtilAnagrafiche.isOK(impresa.infoImpresa.sede.indirizzo.toponimo)) a.BillingStreetType__c = impresa.infoImpresa.sede.indirizzo.toponimo;
            if (String.isBlank(a.BillingStreetType__c)) a.BillingStreetType__c = 'VIA';
            if (UtilAnagrafiche.isOK(impresa.infoImpresa.sede.indirizzo.cap)) a.BillingPostalCode = impresa.infoImpresa.sede.indirizzo.cap;
          }
          if (impresa.infoImpresa.sede.comune != null) {
            Comune__c[] cL = [SELECT Id, Name FROM Comune__c WHERE (Name = :impresa.infoImpresa.sede.comune.content OR NomeRibes__c = :impresa.infoImpresa.sede.comune.content)];
            if (!cL.isEmpty()) {
              a.BillingCity = cL[0].Name;
            } else {
              a.BillingCity = impresa.infoImpresa.sede.comune.content;
            }
          }
          if (impresa.infoImpresa.sede.provincia != null && UtilAnagrafiche.isOK(impresa.infoImpresa.sede.provincia.sigla)) {
            a.BillingState = impresa.infoImpresa.sede.provincia.sigla;
            a.BillingState = impresa.infoImpresa.sede.provincia.sigla;
          }
        }

        if (impresa.infoImpresa.kRea != null && impresa.infoImpresa.kRea.cciaa != null && UtilAnagrafiche.isOK(impresa.infoImpresa.kRea.cciaa.sigla)) {
          a.ProvinciaCCIAA__c = impresa.infoImpresa.kRea.cciaa.sigla;
        }

        if (impresa.infoImpresa.naturaGiuridica != null && UtilAnagrafiche.isOK(impresa.infoImpresa.naturaGiuridica.codice)) {
          a.NaturaGiuridica__c = impresa.infoImpresa.naturaGiuridica.codice;
        }

        if (UtilAnagrafiche.isOK(impresa.infoImpresa.codiceFiscale)) a.CF__c = impresa.infoImpresa.codiceFiscale;
        if (UtilAnagrafiche.isOK(impresa.infoImpresa.partitaIva)) a.PIVA__c = impresa.infoImpresa.partitaIva;
        a.VAT__c = a.PIVA__c;
      }

      //TODO: non arrivano altri indirizzi?
      // a.ShippingStreet = a.BillingStreet;
      // a.ShippingStreetName__c = a.BillingStreetName__c;
      // a.ShippingStreetNumber__c = a.BillingStreetNumber__c;
      // a.ShippingStreetType__c = a.BillingStreetType__c;
      // a.ShippingCity = a.BillingCity;
      // a.ShippingState = a.Billingstate;
      // a.ShippingPostalCode = a.BillingPostalCode;

      if (impresa.infoAttivita != null) {
        if (UtilAnagrafiche.isOK(impresa.infoAttivita.rae) && impresa.infoAttivita.rae != '0') a.RAE__c = impresa.infoAttivita.rae;
        if (UtilAnagrafiche.isOK(impresa.infoAttivita.sae) && impresa.infoAttivita.sae != '0') a.SAE__c = impresa.infoAttivita.sae;
        // SV TEN ADD dataInizioAttivita in wrapper
        if (impresa.infoAttivita.dataInizioAttivita != null){
          if (UtilAnagrafiche.isOK(impresa.infoAttivita.dataInizioAttivita.anno) && 
              UtilAnagrafiche.isOK(impresa.infoAttivita.dataInizioAttivita.mese) && 
              UtilAnagrafiche.isOK(impresa.infoAttivita.dataInizioAttivita.giorno)){

            a.WGC_Data_inizio_attivita__c = date.parse(impresa.infoAttivita.dataInizioAttivita.giorno + '/' + impresa.infoAttivita.dataInizioAttivita.mese + '/' + impresa.infoAttivita.dataInizioAttivita.anno);
          }
        }
      }

      if (impresa.infoDatiEconomici != null && impresa.infoDatiEconomici.capitaleSociale != null) {
        if (UtilAnagrafiche.isOK(impresa.infoDatiEconomici.capitaleSociale.ammontare)) a.WGC_Ammontare__c = impresa.infoDatiEconomici.capitaleSociale.ammontare;
        if (impresa.infoDatiEconomici.capitaleSociale.valuta != null) {
          if (UtilAnagrafiche.isOK(impresa.infoDatiEconomici.capitaleSociale.valuta.content)) a.WGC_Divisa__c = impresa.infoDatiEconomici.capitaleSociale.valuta.content;
        }
      }
    }
    return a;
  }

  private static Contact doRibesContactMapping(Contact c, WsRestRibes.Persona persona) {
    if (c != null && persona != null && persona.infoPersona != null) {
      c.CF__c = persona.infoPersona.codiceFiscale;
      c.CI3N_CF__c = TrgContact.getCI3N_CF(c);

      if (persona.infoPersona.nominativo != null) {
        c.FirstName = persona.infoPersona.nominativo.nome;
        c.LastName = persona.infoPersona.nominativo.cognome;
        UtilCodiceFiscale ucf = new UtilCodiceFiscale();
        UtilCodiceFiscale.ContactInfo ci = ucf.reverseCodiceFiscale(c.CF__c, c.FirstName, c.LastName);
        c.Birthdate = ci.birthDate;
        c.CodCatastaleLocNascita__c = ci.codiceCatastale;

        if (String.isNotBlank(c.CodCatastaleLocNascita__c)) {
          Comune__c com = UtilAnagrafiche.getComune(c.CodCatastaleLocNascita__c);
          if (com != null) {
            c.LuogoNascita__c = com.Name;
            c.CABLocNascita__c = com.Cab__c;
          }
        }

        c.Sesso__c = ci.sesso;
      }

      if (persona.infoPersona.residenza != null) {
        if (persona.infoPersona.residenza.indirizzo != null) {
          c.MailingPostalCode = persona.infoPersona.residenza.indirizzo.cap;
          c.MailingPostalCode__c = persona.infoPersona.residenza.indirizzo.cap;

          c.MailingStreetName__c = persona.infoPersona.residenza.indirizzo.via;
          c.MailingStreetNumber__c = persona.infoPersona.residenza.indirizzo.numeroCivico;
          c.MailingStreetType__c = persona.infoPersona.residenza.indirizzo.codiceToponimo;

        }

        //TODO: al momento non prendiamo comune per il problema oggetto/stringa
        //if (persona.infoPersona.residenza.comune != null) {
        //  c.MailingCity = persona.infoPersona.residenza.comune.content;
        //}
        //

        if (persona.infoPersona.residenza.provincia != null) {
          c.MailingState = persona.infoPersona.residenza.provincia.sigla;
          c.MailingState__c = persona.infoPersona.residenza.provincia.sigla;
        }
      }
    }
    return c;
  }

  public Contact[] getContacts(Id accountId, String rea, String provCciaa) {

    System.debug('SV getContact: ' + accountId);
    System.debug('SV getContact: ' + rea);
    System.debug('SV getContact: ' + provCciaa);
    Contact[] tmp = new Contact[] {};
    if (informazioniPg == null) {
      try {
        informazioniPg = WsRestRibes.getInformazioniPG(rea, provCciaa);
        System.debug('SV informazioniPg: ' + informazioniPg);
      } catch (Exception e) {
        throw new Ex.RibesException('Errore richiesta integration layer (ribes): ' + e.getMessage() + '. Informazioni aggiuntive: ' + e.getStackTraceString(), e);
      }
    }
    WsRestRibes.AziendaFull impresa = (WsRestRibes.AziendaFull)informazioniPg.getImpresa();
    System.debug('SV AziendaFull: ' + impresa);
    if (impresa != null) {
      WsRestRibes.Persona[] persone = impresa.getReferenti();
      if (persone != null) {
        String ci3n = ImpostazioniServizi__c.getInstance().CodiceIstituto3N__c;
        for (WsRestRibes.Persona p : persone) {
          System.debug('SV Ribes Persona: ' + p);
          tmp.add(doRibesContactMapping(new Contact(AccountId = accountId, CodiceIstituto3N__c = ci3n), p));
        }
      }
    }
    return tmp;
  }

  public static EventiNegativiPlain getEventiNegativiSintetico(Id accountId) {
    EventiNegativiPlain eventiNegativi;
    try {
      Account[] accs = [SELECT Id, REA__c, ProvinciaCCIAA__c, NDGGruppo__c
                        FROM Account
                        WHERE Id = :accountId];
      if (!accs.isEmpty()) {
        Account acc = accs[0];
        WsRestRibes.GetEventiNegativiResponse response = WsRestRibes.getEventiNegativi(acc.REA__c, acc.ProvinciaCCIAA__c, 'S', 'XML', null, acc.NDGGruppo__c);
        if (response.isCorrect()) {
          acc.EventiNegativiIdTicket__c = response.getTicketId();

          WsRestRibes.Sintesi sintesi = response.getSintesi();
          if (sintesi != null) {
            eventiNegativi = new EventiNegativiPlain();

            if (sintesi.globale != null) {
              eventiNegativi.globale = sintesi.globale.semaforo;
              acc.EventiNegativiGlobale__c = sintesi.globale.semaforo;
            }
            if (sintesi.protesti != null) {
              eventiNegativi.protesti = sintesi.protesti.semaforo;
              acc.EventiNegativiProtesti__c = sintesi.protesti.semaforo;
            }
            if (sintesi.pregiudizievoli != null) {
              eventiNegativi.pregiudizievoli = sintesi.pregiudizievoli.semaforo;
              acc.EventiNegativiPregiudizievoli__c = sintesi.pregiudizievoli.semaforo;
            }
            if (sintesi.procedureConcorsuali != null) {
              eventiNegativi.procedureConcorsuali = sintesi.procedureConcorsuali.semaforo;
              acc.EventiNegativiProcedureConcorsuali__c = sintesi.procedureConcorsuali.semaforo;
            }
            if (sintesi.cigs != null) {
              eventiNegativi.cigs = sintesi.cigs.semaforo;
              acc.EventiNegativiCIGS__c = sintesi.cigs.semaforo;
            }
            if (sintesi.allarmiQuote != null) {
              eventiNegativi.allarmiQuote = sintesi.allarmiQuote.semaforo;
              acc.EventiNegativiAllarmiQuote__c = sintesi.allarmiQuote.semaforo;
            }
            update acc;
          }
        } else {
          throw new Ex.RibesException(response.getErrors());
        }
      }
      return eventiNegativi;
    } catch (Exception e) {
      throw new Ex.RibesException('Errore richiesta integration layer (ribes): ' + e.getMessage(), e);
    }
  }

  public static Id getEventiNegativiAnalitico(Id accountId) {
    try {
      Id contentDocumentId;
      Account[] accs = [SELECT Id, REA__c, ProvinciaCCIAA__c, EventiNegativiIdTicket__c, NDGGruppo__c
                        FROM Account
                        WHERE Id = :accountId];
      if (!accs.isEmpty()) { // TODO: verificare ENticket vuoto
        Account acc = accs[0];
        //A.M. Modifica Infoprovider RIBES -> CERVED (ticketId alfanumerico)
		WsRestRibes.GetEventiNegativiResponse response = WsRestRibes.getEventiNegativi(acc.REA__c, acc.ProvinciaCCIAA__c, 'A', 'PDF', acc.EventiNegativiIdTicket__c, acc.NDGGruppo__c);
		if (response.isCorrect()) {
          System.debug('response.getPDF(): ' + JSON.serialize(response.getPDF()));
          contentDocumentId = insertPDF(EncodingUtil.base64Decode(response.getPDF()), accountId);
        } else {
          throw new Ex.RibesException(response.getErrors());
        }
      }
      return contentDocumentId;
    } catch (Exception e) {
      throw new Ex.RibesException('Errore richiesta integration layer (ribes): ' + e.getMessage(), e);
    }
  }

  public static Id insertPDF(Blob pdfBlob, Id accountId) {
    System.SavePoint savePoint = Database.setSavePoint();
    System.debug('insertPDF');
    try {
      Id contentDocumentId;
      Allegato__c[] allegati = [SELECT Id, Tipo__c FROM Allegato__c WHERE Account__c = :accountId]; // TODO: passare anche tipo, quando sarà definito dal business
      Allegato__c allegato = null;
      if (!allegati.isEmpty()) {
        allegato = allegati[0];
        ContentDocumentLink[] cdL = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :allegato.Id];
        if (!cdL.isEmpty()) contentDocumentId = cdL[0].ContentDocumentId;
      } else {
        allegato = new Allegato__c(Account__c = accountId); // TODO: passare anche tipo, quando sarà definito dal business
      }
      allegato.DataUltimaGenerazione__c = Datetime.now();
      upsert allegato;

      ContentVersion cv = new ContentVersion(VersionData = pdfBlob, Title = 'EventiNegativi.pdf', PathOnClient = '/EventiNegativi.pdf');
      if (String.isNotBlank(contentDocumentId)) {
        cv.ContentDocumentId = contentDocumentId;
      }
      insert cv;

      if (String.isBlank(contentDocumentId)) {
        cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
        insert new ContentDocumentLink(
          ContentDocumentId = cv.ContentDocumentId,
          LinkedEntityId = allegato.Id,
          ShareType = 'I'
        );
      }
      return cv.ContentDocumentId;
    } catch (Exception e) {
      Database.rollback(savePoint);
      throw e;
    }
  }

  public class EventiNegativiPlain {
    @AuraEnabled
    public String globale;
    @AuraEnabled
    public String protesti;
    @AuraEnabled
    public String pregiudizievoli;
    @AuraEnabled
    public String procedureConcorsuali;
    @AuraEnabled
    public String cigs;
    @AuraEnabled
    public String allarmiQuote;
  }

  public static void updateBilancioSintetico(Id accountId) {
    Logger.setTransactionContext(null, accountId);

    try {
      Account acc = [SELECT
        CF__c,
        UltimaRichiestaBilancio__c
        FROM Account
        WHERE Id = :accountId
      ];

      System.debug('SV ACCOUNT: ' + acc);

      if (acc.UltimaRichiestaBilancio__c != null && Date.today() <= acc.UltimaRichiestaBilancio__c) return;

      WsRestRibes.GetBilancioSinteticoResponse response = WsRestRibes.getBilancioSintetico(acc.CF__c, acc.Id);

      System.debug('SV response: ' + response);
      acc.DataFatturato__c = UDate.getDateValue(response.payload.dataChiusura);
      acc.UltimaRichiestaBilancio__c = Date.today();

      //stato patrimoniale
      acc.ImmobilizzazioniImmateriali__c = response.payload.statoPatrimoniale.immobilizzazioniImmateriali;
      acc.ImmobilizzazioniMateriali__c = response.payload.statoPatrimoniale.immobilizzazioniMateriali;
      acc.ImmobilizzazioniFinanziarieEDiverse__c = response.payload.statoPatrimoniale.immobilizzazioniFinanziarieEDiverse;
      acc.ImmobilizzazioniDiCuiPartecipazioni__c = response.payload.statoPatrimoniale.immobilizzazioniDiCuiPartecipazioni;
      acc.AttivoImmobilizzato__c = response.payload.statoPatrimoniale.attivoImmobilizzato;
      acc.Rimanenze__c = response.payload.statoPatrimoniale.rimanenze;
      acc.CreditiEAttivitaDiverse__c = response.payload.statoPatrimoniale.creditiEAttivitaDiverse;
      acc.CreditiDiCuiVersoClienti__c = response.payload.statoPatrimoniale.creditiDiCuiVersoClienti;
      acc.AttivitaFinanziarieELiquidita__c = response.payload.statoPatrimoniale.attivitaFinanziarieELiquidita;
      acc.AttivoCircolante__c = response.payload.statoPatrimoniale.attivoCircolante;
      acc.TotaleAttivo__c = response.payload.statoPatrimoniale.totaleAttivo;
      acc.Capitale__c = response.payload.statoPatrimoniale.capitale;
      acc.Riserve__c = response.payload.statoPatrimoniale.riserve;
      acc.CreditiVersoSociPerVersDovuti__c = response.payload.statoPatrimoniale.creditiVersoSociPerVersDovuti;
      acc.RisultatoDiEsercizio__c = response.payload.statoPatrimoniale.risultatoDiEsercizio;
      acc.PatrimonioNetto__c = response.payload.statoPatrimoniale.patrimonioNetto;
      acc.FondoTrattamentoAFineRapporto__c = response.payload.statoPatrimoniale.fondoTrattamentoAFineRapporto;
      acc.FondiPerRischiEOneri__c = response.payload.statoPatrimoniale.fondiPerRischiEOneri;
      acc.DebitiOltreIlBt__c = response.payload.statoPatrimoniale.debitiOltreIlBt;
      acc.DebitiDiCuiVersoBanche__c = response.payload.statoPatrimoniale.debitiDiCuiVersoBanche;
      acc.DebitiConsolidati__c = response.payload.statoPatrimoniale.debitiConsolidati;
      acc.RisorsePermanenti__c = response.payload.statoPatrimoniale.risorsePermanenti;
      acc.DebitiCorrenti__c = response.payload.statoPatrimoniale.debitiCorrenti;
      acc.DebitiCorrentiDiCuiDebitiBancari__c = response.payload.statoPatrimoniale.debitiCorrentiDiCuiDebitiBancari;
      acc.DebitiCorrentiDiCuiDebitiCommerciali__c = response.payload.statoPatrimoniale.debitiCorrentiDiCuiDebitiCommerciali;
      acc.DebitiDiversiEAltrePassivita__c = response.payload.statoPatrimoniale.debitiDiversiEAltrePassivita;
      acc.PassivoCorrente__c = response.payload.statoPatrimoniale.passivoCorrente;
      acc.TotalePassivo__c = response.payload.statoPatrimoniale.totalePassivo;
      acc.TotaleGaranziePersonaliPrestate__c = response.payload.statoPatrimoniale.totaleGaranziePersonaliPrestate;
      acc.DiCuiCreditiVersoSociOIntergruppo__c = response.payload.statoPatrimoniale.diCuiCreditiVersoSociOIntergruppo;
      acc.DiCuiDebitiVersoSociOIntergruppo__c = response.payload.statoPatrimoniale.diCuiDebitiVersoSociOIntergruppo;

      //conto economico
      acc.RicaviNetti__c = response.payload.contoEconomico.ricaviNetti;
      acc.VariazioneSemilavoratiEProdotti__c = response.payload.contoEconomico.variazioneSemilavoratiEProdotti;
      acc.VarLavoriInCorsoSuOrdinazione__c = response.payload.contoEconomico.varLavoriInCorsoSuOrdinazione;
      acc.IncrementiImmobilizPerLavoriInterni__c = response.payload.contoEconomico.incrementiImmobilizPerLavoriInterni;
      acc.AltriRicaviEProventi__c = response.payload.contoEconomico.altriRicaviEProventi;
      acc.ValoreDellaProduzione__c = response.payload.contoEconomico.valoreDellaProduzione;
      acc.MateriePrimeSussidiarieDiConsumo__c = response.payload.contoEconomico.materiePrimeSussidiarieDiConsumo;
      acc.VarRimMatPrimeSussidConsumoEMerci__c = response.payload.contoEconomico.varRimMatPrimeSussidConsumoEMerci;
      acc.CostiPerServizi__c = response.payload.contoEconomico.costiPerServizi;
      acc.ValoreAggiunto__c = response.payload.contoEconomico.valoreAggiunto;
      acc.CostiDelPersonale__c = response.payload.contoEconomico.costiDelPersonale;
      acc.RisultatoOperativoLordo__c = response.payload.contoEconomico.risultatoOperativoLordo;
      acc.AmmortamentoImmobilizMateriali__c = response.payload.contoEconomico.ammortamentoImmobilizMateriali;
      acc.AmmortamentoImmobilizImmateriali__c = response.payload.contoEconomico.ammortamentoImmobilizImmateriali;
      acc.AltreSvalutazioniDelleImmobilizzazioni__c = response.payload.contoEconomico.altreSvalutazioniDelleImmobilizzazioni;
      acc.OneriDiversiDiGestione__c = response.payload.contoEconomico.oneriDiversiDiGestione;
      acc.SvalutazioneDelCircolanteEDiverse__c = response.payload.contoEconomico.svalutazioneDelCircolanteEDiverse;
      acc.AccantonamentiPerRischiEOneriDiversi__c = response.payload.contoEconomico.accantonamentiPerRischiEOneriDiversi;
      acc.RisultatoOperativo__c = response.payload.contoEconomico.risultatoOperativo;
      acc.ProventiFinanziari__c = response.payload.contoEconomico.proventiFinanziari;
      acc.InteressiEAltriOneriFinanziari__c = response.payload.contoEconomico.interessiEAltriOneriFinanziari;
      acc.RettificheDiValoreDiAttivitaFinanziarie__c = response.payload.contoEconomico.rettificheDiValoreDiAttivitaFinanziarie;
      acc.RisultatoCorrente__c = response.payload.contoEconomico.risultatoCorrente;
      acc.OneriStraordinari__c = response.payload.contoEconomico.oneriStraordinari;
      acc.ProventiStraordinari__c = response.payload.contoEconomico.proventiStraordinari;
      acc.RisultatoPrimaDelleImposte__c = response.payload.contoEconomico.risultatoPrimaDelleImposte;
      acc.ImposteSulRedditoDiEsercizio__c = response.payload.contoEconomico.imposteSulRedditoDiEsercizio;
      acc.RisultatoDiEsercizioConto__c = response.payload.contoEconomico.risultatoDiEsercizio;
      acc.NumberOfEmployees = response.payload.contoEconomico.numeroDipendenti.intValue();
      acc.WGC_Numero_dipendenti__c = response.payload.contoEconomico.numeroDipendenti.intValue();

      update acc;
      System.debug('SV ACCOUNT UPDATE: ' + acc);
    } catch (Ex.WsCalloutException e) {
    } catch (DMLException e) {
      Logger.log('RIBES_BilancioSintetico', e.getDmlMessage(0) + '. ' + e.getStackTraceString());
    }
  }
}