public with sharing class WizardOpportunityController {    
    public final static String CODICE_SETTORISTA = 'SRC';
    public final static String CODICE_GESTORE_DEBITORE = 'SRD';
    public final static String CODICE_PRESENTATORE = 'SSU';
    public final static String CODICE_PARAMETRO_IMPORTO_LINEA = 'SF6';
    public final static String RT_DEVNAME_FACTORING = 'IFISOpportunitaFactoring';
    public final static String RT_DEVNAME_FACTORING_RINNOVO = 'IFIS_Rinnovo';
    public final static String RT_DEVNAME_INTERNATIONAL = 'WGC_IFIS_International';
    public final static String RT_DEVNAME_FASTFINANCE = 'IFISOpportunitaFastFinance';
    public final static String RT_DEVNAME_FACTORING_FISCALE = 'WGC_IFIS_Oppotunita_Crediti_Erariali';
    public final static String DIREZIONE_COMMERCIALE_PROFILE_NAME = 'IFIS - Direzione Commerciale';
    public final static String SVILUPPO_COMMERCIALE_PROFILE_NAME = 'IFIS - Sviluppo Commerciale Filiali';
    public final static String LEASING_PROFILE_NAME = 'IFIS - Leasing';
    public final static String SYSTEM_ADMIN_PROFILE_NAME = 'Amministratore del Sistema';
    public final static String OPERATORE_NSA_PROFILE_NAME = 'IFIS - Operatori NSA';
    public final static String FAST_FINANCE_BO_PROFILE_NAME = 'IFIS - B/O Valutazione Fast Finance';
    public final static String COD_STATO_LINEA_DECLINATA = '004';
    public final static String COD_STATO_LINEA_DELIBERATA = '003';
	public final static String COD_LINEA_FIRMACONTRATTI = '11';
	public final static String COD_LINEA_DECLINATA = '5';
	public final static String VALUTAZ_PRATICA = '1';
	
    //Controgaranzie
    public final static String COD_MUTUO_CONTROGARANTITO = 'MutuoControgarantitoMCC';
    public final static String NDG_CONTROGARANTITO_UNICREDIT = '643447';
    //A.M. Inserimento Nota Automatica per nuovo mutuo decreto liquidità 
    //-> Inizio
    public final static String COD_MUTUO_DECRETOLIQUIDITA = 'MutuoDecretoLiquidita';
    public final static String COD_MUTUO_DECRETO13E = 'MutuoDecreto13E';
    //A.M. -> Fine
	//A.M. 02/12/2021 Inserimento Nota Automatica per nuovo mutuo Funding CDP 
    public final static String COD_MUTUO_FUNDING_CDP = 'MutuoFundingCDP';

    //SM - Banca Corporate
    public final static String COD_ANTICIPO_FATTURE = 'AnticipoFatture';
    public final static String COD_FIDO_ANTICIPO_FATTURE = 'FidoAnticipoFatture';
    public final static String COD_SBF = 'SBF';
    public final static String COD_FIDO_SBF = 'FIDOSBF';
    public final static String COD_CONTO_ANTICIPI_PTF = 'ContoAnticipiPTF';

    //SM - TEN: Corporate Estero
    public final static String RT_CORPORATE_ESTERO = 'WGC_Corporate_Estero';

    public WizardOpportunityController() {

    }

    // metodo invocabile dai flow di creazione opportunità per gestire la clonazione in caso di revisione o rinnovo
    @InvocableMethod(label='Clona Opportunità' description='Clona l\'opportunità utilizzando i dati delle linee migrate dal DWH.')
    public static List<String> cloneOpportunity(List<String> opportunity) {
        System.debug('@@@@ opportunity: ' + opportunity);

        try {
            Id targetId = opportunity[0];
            Opportunity target = [SELECT AccountId, Account.WGC_Linee_Fact_Cedente__c, Originator__c, Originator_di_dettaglio__c, WGC_Prodotti_Selezionati__c, WizardCompletato__c, WGC_Cross_Selling_JSON__c, WGC_Prodotti_bloccati__c, Tipologia_Opportunit__c, BI_LineeRevisionabili__c FROM Opportunity WHERE Id = :targetId];
            System.debug('@@@@ targetId: ' + JSON.serialize(target));
            Map<Id, WGC_Linea_Prodotto__c> linee;
            if(target.Tipologia_Opportunit__c == 'RINN')
                linee = new Map<Id, WGC_Linea_Prodotto__c>([SELECT Id, Name, Anagrafica__c, Divisa__c, Codice_Linea_Sistema__c, Accordato__c, Data_Scadenza__c, Procedura_Semplificata__c, Linea_di_carico__c FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c = :target.AccountId AND ( Qualifica_Prodotto__c = 'Cliente attivo' OR Qualifica_Prodotto__c = 'Cliente inattivo' OR Qualifica_Prodotto__c = 'Cliente dormiente') AND Codice_stato__c = '003']);
            else
                linee = new Map<Id, WGC_Linea_Prodotto__c>([SELECT Id, Name, Anagrafica__c, Divisa__c, Codice_Linea_Sistema__c, Accordato__c, Data_Scadenza__c, Procedura_Semplificata__c, Linea_di_carico__c FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c = :target.AccountId AND ( Qualifica_Prodotto__c = 'Cliente attivo' OR Qualifica_Prodotto__c = 'Cliente inattivo' OR Qualifica_Prodotto__c = 'Cliente dormiente' OR Qualifica_Prodotto__c = 'Cliente in avvio' OR Qualifica_Prodotto__c = 'Cliente incerto') AND Codice_stato__c = '003']);

            Set<String> lineeDiCarico = U.getSet(linee.values(), 'Linea_di_carico__c');
            // Map<String, SObject> lineeDiCaricoMap = U.keyBy(U.filter(linee.values(), 'Linea_di_carico__c', (Object)null, false), 'Linea_di_carico__c');
            //SM - TEN - Fix TENAM-259 aggiunto su controllo linee di carico e di acquisto
            Map<String,SObject> lineeDiCaricoMap = new Map<String,SObject>();
            for(WGC_Linea_Prodotto__c l : linee.values()){
                if(String.isNotBlank(l.Linea_di_carico__c)){
                    for(WGC_Linea_Prodotto__c ll : linee.values()){
                        if(ll.Name == l.Linea_di_carico__c){
                            lineeDiCaricoMap.put(l.Linea_di_carico__c, ll);
                        }
                    }
                }
            }
			//A.M. SDHDFNZ-116242 - aggiunta Codice_famiglia_coppia__c = 'E' per la gestione dei fidi di coppia "Endo"
            List<WGC_Fido_di_Coppia__c> fidiCoppia = [SELECT Id, Name, Linea__c, Codice_famiglia_coppia__c, Debitore__c, Numero_Linea_Credito__c, NDG_Debitore__c, Importo_Plafond_Prosolvendo__c, Giorni_Dilazione__c, Importo_Plafond_Prosoluto__c, Termini_di_pagamento__c, COD_TIPO_CAR__c FROM WGC_Fido_di_Coppia__c WHERE (COD_TIPO_CAR__c = 'N' OR COD_TIPO_CAR__c = 'G') AND (Codice_famiglia_coppia__c = 'C' OR Codice_famiglia_coppia__c = 'N' OR Codice_famiglia_coppia__c = 'E') AND Codice_stato_linea__c = '003' AND Linea__c IN :linee.keySet() ORDER BY Data_Delibera__c DESC];
            Id recordTypeDebitoreId = [SELECT Id FROM RecordType WHERE SobjectType = 'NDGLinea__c' AND DeveloperName = 'Debitore' LIMIT 1].Id;

            //SM-CART-REVI
            Set<Id> IdLineeFc = new Set<Id>();
            for(WGC_Fido_Di_Coppia__c fc : fidiCoppia){
                IdLineeFc.add(fc.Linea__c);
            }

            List<WGC_Linea_Prodotto__c> lineeFiltered = new List<WGC_Linea_Prodotto__c>([SELECT Id, Name, Codice_Linea_Sistema__c FROM WGC_Linea_Prodotto__c WHERE Id IN : IdLineeFc]);

			//A.M. Gestione linee da revisionare direttamente da opportunità
			target.BI_LineeRevisionabili__c = (lineeFiltered.size() > 0 ? lineeFiltered.size() : 0);
			System.debug('@@@@A.M. BI_LineeRevisionabili__c: ' + target.BI_LineeRevisionabili__c);
			update target;

            //Set<String> codiciProdotto = U.getSet(linee.values(), 'Codice_Linea_Sistema__c');
            Set<String> codiciProdotto = U.getSet(lineeFiltered, 'Codice_Linea_Sistema__c');

            Set<String> codiciProdottoToBlock = new Set<String>();
            List<WGC_Matrice_ATD__mdt> matATD = [SELECT LineaDiAcquisto__c, Maturity__c, Notifica__c, Anticipazione__c, PrevistaLir__c, LineaSingola__c FROM WGC_Matrice_ATD__mdt];
            Map<String, SObject> matATDMap = U.keyBy(matATD, 'LineaDiAcquisto__c');
            Set<String> codiciATD = matATDMap.keySet();
            Map<String, Prodotto__c> prods = new Map<String, Prodotto__c>();
            // Set<String> fakeIds = U.getSet([SELECT Id, FakeId__c FROM NDGLinea__c], 'FakeId__c');
            Set<String> fakeIds = new Set<String>();
            
            String q = 'SELECT Id, Codice__c, WGC_Famiglia__c, WGC_Area__c, Notifica__c, Maturity__c FROM Prodotto__c WHERE Codice__c IN :codiciProdotto';
            if (U.getSet(linee.values(), 'Procedura_Semplificata__c').contains('true'))
                q += ' OR Codice__c = \'742\'';
            List<Prodotto__c> allProds = Database.query(q);
            // popolo la mappa di prodotti
            for (Prodotto__c p : allProds)
                prods.put(p.Codice__c, p);
System.debug('@@@@ prods: ' + prods);
            // raggruppo i fidicoppia per linea e debitore, prendendo solo il fido con dataDelibera più recente
            Map<String, WGC_Fido_di_Coppia__c> fidiCoppiaMap = new Map<String, WGC_Fido_di_Coppia__c>();
            for (WGC_Fido_di_Coppia__c fc : fidiCoppia) {
                if (fidiCoppiaMap.get(fc.Numero_Linea_Credito__c + '_' + fc.NDG_Debitore__c) == null)
                    fidiCoppiaMap.put(fc.Numero_Linea_Credito__c + '_' + fc.NDG_Debitore__c, fc);
            }
// System.debug('@@@@ fidiCoppiaMap: ' + fidiCoppiaMap);
            Map<String, List<String>> joinAttoreLinea = new Map<String, List<String>>();
            Map<String, NDGLinea__c> attori = new Map<String, NDGLinea__c>();
            Map<String, Linea__c> newLines = new Map<String, Linea__c>();
            RecordType factRT = [SELECT Id FROM RecordType WHERE SobjectType = 'Linea__c' AND DeveloperName = 'FactDir' LIMIT 1];
            // populate attori list from fidi coppia
            for (WGC_Fido_di_Coppia__c fc : fidiCoppiaMap.values()) {
                NDGLinea__c newAtt = new NDGLinea__c();
                Linea__c newLine = new Linea__c();
                Id debitore = fc.Debitore__c;
                List<FormulaRecalcResult> formulaDebResults = new List<FormulaRecalcResult>();
                String debMercato;
                if (debitore.getSObjectType().getDescribe().getName().toUpperCase() == 'ACCOUNT')
                    newAtt.Account__c = debitore;
                else
                    newAtt.Contact__c = debitore;

                formulaDebResults = Formula.recalculateFormulas(new List<NDGLinea__c>{newAtt});
                debMercato = String.valueOf(formulaDebResults[0].getSObject().get('Mercato__c'));

                if (!attori.keySet().contains(fc.NDG_Debitore__c)) {                  
                    newAtt.DivisaNew__c = linee.get(fc.Linea__c).Divisa__c;
                    newAtt.FakeId__c = WizardOpportunityController.generateRandomFakeId(fakeIds);
                    newAtt.Opportunita__c = targetId;
                    newAtt.RecordTypeId = recordTypeDebitoreId;
                    newAtt.Tipo__c = 'Debitore';

                    newAtt.Fatturato__c = ( fc.Termini_di_pagamento__c != 0 && fc.Termini_di_pagamento__c != null ? Math.round(((fc.Importo_Plafond_Prosolvendo__c * 360)/fc.Termini_di_pagamento__c)/1000)*1000 : 0 );
                    newAtt.Plafond__c = fc.Importo_Plafond_Prosolvendo__c;
                    newAtt.DurataNominale__c = fc.Termini_di_pagamento__c;
                    newAtt.DiCuiProsoluto__c = fc.Importo_Plafond_Prosoluto__c;
                    newAtt.WGC_Procedura_Semplificata__c = linee.get(fc.Linea__c).Procedura_Semplificata__c;

                    if (codiciATD.contains(linee.get(fc.Linea__c).Codice_Linea_Sistema__c)) {
                        newAtt.ANotifica__c = ((WGC_Matrice_ATD__mdt) matATDMap.get(linee.get(fc.Linea__c).Codice_Linea_Sistema__c)).Notifica__c == 'SI';
                        newAtt.Maturity__c = ((WGC_Matrice_ATD__mdt) matATDMap.get(linee.get(fc.Linea__c).Codice_Linea_Sistema__c)).Maturity__c == 'SI';
                    } else {
                        newAtt.ANotifica__c = prods.get(linee.get(fc.Linea__c).Codice_Linea_Sistema__c).Notifica__c;
                        newAtt.Maturity__c = prods.get(linee.get(fc.Linea__c).Codice_Linea_Sistema__c).Maturity__c;
                    }

                    attori.put(fc.NDG_Debitore__c, newAtt);
                }
                
                if (fc.Codice_famiglia_coppia__c == 'I') {
                    newLine.LineaATD__c = true;
                    newLine.ICAR__c = 'ICAR automatici';
                }

                newLine.Prodotto__c = prods.get((linee.get(fc.Linea__c).Procedura_Semplificata__c ? '742' : linee.get(fc.Linea__c).Codice_Linea_Sistema__c)).Id;
                newLine.WGC_Numero_Linea_Credito__c = linee.get(fc.Linea__c).Name;
                newLine.WGC_Accordato__c = linee.get(fc.Linea__c).Accordato__c;
                newLine.WGC_Data_Scadenza_Fido__c = linee.get(fc.Linea__c).Data_Scadenza__c;
                newLine.DivisaNew__c = linee.get(fc.Linea__c).Divisa__c;
                //OLD Ticket TENAM-211
                // newLine.Mercato__c = '001'; // TODO: smockare mercato; prendere da DWH
                System.debug('@@@ debMercato ' + debMercato);
                System.debug('@@@ fc ' + JSON.serialize(fc));
                newLine.Mercato__c = debMercato != null ? debMercato : '001';
                newLine.DebitoreTipo__c = 'Debitore';
                newLine.LineaATDSingola__c = (lineeDiCarico.contains(linee.get(fc.Linea__c).Name) || String.isNotBlank(linee.get(fc.Linea__c).Linea_di_carico__c) ? 'N' : 'S');
                newLine.LineaATD__c = (codiciATD.contains(linee.get(fc.Linea__c).Codice_Linea_Sistema__c) || lineeDiCarico.contains(linee.get(fc.Linea__c).Name));
                newLine.TipoLinea__c = ( lineeDiCarico.contains(linee.get(fc.Linea__c).Name) ? 'lineaDiCarico' : (String.isNotBlank(linee.get(fc.Linea__c).Linea_di_carico__c) ? 'lineaDiAcquisto' : '') );
                //newLine.TipoLinea__c = lineeDiCarico.contains(linee.get(fc.Linea__c).Name) ? 'lineaDiCarico' : 'lineaDiAcquisto';
                newLine.RecordTypeId = factRT.Id;

                if (newLine.LineaATDSingola__c == 'N') { // se linee atd multiple devo recuperare entrambi i codici prodotto, prima quello della linea di acquisto poi quello della linea di carico
                    String codesContainer = '';
                    if (lineeDiCarico.contains(linee.get(fc.Linea__c).Name)) { // se linea in analisi è linea di carico allora devo recuperare codice prodotto di linea di acquisto
                        List<WGC_Linea_Prodotto__c> lineeDiAcquisto = U.filter(linee.values(), 'Linea_di_carico__c', linee.get(fc.Linea__c).Name);
                        if (lineeDiAcquisto.size() == 1)
                            codesContainer = lineeDiAcquisto[0].Codice_Linea_Sistema__c + '_' + linee.get(fc.Linea__c).Codice_Linea_Sistema__c;
                    } else {
                        codesContainer = linee.get(fc.Linea__c).Codice_Linea_Sistema__c + '_' + ((WGC_Linea_Prodotto__c) lineeDiCaricoMap.get(linee.get(fc.Linea__c).Linea_di_carico__c)).Codice_Linea_Sistema__c;
                    }
                    newLine.WGC_CodiceUnivocoLinea__c = CtrlWizardOpportunity.getCodiceUnivocoLinea(newLine, codesContainer, '_');
                } else // se linea in analisi è linea di acquisto allora devo recuperare codice prodotto di linea di carico
                    newLine.WGC_CodiceUnivocoLinea__c = CtrlWizardOpportunity.getCodiceUnivocoLinea(newLine, linee.get(fc.Linea__c).Procedura_Semplificata__c ? '742' : linee.get(fc.Linea__c).Codice_Linea_Sistema__c, '_');

                if (lineeDiCarico.contains(linee.get(fc.Linea__c).Name))
                    codiciProdottoToBlock.add(linee.get(fc.Linea__c).Codice_Linea_Sistema__c);
                
                newLine.Opportunity__c = targetId;
                
                if (newLines.get(newLine.WGC_Numero_Linea_Credito__c) == null)
                    newLines.put(newLine.WGC_Numero_Linea_Credito__c, newLine);

                // if (joinAttoreLinea.get(fc.Numero_Linea_Credito__c) == null)
                //     joinAttoreLinea.put(fc.Numero_Linea_Credito__c, new List<String>{fc.NDG_Debitore__c});
                // else
                //     joinAttoreLinea.get(fc.Numero_Linea_Credito__c).add(fc.NDG_Debitore__c);
            }
// System.debug('@@@@ attori: ' + attori);
// System.debug('@@@@ newLines: ' + newLines);
            insert attori.values();
            insert newLines.values();

            List<JoinLineaDebitore__c> joinLineaDebitore = new List<JoinLineaDebitore__c>();
            for (WGC_Fido_di_Coppia__c fc : fidiCoppiaMap.values()) {
                JoinLineaDebitore__c newJoin = new JoinLineaDebitore__c();
                Boolean fakeJoin = true;

                if(newLines.get(fc.Numero_Linea_Credito__c).LineaATD__c) {
                    // mi serve per sapere se la linea ATD è singola o meno
                    Boolean lineaSingola = newLines.get(fc.Numero_Linea_Credito__c).LineaATDSingola__c == 'S';
                    String tipoLinea = newLines.get(fc.Numero_Linea_Credito__c).TipoLinea__c;
                    // aggiungo il join solo se si tratta di linea non ATD oppure se è ATD ed è linea di acquisto singola e prosoluto
                    if(lineaSingola && (tipoLinea == 'lineaDiAcquisto' || tipoLinea == '')) fakeJoin = false;
                    // linea doppia, debitore prosolvendo o prosoluto vanno sempre e solo sulla linea di carico
                    if(!lineaSingola && tipoLinea == 'lineaDiCarico') fakeJoin = false;
                    // MB - TEN: fakeJoin uguale a false per prodotto Procedura Semplificata
                    if (linee.get(fc.Linea__c).Procedura_Semplificata__c) fakeJoin = false;
                } else fakeJoin = false; // non si tratta di un ATD, quindi aggiungo sempre

                newJoin.Opportunita__c = targetId;
                newJoin.Linea__c = newLines.get(fc.Numero_Linea_Credito__c).Id;
                newJoin.Debitore__c = attori.get(fc.NDG_Debitore__c).Id;
                newJoin.Fake__c = fakeJoin;
                newJoin.WGC_Codice_Random_Coppia__c = fc.Name;
                newJoin.WGC_Cod_Tipo_Car__c = fc.COD_TIPO_CAR__c;

                joinLineaDebitore.add(newJoin);
            }

            insert joinLineaDebitore;

            // List<JoinLineaDebitore__c> joinLineaDebitore = new List<JoinLineaDebitore__c>();
            // // populate joinLineaDebitore list from fidi coppia and linee
            // for (String numLineaCredito : joinAttoreLinea.keySet()) {
            //     for (String NDGDeb : joinAttoreLinea.get(numLineaCredito)) {
            //         JoinLineaDebitore__c newJoin = new JoinLineaDebitore__c();

            //         newJoin.Opportunita__c = targetId;
            //         newJoin.Linea__c = newLines.get(numLineaCredito).Id;
            //         newJoin.Debitore__c = attori.get(NDGDeb).Id;

            //         joinLineaDebitore.add(newJoin);
            //     }
            // }

            // insert joinLineaDebitore;
            
            // TODO: valorizzare l'elenco dei prodotti bloccati relativi all'opportunità (in attesa del campo relazione tra WGC_Linea_Prodotto__c e Prodotto__c)
            System.debug('@@@@ codiciProdottoToBlock: ' + codiciProdottoToBlock);
            target.WGC_Prodotti_bloccati__c = '';
            for (Prodotto__c pr : prods.values())
                if (pr.WGC_Area__c == 'Factoring - Cedente' && !codiciProdottoToBlock.contains(pr.Codice__c))
                    target.WGC_Prodotti_bloccati__c += pr.WGC_Famiglia__c + ';';

            target.WGC_Prodotti_bloccati__c = target.WGC_Prodotti_bloccati__c.substring(0, target.WGC_Prodotti_bloccati__c.length()-1);
            target.HasFactoringDiretto__c = (target.Account.WGC_Linee_Fact_Cedente__c > 0);
            
            //SM - TEN CR 414
            if(target.WGC_Prodotti_Bloccati__c != null && target.WGC_Prodotti_Selezionati__c != null){
                List<String> prodBlocked = target.WGC_Prodotti_Bloccati__c.split(';');
                List<String> prodSelected = target.WGC_Prodotti_Selezionati__c.split(';');
                Set<String> prodSelectedFiltered = new Set<String>(prodSelected);
                prodSelected = new List<String>(prodSelectedFiltered);

                Boolean checkDuplicati = false;
                for(String ps : prodSelected){
                    if(prodBlocked.contains(ps))
                        checkDuplicati = true;
                }
	
                if(checkDuplicati){
                    for(String pB : prodBlocked){
                        if(prodSelectedFiltered.contains(pB)){
                            for(String pS : prodSelectedFiltered){
                                if(pS == pB){
                                    prodSelectedFiltered.remove(pS);
                                }
                            }
                        }
                    }
                             
                    String prodSelectedStr = '';
                    for(String pS : prodSelectedFiltered){
                        prodSelectedStr += pS+';';
                    }
                    
                    if(prodSelectedStr != '')
                        target.WGC_Prodotti_Selezionati__c = prodSelectedStr.substring(0, prodSelectedStr.length()-1);
                    else
                        target.WGC_Prodotti_Selezionati__c = prodSelectedStr;
                }
            }

            update target;

            return null;
        } catch (Exception e) {
            System.debug('@@@ clona exc ' + e.getStackTraceString() + ' -- ' + e.getCause());
            List<String> ret = new List<String>();
            ret.add(e.getMessage());
            Log__c l = new Log__c(Source__c = 'Clona', ErorrMessage__c = e.getMessage(), InputPayload__c = e.getStackTraceString());
            return ret;
        }
    }

    @AuraEnabled
    public static Opportunity getOpportunityRecordType (Id opportunityId) {
        return [SELECT Id, RecordTypeId, RecordType.DeveloperName FROM Opportunity WHERE Id = :opportunityId];
    }
    
    @AuraEnabled
    public static Boolean isOpportunityVisible(Id opportunityId) {
        // MB - TEN-961 *** ALL PROFILES HAVE ACCESS TO OPPORTUNITIES
        return true;
        // MB - TEN-961 *** ALL PROFILES HAVE ACCESS TO OPPORTUNITIES
        
        // User u = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        // if (u.Profile.Name == 'Amministratore del sistema' || u.Profile.Name == 'System Administrator') // SKIP PER ADMIN
        //     return true;

        // if (u.Profile.Name == SVILUPPO_COMMERCIALE_PROFILE_NAME || u.Profile.Name == DIREZIONE_COMMERCIALE_PROFILE_NAME || u.Profile.Name == LEASING_PROFILE_NAME) // SKIP PER DIREZIONE COMMERCIALE, SKIP PER SVILUPPO COMMERCIALE FILIALE (READONLY)
        //     return true;
        
        // List<Opportunity> listOpp = new List<Opportunity>();
        // Opportunity opp = new Opportunity();
        // listOpp = [SELECT Id, OwnerId, TiAnticipo__c, IsOppNSA__c, RecordType.DeveloperName, StageName FROM Opportunity WHERE Id = :opportunityId]; // SKIP PER TA, NSA, FASTFINANCE, FASE DIVERSA DA "IN ISTRUTTORIA"

        // if (listOpp.size() == 0)
        //     return false;
        // else
        //     opp = listOpp[0];

        // if (opp.TiAnticipo__c == true || opp.IsOppNSA__c == true || opp.RecordType.DeveloperName == 'IFISOpportunitaFastFinance' || opp.StageName != 'In Istruttoria')
        //     return true;

        // return opp.OwnerId == UserInfo.getUserId();
    }

    @AuraEnabled
    public static Boolean checkOwnership(Id opportunityId){
        Opportunity opp = [SELECT OwnerId, Owner.Profile.Name, Owner.ManagerId, TiAnticipo__c, IsOppNSA__c FROM Opportunity WHERE Id = :opportunityId];
        User cu = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];

        return  opp.OwnerId == UserInfo.getUserId() || 
                opp.Owner.ManagerId == UserInfo.getUserId() || 
                cu.Profile.Name == DIREZIONE_COMMERCIALE_PROFILE_NAME || 
                cu.Profile.Name == SYSTEM_ADMIN_PROFILE_NAME ||
                ((opp.TiAnticipo__c == true || opp.IsOppNSA__c == true) && cu.Profile.Name == OPERATORE_NSA_PROFILE_NAME);
    }

    @AuraEnabled
    public static Boolean checkIfClosable(Id opportunityId){
        Opportunity opp = [SELECT OwnerId, StageName, StatoPEF__c, Owner.Profile.Name, Owner.ManagerId, TiAnticipo__c, IsOppNSA__c FROM Opportunity WHERE Id = :opportunityId];
        User cu = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        
        Boolean isClosable = false;
        
        //A.M. -> Chiusura Opportunità manualmente anche nello stage "Perfezionamento Contratto" in quanto è lo step in cui il commerciale dovrebbe far firmare il contratto al cliente
        //        ma ci sono casi in cui il cliente ci ripensa o il commerciale sa che non sarà mai avviato
        //if(opp.StageName == 'In Istruttoria' || opp.StageName == 'In Lavorazione'){
		//SDCHG-6141 - A.M. -> 01/04/22 Abilitazione del pulsante in fase "Da avviare" o legata alla parametrizzazione (aggiunto Funzionalita__c.getInstance().BI_Chiudi_Opportunity__c)
        if(opp.StageName == 'In Istruttoria' || opp.StageName == 'In Lavorazione' || opp.StageName == 'Perfezionamento Contratto' || opp.StageName == 'Attivazione' || Funzionalita__c.getInstance().BI_Chiudi_Opportunity__c){
            return true;
        }
        if(opp.StageName == 'Valutazione Pratica' && String.isBlank(opp.StatoPEF__c) && (cu.Profile.Name == DIREZIONE_COMMERCIALE_PROFILE_NAME || cu.Profile.Name == SYSTEM_ADMIN_PROFILE_NAME || cu.Profile.Name == OPERATORE_NSA_PROFILE_NAME)){
            return true;
        }        
        return isClosable;        
    }

    @AuraEnabled
    public static String getOptyRT(Id opportunityId){
        return [SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id = :opportunityId].RecordType.DeveloperName;    
    }    
    
    @AuraEnabled
    public static List<Opportunity> getOpportunities (String accountID) {
        return [SELECT Id, Name, Account.Name, StageName, Amount, Owner.Name, CloseDate, Probability, CreatedDate, WGC_Prodotti_Selezionati__c FROM Opportunity WHERE AccountId =: accountID];
    }

    @AuraEnabled
    public static List<Opportunity> getOpportunities (String accountID, String recordTypeDevName) {
        return [SELECT Id, Name, Account.Name, StageName, Amount, Owner.Name, CloseDate, Probability, CreatedDate, WGC_Prodotti_Selezionati__c FROM Opportunity WHERE AccountId = :accountID AND RecordType.DeveloperName = :recordTypeDevName];
    }

    @AuraEnabled
    public static List<Opportunity> getFactoringOpportunities (String accountID) {
        return getOpportunities(accountID, 'IFISOpportunitaFactoring');
    }

    @AuraEnabled
    public static List<Opportunity> setProductInOpp (String opportunityId, String itemsProduct) {
        System.debug('SV opportunityId: ' + opportunityId);
        System.debug('SV itemsProduct: ' + itemsProduct);

        List<Opportunity> oppList = new List<Opportunity>();
        List<WrapperProduct> InputList = (List<WrapperProduct>)JSON.deserialize(itemsProduct, List<WrapperProduct>.class);
        Opportunity opp = [ SELECT Id, Name, Account.Name, StageName, Amount, Owner.Name, CloseDate, Probability, CreatedDate, WGC_Prodotti_Selezionati__c FROM Opportunity WHERE Id =: opportunityId ];

        String Prodotti_Selezionati = '';
        for (WrapperProduct prod : InputList){
            Prodotti_Selezionati += prod.name;
            Prodotti_Selezionati += ';';
        }
        
        opp.WGC_Prodotti_Selezionati__c = Prodotti_Selezionati.removeEnd(';');
        upsert opp;

        oppList.add(opp);

        return oppList;
    }

    @AuraEnabled
    public static List<WrapperProduct> getProducts(Id opportunityId) {
        List<WrapperProduct> result = new List<WrapperProduct>();
        Map<String, List<String>> sbMap = new Map<String, List<String>>();
        Integer counter = 0;
		//A.M. Gestione cliente incerto
        // filtro i conti correnti non affidati (vengono generati automaticamente a livello di motore)
        Opportunity opp = [SELECT Tipologia_Opportunit__c, Account.WGC_Linee_Fact_Cedente__c, Account.WGC_Linee_Fact_Debitore__c, Account.WGC_Linee_Conto_Corrente__c, Account.WGC_Linee_Fact_Cedente_Incerto__c FROM Opportunity WHERE Id = :opportunityId]; // CONC: Nuova Concessione, RINN: Rinnovo, REVI: Revisione, CROSS: Cross Selling
        List<Prodotto__c> prods = [SELECT Id, Name, CodiceUnivoco__c, WGC_Famiglia__c, WGC_Area__c, WGC_Sottobisogno__c, WGC_Tipo_Cross_Selling__c, WGC_ConfigurazioneFormSubProduct__c, WGC_Icona__c FROM Prodotto__c WHERE WGC_Famiglia__c != '' AND ((NOT CodiceUnivoco__c LIKE '%NonAffidato%')) ORDER BY WGC_Famiglia__c];
        Map<String, Linea__c[]> usersRecentLines = (Map<String, Linea__c[]>) U.groupBy([SELECT Id, Prodotto__r.WGC_Famiglia__c FROM Linea__c WHERE Opportunity__r.OwnerId = :UserInfo.getUserId() ORDER BY CreatedDate DESC], 'Prodotto__r.WGC_Famiglia__c');
        // for loop to remove recentLines above the first 4
        for (String k : usersRecentLines.keySet()) {
            if (counter < 4)
                counter++;
            else
                usersRecentLines.remove(k);
        }

        List<Prodotto__c> filteredProds = new List<Prodotto__c>();
        for (Prodotto__c p : prods) {
            // if (p.WGC_Area__c == 'Factoring - Cedente' && opp.Tipologia_Opportunit__c == 'CROSS')
            //     continue;
            if (sbMap.containsKey(p.WGC_Famiglia__c) == true) {
                if (!sbMap.get(p.WGC_Famiglia__c).contains(p.WGC_Sottobisogno__c))
                    sbMap.get(p.WGC_Famiglia__c).add(p.WGC_Sottobisogno__c);
            }
            else
                sbMap.put(p.WGC_Famiglia__c, new List<String>{p.WGC_Sottobisogno__c});

            filteredProds.add(p);
        }
        
        Map<String, Prodotto__c[]> familyProds = (Map<String, Prodotto__c[]>) U.groupBy(filteredProds, 'WGC_Famiglia__c');
        for (String fam : familyProds.keySet()) {
            WrapperProduct wp = new WrapperProduct();
            wp.name = fam;
            wp.area = familyProds.get(fam)[0].WGC_Area__c;
            wp.codice = familyProds.get(fam)[0].CodiceUnivoco__c;
            wp.sottobisogni = sbMap.get(fam);
            wp.recent = (usersRecentLines.get(fam) != null);
            wp.subProductForm = familyProds.get(fam)[0].WGC_ConfigurazioneFormSubProduct__c;
            wp.icona = familyProds.get(fam)[0].WGC_Icona__c;
            wp.tipoCrossSelling = familyProds.get(fam)[0].WGC_Tipo_Cross_Selling__c;
            result.add(wp);
        }

        return getProfilatedProducts(result, opp);
    }

    private static List<WrapperProduct> getProfilatedProducts(List<WrapperProduct> products, Opportunity opp) {
        User u = [SELECT Id, Qualifica_Utente__c, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
System.debug('@@@@ MB - TEN: products -- ' + products);
        switch on u.Qualifica_Utente__c {
            when 'Sviluppo_Commerciale_Filiali', 'Finanza Strutturata' { // Factoring
                // DO NOTHING: USERS CAN SEE AND SELL ALL PRODUCTS
                if (opp.Tipologia_Opportunit__c == 'CROSS') { // SE oppty only CROSS SELLING => PRODS FILTERED
                    List<WrapperProduct> filtered = new List<WrapperProduct>();
                    for (WrapperProduct p : products)
                        if (p.tipoCrossSelling != 'IFISOpportunitaFactoring')
                            filtered.add(p);
                    
                    products = filtered;
                }
            }
            // when 'Finanza Strutturata' {
            //     List<WrapperProduct> filtered = new List<WrapperProduct>();
            //     for (WrapperProduct p : products)
            //         if (p.tipoCrossSelling != 'IFISOpportunitaFinanzaStrutturata')
            //             filtered.add(p);
                
            //     products = filtered;
            // }
            when 'Leasing EF', 'Leasing TR' {
                List<WrapperProduct> filtered = new List<WrapperProduct>();
                for (WrapperProduct p : products)
                    if (p.tipoCrossSelling != 'WGC_IFIS_Leasing' && p.tipoCrossSelling != 'WGC_IFIS_Oppotunita_Crediti_Erariali' && p.tipoCrossSelling != 'WGC_IFIS_Corporate' && p.tipoCrossSelling != 'WGC_IFIS_Corporate_Estero')
                        filtered.add(p);
                
                if (opp.Tipologia_Opportunit__c == 'CROSS' && opp.Account.WGC_Linee_Fact_Cedente__c > 0) { // SE oppty CROSS SELLING e ANAGRAFICA ha già linee attive di FACTORING => BLOCCO la possibilità di fare CROSS SELLING verso FACTORING
                    for (WrapperProduct p : products)
                        if (p.tipoCrossSelling != 'IFISOpportunitaFactoring')
                            filtered.add(p);
                    
                    products = filtered;
                }
                
                products = filtered;
            }
            when 'IFIS_International' {
                List<WrapperProduct> filtered = new List<WrapperProduct>();
                for (WrapperProduct p : products)
                    if (p.tipoCrossSelling == 'IFISOpportunitaFactoring')
                        filtered.add(p);
                
                products = filtered;
            }
            when 'Crediti Erariali' {
                List<WrapperProduct> filtered = new List<WrapperProduct>();
                for (WrapperProduct p : products){
				//A.M. SDCHG-5654 Apertura c/c per commerciali di Crediti Erariali (aggiunto || p.subProductForm == 'ContoCorrente')
                    if ((opp.Tipologia_Opportunit__c != 'CROSS' && (p.tipoCrossSelling == 'WGC_IFIS_Oppotunita_Crediti_Erariali' || u.Profile.Name == FAST_FINANCE_BO_PROFILE_NAME || p.subProductForm == 'ContoCorrente')) || (opp.Tipologia_Opportunit__c == 'CROSS' && p.tipoCrossSelling != 'WGC_IFIS_Oppotunita_Crediti_Erariali' && p.tipoCrossSelling != 'WGC_IFIS_Corporate' && p.tipoCrossSelling != 'WGC_IFIS_Corporate_Estero'))
                        filtered.add(p);
                }
                
                products = filtered;
            }
        }

        // if ((opp.Account.WGC_Linee_Fact_Cedente__c > 0 || opp.Account.WGC_Linee_Fact_Debitore__c > 0 || opp.Account.WGC_Linee_Conto_Corrente__c > 0) && opp.Tipologia_Opportunit__c == 'CROSS') {
        //     List<WrapperProduct> filtered = new List<WrapperProduct>();
        //     for (WrapperProduct p : products)
        //         if (p.tipoCrossSelling != 'IFISOpportunitaFactoring')
        //             filtered.add(p);
            
        //     products = filtered;
        // }

        return products;
    }

    @AuraEnabled
    public static User getUserInfo(){
        return [SELECT Id, Qualifica_Utente__c FROM User WHERE Id = :UserInfo.getUserId()];
    }
    
    /*..........................................*/
    /* Wrapper class to display Prodotti        */
    /*..........................................*/
    
    public class WrapperProduct {
        
        @AuraEnabled public String area;
        @AuraEnabled public String name;
        @AuraEnabled public String codice;
        @AuraEnabled public List<String> sottobisogni;
        @AuraEnabled public Boolean recent;
        @AuraEnabled public String subProductForm;
        @AuraEnabled public String icona;
        @AuraEnabled public String tipoCrossSelling;
        
        public WrapperProduct(){
            area = '';
            name = '';
            codice = '';
            sottobisogni = new List<String>();
            recent = false;
            subProductForm = '';
            icona = '';
            tipoCrossSelling = '';
        }
    }

    @AuraEnabled
    public static WrapperSectionsAndParameters getParametriEConfigurazioniLinee(Id opportunityId) {
        WrapperSectionsAndParameters result = new WrapperSectionsAndParameters();
        result.sezioni = CtrlWizardOpportunity.getSezioni();
        result.parametri = CtrlWizardOpportunity.getParametriProdottiLinea(opportunityId);
        system.debug(result.parametri);
        return result;
    }

    /*..........................................*/
    /* Wrapper class to display Parametri       */
    /*..........................................*/
    
    public class WrapperSectionsAndParameters {
        
        @AuraEnabled public List<MatriceSezioni__mdt> sezioni;
        @AuraEnabled public List<CtrlWizardOpportunity.WoConfigurazioneParametro> parametri;
        
        public WrapperSectionsAndParameters(){
            sezioni = new List<MatriceSezioni__mdt>();
            parametri = new List<CtrlWizardOpportunity.WoConfigurazioneParametro>();
        }
    }

    @AuraEnabled
    public static WrapperResponse getPayload(Id opportunityId) {
        WrapperResponse resp = new WrapperResponse();
        try {
            resp.data = CtrlWizardOpportunity.editRsf(opportunityId);
            
            Set<Id> accountSet = new Set<Id>();
            for (CtrlWizardOpportunity.WoDebitore deb : resp.data.debitori)
                accountSet.add(deb.account);
            
            Map<ID, Account> mapAccPiva = new Map<ID, Account>([SELECT Id, PIVA__c FROM Account WHERE Id IN :accountSet]);
            // ITERATE OVER DEBITORI TO SET P.IVA = CF RATHER THEN ID
            for (CtrlWizardOpportunity.WoDebitore deb : resp.data.debitori)
                deb.piva = (deb.piva == deb.account ? mapAccPiva.get(deb.account).PIVA__c : deb.piva);
        } catch (Exception e) {
            resp.success = false;
            resp.msg = e.getMessage();
        }
        // System.debug(resp);
        // System.debug(resp.data);
        return resp;
    }
    
    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public String redirect;
        @AuraEnabled public CtrlWizardOpportunity.WoPayload data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            redirect = '';
            data = new CtrlWizardOpportunity.WoPayload();
        }
    }

    // @AuraEnabled
    // public static WrapperResponse saveWizard(String payload, String step) {
    //     return saveWizard(payload, step, false);
    // }

    @AuraEnabled
    public static WrapperResponse saveWizard(String payload, String step) {
        WrapperResponse resp = new WrapperResponse();
		System.debug('@@@@A.M. saveWizard-step: '+ step);
		System.debug('@@@@A.M. saveWizard-payload: '+ payload);
        // resp.data = CtrlWizardOpportunity.saveWizard(payload, step);
        try {
            for (String s : step.split(',')) { // ciclo per salvataggio icarManuali
                resp.data = CtrlWizardOpportunity.saveWizard(payload, s);
                System.debug('@@@@ resp.data: '+ resp.data);
            }
            if (step == 'categorie') {
                Map<String, Object> p = (Map<String, Object>) JSON.deserializeUntyped(payload);
                WizardOpportunityController.updateWizardCompletato(payload);
                // WizardOpportunityController.updateNoteAutomatiche(payload);
                WizardOpportunityController.updateFactFiscFlag(payload);
                //A.M. Gestione Bonus Edilizi
                //resp.data = WizardOpportunityController.manageDefaultDebitore((Boolean) p.get('factfisc'), (String) p.get('opportunityId'));
                WizardOpportunityController.updateBonusEdiliziFlag(payload);
                resp.data = WizardOpportunityController.manageDefaultDebitore((Boolean) p.get('factfisc'), (Boolean) p.get('BonusEdil'), (String) p.get('opportunityId'));
            }
            // if(step == 'categorie_corporate'){
            //     resp.data = WizardOpportunityController.saveCorporateLines(payload);
            // }
            if (step == 'configurazionelinee')
                WizardOpportunityController.updateWizardCompletato(payload);
                WizardOpportunityController.updateNoteAutomatiche(payload);
            if (step == 'servizi') {
                WizardOpportunityController.updateWizardCompletato(payload);
                resp.redirect = WizardOpportunityController.manageCrossSelling(payload);
            }

        } catch (Exception e) {
            resp.success = false;
            resp.msg = e.getMessage();
            System.debug('SAVEWIZARD ERROR: '+e.getMessage()+' --- '+e.getStackTraceString());
        }

        System.debug('resp: '+resp);
        // System.debug(resp.data);
        return resp;
    }

    @AuraEnabled
    public static MatriceServizio__mdt[] getServizi() {
        // return CtrlWizardOpportunity.getServizi(false);
        return [SELECT Id,
                    DeveloperName,
                    Label,
                    Icona__c,
                    Ordinamento__c,
                    Acquisto__c,
                    WGC_Famiglia__c
                FROM MatriceServizio__mdt
                ORDER BY Ordinamento__c];
                // WHERE DeveloperName != 'ATDTiAnticipo'
    }

    @AuraEnabled
    public static WGC_Mapping_Divisa__mdt[] getDiviseOptions() {
        return [SELECT Id, Codice_Divisa__c, Simbolo__c, Valore__c FROM WGC_Mapping_Divisa__mdt];
    }

    @AuraEnabled
    //A.M. Aggiunto ordinamento
    public static List<Prodotto__c> getTipologieMutui(){
        return [SELECT CodiceUnivoco__c, Name FROM Prodotto__c WHERE WGC_Famiglia__c = 'Mutuo' ORDER BY Codice__c];
    }

    @AuraEnabled
    //A.M. Gestione Mutuo Veneto Sviluppo
    public static List<Prodotto__c> getTipologieMutuiVS(){
        return [SELECT CodiceUnivoco__c, Name FROM Prodotto__c WHERE WGC_Famiglia__c = 'Mutuo Veneto Sviluppo' ORDER BY Codice__c];
    }

    @AuraEnabled
    public static Map<String, String[]> getDebitoriPerLinea(String opportunityId) {
        return CtrlWizardOpportunity.getDebitoriPerLinea(opportunityId);
    }

    @AuraEnabled
    public static WGC_Bilancio__c getBilancioCedente(Id opportunityId){
        Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :opportunityId];
        List<WGC_Bilancio__c> bilancio = new List<WGC_Bilancio__c>();
        bilancio = [SELECT KPI_Factoring_Cedente__c, KPI_Factoring_Debitore__c, KPI_Finanziamenti__c FROM WGC_Bilancio__c WHERE Account__c = :opp.AccountId ORDER BY DataFatturato__c DESC LIMIT 1];
        
        if (bilancio.size() > 0)
            return bilancio[0];
        else
            return null;
    }

    @AuraEnabled
    public static WrapperResponse updateDebitori(String payload, String debitoreNewFields) {
        Map<String, String> mapAccPiva = new Map<String, String>();
        WrapperResponse resp = new WrapperResponse();
        System.debug('@@@@@ payload: ' + payload);
        System.debug('@@@@@ debitoreNewFields: ' + debitoreNewFields);
        // System.debug(p);
        try {
            CtrlWizardOpportunity.WoPayload p = (CtrlWizardOpportunity.WoPayload) JSON.deserialize(payload, CtrlWizardOpportunity.WoPayload.class);
            WizardOpportunityController.manageDebitoriFakeIds(p);
            Map<Id, NDGLinea__c> mapDebitori = WizardOpportunityController.generateMapDebitori(p.debitori);
            System.debug('@@@@ mapDebitori: ' + mapDebitori);
            // EXCEPTION REMOVED TO ALLOW UPDATE DEBITORI
            // if (WizardOpportunityController.checkIfDebitoreAlreadyExists(p) == true)
            //     throw new AuraHandledException('Debitore già inserito. Selezionare un differente debitore.');
            // SAVE MAP <IDACCOUNT, PIVA>
            for (CtrlWizardOpportunity.WoDebitore deb : p.debitori) {
                mapAccPiva.put(deb.account, deb.piva);
                deb.piva = deb.account;
                WizardOpportunityController.autoCompletion(deb, mapDebitori.get(deb.account));
                if (debitoreNewFields == null)
                    debitoreNewFields = WizardOpportunityController.autoCompletionContesto(deb.id, mapDebitori.get(deb.account));
            }
            // System.debug(mapAccPiva);
            if (p.valutazionePortafoglio == true)
                CtrlWizardOpportunity.saveValutazionePortafoglio(p);
            CtrlWizardOpportunity.saveDebitoriInternal(p);
            WizardOpportunityController.updateWizardCompletato(payload);
            // TODO: FIX ICAR MANUALI
            resp.data = CtrlWizardOpportunity.editRsf(p.opportunityId);
            
            generateSoggettiCollegati(resp.data);

            if (p.valutazioniPortafoglio.size() > 0) {
                List<Object> existingAttori = new List<Object>();
                if (debitoreNewFields != '' && debitoreNewFields != null)
                    existingAttori = (List<Object>) JSON.deserializeUntyped(debitoreNewFields);
                
                for (CtrlWizardOpportunity.WoDebitore valPort : p.valutazioniPortafoglio) {
                    Map<String, Object> debMap = new Map<String, Object>();
                    debMap.put('debitore', valPort.id);
                    debMap.put('mercato', valPort.mercato);
                    debMap.put('servizio', valPort.servizio);
                    existingAttori.add((Object) debMap);
                }
                debitoreNewFields = JSON.serialize(existingAttori);
            }
            System.debug('@@@@ debitoreNewFields: ' + debitoreNewFields);
            if (debitoreNewFields != '' && debitoreNewFields != null)
                WizardOpportunityController.saveDebitoriInternalNewFields(debitoreNewFields);
            // ITERATE OVER DEBITORI TO RESET PIVA INSTEAD OF ACCOUNTID
            // System.debug(resp.data);
            for (CtrlWizardOpportunity.WoDebitore deb : resp.data.debitori)
                deb.piva = mapAccPiva.get(deb.account);

        } catch (Exception e) {
            resp.success = false;
            resp.msg = e.getMessage();
        }
        // System.debug(resp);
        // System.debug(resp.data);
        return resp;
    }

    public static void generateSoggettiCollegati(CtrlWizardOpportunity.WoPayload payload) {
        String opportunityId = payload.opportunityId;
        Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :opportunityId];
        List<WGC_Soggetti_Collegati__c> soggColl = new List<WGC_Soggetti_Collegati__c>();
        soggColl = [SELECT Id, Anagrafica_Collegata__c FROM WGC_Soggetti_Collegati__c WHERE Anagrafica__c = :opp.AccountId];
        Set<String> soggCollIds = U.getSet(soggColl, 'Anagrafica_Collegata__c');

        for (CtrlWizardOpportunity.WoDebitore deb : payload.debitori) {
            if (!soggCollIds.contains(deb.account))
                CreateAccount.saveSoggettiCollegati(deb.account, opp.AccountId, 'Cliente');
        }

    }

    @AuraEnabled
    public static NDGLinea__c[] getDebitoriNewFields(String opportunityId) {
        return [SELECT Id, WGC_ContropartePrivato__c, Tipologia_Controparte__c, Tipologia_di_Fornitura__c, Commessa__c, Appalto_d_opera__c, FakeId__c, WGC_Mercato__c FROM NDGLinea__c WHERE Opportunita__c = :opportunityId];
    }

    private static void saveDebitoriInternalNewFields(String debitoreNewFields) {
        List<Object> resultMap = (List<Object>) JSON.deserializeUntyped(debitoreNewFields);
        List<NDGLinea__c> attori = new List<NDGLinea__c>();
        for (Object tmpMap : resultMap) {
            Map<String, Object> m = (Map<String, Object>) tmpMap;
            NDGLinea__c ndgl = new NDGLinea__c();
            System.debug('@@@@ json: ' + m);
            ndgl.FakeId__c = (String) m.get('debitore');
            if (m.get('commessa') != null) ndgl.Commessa__c = (Boolean) m.get('commessa');
            if (m.get('appalto') != null) ndgl.Appalto_d_opera__c = (Boolean) m.get('appalto');
            // if (m.get('tipologiaControparte') != null) ndgl.Tipologia_Controparte__c = (String) m.get('tipologiaControparte');
            if (m.get('contropartePrivato') != null) ndgl.WGC_ContropartePrivato__c = (Boolean) m.get('contropartePrivato');
            if (m.get('tipologiaFornitura') != null) ndgl.Tipologia_di_Fornitura__c = (String) m.get('tipologiaFornitura');
            if (m.get('mercato') != null) ndgl.WGC_Mercato__c = (String) m.get('mercato');
            attori.add(ndgl);
        }
        upsert attori FakeId__c;
    }

    private static Map<Id, NDGLinea__c> generateMapDebitori(List<CtrlWizardOpportunity.WoDebitore> debitori) {
        Set<Id> accountIds = new Set<Id>();
        Map<Id, NDGLinea__c> debitoriMap = new Map<Id, NDGLinea__c>();
        Map<Id, Boolean> debitoreNotificaMap = new Map<Id, Boolean>();
        Map<Id, Boolean> debitoreMaturityMap = new Map<Id, Boolean>();

        for (CtrlWizardOpportunity.WoDebitore deb : debitori)
            accountIds.add(deb.account);

        List<NDGLinea__c> attori = [SELECT Id,
                                        Account__c,
                                        ANotifica__c,
                                        Maturity__c,
                                        DurataMediaCredito__c,
                                        DurataNominale__c,
                                        Fatturato__c,
                                        DiCuiProsoluto__c,
                                        Plafond__c,
                                        DivisaNew__c,
                                        Anticipazione__c,
                                        CessioneContinuativa__c,
                                        PerfezionamentoAcquisto__c,
                                        NotificaLIRSingoleCessioni__c,
                                        Rotativita__c,
                                        ProsolutoATD__c,
                                        FakeId__c,
                                        Commessa__c,
                                        Appalto_d_opera__c,
                                        Tipologia_Controparte__c,
                                        WGC_ContropartePrivato__c,
                                        Tipologia_di_Fornitura__c
                                        FROM NDGLinea__c WHERE Account__c IN :accountIds ORDER BY CreatedDate DESC];

        // ITERATE TO INITIALIZE FLAGS' MAP FOR NOTIFICATION AND MATURITY
        // "In presenza di almeno una linea notificata associata a quel debitore, anche in questo caso si popola in automatico la scelta di operare a notifica. Medesima logica anche per maturity"
        for (NDGLinea__c att : attori) {
            if (att.ANotifica__c == true || !debitoreNotificaMap.containsKey(att.Account__c))
                debitoreNotificaMap.put(att.Account__c, att.ANotifica__c);
            if (att.Maturity__c == true || !debitoreMaturityMap.containsKey(att.Account__c))
                debitoreMaturityMap.put(att.Account__c, att.Maturity__c);
        }

        for (NDGLinea__c att : attori)
            if (!debitoriMap.containsKey(att.Account__c)) {
                att.ANotifica__c = debitoreNotificaMap.get(att.Account__c);
                att.Maturity__c = debitoreMaturityMap.get(att.Account__c);
                debitoriMap.put(att.Account__c, att);
            }

        return debitoriMap;
    }

    private static void autoCompletion(CtrlWizardOpportunity.WoDebitore deb, NDGLinea__c debForAutocompletion) {
        if (debForAutocompletion != null) {
            if (deb.aNotifica == null) deb.aNotifica = debForAutocompletion.ANotifica__c;
            if (deb.maturity == null) deb.maturity = debForAutocompletion.Maturity__c;
        }
    }
    @TestVisible
    private static String autoCompletionContesto(String debitoreFakeId, NDGLinea__c debitore) {
        List<Map<String, Object>> debitoriNewFields = new List<Map<String, Object>>();

        if (debitore != null) {
            Map<String, Object> debNewFields = new Map<String, Object>();
            debNewFields.put('debitore', debitoreFakeId);
            debNewFields.put('commessa', debitore.Commessa__c);
            debNewFields.put('appalto', debitore.Appalto_d_opera__c);
            // debNewFields.put('tipologiaControparte', debitore.Tipologia_Controparte__c);
            debNewFields.put('contropartePrivato', debitore.WGC_ContropartePrivato__c);
            debNewFields.put('tipologiaFornitura', debitore.Tipologia_di_Fornitura__c);
            debitoriNewFields.add(debNewFields);
            System.debug('@@@@ debitoriNewFields: ' + debitoriNewFields);
            return JSON.serialize(debitoriNewFields);
        }
        return null;
    }

    private static void manageDebitoriFakeIds(CtrlWizardOpportunity.WoPayload payload) {
        // Set<String> fakeIds = U.getSet([SELECT Id, FakeId__c FROM NDGLinea__c], 'FakeId__c');
        Set<String> fakeIds = new Set<String>();
        System.debug('@@@@ fakeIds: ' + fakeIds);
        if (payload.debitori.size() > 0)
            for (CtrlWizardOpportunity.WoDebitore deb : payload.debitori) {
                System.debug('@@@@ deb: ' + deb);
                System.debug('@@@@ deb.id == null: ' + (deb.id == null));
                if (deb.id == null)
                    deb.id = WizardOpportunityController.generateRandomFakeId(fakeIds);
            }

        if (payload.valutazioniPortafoglio.size() > 0)
            for (CtrlWizardOpportunity.WoDebitore deb : payload.valutazioniPortafoglio) {
                if (deb.id == null)
                    deb.id = WizardOpportunityController.generateRandomFakeId(fakeIds);
            }
    }
    @TestVisible
    private static void manageGaranzieFakeIds(Garanzia__c garanzia) {
        Set<String> fakeIds = new Set<String>();
        // Set<String> fakeIds = U.getSet([SELECT Id, IdEsterno__c FROM Garanzia__c], 'IdEsterno__c');
        System.debug('@@@@ fakeIds: ' + fakeIds);
        garanzia.IdEsterno__c = WizardOpportunityController.generateRandomFakeId(fakeIds);
    }

    private static String generateRandomFakeId(Set<String> fakeIds) { // RECORSIVE FUNCTION TO PREVENT DUPLICATION OF FAKE IDs
        String fakeId = U.generateRandomString(10);
        if (!fakeIds.contains(fakeId))
            return fakeId;
        else
            return generateRandomFakeId(fakeIds);
    }
    // @TestVisible
    // private static Boolean checkIfDebitoreAlreadyExists(CtrlWizardOpportunity.WoPayload payload) {
    //     Map<String, CtrlWizardOpportunity.WoDebitore[]> debitoriMap = new Map<String, CtrlWizardOpportunity.WoDebitore[]>();
    //     Boolean existsSoFar = false;

    //     for (CtrlWizardOpportunity.WoDebitore deb : payload.debitori) {
    //         if (debitoriMap.keySet().contains(deb.account))
    //             debitoriMap.get(deb.account).add(deb);
    //         else
    //             debitoriMap.put(deb.account, new CtrlWizardOpportunity.WoDebitore[]{deb});
            
    //         if (debitoriMap.get(deb.account).size() > 1) {
    //             existsSoFar = true;
    //             break;
    //         }
    //     }

    //     return existsSoFar;
    // }

    @AuraEnabled
    public static Map<String, Object> getQualificaDebitore(String debitore) {
        Map<String, Object> res = new Map<String, Object>();
        List<WGC_Posizione_Debitore__c> qualificaDebitore = new List<WGC_Posizione_Debitore__c>();
        NDGLinea__c deb = new NDGLinea__c();
        List<WGC_Centrale_Rischi__c> cr = new List<WGC_Centrale_Rischi__c>();

        try {
            deb = [SELECT Id, Account__c, Account__r.WGC_DataRichiestaCR__c FROM NDGLinea__c WHERE FakeId__c = :debitore LIMIT 1];
            cr = [SELECT Id, Data_ultima_rilevazione__c FROM WGC_Centrale_Rischi__c WHERE Anagrafica__c = :deb.Account__c ORDER BY Data_ultima_rilevazione__c DESC LIMIT 1];
            qualificaDebitore = [SELECT Tipo_importo__c, Importo__c, Anagrafica__r.WGC_DataRichiestaCR__c
                                FROM WGC_Posizione_Debitore__c
                                WHERE Anagrafica__c = :deb.Account__c AND
                                Aggregato__c = 'Mese_1' AND
                                (Tipo_importo__c='IMP_PLAFOND_UTIL_PROSOLUTO' OR
                                Tipo_importo__c='IMP_PLAFOND_UTIL_PROSOLVENDO' OR
                                Tipo_importo__c='IMP_PLAFOND_PROSOLUTO' OR
                                Tipo_importo__c='IMP_PLAFOND_PROSOLVENDO')
                                ];

            if (qualificaDebitore.size() == 0)
                res.put('error', Label.WGC_Cart_QualificaDebitoreError);
            else {
                for (WGC_Posizione_Debitore__c qd : qualificaDebitore)
                    res.put(qd.Tipo_importo__c, qd.Importo__c);
            }

            res.put('WGC_DataRichiestaCR__c', deb.Account__r.WGC_DataRichiestaCR__c);
            res.put('Data_ultima_rilevazione__c', (cr.size() > 0 ? cr[0].Data_ultima_rilevazione__c : null));

        } catch (Exception e) {
            System.debug('@@@@ TEN - ERRORE QUALIFICA DEBITORE: ' + e.getStackTraceString() + ' --- ' + e.getMessage());
            res.put('error', Label.WGC_Cart_QualificaDebitoreError);
        }

        return res;
    }

    @future (callout=true)
    public static void callInfoCRAsync(String ndg) {
        try {
            WsRestPefMutui.InfoCrInput input = new WsRestPefMutui.InfoCrInput();
            input.ndg = Long.valueOf(ndg);
            WsRestPefMutui.InfoCr(input);
        } catch (Exception e) {
            System.debug('@@@@ TEN - ERROR: ' + e.getStackTraceString() + ' --- ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void richiestaPrimaInfoCR(Id opportunityId, String target){
        // Set<String> ndgSet = new Set<String>();
        Opportunity opp = [SELECT AccountId, Account.NDGGruppo__c, Account.NaturaGiuridica__c, Account.WGC_DataRichiestaCR__c, Account.WGC_Area__c FROM Opportunity WHERE Id = :opportunityId];
        List<WGC_Centrale_Rischi__c> cr = new List<WGC_Centrale_Rischi__c>();
        Account acc = new Account(Id = opp.AccountId);
        cr = [SELECT Id, Data_ultima_rilevazione__c FROM WGC_Centrale_Rischi__c WHERE Anagrafica__c = :opp.AccountId ORDER BY Data_ultima_rilevazione__c DESC LIMIT 1];
        Map<String, Account> ndgAccMap = new Map<String, Account>();
        Map<String, Contact> ndgCntMap = new Map<String, Contact>();
        Map<String, WGC_Centrale_Rischi__c> ndgCRMap = new Map<String, WGC_Centrale_Rischi__c>();
        List<Log__c> logs = new List<Log__c>();
        Integer ggValidCR = Integer.valueOf(Impostazioni__c.getInstance().WGC_Giorni_Validit_CR__c);
        System.debug('@@@@ opportunityId: ' + opportunityId + ' --target: ' + target);
        try {
            switch on target {
                when 'cedente' {
                    // NDGGruppo__c
                    if ((cr.size() > 0 && cr[0] != null && cr[0].Data_ultima_rilevazione__c.daysBetween(Date.today()) < ggValidCR) || opp.Account.WGC_Area__c == 'EE')
                        return;

                    if (opp.Account.NaturaGiuridica__c == 'DI') { // SE DITTA INDIVIDUALE ALLORA PRIMA INFO CR SU TITOLARE EFFETTIVO
                        List<AccountContactRelation> acrs = new List<AccountContactRelation>();
                        acrs = [SELECT Id, ContactId, WGC_Ruolo__c, Contact.NDGGruppo__c, Contact.WGC_DataRichiestaCR__c FROM AccountContactRelation WHERE AccountId = :opp.AccountId AND WGC_Ruolo__c != null AND Contact.NDGGruppo__c != null ORDER BY CreatedDate ASC];

                        if (acrs.size() > 0) { // ALMENO UNA ASSOCIAZIONE ANAGRAFICA-REFERENTE; REFERENTE CON NDG E RUOLO
                            AccountContactRelation acr = acrs[0];
                            Contact cnt = new Contact(Id = acr.ContactId);
                            
                            if (acr.WGC_Ruolo__c.contains('J')) { // SE PRIMO REFERENTE É TITOLARE EFFETTIVO ALLORA CHIAMO PRIMA INFO CR

                                if (acr.Contact.WGC_DataRichiestaCR__c != null && Date.newinstance(acr.Contact.WGC_DataRichiestaCR__c.year(), acr.Contact.WGC_DataRichiestaCR__c.month(), acr.Contact.WGC_DataRichiestaCR__c.day()).daysBetween(Date.today()) < ggValidCR) // SE ULTIMA RICHIESTA PER NDG MINORE DI 2 MESI FA, ALLORA SKIPPO
                                    return;

                                // WsRestPefMutui.InfoCrInput input = new WsRestPefMutui.InfoCrInput();
                                // input.ndg = Long.valueOf(acr.Contact.NDGGruppo__c);
                                // WsRestPefMutui.InfoCr(input);
                                callInfoCRAsync(acr.Contact.NDGGruppo__c);
                                cnt.WGC_DataRichiestaCR__c = Datetime.now();
                                acc.WGC_DataRichiestaCR__c = Datetime.now();

                                update cnt;
								update acc;
                            }
                        }
                    } else {
                        
                        if (opp.Account.WGC_DataRichiestaCR__c != null && Date.newinstance(opp.Account.WGC_DataRichiestaCR__c.year(), opp.Account.WGC_DataRichiestaCR__c.month(), opp.Account.WGC_DataRichiestaCR__c.day()).daysBetween(Date.today()) < ggValidCR) // SE ULTIMA RICHIESTA PER NDG MINORE DI 2 MESI FA, ALLORA SKIPPO
                            return;

                        // WsRestPefMutui.InfoCrInput input = new WsRestPefMutui.InfoCrInput();
                        // input.ndg = Long.valueOf(opp.Account.NDGGruppo__c);
                        // WsRestPefMutui.InfoCr(input);
                        callInfoCRAsync(opp.Account.NDGGruppo__c);
                        acc.WGC_DataRichiestaCR__c = Datetime.now();

                        update acc;
                    }
                }
                when 'debitori' {
                    // expected to be only one
                    List<Account> accToUpdate = new List<Account>();
                    Map<String, SObject> attori = U.keyBy([SELECT NDG__c, Account__c, Account__r.NDGGruppo__c, Account__r.CF__c, Account__r.CodiceIstituto3N__c, Account__r.WGC_DataRichiestaCR__c, Account__r.WGC_Area__c
                                                FROM NDGLinea__c
                                                WHERE Tipo__c = 'Debitore' AND Account__r.NDGGruppo__c != NULL AND Opportunita__c =: opportunityId], 'NDG__c');
                    // List<NDGLinea__c> attori = [SELECT NDG__c, Account__c, Account__r.NDGGruppo__c, Account__r.CF__c, Account__r.CodiceIstituto3N__c, Account__r.WGC_DataRichiestaCR__c, Account__r.WGC_Area__c
                    //                             FROM NDGLinea__c
                    //                             WHERE Tipo__c = 'Debitore' AND Account__r.NDGGruppo__c != NULL AND Opportunita__c =: opportunityId];

                    // for (NDGLinea__c att : attori)
                    //     ndgAccMap.put(att.NDG__c, new Account(Id=att.Account__c, WGC_DataRichiestaCR__c=att.Account__r.WGC_DataRichiestaCR__c, WGC_Area__c=att.Account__r.WGC_Area__c));

                    List<WGC_Centrale_Rischi__c> crDebitori = new List<WGC_Centrale_Rischi__c>();
                    crDebitori = [SELECT Id, Data_ultima_rilevazione__c, Anagrafica__r.NDGGruppo__c FROM WGC_Centrale_Rischi__c WHERE Anagrafica__r.NDGGruppo__c IN :attori.keySet() ORDER BY Data_ultima_rilevazione__c DESC];

                    for (WGC_Centrale_Rischi__c crTMP : crDebitori)
                        if (ndgCRMap.get(crTMP.Anagrafica__r.NDGGruppo__c) == null)
                            ndgCRMap.put(crTMP.Anagrafica__r.NDGGruppo__c, crTMP);

                    for (String ndg : attori.keySet()) {
                        if (ndgCRMap.get(ndg) != null && ndgCRMap.get(ndg).Data_ultima_rilevazione__c.daysBetween(Date.today()) < ggValidCR)
                            return;
                        
                        if (((NDGLinea__c)attori.get(ndg)).Account__r.WGC_Area__c == 'EE' || (((NDGLinea__c)attori.get(ndg)).Account__r.WGC_DataRichiestaCR__c != null && Date.newinstance(((NDGLinea__c)attori.get(ndg)).Account__r.WGC_DataRichiestaCR__c.year(), ((NDGLinea__c)attori.get(ndg)).Account__r.WGC_DataRichiestaCR__c.month(), ((NDGLinea__c)attori.get(ndg)).Account__r.WGC_DataRichiestaCR__c.day()).daysBetween(Date.today()) < ggValidCR)) // SE ULTIMA RICHIESTA PER NDG MINORE DI 2 MESI FA, ALLORA SKIPPO
                            continue;

                        // WsRestPefMutui.InfoCrInput input = new WsRestPefMutui.InfoCrInput();
                        // input.ndg = Long.valueOf(ndg);
                        // WsRestPefMutui.InfoCr(input);
                        callInfoCRAsync(ndg);
                        accToUpdate.add(new Account(Id=((NDGLinea__c)attori.get(ndg)).Account__c, WGC_DataRichiestaCR__c=Datetime.now()));
                        // ndgAccMap.get(ndg).WGC_DataRichiestaCR__c = Datetime.now();
                    }

                    update accToUpdate;
                }
                when 'garanti' {
                    Set<String> ndgEsteri = new Set<String>();
                    List<NDGLinea__c> attori = [SELECT NDG__c, Account__c, Contact__c, Account__r.WGC_DataRichiestaCR__c, Contact__r.WGC_DataRichiestaCR__c, Contact__r.MailingState__c, Account__r.WGC_Area__c
                                                FROM NDGLinea__c
                                                WHERE Tipo__c = 'Garante' AND NDG__c != NULL AND Opportunita__c =: opportunityId];

                    for (NDGLinea__c att : attori)
                        if (att.Account__c != null) {
                            ndgAccMap.put(att.NDG__c, new Account(Id=att.Account__c, WGC_DataRichiestaCR__c=att.Account__r.WGC_DataRichiestaCR__c));
                            if (att.Account__r.WGC_Area__c == 'EE')
                                ndgEsteri.add(att.NDG__c);
                        }

                    for (NDGLinea__c att : attori)
                        if (att.Contact__c != null) {
                            ndgCntMap.put(att.NDG__c, new Contact(Id=att.Contact__c, WGC_DataRichiestaCR__c=att.Contact__r.WGC_DataRichiestaCR__c));
                            if (att.Contact__r.MailingState__c == 'EE')
                                ndgEsteri.add(att.NDG__c);
                        }

                    for (String ndg : ndgAccMap.keySet()) {
                        // WsRestPefMutui.InfoCrInput input = new WsRestPefMutui.InfoCrInput();

                        if (ndgAccMap.keySet().contains(ndg) == true && ndgAccMap.get(ndg).WGC_DataRichiestaCR__c != null && Date.newinstance(ndgAccMap.get(ndg).WGC_DataRichiestaCR__c.year(), ndgAccMap.get(ndg).WGC_DataRichiestaCR__c.month(), ndgAccMap.get(ndg).WGC_DataRichiestaCR__c.day()).daysBetween(Date.today()) < ggValidCR) // SE ULTIMA RICHIESTA PER NDG MINORE DI 2 MESI FA, ALLORA SKIPPO
                            continue;
                        else if (ndgCntMap.keySet().contains(ndg) == true && ndgCntMap.get(ndg).WGC_DataRichiestaCR__c != null && Date.newinstance(ndgCntMap.get(ndg).WGC_DataRichiestaCR__c.year(), ndgCntMap.get(ndg).WGC_DataRichiestaCR__c.month(), ndgCntMap.get(ndg).WGC_DataRichiestaCR__c.day()).daysBetween(Date.today()) < ggValidCR) // SE ULTIMA RICHIESTA PER NDG MINORE DI 2 MESI FA, ALLORA SKIPPO
                            continue;

                        if (ndgEsteri.contains(ndg) == true) // SE NDG ESTERO, ALLORA SKIPPO
                            continue;

                        // input.ndg = Long.valueOf(ndg);
                        // WsRestPefMutui.InfoCr(input);
                        callInfoCRAsync(ndg);
                        
                        if (ndgAccMap.keySet().contains(ndg) == true)
                            ndgAccMap.get(ndg).WGC_DataRichiestaCR__c = Datetime.now();
                        else if (ndgCntMap.keySet().contains(ndg) == true)
                            ndgCntMap.get(ndg).WGC_DataRichiestaCR__c = Datetime.now();
                    }

                    update ndgAccMap.values();
                    update ndgCntMap.values();
                }
            }
        } catch (Exception e) {
            System.debug('@@@@ TEN - ERROR: ' + e.getStackTraceString() + ' --- ' + e.getMessage());
        }
    }

    // @AuraEnabled
    // public static Boolean checkIsValidCR(Id opportunityId){
    //     Opportunity opp = [SELECT Id, AccountId FROM Opportunity WHERE Id = :opportunityId];
    //     List<WGC_Centrale_Rischi__c> cr = new List<WGC_Centrale_Rischi__c>();
    //     cr = [SELECT Id, Data_ultima_rilevazione__c FROM WGC_Centrale_Rischi__c WHERE Anagrafica__c = :opp.AccountId ORDER BY Data_ultima_rilevazione__c DESC LIMIT 1];
    //     Integer ggValidCR = Integer.valueOf(Impostazioni__c.getInstance().WGC_Giorni_Validit_CR__c);
        
    //     return (cr.size() > 0 && cr[0] != null && cr[0].Data_ultima_rilevazione__c.daysBetween(Date.today()) < ggValidCR);
    // }

    // @AuraEnabled
    public static String getCRData(Id opportunityId){
        Map<String, Object> resultMap = new Map<String, Object>();
        Opportunity opp = [SELECT Id, AccountId, IsOppNSA__c, WGC_Presa_Visione_CR__c, WGC_NoteCR__c FROM Opportunity WHERE Id = :opportunityId];
        Account acc = [SELECT Id, WGC_Alert_KPI_Centrale_Rischi__c, WGC_Area__c, WGC_Flag_non_affidato__c, WGC_Data_Caricamento_BKIT__c, WGC_DataRichiestaCR__c,
                                    Name, Sconfini_a_revoca_Utilizzato_Accordato__c, Sconfini_a_revoca__c, 
                                    Sconfini_a_scadenza_Utilizzato_Accordato__c, Sconfini_a_scadenza__c, Impagato_50_Utilizzato_Autoliquidante__c,
                                    Sofferenze__c FROM Account WHERE Id = :opp.AccountId];
        List<WGC_Centrale_Rischi__c> cr = new List<WGC_Centrale_Rischi__c>();
        cr = [SELECT Id, Data_ultima_rilevazione__c FROM WGC_Centrale_Rischi__c WHERE Anagrafica__c = :opp.AccountId ORDER BY Data_ultima_rilevazione__c DESC LIMIT 1];
        Map<String, SObject> debitori = U.keyBy([SELECT Account__c, Nome__c, Account__r.WGC_DataRichiestaCR__c FROM NDGLinea__c WHERE Tipo__c = 'Debitore' AND Opportunita__c = :opportunityId], 'Account__c');
        Map<String, SObject> debitoriCRs = U.keyBy([SELECT Anagrafica__c, Data_ultima_rilevazione__c FROM WGC_Centrale_Rischi__c WHERE Anagrafica__c IN :debitori.keySet()], 'Anagrafica__c');
        List<Map<String, Object>> debsData = new List<Map<String, Object>>();
        Integer ggValidCR = Integer.valueOf(Impostazioni__c.getInstance().WGC_Giorni_Validit_CR__c);

        for (String accId : debitori.keySet()) {
            Map<String, Object> ddMap = new Map<String, Object>();
            ddMap.put('debitore', (((NDGLinea__c)debitori.get(accId)) != null ? ((NDGLinea__c)debitori.get(accId)).Nome__c : null));
            ddMap.put('dataUltimaRilevazione', (((WGC_Centrale_Rischi__c)debitoriCRs.get(accId)) != null ? ((WGC_Centrale_Rischi__c)debitoriCRs.get(accId)).Data_ultima_rilevazione__c : null));
            ddMap.put('dataRichiesta', (((NDGLinea__c)debitori.get(accId)) != null ? ((NDGLinea__c)debitori.get(accId)).Account__r.WGC_DataRichiestaCR__c : null));
            debsData.add(ddMap);
        }

        resultMap.put('hasCRData', cr.size() > 0);
        resultMap.put('lastCRDate', (cr.size() > 0 && cr[0] != null ? cr[0].Data_ultima_rilevazione__c : null));
        resultMap.put('isValidCR', (cr.size() > 0 && cr[0] != null && cr[0].Data_ultima_rilevazione__c.daysBetween(Date.today()) < ggValidCR));
        resultMap.put('debsData', debsData);
        resultMap.put('opportunity', opp);
        resultMap.put('account', acc);
        
        return JSON.serialize(resultMap);
    }

    @AuraEnabled
    public static void updateWizardCompletato(String payload){
        User u = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        Map<String, Object> p = (Map<String, Object>) JSON.deserializeUntyped(payload);
        
        if (p.get('wizardCompletato') != null)
            if (u.Profile.Name == FAST_FINANCE_BO_PROFILE_NAME) {
                updateField('WGC_WizardCompletatoBO__c', (Boolean) p.get('wizardCompletato'), (String) p.get('opportunityId'));
                CtrlWizardOpportunity.setWizardCompletato((String) p.get('opportunityId'), (Boolean) p.get('wizardCompletato'));
            }
            else
                CtrlWizardOpportunity.setWizardCompletato((String) p.get('opportunityId'), (Boolean) p.get('wizardCompletato'));
    }

    @AuraEnabled
    public static Boolean updatePresaVisione(Id opportunityId, String field){
        Opportunity opp = new Opportunity();

        try {
            opp.Id = opportunityId;
            opp.put(field, true);
            
            update opp;

            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static List<JoinLineaDebitore__c> getCodiciCoppia(Id opportunityId){
        return [SELECT Id, WGC_Codice_Random_Coppia__c, Linea__c, Linea__r.Prodotto__r.WGC_Famiglia__c, Debitore__r.FakeId__c, WGC_Cod_Tipo_Car__c FROM JoinLineaDebitore__c WHERE Linea__r.Opportunity__c = :opportunityId AND WGC_Codice_Random_Coppia__c != null];
    }

    public static void updateNoteAutomatiche(String payload) {
        CtrlWizardOpportunity.WoPayload p = (CtrlWizardOpportunity.WoPayload) JSON.deserialize(payload, CtrlWizardOpportunity.WoPayload.class);
        String notaAutomatica = '';
        Boolean hasCPI = false;
        Boolean hasBEI = false;

        //SM - TEN: Salvo le note automatiche per estero
        updateNoteAutomaticheEstero(p);
        //A.M. -> Inizio
        //List<Linea__c> controgarantitoMCC = new List<Linea__c>([SELECT Id FROM Linea__c WHERE Opportunity__c =: p.opportunityId AND Prodotto__r.CodiceUnivoco__c =: COD_MUTUO_CONTROGARANTITO ]);
        List<Linea__c> garantitoMCC = new List<Linea__c>([SELECT Id, Prodotto__r.CodiceUnivoco__c 
															FROM Linea__c 
														   WHERE Opportunity__c =: p.opportunityId 
														     AND (Prodotto__r.CodiceUnivoco__c =: COD_MUTUO_CONTROGARANTITO 
															   OR Prodotto__r.CodiceUnivoco__c =: COD_MUTUO_DECRETOLIQUIDITA 
															   OR Prodotto__r.CodiceUnivoco__c =: COD_MUTUO_DECRETO13E 
															   OR Prodotto__r.CodiceUnivoco__c =: COD_MUTUO_FUNDING_CDP)]);
        //A.M. -> Fine

        //Crediti
        List<Credito__c> crediti = new List<Credito__c>([SELECT Id, Name, WGC_Ade_Territoriale__r.Name, WGC_Esenzione_Garanzia__c, ValoreNominale__c,
                                                                    WGC_Data_DSO__c, WGC_Data_Richiesta_Rimborso__c, WGC_Commissione_Acquisto__c, WGC_Offerta_perc__c,
                                                                    WGC_IRR_Perc__c, WGC_Ruoli_Compens__c, WGC_Val_Nom_Esigibile__c
                                                                FROM Credito__c WHERE Opportunita__c =: p.opportunityId AND WGC_Invia_Credito__c = true ]);

        List<NDGLinea__c> agenzia = new List<NDGLinea__c>([SELECT Id, name, ANotifica__c, WGC_Storicita_Rimborsi__c FROM NDGLinea__c WHERE Account__c =: WGC_PC_CartController.idAdE AND Opportunita__c =: p.opportunityId LIMIT 1 ]);


        //SM - TEN: Banca Coporate - Aggiunto campo WGC_Comm_Disponibilit_Fondi_CDF_Trim__c
        Opportunity opp = [SELECT WGC_Comm_Disponibilit_Fondi_CDF_Trim__c FROM Opportunity WHERE Id =: p.opportunityId];
        Map<Id,Linea__c> lineeBC = new Map<Id, Linea__c>([SELECT Id, WGC_Tipologia__c, Prodotto__r.Name, Prodotto__r.CodiceUnivoco__c, WGC_Utilizzo_CC_IFIS_Impresa__c, WGC_Seleziona_CC_IFIS_Impresa_esistente__c FROM Linea__c WHERE Opportunity__c =: p.opportunityId AND ( ( RecordType.DeveloperName = 'Corporate' AND ( Prodotto__r.CodiceUnivoco__c != 'ContoAnticipiPTF' AND Prodotto__r.CodiceUnivoco__c != 'FIDOSBF' AND Prodotto__r.CodiceUnivoco__c != 'FidoAnticipoFatture' ) ) OR Prodotto__r.CodiceUnivoco__c LIKE '%IfisImpresa%') ]);
        List<PConfigurato__c> pconfs = new List<PConfigurato__c>([SELECT Id, Codice__c, Valore__c, Linea__c, Linea__r.Prodotto__r.Name FROM PConfigurato__c WHERE Linea__r.Opportunity__c =: p.opportunityId AND Linea__c IN: lineeBC.keySet()/*AND Linea__r.RecordType.DeveloperName = 'Corporate'*/ ]);
        Map<String, List<SObject>> lineXPconfs = U.groupBy(pconfs, 'Linea__r.Prodotto__r.Name');

        Map<Id,Linea__c> lineeBCENote = new Map<Id,Linea__c>([SELECT Id, Prodotto__c, Prodotto__r.Name, Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Opportunity__c =: p.opportunityId AND RecordType.DeveloperName = 'WGC_Corporate_Estero' AND ( Prodotto__r.CodiceUnivoco__c = 'AnticipoExport' OR Prodotto__r.CodiceUnivoco__c = 'FinanziamentoImport' OR Prodotto__r.CodiceUnivoco__c = 'FinanziamentoExport' )]);

        //SM - TEN: CR 212 Gestione pre-ammortamento
        List<Linea__c> lineePreAmmortamento = new List<Linea__c>([SELECT Id, Prodotto__r.Name, WGC_Pre_ammortamento__c, WGC_Durata_pre_ammortamento__c, WGC_Durata_ammortamento__c FROM Linea__c WHERE Opportunity__c =: p.opportunityId AND WGC_Pre_ammortamento__c = true ]);

        if(!lineePreAmmortamento.isEmpty()){
            for(Linea__c l : lineePreAmmortamento){
                notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + l.Prodotto__r.Name + ': ';
                notaAutomatica += (notaAutomatica == '' ? '' : '\n') + 'Pre-ammortamento: Si, ';
                notaAutomatica += 'Durata Pre-ammortamento: ' + l.WGC_Durata_pre_ammortamento__c + ', ';
                notaAutomatica += 'Durata Ammortamento: ' + l.WGC_Durata_ammortamento__c;
            }
        }

        for (CtrlWizardOpportunity.WoProdotto l : p.pb) {
            if (l.polizzaCPI == true && hasCPI == false) {
                hasCPI = true;
                notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + Label.WGC_Cart_PolizzaCPI_NotaAutomatica.replace('LL_NUMASS', String.valueOf(l.numeroAssicurati)).replace('LL_PERCASS', String.valueOf(l.percAssicurazioneSingoli));
            }
            if (l.fundingBEI == true && hasBEI == false) {
                notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + Label.WGC_Cart_FundingBEI_NotaAutomatica;
            }
        }

        //A.M. -> Inizio
        if (!garantitoMCC.isEmpty()){
            for(Linea__C ProdMutuo : garantitoMCC){
                if (ProdMutuo.Prodotto__r.CodiceUnivoco__c == COD_MUTUO_DECRETOLIQUIDITA || ProdMutuo.Prodotto__r.CodiceUnivoco__c == COD_MUTUO_DECRETO13E) {    
                    notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + Label.WGC_Cart_DecretoLiquiditaMCC;
                    //System.debug('###A.M. Muto: ' + ProdMutuo.Prodotto__r.CodiceUnivoco__c);
                }
   
               if(ProdMutuo.Prodotto__r.CodiceUnivoco__c == COD_MUTUO_CONTROGARANTITO){
                   notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + Label.WGC_Cart_MutuoControgarantitoMCC;
               }

			   if(ProdMutuo.Prodotto__r.CodiceUnivoco__c == COD_MUTUO_FUNDING_CDP){
                   notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + Label.WGC_Cart_MutuoFundingCDP;
               }
            }
         }   
        //if(!controgarantitoMCC.isEmpty()){
        //   notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + Label.WGC_Cart_MutuoControgarantitoMCC;
        //}    
        //A.M. -> Fine   

        //SM - TEN: Crediti Erariali - Compilazione Crediti
        if(!crediti.isEmpty() && !agenzia.isEmpty())
            notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + WGC_PC_CartController.creaNotaBonis(crediti, agenzia[0]);

        //SM - TEN: Banca Corporate - Note automatiche
        Boolean checkCommissione = false;
        Set<String> prodsBCExclude = new Set<String>();

        for(Linea__c l : lineeBC.values()){
            prodsBCExclude.add(l.Prodotto__r.CodiceUnivoco__c);
        }

        //SM - TEN: Aggiungo la commissione nelle note solo se è presente un prodotto di sbf o anticipo fatture
        if((prodsBCExclude.contains('IfisImpresa') || prodsBCExclude.contains('IfisImpresaNonAffidato') || prodsBCExclude.contains('GestionePTF')) && 
            !( prodsBCExclude.contains('SBF') || prodsBCExclude.contains('AnticipoFatture') ) ){
                checkCommissione = true;
            }

        //SM - TEN: Aggiungo i prodotti di Corporate Estero
        if(opp.WGC_Comm_Disponibilit_Fondi_CDF_Trim__c != null && !lineeBC.values().isEmpty() && !checkCommissione){
            notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + 'Commissione Disponibilità Fondi (CDF): ' + opp.WGC_Comm_Disponibilit_Fondi_CDF_Trim__c + '%';
        }

        //SM - TEN: Aggiungo i prodotti di Corporate Estero
        if(opp.WGC_Comm_Disponibilit_Fondi_CDF_Trim__c != null && !lineeBCENote.values().isEmpty() && !notaAutomatica.contains('Commissione Disponibilità Fondi (CDF):')){
            notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + 'Commissione Disponibilità Fondi (CDF): ' + opp.WGC_Comm_Disponibilit_Fondi_CDF_Trim__c + '%';
        }

        // Boolean checkSpread = false;
        String sbfId = '';
        String numeroContoSBF;
        String numeroContoAnticipoFatture;
        String numeroContoGestionePTF;
        String tipologiaConto;
        // String antFattId = '';
        for(Linea__c l : lineeBC.values()){
            if(l.Prodotto__r.CodiceUnivoco__c == 'SBF' /*&& l.WGC_Tipologia__c == 'Conto Unico' && l.WGC_Utilizzo_CC_IFIS_Impresa__c == 'Esistente'*/){
                // checkSpread = true;
                if(l.WGC_Tipologia__c == 'Conto Unico')
                    sbfId = l.Id;

                if(l.WGC_Utilizzo_CC_IFIS_Impresa__c == 'Esistente')
                    numeroContoSBF = l.WGC_Seleziona_CC_IFIS_Impresa_esistente__c;
                // break;

                tipologiaConto = l.WGC_Tipologia__c;
            }

            if(l.Prodotto__r.CodiceUnivoco__c == 'AnticipoFatture' && l.WGC_Utilizzo_CC_IFIS_Impresa__c == 'Esistente'){
                numeroContoAnticipoFatture = l.WGC_Seleziona_CC_IFIS_Impresa_esistente__c;
            }

            if(l.Prodotto__r.CodiceUnivoco__c == 'GestionePTF' && l.WGC_Utilizzo_CC_IFIS_Impresa__c == 'Esistente'){
                numeroContoGestionePTF = l.WGC_Seleziona_CC_IFIS_Impresa_esistente__c;
            }
        }

        for(String s : lineXPconfs.keySet()){
            //Indico il nome del prodotto associato alla linea, per dare l'indicazione dell'associazione dei parametri alla linea
            //Non includo il c/c poichè non ci serve ai fini delle note automatiche
            if(!s.contains('C/C')){
                
                notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + s + ': ' + (s == 'SBF a disponibilità immediata' ? tipologiaConto : '') + '\n\r'; /*String.valueOf(lineXPconfs.get(s)[0].get('Linea__r.Prodotto__r.Name'));*/

                //Numero Conto Anticipo Fatture
                if(s == 'Anticipo Fatture' && numeroContoAnticipoFatture != null){
                    notaAutomatica += 'Legato al C/C: ' + numeroContoAnticipoFatture + ', ';
                }

                //Numero Conto Gestione PTF Dopo Incasso
                if(s == 'Gestione PTF dopo incasso' && numeroContoGestionePTF != null){
                    notaAutomatica += 'Legato al C/C: ' + numeroContoGestionePTF + ', ';
                }

                //Numero Conto SBF
                if(s == 'SBF a disponibilità immediata' && numeroContoSBF != null)
                    notaAutomatica += 'Legato al C/C: ' + numeroContoSBF + ', ';

                for(SObject pc : lineXPConfs.get(s)){

                    if(String.valueOf(pc.get('Codice__c')) == 'CDA02_1053' && String.isNotBlank(sbfId) && s == 'SBF a disponibilità immediata' && pc.get('Valore__c') != null ){
                        notaAutomatica += 'Spread SBF Portafoglio: ' + String.valueOf(pc.get('Valore__c')) + '% , '; /*'% legato al C/C: ' + numeroContoSBF + ', ';*/
                    }

                    if(String.valueOf(pc.get('Codice__c')) == 'SF51' && pc.get('Valore__c') != null){
                        notaAutomatica += 'Cessione: ' + ( String.valueOf(pc.get('Valore__c')).toLowerCase() == 'true' ? 'Si' : 'No' ) + ', '; 
                    }

                    if(String.valueOf(pc.get('Codice__c')) == 'SF52' && pc.get('Valore__c') != null){
                        notaAutomatica += 'A notifica: ' + ( String.valueOf(pc.get('Valore__c')).toLowerCase() == 'true' ? 'Si' : 'No' ) + ', ';
                    }

                    if(String.valueOf(pc.get('Codice__c')) == 'SF57' && pc.get('Valore__c') != null){
                        notaAutomatica += 'Richiesta servizio SEDA (banca allineamento): ' + ( String.valueOf(pc.get('Valore__c')).toLowerCase() == 'true' ? 'Si' : 'No' ) + ', ';
                    }

                    if(String.valueOf(pc.get('Codice__c')) == 'SF56' && pc.get('Valore__c') != null){
                        notaAutomatica += 'Richiesta nuovo creditor ID: ' + ( String.valueOf(pc.get('Valore__c')).toLowerCase() == 'true' ? 'Si' : 'No' ) + ', ';
                    }

                    if(String.valueOf(pc.get('Codice__c')) == 'SF62' && pc.get('Valore__c') != null){
                        notaAutomatica += 'Creditor ID esistente: ' + String.valueOf(pc.get('Valore__c')) + ', '; 
                    }

                    if(String.valueOf(pc.get('Codice__c')) == 'SF61' && pc.get('Valore__c') != null){
                        notaAutomatica += 'Codice SIA: ' + String.valueOf(pc.get('Valore__c')) + ', ';
                    }

                    if(String.valueOf(pc.get('Codice__c')) == 'SF60' && pc.get('Valore__c') != null){
                        notaAutomatica += 'Codice CUC: ' + String.valueOf(pc.get('Valore__c')) + ', ';
                    }

                    if(String.valueOf(pc.get('Codice__c')) == 'SF64' && pc.get('Valore__c') != null){
                        notaAutomatica += 'Riconoscimento/Anticipazione: ' + (String.valueOf(pc.get('Valore__c')) == 'true' ? 'Si' : 'No') + ', ';
                    }
                }
            }
        }

        //SM - TEN: Banca Corporate END
        //if (notaAutomatica != '')
            updateField('WGC_Note_automatiche__c', notaAutomatica, p.opportunityId);
    }

    @AuraEnabled
    public static void updateNoteAutomaticheEstero(CtrlWizardOpportunity.WoPayload p){

        String notaAutomatica = '';

        Map<Id,Linea__c> lineeBCE = new Map<Id,Linea__c>([SELECT Id, Prodotto__c, Prodotto__r.Name, Prodotto__r.CodiceUnivoco__c, Importo__c, DivisaNew__c, Durata__c,  WGC_Tipologia_Estero__c, WGC_Affidamento__c, WGC_Seleziona_CC_IFIS_Impresa_esistente__c, WGC_Tipo_di_garanzia__c  FROM Linea__c WHERE Opportunity__c =: p.opportunityId AND RecordType.DeveloperName = 'WGC_Corporate_Estero']);
        Map<String,SObject> lineeBCEMap = (Map<String,SObject>) U.keyBy(lineeBCE.values(), 'Prodotto__r.Name');
        Set<String> prodIds = U.getSet(lineeBCE.values(), 'Prodotto__c');
        List<PConfigurato__c> pconfsBCE = new List<PConfigurato__c>([SELECT Id, Codice__c, Valore__c, Linea__r.Prodotto__r.Name FROM PConfigurato__c WHERE Linea__c IN: lineeBCE.keySet()]);
        Map<String,SObject> ppBCE = U.keyBy([SELECT Id, Name, Label__c, Prodotto__r.Name, Parametro__r.CodiceUnivoco__c FROM ParametroProdotto__c WHERE Prodotto__c IN: prodIds],'Parametro__r.CodiceUnivoco__c');
        Map<String, List<SObject>> lineXPconfsBCE = U.groupBy(pconfsBCE, 'Linea__r.Prodotto__r.Name');

        List<String> options = getPicklistValues('NDGLinea__c', 'DivisaNew__c', false);

        if(lineeBCEMap.keySet().contains('Anticipo Export') ||
            lineeBCEMap.keySet().contains('Finanziamento Export') || 
            lineeBCEMap.keySet().contains('Finanziamento Import') ){
            Opportunity opp = [SELECT Id, Name, WGC_Comm_Disponibilit_Fondi_CDF_Trim__c FROM Opportunity WHERE Id =: p.opportunityId];
            notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + 'Commissione Disponibilità Fondi (CDF): ' + opp.WGC_Comm_Disponibilit_Fondi_CDF_Trim__c + '%';
        }

        for(String s : lineeBCEMap.keySet()){
            //Scrivo i parametri della linea poichè essi non vengono mandati a NV ma tramite mail
            //Serve per recuperare la label del campo divisa
            String divisaCod = String.valueOf(lineeBCEMap.get(s).get('DivisaNew__c'));
            String divisaLabel = '';
            for(String o : options){
                if(o.contains(divisaCod))
                    divisaLabel = o.split(':')[1];
            }

            if(s == 'Documentate all\'incasso' || s == 'Credito Documentario Export'){

                notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + s + '\n';

                if(s == 'Documentate all\'incasso'){
                    notaAutomatica += 'Divisa: ' + divisaLabel + ', ';
                    notaAutomatica += 'Importo: ' + Decimal.valueOf(String.valueOf(lineeBCEMap.get(s).get('Importo__c'))) + ', ';
                    notaAutomatica += 'Durata (gg): ' + String.valueOf(lineeBCEMap.get(s).get('Durata__c')) + ', ';
                    notaAutomatica += 'Tipologia: ' + String.valueOf(lineeBCEMap.get(s).get('WGC_Tipologia_Estero__c')) + ', ';
                    if(String.valueOf(lineeBCEMap.get(s).get('WGC_Tipologia_Estero__c')) == 'Import') notaAutomatica += 'Affidamento: ' + (String.valueOf(lineeBCEMap.get(s).get('WGC_Affidamento__c')) == 'true'  ? 'Si' : 'No') + ', ';
                    notaAutomatica += (String.valueOf(lineeBCEMap.get(s).get('WGC_Seleziona_CC_IFIS_Impresa_esistente__c')) != null ? 'Legato al C/C: ' + String.valueOf(lineeBCEMap.get(s).get('WGC_Seleziona_CC_IFIS_Impresa_esistente__c')) + ', ' : '');
                }
                if(s == 'Credito Documentario Export'){
                    notaAutomatica += 'Divisa: ' + divisaLabel + ', ';
                    notaAutomatica += 'Importo: ' + Decimal.valueOf(String.valueOf(lineeBCEMap.get(s).get('Importo__c'))) + ', ';
                    notaAutomatica += 'Durata (gg): ' + String.valueOf(lineeBCEMap.get(s).get('Durata__c')) + ', ';
                    notaAutomatica += (String.valueOf(lineeBCEMap.get(s).get('WGC_Seleziona_CC_IFIS_Impresa_esistente__c')) != null ? 'Legato al C/C: ' + String.valueOf(lineeBCEMap.get(s).get('WGC_Seleziona_CC_IFIS_Impresa_esistente__c')) + ', ' : '');
                }
            }

            //Escludo alcuni prodotti poichè compilo dopo le note automatiche estero
            if(s != 'Documentate all\'incasso' && s != 'Credito Documentario Export' && s != 'Finanziamento Export' && 
                s != 'Garanzia Internazionale LT' && s != 'Garanzia Internazionale BT' && s != 'Finanziamento Import' && 
                s != 'Anticipo Export'){

                notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + s + '\n';
                notaAutomatica += 'Divisa: ' + divisaLabel + ', ';
                notaAutomatica += 'Importo: ' + Decimal.valueOf(String.valueOf(lineeBCEMap.get(s).get('Importo__c'))) + ', ';
                notaAutomatica += 'Durata (gg): ' + String.valueOf(lineeBCEMap.get(s).get('Durata__c')) + ', ';
                notaAutomatica += (String.valueOf(lineeBCEMap.get(s).get('WGC_Seleziona_CC_IFIS_Impresa_esistente__c')) != null ? 'Legato al C/C: ' + String.valueOf(lineeBCEMap.get(s).get('WGC_Seleziona_CC_IFIS_Impresa_esistente__c')) + ', ' : '');
            }
        }

        for(String s : lineXPconfsBCE.keySet()){
            notaAutomatica += (notaAutomatica == '' ? '' : '\n\r') + s + '\n';

            String divisaCod = String.valueOf(lineeBCEMap.get(s).get('DivisaNew__c'));
            String divisaLabel = '';
            for(String o : options){
                if(o.contains(divisaCod))
                    divisaLabel = o.split(':')[1];
            }

            if(s != 'Documentate all\'incasso' && s != 'Credito Documentario Export' && s != 'Stand By Letter' && 
                s != 'Credito Documentario Import'){
                notaAutomatica += 'Divisa: ' + divisaLabel + ', ';
                notaAutomatica += 'Importo: ' + Decimal.valueOf(String.valueOf(lineeBCEMap.get(s).get('Importo__c'))) + ', ';
                notaAutomatica += 'Durata (gg): ' + String.valueOf(lineeBCEMap.get(s).get('Durata__c')) + ', ';
                if(s.contains('Garanzia Internazionale')) notaAutomatica += 'Tipo di garanzia: ' + String.valueOf(lineeBCEMap.get(s).get('WGC_Tipo_di_garanzia__c')) + ', ';
                notaAutomatica += (String.valueOf(lineeBCEMap.get(s).get('WGC_Seleziona_CC_IFIS_Impresa_esistente__c')) != null ? 'Legato al C/C: ' + String.valueOf(lineeBCEMap.get(s).get('WGC_Seleziona_CC_IFIS_Impresa_esistente__c')) + ', ' : '');
            }

            for(SObject pconf : lineXPconfsBCE.get(s)){
                if(pconf.get('Valore__c') != null && ppBCE.get(String.valueOf(pconf.get('Codice__c'))) != null){
                    String valore = String.valueOf(pconf.get('Valore__c')).toLowerCase();
                    String valoreFormattato = valore == 'false' ? 'No' : valore == 'true' ? 'Si' : valore;
                    notaAutomatica += String.valueOf(ppBCE.get(String.valueOf(pconf.get('Codice__c'))).get('Label__c'))+': ' + valoreFormattato + ', ';// pconf.get('')
                }
            }
        }
        updateField('WGC_Note_Automatiche_Estero__c', notaAutomatica, p.opportunityId);
    }

    @AuraEnabled
    public static void changeOwner(String opportunityId, sObject owner) {
        updateNote('OwnerId', owner.Id, opportunityId);
		//A.M. SDHDFNZ-118722
		User own = [SELECT Id, Manager.Email FROM User WHERE id = :owner.Id];
		updateNote('WGC_Email_Referente_Factoring_Anagrafica__c', own.Manager.Email, opportunityId);
    }

    /* METODI DI GESTIONE CHECK LINEE ESISTENTI */

    @AuraEnabled
    public static Object checkLinesConsistency(String famigliaProdotto, String optyId, String debitore, String uid, String resolveAction) {
        //CtrlWizardOpportunity.WoPayload p = (CtrlWizardOpportunity.WoPayload) JSON.deserialize(payload, CtrlWizardOpportunity.WoPayload.class);
        //Set<String> revisionedProds = U.getSet([SELECT Id, WGC_Numero_Linea_Credito__c FROM Linea__c WHERE Opportunity__c = :p.opportunityId AND WGC_Numero_Linea_Credito__c != null], 'WGC_Numero_Linea_Credito__c');
        
        return getProductsFromConfiguration(famigliaProdotto, optyId, debitore);
    }

    public static Map<String, List<Linea__c>> getProductsFromConfiguration(String famigliaProdotto, String optyId, String debitore){
        Id rtFactoringDiretto = U.getRecordTypes('Linea__c').get('FactDir').Id;
        Id rtConfirming = U.getRecordTypes('Linea__c').get('Confirming').Id;
        Set<Id> rTypes = new Set<Id>{rtFactoringDiretto, rtConfirming};

        List<Linea__c> lineePossibili;
        if(famigliaProdotto == 'Acquisto Titolo Definitivo')
            lineePossibili = new List<Linea__c>([SELECT Id, Name, Prodotto__r.Name, Prodotto__r.WGC_Famiglia__c, WGC_Numero_Linea_Credito__c, TipoLinea__c, LineaATD__c FROM Linea__c WHERE LineaATD__c = true AND Opportunity__c =: optyId AND WGC_Numero_Linea_Credito__c != null AND RecordTypeId IN :rTypes]);
        else
            lineePossibili = new List<Linea__c>([SELECT Id, Name, Prodotto__r.Name, Prodotto__r.WGC_Famiglia__c, WGC_Numero_Linea_Credito__c FROM Linea__c WHERE Prodotto__r.WGC_Famiglia__c =: famigliaProdotto AND LineaATD__c != true AND Opportunity__c =: optyId AND WGC_Numero_Linea_Credito__c != null AND RecordTypeId IN :rTypes]);
        
        System.debug('@@@ lineePossibili ' + JSON.serialize(lineePossibili));

        Map<String, List<Linea__c>> resultMap = new Map<String, List<Linea__c>>();

        if(!lineePossibili.isEmpty())
            resultMap.put(debitore, lineePossibili);

        return resultMap.keySet().size() > 0 ? resultMap : null;
    }

    /*
    public static Map<String, List<Linea__c>> getProductsFromConfiguration(CtrlWizardOpportunity.WoPayload payload){
        Map<String, List<Linea__c>> resultMap = new Map<String, List<Linea__c>>();

        Id rtFactoringDiretto = U.getRecordTypes('Linea__c').get('FactDir').Id;
        Id rtConfirming = U.getRecordTypes('Linea__c').get('Confirming').Id;
        Set<Id> rTypes = new Set<Id>{rtFactoringDiretto, rtConfirming};

        // SALVO VALORI OPZIONI ATD (stanno sui debitori) + ritorno nuovo WoPayload che ha azzerato id js
        CtrlWizardOpportunity.WoPayload p = CtrlWizardOpportunity.saveDebitoriInternal(payload);
        // MB - TEN: AGGIUNTO PARAMETRO "WGC_Mercato__c" PER SOVRASCRITTURA MERCATO LINEA SE CAMPO VALORIZZATO
        // recupero NDGLinea per l'opportunità corrente
        Map<String, SObject> debitoriMap = U.keyBy([SELECT
        FakeId__c,
        ANotifica__c,
        Maturity__c,
        DivisaNew__c,
        Mercato__c,
        WGC_Mercato__c,
        Prosoluto__c,
        ProsolutoATD__c,
        Rotativita__c,
        Anticipazione__c,
        Tipo__c
        FROM NDGLinea__c
        WHERE Opportunita__c = :p.opportunityId
        AND Tipo__c IN ('Debitore', 'Valutazione portafoglio')
        ], 'FakeId__c');

        Boolean haIfisImpresa = CtrlWizardOpportunity.hasProdottoInOpp(K.CODPROD_IFIS_IMPRESA, p.opportunityId);
        Map<String, CtrlWizardOpportunity.CodiceATD[]> codiciProdottoATDStruct = CtrlWizardOpportunity.getCodiciProdottoAtd(p, haIfisImpresa);

        // allCodici conterrà l'elenco dei codici delle linee che dovremo creare, in base alle configurazioni matchate in matriceATD e quelle per ATDCS
        Set<String> allCodici = new Set<String>();
        for(CtrlWizardOpportunity.CodiceATD[] cATD : codiciProdottoATDStruct.values()) {
            for(CtrlWizardOpportunity.CodiceATD c : cATD) {
                allCodici.add(c.linea);
            }
        }

        Set<String> revisionedProds = U.getSet([SELECT Id, WGC_Numero_Linea_Credito__c FROM Linea__c WHERE Opportunity__c = :p.opportunityId AND WGC_Numero_Linea_Credito__c != null], 'WGC_Numero_Linea_Credito__c');

        // MB - TEN: AGGIUNTO CAMPO "WGC_Famiglia__c"
        QueryBuilder.FilterBuilder qb = QueryBuilder.newInstance('Prodotto__c', new String[]{'Id', 'Servizio__c', 'Notifica__c', 'Maturity__c', 'Codice__c', 'WGC_Famiglia__c'})
        .beginFilter()
            .beginOr();

            for(CtrlWizardOpportunity.WoJoinLineaAttore j : p.joinLineaAttore) {
                for(String servizio : j.servizi) {
                // per ATDCS e ATD la query sarà la stessa
                String s = (servizio == 'ATD - TiAnticipo' || servizio == 'ATD con proroga Confirming') ? 'Acquisto a titolo definitivo' : servizio;
                if (s == 'Factoring' || s == 'Anticipo Crediti futuri') {
                    qb.beginAnd()
                    .add('Servizio__c', QBOp.QEQUAL, s)
                    .add('Notifica__c', QBOp.QEQUAL, debitoriMap.get(j.debitore).get('ANotifica__c'))
                    .end();
                }

                if (s == 'Confirming') {
                    qb.beginAnd()
                    .add('Servizio__c', QBOp.QEQUAL, s)
                    .end();
                }

                // Se è factoring, meglio prendersi su anche i Maturity
                if(s == 'Factoring') {
                    qb.add('Servizio__c', QBOp.QEQUAL, 'Maturity');
                }

                // ATD SE NE FREGA DI Servizio__c e Notifica__c
                if(s == 'Acquisto a titolo definitivo') {
                    qb.add('Codice__c', QBOp.QIN, allCodici);
                }

                // MB - TEN: AGGIUNTO PRODOTTO "SOLA GESTIONE" COME LINEA D'ACQUISTO
                if (s == 'Sola Gestione') {
                    qb.add('Codice__c', QBOp.QEQUAL, (debitoriMap.get(j.debitore).get('ANotifica__c') == true ? '561' : '661'));
                }
                }
            }

        if (revisionedProds.size() > 0)
            qb.add('Codice__c', QBOp.QNOT_IN, revisionedProds);

        String query2 = qb
        .end()
        .endFilter()
        .getQuery();

        List<Prodotto__c> prodottiQuery = Database.query(query2);

        System.debug('@@@ prodottiQuery ' + JSON.serialize(prodottiQuery));

        // MB - TEN: AGGIUNTA MAPPA PER GESTIONE "Sola Gestione"    
        // Ho ora l'elenco dei prodotti che dovrò creare
        Map<String, SObject> prodottiMap = U.keyBy(prodottiQuery, 'Servizio__c', true);
        System.debug('@@@ prodottiMap ' + JSON.serialize(prodottiMap));
        Map<String, SObject> prodottiATD = U.keyBy(prodottiQuery, 'Codice__c');
        System.debug('@@@ prodottiATD ' + JSON.serialize(prodottiATD));
        Map<String, SObject> prodottiSolaGestioneMap = U.keyBy(prodottiQuery, 'Codice__c');
        System.debug('@@@@ prodottiSolaGestioneMap: ' + prodottiSolaGestioneMap);
        // nuove linee (da inserire o aggiornare)
        Map<String, Linea__c> linee = new Map<String, Linea__c>();

        // MB - TEN: AGGIUNTO PARAMETRO "WGC_Mercato__c"
        // vecchie linee da rimuovere
        List<Linea__c> oldLinee = [SELECT
        Id,
        Prodotto__r.Servizio__c,
        Prodotto__r.Notifica__c,
        Prodotto__r.Maturity__c,
        Prodotto__r.Codice__c,
        Prodotto__r.Name,
        Mercato__c,
        DivisaNew__c,
        DebitoreAnticipazione__c,
        DebitoreRotativita__c,
        DebitoreTipo__c,
        LineaProsoluto__c,
        ProsolutoATD__c,
        LineaATD__c,
        TipoLinea__c,
        WGC_Numero_Linea_Credito__c
        FROM Linea__c
        WHERE Opportunity__c = :p.opportunityId
        AND RecordTypeId IN :rTypes
        AND WGC_Numero_Linea_Credito__c != null
        ];

        // mappe delle vecchie per chiave
        Map<String, SObject> oldLineeMap = U.keyBy(oldLinee, '{Prodotto__r.Servizio__c}_{Prodotto__r.Notifica__c}_{Prodotto__r.Maturity__c}_{Mercato__c}_{DivisaNew__c}_{LineaATD__c}', true);
        Map<String, SObject> oldLineeMapATD = U.keyBy(oldLinee, '{Prodotto__r.Codice__c}_{Mercato__c}_{DivisaNew__c}_{DebitoreAnticipazione__c}_{ProsolutoATD__c}_{DebitoreRotativita__c}_{DebitoreTipo__c}_{LineaATD__c}', true);
        Map<String, SObject> oldProdsMap = U.keyBy(oldLinee, 'Prodotto__r.Codice__c');

        Map<String, SObject> oldJoinsMap = U.keyBy([SELECT Id, Linea__r.Prodotto__r.WGC_Famiglia__c, Linea__r.Prodotto__r.Codice__c, Debitore__r.FakeId__c, WGC_Codice_Random_Coppia__c 
                                                    FROM JoinLineaDebitore__c
                                                    WHERE Linea__r.Opportunity__c = :p.opportunityId AND WGC_Codice_Random_Coppia__c != null],
                                                    '{Debitore__r.FakeId__c}_{Linea__r.Prodotto__r.WGC_Famiglia__c}_{Linea__r.Prodotto__r.Codice__c}', true);

        System.debug('@@@ oldLineeMap ' + JSON.serialize(oldLineeMap));
        System.debug('@@@ oldLineeMapATD ' + JSON.serialize(oldLineeMapATD));
        System.debug('@@@ oldProdsMap ' + JSON.serialize(oldProdsMap));
        System.debug('@@@ oldJoinsMap ' + JSON.serialize(oldJoinsMap));

        for(CtrlWizardOpportunity.WoJoinLineaAttore j : p.joinLineaAttore) {
            System.debug('@@@ j ' + JSON.serialize(j));
            NDGLinea__c debitore = (NDGLinea__c) debitoriMap.get(j.debitore);

            // codiciATDMap contiene (per il debitore corrente nel ciclo) una mappa "codice linea" -> "informazioni linea da creare"
            Map<String, CtrlWizardOpportunity.CodiceATD> codiciATDMap = new Map<String,CtrlWizardOpportunity.CodiceATD>();
            if(codiciProdottoATDStruct.containsKey(j.debitore)) {
                for(CtrlWizardOpportunity.CodiceATD cod : codiciProdottoATDStruct.get(j.debitore)) {
                    codiciATDMap.put(cod.linea, cod);
                }
            }

            for(String s : j.servizi) {
                // la chiave per i prodotti è priva di mercato: mercato è solo su Linea__c
                Boolean isATD = (s == 'Acquisto a titolo definitivo' || s == 'ATD - TiAnticipo' || s == 'ATD con proroga Confirming');
                // MB - TEN: GESTIONE "Sola Gestione"
                Boolean isSolaGestione = s == 'Sola Gestione';
                System.debug('@@@@ debitore: ' + debitore);
                Set<String> chiaviProd = new Set<String>{s};
                if(isATD) chiaviProd = codiciATDMap.keySet();
                // MB - TEN: GESTIONE "Sola Gestione"
                if (isSolaGestione) {
                    Set<String> codes = new Set<String>{ debitore.ANotifica__c == true ? '561' : '661' };
                    chiaviProd = codes;
                }

                // MB - TEN: AGGIUNTA CONDIZIONE PER UTILIZZARE MAPPA PRODOTTI_CODICE IN CASO DI SERVIZIO "Sola Gestione"
                Map<String, SObject> prodottiMapFinal = (isATD ? prodottiATD : (isSolaGestione ? prodottiSolaGestioneMap : prodottiMap));
                Map<String, SObject> oldLineeMapFinal = isATD ? oldLineeMapATD : oldLineeMap;

                for(String codProd : chiaviProd) {
                    String servizio = codProd.split('_')[0];
                    // MB - TEN: AGGIUNTO PARAMETRO "WGC_Mercato__c"
                    // TODO ATD DM: in teoria per fare il match sulla mappa bisognerebbe tenere così le stringhe, CHECK!
                    // String codLinea = codProd  + '_' + (debitore.Mercato__c != null ? debitore.Mercato__c : '{Mercato__c}') + '_' + (debitore.DivisaNew__c != null ? debitore.DivisaNew__c : '{DivisaNew__c}');
                    String codLinea = codProd  + '_' + (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : (debitore.Mercato__c != null ? debitore.Mercato__c : '{Mercato__c}')) + '_' + (debitore.DivisaNew__c != null ? debitore.DivisaNew__c : '{DivisaNew__c}');
                    // TODO - TEN: DA MODIFICARE LA GESTIONE DEI CAMPI UTILIZZANDO QUELLI NUOVI ATD2.0
                    if(isATD)
                        codLinea += '_' + (debitore.Anticipazione__c != null ? debitore.Anticipazione__c : '{DebitoreAnticipazione__c}') + '_' +
                                          (debitore.ProsolutoATD__c != null ? debitore.ProsolutoATD__c : '{ProsolutoATD__c}') + '_' + 
                                          debitore.Rotativita__c + '_' + (debitore.Tipo__c != null ? debitore.Tipo__c : '{DebitoreTipo__c}');
                    // String codLinea = codProd  + '_' + debitore.Mercato__c + '_' + debitore.DivisaNew__c;
                    // if(isATD) codLinea += '_' + debitore.Anticipazione__c + '_' + debitore.ProsolutoATD__c + '_' + debitore.Rotativita__c + '_' + debitore.Tipo__c;
                    codLinea += '_' + isATD;
            // System.debug('@@@@ codProd: ' + codProd);
            // System.debug('@@@@ prodottiMapFinal: ' + prodottiMapFinal);
                    if(!prodottiMapFinal.containsKey(codProd)) throw new Ex.WSException(CtrlWizardOpportunity.ERROR_CONFIGURAZIONE);

                    Prodotto__c pd = (Prodotto__c) prodottiMapFinal.get(codProd);
                    System.debug('@@@@ prodotto: ' + pd);
                    System.debug('@@@@ oldLineeMapFinal: ' + oldLineeMapFinal);
                    System.debug('@@@@ codLinea: ' + codLinea);
                    System.debug('@@@@ oldJoinsMap: ' + oldJoinsMap);
                    System.debug('@@@@ chiave oldJoinsMap ' + j.debitore + '_' + pd.WGC_Famiglia__c + '_' + pd.Codice__c);
                    if (oldLineeMapFinal.containsKey(codLinea) || (isATD && oldProdsMap.get(codProd) != null)) {
                        if (oldJoinsMap.get(j.debitore + '_' + pd.WGC_Famiglia__c + '_' + pd.Codice__c) == null) {
                            if (resultMap.get(j.debitore) == null)
                                resultMap.put(j.debitore, new List<Linea__c>());
                                
                            resultMap.get(j.debitore).add(
                                isATD ? (Linea__c) oldProdsMap.get(codProd) : (Linea__c) oldLineeMapFinal.get(codLinea)
                            );
                        }
                    }
                }
            }
        }

        return resultMap.keySet().size() > 0 ? resultMap : null; 
    }

    /*
    public static Map<String, List<Linea__c>> getProductsFromConfiguration(CtrlWizardOpportunity.WoPayload payload) {
        Id rtFactoringDiretto = U.getRecordTypes('Linea__c').get('FactDir').Id;
        Id rtConfirming = U.getRecordTypes('Linea__c').get('Confirming').Id;
        Set<Id> rTypes = new Set<Id>{rtFactoringDiretto, rtConfirming};
    System.debug('@@@@ rtFactoringDiretto: ' + rtFactoringDiretto);
        // SALVO VALORI OPZIONI ATD (stanno sui debitori) + ritorno nuovo WoPayload che ha azzerato id js
        CtrlWizardOpportunity.WoPayload p = CtrlWizardOpportunity.saveDebitoriInternal(payload);
        // MB - TEN: AGGIUNTO PARAMETRO "WGC_Mercato__c" PER SOVRASCRITTURA MERCATO LINEA SE CAMPO VALORIZZATO
        // recupero NDGLinea per l'opportunità corrente
        Map<String, SObject> debitoriMap = U.keyBy([SELECT
        FakeId__c,
        ANotifica__c,
        Maturity__c,
        DivisaNew__c,
        Mercato__c,
        WGC_Mercato__c,
        Prosoluto__c,
        ProsolutoATD__c,
        Rotativita__c,
        Anticipazione__c,
        Tipo__c
        FROM NDGLinea__c
        WHERE Opportunita__c = :p.opportunityId
        AND Tipo__c IN ('Debitore', 'Valutazione portafoglio')
        ], 'FakeId__c');


        Boolean haIfisImpresa = CtrlWizardOpportunity.hasProdottoInOpp(K.CODPROD_IFIS_IMPRESA, p.opportunityId);
        Map<String, CtrlWizardOpportunity.CodiceATD[]> codiciProdottoATDStruct = CtrlWizardOpportunity.getCodiciProdottoAtd(p, haIfisImpresa);

        // allCodici conterrà l'elenco dei codici delle linee che dovremo creare, in base alle configurazioni matchate in matriceATD e quelle per ATDCS
        Set<String> allCodici = new Set<String>();
        for(CtrlWizardOpportunity.CodiceATD[] cATD : codiciProdottoATDStruct.values()) {
            for(CtrlWizardOpportunity.CodiceATD c : cATD) {
                allCodici.add(c.linea);
            }
        }

        Set<String> revisionedProds = U.getSet([SELECT Id, WGC_Numero_Linea_Credito__c FROM Linea__c WHERE Opportunity__c = :p.opportunityId AND WGC_Numero_Linea_Credito__c != null], 'WGC_Numero_Linea_Credito__c');

        // MB - TEN: AGGIUNTO CAMPO "WGC_Famiglia__c"
        QueryBuilder.FilterBuilder qb = QueryBuilder.newInstance('Prodotto__c', new String[]{'Id', 'Servizio__c', 'Notifica__c', 'Maturity__c', 'Codice__c', 'WGC_Famiglia__c'})
        .beginFilter()
            .beginOr();

            for(CtrlWizardOpportunity.WoJoinLineaAttore j : p.joinLineaAttore) {
                for(String servizio : j.servizi) {
                // per ATDCS e ATD la query sarà la stessa
                String s = (servizio == 'ATD - TiAnticipo' || servizio == 'ATD con proroga Confirming') ? 'Acquisto a titolo definitivo' : servizio;
                if (s == 'Factoring' || s == 'Anticipo Crediti futuri') {
                    qb.beginAnd()
                    .add('Servizio__c', QBOp.QEQUAL, s)
                    .add('Notifica__c', QBOp.QEQUAL, debitoriMap.get(j.debitore).get('ANotifica__c'))
                    .end();
                }

                if (s == 'Confirming') {
                    qb.beginAnd()
                    .add('Servizio__c', QBOp.QEQUAL, s)
                    .end();
                }

                // Se è factoring, meglio prendersi su anche i Maturity
                if(s == 'Factoring') {
                    qb.add('Servizio__c', QBOp.QEQUAL, 'Maturity');
                }

                // ATD SE NE FREGA DI Servizio__c e Notifica__c
                if(s == 'Acquisto a titolo definitivo') {
                    qb.add('Codice__c', QBOp.QIN, allCodici);
                }

                // MB - TEN: AGGIUNTO PRODOTTO "SOLA GESTIONE" COME LINEA D'ACQUISTO
                if (s == 'Sola Gestione') {
                    qb.add('Codice__c', QBOp.QEQUAL, (debitoriMap.get(j.debitore).get('ANotifica__c') == true ? '561' : '661'));
                }
                }
            }

        if (revisionedProds.size() > 0)
            qb.add('Codice__c', QBOp.QNOT_IN, revisionedProds);

        String query2 = qb
        .end()
        .endFilter()
        .getQuery();

        List<Prodotto__c> prodottiQuery = Database.query(query2);

        // MB - TEN: AGGIUNTA MAPPA PER GESTIONE "Sola Gestione"
        // Ho ora l'elenco dei prodotti che dovrò creare
        Map<String, SObject> prodottiMap = U.keyBy(prodottiQuery, '{Servizio__c}_{Notifica__c}_{Maturity__c}', true);
        Map<String, SObject> prodottiATD = U.keyBy(prodottiQuery, 'Codice__c');
        Map<String, SObject> prodottiSolaGestioneMap = U.keyBy(prodottiQuery, 'Codice__c');
        System.debug('@@@@ prodottiSolaGestioneMap: ' + prodottiSolaGestioneMap);
        // nuove linee (da inserire o aggiornare)
        Map<String, Linea__c> linee = new Map<String, Linea__c>();

        // MB - TEN: AGGIUNTO PARAMETRO "WGC_Mercato__c"
        // vecchie linee da rimuovere
        List<Linea__c> oldLinee = [SELECT
        Id,
        Prodotto__r.Servizio__c,
        Prodotto__r.Notifica__c,
        Prodotto__r.Maturity__c,
        Prodotto__r.Codice__c,
        Prodotto__r.Name,
        Mercato__c,
        DivisaNew__c,
        DebitoreAnticipazione__c,
        DebitoreRotativita__c,
        DebitoreTipo__c,
        LineaProsoluto__c,
        ProsolutoATD__c,
        LineaATD__c,
        TipoLinea__c,
        WGC_Numero_Linea_Credito__c
        FROM Linea__c
        WHERE Opportunity__c = :p.opportunityId
        AND RecordTypeId IN :rTypes
        AND WGC_Numero_Linea_Credito__c != null
        ];

        // mappe delle vecchie per chiave
        Map<String, SObject> oldLineeMap = U.keyBy(oldLinee, '{Prodotto__r.Servizio__c}_{Prodotto__r.Notifica__c}_{Prodotto__r.Maturity__c}_{Mercato__c}_{DivisaNew__c}_{LineaATD__c}', true);
        Map<String, SObject> oldLineeMapATD = U.keyBy(oldLinee, '{Prodotto__r.Codice__c}_{Mercato__c}_{DivisaNew__c}_{DebitoreAnticipazione__c}_{ProsolutoATD__c}_{DebitoreRotativita__c}_{DebitoreTipo__c}_{LineaATD__c}', true);
        Map<String, SObject> oldProdsMap = U.keyBy(oldLinee, 'Prodotto__r.Codice__c');

        Map<String, SObject> oldJoinsMap = U.keyBy([SELECT Id, Linea__r.Prodotto__r.WGC_Famiglia__c, Linea__r.Prodotto__r.Codice__c, Debitore__r.FakeId__c, WGC_Codice_Random_Coppia__c 
                                                    FROM JoinLineaDebitore__c
                                                    WHERE Linea__r.Opportunity__c = :p.opportunityId AND WGC_Codice_Random_Coppia__c != null],
                                                    '{Debitore__r.FakeId__c}_{Linea__r.Prodotto__r.WGC_Famiglia__c}_{Linea__r.Prodotto__r.Codice__c}', true);

        Map<String, List<Linea__c>> resultMap = new Map<String, List<Linea__c>>();

        for(CtrlWizardOpportunity.WoJoinLineaAttore j : p.joinLineaAttore) {
            System.debug('@@@ j ' + JSON.serialize(j));
            NDGLinea__c debitore = (NDGLinea__c) debitoriMap.get(j.debitore);

            // codiciATDMap contiene (per il debitore corrente nel ciclo) una mappa "codice linea" -> "informazioni linea da creare"
            Map<String, CtrlWizardOpportunity.CodiceATD> codiciATDMap = new Map<String,CtrlWizardOpportunity.CodiceATD>();
            if(codiciProdottoATDStruct.containsKey(j.debitore)) {
                for(CtrlWizardOpportunity.CodiceATD cod : codiciProdottoATDStruct.get(j.debitore)) {
                    codiciATDMap.put(cod.linea, cod);
                }
            }


            for(String s : j.servizi) {
                // nel caso di factoring ordinario si considera il flag maturity, altrimenti non lo si considera nella chiave
                Boolean flagMaturity = s == 'Factoring' ? debitore.Maturity__c : false;
                // i codici sono quelli comprensivi di mercato, per le linee. Per trovare i codici dei prodotti, bisogna escludere Mercato__c dalla chiave
                // la chiave per i prodotti è priva di mercato: mercato è solo su Linea__c
                Boolean isATD = (s == 'Acquisto a titolo definitivo' || s == 'ATD - TiAnticipo' || s == 'ATD con proroga Confirming');
                // MB - TEN: GESTIONE "Sola Gestione"
                Boolean isSolaGestione = s == 'Sola Gestione';
        System.debug('@@@@ debitore: ' + debitore);
                Set<String> chiaviProd = new Set<String>{s + '_' + debitore.ANotifica__c + '_' + flagMaturity};
                if(isATD) chiaviProd = codiciATDMap.keySet();
                // MB - TEN: GESTIONE "Sola Gestione"
                if (isSolaGestione) {
                    Set<String> codes = new Set<String>{ debitore.ANotifica__c == true ? '561' : '661' };
                    chiaviProd = codes;
                }

                // MB - TEN: AGGIUNTA CONDIZIONE PER UTILIZZARE MAPPA PRODOTTI_CODICE IN CASO DI SERVIZIO "Sola Gestione"
                // Map<String, SObject> prodottiMapFinal = isATD ? prodottiATD : prodottiMap;
                Map<String, SObject> prodottiMapFinal = (isATD ? prodottiATD : (isSolaGestione ? prodottiSolaGestioneMap : prodottiMap));
                Map<String, SObject> oldLineeMapFinal = isATD ? oldLineeMapATD : oldLineeMap;

                for(String codProd : chiaviProd) {
                    String servizio = codProd.split('_')[0];
                    // MB - TEN: AGGIUNTO PARAMETRO "WGC_Mercato__c"
                    // TODO ATD DM: in teoria per fare il match sulla mappa bisognerebbe tenere così le stringhe, CHECK!
                    // String codLinea = codProd  + '_' + (debitore.Mercato__c != null ? debitore.Mercato__c : '{Mercato__c}') + '_' + (debitore.DivisaNew__c != null ? debitore.DivisaNew__c : '{DivisaNew__c}');
                    String codLinea = codProd  + '_' + (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : (debitore.Mercato__c != null ? debitore.Mercato__c : '{Mercato__c}')) + '_' + (debitore.DivisaNew__c != null ? debitore.DivisaNew__c : '{DivisaNew__c}');
                    // TODO - TEN: DA MODIFICARE LA GESTIONE DEI CAMPI UTILIZZANDO QUELLI NUOVI ATD2.0
                    if(isATD)
                        codLinea += '_' + (debitore.Anticipazione__c != null ? debitore.Anticipazione__c : '{DebitoreAnticipazione__c}') + '_' +
                                          (debitore.ProsolutoATD__c != null ? debitore.ProsolutoATD__c : '{ProsolutoATD__c}') + '_' + 
                                          debitore.Rotativita__c + '_' + (debitore.Tipo__c != null ? debitore.Tipo__c : '{DebitoreTipo__c}');
                    // String codLinea = codProd  + '_' + debitore.Mercato__c + '_' + debitore.DivisaNew__c;
                    // if(isATD) codLinea += '_' + debitore.Anticipazione__c + '_' + debitore.ProsolutoATD__c + '_' + debitore.Rotativita__c + '_' + debitore.Tipo__c;
                    codLinea += '_' + isATD;
            // System.debug('@@@@ codProd: ' + codProd);
            // System.debug('@@@@ prodottiMapFinal: ' + prodottiMapFinal);
                    if(!prodottiMapFinal.containsKey(codProd)) throw new Ex.WSException(CtrlWizardOpportunity.ERROR_CONFIGURAZIONE);

                    Prodotto__c pd = (Prodotto__c) prodottiMapFinal.get(codProd);
            System.debug('@@@@ prodotto: ' + pd);
            System.debug('@@@@ oldLineeMapFinal: ' + oldLineeMapFinal);
            System.debug('@@@@ codLinea: ' + codLinea);
            System.debug('@@@@ oldJoinsMap: ' + oldJoinsMap);
            System.debug('@@@@ chiave oldJoinsMap ' + j.debitore + '_' + pd.WGC_Famiglia__c + '_' + pd.Codice__c);
                    if (oldLineeMapFinal.containsKey(codLinea) || (isATD && oldProdsMap.get(codProd) != null)) {
                        if (oldJoinsMap.get(j.debitore + '_' + pd.WGC_Famiglia__c + '_' + pd.Codice__c) == null) {
                            if (resultMap.get(j.debitore) == null)
                                resultMap.put(j.debitore, new List<Linea__c>());
                                
                            resultMap.get(j.debitore).add(
                                isATD ? (Linea__c) oldProdsMap.get(codProd) : (Linea__c) oldLineeMapFinal.get(codLinea)
                            );
                        }
                    }
                }
            }
        }
            System.debug('@@@@ resultMap: ' + resultMap);
        return resultMap.keySet().size() > 0 ? resultMap : null;
    }
    */

    // public static String getJoinDebLinea(CtrlWizardOpportunity.WoPayload p) {
    //     Id rtFactoringDiretto = U.getRecordTypes('Linea__c').get('FactDir').Id;
    //     Id rtConfirming = U.getRecordTypes('Linea__c').get('Confirming').Id;
    //     Set<Id> rTypes = new Set<Id>{rtFactoringDiretto, rtConfirming};
    //     List<Object> joins = new List<Objet>();

    //     List<Linea__c> oldLinee = [SELECT
    //     Id,
    //     Prodotto__r.Servizio__c,
    //     Prodotto__r.Notifica__c,
    //     Prodotto__r.Maturity__c,
    //     Prodotto__r.Codice__c,
    //     Mercato__c,
    //     DivisaNew__c,
    //     DebitoreAnticipazione__c,
    //     DebitoreRotativita__c,
    //     DebitoreTipo__c,
    //     LineaProsoluto__c,
    //     ProsolutoATD__c,
    //     LineaATD__c,
    //     WGC_Numero_Linea_Credito__c
    //     FROM Linea__c
    //     WHERE Opportunity__c = :p.opportunityId
    //     AND RecordTypeId IN :rTypes
    //     AND WGC_Numero_Linea_Credito__c != null
    //     ];

    //     Map<String, SObject> oldJoinMap = U.keyBy([SELECT Id, Linea__r.Prodotto__r.WGC_Famiglia__c, Linea__r.Prodotto__r.Codice__c, Debitore__r.FakeId__c, Linea__c, WGC_Codice_Random_Coppia__c FROM JoinLineaDebitore__c WHERE Linea__r.Opportunity__c = :p.opportunityId], '{Debitore__r.FakeId__c}_{Linea__r.Prodotto__r.WGC_Famiglia__c}', true);

    //     // mappe delle vecchie per chiave
    //     Map<String, SObject> oldLineeMap = U.keyBy(oldLinee, '{Prodotto__r.Servizio__c}_{Prodotto__r.Notifica__c}_{Prodotto__r.Maturity__c}_{Mercato__c}_{DivisaNew__c}_{LineaATD__c}', true);
    //     Map<String, SObject> oldLineeMapATD = U.keyBy(oldLinee, '{Prodotto__r.Codice__c}_{Mercato__c}_{DivisaNew__c}_{DebitoreAnticipazione__c}_{ProsolutoATD__c}_{DebitoreRotativita__c}_{DebitoreTipo__c}_{LineaATD__c}', true);

    //     for (CtrlWizardOpportunity.WoJoinLineaAttore j : p.joinLineaAttore) {
    //         for (String s : j.servizi) {
    //             if (oldJoinMap.get(j.debitore + '_' + s) == null) // SE NUOVA JOIN (SENZA CODICE RANDOM COPPIA)
                    
    //         }
    //     }
    // }

/* END - METODI DI GESTIONE CHECK LINEE ESISTENTI */

/* METODI DI GESTIONE RSF (CHECK, DOWNLOAD, UPLOAD) */

    @AuraEnabled
    public static String docCheckListOpportunity(String opportunityId){
        WGC_Documenti_Controller.WrapperResponse resp_oppty = WGC_Documenti_Controller.docCheckListOpportunity(opportunityId);
        String RSFDocumentCode;
        List<WGC_Metadati_Documentale__mdt> documents = new List<WGC_Metadati_Documentale__mdt>();
        documents = [SELECT Id, MasterLabel, DeveloperName, Classe__c, Documento__c, Istituto__c, Sottoclasse__c FROM WGC_Metadati_Documentale__mdt WHERE DeveloperName = 'RSF'];

        for (WGC_Metadati_Documentale__mdt d : documents) {
            if (d.DeveloperName == 'RSF')
                RSFDocumentCode = d.Documento__c;
        }

        Boolean bool = false;
        Map<String, Object> returnMap = new Map<String, Object>();
        String scadenzaRSF = '';
        Date dataRSF;
        returnMap.put('datiDoc', RSFDocumentCode);
        
        try {
            // RECUPERO RSF
            if (resp_oppty.data != null) {
                WGC_Documenti_Controller.OutputDoc10 output = (WGC_Documenti_Controller.OutputDoc10) resp_oppty.data[0];
                if (output.payload != null && output.payload.results != null) {
                    for (WGC_Documenti_Controller.ResultDoc10 res : output.payload.results) {
                        if (res.index_value == RSFDocumentCode) {
                            returnMap.put('validRSF', !res.missing);
                            returnMap.put('docIdRSF', res.docs[0].id);
                            for (WGC_Documenti_Controller.IndiceDoc10 i : res.docs[0].indice) {
                                System.debug('@@@@ IndiceDoc: ' + i);
                                if (i.nome == 'DATASTATO') {
                                    returnMap.put('scadenzaRSF', i.valore);
                                    dataRSF = Date.newInstance(
                                        Integer.valueOf(i.valore.substring(4, 8)),
                                        Integer.valueOf(i.valore.substring(2, 4)),
                                        Integer.valueOf(i.valore.substring(0, 2)));

                                    if (dataRSF.daysBetween(Date.today()) > 0)
                                        returnMap.put('validRSF', false);
                                }
                                if (i.nome == 'Name') {
                                    System.debug('@@@@ Name: ' + i.valore);
                                    returnMap.put('fileNameRSF', i.valore);
                                }
                            }
                        }
                    }
                }
            } else
                returnMap.put('validRSF', false);
            
        } catch (Exception e) {
            System.debug('@@@@ ERRORE NELLA VERIFICA DEL FILE RSF: ' + e.getStackTraceString() + ' --- ' + e.getMessage());
            returnMap.put('valid', false);
        }

        return JSON.serialize(returnMap);
    }

    @AuraEnabled
    public static String docCheckListAccount(String accountId) {
        WGC_Documenti_Controller.WrapperResponse resp_anag = WGC_Documenti_Controller.docCheckList(accountId);
        String PrivacyDocumentCode;
        List<WGC_Metadati_Documentale__mdt> documents = new List<WGC_Metadati_Documentale__mdt>();
        documents = [SELECT Id, MasterLabel, DeveloperName, Classe__c, Documento__c, Istituto__c, Sottoclasse__c FROM WGC_Metadati_Documentale__mdt WHERE DeveloperName = 'Scansione_privacy'];

        for (WGC_Metadati_Documentale__mdt d : documents) {
            if (d.DeveloperName == 'Scansione_privacy')
                PrivacyDocumentCode = d.Documento__c;
        }

        Boolean bool = false;
        Map<String, Object> returnMap = new Map<String, Object>();
        
        try {
            // RECUPERO PRIVACY
            if (resp_anag.data != null) {
                WGC_Documenti_Controller.OutputDoc10 output = (WGC_Documenti_Controller.OutputDoc10) resp_anag.data[0];
                if (output.payload != null && output.payload.results != null) {
                    for (WGC_Documenti_Controller.ResultDoc10 res : output.payload.results) {
                        if (res.index_value == PrivacyDocumentCode) {
                            returnMap.put('validPrivacy', !res.missing);
                        }
                    }
                }
            } else
                returnMap.put('validPrivacy', false);
            
        } catch (Exception e) {
            System.debug('@@@@ ERRORE NELLA VERIFICA DEL FILE PRIVACY: ' + e.getStackTraceString() + ' --- ' + e.getMessage());
            returnMap.put('valid', false);
        }

        return JSON.serialize(returnMap);
    }

    @AuraEnabled
    public static WGC_Documenti_Controller.WrapperResponse doc08(String accountId, String document){
        return WGC_Documenti_Controller.doc08(accountId, document);
    }

    @AuraEnabled
    public static WGC_Documenti_Controller.WrapperResponse doc11(String recordId, String codiceModulo, String nomeFile, String language){
        return WGC_Documenti_Controller.doc11(recordId, codiceModulo, nomeFile, language);
    }

/* END - METODI DI GESTIONE RSF (CHECK, DOWNLOAD, UPLOAD) */

/* METODI DI GESTIONE CROSS SELLING */

    @AuraEnabled
    public static Boolean saveCrossSellingJSON(Id opportunityId, String crossSellingJSON){
        try {
            Opportunity o = new Opportunity();
            o.Id = opportunityId;
            o.WGC_Cross_Selling_JSON__c = crossSellingJSON;
            update o;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public static String manageCrossSelling(String payload) {
        Map<String, Object> p = (Map<String, Object>) JSON.deserializeUntyped(payload);
        List<Object> crossSelling = (List<Object>) p.get('crossSelling');
        // Boolean redirect = false;
        String redirect = '';

        if (crossSelling != null && crossSelling.size() > 0) { // SE ALMENO UN PRODOTTO CROSS SELLING SELEZIONATO
            Id opportunityId = (Id) p.get('opportunityId');
            Opportunity currentOpp = [SELECT AccountId, WGC_Prodotti_Selezionati__c, Account.WGC_Qualifica_Corporate__c FROM Opportunity WHERE Id = :opportunityId];
            Id accountId = currentOpp.AccountId;
            List<Object> pb = (List<Object>) p.get('pb');
            List<Object> pfi = (List<Object>) p.get('pfi');
            List<Object> joinLineaAttore = (List<Object>) p.get('joinLineaAttore');
            List<String> prodToRemove = new List<String>();
            List<Opportunity> csItems = new List<Opportunity>();
            List<Prodotto__c> prods = [SELECT Id, WGC_Area__c, WGC_Famiglia__c, WGC_Tipo_Cross_Selling__c FROM Prodotto__c WHERE WGC_Tipo_Cross_Selling__c != null];
            Map<String, String> prodToOpptyRTNameMap = new Map<String, String>();
            Map<String, String> opptyRTMap = new Map<String, String>();
            Map<String, Id> assegnatari = WizardOpportunityController.getCrossSellingAssegnatariPerBU(accountId);
            User currUser = [SELECT Qualifica_Utente__c FROM User WHERE Id = :UserInfo.getUserId()];
            Map<String, SObject> originators = U.keyBy([SELECT Id, Originator_dettaglio__c, Qualifica_Utente__c FROM WGC_Originator__mdt], 'Qualifica_Utente__c');

            //SM - CR Settembre
            Map<String, Opportunity> factOpty = new Map<String,Opportunity>();
			
            for (Prodotto__c pr : prods)
                if (prodToOpptyRTNameMap.get(pr.WGC_Area__c + '_' + pr.WGC_Famiglia__c) == null)
                    prodToOpptyRTNameMap.put(pr.WGC_Area__c + '_' + pr.WGC_Famiglia__c, pr.WGC_Tipo_Cross_Selling__c);
            
            System.debug('@@@ prodToOpptyRTNameMap ' + JSON.serialize(prodToOpptyRTNameMap));
            for (RecordType rt : [SELECT DeveloperName, Id FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName IN :prodToOpptyRTNameMap.values()])
                opptyRTMap.put(rt.DeveloperName, rt.Id);

            for (Object cs : crossSelling) {
                Map<String, Object> csMap = (Map<String, Object>) cs;
                Opportunity opp = new Opportunity();
                //SM - TEN: 395 Modifiche cross selling
                List<String> dateArr = new List<String>();
                if(csMap.get('closeDate') != null)
                    dateArr = ((String) csMap.get('closeDate')).split('-');
                String crossSellingBU = WizardOpportunityController.getBU(csMap);
                if (dateArr.size() == 3)
                    opp.CloseDate = Date.newInstance(Integer.valueOf(dateArr[0]), Integer.valueOf(dateArr[1]), Integer.valueOf(dateArr[2]));
                if (csMap.get('amount') != null) opp.Amount = Decimal.valueOf(String.valueOf(csMap.get('amount')));
                if (csMap.get('tipologia') != null) opp.WGC_Tipologia_CrossSelling__c = String.valueOf(csMap.get('tipologia'));
                if (csMap.get('business') != null) opp.WGC_Business_CrossSelling__c = String.valueOf(csMap.get('business'));
                if (csMap.get('ownershipSviluppo') != null) opp.WGC_CrossSelling_Ownership_Sviluppo__c = String.valueOf(csMap.get('ownershipSviluppo'));
                // CR Lotto 4.2 Id 157
                if (csMap.get('finalita_finance') != null) opp.WGC_Finalita_Finance__c = String.valueOf(csMap.get('finalita_finance'));
                prodToRemove.add( (String.valueOf(csMap.get('product'))).split('_')[1] );
                if (!String.isBlank(String.valueOf(csMap.get('referente')))) opp.WGC_Referente_CrossSelling__c = (Id) csMap.get('referente');
                if (!String.isBlank(String.valueOf(csMap.get('agente')))) opp.WGC_Agente_Segnalante__c = String.valueOf(csMap.get('agente'));
                opp.WGC_Note_CrossSelling__c = String.valueOf(csMap.get('note'));
                opp.WGC_Qualifica_Cliente_CrossSelling__c = currentOpp.Account.WGC_Qualifica_Corporate__c;
                opp.RecordTypeId = opptyRTMap.get(prodToOpptyRTNameMap.get(String.valueOf(csMap.get('product'))));
                opp.AccountId = accountId;
                opp.OwnerId = assegnatari.get(crossSellingBU);
                opp.WGC_Segnalatore_CrossSelling__c = UserInfo.getUserId();
				//A.M. SDHDFNZ-121813 Gestione mail responsabile per opp cross-selling
				User own = [SELECT Id, Manager.Email FROM User WHERE id = :opp.OwnerId];
		        opp.WGC_Email_Referente_Factoring_Anagrafica__c = own.Manager.Email;
                
				System.debug('@@@ prova 3 ' + ''+ String.valueOf(prodToOpptyRTNameMap.get(String.valueOf(csMap.get('product')))) + '' == RT_DEVNAME_FACTORING);
                opp.WGC_Prodotti_Selezionati__c = (String.valueOf(csMap.get('product'))).split('_')[1];
                opp.WGC_Prodotti_Cross_Selling_Selezionati__c = (String.valueOf(csMap.get('product'))).split('_')[1];
                if((String.valueOf(csMap.get('product'))).split('_')[0] == 'Factoring - Cedente' || (String.valueOf(csMap.get('product'))).split('_')[0] == 'Finanziamenti')
                    	factOpty.put((String.valueOf(csMap.get('product'))).split('_')[1], opp);
                //if (String.valueOf(prodToOpptyRTNameMap.get(String.valueOf(csMap.get('product')))) == RT_DEVNAME_FACTORING){
                    //if((String.valueOf(csMap.get('product'))).split('_')[1] == 'Mutuo' || (String.valueOf(csMap.get('product'))).split('_')[1] == 'Factoring' || (String.valueOf(csMap.get('product'))).split('_')[1] == 'Acquisto Titolo Definitivo' || (String.valueOf(csMap.get('product'))).split('_')[1] == 'Factoring MCC' || (String.valueOf(csMap.get('product'))).split('_')[1] == 'Anticipo Crediti Futuri')
                    //if((String.valueOf(csMap.get('product'))).split('_')[0] == 'Factoring - Cedente')
                    	//factOpty.put((String.valueOf(csMap.get('product'))).split('_')[1], opp);
                //}
                if((String.valueOf(csMap.get('product'))).split('_')[0] != 'Factoring - Cedente' && (String.valueOf(csMap.get('product'))).split('_')[0] != 'Finanziamenti')
                	csItems.add(opp);
            }
			
            if(!factOpty.values().isEmpty()){
                for(String optyProd : factOpty.keySet()){
                    if(factOpty.values().size() > 1){
                        factOpty.values().get(0).WGC_Prodotti_Selezionati__c += ';'+optyProd; 
                        factOpty.values().get(0).WGC_Prodotti_Cross_Selling_Selezionati__c += ';'+optyProd;
                    }
                }
                csItems.add(factOpty.values().get(0));
            }
            
            //SM-CART-REVI
            //if (pfi.size() == 0 && joinLineaAttore.size() == 0) { // INSERIMENTO DI MULTIPLI PRODOTTI (SINGOLO PRODOTTO) CROSS SELLING ( && csItems.size() == 1)
            if (pb.size() == 0 && pfi.size() == 0 && joinLineaAttore.size() == 0) { // INSERIMENTO DI MULTIPLI PRODOTTI (SINGOLO PRODOTTO) CROSS SELLING ( && csItems.size() == 1)
                List<Prodotto__c> pps = [SELECT Id, WGC_Tipo_Cross_Selling__c FROM Prodotto__c WHERE WGC_Famiglia__c IN :prodToRemove];
                Set<String> xsellingTypes = new Set<String>();

                for (Prodotto__c pp : pps)
                    xsellingTypes.add(pp.WGC_Tipo_Cross_Selling__c);

                // csItems[0].WGC_Prodotti_Selezionati__c = null;

                if (xsellingTypes.contains('IFISOpportunitaFinanzaStrutturata') && currUser.Qualifica_Utente__c == 'Finanza Strutturata') {
                    redirect = opportunityId;
                    for (Opportunity csi : csItems) {
                        csi.WGC_Cross_Selling_JSON__c = '[]';
                        if (csi.RecordTypeId == opptyRTMap.get('IFISOpportunitaFinanzaStrutturata')) {
                            csi.Id = opportunityId;
                            csi.Tipologia_Opportunit__c = 'CONC';
                        } else {
                            csi.Originator__c = 'Cross Selling';
                            csi.Originator_di_dettaglio__c = ((WGC_Originator__mdt) originators.get(currUser.Qualifica_Utente__c)).Originator_dettaglio__c;
                            csi.WGC_Forzatura__c = true;
                        }
                    }
                }
                else {
                    redirect = currentOpp.AccountId;
                    for (Opportunity csi : csItems) {
                        csi.Tipologia_Opportunit__c = 'CONC';
                        csi.Originator__c = 'Cross Selling';
                        csi.Originator_di_dettaglio__c = ((WGC_Originator__mdt) originators.get(currUser.Qualifica_Utente__c)).Originator_dettaglio__c;
                        csi.WGC_Forzatura__c = true;
                        csi.WGC_Descrizione_Operativit_Proposta__c = csi.WGC_Note_CrossSelling__c;
                        csi.WGC_Cross_Selling_JSON__c = '[]';
                    }
                    csItems[0].Id = opportunityId;
                }
                // redirect = (u.Qualifica_Utente__c == 'Sviluppo_Commerciale_Filiali' ? 'AUTOREDIRECT_ANAG' : 'RELOAD_OPPORTUNITY');;
            } else {
                Opportunity current = new Opportunity();
                List<String> prodSelezionati = currentOpp.WGC_Prodotti_Selezionati__c.split(';');

                for (String prSel : prodSelezionati){
                    if (!prodToRemove.contains(prSel)){
                        current.WGC_Prodotti_Selezionati__c = (current.WGC_Prodotti_Selezionati__c == null ? prSel : current.WGC_Prodotti_Selezionati__c + ';' + prSel);
                        current.WGC_Prodotti_Cross_Selling_Selezionati__c = (current.WGC_Prodotti_Cross_Selling_Selezionati__c == null ? prSel : current.WGC_Prodotti_Cross_Selling_Selezionati__c + ';' + prSel);
                    }
                }

                current.Id = opportunityId;
                current.Tipologia_Opportunit__c = 'CONC';
                current.Originator__c = 'Cross Selling';
                current.Originator_di_dettaglio__c = ((WGC_Originator__mdt) originators.get(currUser.Qualifica_Utente__c)).Originator_dettaglio__c;
                current.WGC_Forzatura__c = true;
                current.WGC_Descrizione_Operativit_Proposta__c = csItems[0].WGC_Note_CrossSelling__c;
                current.WGC_Cross_Selling_JSON__c = '[]';
                csItems.add(current);
            }

            System.debug('@@@ csItems ' + JSON.serialize(csItems));
            upsert csItems;

            List<WGC_Linea_Prodotto__c> reviLines = new List<WGC_Linea_Prodotto__c>([SELECT Id, Name, Anagrafica__c, Divisa__c, Codice_Linea_Sistema__c, Accordato__c, Data_Scadenza__c, Procedura_Semplificata__c, Linea_di_carico__c FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c =: currentOpp.AccountId AND ( Qualifica_Prodotto__c = 'Cliente attivo' OR Qualifica_Prodotto__c = 'Cliente inattivo' OR Qualifica_Prodotto__c = 'Cliente dormiente' OR Qualifica_Prodotto__c = 'Cliente in avvio' OR Qualifica_Prodotto__c = 'Cliente incerto') AND Codice_stato__c = '003']);

            if(!reviLines.isEmpty()){
                for(Opportunity o : csItems){
                    cloneOpportunity(new String[]{o.Id});
                }
            }
        }

        return redirect;
    }

    public static Map<String, Id> getCrossSellingAssegnatariPerBU(Id accountId) {
        Account acc = [SELECT Id, WGC_Specialista_Finanza_Strutturata__c, WGC_Specialista_Leasing__c, WGC_Specialista_Leasing_TR__c, WGC_Specialista_Factoring__c FROM Account WHERE Id = :accountId];
        Map<String, Id> referenti = new Map<String, Id>();
        Map<String, Id> assegnatari = new Map<String, Id>();

        for (WGC_ReferenteBU__mdt ref : [SELECT WGC_BU__c, WGC_Referente__c FROM WGC_ReferenteBU__mdt WHERE WGC_Ambito__c = 'Carrello'])
            referenti.put(ref.WGC_BU__c, ref.WGC_Referente__c);

        assegnatari.put('FACTORING', acc.WGC_Specialista_Factoring__c);

        assegnatari.put('FINANZA_STRUTTURATA', (acc.WGC_Specialista_Finanza_Strutturata__c == null ? referenti.get('FINANZA_STRUTTURATA') : acc.WGC_Specialista_Finanza_Strutturata__c));

        // assegnatari.put('LEASING_TR', (acc.WGC_Specialista_Leasing_TR__c == null ? referenti.get('LEASING_TR') : acc.WGC_Specialista_Leasing_TR__c));

        // assegnatari.put('LEASING_EF', (acc.WGC_Specialista_Leasing__c == null ? referenti.get('LEASING_EF') : acc.WGC_Specialista_Leasing__c));

        assegnatari.put('LEASING_TR', referenti.get('LEASING_TR'));

        assegnatari.put('LEASING_EF', referenti.get('LEASING_EF'));

        return assegnatari;
    }

    public static String getBU(Map<String, Object> csMap) { // VALUES: LEASING_TR, LEASING_EF, FACTORING, FINANZA_STRUTTURATA
        List<String> prodSplit = ((String) csMap.get('product')).split('_');
        String BU = '';
        
        switch on prodSplit[0] {
            when 'Leasing' {
                if ( ((String) csMap.get('tipologia')) == 'Leasing' )
                    BU = 'LEASING_TR';
                else if ( ((String) csMap.get('tipologia')) == 'Noleggio' )
                    BU = 'LEASING_EF';
            }
            when 'Factoring - Cedente', 'Finanziamenti', 'Servizi Bancari' {
                BU = 'FACTORING';
            }
            when 'Corporate Finance' { // Finanziamenti
                BU = 'FINANZA_STRUTTURATA';
            }
        }

        return BU;
    }

/* END - METODI DI GESTIONE CROSS SELLING */

/* GESTIONE DATI PEF (PEF39) */

    public class WrapperResponseWS {
        @AuraEnabled public String msg;
        @AuraEnabled public Boolean success;
        @AuraEnabled public Object data;

        public WrapperResponseWS() {
            msg = '';
            success = true;
        }
    }

    @AuraEnabled
    public static WrapperResponseWS loadDatiPEF(Id accountId, Id opportunityId){
        WrapperResponseWS resp = new WrapperResponseWS();
        Account acc = [SELECT Id, CodiceIstituto3N__c, NDGGruppo__c FROM Account WHERE Id = :accountId];
        //SM - CR 482 - Organo Deliberante/Data Delibera
        Opportunity opp = [SELECT Id, WGC_Codice_Pratica__c, WGC_Organo_Deliberante__c, WGC_Data_Delibera_PEF__c FROM Opportunity WHERE Id = :opportunityId];
        try {
            if (opp.WGC_Codice_Pratica__c == null) {
                resp.success = false;
                resp.msg = 'Codice pratica mancante.';
                return resp;
            }
            
            WGC_WSUtils_Cart.DatiPEFInput input = new WGC_WSUtils_Cart.DatiPEFInput();
            input.codNdg = Long.valueOf(acc.NDGGruppo__c);
            input.codiceIstituto3N = Integer.valueOf(acc.CodiceIstituto3N__c);
            input.codPratica = Integer.valueOf(opp.WGC_Codice_Pratica__c);
            WGC_WSUtils_Cart.DatiPEFResponse response = WGC_WSUtils_Cart.loadDatiPEF(input);
            Map<String, Object> respMap = new Map<String, Object>();
            respMap.put('response', response);
            respMap.put('factoringProducts', [SELECT Codice__c FROM Prodotto__c WHERE WGC_Area__c = 'Factoring - Cedente']); //  OR WGC_Area__c = 'Factoring - Fiscale'
            // respMap.put('linee', [SELECT Id, Importo__c, Prodotto__r.Codice__c FROM Linea__c WHERE Opportunity__c = :opportunityId]);
            // CR 273 - SVILUPPO POSTICIPATO IN L3.4 - L4.1
            respMap.put('linee', [SELECT Id, Importo__c, Prodotto__r.Codice__c, Stato__c, WGC_Deliberata__c, WGC_Non_Deliberata__c, WGC_Data_Delibera__c, WGC_Data_Declinazione__c, WGC_Data_Contratti_Pronti__c, WGC_FaseDiCaduta__c, WGC_DataFaseDiCaduta__c, WGC_Attivata__c, WGC_Data_Attivazione__c, WGC_Importo_Accordato__c FROM Linea__c WHERE Opportunity__c = :opportunityId]);
            respMap.put('importi', [SELECT Id, Linea__r.Prodotto__r.Codice__c, Valore__c, Codice__c FROM PConfigurato__c WHERE Linea__r.Opportunity__c = :opportunityId AND Codice__c = :CODICE_PARAMETRO_IMPORTO_LINEA]);

            //SM - TEN - CR Importo Accordato
            for(WGC_WsUtils_Cart.LineaCredito lc : response.payload.outputRichiesta.elencoLineeCredito){
                for(Linea__c l : (List<Linea__c>)respMap.get('linee')){
                    if(l.Prodotto__r.Codice__c == lc.codLineaSistema)
                        l.WGC_Importo_Accordato__c = lc.impAccordatoLinea;
						//A.M. SDHDFNZ-124486 - Aggiornamento anche dello stato della linea
						l.Stato__c = lc.codStatoLinea == COD_STATO_LINEA_DELIBERATA ? COD_LINEA_FIRMACONTRATTI : (lc.codStatoLinea == COD_STATO_LINEA_DECLINATA ? COD_LINEA_DECLINATA : VALUTAZ_PRATICA);
						System.debug('@@@@A.M. Linea Sistema: ' + lc.codLineaSistema + '-' + lc.codStatoLinea + ' -> linea CRM: ' + l.Prodotto__r.Codice__c + '-' + l.Stato__c);
				}
            }

            Update (List<Linea__c>)respMap.get('linee');
			//SM - CR 482 - Organo Deliberante/Data Delibera
			if (response.payload.outputRichiesta.datDelibera != null && response.payload.outputRichiesta.codRuoloDeliberante != null && response.payload.outputRichiesta.codRuoloDeliberante != ''){
               opp.WGC_Organo_Deliberante__c = response.payload.outputRichiesta.codRuoloDeliberante;
               opp.WGC_Data_Delibera_PEF__c = DateTime.newInstance(response.payload.outputRichiesta.datDelibera).date();
               //update opp;
			}
			//SDCHG-6051 - salvataggio dati PEF: campo stato pratica e tipo pratica 
			System.debug('@@@@A.M. Tipo e Stato Pratica: ' + response.payload.outputRichiesta.desTipoPratica + ' - ' + response.payload.outputRichiesta.desStatoPratica);
			if (response.payload.outputRichiesta.desStatoPratica != null && response.payload.outputRichiesta.desTipoPratica != null){
			   opp.BI_Stato_Pratica_PEF__c = response.payload.outputRichiesta.desStatoPratica;
			   opp.BI_Tipo_Pratica_PEF__c = response.payload.outputRichiesta.desTipoPratica;
               //update opp;
			}
			if (opp.WGC_Organo_Deliberante__c != null || opp.BI_Stato_Pratica_PEF__c != null || opp.BI_Tipo_Pratica_PEF__c != null){
               update opp;
			}

            resp.data = JSON.serialize(respMap);
        } catch (Exception e) {
            System.debug('@@@@ MB - TEN: ' + e.getMessage() + ' --- ' + e.getStackTraceString());
            resp.success = false;
            resp.msg = e.getMessage();
        }

        return resp;
    }

    public static WrapperResponseWs asyncLoadDatiPEF(Id accountId, Id opportunityId){
        WrapperResponseWS resp = new WrapperResponseWS();
        Account acc = [SELECT Id, CodiceIstituto3N__c, NDGGruppo__c FROM Account WHERE Id = :accountId];
        //SM - CR 482 - Organo Deliberante/Data Delibera
        Opportunity opp = [SELECT Id, WGC_Codice_Pratica__c, WGC_Organo_Deliberante__c, WGC_Data_Delibera_PEF__c FROM Opportunity WHERE Id = :opportunityId];
        // DO SOMETHING
        try {
            if (opp.WGC_Codice_Pratica__c == null) {
                resp.success = false;
                resp.msg = 'Codice pratica mancante.';
                return resp;
            }
            
            WGC_WSUtils_Cart.DatiPEFInput input = new WGC_WSUtils_Cart.DatiPEFInput();
            input.codNdg = Long.valueOf(acc.NDGGruppo__c);
            input.codiceIstituto3N = Integer.valueOf(acc.CodiceIstituto3N__c);
            input.codPratica = Integer.valueOf(opp.WGC_Codice_Pratica__c);
            WGC_WSUtils_Cart.DatiPEFResponse response = WGC_WSUtils_Cart.loadDatiPEF(input);

			Map<String, Object> respMap = new Map<String, Object>();
            respMap.put('response', response);
            respMap.put('factoringProducts', [SELECT Codice__c FROM Prodotto__c WHERE WGC_Area__c = 'Factoring - Cedente']); //  OR WGC_Area__c = 'Factoring - Fiscale'
 
            // CR 273 - SVILUPPO POSTICIPATO IN L3.4 - L4.1
            respMap.put('linee', [SELECT Id, Importo__c, Prodotto__r.Codice__c, Stato__c, WGC_Deliberata__c, WGC_Non_Deliberata__c, WGC_Data_Delibera__c, WGC_Data_Declinazione__c, WGC_Data_Contratti_Pronti__c, WGC_FaseDiCaduta__c, WGC_DataFaseDiCaduta__c, WGC_Attivata__c, WGC_Data_Attivazione__c, WGC_Importo_Accordato__c FROM Linea__c WHERE Opportunity__c = :opportunityId]);
            respMap.put('importi', [SELECT Id, Linea__r.Prodotto__r.Codice__c, Valore__c, Codice__c FROM PConfigurato__c WHERE Linea__r.Opportunity__c = :opportunityId AND Codice__c = :CODICE_PARAMETRO_IMPORTO_LINEA]);

			//SM - TEN - CR Importo Accordato
            for(WGC_WsUtils_Cart.LineaCredito lc : response.payload.outputRichiesta.elencoLineeCredito){
                for(Linea__c l : (List<Linea__c>)respMap.get('linee')){
                    if(l.Prodotto__r.Codice__c == lc.codLineaSistema)
                        l.WGC_Importo_Accordato__c = lc.impAccordatoLinea;
						//A.M. SDHDFNZ-124486 - Aggiornamento anche dello stato della linea
						l.Stato__c = lc.codStatoLinea == COD_STATO_LINEA_DELIBERATA ? COD_LINEA_FIRMACONTRATTI : (lc.codStatoLinea == COD_STATO_LINEA_DECLINATA ? COD_LINEA_DECLINATA : VALUTAZ_PRATICA);
						System.debug('@@@@A.M. Stato Linea Sistema: ' + lc.codStatoLinea + ' -> linea CRM: ' + l.Stato__c);
                }
            }
            Update (List<Linea__c>)respMap.get('linee');

            //SM - CR 482 - Organo Deliberante/Data Delibera
			if (response.payload.outputRichiesta.datDelibera != null && response.payload.outputRichiesta.codRuoloDeliberante != null && response.payload.outputRichiesta.codRuoloDeliberante != ''){
               opp.WGC_Organo_Deliberante__c = response.payload.outputRichiesta.codUtenteDeliberante;
               opp.WGC_Data_Delibera_PEF__c = DateTime.newInstance(response.payload.outputRichiesta.datDelibera).date();
               update opp;
			}

            resp.data = response;
        } catch (Exception e) {
            resp.success = false;
            resp.msg = e.getMessage();
        }

        return resp;
    }

    @AuraEnabled
    public static List<WGC_Chiusura_Linea__c> loadLineeChiuse(Id opportunityId) {
        List<WGC_Chiusura_Linea__c> lineeChiuse = new List<WGC_Chiusura_Linea__c>();

        lineeChiuse = [SELECT Id, CategoriaChiusuraTrattativa__c, Codice_Linea__c, Data_Chiusura_Linea__c, Fase__c, MotivoChiusuraTrattativa__c, Stato_PEF_pre_chiusura__c FROM WGC_Chiusura_Linea__c WHERE Opportunit__c = :opportunityId];

        return lineeChiuse;
    }

    @AuraEnabled
    public static WrapperResponseWs checkLinesCompleteness(String JSONlines, Id opportunityId) {
        WrapperResponseWS resp = new WrapperResponseWS();
        Opportunity opp = [SELECT Tipologia_Opportunit__c, WGC_Data_Delibera_PEF__c FROM Opportunity WHERE Id = :opportunityId];
        List<Linea__c> linesToUpdate = new List<Linea__c>();
        WGC_WSUtils_Cart.LineaCredito[] lines = (WGC_WSUtils_Cart.LineaCredito[]) JSON.deserialize(JSONlines, WGC_WSUtils_Cart.LineaCredito[].class);
        Set<String> lineeChiuse = U.getSet([SELECT Codice_Linea__c FROM WGC_Chiusura_Linea__c WHERE Opportunit__c = :opportunityId], 'Codice_Linea__c');
        
        try {
            Map<String, SObject> linesMap = U.keyBy([SELECT Id, Importo__c, Prodotto__r.Codice__c, Stato__c, WGC_Data_Delibera__c, WGC_Non_Deliberata__c, WGC_Deliberata__c, WGC_Data_Declinazione__c, WGC_Data_Contratti_Pronti__c FROM Linea__c WHERE Opportunity__c = :opportunityId], 'Prodotto__r.Codice__c');
            Set<String> prodCodes = linesMap.keySet();
            Map<String, Object> respData = new Map<String, Object>();
            
            for (WGC_WSUtils_Cart.LineaCredito l : lines) {
                if (prodCodes.contains(l.codLineaSistema) && !lineeChiuse.contains(String.valueOf(l.numLineaCredito)) && ( (opp.Tipologia_Opportunit__c == 'CONC' && l.codGestione == 'N') || (opp.Tipologia_Opportunit__c == 'REVI' && (l.codGestione == 'N' || l.codGestione == 'R')) )) {
                    if (l.codStatoLinea == COD_STATO_LINEA_DECLINATA && ((Linea__c) linesMap.get(l.codLineaSistema)).WGC_Non_Deliberata__c != true) {
                        ((Linea__c) linesMap.get(l.codLineaSistema)).WGC_Non_Deliberata__c = true;
						//A.M. SDHDFNZ-120376 AGGIORNAMENTO STATO - ERRORE non va messa la data odierna, ma uguale a opp.WGC_Data_Delibera_PEF__c 
                        //((Linea__c) linesMap.get(l.codLineaSistema)).WGC_Data_Declinazione__c = Date.today();
						((Linea__c) linesMap.get(l.codLineaSistema)).WGC_Data_Declinazione__c = Date.valueOf(opp.WGC_Data_Delibera_PEF__c);
						((Linea__c) linesMap.get(l.codLineaSistema)).Stato__c = COD_LINEA_DECLINATA;
                        linesToUpdate.add((Linea__c) linesMap.get(l.codLineaSistema));
                    } else if (l.codStatoLinea == COD_STATO_LINEA_DELIBERATA && ((Linea__c) linesMap.get(l.codLineaSistema)).WGC_Deliberata__c != true) {
                        ((Linea__c) linesMap.get(l.codLineaSistema)).WGC_Deliberata__c = true;
						//A.M. SDHDFNZ-120376 AGGIORNAMENTO STATO - ERRORE non data odierna, ma data delibera e aggirnamento Stato linea
                        //((Linea__c) linesMap.get(l.codLineaSistema)).WGC_Data_Delibera__c = Date.today();
						((Linea__c) linesMap.get(l.codLineaSistema)).WGC_Data_Delibera__c = Date.valueOf(opp.WGC_Data_Delibera_PEF__c);
						((Linea__c) linesMap.get(l.codLineaSistema)).Stato__c = COD_LINEA_FIRMACONTRATTI;
                        linesToUpdate.add((Linea__c) linesMap.get(l.codLineaSistema));
                    }
                }
            }

            if (linesToUpdate.size() > 0) {
                update linesToUpdate;

                respData.put('linee', (Object)linesMap.values());
                resp.data = JSON.serialize(respData);
                
                if (RestStatoOpportunita.checkAllLinesCompleted(opportunityId)) {
                    opp.StageName = 'Perfezionamento Contratto';
                    update opp;
                    
                    respData.put('opportunity', (Object)opp);
                    resp.data = JSON.serialize(respData);
                } else if (RestStatoOpportunita.checkAllLinesDeclined(opportunityId)) {
					//A.M. SDHDFNZ-125248 -> Se tutte le linee sono declinate (per le revisioni non arriva la chiamata inbound di PEF DECLINATA)
                    opp.StageName = 'Persa';
                    update opp;
                    
                    respData.put('opportunity', (Object)opp);
                    resp.data = JSON.serialize(respData);
                }

				System.debug('@@@@A.M. checkLinesCompleteness - StageName: ' + opp.StageName);
            }
            // codStatoLinea = '002'
            // codGestione = 'N'
            resp.success = true;
        } catch (Exception e) {
            System.debug('@@@@ MB - TEN: checkLinesCompleteness ERROR --> ' + e.getMessage() + ' ---- ' + e.getStackTraceString());
            resp.success = false;
            resp.msg = e.getMessage() + ' ---- ' + e.getStackTraceString();
        }

        return resp;
    }

    @AuraEnabled
    public static Boolean updateLinesAfterClosing(String lineId, String faseDiCaduta, WGC_Chiusura_Linea__c chiusuraLinea) {
        try {
            Linea__c l = new Linea__c();
            l.Id = lineId;
            l.WGC_Non_Deliberata__c = true;
            l.WGC_FaseDiCaduta__c = faseDiCaduta;
            l.WGC_DataFaseDiCaduta__c = Date.today();
            update l;
            insert chiusuraLinea;
            return true;
        } catch (Exception e) {
            System.debug('@@@@ MB - TEN: error updateLinesAfterClosing -- ' + e.getMessage() + ' --- ' + e.getStackTraceString());
            return false;
        }
    }

/* END - GESTIONE DATI PEF (PEF39) */

/* GESTIONE REVISIONE (PEF38) */

    @AuraEnabled
    public static WrapperResponseWS pef38(Integer numLinea, Id accountId) {
        WrapperResponseWS resp = new WrapperResponseWS();
        Account acc = [SELECT Id, CodiceIstituto3N__c, NDGGruppo__c FROM Account WHERE Id = :accountId];
        
        try {
            WGC_WSUtils_Cart.PEF38Input input = new WGC_WSUtils_Cart.PEF38Input();
            input.codNdg = Long.valueOf(acc.NDGGruppo__c);
            input.codiceIstituto3N = Integer.valueOf(acc.CodiceIstituto3N__c);
            input.numLineaCredito = numLinea;
            WGC_WSUtils_Cart.DatiPEFResponse38 response = WGC_WSUtils_Cart.loadPEF38(input);

            resp.data = JSON.serialize(response);
        } catch (Exception e) {
            resp.success = false;
            resp.msg = e.getMessage();
        }
        
        return resp;
    }

    @AuraEnabled
    public static WrapperResponse getRevisionedParameters(String lineId) {
        WrapperResponse resp = new WrapperResponse();
        List<Linea__c> lines = new List<Linea__c>();
        lines = [SELECT Id, WGC_Numero_Linea_Credito__c, Opportunity__c, Opportunity__r.Account.CodiceIstituto3N__c, Opportunity__r.Account.NDGGruppo__c FROM Linea__c WHERE Id = :lineId];
        Linea__c line = lines.size() > 0 ? lines[0] : new Linea__c();
        
        try {
            WGC_WSUtils_Cart.PEF38Input input = new WGC_WSUtils_Cart.PEF38Input();
            input.codNdg = Long.valueOf(line.Opportunity__r.Account.NDGGruppo__c);
            // input.codNdg = 125067;
            input.codiceIstituto3N = Integer.valueOf(line.Opportunity__r.Account.CodiceIstituto3N__c);
            input.numLineaCredito = Integer.valueOf(line.WGC_Numero_Linea_Credito__c);
            // input.numLineaCredito = 2286913;
            WGC_WSUtils_Cart.DatiPEFResponse38 response = WGC_WSUtils_Cart.loadPEF38(input);

            WizardOpportunityController.manageAndInsertRevisionedParameters(response, line);

            resp.data = CtrlWizardOpportunity.editRsf(line.Opportunity__c);
        } catch (Exception e) {
            resp.success = false;
            resp.msg = e.getMessage();
        }
        
        return resp;
    }

    public static void manageAndInsertRevisionedParameters(WGC_WSUtils_Cart.DatiPEFResponse38 output, Linea__c line) {
        List<PConfigurato__c> paramsToInsert = new List<PConfigurato__c>();
        List<NDGLinea__c> attori = [SELECT Id, NDG__c FROM NDGLinea__c WHERE Opportunita__c = :line.Opportunity__c];
        List<WGC_Fido_di_Coppia__c> fidiDiCoppia = [SELECT Id, NDG_Debitore__c, Termini_di_pagamento__c, Importo_Plafond_Prosoluto__c, Importo_Plafond_Prosolvendo__c FROM WGC_Fido_di_Coppia__c WHERE Linea__r.Name = :line.WGC_Numero_Linea_Credito__c AND NDG_Debitore__c IN :U.getSet(attori, 'NDG__c')];
        Map<String, Id> attoriMap = new Map<String, Id>();
        Set<String> fixedValueParams = getFixedValuesParameters();
        System.debug('@@@@ MB - TEN: fixedValueParams -- ' + fixedValueParams);
        
        for (NDGLinea__c att : attori)
            if (att.NDG__c != '' && att.NDG__c != null)
                attoriMap.put(att.NDG__c, att.Id);
        
        System.debug('@@@@ MB - TEN: elencoParametriLinea -- ' + output.payload.outputRichiesta.elencoParametriLinea);
        if (output.payload.outputRichiesta.elencoParametriLinea.size() > 0)
            WizardOpportunityController.populateParamsByWrapper(paramsToInsert, line.Id, attoriMap, output.payload.outputRichiesta.elencoParametriLinea, fixedValueParams);
        System.debug('@@@@ MB - TEN: elencoParametriDerogati -- ' + output.payload.outputRichiesta.elencoParametriDerogati);
        if (output.payload.outputRichiesta.elencoParametriDerogati.size() > 0)
            WizardOpportunityController.populateParamsByWrapper(paramsToInsert, line.Id, attoriMap, output.payload.outputRichiesta.elencoParametriDerogati, fixedValueParams);
        System.debug('@@@@ MB - TEN: elencoCondizioniLinea -- ' + output.payload.outputRichiesta.elencoCondizioniLinea);
        if (output.payload.outputRichiesta.elencoCondizioniLinea.size() > 0)
            WizardOpportunityController.populateParamsByWrapper(paramsToInsert, line.Id, attoriMap, output.payload.outputRichiesta.elencoCondizioniLinea, fixedValueParams);
        System.debug('@@@@ MB - TEN: elencoCondizioniDerogate -- ' + output.payload.outputRichiesta.elencoCondizioniDerogate);
        if (output.payload.outputRichiesta.elencoCondizioniDerogate.size() > 0)
            WizardOpportunityController.populateParamsByWrapper(paramsToInsert, line.Id, attoriMap, output.payload.outputRichiesta.elencoCondizioniDerogate, fixedValueParams);
        System.debug('@@@@ MB - TEN: elencoConti -- ' + output.payload.outputRichiesta.elencoConti);
        if (output.payload.outputRichiesta.elencoConti.size() > 0) {
            for (WGC_WSUtils_Cart.ElencoConti conto : output.payload.outputRichiesta.elencoConti)
                WizardOpportunityController.populateParamsByWrapper(paramsToInsert, line.Id, attoriMap, conto.elencoCondizioniConto, fixedValueParams);
        }

        WizardOpportunityController.populateSFParams(paramsToInsert, line.Id, attoriMap, output.payload.outputRichiesta);

        WizardOpportunityController.populateFDCParams(paramsToInsert, line.Id, attoriMap, fidiDiCoppia);
        
        System.debug('@@@ paramsToInsert ' + JSON.serialize(paramsToInsert));
        insert paramsToInsert;
    }

    public static void populateParamsByWrapper(List<PConfigurato__c> paramsToInsert, Id lineId, Map<String, Id> attoriMap, WGC_WSUtils_Cart.ElencoParametriLinea[] parameters) {
        populateParamsByWrapper(paramsToInsert, lineId, attoriMap, parameters, new Set<String>());
    }
    public static void populateParamsByWrapper(List<PConfigurato__c> paramsToInsert, Id lineId, Map<String, Id> attoriMap, WGC_WSUtils_Cart.ElencoParametriLinea[] parameters, Set<String> fixedValueParams) {
        for (WGC_WSUtils_Cart.ElencoParametriLinea p : parameters) {
            String valParaToInsert = '';
            String prgvalParaToInsert = '';
            for (WGC_WSUtils_Cart.ElencoValoriParametro valPara : p.elencoValoriParametro) {
                valParaToInsert += (valParaToInsert == '' ? valPara.valParametro : ';' + valPara.valParametro);
                prgvalParaToInsert += (prgvalParaToInsert == '' ? valPara.prgvalPara + ':' + valPara.valParametro : ';' + valPara.prgvalPara + ':' + valPara.valParametro);
            }
            
            paramsToInsert.add(populateParams(lineId, p.codParametro, valParaToInsert, null, prgvalParaToInsert, fixedValueParams.contains(p.codParametro)));
        }
    }
    public static void populateParamsByWrapper(List<PConfigurato__c> paramsToInsert, Id lineId, Map<String, Id> attoriMap, WGC_WSUtils_Cart.ElencoParametriDerogati[] parameters) {
        populateParamsByWrapper(paramsToInsert, lineId, attoriMap, parameters, new Set<String>());
    }
    public static void populateParamsByWrapper(List<PConfigurato__c> paramsToInsert, Id lineId, Map<String, Id> attoriMap, WGC_WSUtils_Cart.ElencoParametriDerogati[] parameters, Set<String> fixedValueParams) {
        for (WGC_WSUtils_Cart.ElencoParametriDerogati p : parameters) {
            if (p.codtipoCoppia == 'C' && p.codCarTecn == 'N') {
                String valParaToInsert = '';
                String prgvalParaToInsert = '';
                for (WGC_WSUtils_Cart.ElencoValoriParametro valPara : p.elencoValoriParametro) {
                    valParaToInsert += (valParaToInsert == '' ? valPara.valParametro : ';' + valPara.valParametro);
                    prgvalParaToInsert += (prgvalParaToInsert == '' ? valPara.prgvalPara + ':' + valPara.valParametro : ';' + valPara.prgvalPara + ':' + valPara.valParametro);
                }

                paramsToInsert.add(populateParams(lineId, p.codParametro, valParaToInsert, attoriMap.get(p.codNdgDebitore), prgvalParaToInsert, fixedValueParams.contains(p.codParametro)));
            }
        }
    }
    public static void populateParamsByWrapper(List<PConfigurato__c> paramsToInsert, Id lineId, Map<String, Id> attoriMap, WGC_WSUtils_Cart.ElencoCondizioniLinea[] parameters) {
        populateParamsByWrapper(paramsToInsert, lineId, attoriMap, parameters, new Set<String>());
    }
    public static void populateParamsByWrapper(List<PConfigurato__c> paramsToInsert, Id lineId, Map<String, Id> attoriMap, WGC_WSUtils_Cart.ElencoCondizioniLinea[] parameters, Set<String> fixedValueParams) {
        for (WGC_WSUtils_Cart.ElencoCondizioniLinea p : parameters)
            if (p.codCondizione != 'C165')
                paramsToInsert.add(populateParams(lineId, p.codCondizione, p.attributiCondizione.elencoScaglioni[0].valCondizione, null, fixedValueParams.contains(p.codCondizione)));
            else
                for (WGC_WSUtils_Cart.ElencoScaglioni scag : p.attributiCondizione.elencoScaglioni) 
                    if (scag.valInizScaglione != '0')
                        paramsToInsert.add(populateParams(lineId, p.codCondizione, scag.valCondizione, null));
    }
    public static void populateParamsByWrapper(List<PConfigurato__c> paramsToInsert, Id lineId, Map<String, Id> attoriMap, WGC_WSUtils_Cart.ElencoCondizioniDerogate[] parameters) {
        populateParamsByWrapper(paramsToInsert, lineId, attoriMap, parameters, new Set<String>());
    }
    public static void populateParamsByWrapper(List<PConfigurato__c> paramsToInsert, Id lineId, Map<String, Id> attoriMap, WGC_WSUtils_Cart.ElencoCondizioniDerogate[] parameters, Set<String> fixedValueParams) {
        for (WGC_WSUtils_Cart.ElencoCondizioniDerogate p : parameters)
            paramsToInsert.add(populateParams(lineId, p.codCondizione, p.elencoScaglioni[0].valCondizione, attoriMap.get(p.codNdgDebitore), fixedValueParams.contains(p.codCondizione)));
    }

    // METHOD TO POPULATE FIDO DI COPPIA PARAMS, RETRIEVED FROM FIDO DI COPPIA OBJECT
    public static void populateFDCParams(List<PConfigurato__c> paramsToInsert, Id lineId, Map<String, Id> attoriMap, List<WGC_Fido_di_Coppia__c> fidiDiCoppia) {
        Map<String, Object> fdcPerDeb = U.keyBy(fidiDiCoppia, 'NDG_Debitore__c');

        for (String ndgDeb : fdcPerDeb.keySet()) {
            paramsToInsert.add(populateParams(lineId, '008', String.valueOf(((WGC_Fido_di_Coppia__c)fdcPerDeb.get(ndgDeb)).Termini_di_pagamento__c), attoriMap.get(ndgDeb)));
            paramsToInsert.add(populateParams(lineId, 'SF25', String.valueOf(((WGC_Fido_di_Coppia__c)fdcPerDeb.get(ndgDeb)).Importo_Plafond_Prosolvendo__c), attoriMap.get(ndgDeb)));
            paramsToInsert.add(populateParams(lineId, 'SF26', String.valueOf(((WGC_Fido_di_Coppia__c)fdcPerDeb.get(ndgDeb)).Importo_Plafond_Prosoluto__c), attoriMap.get(ndgDeb)));
        }
    }

    // METHOD TO POPULATE SF PARAMS, CALCULATED FROM THE VALUES OF THE OTHER PARAMETERS
    public static void populateSFParams(List<PConfigurato__c> paramsToInsert, Id lineId, Map<String, Id> attoriMap, WGC_WSUtils_Cart.OutputRichiestaWrapper38 outputRichiesta) {
        String SF6;
        String SF14;
        String SF16;
        String SF18;
        List<String> SF7_perAttore = new List<String>();
        List<String> SF8_perAttore = new List<String>();
        List<String> SF13_perAttore = new List<String>();
        List<String> SF1_perAttore = new List<String>();
        List<String> SF2_perAttore = new List<String>();
        List<String> SF3_perAttore = new List<String>();
        for (PConfigurato__c p : paramsToInsert) {
            if (outputRichiesta.impAccordato != null)
                SF6 = String.valueOf(outputRichiesta.impAccordato);
            if (p.Codice__c == '026' && p.Valore__c != null)
                SF7_perAttore.add(attoriMap.get(p.Attore__c) + '_true');
            if (p.Codice__c == '027' && p.Valore__c != null)
                SF8_perAttore.add(attoriMap.get(p.Attore__c) + '_true');
            if (p.Codice__c == 'C163' || p.Codice__c == 'C102')
                SF13_perAttore.add(attoriMap.get(p.Attore__c) + '_' + (p.Codice__c == 'C163' && p.Valore__c != null ? 'Mensile' : (p.Valore__c != null ? 'Flat' : null)));
            if (p.Codice__c == 'C166' || p.Codice__c == 'C167')
                SF14 = (p.Codice__c == 'C167' && p.Valore__c != null && p.Valore__c != '0' ? 'Mensile' : (p.Valore__c != null && p.Valore__c != '0' ? 'Flat' : null));
            if (p.Codice__c == 'D104' || p.Codice__c == 'D163')
                SF18 = (p.Codice__c == 'D163' && p.Valore__c != null && p.Valore__c != '0' ? 'Mensile' : (p.Valore__c != null && p.Valore__c != '0' ? 'Flat' : null));
            if (p.Codice__c == '039' && p.Valore__c != null) {
                SF2_perAttore.add(attoriMap.get(p.Attore__c) + (p.Valore__c != '/' ? '_true' : '_false'));
                if (p.Valore__c != '/')
                    SF1_perAttore.add(attoriMap.get(p.Attore__c) + '_true');
            }
            if (p.Codice__c == '092' && p.Valore__c != null) {
                SF3_perAttore.add(attoriMap.get(p.Attore__c) + (p.Valore__c != '/' ? '_true' : '_false'));
                if (p.Valore__c != '/')
                    SF1_perAttore.add(attoriMap.get(p.Attore__c) + '_true');
            }
                
            for (WGC_WSUtils_Cart.ElencoConti conto : outputRichiesta.elencoConti) 
                for (WGC_WSUtils_Cart.ElencoCondizioniLinea cond : conto.elencoCondizioniConto)
                    for (WGC_WSUtils_Cart.ElencoScaglioni scag : cond.attributiCondizione.elencoScaglioni) 
                        if (scag.valInizScaglione == '0')
                            SF16 = scag.valFineScaglione;
        }

        // CICLO DUPLICATO PER GESTIRE IL PARAMETRO SF1, CHE SI BASA SUI VALORI DEI PARAMETRI SF2 E SF3
        for (PConfigurato__c p : paramsToInsert) {
            if (!SF1_perAttore.contains(attoriMap.get(p.Attore__c) + '_true') && !SF1_perAttore.contains(attoriMap.get(p.Attore__c) + '_false'))
                SF1_perAttore.add(attoriMap.get(p.Attore__c) + '_false');
        }
        
        if (SF6 != null)
            paramsToInsert.add(populateParams(lineId, 'SF6', SF6, null));
        // FORZATURA SU PARAMETRO SF14 PER EVITARE IL BLOCCO DELLA COMPILAZIONE
        paramsToInsert.add(populateParams(lineId, 'SF14', (SF14 != '' && SF14 != null ? SF14 : 'Mensile'), null));
        if (SF16 != null)
            paramsToInsert.add(populateParams(lineId, 'SF16', SF16, null));
        // FORZATURA SU PARAMETRO SF18 PER EVITARE IL BLOCCO DELLA COMPILAZIONE
        paramsToInsert.add(populateParams(lineId, 'SF18', (SF18 != '' && SF18 != null ? SF18 : 'Mensile'), null));
        for (String tmp : SF1_perAttore)
            paramsToInsert.add(populateParams(lineId, 'SF1', tmp.split('_')[1], (tmp.split('_')[0] != 'null' ? tmp.split('_')[0] : null)));
        for (String tmp : SF2_perAttore)
            paramsToInsert.add(populateParams(lineId, 'SF2', tmp.split('_')[1], (tmp.split('_')[0] != 'null' ? tmp.split('_')[0] : null)));
        for (String tmp : SF3_perAttore)
            paramsToInsert.add(populateParams(lineId, 'SF3', tmp.split('_')[1], (tmp.split('_')[0] != 'null' ? tmp.split('_')[0] : null)));
        for (String tmp : SF7_perAttore)
            paramsToInsert.add(populateParams(lineId, 'SF7', tmp.split('_')[1], (tmp.split('_')[0] != 'null' ? tmp.split('_')[0] : null)));
        for (String tmp : SF8_perAttore)
            paramsToInsert.add(populateParams(lineId, 'SF8', tmp.split('_')[1], (tmp.split('_')[0] != 'null' ? tmp.split('_')[0] : null)));
        for (String tmp : SF13_perAttore)
            paramsToInsert.add(populateParams(lineId, 'SF13', tmp.split('_')[1], (tmp.split('_')[0] != 'null' ? tmp.split('_')[0] : null)));

        // PARAMETRI SENZA MAPPING, VALORIZZATI PER EVITARE IL BLOCCO DELLA COMPILAZIONE 
        paramsToInsert.add(populateParams(lineId, 'SF13', 'FALSE', null));
    }

    public static PConfigurato__c populateParams(Id lineId, String codice, String valore, String attore) {
        return populateParams(lineId, codice, valore, attore, '');
    }
    public static PConfigurato__c populateParams(Id lineId, String codice, String valore, String attore, Boolean isFixedValue) {
        return populateParams(lineId, codice, valore, attore, '', isFixedValue);
    }
    public static PConfigurato__c populateParams(Id lineId, String codice, String valore, String attore, String prgvalPara) {
        return populateParams(lineId, codice, valore, attore, '', false);
    }
    public static PConfigurato__c populateParams(Id lineId, String codice, String valore, String attore, String prgvalPara, Boolean isFixedValue) {
        PConfigurato__c newParam = new PConfigurato__c();
        newParam.Linea__c = lineId;
        newParam.Codice__c = codice;
        newParam.Valore__c = valore;
        newParam.WGC_Valore_Pef_38__c = valore;
        newParam.WGC_Valore_Prg_Pef_38__c = prgvalPara;
        newParam.Attore__c = attore;
        newParam.WGC_IsFixedValue__c = isFixedValue;

        return newParam;
    }

    public static Set<String> getFixedValuesParameters() {
        return U.getSet([SELECT Label FROM WGC_Parametri_Fissi__mdt], 'Label');
        // return new Set<String>{'C451','C453'};
    }

/* END - GESTIONE REVISIONE (PEF38) */

    @AuraEnabled
    public static Boolean upsertNote(String field_apiname, String value, String opportunityId){
        Opportunity opp = new Opportunity();

        opp.put(field_apiname, value);
        opp.put('Id', opportunityId);
        upsert opp;

        return true;
    }

    @AuraEnabled
    public static Map<String, List<AccountContactRelation>> getTitolariEsecutori(Id accountId){
        Map<String, List<AccountContactRelation>> retMap = new Map<String, List<AccountContactRelation>>();
        List<AccountContactRelation> acr = [SELECT Id, Contact.Name, Contact.WGC_Censimento_MAV__c, WGC_Selezionato__c, WGC_Ruolo_Pratica__c, WGC_Tipologia_Titolare_Effettivo__c, WGC_Esecutore_MAV__c, WGC_Effettivo_MAV__c FROM AccountContactRelation WHERE AccountId = :accountId AND WGC_Selezionato__c = true];

        retMap.put('titeff', new List<AccountContactRelation>());
        retMap.put('esec', new List<AccountContactRelation>());

        for (AccountContactRelation tmp_acr : acr) {
            if (tmp_acr.WGC_Ruolo_Pratica__c != null) {
                // List<String> roles = tmp_acr.WGC_Ruolo_Pratica__c.split(';');
                List<AccountContactRelation> titeff = retMap.get('titeff');
                List<AccountContactRelation> esec = retMap.get('esec');
                
                if (tmp_acr.WGC_Effettivo_MAV__c == true) {
                    titeff.add(tmp_acr);
                    retMap.put('titeff', titeff);
                }
                if (tmp_acr.WGC_Esecutore_MAV__c == true) {
                    esec.add(tmp_acr);
                    retMap.put('esec', esec);
                }
            }
        }

        return retMap;
    }

    @AuraEnabled
    public static List<AccountContactRelation> getReferenti(Id accountId){
        return [SELECT Id, Contact.Id, Contact.Name FROM AccountContactRelation WHERE AccountId = :accountId AND Contact.NDGGruppo__c != null];
    }

    @AuraEnabled
    public static String updateNote(String field, Object value, Id objectId){
        return updateField(field, value, objectId);
    }

    @AuraEnabled
    public static String updateField(String field, Object value, Id objectId){
        System.debug('@@@@ field: ' + field);
        System.debug('@@@@ value: ' + value);
        System.debug('@@@@ objectId: ' + objectId);
        System.debug('@@@@ objectId.getSObjectType(): ' + objectId.getSObjectType());
        SObject obj = objectId.getSObjectType().newSObject(objectId);
        // obj.put('Id', objectId);
        obj.put(field, value);

        try {
            update obj;
            return null;
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static Boolean checkExistingPlafond(String opportunityId) {
        String ndg = [SELECT Account.NDGGruppo__c FROM Opportunity WHERE Id = :opportunityId LIMIT 1].get(0).Account.NDGGruppo__c;
        return ([SELECT Id FROM WGC_Linea_Prodotto__c WHERE Famiglia_Prodotto__c = 'PFD' and Codice_Stato__c = '003' AND Anagrafica__r.NDGGruppo__c = :ndg].size() > 0);
    }

    // Modificato per CR Lotto 4.2 Id 315
    @AuraEnabled
    public static Map<String,Boolean> getEsclusione(String ateco) {
        List<Ateco__c> atecos = new List<Ateco__c>([SELECT Id, Cedacri__c, WGC_Esclusione_BEI__c, WGC_Esclusione_Fondo__c FROM Ateco__c WHERE Cedacri__c = :ateco LIMIT 1]);
        Map<String,Boolean> esclusioni = new Map<String,Boolean>();

        if (atecos.size() > 0) {
            Ateco__c a = atecos[0];
            esclusioni.put('esclusioneBEI', a.WGC_Esclusione_BEI__c);
            esclusioni.put('esclusionePolizzaCPI', a.WGC_Esclusione_Fondo__c);
            return esclusioni;
        } else {
            return null;
        }
    }

/* METODI PER GESTIONE GARANTI E GARANZIE */

    @AuraEnabled
    public static String loadGaranziaData(){
        Map<String, Object> result = new Map<String, Object>();
        List<MatriceGaranzie__mdt> matriceGaranzie = CtrlWizardOpportunity.getGaranzie();

        result.put('matriceGaranzie', matriceGaranzie); // custom metadata
        result.put('divise', WizardOpportunityController.getPicklistValues('Garanzia__c', 'DivisaNew__c', false));

        return JSON.serialize(result);
    }

    @AuraEnabled
    public static Map<String, Object> getGarantiEGaranzie(String opportunityId){
        Map<String, Object> resp = new Map<String, Object>();

        try {
            Map<String, Object> wrapperMap = new Map<String, Object>();
            // List<Garanzia> garanzie = new List<Garanzia>();
            // List<Garante> garanti = new List<Garante>();

            // for (Garanzia__c g : [SELECT Id, IdEsterno__c,CodiceGaranzia__c, DivisaNew__c, Importo__c, Linea__c, Opportunita__c, Tipo__c FROM Garanzia__c WHERE Opportunita__c = :opportunityId]) {
            //     Garanzia tmp_g = new Garanzia();
            //     tmp_g.tipologia = g.CodiceGaranzia__c;
            //     tmp_g.idEsterno = g.IdEsterno__c;
            //     tmp_g.divisa = g.DivisaNew__c;
            //     tmp_g.importo = g.Importo__c;
            //     tmp_g.linea = g.Linea__c;
            //     tmp_g.opportunita = g.Opportunita__c;
            //     tmp_g.copertura = g.Tipo__c;
            //     garanzie.add(tmp_g);
            // }
            
            // for (NDGLinea__c g : [SELECT Id, Account__r.Name, Contact__r.Name, Opportunita__c, Account__r.NDGGruppo__c, Contact__r.NDGGruppo__c FROM NDGLinea__c WHERE Tipo__c = 'Garante' AND Opportunita__c = :opportunityId]) {
            //     Garante tmp_g = new Garante();
            //     tmp_g.id = g.Id;
            //     tmp_g.nome = (g.Account__r.Name == null ? g.Contact__r.Name : g.Account__r.Name);
            //     tmp_g.ndg = (g.Account__r.NDGGruppo__c == null ? g.Contact__r.NDGGruppo__c : g.Account__r.NDGGruppo__c);
            //     tmp_g.opportunita = g.Opportunita__c;
            //     garanti.add(tmp_g);
            // }

            // wrapperMap.put('garanzie', garanzie);
            wrapperMap.put('garanzie', [SELECT Id, IdEsterno__c, CodiceGaranzia__c, DivisaNew__c, Importo__c, Linea__c, Opportunita__c, Tipo__c, PercentualeGaranziaImporto__c FROM Garanzia__c WHERE Opportunita__c = :opportunityId]);
            // wrapperMap.put('garanti', garanti);
            wrapperMap.put('garanti', [SELECT Id, Nome__c, NDG__c, TipoGarante__c FROM NDGLinea__c WHERE Tipo__c = 'Garante' AND Opportunita__c = :opportunityId]);

            resp.put('success', true);
            resp.put('data', wrapperMap);
        } catch (Exception e) {
            resp.put('success', false);
            resp.put('msg', e.getMessage());
        }

        return resp;
    }

    @AuraEnabled
    public static Garanzia__c saveGaranzia(Map<String, Object> garanzia){
        Garanzia__c g = new Garanzia__c();

        try {
            g.DivisaNew__c = (String) garanzia.get('divisa');
            if (garanzia.get('importo') != null)
                g.Importo__c = Decimal.valueOf(String.valueOf(garanzia.get('importo')));
            if (garanzia.get('linea') != null && garanzia.get('linea') != '')
                g.Linea__c = (Id) garanzia.get('linea');
            g.Opportunita__c = (Id) garanzia.get('opportunita');
            g.Tipo__c = (String) garanzia.get('copertura');
            g.CodiceGaranzia__c = (String) garanzia.get('tipologia');
            if (garanzia.get('percentualeImporto') != null)
                g.PercentualeGaranziaImporto__c = Decimal.valueOf((String) garanzia.get('percentualeImporto'));
            if (garanzia.get('idEsterno') == null)
                manageGaranzieFakeIds(g);
            else
                g.IdEsterno__c = (String) garanzia.get('idEsterno');
            System.debug('@@@@ Garanzia: ' + g);
            return (CtrlWizardOpportunity.saveGaranzia(g) ? g : null);
        } catch (Exception e) {
            System.debug('@@@@ TEN - ERRORE NEL SALVATAGGIO DELLA GARANZIA: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static WrapperResponseWS saveGarante(Id garanteId, Id opportunityId, String garanzia){
        WrapperResponseWS response = new WrapperResponseWS();
        
        try {
            response.data = CtrlWizardOpportunity.saveGarante(garanteId, opportunityId);
        } catch (Exception e) {
            response.msg = e.getMessage();
            response.success = false;
        }

        return response;
    }
    
    @AuraEnabled
    public static WrapperResponseWS saveGaranteDefault(Garanzia__c garanzia, Id opportunityId){
        WrapperResponseWS response = new WrapperResponseWS();
        Linea__c lineaGaranzia = [SELECT Id, Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Id =: garanzia.Linea__c];
        List<JoinGaranteGaranzia__c> jGG = new List<JoinGaranteGaranzia__c>([SELECT Id FROM JoinGaranteGaranzia__c WHERE Garanzia__r.Linea__c =: garanzia.Linea__c AND Garante__r.Account__r.NDGGruppo__c =: NDG_CONTROGARANTITO_UNICREDIT  ]);
        try {
            if(lineaGaranzia.Prodotto__r.CodiceUnivoco__c == COD_MUTUO_CONTROGARANTITO && jGG.size() == 1){
                response.data = saveGaranteDefaultMutuoControgarantito(garanzia, opportunityId);
            } else {
                response.data = CtrlWizardOpportunity.saveGaranteDefault(garanzia, opportunityId);
            }
        } catch (Exception e) {
            response.msg = e.getMessage();
            response.success = false;
        }

        return response;
    }

    // Mutui controgarantiti
    @AuraEnabled
    public static List<NDGLinea__c> saveGaranteDefaultMutuoControgarantito(Garanzia__c garanzia, Id opportunityId){
        List<NDGLinea__c> garanti = new List<NDGLinea__c>();
        MatriceGaranzie__mdt matrGara = [SELECT CodiceKnet__c, Tipo__c, ProdottiGaranteDefault__c FROM MatriceGaranzie__mdt WHERE CodiceKnet__c = :garanzia.CodiceGaranzia__c];
        //linee per le quali deve scattare la logica
        if(matrGara.Tipo__c == 'Percentuale'){
            Set<String> prodottiConGaranteDefault = new Set<String>(matrGara.ProdottiGaranteDefault__c.split(';'));
            Linea__c linea = [SELECT Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Id = :garanzia.Linea__c];
            if(prodottiConGaranteDefault.contains(linea.Prodotto__r.CodiceUnivoco__c)){
                List<String> idGaranti = String.valueOf(UtenzeDefault__c.getInstance().get('IdGaranteDefault' + linea.Prodotto__r.CodiceUnivoco__c + '__c')).split(';');
                List<Account> accs = new List<Account>([SELECT Id, Name, NDGGruppo__c, CF__c FROM Account WHERE Id IN: idGaranti]); 
                for(String id : idGaranti){
                    NDGLinea__c newAttore = new NDGLinea__c(
                    Account__c = (Id) id,
                    Opportunita__c = opportunityId,
                    Tipo__c = 'Garante',
                    RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Referente').Id,
                    TipoGarante__c = 'S');

                    garanti.add(newAttore);
                }
                try {
                    insert garanti;

                    Set<Id> garantiId = new Set<Id>();
                    for(NDGLinea__c attore : garanti){
                        garantiId.add(attore.Id);
                    }

                    garanti = [SELECT Id, Nome__c, NDG__c, CF__c, TipoGarante__c, CodiceRapporto__c FROM NDGLinea__c WHERE Id IN: garantiId];
                    return garanti;
                }
                catch(DmlException e) {
                    throw new Ex.WSException(e.getDmlMessage(0), e);
                    // return null;
                }
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static WrapperResponseWS saveGaranti(String cointestazione, Id oppId) {
        WrapperResponseWS response = new WrapperResponseWS();
        System.debug('@@@@ cointestazione: ' + cointestazione);
        try {
            response.data = CtrlWizardOpportunity.saveGaranti((CtrlCointestazione.Cointestazione) JSON.deserialize(cointestazione, CtrlCointestazione.Cointestazione.Class), oppId);
        } catch (Exception e) {
            response.msg = e.getMessage();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static Boolean removeGaranzia(String garanziaId){
        List<Id> garantiIds = new List<Id>();
        Set<String> garanti = U.getSet([SELECT Id, Garante__c FROM JoinGaranteGaranzia__c WHERE Garanzia__r.IdEsterno__c = :garanziaId], 'Garante__c');
        for (String id : garanti)
            garantiIds.add((Id) id);
        
        if (CtrlWizardOpportunity.removeGaranti(garantiIds) == false)
            return false;
        
        return CtrlWizardOpportunity.removeGaranzia(garanziaId);
    }

    @AuraEnabled
    public static Boolean removeGarante(String garanteId){
        return CtrlWizardOpportunity.removeGarante(garanteId);
    }

    @AuraEnabled
    public static Boolean removeGaranti(Id[] garantiIds){
        return CtrlWizardOpportunity.removeGaranti(garantiIds);
    }

    @AuraEnabled
    public static String gestisciCointestazione(Id sObjectId) {
        return CtrlWizardOpportunity.gestisciCointestazione(sObjectId);
    }

    @AuraEnabled
    public static CtrlCointestazione.ResponseObject recuperaCointestazioni(String processId, Boolean riepilogoCointestazioni, Id sObjectId) {
        try {
            return CtrlWizardOpportunity.recuperaCointestazioni(processId, riepilogoCointestazioni, sObjectId);
        } catch (Exception e) {
            System.debug('@@@@ ERRORE NEL RECUPERO COINTESTAZIONI: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static Boolean hasProdottiGaranteDefault(String opportunityId){
        Boolean needGaranzia = false;
        List<Linea__c> lines = new List<Linea__c>();
        lines = [SELECT Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Opportunity__c = :opportunityId];
        List<MatriceGaranzie__mdt> matGaranzie = new List<MatriceGaranzie__mdt>();
        matGaranzie = [SELECT ProdottiGaranteDefault__c FROM MatriceGaranzie__mdt ];
        Set<String> prods = new Set<String>();

        for (MatriceGaranzie__mdt mg : matGaranzie) {
            if (String.isNotBlank(mg.ProdottiGaranteDefault__c))
                prods.addAll(mg.ProdottiGaranteDefault__c.split(';'));
        }

        for (Linea__c l : lines) {
            if (prods.contains(l.Prodotto__r.CodiceUnivoco__c)) {
                needGaranzia = true;
                break;
            }
        }

        return needGaranzia;
    }

    public class Garanzia {
        @AuraEnabled public String tipologia;
        @AuraEnabled public String copertura;
        @AuraEnabled public String opportunita;
        @AuraEnabled public String linea;
        @AuraEnabled public Decimal importo;
        @AuraEnabled public String divisa;
        @AuraEnabled public String idEsterno;

        public Garanzia() {
            tipologia = '';
            copertura = '';
            opportunita = '';
            linea = '';
            importo = null;
            divisa = '';
            idEsterno = '';
        }
    }

    public class Garante {
        @AuraEnabled public String id;
        @AuraEnabled public String nome;
        @AuraEnabled public String ndg;
        @AuraEnabled public String opportunita;
        // da aggiungere percentuale?

        public Garante() {
            id = '';
            nome = '';
            ndg = '';
            opportunita = '';
        }
    }

/* END - METODI PER GESTIONE GARANTI E GARANZIE */

/* METODI PER INVIO A NUOVA VENDITA OPPTY */

    @AuraEnabled
    public static Boolean privacyEsecutoreFirmata(String accountId){
        return WGC_Documenti_Controller.privacyEsecutoreFirmata(accountId);
    }

    @AuraEnabled
    public static Boolean isCurrentUserSpecialista(Id accountId, Id opportunityId){
        Boolean resp = false;
        Account acc = [SELECT WGC_Specialista_Factoring__c, WGC_Specialista_IFIS_International__c, WGC_Specialista_Crediti_Erariali__c FROM Account WHERE Id = :accountId];
        Opportunity opp = [SELECT RecordType.DeveloperName FROM Opportunity WHERE Id = :opportunityId];

        if (opp.RecordType.DeveloperName == RT_DEVNAME_FACTORING) {
            resp = (UserInfo.getUserId() == acc.WGC_Specialista_Factoring__c);
        } else if (opp.RecordType.DeveloperName == RT_DEVNAME_INTERNATIONAL) {
            resp = (UserInfo.getUserId() == acc.WGC_Specialista_IFIS_International__c);
        } else if (opp.RecordType.DeveloperName == RT_DEVNAME_FASTFINANCE){
            resp = (UserInfo.getUserId() == acc.WGC_Specialista_Crediti_Erariali__c);
        }

		//A.M. SDHDFNZ-118722 - Aggiornamento mail Responsabile
		if (resp == true) {
			User own = [SELECT Id, Manager.Email FROM User WHERE id = :UserInfo.getUserId()];
			updateNote('WGC_Email_Referente_Factoring_Anagrafica__c', own.Manager.Email, opportunityId);
			System.debug('@@@@A.M. Aggiornamento mail Responsabile: ' + own.Manager.Email + ' Opportunity: ' + opportunityId);
		}

        return resp;
    }

    @AuraEnabled
    public static String validateInfoOpportunity(String opportunityId){
        String errorString = '';

        errorString = checkValidGaranzie(opportunityId);
        if (String.isBlank(errorString)) {
            errorString = manageCreditsUniqueCode(opportunityId);
            if (String.isBlank(errorString)) {
                // ULTERIORI CHECK
            }
        }

        return errorString;
    }

    // DEPRECATED
    @AuraEnabled
    public static Boolean fetchInnescoOpportunita(Id oppId) {
        return ExtViewCheckList.fetchInnescoOpportunita(oppId);
    }

    @AuraEnabled
    public static Boolean esistePef(Id oppId) {
        try {
            return ExtViewCheckList.esistePef(oppId);
        } catch (Exception e) {
            System.debug('@@@@ TEN - ERRORE NEL CHECK ESISTENZA PEF: ' + e.getStackTraceString() + ' --- ' + e.getMessage());
            return true;
        }
    }

    @AuraEnabled
    public static String checkTitolariEsecutore(Id accountId, Id opportunityId){
        String retMessage = '';
        Id referenteRT = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'NDGLinea__c' AND DeveloperName = 'Referente' LIMIT 1].Id;
        List<AccountContactRelation> acr = [SELECT Id, ContactId, Contact.Name, Contact.WGC_Censimento_MAV__c, WGC_Selezionato__c, WGC_Ruolo_Pratica__c, WGC_Tipologia_Titolare_Effettivo__c, WGC_Esecutore_MAV__c, WGC_Effettivo_MAV__c, Contact.PEP__c FROM AccountContactRelation WHERE AccountId = :accountId AND WGC_Selezionato__c = true];

        List<NDGLinea__c> referenti = [SELECT Id, Contact__c, Tipo__c FROM NDGLinea__c WHERE Opportunita__c = :opportunityId AND (Tipo__c = 'Esecutore adeguata verifica' OR Tipo__c = 'Titolare effettivo adeguata verifica')];
        Opportunity opp = [SELECT Id, Tipologia_Opportunit__c, WGC_PEP__c, BI_LineeRevisionabili__c FROM Opportunity WHERE Id = :opportunityId];

        List<AccountContactRelation> titeff = new List<AccountContactRelation>();
        List<AccountContactRelation> esec = new List<AccountContactRelation>();

        try {
		//A.M. Gestione cliente incerto
            Account acc = [SELECT Id, Name, 
                                    WGC_Linee_Conto_Corrente__c, WGC_Linee_Fact_Cedente__c, WGC_Linee_Fact_Debitore__c, WGC_Linee_Fact_Cedente_Incerto__c, PartecipazioneSocietaFiduciarie2__c
                                    FROM Account WHERE Id =: accountId];
            //SM - TEN: Corporate Estero - Escludo le linee per cui devo solo mandare la mail 
            List<Linea__c> allLinee = [SELECT Id, Name FROM Linea__c WHERE Opportunity__c =: opportunityId 
                                        AND Prodotto__r.CodiceUnivoco__c != 'DocumentateIncasso'
                                        AND Prodotto__r.CodiceUnivoco__c != 'CreditoDocumentarioExport'];

            Boolean parametriModificati = getParametriModificati(allLinee);
            //A.M. Gestione linee da revisionare direttamente da opportunità
			//Boolean nuoveLinee = getNuovaCessione(acc, allLinee);
			Boolean nuoveLinee = getNuovaCessione(opp, allLinee);

            if (opp.Tipologia_Opportunit__c == 'RINN' || (parametriModificati == true && nuoveLinee == false)) // SKIPPO SU SCENARI: SOLA REVISIONE, RINNOVO
                return retMessage;

            Boolean allValid = true;
            Set<Id> esecutori = new Set<Id>();
            NDGLinea__c titolarePresente;
            Boolean removeTitolarePresente = false;

            for (AccountContactRelation tmp_acr : acr) {
                // List<String> roles = tmp_acr.WGC_Ruolo_Pratica__c.split(';');
                
                if (tmp_acr.WGC_Effettivo_MAV__c == true)
                    titeff.add(tmp_acr);
                if (tmp_acr.WGC_Esecutore_MAV__c == true)
                    esec.add(tmp_acr);
                if (tmp_acr.Contact.WGC_Censimento_MAV__c != 'Completo')
                    allValid = false;
            }

            for (NDGLinea__c l : referenti) {
                if (l.Tipo__c == 'Esecutore adeguata verifica')
                    esecutori.add(l.Contact__c);
                if (l.Tipo__c == 'Titolare effettivo adeguata verifica')
                    titolarePresente = l;
            }

            // THERE MUST BE AT LEAST ONE "ESECUTORE" AND ONE "TITOLARE EFFETTIVO"
            // EDIT: SE CEDENTE HA FLAG PartecipazioneSocietaFiduciarie2__c ALZATO, ALLORA TITOLARE EFFETTIVO NON OBBLIGATORIO
            if ((titeff.size() == 0 && acc.PartecipazioneSocietaFiduciarie2__c == false) || esec.size() == 0)
                return Label.WGC_Cart_TitEff_Esec_AtLeastOne;

            // ALL ACTORS MUST BEEN COMPLETED
            if (allValid == false)
                return Label.WGC_Cart_TitEff_Esec_Incomplete;

            List<NDGLinea__c> actors = new List<NDGLinea__c>();
            // PROCEED TO INSERT NDGLINEA FOR "ESECUTORE"
            for (AccountContactRelation e : esec) {
                if (!esecutori.contains(e.ContactId)) {
                    NDGLinea__c esecutore = new NDGLinea__c();
                    esecutore.Opportunita__c = opportunityId;
                    esecutore.Tipo__c = 'Esecutore adeguata verifica';
                    esecutore.Contact__c = e.ContactId;
                    esecutore.RecordTypeId = referenteRT;
                    actors.add(esecutore);
                }
            }
            // PROCEED TO INSERT NDGLINEA FOR "TITOLARI EFFETTIVI"
            for (AccountContactRelation t : titeff) {
                if (titolarePresente == null) {
                    NDGLinea__c titolare = new NDGLinea__c();
                    titolare.Opportunita__c = opportunityId;
                    titolare.Tipo__c = 'Titolare effettivo adeguata verifica';
                    titolare.Contact__c = t.ContactId;
                    titolare.RecordTypeId = referenteRT;
                    actors.add(titolare);
                } else if (titolarePresente.Contact__c != t.ContactId) {
                    NDGLinea__c titolare = new NDGLinea__c();
                    titolare.Opportunita__c = opportunityId;
                    titolare.Tipo__c = 'Titolare effettivo adeguata verifica';
                    titolare.Contact__c = t.ContactId;
                    titolare.RecordTypeId = referenteRT;
                    actors.add(titolare);

                    removeTitolarePresente = true;
                }
            }

            if (removeTitolarePresente)
                delete titolarePresente;

            for(AccountContactRelation tmp_acr : acr){
                if( ( tmp_acr.WGC_Esecutore_MAV__c || tmp_acr.WGC_Effettivo_MAV__c ) && tmp_acr.Contact.PEP__c ){
                    opp.WGC_PEP__c = true;
                    break;
                }
            }

            insert actors;

            System.debug('@@@ opp ' + JSON.serialize(opp));
            if(opp.WGC_PEP__c) Update opp;
            
        } catch (Exception e) {
            System.debug('@@@@ ERROR: ' + e.getMessage());
            retMessage = e.getMessage();
        }

        return retMessage;
    }
    
    @AuraEnabled
    public static Boolean cambiaInnescoOpportunita(Id oppId) {
        ExtViewCheckList.cambiaInnescoOpportunita(true, oppId);
        
        // CREAZIONE DI DATI FITTIZI PER INVIO NV
        // List<NDGLinea__c> esecutori = [SELECT Id FROM NDGLinea__c WHERE Opportunita__c = :oppId AND Tipo__c = 'Esecutore adeguata verifica'];
        // if (esecutori.size() == 0) {
        //     NDGLinea__c esecutore = new NDGLinea__c();
        //     esecutore.Opportunita__c = oppId;
        //     esecutore.Tipo__c = 'Esecutore adeguata verifica';
        //     Opportunity o = [SELECT AccountId FROM Opportunity WHERE Id = :oppId];
        //     Contact cont = [SELECT Id, NDGGruppo__c FROM Contact WHERE AccountId = :o.AccountId AND NDGGruppo__c != null LIMIT 1];
        //     if (cont == null)
        //         throw new AuraHandledException('Non ci sono referenti validi associati all\' Anagrafica');
        //     esecutore.Contact__c = cont.Id;
            // if (cont.NDGGruppo__c == null) {
            //     cont.NDGGruppo__c = '123456';
            //     update cont;
            // }
        //     Account a = [SELECT Id, Filiale__c FROM Account WHERE Id = :o.AccountId];
        //     if (a.Filiale__c == '0' || a.Filiale__c == '' || a.Filiale__c == null) {
        //         a.Filiale__c = '92';
        //         update a;
        //     }
        //     insert esecutore;
        // }
        // CREAZIONE DI DATI FITTIZI PER INVIO NV
        
        return true;
    }

    @AuraEnabled
    public static String associaResponsabili(String accountId, String opportunityRecordType){
        try {
            Id settorista;
            String settoristaNDG = '';
            List<Account> acc = [SELECT
                                    Id,
                                    WGC_Specialista_Factoring__c,
                                    WGC_Specialista_Factoring__r.NDGGruppo__c,
                                    WGC_Specialista_Factoring__r.Ruolo_Knet__c,
                                    WGC_Specialista_IFIS_International__c,
                                    WGC_Specialista_IFIS_International__r.NDGGruppo__c,
                                    WGC_Specialista_IFIS_International__r.Ruolo_Knet__c,
                                    WGC_Specialista_Crediti_Erariali__c,
                                    WGC_Specialista_Crediti_Erariali__r.NDGGruppo__c,
                                    WGC_Gestore_Debitore__r.NDGGruppo__c,
                                    WGC_Gestore_Debitore__r.Ruolo_Knet__c,
                                    Presentatore__r.NDGGruppo__c,
                                    Presentatore__r.Ruolo_Knet__c,
                                    NDGGruppo__c
                                FROM Account WHERE Id = :accountId];

            if (acc.size() == 0)
                return 'Account non presente a sistema.';

            if (acc[0].NDGGruppo__c == null)
                return 'NDGGruppo non valorizzato';

            if (opportunityRecordType == RT_DEVNAME_FACTORING || opportunityRecordType == RT_DEVNAME_FACTORING_RINNOVO) {
                settorista = acc[0].WGC_Specialista_Factoring__c;
                settoristaNDG = acc[0].WGC_Specialista_Factoring__r.NDGGruppo__c;
            } else if (opportunityRecordType == RT_DEVNAME_INTERNATIONAL) {
                settorista = acc[0].WGC_Specialista_IFIS_International__c;
                settoristaNDG = acc[0].WGC_Specialista_IFIS_International__r.NDGGruppo__c;
            } else if (opportunityRecordType == RT_DEVNAME_FACTORING_FISCALE || opportunityRecordType == RT_DEVNAME_FASTFINANCE) {
                settorista = acc[0].WGC_Specialista_Crediti_Erariali__c;
                settoristaNDG = acc[0].WGC_Specialista_Crediti_Erariali__r.NDGGruppo__c;
            }

            if (settorista == null)
                return 'Settorista non valorizzato';

            if (settoristaNDG == null)
                return 'Parametro NDG non valorizzato per il Settorista selezionato';

            // WsAnagrafe.GestioneCollNdgResponse response_specialistaSettorista = WsAnagrafe.associaPfPgCollNdg(acc[0].NDGGruppo__c, settoristaNDG, CODICE_SETTORISTA, true);
            WGC_WSUtils_Cart.InputPayloadANAG70 inputSettorista = new WGC_WSUtils_Cart.InputPayloadANAG70();
            inputSettorista.ndgSoggetto = acc[0].NDGGruppo__c;
            inputSettorista.ndgGestore = settoristaNDG;
            inputSettorista.codTipoRela = CODICE_SETTORISTA;
            inputSettorista.service = 'CRM2.0';
            System.debug('@@@@ inputSettorista: ' + inputSettorista);
            WGC_WSUtils_Cart.PayloadResponseANAG70 respSettorista = WGC_WSUtils_Cart.callANAG70(inputSettorista);
            System.debug('@@@@ respSettorista: ' + respSettorista);
            
            if (acc[0].WGC_Gestore_Debitore__r.NDGGruppo__c != null) {
                WGC_WSUtils_Cart.InputPayloadANAG70 inputGestDeb = new WGC_WSUtils_Cart.InputPayloadANAG70();
                inputGestDeb.ndgSoggetto = acc[0].NDGGruppo__c;
                inputGestDeb.ndgGestore = acc[0].WGC_Gestore_Debitore__r.NDGGruppo__c;
                inputGestDeb.codTipoRela = CODICE_GESTORE_DEBITORE;
                inputGestDeb.service = 'CRM2.0';
                System.debug('@@@@ inputGestDeb: ' + inputGestDeb);
                WGC_WSUtils_Cart.PayloadResponseANAG70 respGestDeb = WGC_WSUtils_Cart.callANAG70(inputGestDeb);
                System.debug('@@@@ respGestDeb: ' + respGestDeb);
            }
            // WsAnagrafe.GestioneCollNdgResponse response_gestDeb = WsAnagrafe.associaPfPgCollNdg(acc[0].NDGGruppo__c, acc[0].WGC_Gestore_Debitore__r.NDGGruppo__c, CODICE_GESTORE_DEBITORE, true);
            
            if (acc[0].Presentatore__r.NDGGruppo__c != null) {
                WGC_WSUtils_Cart.InputPayloadANAG70 inputPresentatore = new WGC_WSUtils_Cart.InputPayloadANAG70();
                inputPresentatore.ndgSoggetto = acc[0].NDGGruppo__c;
                inputPresentatore.ndgGestore = acc[0].Presentatore__r.NDGGruppo__c;
                inputPresentatore.codTipoRela = CODICE_PRESENTATORE;
                inputPresentatore.service = 'CRM2.0';
                System.debug('@@@@ inputPresentatore: ' + inputPresentatore);
                WGC_WSUtils_Cart.PayloadResponseANAG70 respPresentatore = WGC_WSUtils_Cart.callANAG70(inputPresentatore);
                System.debug('@@@@ respPresentatore: ' + respPresentatore);
            }
            // WsAnagrafe.GestioneCollNdgResponse response_presentatore = WsAnagrafe.associaPfPgCollNdg(acc[0].NDGGruppo__c, acc[0].Presentatore__r.NDGGruppo__c, CODICE_PRESENTATORE, true);
            
        } catch (Exception e) {
            System.debug('@@@@ ERROR: ' + e.getMessage());
            return e.getMessage();
        }
        return '';
    }
    
    @AuraEnabled
    public static String inviaNuovaVendita(Id oppId) {
        List<Linea__c> allLinee = new List<Linea__c>();
        String returnString = '';

        try {
            Opportunity opp = [SELECT Id, AccountId, Tipologia_Opportunit__c, BI_LineeRevisionabili__c FROM Opportunity WHERE Id =: oppId];
			//A.M. Gestione cliente incerto
            Account acc = [SELECT Id, Name, 
                                    WGC_Linee_Conto_Corrente__c, WGC_Linee_Fact_Cedente__c, WGC_Linee_Fact_Debitore__c, WGC_Linee_Fact_Cedente_Incerto__c 
                                    FROM Account WHERE Id =: opp.AccountId];
            User usr = [SELECT Id, NDGGruppo__c FROM User WHERE Id = :UserInfo.getUserId()];

            //SM - TEN - Fix per doppia Join
            Map<String, List<JoinGaranteGaranzia__c>> garanziaXJoin = (Map<String,List<JoinGaranteGaranzia__c>>)U.groupBy([SELECT Id, Garanzia__c, Garante__c FROM JoinGaranteGaranzia__c WHERE Garanzia__r.Opportunita__c =: oppId ORDER BY CreatedDate ASC], 'Garanzia__c');

            Set<String> joinIds = new Set<String>();
            for(String id : garanziaXJoin.keySet()){
                if(garanziaXJoin.get(id).size() > 1){
                    joinIds.add(garanziaXJoin.get(id).get(0).Id);
                } else {
                    joinIds.addAll((Set<String>)U.getSet(garanziaXJoin.get(id), 'Id'));
                }
            }

            if(!joinIds.isEmpty())
                delete [SELECT Id FROM JoinGaranteGaranzia__c WHERE Id NOT IN: joinIds AND Garanzia__r.Opportunita__c =: oppId];
                                    
            //SM - TEN End Fix
            allLinee = [SELECT Id, Name FROM Linea__c WHERE Opportunity__c =: oppId 
                        AND Prodotto__r.CodiceUnivoco__c != 'DocumentateIncasso'
                        AND Prodotto__r.CodiceUnivoco__c != 'CreditoDocumentarioExport' ];

            Boolean parametriModificati = getParametriModificati(allLinee);
            //A.M. Gestione linee da revisionare direttamente da opportunità
			//Boolean nuoveLinee = getNuovaCessione(acc, allLinee);
			Boolean nuoveLinee = getNuovaCessione(opp, allLinee);

            if (opp.Tipologia_Opportunit__c == 'RINN') { // RINNOVO
                returnString = generatePEF41Callout(opp, usr);
            }
            else if (parametriModificati && nuoveLinee) { // MIX: NUOVA CONCESSIONE + REVISIONE
                returnString = ExtViewCheckList.inviaNuovaVendita(oppId);
            }
            else {
                if (parametriModificati) { // REVISIONE
                    returnString = generatePEF41Callout(opp, usr);
                }
                else { // NUOVA CONCESSIONE (ANCHE SU OPPORTUNITA' IN REVISIONE SE NESSUN PARAMETRO MODIFICATO)
                    returnString = ExtViewCheckList.inviaNuovaVendita(oppId);
                }
            }
        } catch (Exception e) {
            System.debug('@@@@ TEN - ERRORE INVIO IN VALUTAZIONE: ' + e.getStackTraceString() + ' --- ' + e.getMessage());
            return e.getMessage();
        }

        return returnString;
    }

    public static String generatePEF41Callout(Opportunity opp, User currentUser) {
        if (currentUser.NDGGruppo__c == '' || currentUser.NDGGruppo__c == null)
            return Label.WGC_Cart_PEF41UserNDGMissing;
        else {
            WGC_WSUtils_Cart.PEF41Response respPef41 = WGC_WSUtils_Cart.calloutPEF41(opp.Id, currentUser.NDGGruppo__c);
            if (respPef41.payload.outputRichiesta.codPratica != null) {
                List<Linea__c> linee = [SELECT Id,
                    Prodotto__r.CodiceUnivoco__c,
                    Opportunity__r.AccountId,
                    Opportunity__r.Account.BillingPostalCode,
                    Opportunity__r.Account.ShippingPostalCode,
                    Opportunity__r.Account.BillingCity,
                    Opportunity__r.Account.ShippingCity,
                    Opportunity__r.Account.BillingState,
                    Opportunity__r.Account.ShippingState,
                    Opportunity__r.Account.OwnerId
                    FROM Linea__c
                    WHERE Opportunity__c = :opp.Id];
                U.massSet(linee, 'Stato__c', '1');
                // TODO: Gestire diversi casi tra Revisione e Rinnovo
                opp.StageName = (opp.Tipologia_Opportunit__c == 'RINN' ? 'Valutazione' : 'Valutazione Pratica');
                opp.WGC_Codice_Pratica__c = respPef41.payload.outputRichiesta.codPratica;
                opp.StatoPEF__c = '6';
                // Opportunity o = new Opportunity(Id = oppId, StageName = ('Valutazione Pratica'), WGC_Codice_Pratica__c = respPef41.payload.outputRichiesta.codPratica);
                update opp;
                update linee;
            }
            //TODO override metodo getErrors classe estesa PEF41Response
            return respPef41.isCorrect() ? null : respPef41.getErrors();
        }
    }

    @AuraEnabled
    public static String invioDocumentiNuovaVendita(Id opportunityId, Id accountId) {
        String resp = '';

        try {
		//A.M. Gestione cliente incerto
            Account acc = [SELECT Id, Name, NDGGruppo__c,
                                        WGC_Linee_Conto_Corrente__c, WGC_Linee_Fact_Cedente__c, WGC_Linee_Fact_Debitore__c, WGC_Linee_Fact_Cedente_Incerto__c 
                                        FROM Account WHERE Id =: accountId];
            List<Linea__c> allLinee = [SELECT Id, Name FROM Linea__c WHERE Opportunity__c =: opportunityId
                                        AND Prodotto__r.CodiceUnivoco__c != 'DocumentateIncasso'
                                        AND Prodotto__r.CodiceUnivoco__c != 'CreditoDocumentarioExport'];
		    
			//A.M. Gestione linee da revisionare direttamente da opportunità
			Opportunity opp = [SELECT Id, BI_LineeRevisionabili__c  
                                        FROM Opportunity WHERE Id =: opportunityId];

			
            
            Boolean parametriModificati = getParametriModificati(allLinee);
            //A.M. Gestione linee da revisionare direttamente da opportunità
			//Boolean nuoveLinee = getNuovaCessione(acc, allLinee);
			Boolean nuoveLinee = getNuovaCessione(opp, allLinee);

            if ((parametriModificati && nuoveLinee) || (!parametriModificati && nuoveLinee)) {
                WGC_Documenti_Controller.InvioDocNuovaVendita(opportunityId);
                WGC_Documenti_Controller.ricercaMAV(acc.NDGGruppo__c, opportunityId);
            }
        } catch (Exception e) {
            resp = e.getMessage();
        }

        return resp;
    }

    public static Boolean getParametriModificati(List<Linea__c> linee){
        Boolean result = false;

        Set<Id> lineeId = new Set<Id>();
        List<PConfigurato__c> parametriLinee = new List<PConfigurato__c>();

        for(Linea__c lin : linee){
            lineeId.add(lin.Id);
        }

        parametriLinee = [SELECT Id, WGC_Parametro_revisionato__c, Linea__c FROM PConfigurato__c 
                            WHERE Linea__c IN : lineeId AND WGC_Parametro_revisionato__c = true];

        //Se la lista di parametriLinee non è vuota allora ho dei parametri modificati
        if(parametriLinee.size() > 0){
            result = true;
        }

        return result;
    }

	//A.M. 
    //public static Boolean getNuovaCessione(Account accOldLinee, List<Linea__c> newLinee){
	public static Boolean getNuovaCessione(Opportunity oppOldLinee, List<Linea__c> newLinee){
        Boolean result = false;
        Decimal countNewLinee = 0;

		//A.M. Gestione linee da revisionare direttamente da opportunità
        //countNewLinee = accOldLinee.WGC_Linee_Conto_Corrente__c + accOldLinee.WGC_Linee_Fact_Cedente__c + + accOldLinee.WGC_Linee_Fact_Cedente_Incerto__c; // + accOldLinee.WGC_Linee_Fact_Debitore__c;
		countNewLinee = (oppOldLinee.BI_LineeRevisionabili__c != null ? oppOldLinee.BI_LineeRevisionabili__c : 0);
		System.debug('@@@@A.M. countNewLinee: ' + countNewLinee);

        if(newLinee.size() != countNewLinee){
            result = true;
        }
		System.debug('@@@@A.M. result: ' + result);
        return result;
    }
    
    @AuraEnabled
    public static Boolean esisteTitolareEffettivo(Id oppId) {
        return ExtViewCheckList.esisteTitolareEffettivo(oppId);
    }

    @AuraEnabled
    public static String checkValidGaranzie(String opportunityId){
        //A.M. Validazione garanzia non per i prodotti in revisione
        //Set<String> prodCodes = U.getSet([SELECT Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Opportunity__c = :opportunityId], 'Prodotto__r.CodiceUnivoco__c');
        Set<String> prodCodes = U.getSet([SELECT Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Opportunity__c = :opportunityId AND WGC_Numero_Linea_Credito__c = null], 'Prodotto__r.CodiceUnivoco__c');
        Set<String> garanCodes = U.getSet([SELECT CodiceGaranzia__c FROM Garanzia__c WHERE Opportunita__c = :opportunityId], 'CodiceGaranzia__c');
        List<MatriceGaranzie__mdt> matGaranzie = new List<MatriceGaranzie__mdt>();
        matGaranzie = [SELECT ProdottiGaranteDefault__c, CodiceKNET__c FROM MatriceGaranzie__mdt];
        Map<String, String[]> mapProdGara = new Map<String, String[]>();

        for (MatriceGaranzie__mdt mg : matGaranzie) {
            if (String.isNotBlank(mg.ProdottiGaranteDefault__c))
                if (mapProdGara.keySet().contains(mg.CodiceKNET__c))
                    mapProdGara.get(mg.CodiceKNET__c).add(mg.ProdottiGaranteDefault__c);
                else
                    mapProdGara.put(mg.CodiceKNET__c, mg.ProdottiGaranteDefault__c.split(';'));
        }

        for (String prodCode : prodCodes) {
            for (String codKNET : mapProdGara.keySet()) {
                if (mapProdGara.get(codKNET).contains(prodCode)) {
                    if (!garanCodes.contains(codKNET))
                        return Label.WGC_Cart_GaranziaMancante;
                }
            }
        }

        return '';
    }
    
    // @AuraEnabled
    // public static WGC_Documenti_Controller.WrapperResponse ricercaMAV(String ndg, String opportunityId) {
    //     return WGC_Documenti_Controller.ricercaMAV(ndg, opportunityId);
    // }
    
    // @AuraEnabled
    // public static WGC_FileUploaderController.WrapperResponse uploadMAV(WGC_Documenti_Controller.WrapperRicercaMAV mav) {
    //     return WGC_FileUploaderController.uploadDocMultipart_Direct(mav);
    // }
    
/* END - METODI PER INVIO A NUOVA VENDITA OPPTY */

    // @AuraEnabled
    // public static String manageDeleteOpportunity(Id opportunityId){
    //     // do something
    // }

    @AuraEnabled
    public static MatriceSezioni__mdt[] getSezioni() {
        return CtrlWizardOpportunity.getSezioni();
    }

    public static Boolean hasIcarManuali(Linea__c linea) {
        return linea.Prodotto__r.CodiceUnivoco__c == 'ATDTiAnticipo' || linea.ICAR__c == 'ICAR Manuale';
    }

    /* METODI PER GESTIONE DASHBOARD PARAMETRI */

    @AuraEnabled
    public static List<Opportunity> getAllOpportunities() {
        return [SELECT Id, Name FROM Opportunity];
    }

    @AuraEnabled
    public static List<String> getAllProducts() {
        List<ParametroProdotto__c> q = [SELECT Prodotto__r.Name FROM ParametroProdotto__c];
        List<String> ret = new List<String>();
        
        for (ParametroProdotto__c pp : q)
            if (!ret.contains(pp.Prodotto__r.Name))
                ret.add(pp.Prodotto__r.Name);

        return ret;
    }

    @AuraEnabled
    public static List<CtrlWizardOpportunity.WoConfigurazioneParametro> getParametri(String opportunity, String product) {
        
        if (opportunity != null && product == null) {
                    
            List<Linea__c> lineeOpp = [SELECT Id, Prodotto__c FROM Linea__c WHERE Opportunity__r.Name = :opportunity];
            Set<String> prodotti = U.getSet(lineeOpp,'Prodotto__c');

            Map<String, ParametroProdotto__c[]> ppByProdotto = U.groupBy([SELECT
            Prodotto__c,
            Parametro__c,
            Dominio__c,
            ReadOnly__c,
            FormulaDiControllo__c,
            Default__c,
            RegolaDiConvalida__c,
            MessaggioRegolaDiConvalida__c,
            toLabel(Sezione__c),
            toLabel(SottoSezione__c),
            Ordine__c,
            SoloDeroga__c,
            DerogaFidoDiCoppia__c,
            Parametro__r.Name,
            Parametro__r.Tipo__c,
            Parametro__r.Tipologia__c,
            Parametro__r.CodiceUnivoco__c,
            Id
            FROM ParametroProdotto__c
            WHERE Prodotto__c IN :prodotti
            AND (Wizard__c = true AND Sezione__c != null)
            AND Parametro__r.CodiceUnivoco__c != null
            ORDER BY Ordine__c
            ], 'Prodotto__c');

            List<CtrlWizardOpportunity.WoConfigurazioneParametro> confparametri = new List<CtrlWizardOpportunity.WoConfigurazioneParametro>();
            for(Linea__c linea : lineeOpp) {
                if(!ppByProdotto.containsKey(linea.Prodotto__c)) continue;
                for(ParametroProdotto__c p : ppByProdotto.get(linea.Prodotto__c)) {
                    CtrlWizardOpportunity.WoConfigurazioneParametro cp = new CtrlWizardOpportunity.WoConfigurazioneParametro();
                    cp.linea = linea.Id;
                    cp.nome = p.Parametro__r.Name;
                    cp.codice = p.Parametro__r.CodiceUnivoco__c;
                    cp.tipologia = p.Parametro__r.Tipologia__c;
                    cp.sezione = p.Sezione__c;
                    cp.sottoSezione = p.SottoSezione__c;
                    cp.ordine = p.Ordine__c;
                    cp.dominioVal = p.Dominio__c;
                    cp.dominioFormula = '';
                    if(cp.dominioVal != null && cp.dominioVal.startsWith('${')) cp.dominioFormula = cp.dominioVal.substring(2, cp.dominioVal.length() - 1);
                    cp.readonly = p.ReadOnly__c;
                    cp.defaultval = String.isBlank(p.Default__c) ? '' : p.Default__c;
                    cp.defaultFormula = '';
                    if(cp.defaultval.startsWith('${')) cp.defaultFormula = cp.defaultval.substring(2, cp.defaultval.length() - 1);
                    cp.tipo = p.Parametro__r.Tipo__c;
                    cp.regolaConvalida = p.RegolaDiConvalida__c;
                    cp.messaggioConvalida = p.MessaggioRegolaDiConvalida__c;
                    cp.derogaFidoDiCoppia = p.DerogaFidoDiCoppia__c;
                    cp.formulaControllo = p.FormulaDiControllo__c;
                    cp.soloDeroga = p.SoloDeroga__c;
                    cp.id = p.Id;

                    confparametri.add(cp);
                }
            }

            return confparametri;

        } else if (product != null) {
            
            Map<String, ParametroProdotto__c[]> ppByProdotto = U.groupBy([SELECT
            Prodotto__c,
            Prodotto__r.Name,
            Parametro__c,
            Dominio__c,
            ReadOnly__c,
            FormulaDiControllo__c,
            Default__c,
            RegolaDiConvalida__c,
            MessaggioRegolaDiConvalida__c,
            toLabel(Sezione__c),
            toLabel(SottoSezione__c),
            Ordine__c,
            SoloDeroga__c,
            DerogaFidoDiCoppia__c,
            Parametro__r.Name,
            Parametro__r.Tipo__c,
            Parametro__r.Tipologia__c,
            Parametro__r.CodiceUnivoco__c,
            Id
            FROM ParametroProdotto__c
            WHERE Prodotto__r.Name = :product
            AND (Wizard__c = true AND Sezione__c != null)
            AND Parametro__r.CodiceUnivoco__c != null
            ORDER BY Ordine__c
            ], 'Prodotto__r.Name');

            List<CtrlWizardOpportunity.WoConfigurazioneParametro> confparametri = new List<CtrlWizardOpportunity.WoConfigurazioneParametro>();
            // for(Linea__c linea : lineeOpp) {
                // if(!ppByProdotto.containsKey(linea.Prodotto__c)) continue;
                for(ParametroProdotto__c p : ppByProdotto.get(product)) {
                    CtrlWizardOpportunity.WoConfigurazioneParametro cp = new CtrlWizardOpportunity.WoConfigurazioneParametro();
                    cp.linea = '--';
                    cp.nome = p.Parametro__r.Name;
                    cp.codice = p.Parametro__r.CodiceUnivoco__c;
                    cp.tipologia = p.Parametro__r.Tipologia__c;
                    cp.sezione = p.Sezione__c;
                    cp.sottoSezione = p.SottoSezione__c;
                    cp.ordine = p.Ordine__c;
                    cp.dominioVal = p.Dominio__c;
                    cp.dominioFormula = '';
                    if(cp.dominioVal != null && cp.dominioVal.startsWith('${')) cp.dominioFormula = cp.dominioVal.substring(2, cp.dominioVal.length() - 1);
                    cp.readonly = p.ReadOnly__c;
                    cp.defaultval = String.isBlank(p.Default__c) ? '' : p.Default__c;
                    cp.defaultFormula = '';
                    if(cp.defaultval.startsWith('${')) cp.defaultFormula = cp.defaultval.substring(2, cp.defaultval.length() - 1);
                    cp.tipo = p.Parametro__r.Tipo__c;
                    cp.regolaConvalida = p.RegolaDiConvalida__c;
                    cp.messaggioConvalida = p.MessaggioRegolaDiConvalida__c;
                    cp.derogaFidoDiCoppia = p.DerogaFidoDiCoppia__c;
                    cp.formulaControllo = p.FormulaDiControllo__c;
                    cp.soloDeroga = p.SoloDeroga__c;
                    cp.id = p.Id;

                    confparametri.add(cp);
                }
            // }

            return confparametri;
            
        }

        return null;
    }

    @AuraEnabled
    public static void saveParameter(CtrlWizardOpportunity.WoConfigurazioneParametro param) {
        // CtrlWizardOpportunity.WoConfigurazioneParametro param = (CtrlWizardOpportunity.WoConfigurazioneParametro) JSON.deserialize(json, CtrlWizardOpportunity.WoConfigurazioneParametro.class);

        ParametroProdotto__c pp = new ParametroProdotto__c();

        try {
            pp.Id = param.id;
            pp.Dominio__c = param.dominioVal;
            pp.SoloDeroga__c = param.soloDeroga;
            pp.Default__c = param.defaultval;
            pp.Sezione__c = param.sezione;

            update pp;
        } catch (Exception e) {
            system.debug('@@@@ ERROR: ' + e.getMessage());
        }
    }

    //SM - Spese Istruttoria
    @AuraEnabled
    public static void savePConfigurati(String paramsJSON){
        List<PConfigurato__c> pConfigurati = new List<PConfigurato__c>();
        List<CtrlWizardOpportunity.WoParametro> params = new List<CtrlWizardOpportunity.WoParametro>();
        System.debug('@@@ params json ' + paramsJSON);

        try{
            params = (List<CtrlWizardOpportunity.WoParametro>) JSON.deserialize(paramsJSON, List<CtrlWizardOpportunity.WoParametro>.class);
            System.debug('@@@ params ' + JSON.serialize(params));

            for(CtrlWizardOpportunity.WoParametro p : params){
                PConfigurato__c pconf = new PConfigurato__c();
                if(p.Id != null) pconf.Id = p.Id;
                pconf.Valore__c = p.valore;
                if(p.Id == null) pconf.Linea__c = p.linea;
                if(p.Id == null) pconf.Codice__c = p.codice;

                pConfigurati.add(pconf);
            }
            System.debug('@@@ pConfigurati ' + JSON.serialize(pConfigurati));
            Upsert pConfigurati;
            System.debug('@@@ pConfigurati ' + JSON.serialize(pConfigurati));
        }
        catch(Exception e){
            System.debug('@@@ eccezione ' + e.getMessage() + ' -- ' + e.getLineNumber());
        }


    }

    /* FACTORING FISCALE - INBONIS */

    @AuraEnabled
    public static User getCurrentUser() {
        return [SELECT Id, Name, Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    }
    
    @AuraEnabled
    public static String getIdAdE() {
        String IdAdE = UtenzeDefault__c.getOrgDefaults().IdAgenziadelleEntrate__c;
        System.debug('@@@IdAdE: ' + IdAdE);
        return IdAdE;
    }

    @AuraEnabled
    public static void updateFactFiscFlag(String payload){
        Map<String, Object> p = (Map<String, Object>) JSON.deserializeUntyped(payload);
        if (p.get('factfisc') != null)
            updateField('HasFactFisc__c', p.get('factfisc'), (Id) p.get('opportunityId'));
    }
    
    //A.M. Gestione flag Bonus Edilizi
    public static void updateBonusEdiliziFlag(String payload){
        Map<String, Object> p = (Map<String, Object>) JSON.deserializeUntyped(payload);
        if (p.get('BonusEdil') != null)
            updateField('BonusEdilizi__c', p.get('BonusEdil'), (Id) p.get('opportunityId'));
    }

    public static CtrlWizardOpportunity.WoPayload manageDefaultDebitore(Boolean hasFactFisc, Boolean BonusEdil, String opportunityId) {
        Id IdAnagAgenzia = UtenzeDefault__c.getOrgDefaults().IdAgenziadelleEntrate__c;
        List<NDGLinea__c> defaultDebs = [SELECT Id FROM NDGLinea__c WHERE Account__c = :IdAnagAgenzia AND Opportunita__c = :opportunityId];
        
        system.debug('A.M. BonusEdil - defaultDeb:' + BonusEdil);
        
         if (hasFactFisc) {
            if (defaultDebs.size() == 0) {
                NDGLinea__c defaultDeb = new NDGLinea__c(
                    Account__c = IdAnagAgenzia,
                    Opportunita__c = opportunityId,
                    RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Debitore').Id,
                    DivisaNew__c = '242',
                    Tipo__c = 'Debitore',
                    FakeId__c = generateRandomFakeId(new Set<String>()),
                    IsAutoAdd__c = true);
                insert defaultDeb;
            }
        } else if (BonusEdil) {
            if (defaultDebs.size() == 0) {      
                NDGLinea__c defaultDeb = new NDGLinea__c(
                    Account__c = IdAnagAgenzia,
                    Opportunita__c = opportunityId,
                    RecordTypeId = U.getRecordTypes('NDGLinea__c').get('Debitore').Id,
                    DivisaNew__c = '242',
                    Tipo__c = 'Debitore',
                    FakeId__c = generateRandomFakeId(new Set<String>()),
                    Plafond__c = 0,
                    Fatturato__c = 0,
                    DurataNominale__c = 0,	
                    ANotifica__c = true,
                    Maturity__c = false,
                    WGC_ContropartePrivato__c = false,
                    Tipologia_di_Fornitura__c	= 'Altro',
                    IsAutoAdd__c = false);
                insert defaultDeb;
            }
        } else {
            if (defaultDebs.size() > 0)
                delete defaultDebs;
        }

        return CtrlWizardOpportunity.editRsf(opportunityId);
    }
    
    

    @AuraEnabled
    public static WrapperResponseWS saveDataFactFisc(NDGLinea__c debitore, Opportunity opp) {
        WrapperResponseWS resp = new WrapperResponseWS();
        Map<String, Object> respData = new Map<String, Object>();

        try {
            update debitore;
            // respData.put('debitore', debitore);
            update opp;
            // respData.put('opp', opp);
            resp.success = true;
            resp.data = CtrlWizardOpportunity.editRSF(opp.Id);
        } catch (Exception e) {
            System.debug('@@@@ MB - TEN: ' + e.getMessage() + ' --- ' + e.getStackTraceString());
            resp.success = false;
            resp.msg = e.getMessage();
        }

        return resp;
    }

    public static void saveFactFisc(CtrlWizardOpportunity.WoPayload payload, Map<String, SObject> debitoriMap) {

        try {
            if (payload.factfisc) {
                Opportunity opp = [SELECT WGC_Prodotti_Selezionati__c FROM Opportunity WHERE Id = :payload.opportunityId];
                List<Prodotto__c> prods = [SELECT Id, Name, Notifica__c, Maturity__c, Codice__c, WGC_Famiglia__c, Servizio__c FROM Prodotto__c WHERE WGC_Area__c = 'Factoring - Fiscale' OR Codice__c = '364' OR Codice__c = '464'];
                List<Linea__c> oldLinee = [SELECT Id, Prodotto__r.Servizio__c, Prodotto__r.Notifica__c, Prodotto__r.Maturity__c, Prodotto__r.Codice__c, Mercato__c, DivisaNew__c, DebitoreAnticipazione__c, DebitoreRotativita__c, DebitoreTipo__c, LineaProsoluto__c, ProsolutoATD__c, LineaATD__c, TipoLinea__c, ICAR__c, WGC_Numero_Linea_Credito__c, LineaATDSingola__c, ICARAutomaticiATD__c, WGC_DocumentiOperativit_Cedente__c FROM Linea__c WHERE Opportunity__c = :payload.opportunityId AND RecordTypeId = :U.getRecordTypes('Linea__c').get('FactDir').Id];
                Map<String, SObject> oldLineeMap = U.keyBy(oldLinee, '{Prodotto__r.Servizio__c}_{Prodotto__r.Notifica__c}_{Prodotto__r.Maturity__c}_{DivisaNew__c}_{Mercato__c}', true);
                Map<String, SObject> oldLineeMapByCode = U.keyBy(oldLinee, 'Prodotto__r.Codice__c');
                Map<String, String> nameToService = new Map<String, String>();
                Map<String, SObject> prodottiByCode = U.keyBy(prods, 'Codice__c');
                Map<String, SObject> prodottiMap = U.keyBy(prods, '{Servizio__c}_{Notifica__c}_{Maturity__c}', true);
                NDGLinea__c debitore;
                String key = '';
                List<Linea__c> lines = new List<Linea__c>();
System.debug('@@@@ MB - TEN: oldLineeMap -- ' + oldLineeMap);
                for (Prodotto__c p : prods)
                    nameToService.put(p.Name, p.Servizio__c);

                for (SObject d : debitoriMap.values()) {
                    if (((NDGLinea__c) d).IsAutoAdd__c == true) {
                        debitore = (NDGLinea__c) d;
                        // GET SERVIZIO FROM NAME OF PRODUCT SELECTED
                        for (String n : nameToService.keySet())
                            if (opp.WGC_Prodotti_Selezionati__c.contains(n))
                                key = nameToService.get(n) + '_';
                        // COMPLETE KEY
                        key += debitore.ANotifica__c + '_' + debitore.Maturity__c;
                    }
                }

                Prodotto__c prod = (Prodotto__c) prodottiMap.get(key);
                Boolean isATD = key.startsWith('ATD');
                
                Linea__c l = new Linea__c(
                    RecordTypeId = U.getRecordTypes('Linea__c').get('FactDir').Id,
                    Opportunity__c = payload.opportunityId,
                    DivisaNew__c = debitore.DivisaNew__c,
                    Mercato__c = (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : debitore.Mercato__c),
                    DebitoreTipo__c = debitore.Tipo__c,
                    LineaATD__c = isATD,
                    LineaATDSingola__c = (isATD ? 'N' : 'S'),
                    TipoLinea__c = (isATD ? 'lineaDiAcquisto' : ''),
                    Prodotto__c = prod.Id,
                    HasCrediti__c = true
                );
                String finalKey = key + '_' + debitore.DivisaNew__c + '_' + (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : debitore.Mercato__c);
                System.debug('@@@@ MB - TEN: finalKey -- ' + finalKey);
                if (oldLineeMap.get(finalKey) != null)
                    l.Id = oldLineeMap.get(finalKey).Id;

                lines.add(l);

                if (isATD) {
                    if (prod.Codice__c == '744') {
                        System.debug('@@@@ MB - TEN: oldLineeMapByCode.get(464) -- ' + oldLineeMapByCode.get('464'));
                        lines.add(new Linea__c(
                            Id = (oldLineeMapByCode.get('464') != null ? oldLineeMapByCode.get('464').Id : null),
                            RecordTypeId = U.getRecordTypes('Linea__c').get('FactDir').Id,
                            Opportunity__c = payload.opportunityId,
                            DivisaNew__c = debitore.DivisaNew__c,
                            Mercato__c = (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : debitore.Mercato__c),
                            DebitoreTipo__c = debitore.Tipo__c,
                            LineaATD__c = isATD,
                            LineaATDSingola__c = 'N',
                            TipoLinea__c = 'lineaDiCarico',
                            Prodotto__c = prodottiByCode.get('464').Id
                        ));
                    } else if (prod.Codice__c == '844') {
                        System.debug('@@@@ MB - TEN: oldLineeMapByCode.get(364) -- ' + oldLineeMapByCode.get('364'));
                        lines.add(new Linea__c(
                            Id = (oldLineeMapByCode.get('364') != null ? oldLineeMapByCode.get('364').Id : null),
                            RecordTypeId = U.getRecordTypes('Linea__c').get('FactDir').Id,
                            Opportunity__c = payload.opportunityId,
                            DivisaNew__c = debitore.DivisaNew__c,
                            Mercato__c = (debitore.WGC_Mercato__c != null ? debitore.WGC_Mercato__c : debitore.Mercato__c),
                            DebitoreTipo__c = debitore.Tipo__c,
                            LineaATD__c = isATD,
                            LineaATDSingola__c = 'N',
                            TipoLinea__c = 'lineaDiCarico',
                            Prodotto__c = prodottiByCode.get('364').Id
                        ));
                    }
                }

                System.debug('@@@@ MB - TEN: FACTFISC lines -- ' + lines);
                upsert lines;
                Set<String> lineIds = U.getSet(lines, 'Id');

                //SM - Fast Finance - elimino i crediti in associati alle linee di factoring fiscale
                Map<Id,Linea__c> linesToDelete = new Map<Id,Linea__c>([SELECT Id FROM Linea__c WHERE Opportunity__c = :payload.opportunityId AND Id NOT IN :lineIds AND Prodotto__r.Codice__c IN :prodottiByCode.keySet() AND RecordTypeId = :U.getRecordTypes('Linea__c').get('FactDir').Id]);

                System.debug('@@@ linesToDelete ' + JSON.serialize(linesToDelete));
                //SM - FastFinance - Oltre alle linee elimino i crediti associati
                // eliminazione della linea e degli eventuali crediti
                delete [SELECT Id FROM Credito__c WHERE WGC_Linea__c IN: linesToDelete.keySet() OR WGC_Linea__c = null ];
                delete linesToDelete.values();

                // delete [SELECT Id FROM Linea__c WHERE Opportunity__c = :payload.opportunityId AND Id NOT IN :lineIds AND Prodotto__r.Codice__c IN :prodottiByCode.keySet() AND RecordTypeId = :U.getRecordTypes('Linea__c').get('FactDir').Id];

                List<JoinLineaDebitore__c> joins = new List<JoinLineaDebitore__c>();
                for (String lineId : lineIds) { // TODO: MANAGE FAKE FOR ATD SECOND LINE
                    JoinLineaDebitore__c jld = new JoinLineaDebitore__c(
                        Debitore__c = debitore.Id,
                        Linea__c = lineId,
                        Opportunita__c = payload.opportunityId
                    );
                    joins.add(jld);
                }

                insert joins;
                delete [SELECT Id FROM JoinLineaDebitore__c WHERE Opportunita__c = :payload.opportunityId AND Id NOT IN :joins AND Linea__r.Prodotto__r.Codice__c IN :prodottiByCode.keySet()];
            }
        } catch (Exception e) {
            System.debug('@@@@ MB - TEN: ' + e.getMessage() + ' --- ' + e.getStackTraceString());
        }
    }

    public static String manageCreditsUniqueCode(String opportunityId) {
        String errorMsg = '';
        Opportunity opp = [SELECT Id, HasFactFisc__c FROM Opportunity WHERE Id = :opportunityId];

        if (opp.HasFactFisc__c) {
            try {
                // List<Linea__c> lines = new List<Linea__c>();
                List<Credito__c> credits = new List<Credito__c>();
                // lines = [SELECT Id, Prodotto__r.Codice__c FROM Linea__c WHERE Opportunity__c = :opportunityId AND Prodotto__r.Codice__c IN ('744','464','844','364','644','534')];
                credits = [SELECT Id, WGC_Anno__c, WGC_Tipo_rimborso__c, WGC_Progressivo_ICAR__c, WGC_UniqueCode__c FROM Credito__c WHERE WGC_Linea__r.Opportunity__c = :opportunityId AND WGC_Invia_Credito__c = true];

                for (Credito__c c : credits) {
                    if (String.isBlank(c.WGC_UniqueCode__c)) {
                        if (c.WGC_Anno__c == null || c.WGC_Tipo_rimborso__c == null || c.WGC_Progressivo_ICAR__c == null)
                            throw new Ex.WSException('Errore nella generazione automatica dei dati di fattura. Contatta un amministratore.');
                        else
                            c.WGC_UniqueCode__c = c.WGC_Anno__c + '-' + c.WGC_Tipo_rimborso__c + '-' + c.WGC_Progressivo_ICAR__c;
                    }
                }

                if (credits.size() > 0)
                    update credits;
            } catch (Exception e) {
                errorMsg = e.getMessage();
                System.debug('@@@@ MB - TEN: ' + e.getMessage() + ' --- ' + e.getStackTraceString());
            }
        }

        return errorMsg;
    }

    @AuraEnabled
    public static WGC_PC_CartController.WrapperResponse saveCrediti(String opportunityId, List<Credito__c> crediti) {
        return WGC_PC_CartController.saveCrediti(opportunityId, crediti);
    }

    @AuraEnabled
    public static String saveEventiNegativiInfo(Opportunity opportunity) {
        String retMessage = '';
        
        try {
            update opportunity;
        } catch (Exception e) {
            System.debug('@@@@ MB - TEN: ' + e.getMessage() + ' --- ' + e.getStackTraceString());
            retMessage = e.getMessage();
        }

        return retMessage;
    }

    /* END - FACTORING FISCALE - INBONIS */

    /* START - BANCA CORPORATE */

    @AuraEnabled
    public static WrapperResponseWs saveCorporateLines(String p){
        CtrlWizardOpportunity.WoPayload payload = (CtrlWizardOpportunity.WoPayload) JSON.deserialize(p, CtrlWizardOpportunity.WoPayload.Class);

        WrapperResponseWs response = new WrapperResponseWs();

        try{
            if(payload.pbc.size() > 0){
                Opportunity opp = [SELECT Id, WGC_Prodotti_Selezionati__c FROM Opportunity WHERE Id =: payload.opportunityId];
                // Id rtCorporate = [SELECT Id FROM RecordType WHERE SObjectType = 'Linea__c' AND DeveloperName = 'Corporate'].Id;
                // Id rtFido = [SELECT Id FROM RecordType WHERE SObjectType = 'Linea__c' AND DeveloperName = 'Fido'].Id;
                Map<String, SObject> rtMap = (Map<String,SObject>) U.keyBy([SELECT Id, DeveloperName FROM RecordType], 'DeveloperName');
                Map<String,Sobject> prodMap = (Map<String,Sobject>)U.keyBy([SELECT Id, Name, CodiceUnivoco__c, Codice__c FROM Prodotto__c], 'CodiceUnivoco__c');
                System.debug('@@@ prodMap ' + JSON.serialize(prodMap));
                Map<String,Sobject> existingLines = (Map<String,Sobject>) U.keyBy([SELECT Id, Prodotto__r.Name, Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE RecordType.DeveloperName = 'Corporate' AND Opportunity__c =: payload.opportunityId], 'Prodotto__r.CodiceUnivoco__c');
                List<Linea__c> newLines = new List<Linea__c>();
                Set<Id> newLinesIds = new Set<Id>();
                Boolean checkCC = false;

                for(CtrlWizardOpportunity.WoProdotto newLine : payload.pbc){
                    System.debug('@@@ newLine ' + JSON.serialize(newLine));
                    Linea__c l = new Linea__c(
                        Id = newLine.id,
                        Opportunity__c = payload.opportunityId,
                        // RecordTypeId = rtCorporate,
                        RecordTypeId = (Id)rtMap.get('Corporate').get('Id'),
                        Prodotto__c = prodMap.get(newLine.tipo) != null ? (Id)prodMap.get(newLine.tipo).get('Id') : null, // TODO Togliere controllo, dovrebbe essere sempre presente
                        Importo__c = newLine.importo,
                        WGC_Tipologia__c = newLine.tipologiaConto,
                        WGC_Utilizzo_CC_IFIS_Impresa__c = newLine.utilizzoCC,
                        WGC_Seleziona_CC_IFIS_Impresa_esistente__c = (newLine.utilizzoCC == 'Nuovo' ? '' : newLine.CCSelezionato)
                    );
                    newLines.add(l);

                    //Controllo il tipo di prodotto per la generazione delle linee fido di appoggio
                    //AnticipoFatture
                    if(String.valueOf(prodMap.get(newLine.tipo).get('CodiceUnivoco__c')) == COD_ANTICIPO_FATTURE){
                        Linea__c l2 = new Linea__c(
                            Id = existingLines.get(COD_FIDO_ANTICIPO_FATTURE) != null ? (Id)existingLines.get(COD_FIDO_ANTICIPO_FATTURE).get('Id') : null,
                            Opportunity__c = payload.opportunityId,
                            RecordTypeId = (Id)rtMap.get('Corporate').get('Id'),
                            Prodotto__c = (Id)prodMap.get(COD_FIDO_ANTICIPO_FATTURE).get('Id'),
                            Importo__c = newLine.importo
                        );
                        newLines.add(l2);
                    }
                    //SBF
                    if(String.valueOf(prodMap.get(newLine.tipo).get('CodiceUnivoco__c')) == COD_SBF){
                        //Linea di fido SBF
                        Linea__c l2 = new Linea__c(
                            Id = existingLines.get(COD_FIDO_SBF) != null ? (Id)existingLines.get(COD_FIDO_SBF).get('Id') : null,
                            Opportunity__c = payload.opportunityId,
                            RecordTypeId = (Id)rtMap.get('Corporate').get('Id'),
                            Prodotto__c = (Id)prodMap.get(COD_FIDO_SBF).get('Id'),
                            Importo__c = newLine.importo
                        );
                        newLines.add(l2);


                        //Linea Conto Cedenti Portafoglio SBF, la creo solo se il campo tipologiaConto è "Conto Doppio"
                        if(newLine.tipologiaConto == 'Conto Doppio'){
                            Linea__c l3 = new Linea__c(
                                Id = existingLines.get(COD_CONTO_ANTICIPI_PTF) != null ? (Id)existingLines.get(COD_CONTO_ANTICIPI_PTF).get('Id') : null,
                                Opportunity__c = payload.opportunityId,
                                RecordTypeId = (Id)rtMap.get('Corporate').get('Id'),
                                Prodotto__c = (Id)prodMap.get(COD_CONTO_ANTICIPI_PTF).get('Id'),
                                Importo__c = newLine.importo
                            );
                            newLines.add(l3);
                        }
                    }

                    //Controllo per eliminare il conto corrente se esistente
                    if(!checkCC && newLine.utilizzoCC == 'Nuovo'){
                        checkCC = true;
                    }

                }

                String condizione = '%' + prodMap.get('IfisImpresa').get('CodiceUnivoco__c') + '%';
                System.debug('@@@ condizione ' + condizione);
                List<Linea__c> CCLines = new List<Linea__c>([SELECT Id, Prodotto__r.Name, Importo__c FROM Linea__c WHERE Opportunity__c =: payload.opportunityId AND Prodotto__r.CodiceUnivoco__c LIKE: condizione/*AND RecordType.DeveloperName = 'Fido'*/]);
                System.debug('@@@ CCLines ' + JSON.serialize(CCLines));

                if(!checkCC && payload.pbc.size() > 0){
                    // delete [SELECT Id FROM Linea__c WHERE Opportunity__c =: payload.opportunityId AND RecordType.DeveloperName = 'Fido'];
                    Delete CCLines;
                    opp.WGC_Prodotti_Selezionati__c = opp.WGC_Prodotti_Selezionati__c.replace(';C/C Imprese Residente Euro','');
                    opp.WGC_Prodotti_Selezionati__c = opp.WGC_Prodotti_Selezionati__c.replace('C/C Imprese Residente Euro;','');
                    Update opp;
                } else if(payload.pbc.size() > 0 && CCLines.isEmpty()){
                    Linea__c cc = new Linea__c();
                    cc.RecordTypeId = (Id)rtMap.get('Fido').get('Id');
                    cc.Opportunity__c = payload.opportunityId;
                    cc.Prodotto__c = (Id)prodMap.get('IfisImpresaNonAffidato').get('Id');
                    cc.Anatocismo__c = true;
                    newLines.add(cc);

                    opp.WGC_Prodotti_Selezionati__c = opp.WGC_Prodotti_Selezionati__c += ';C/C Imprese Residente Euro';
                    Update opp;
                    //Utilizzato per aggiornare il prodotto associato in base alla presenza dell'importo del fido su CC, dato che viene inserito in un secondo momento //TODO Scommentare
                } // else if(checkCC && !CCLines.isEmpty()){
                //     // delete CCLines;
                //     Boolean checkImporto = false;
                //     Decimal importo = 0;
                //     for(Linea__c l : CCLines){
                //         if(l.Prodotto__r.Name == 'Fido'){
                //             checkImporto = true;
                //             importo = l.Importo__c;
                //             break;
                //         }
                //     }

                //     for(Linea__c l : CCLines){
                //         if(l.Prodotto__r.Name.contains('C/C')){
                //             l.Prodotto__c = checkImporto ? (Id)prodMap.get('IfisImpresa').get('Id') : (Id)prodMap.get('IfisImpresaNonAffidato').get('Id');
                //             l.Importo__c = importo;
                //             newLines.add(l);
                //         }
                //     }  
                // }

                Upsert newLines;

                for(Linea__c l : newLines){
                    newLinesIds.add(l.Id);
                }

                Map<Id, Linea__c> oldLineeMap = new Map<Id, Linea__c>([SELECT Id, Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Opportunity__c =: payload.opportunityId AND RecordTypeId =: (Id)rtMap.get('Corporate').get('Id') AND Id NOT IN: newLinesIds ]);
                delete oldLineeMap.values();

                response.data = CtrlWizardOpportunity.editRsf(payload.opportunityId);
            } else {
                Map<String, SObject> rtMap = (Map<String,SObject>) U.keyBy([SELECT Id, DeveloperName FROM RecordType], 'DeveloperName');
                delete [SELECT Id FROM Linea__c WHERE Opportunity__c =: payload.opportunityId AND RecordTypeId =: (Id)rtMap.get('Corporate').get('Id')];
            }
        } catch (exception e){
            response.success = false;
            response.msg = e.getMessage() + ' -- ' +  e.getLineNumber();
            System.debug('@@@ msg ' + e.getMessage() + ' -- ' + e.getLineNumber());
        }

        return response;
    }

    @AuraEnabled
    public static WrapperResponseWs getCCData(Id opportunityId){
        WrapperResponseWs resp = new WrapperResponseWs();
        // Account acc = [SELECT Id, Name, NDGGruppo__c FROM Account WHERE Id =: accountId];
        Opportunity opp = [SELECT Id, Name, Account.NDGGruppo__c FROM Opportunity WHERE Id =: opportunityId];
        WGC_WsUtils_Cart.InputPayloadAnag11 payload = new WGC_WsUtils_Cart.InputPayloadAnag11(opp.Account.NDGGruppo__c, false, false);

        try{
            // WsRestInput input = new WsRestInput(payload);
            WGC_WsUtils_Cart.PayloadResponseAnag11 response = (WGC_WsUtils_Cart.PayloadResponseAnag11)WGC_WsUtils_Cart.callAnag11(payload);
            resp.data = response;
        } catch (exception e){
            resp.msg = e.getMessage() + ' -- ' + e.getLineNumber() + ' -- ' + e.getStackTraceString();
            resp.success = false;
        }

        return resp;
    }

    @AuraEnabled
    public static List<WGC_Condizioni_Banca_Corporate__mdt> getCondizioniBC(String opportunityId, String codProd){
        //Linea recuperata per verificare che sia a Conto Unico o Conto Doppio
        String tipoConto = [SELECT Id, WGC_Tipologia__c FROM Linea__c WHERE Opportunity__c =: opportunityId AND Prodotto__r.CodiceUnivoco__c =: codProd ].WGC_Tipologia__c == 'Conto Unico' ? '01' : '02';

        return [SELECT Id, Prodotto__c, Codice_Condizione__c, Label__c, Tipo__c, Tipologia_Conto_SBF__c, Valore_Limite__c, Output__c 
                            FROM WGC_Condizioni_Banca_Corporate__mdt 
                            WHERE Prodotto__c =: codProd AND Tipologia_Conto_SBF__c =: tipoConto];
    }   

    /* END - BANCA CORPORATE */

    /* START - CORPORATE ESTERO */

    @AuraEnabled
    public static WrapperResponseWs saveCorporateEstero(String payload){
        WrapperResponseWs response = new WrapperResponseWs();

        try{
            CtrlWizardOpportunity.WoPayload p = (CtrlWizardOpportunity.WoPayload) JSON.deserialize(payload, CtrlWizardOpportunity.WoPayload.Class);
            System.debug('@@@ payload ' + JSON.serialize(p));
            if(p.pbce.size() > 0){
                Opportunity opp = [SELECT Id, WGC_Prodotti_Selezionati__c FROM Opportunity WHERE Id =: p.opportunityId];
                List<Linea__c> newLines = new List<Linea__c>();
                Set<Id> newLineIds = new Set<Id>();
                Map<String,Sobject> prodMap = (Map<String,Sobject>)U.keyBy([SELECT Id, Name, CodiceUnivoco__c, Codice__c FROM Prodotto__c], 'CodiceUnivoco__c');
                Map<String, SObject> rtMap = (Map<String,SObject>) U.keyBy([SELECT Id, DeveloperName FROM RecordType], 'DeveloperName');
                Boolean checkCC = false;

                for(CtrlWizardOpportunity.WoProdotto line : p.pbce){
                    System.debug('@@@ line.id ' + line.id);
                    String tipo = ( line.tipo.contains('GaranziaInternazionale') ? ( line.durataGG >= 540 ? 'GaranziaInternazionaleLT' : 'GaranziaInternazionaleBT' ) : line.tipo ); 
                    Linea__c newLine = new Linea__c(
                        Id = line.id,
                        Opportunity__c = p.opportunityId,
                        RecordTypeId = (Id)rtMap.get(RT_CORPORATE_ESTERO).get('Id'),
                        Prodotto__c = (Id)prodMap.get(tipo).get('Id'), //(line.tipo.contains('GaranziaInternazionale') && line.durataGG >= 180 ? (Id)prodMap.get('GaranziaInternazionaleLT').get('Id') : (line.tipo.contains('GaranziaInternazionale') && line.durataGG < 180 ? (Id)prodMap.get('GaranziaInternazionaleBT').get('Id') : (Id)prodMap.get(line.tipo).get('Id'))), // TODO Togliere controllo, dovrebbe essere sempre presente
                        Importo__c = line.importo,
                        DivisaNew__c = line.divisa,
                        //WGC_Finalita_Estero__c = line.finalitaExport,
                        //WGC_Lista_Documenti__c = line.listaDocumenti,
                        WGC_Tipologia_Estero__c = line.tipologiaImpExp,
                        WGC_Affidamento__c = line.affidamento == 'S' ? true : false, 
                        Durata__c = line.durataGG,
                        WGC_Tipo_di_garanzia__c = line.tipoGaranzia,
                        WGC_Utilizzo_CC_IFIS_Impresa__c = line.utilizzoCC,
                        WGC_Seleziona_CC_IFIS_Impresa_esistente__c = line.utilizzoCC == 'Nuovo' ? '' : line.CCSelezionato
                    );
                    System.debug('@@@ newLine ' + JSON.serialize(newLine));
                    newLines.add(newLine);

                    //Controllo per eliminare il conto corrente se esistente
                    if(!checkCC && line.utilizzoCC == 'Nuovo'){
                        checkCC = true;
                    }
                }

                String condizione = '%' + prodMap.get('IfisImpresa').get('CodiceUnivoco__c') + '%';
                List<Linea__c> CCLines = new List<Linea__c>([SELECT Id, Prodotto__r.Name, Importo__c FROM Linea__c WHERE Opportunity__c =: p.opportunityId AND Prodotto__r.CodiceUnivoco__c LIKE: condizione]);

                if(!checkCC && p.pbce.size() > 0){
                    Delete CCLines;
                    opp.WGC_Prodotti_Selezionati__c = opp.WGC_Prodotti_Selezionati__c.replace(';C/C Imprese Residente Euro','');
                    opp.WGC_Prodotti_Selezionati__c = opp.WGC_Prodotti_Selezionati__c.replace('C/C Imprese Residente Euro;','');
                    Update opp;
                } else if(p.pbce.size() > 0 && CCLines.isEmpty()){
                    Linea__c cc = new Linea__c(
                        RecordTypeId = (Id)rtMap.get('Fido').get('Id'),
                        Opportunity__c = p.opportunityId,
                        Prodotto__c = (Id)prodMap.get('IfisImpresaNonAffidato').get('Id'),
                        Anatocismo__c = true
                    );
                    newLines.add(cc);

                    opp.WGC_Prodotti_Selezionati__c = opp.WGC_Prodotti_Selezionati__c += ';C/C Imprese Residente Euro';
                    Update opp;
                }

                Upsert newLines;

                for(Linea__c l : newLines){
                    newLineIds.add(l.Id);
                }

                System.debug('@@@ newLines ' + JSON.serialize(newLines));

                Delete [SELECT Id FROM Linea__c WHERE Opportunity__c =: p.opportunityId AND Id NOT IN: newLineIds AND RecordTypeId =: (Id)rtMap.get(RT_CORPORATE_ESTERO).get('Id') ];

                response.data = CtrlWizardOpportunity.editRsf(p.opportunityId);

            } else {
                Map<String, SObject> rtMap = (Map<String,SObject>) U.keyBy([SELECT Id, DeveloperName FROM RecordType], 'DeveloperName');
                Delete [SELECT Id FROM Linea__c WHERE Opportunity__c =: p.opportunityId AND RecordTypeId =: (Id)rtMap.get(RT_CORPORATE_ESTERO).get('Id') ];
            }
        } catch (Exception e){
            System.debug('@@@ ex ' + e.getMessage() + ' -- ' + e.getStackTraceString());
            response.msg = e.getStackTraceString();
            response.success = false;
        }

        return response;
    }

    /* END - CORPORATE ESTERO */

    @AuraEnabled
    public static List<ParamWrapper> compareAndGroupParams(){
        List<ParametroProdotto__c> pp = [SELECT Id, Default__c, Dominio__c, Parametro__r.CodiceUnivoco__c, Prodotto__r.Codice__c, Parametro__r.Tipologia__c, Parametro__r.Name, Prodotto__r.Name, Sezione__c FROM ParametroProdotto__c];
        List<Compare_Parametri_prodotto__c> cpp = [SELECT Id, ALT_DOMINIO__c, COD_LINEA_SISTEMA__c, COD_PARAMETRO__c, LINEA_PARAMETRO__c, PRG_VALORE__c, VALORE_CODICE__c, VALORE_DESCRIZ__c, VALORE_LABEL__c, Default__c, Visibilit__c FROM Compare_Parametri_prodotto__c];
        Map<String, Compare_Parametri_prodotto__c> cppMap = new Map<String, Compare_Parametri_prodotto__c>();
        Map<String, String> cppMapDominio = new Map<String, String>();
        Map<String, String> cppMapDefault = new Map<String, String>();
        Map<String, Boolean> cppMapVisibility = new Map<String, Boolean>();
        Set<String> picklistKeys = new Set<String>();
        Set<String> oldParamsKeys = new Set<String>();
        Set<String> newParamsKeys = new Set<String>();
        Set<String> paramsNotForChange = new Set<String>();
        List<ParamWrapper> params2delete = new List<ParamWrapper>();
        List<ParamWrapper> params2add = new List<ParamWrapper>();
        List<ParamWrapper> params2change = new List<ParamWrapper>();
        List<ParamWrapper> params = new List<ParamWrapper>();

        // ciclo per recuperare le chiavi parametro - prodotto dei parametri picklist
        for (ParametroProdotto__c tmp_pp : pp) {
            newParamsKeys.add(tmp_pp.Prodotto__r.Codice__c + ' - ' + tmp_pp.Parametro__r.CodiceUnivoco__c);
            if (tmp_pp.Parametro__r.Tipologia__c == 'Picklist' || tmp_pp.Parametro__r.Tipologia__c == 'Multi-picklist')
                picklistKeys.add(tmp_pp.Prodotto__r.Codice__c + ' - ' + tmp_pp.Parametro__r.CodiceUnivoco__c);
        }
        // ciclo per mappare la chiave parametro - prodotto con il rispettivo dominio dal file csv
        for (Compare_Parametri_prodotto__c tmp_cpp : cpp) {
            if (picklistKeys.contains(tmp_cpp.LINEA_PARAMETRO__c)) {
                if (!cppMapDominio.containsKey(tmp_cpp.LINEA_PARAMETRO__c)) {
                    // cppMapDominio.put(tmp_cpp.LINEA_PARAMETRO__c, tmp_cpp.VALORE_LABEL__c);
                    cppMapDominio.put(tmp_cpp.LINEA_PARAMETRO__c, tmp_cpp.ALT_DOMINIO__c);
                    if (tmp_cpp.Default__c == 'S')
                    	cppMapDefault.put(tmp_cpp.LINEA_PARAMETRO__c, tmp_cpp.VALORE_CODICE__c);
                }
                else {
                    // cppMapDominio.put(tmp_cpp.LINEA_PARAMETRO__c, (cppMapDominio.get(tmp_cpp.LINEA_PARAMETRO__c) + ';' + tmp_cpp.VALORE_LABEL__c));
                    cppMapDominio.put(tmp_cpp.LINEA_PARAMETRO__c, (cppMapDominio.get(tmp_cpp.LINEA_PARAMETRO__c) + ';' + tmp_cpp.ALT_DOMINIO__c));
                    if (tmp_cpp.Default__c == 'S')
                    	cppMapDefault.put(tmp_cpp.LINEA_PARAMETRO__c, tmp_cpp.VALORE_CODICE__c);
                }
            }
            oldParamsKeys.add(tmp_cpp.LINEA_PARAMETRO__c);
            cppMapVisibility.put(tmp_cpp.LINEA_PARAMETRO__c, tmp_cpp.Visibilit__c);
            if (tmp_cpp.Default__c != null && tmp_cpp.Default__c != 'N' && tmp_cpp.Default__c != 'S')
                cppMapDefault.put(tmp_cpp.LINEA_PARAMETRO__c, tmp_cpp.Default__c);
            if (!cppMap.containsKey(tmp_cpp.LINEA_PARAMETRO__c))
                cppMap.put(tmp_cpp.LINEA_PARAMETRO__c, tmp_cpp);
        }

        // ciclo sui parametri "old" per aggiungere i parametri in "uscita"
        // for (ParametroProdotto__c tmp_pp : pp) {
        //     if (
        //         oldParamsKeys.contains(tmp_pp.Prodotto__r.Codice__c + ' - ' + tmp_pp.Parametro__r.CodiceUnivoco__c) &&
        //         !newParamsKeys.contains(tmp_pp.Prodotto__r.Codice__c + ' - ' + tmp_pp.Parametro__r.CodiceUnivoco__c)
        //     ) {
        //         paramsNotForChange.add(tmp_pp.Prodotto__r.Codice__c + ' - ' + tmp_pp.Parametro__r.CodiceUnivoco__c);
        //         ParamWrapper wrap = new ParamWrapper();
        //         Param2Compare tmp_param = new Param2Compare();
        //         tmp_param.defaultValue = tmp_pp.Default__c;
        //         tmp_param.codiceParametro = tmp_pp.Parametro__r.CodiceUnivoco__c;
        //         tmp_param.codiceProdotto = tmp_pp.Prodotto__r.Codice__c;
        //         tmp_param.dominio = tmp_pp.Dominio__c;
        //         wrap.oldParams = tmp_param;
        //         params2delete.add(wrap);
        //     }
        // }

        // ciclo sui parametri "new" per aggiungere i parametri in "entrata"
        for (String key : cppMap.keySet()) {
            if (
                !oldParamsKeys.contains(key) &&
                newParamsKeys.contains(key)
            ) {
                paramsNotForChange.add(key);
                ParamWrapper wrap = new ParamWrapper();
                Param2Compare tmp_param = new Param2Compare();
                tmp_param.defaultValue = cppMapDefault.get(key);// cppMap.get(key).VALORE_CODICE__c;
                tmp_param.codiceParametro = cppMap.get(key).COD_PARAMETRO__c;
                tmp_param.codiceProdotto = cppMap.get(key).COD_LINEA_SISTEMA__c;
                tmp_param.dominio = cppMapDominio.get(key);
                wrap.newParams = tmp_param;
                params2add.add(wrap);
            }
        }
// System.debug('@@@@ cppMap: ' + cppMap);
        // ciclo sui parametri rimasti per aggiungere i parametri "in modifica"
        for (ParametroProdotto__c tmp_pp : pp) {
            String key = tmp_pp.Prodotto__r.Codice__c + ' - ' + tmp_pp.Parametro__r.CodiceUnivoco__c;
            if (!paramsNotForChange.contains(key) && cppMap.containsKey(key)) {
                if (
                    (tmp_pp.Default__c != cppMapDefault.get(key)) ||
                    (cppMapDominio.containsKey(key) && tmp_pp.Dominio__c != null ? (tmp_pp.Dominio__c.toUpperCase() != cppMapDominio.get(key)) : false) ||
                    (tmp_pp.Dominio__c == null && cppMapDominio.containsKey(key)) ||
                    ((tmp_pp.Sezione__c == 'PN01' && cppMapVisibility.get(key) == false) || (tmp_pp.Sezione__c != 'PN01' && cppMapVisibility.get(key) == true))
                ) {
                    // System.debug('@@@@ tmp_pp: ' + tmp_pp);
                    // System.debug('@@@@ key: ' + key);
                    ParamWrapper wrap = new ParamWrapper();
                    Param2Compare tmp_param_old = new Param2Compare();
                    Param2Compare tmp_param_new = new Param2Compare();
                    tmp_param_old.defaultValue = tmp_pp.Default__c;
                    tmp_param_old.codiceParametro = tmp_pp.Parametro__r.CodiceUnivoco__c;
                    tmp_param_old.codiceProdotto = tmp_pp.Prodotto__r.Codice__c;
                    tmp_param_old.parametro = tmp_pp.Parametro__r.Name;
                    tmp_param_old.prodotto = tmp_pp.Prodotto__r.Name;
                    tmp_param_old.dominio = (tmp_pp.Dominio__c != null ? tmp_pp.Dominio__c.toUpperCase() : '');
                    tmp_param_old.visibility = (tmp_pp.Sezione__c != 'PN01');
                    wrap.oldParams = tmp_param_old;
                    tmp_param_new.defaultValue = cppMapDefault.get(key);
                    tmp_param_new.codiceParametro = cppMap.get(key).COD_PARAMETRO__c;
                    tmp_param_new.codiceProdotto = cppMap.get(key).COD_LINEA_SISTEMA__c;
                    tmp_param_new.parametro = tmp_pp.Parametro__r.Name;
                    tmp_param_new.prodotto = tmp_pp.Prodotto__r.Name;
                    tmp_param_new.dominio = cppMapDominio.get(key);
                    tmp_param_new.visibility = cppMapVisibility.get(key);
                    wrap.newParams = tmp_param_new;
                    params2change.add(wrap);
                }
            }
        }

        // params.addAll(params2delete);
        params.addAll(params2add);
        params.addAll(params2change);

        return params;
    }

    public class ParamWrapper {
        
        @AuraEnabled public Param2Compare oldParams;
        @AuraEnabled public Param2Compare newParams;

        public ParamWrapper(){
            oldParams = new Param2Compare();
            newParams = new Param2Compare();
        }
    }

    public class Param2Compare {
        
        @AuraEnabled public String defaultValue;
        @AuraEnabled public String codiceParametro;
        @AuraEnabled public String codiceProdotto;
        @AuraEnabled public String parametro;
        @AuraEnabled public String prodotto;
        @AuraEnabled public String dominio;
        @AuraEnabled public Boolean visibility;
        
        public Param2Compare(){
            defaultValue = '';
            codiceParametro = '';
            codiceProdotto = '';
            parametro = '';
            prodotto = '';
            dominio = '';
        }
    }

    /* END - METODI PER GESTIONE DASHBOARD PARAMETRI */

    /* METODO ASYNC DI AGGIORNAMENTO STATO OPPORTUNITA' PER TRIGGER LINEA-PRODOTTO DWH */

    @future
    public static void updateStageNameAsync(Map<String, String> opptyMap) {
        try{
            List<Opportunity> oppToUpdate = new List<Opportunity>();

            for (String oppId : opptyMap.keySet()) {
                Opportunity o = new Opportunity();
                o.Id = oppId;
                o.StageName = opptyMap.get(oppId);
                oppToUpdate.add(o);
            }

            update oppToUpdate;
        } catch(exception e){
            Log__c exLog = new Log__c(ErorrMessage__c = e.getTypeName() + ' -- ' + e.getLineNumber() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getMessage(), Source__c = 'Log linee prodotto');
            Insert exLog;
        }
    }

    /* END - METODO ASYNC DI AGGIORNAMENTO STATO OPPORTUNITA' PER TRIGGER LINEA-PRODOTTO DWH */

    /*..........................................*/
    /* Wrapper class to manage picklist options */
    /*..........................................*/
    
    public class PicklistValue {
        
        @AuraEnabled public String field;
        @AuraEnabled public List<String> options;
        
        public PicklistValue(){
            field = '';
            options = new List<String>();
        }
    }

    // UTILITY - METHOD TO GET PICKLIST DEPENDENT OPTIONS BY ARRAY OF OBJECT AND FIELD'S API NAME (es. [{"controller":"Opportunity.ControllerField__c","field":"Opportunity.ControllingField__c"}])
    @AuraEnabled
    public static String getDependentPicklistValuesFromArray(List<Object> arrayFields){
        Map<String, Map<String, List<String>>> result = new Map<String, Map<String, List<String>>>();
        for (Object fields : arrayFields) {
            Map<String, String> fieldsMap = new Map<String, String>();

            Map<Object, Object> tmpFields = (Map<Object, Object>)fields;
            for (Object k : tmpFields.keySet())
                fieldsMap.put(k.toString(), tmpFields.get(k).toString());
            
            String objectName = fieldsMap.get('field').left(fieldsMap.get('field').indexOf('.', 0));
            String controller = fieldsMap.get('controller').replace(objectName+'.', '');
            String field = fieldsMap.get('field').replace(objectName+'.', '');
            System.debug('@@@@ controller: ' + controller);
            System.debug('@@@@ field: ' + field);

            Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
            Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap();
            System.debug('@@@@ field_map: ' + field_map);
            System.debug('@@@@ controllerDescribe: ' + field_map.get(controller));
            System.debug('@@@@ fieldDescribe: ' + field_map.get(field));
            Map<String, List<String>> values = WGC_HL_FieldDescribeUtil.getDependentOptionsImpl(field_map.get(field.toLowerCase()), field_map.get(controller.toLowerCase()));
            result.put(controller+'|'+field, values);
        }

        return JSON.serialize(result);
    }

    // UTILITY - METHOD TO GET PICKLIST OPTIONS BY ARRAY OF OBJECT AND FIELD'S API NAME (es. "Opportunity.StageName")
    @AuraEnabled
    public static String getPicklistValuesFromArray(List<String> arrayFields){
        List<PicklistValue> picklistValues = new List<PicklistValue>();
        // List<String> desc = new List<String>();

        for (String field : arrayFields) {
            // desc = field.split('.', 1);
            // if (desc.size() == 2)

            PicklistValue pv = new PicklistValue();
            pv.field = field;
            if (field != 'NDGLinea__c.DivisaNew__c')
                pv.options = WizardOpportunityController.getPicklistValues(field.left(field.indexOf('.')), field.right(field.length() - field.indexOf('.') - 1), false);
            else {
                List<String> availableOptions = WizardOpportunityController.getPicklistValues(field.left(field.indexOf('.')), field.right(field.length() - field.indexOf('.') - 1), false);
                List<String> availableDivise = CtrlWizardOpportunity.getDiviseDisponibili();
                for (String opt : availableOptions)
                    if (availableDivise.contains(opt.left(opt.indexOf(':'))))
                        pv.options.add(opt);
                }

            picklistValues.add(pv);
        }

        return JSON.serialize(picklistValues);
    }

    // UTILITY - METHOD TO GET PICKLIST OPTIONS BY OBJECT AND FIELD'S API NAME
    @AuraEnabled
    public static List<String> getPicklistValues(String objectName, String field_apiname, Boolean nullRequired){
        List<String> optionlist = new List<String>();
        
        Map<String,Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Map<String, Schema.SObjectField> field_map = gd.get(objectName.toLowerCase()).getDescribe().fields.getMap(); 
        
        List<Schema.PicklistEntry> picklistValues = field_map.get(field_apiname).getDescribe().getPickListValues();
        
        if(nullRequired == true){
            optionlist.add('--seleziona--');
        }
        
        for (Schema.PicklistEntry pv : picklistValues) {
            optionlist.add((pv.getValue() != pv.getLabel() ? pv.getValue() + ':' + pv.getLabel() : pv.getValue()));
        }
        return optionlist;
    }

    // UTILITY - METHOD TO GET OBJECT FIELDS' LABELS
    @AuraEnabled
    public static Map<String, String> getObjectLabels(String objectName){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        Map<String, String> resultMap = new Map<String, String>();

        for (String fieldName: fieldMap.keySet())
            resultMap.put(fieldName, fieldMap.get(fieldName).getDescribe().getLabel());

        return resultMap;
    }

    //SM - Spese Istruttoria
    @AuraEnabled
    public static List<WGC_Spese_Istruttoria__mdt> getDatiSpeseIstruttoria(Id opportunityId){
        Map<String, WGC_Spese_Istruttoria__mdt> metadatiSI = new Map<String, WGC_Spese_Istruttoria__mdt>([SELECT Id, DeveloperName, Default_Value__c, Label__c, Prodotti_Coinvolti__c FROM WGC_Spese_Istruttoria__mdt ORDER BY DeveloperName]);
        Set<String> prodottiPossibili = new Set<String>();

        for(WGC_Spese_Istruttoria__mdt meta : metadatiSI.values()){
            List<String> prodottiMeta = meta.Prodotti_Coinvolti__c.split(';');
            prodottiPossibili.addAll(prodottiMeta);
        }

        List<Linea__c> lineeOpty = new List<Linea__c>([SELECT Id, Prodotto__r.CodiceUnivoco__c FROM Linea__c WHERE Opportunity__c =: opportunityId AND Prodotto__r.CodiceUnivoco__c IN: prodottiPossibili]);

        if(lineeOpty.size() > 0)
            return metadatiSI.values();
        else
            return null;
    }
    
    @AuraEnabled
	public static Boolean checkIfOpenable (String opportunityId) {		
		Opportunity opp = [SELECT OwnerId, StageName, StatoPEF__c, Owner.Profile.Name, Owner.ManagerId, TiAnticipo__c, IsOppNSA__c FROM Opportunity WHERE Id = :opportunityId];
        User cu = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
                
		if(opp.StageName == 'Valutazione Pratica' && String.isBlank(opp.StatoPEF__c) && (cu.Profile.Name == DIREZIONE_COMMERCIALE_PROFILE_NAME || cu.Profile.Name == SYSTEM_ADMIN_PROFILE_NAME || cu.Profile.Name == 'Amministratore Banca Ifis' || cu.Profile.Name == OPERATORE_NSA_PROFILE_NAME))
			return true;
		return false;
	}
	
	@AuraEnabled
	public static void openOpportunity (String opportunityId) {
		Opportunity opp = [select Id, WGC_Data_Fase_Valutazione_Pratica__c, WGC_Data_out_Fase_In_Istruttoria__c, StageName FROM Opportunity WHERE Id = :opportunityId];
		opp.WGC_Data_Fase_Valutazione_Pratica__c = null;
		opp.WGC_Data_out_Fase_In_Istruttoria__c = null;
		opp.IdCartella__c = null;
		opp.StageName = 'In Istruttoria';

		update opp;
    }
    
    @AuraEnabled
    public static String invioPrivacyPF(String opportunityId){
        try{
            Id accountId = [SELECT AccountId FROM Opportunity WHERE Id =: opportunityId].AccountId;
            System.debug('@@@ accountId ' + accountId);
            Id contactId = [SELECT ContactId FROM AccountContactRelation WHERE AccountId =: accountId AND WGC_Esecutore_MAV__c  = true LIMIT 1].ContactId;
            System.debug('@@@ contactId ' + contactId);
            
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
                        DataInserimentoConsensi__c FROM Contact WHERE Id=: contactId];

            accOld.DataInserimentoConsensi__c = System.Today();

            accOld.ConsensoAllaProfilazione__c = false;
            accOld.ConsensoProdottiBancaRicercheMercato__c = false;
            accOld.ConsensoProdottiSocietaTerze__c = false;
            accOld.ConsensoAttivitaPromozionaleTerzi__c = false;
            accOld.ConsensoAttivitaPromRicercheMercato__c = false;
            accOld.ConsensoSoloModalitaTradizionali__c = false;

            String response = WsAnagrafeUtils.WGC_variazione(null, accOld);
            System.debug('@@@ response ' + response);

            Update accOld;

        } catch(QueryException qe){
            return 'Definire l\' esecutore adeguata verifica prima di invia la pratica';
        } catch(Exception e){
            return e.getMessage();
        }

        return null;
    }

    @AuraEnabled
    public static String checkCensimentoAnag(String accountId){
        return WGC_PC_CartController.checkCensimentoAnag(accountId);
    }
}