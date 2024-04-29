trigger WGC_LineaAsyncTrigger on WGC_Linea_Prodotto__ChangeEvent (after insert) {

    System.debug('@@@@ MB - TEN: WGC_LineaAsyncTrigger START');
	if (Funzionalita__c.getInstance().DisabilitaTriggers__c) return;

    //Variabili per debug
    String idOppCheck = '';
    String idLineaCheck = '';
    Map<Id,Opportunity> copyMapOpp = new Map<Id,Opportunity>();

    try{
        List<WGC_Linea_Prodotto__ChangeEvent> changes = Trigger.new;
        
        Set<String> lineIds = new Set<String>();
        
        //Get all record Ids for this change and add it to a set for further processing
        for(WGC_Linea_Prodotto__ChangeEvent lce: changes){
            List<String> recordIds = lce.ChangeEventHeader.getRecordIds();
            lineIds.addAll(recordIds);
        }
        List<WGC_Linea_Prodotto__c> lines = new List<WGC_Linea_Prodotto__c>();
        lines = [SELECT Id, Anagrafica__c, Opportunit__c, Qualifica_Prodotto__c, Opportunit__r.StageName, Codice_Stato__c, Anagrafica__r.WGC_Filo_Diretto_Attivo__c, Anagrafica__r.WGC_Specialista_Filo_Diretto__r.NDGGruppo__c, NDG_Filo_Diretto__c, Data_ultima_cessione__c, RecordType.DeveloperName, RecordType.Name, Tipologia_Prodotto__c, Codice_Linea_Sistema__c, Famiglia_Prodotto__c FROM WGC_Linea_Prodotto__c WHERE Id IN :lineIds ORDER BY Anagrafica__c];
        Set<Id> accId = new Set<Id>();
        Set<Id> oppId = new Set<Id>();

        for(WGC_Linea_Prodotto__c lp : lines){ 
            accId.add(lp.Anagrafica__c);
            oppId.add(lp.Opportunit__c);
        }

        Map<String, List<Linea__c>> linesMap = U.groupBy([SELECT Id, Opportunity__c, Prodotto__r.Codice__c, WGC_Attivata__c, WGC_Data_Attivazione__c FROM Linea__c WHERE Opportunity__c IN :oppId], '{Opportunity__c}_{Prodotto__r.Codice__c}', true);

        //SM - TEN: Crediti per avanzamento pratiche FF
        Map<String, List<Credito__c>> creditiMap = U.groupBy([SELECT Id, Opportunita__c, WGC_Linea__r.Prodotto__r.Codice__c, WGC_Attivata__c, WGC_Data_Attivazione__c FROM Credito__c WHERE Opportunita__c IN : oppId AND WGC_Credito_Confermato__c = true AND WGC_Deliberata__c = true AND WGC_Non_Deliberata__c = false ], '{Opportunita__c}', true);

        System.debug('@@@ creditiMap ' + JSON.serialize(creditiMap));
        
        Map<Id,Account> mapAcc = new Map<ID, Account>([SELECT Id,Ultima_opportunita_creata__c FROM Account WHERE Id IN :accID]);
        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>([SELECT Id, StageName FROM Opportunity WHERE Id IN :oppID AND IsClosed = false]);

        //Debug
        copyMapOpp = mapOpp;

        Map<Id, Account> accToUpdate = new Map<Id, Account>();
        Map<String, String> oppToUpdate = new Map<String, String>();
        List<WGC_Linea_Prodotto__c> linesToUpdate = new List<WGC_Linea_Prodotto__c>();
        List<Linea__c> cartLinesToUpdate = new List<Linea__c>();
        //SM - TEN: Lista crediti da aggiornare
        List<Credito__c> cartCreditiToUpdate = new List<Credito__c>();
        
        for (WGC_Linea_Prodotto__c lp : lines) {

            if (lp.Opportunit__c!= null && lp.Qualifica_Prodotto__c == 'Cliente in avvio' && mapOpp.get(lp.Opportunit__c) != null){
                if (lp.Opportunit__r.StageName != 'Attivazione' || lp.Opportunit__r.StageName != 'Vinta'){
                    //lp.Opportunit__r.StageName = 'Attivazione';
                    //Debug
                    idLineaCheck = String.valueOf(lp.Id);
                    idOppCheck = String.valueOf(lp.Opportunit__c);
                    mapOpp.get(lp.Opportunit__c).StageName = 'Attivazione';
                    oppToUpdate.put(lp.Opportunit__c, 'Attivazione');
                    // MB - TEN: CR 273
                    if (linesMap.get(lp.Opportunit__c + '_' + lp.Codice_Linea_Sistema__c) != null)
                        for (Linea__c l : linesMap.get(lp.Opportunit__c + '_' + lp.Codice_Linea_Sistema__c)) {
                            Linea__c newLine = l;
                            newLine.WGC_Attivata__c = true;
                            newLine.WGC_Data_Attivazione__c = Date.today();
							//A.M. SDHDFNZ-117370 -> Aggiunto nuovo stato linea attivata
							newLine.Stato__c = '14';
                            cartLinesToUpdate.add(newLine);
                        }
                }
            }
            
            if (lp.Opportunit__c != null && lp.Qualifica_Prodotto__c == 'Cliente attivo' && mapOpp.get(lp.Opportunit__c) != null){
                if (lp.Opportunit__r.StageName != 'Vinta'){
                    //lp.Opportunit__r.StageName = 'Vinta';
                    idLineaCheck = lp.Id;
                    idOppCheck = String.valueOf(lp.Opportunit__c);
                    mapOpp.get(lp.Opportunit__c).StageName = 'Vinta';
                    oppToUpdate.put(lp.Opportunit__c, 'Vinta');
                }
                //lp.Anagrafica__r.Ultima_opportunità_creata__c = lp.Opportunit__r.Id;
                mapAcc.get(lp.Anagrafica__c).Ultima_opportunita_creata__c = lp.Opportunit__c;
                if (!accToUpdate.keySet().contains(lp.Anagrafica__c))
                    accToUpdate.put(lp.Anagrafica__c, mapAcc.get(lp.Anagrafica__c));
            }
    System.debug('@@@@ lp: ' + lp);
            // UPDATE SU OGGETTO LINEA; INNESCA NUOVO CICLO DI UPDATE, CON TRIGGER ASINCRONO. LE CONDIZIONI IMPEDISCONO DI POPOLARE LE MAPPE/LISTE AL SECONDO GIRO DEL TRIGGER ASINCRONO
            if (lp.Qualifica_Prodotto__c == 'Cliente attivo' && lp.Codice_Stato__c == '003' && lp.Anagrafica__r.WGC_Filo_Diretto_Attivo__c && String.isBlank(lp.NDG_Filo_Diretto__c)) {
                WGC_Linea_Prodotto__c lpToUpdate = new WGC_Linea_Prodotto__c(Id = lp.Id);
                lpToUpdate.Data_attivazione_linea__c = Date.today();
                lpToUpdate.NDG_Filo_Diretto__c = lp.Anagrafica__r.WGC_Specialista_Filo_Diretto__r.NDGGruppo__c;
                linesToUpdate.add(lpToUpdate);
            }

            //SM - TEN: Avanzamento crediti per pratiche FF
            if(lp.Opportunit__c != null && lp.Qualifica_Prodotto__c == 'Cliente attivo' && mapOpp.get(lp.Opportunit__c) != null && lp.RecordType.DeveloperName == 'CREDITIERARIALI'){
                // if(lp.Opprtunit__r.StageName != 'Vinta'){
                //     idLineaCheck = lp.Id;
                //     idOppCheck = String.valueOf(lp.Opportunit__c);
                //     mapOpp.get(lp.Opportunit__c).StageName = 'Vinta';
                //     oppToUpdate.put(lp.Opportunit__c, 'Vinta');
                // }

                System.debug('@@@ primo controllo');
                if (creditiMap.get(lp.Opportunit__c) != null){
                    System.debug('@@@ secondo controllo');
                    for (Credito__c l : creditiMap.get(lp.Opportunit__c)) {
                        System.debug('@@@ for');
                        Credito__c newCredito = l;
                        newCredito.WGC_Attivata__c = true;
                        newCredito.WGC_Data_Attivazione__c = Date.today();
                        cartCreditiToUpdate.add(newCredito);
                    }
                }
            }
        }
        
        if (accToUpdate.values().size() > 0) update accToUpdate.values();
        if (oppToUpdate.size() > 0) WizardOpportunityController.updateStageNameAsync(oppToUpdate); // update mapOpp.values();
        System.debug('@@@@ linesToUpdate: ' + linesToUpdate);
        if (linesToUpdate.size() > 0) update linesToUpdate;
        if (cartLinesToUpdate.size() > 0) update cartLinesToUpdate;
        
        //SM - TEN: Aggiorno i crediti delle opportunità fast finance
        System.debug('@@@ cartCreditiToUpdate ' + JSON.serialize(cartCreditiToUpdate));
        if(cartCreditiToUpdate.size() > 0) update cartCreditiToUpdate;
        
        System.debug('@@@@ MB - TEN: WGC_LineaAsyncTrigger END');


        System.debug('@@@ SM - Modifica Dettaglio Visite e Prodotti Dettaglio Visite');

        //Recupero i dettagli visite
        List<WGC_Dettaglio_Visite__c> dtList = new List<WGC_Dettaglio_Visite__c>([SELECT Id, Name, Ragione_Sociale__c, Ragione_Sociale__r.WGC_Qualifica_Corporate__c, Ragione_Sociale__r.WGC_Giorni_Ex_cliente_SvilCommFiliali__c, Primo_Prodotto__c, Data_avvio_rapporto__c, CreatedDate, Data_di_Creazione__c, Rapporto_Avviato__c, Data_avvio_rapporto_DWH__c, Famiglia_Primo_Prodotto__c FROM WGC_Dettaglio_Visite__c WHERE Ragione_Sociale__c IN: accID ORDER BY Data_di_Creazione__c DESC ]);
        List<WGC_Dettaglio_Visite__c> dtListToUpd = new List<WGC_Dettaglio_Visite__c>();
        List<WGC_Prodotto_DettaglioVisite__c> prodottiDtListToIns = new List<WGC_Prodotto_DettaglioVisite__c>();
        Map<Id,WGC_Dettaglio_Visite__c> accIdsXDT = new Map<Id,WGC_Dettaglio_Visite__c>();

        // for(WGC_Linea_Prodotto__c linea : lines){
        //     for(WGC_Dettaglio_Visite__c dt : dtList){
        //         if(dt.Ragione_Sociale__c == linea.Anagrafica__c){
        //             accIdsXDT.put(linea.Anagrafica__c, dt);
        //         }
        //     }
        // }

        for(WGC_Dettaglio_Visite__c dt : dtList){
            for(WGC_Linea_Prodotto__c linea : lines){
                if(dt.Ragione_Sociale__c == linea.Anagrafica__c){
                    System.debug('@@@ dt before map ' + JSON.serialize(dt));
                    if(!accIdsXDT.keySet().contains(linea.Anagrafica__c)){
                        accIdsXDT.put(linea.Anagrafica__c, dt);
                    }
                }
            }
        }

        System.debug('@@@ accIdsXDT ' + JSON.serialize(accIdsXDT));

        for(WGC_Linea_Prodotto__c linea : lines){
            for(WGC_Dettaglio_Visite__c dt : accIdsXDT.values()){
                if(linea.Anagrafica__c == dt.Ragione_Sociale__c){
                    WGC_Prodotto_DettaglioVisite__c prodottoDT = new WGC_Prodotto_DettaglioVisite__c(Dettaglio_Visite__c = dt.Id,Prodotto__c = linea.Id);
                    prodottiDtListToIns.add(prodottoDT);

                    if(dt.CreatedDate.Date() <= linea.Data_ultima_cessione__c && dt.Primo_Prodotto__c == null && dt.Data_avvio_rapporto__c == null){
                        dt.Primo_Prodotto__c = linea.Tipologia_Prodotto__c;
                        //dt.Data_avvio_rapporto__c = linea.Data_ultima_cessione__c;
                        //Spostata logica su campo Data_avvio_rapporto_DWH__c
                        dt.Data_avvio_rapporto_DWH__c = linea.Data_ultima_cessione__c;
                        dt.Rapporto_Avviato__c = 'Si';
                        dt.Famiglia_Primo_Prodotto__c = linea.Famiglia_Prodotto__c;
                        dtListToUpd.add(dt);
                    }
                }
            }
        }

        if(!prodottiDtListToIns.isEmpty()) Insert prodottiDtListToIns;

        if(!dtListToUpd.isEmpty()) Update dtListToUpd;

        System.debug('@@@ prodottiDtListToIns ' + JSON.serialize(prodottiDtListToIns));

        System.debug('@@@ dtListToUpd ' + JSON.serialize(dtListToUpd));

    } catch (exception e){
        Log__c exLog = new Log__c(ErorrMessage__c = e.getTypeName() + ' -- ' + e.getLineNumber() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getMessage(), Source__c = 'Log linee prodotto', InputPayload__c = 'Id Opportunity ' + idOppCheck + ' --- Id Linea Prodotto ' + idLineaCheck, OutputPayload__c = JSON.serialize(copyMapOpp));
        Insert exLog;
    }
}