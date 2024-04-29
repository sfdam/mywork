public with sharing class WsAnagraficaBeanIn {
    SObject obj;
    WsAnagrafe.DatiAnagraficiCedacri da;

    public WsAnagraficaBeanIn(WsAnagrafe.DatiAnagraficiCedacri datiAnagrafici) {
      this(null, datiAnagrafici);
    }

    public WsAnagraficaBeanIn(SObject obj, WsAnagrafe.DatiAnagraficiCedacri datiAnagrafici) {
      this.obj = obj;
      this.da = datiAnagrafici;
      fixDatiAnagrafici(da);
      mapObject();
    }

    private void fixDatiAnagrafici(WsAnagrafe.DatiAnagraficiCedacri da) {
      System.debug('@@@ da ' + da);
      if(da.infoNascita == null) da.infoNascita = new WsAnagrafe.InfoNascita();
      if(da.cittadinanzaResidenza == null) da.cittadinanzaResidenza = new WsAnagrafe.CittadinanzaResidenza();
      if(da.residenzaLegale == null) da.residenzaLegale = new WsAnagrafe.Indirizzo3();
      if(da.residenzaLegale.via == null) da.residenzaLegale.via = new WsAnagrafe.Via2();
      if(da.residenzaLegale.cap == 0) da.residenzaLegale.cap = null;
      if(da.documento == null) da.documento = new WsAnagrafe.Documento();
      if(da.attivitaEcononica == null) da.attivitaEcononica = new WsAnagrafe.AttivitaEcononica();
      if(da.attivitaEcononica.sae == 0) da.attivitaEcononica.sae = null;
      if(da.attivitaEcononica.rae == 0) da.attivitaEcononica.rae = null;
      if(da.telefono == null) da.telefono = new WsAnagrafe.Telefono2();
      if(da.naturaGiuridica == null) da.naturaGiuridica = new WsAnagrafe.NaturaGiuridica();
      if(da.infoCCIAA == null) da.infoCCIAA = new WsAnagrafe.InfoCCIAA();
      if(da.infoCCIAA.numeroIscrizioneLegale == 0) da.infoCCIAA.numeroIscrizioneLegale = null;
      if(da.domiciliazioneAmministrativa == null) da.domiciliazioneAmministrativa = new WsAnagrafe.DomiciliazioneAmministrativa();
      if(da.domiciliazioneAmministrativa.indirizzo == null) da.domiciliazioneAmministrativa.indirizzo = new WsAnagrafe.Indirizzo3();
      if(da.domiciliazioneAmministrativa.indirizzo.via == null) da.domiciliazioneAmministrativa.indirizzo.via = new WsAnagrafe.Via2();
      if(da.domiciliazioneAmministrativa.indirizzo.cap == 0) da.domiciliazioneAmministrativa.indirizzo.cap = null;
    }

    private void fillPrivacy() {
      if (da.tabellaPrivacy != null) {
        obj.put('ConsensoAllaProfilazione__c', da.tabellaPrivacy.getPrivacyFlag(K.CONSENSO_PROFILAZIONE));
        obj.put('ConsensoAttivitaPromRicercheMercato__c', da.tabellaPrivacy.getPrivacyFlag(K.CONSENSO_PROD_MKT));
        obj.put('ConsensoAttivitaPromozionaleTerzi__c', da.tabellaPrivacy.getPrivacyFlag(K.CONSENSO_PROD_TERZI));
        obj.put('ConsensoProdottiBancaRicercheMercato__c', da.tabellaPrivacy.getPrivacyFlag(K.CONSENSO_PROMOZ_MKT));
        obj.put('ConsensoProdottiSocietaTerze__c', da.tabellaPrivacy.getPrivacyFlag(K.CONSENSO_PROMOZ_TERZI));
        obj.put('ConsensoSoloModalitaTradizionali__c', da.tabellaPrivacy.getPrivacyFlag(K.CONSENSO_MOD_TRADIZ));
      }
    }

    private String fixCap(String state, Decimal cap) {
      if(cap == null) return null;
      else if(state == 'EE') return String.valueOf(cap);
      else return String.valueOf(cap).leftPad(5, '0');
    }

    private String concat(String[] tokens, String sep) {
      String[] newTokens = new String[]{};
      for(String t : tokens) {
        if(!String.isBlank(t)) newTokens.add(t);
      }
      return String.join(newTokens, sep);
    }

    private void mapObject() {
      if(da == null) return;
      if(obj == null) obj = da.isPersonaFisica() ? (SObject) new Contact() : (SObject) new Account();

      fillPrivacy();
      add('CodiceIstituto3N__c', String.valueOf(da.codiceIstituto3N));
      add('NDGGruppo__c', String.valueOf(da.ndg));
      add('SAE__c', da.attivitaEcononica.sae != null ? String.valueOf(da.attivitaEcononica.sae) : null);
      add('TAECode__c', da.codiceTAE);
      add('Phone', da.telefono.getNumeroCompleto());
      add('TelefonoPrefisso__c', da.telefono.prefisso);
      add('TelefonoNumero__c', da.telefono.numero);
      add('CF__c', da.codiceFiscale);
      add('NaturaGiuridica__c', da.naturaGiuridica.descrizione);
      add('Origine__c', WsAnagrafe.CEDACRI);

      if (obj.getSObjectType() == Account.SObjectType && !da.isPersonaFisica()) {
        List<Schema.PicklistEntry> filialePicklist = Account.Filiale__c.getDescribe().getPicklistValues();
        Set<String> filialeValues = new Set<String>();
        for(Schema.PicklistEntry s : filialePicklist){
          filialeValues.add(s.getValue());
        }
        String agenziaCodice;
        try {
          agenziaCodice = String.valueOf(da.agenzia.codice);
        } catch (Exception e) {}

        if (da.naturaGiuridica.descrizione != 'DI') {
          add('Name', concat(new String[]{da.intestazione.cognome, da.intestazione.nome, da.intestazione.attivita}, ' '));
        } else {
          // TODO INTERNATIONAL: dove salvare nome e cognome nel caso di ditte estere? per il reverseCodiceFiscale
          add('Name', da.intestazione.attivita);
          // SObject x = (SObject) da.documento;
          add('WGC_Contact_Information__c', JSON.Serialize(da.documento).replace('}', ',"dataScadenza":' + JSON.Serialize(da.dataScadenzaDocumento) + '}'));
        }
        add('Ateco__c', da.ateco);
        add('RAE__c', da.attivitaEcononica.rae != null ? String.valueOf(da.attivitaEcononica.rae) : null);
        add('Email__c', da.email);
        add('EmailPEC__c', da.datiAggiuntiviComplementari.emailPec);
        add('WebSite', da.sitoInternet);

        add('BillingStreetName__c', da.residenzaLegale.via.nome);
        add('BillingStreetNumber__c', da.residenzaLegale.via.numero);
        add('BillingStreetType__c', da.residenzaLegale.via.tipo);
        add('BillingCity', da.residenzaLegale.comune);
        add('BillingState', da.residenzaLegale.provincia);
        add('BillingPostalCode', fixCap(da.residenzaLegale.provincia, da.residenzaLegale.cap));
        add('BillingCity__c', da.residenzaLegale.comune);
        add('BillingState__c', da.residenzaLegale.provincia);
        add('BillingPostalCode__c', fixCap(da.residenzaLegale.provincia, da.residenzaLegale.cap));

        // TEN - SV CLEAN SHIPPING FOR CREATE ACCOUNT
        add('ShippingStreetName__c', da.domiciliazioneAmministrativa.indirizzo.via.nome);
        add('ShippingStreetNumber__c', da.domiciliazioneAmministrativa.indirizzo.via.numero);
        add('ShippingStreetType__c', da.domiciliazioneAmministrativa.indirizzo.via.tipo);
        add('ShippingCity', da.domiciliazioneAmministrativa.indirizzo.comune);
        add('ShippingState', da.domiciliazioneAmministrativa.indirizzo.provincia);
        add('ShippingPostalCode', fixCap(da.domiciliazioneAmministrativa.indirizzo.provincia, da.domiciliazioneAmministrativa.indirizzo.cap));
        add('ShippingCity__c', da.domiciliazioneAmministrativa.indirizzo.comune);
        add('ShippingState__c', da.domiciliazioneAmministrativa.indirizzo.provincia);
        add('ShippingPostalCode__c', fixCap(da.domiciliazioneAmministrativa.indirizzo.provincia, da.domiciliazioneAmministrativa.indirizzo.cap));

        add('PIVA__c', da.partitaIVA);
        add('REA__c', da.infoCCIAA.numeroIscrizioneLegale == null ? null : String.valueOf(da.infoCCIAA.numeroIscrizioneLegale));
        add('ProvinciaCCIAA__c', da.infoCCIAA.provinciaSedeLegale);
        add('VAT__c', da.partitaIVA);
        add('DataIscrizioneCCIAA__c', UDate.getDateValue(da.infoCCIAA.dataIscrizioneLegale));
        add('Filiale__c', agenziaCodice!= null && filialeValues.contains(agenziaCodice) ? agenziaCodice : null);
        add('CI3N_NDGGruppo__c', da.codiceIstituto3N + '-' + da.ndg);
        obj.put('RecordTypeId', U.getRecordTypes('Account').get('Cliente').Id);
      }

      if(obj.getSObjectType() == Contact.SObjectType && da.isPersonaFisica()) {
        add('Sesso__c', da.sesso);
        add('LastName', da.intestazione.cognome);
        add('FirstName', da.intestazione.nome);
        add('TAECode__c', da.codiceTAE);
        add('Birthdate', UDate.getDateValue(da.infoNascita.data));
        add('LuogoNascita__c', da.infoNascita.luogo);
        add('ProvinciaNascita__c', da.infoNascita.provincia);
        add('Cittadinanza__c', da.cittadinanzaResidenza.descrizioneCittadinanza);

        add('MailingStreetName__c', da.residenzaLegale.via.nome);
        add('MailingStreetNumber__c', da.residenzaLegale.via.numero);
        add('MailingStreetType__c', da.residenzaLegale.via.tipo);
        add('MailingCity', da.residenzaLegale.comune);
        add('MailingPostalCode', fixCap(da.residenzaLegale.provincia, da.residenzaLegale.cap));
        add('MailingState', da.residenzaLegale.provincia);
        add('MailingCity__c', da.residenzaLegale.comune);
        add('MailingPostalCode__c', fixCap(da.residenzaLegale.provincia, da.residenzaLegale.cap));
        add('MailingState__c', da.residenzaLegale.provincia);

        add('DataScadenzaDoc__c', UDate.getDateValue(da.dataScadenzaDocumento));
        add('TipoDocumentoId__c', da.documento.codiceTipo);
        add('NumeroDoc__c', da.documento.numero);
        add('LuogoEmissioneDoc__c', da.documento.ente);
        add('DataEmissioneDoc__c', UDate.getDateValue(da.documento.data));
        add('MobilePhone', da.numeroCellulare);
        add('OtherPhone', da.numeroTelefonoAlternativo);
        add('Email', da.email);
        add('Fax', da.numeroFax);
        add('CI3N_NDGGruppo__c', da.codiceIstituto3N + '-' + da.ndg);

        if(String.isNotBlank(da.infoNascita.luogo)) {
          Comune__c[] comuni = [SELECT
            Id,
            Name,
            CodiceCatastale__c,
            Cab__c
            FROM Comune__c
            WHERE Name = :da.infoNascita.luogo
          ];

          if (!comuni.isEmpty()) {
            Comune__c comune = comuni[0];
            add('CABLocNascita__c', comune.Cab__c);
            add('CodCatastaleLocNascita__c', comune.CodiceCatastale__c);
          }
        }
      }
    }

    private void add(String f, Object v) {
      if(UtilAnagrafiche.isOK(v)) obj.put(f, v);
    }

    public SObject getObj() {
      return this.obj;
    }

    public WsAnagrafe.DatiAnagraficiCedacri getDa() {
      return this.da;
    }
}