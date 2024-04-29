@RestResource(urlMapping='/v1.0/InserimentoOfferta')
global without sharing class RestInserimentoOffertaInfostore {

    @HttpPost
    global static ResponseWrapper doPost(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        ObjectResponseWrapper response = new ObjectResponseWrapper();

        Savepoint sp = Database.SetSavepoint();

        // Funzionalita__c f = Funzionalita__c.getInstance();
        // Funzionalita__c f = [SELECT Id, Disabilita_tutti_i_trigger__c FROM Funzionalita__c LIMIT 1];
        // f.Disabilita_tutti_i_trigger__c = true;
        // update f;

        try{

            SBQQ.TriggerControl.disable();

            // System.debug('@@@ req ' + req.requestBody.toString());
            
            //Casting del body della request
            Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());

            System.debug('@@@ body ' + JSON.serialize(body));
            //Prendo la quote
            SBQQ__Quote__c quote = (SBQQ__Quote__c)JSON.deserializeStrict(JSON.serialize(body.get('Quote')), SBQQ__Quote__c.Class);
            //Prendo la quote line
            List<SBQQ__QuoteLine__c> qlList = (List<SBQQ__QuoteLine__c>)JSON.deserializeStrict(JSON.serialize(body.get('LineItems')), List<SBQQ__QuoteLine__c>.Class);

            Schema.DescribeSObjectResult dOpp = Schema.SObjectType.Opportunity; 
            Id rtOpp = dOpp.getRecordTypeInfosByDeveloperName().get('WRT_CPQ').getRecordTypeId();

            // Id pbId = [SELECT Id FROM Pricebook2 WHERE Name = 'Prodotti Warrant'].Id;

            // if(quote.SBQQ__Opportunity2__c == null){
                Opportunity opp = new Opportunity(
                    AccountId = quote.SBQQ__Account__c,
                    CloseDate = quote.CloseDate__c,
                    WH_Business_Area__c = quote.WH_Business_Area__c,
                    // Name = quote.Name,
                    Name = quote.Opportunity_Name__c,
                    // ForecastCategoryName = quote.ForecastCategoryName__c,
                    Pricebook2Id = quote.SBQQ__PricebookId__c,
                    // Pricebook2Id = pbId,
                    WRT_Probabilita_rientro_offerta_in_corso__c = 50,
                    Probability = quote.Probability__c,
                    RecordTypeId = rtOpp,
                    StageName = quote.StageName__c,
                    Escludi_da_Template__c = true
                );
                insert opp;

                List<OpportunityLineItem> oppli_list = new List<OpportunityLineItem>();
                for(SBQQ__QuoteLine__c ql : qllist){
                    OpportunityLineItem oppli = new OpportunityLineItem(
                        OpportunityId = opp.Id, 
                        Product2Id = ql.SBQQ__Product__c, 
                        WH_Sottoprogetto__c = ql.WH_Sottoprogetto__c,
                        Quantity = 1,
                        UnitPrice = 0,
                        PricebookEntryId = [SELECT id, name FROM PriceBookEntry WHERE Pricebook2id =: quote.SBQQ__PricebookId__c AND Product2Id =: ql.SBQQ__Product__c ].Id
                    );
                    oppli_list.add(oppli);
                }

                insert oppli_list;
                // System.debug('@@@ ql ' + JSON.serialize(ql));
                
                //Assegno recordType warrant alla quote
                // Schema.DescribeSObjectResult d = Schema.SObjectType.SBQQ__Quote__c; 
                // Id rtQuote = d.getRecordTypeInfosByName().get('Warrant').getRecordTypeId();
                // quote.RecordTypeId = rtQuote;
                quote.SBQQ__Opportunity2__c = opp.Id;
                // qutoe.Opportunity_Name__c = quote.Name;
                // quote.SBQQ__PricebookId__c = pbId;
                
                insert quote;

            //     if(quote.SBQQ__Primary__c){
            //         opp.SBQQ__PrimaryQuote__c = quote.Id;
            //         update opp;    
            //     }
    
            // } else {
            //     insert quote;
            // }


            // Schema.DescribeSObjectResult dQl = Schema.SObjectType.SBQQ__QuoteLine__c; 
            // Id rtQl = Schema.SObjectType.SBQQ__QuoteLine__c.getRecordTypeInfosByDeveloperName().get('Warrant').getRecordTypeId();

            //Aggiungo lookup a quote, il campo è master detail, e non è abilitato il reparenting
            for(SBQQ__QuoteLine__c ql : qlList){
                ql.put('SBQQ__Quote__c', quote.Id);
                // ql.put('RecordTypeId', rtQl);
            }

            System.debug('@@@ qlList ' + JSON.serialize(qlList));
            insert qlList;

            // Map<String,SObject> qlXChiave = (Map<String,SObject>) Utilities.keyBy(qlList, 'Chiave_Esterna__c');
            // System.debug('@@@ qlXChiave ' + qlXChiave);

            //Prendo finanziamenti condizioniOpz e pagamenti
            List<Finanziamenti__c> finanziamenti =  (List<Finanziamenti__c>)JSON.deserializeStrict(JSON.serialize(body.get('Finanziamenti')), List<Finanziamenti__c>.Class);
            // List<Condizione_Opzionale__c> condizioniOpzionali =  (List<Condizione_Opzionale__c>)JSON.deserializeStrict(JSON.serialize(body.get('Condizioni')), List<Condizione_Opzionale__c>.Class);
            List<SObject> condizioni = (List<SObject>) JSON.deserializeStrict(JSON.serialize(body.get('Condizioni')), List<SObject>.Class);
            List<Pagamenti__c> pagamenti =  (List<Pagamenti__c>)JSON.deserializeStrict(JSON.serialize(body.get('Pagamenti')), List<Pagamenti__c>.Class);

            // System.debug('@@@ finanziamenti ' + JSON.serialize(finanziamenti));
            // System.debug('@@@ condizioniOpzionali ' + JSON.serialize(condizioniOpzionali));
            System.debug('@@@ pagamenti ' + JSON.serialize(pagamenti));

            //Associo i finanziamenti alla quote line e li inserisco
            System.debug('@@@ finanziamenti ' + JSON.serialize(finanziamenti));
            for(Finanziamenti__c fin : finanziamenti){
                fin.Quote_Line__c = qlList[0].Id;
            }

            insert finanziamenti;

            //Raggruppo i finanziamenti per Tipologia_Finanziamento_WarrantCPQ__c
            Map<String,SObject> tipoFinMap = (Map<String,SObject>)Utilities.keyBy(finanziamenti, 'Tipologia_Finanziamento_WarrantCPQ__c');
            //Per ogni gruppo di finanziamenti creo una condizione padre
            List<Condizioni__c> condizioniPadre = new List<Condizioni__c>();
            
            Map<String,List<SObject>> FF_CondizioniMap = (Map<String,List<SObject>>) Utilities.groupBy(condizioni, '{FF_WarrantCPQ__c}_{Progressivo__c}', true);

            System.debug('@@@ FF_CondizioniMap ' + JSON.serialize(FF_CondizioniMap));

            for(String key : FF_CondizioniMap.keySet()){
                if(key == 'false_false'){
                    for(SObject sobj : FF_CondizioniMap.get(key)){
                        Condizioni__c c = (Condizioni__c)JSON.deserializeStrict(JSON.serialize(sobj), Condizioni__c.Class);
                        system.debug('@@@ c ' + JSON.serialize(c));
                        System.debug('@@@ c.Tipo_WarrantCPQ__c ' + c.Tipo_WarrantCPQ__c);
                        // Condizioni__c c = new Condizioni__c(Finanziamento__c = (Id)tipoFinMap.get(String.valueOf(sobj.get('Tipologia_Finanziamento_WarrantCPQ__c'))), Quote_Line__c = qlList[0].Id, );
                        // c.Finanziamento__c = (Id)tipoFinMap.get((String)sobj.get('Tipologia_Finanziamento_WarrantCPQ__c')).get('Id');
                        c.Finanziamento__c = tipoFinMap.get((String)sobj.get('Tipologia_Finanziamento_WarrantCPQ__c')) != null ? (Id)tipoFinMap.get((String)sobj.get('Tipologia_Finanziamento_WarrantCPQ__c')).get('Id') : null;
                        c.Quote_Line__c = qlList[0].Id;
                        // c.Tipo_WarrantCPQ__c = c.Progressivo__c ? 'Progressivo' : 'Alternativo';
                        // c.Tipo_WarrantCPQ__c = 'FISSO';
                        condizionipadre.add(c);
                    }
                }
            }

            System.debug('@@@ condizioniPadre1 ' + JSON.serialize(condizioniPadre));

            // insert condizioniPadre;

            // System.debug('@@@ condizioniPadre ' + JSON.serialize(condizioniPadre));

            //Per ogni gruppo di condizioni padre associo una lista di condizioni opzionali
            // Map<String,SObject> CondizioniPadreGroup = (Map<String,SObject>)Utilities.keyBy(condizioniPadre, 'Tipologia_Finanziamento_WarrantCPQ__c');
            // Map<String,List<Condizione_Opzionale__c>> CondizioniOpzGroup = (Map<String,List<Condizione_Opzionale__c>>)Utilities.groupBy(condizioniOpzionali, 'Tipologia_Finanziamento_WarrantCPQ__c');
            // Map<String,List<Condizione_Opzionale__c>> CondizioniOpzGroup = (Map<String,List<Condizione_Opzionale__c>>)Utilities.groupBy(FF_CondizioniMap.get('true'), 'Tipologia_Finanziamento_WarrantCPQ__c');

            List<SObject> CondizioniConPadri = new List<SObject>();

            if(FF_CondizioniMap.get('true_false') != null)
                CondizioniConPadri.addAll(FF_CondizioniMap.get('true_false'));
            if(FF_CondizioniMap.get('false_true') != null)
                CondizioniConPadri.addAll(FF_CondizioniMap.get('false_true'));

            Map<String,List<Condizione_Opzionale__c>> CondizioniOpzGroup = (Map<String,List<Condizione_Opzionale__c>>)Utilities.groupBy(CondizioniConPadri, 'Pag_WarrantCPQ__c');
            // Map<String,List<Condizione_Opzionale__c>> CondizioniOpzGroup2 = (Map<String,List<Condizione_Opzionale__c>>)Utilities.groupBy(FF_CondizioniMap.get('true'), 'Tipologia_Finanziamento_WarrantCPQ__c');

            System.debug('@@@ condizioniOpzGroup ' + JSON.serialize(CondizioniOpzGroup));

            // List<Condizioni__c> condizioniPadre = new List<Condizioni__c>();
            for(String key : CondizioniOpzGroup.keySet()){
                System.debug('@@@ key ' + key);
                System.debug('@@@ CondizioniOpzGroup.get(key) ' + CondizioniOpzGroup.get(key));
                Condizioni__c c = new Condizioni__c(
                    Quote_Line__c = qlList[0].Id,
                    Pag_WarrantCPQ__c = CondizioniOpzGroup.get(key)[0].Pag_WarrantCPQ__c,
                    // Tipo_WarrantCPQ__c = CondizioniOpzGroup.get(key)[0].Tipo_WarrantCPQ__c.toUpperCase(),
                    Tipo_WarrantCPQ__c = CondizioniOpzGroup.get(key)[0].Progressivo__c ? 'Progressivo' : 'Alternativo',
                    Finanziamento__c = tipoFinMap.get((String)CondizioniOpzGroup.get(key)[0].get('Tipologia_Finanziamento_WarrantCPQ__c')) != null ? (Id)tipoFinMap.get((String)CondizioniOpzGroup.get(key)[0].get('Tipologia_Finanziamento_WarrantCPQ__c')).get('Id') : null
                );
                condizioniPadre.add(c);
            }

            System.debug('@@@ condizioniPadre ' + JSON.serialize(condizioniPadre));
            insert condizioniPadre;

            // Map<String,SObject> CondizioniPadreGroup = (Map<String,SObject>)Utilities.keyBy(condizioniPadre, 'Tipologia_Finanziamento_WarrantCPQ__c');
            Map<String,SObject> CondizioniPadreGroup = (Map<String,SObject>) Utilities.keyBy(condizioniPadre, 'Pag_WarrantCPQ__c');

            for(String key : CondizioniOpzGroup.keySet()){
                for(Condizione_Opzionale__c co : CondizioniOpzGroup.get(key)){
                    //CondizionePadre_WarrantCPQ__c è in master detail, reparenting non abilitato
                    //Associo le condizioni opzionali alla condizione padre
                    // co.put('Quote_Line__c', qlList[0].Id);
                    co.put('CondizionePadre_WarrantCPQ__c', (Id)CondizioniPadreGroup.get(co.Pag_WarrantCPQ__c).get('Id'));
                    //OLD
                    // CondizioniPadreGroup.get(co.Tipologia_Finanziamento_WarrantCPQ__c).put('Pag_WarrantCPQ__c', co.Pag_WarrantCPQ__c);
                    // CondizioniPadreGroup.get(co.Tipologia_Finanziamento_WarrantCPQ__c).put('Tipo_WarrantCPQ__c', co.Tipo_WarrantCPQ__c.toUpperCase());
                }
            }

            update CondizioniPadreGroup.values();
            System.debug('@@@ condizioniOpzGroup ' + JSON.serialize(condizioniOpzGroup.values()));

            // insert CondizioniOpzGroup.values();
            // insert CondizioniOpzGroup.values()[0];

            List<Condizione_Opzionale__c> CondizioniOpzAll = new List<Condizione_Opzionale__c>();
            for(List<Condizione_Opzionale__c> condlist : CondizioniOpzGroup.values())
                CondizioniOpzAll.addAll(condList);

            System.debug('@@@ CondizioniOpzAll ' + JSON.serialize(CondizioniOpzAll));
            insert CondizioniOpzAll;

            //Per ogni raggruppamento di condizioni associo il pagamento alla condizione padre
            // Map<String,List<Condizione_Opzionale__c>> CondizioniOpzGroupPag = (Map<String,List<Condizione_Opzionale__c>>)Utilities.groupBy(condizioniOpzionali, 'Pag_WarrantCPQ__c');
            // Map<String,List<Condizione_Opzionale__c>> CondizioniOpzGroupPag = (Map<String,List<Condizione_Opzionale__c>>)Utilities.groupBy(condizioniPadre, 'Pag_WarrantCPQ__c');
            Map<String,List<Condizioni__c>> CondizioniOpzGroupPag = (Map<String,List<Condizioni__c>>)Utilities.groupBy(condizioniPadre, 'Pag_WarrantCPQ__c');
            Map<String,List<Pagamenti__c>> pagamentiGroup = (Map<String,List<Pagamenti__c>>) Utilities.groupBy(pagamenti, 'Pag_WarrantCPQ__c');

            System.debug('@@@ condizioniPadre ' + JSON.serialize(condizioniPadre));
            System.debug('@@@ CondizioniOpzGroupPag ' + JSON.serialize(CondizioniOpzGroupPag));

            for(String key : pagamentiGroup.keySet()){
                for(Pagamenti__c p : pagamentiGroup.get(key)){
                    p.Quote_Line__c = qlList[0].Id;
                    p.SingoloProdotto_WarrantCPQ__c = qlList[0].SBQQ__Product__c;
                    System.debug('@@@ p ' + JSON.serialize(p));
                    System.debug('@@@ ondizioniOpzGroupPag.get(key) ' + JSON.serialize(CondizioniOpzGroupPag.get(key)));
                    for(Condizioni__c co : CondizioniOpzGroupPag.get(key)){
                        p.Condizione_WarrantCPQ__c = co.Id;
                    }
                }
            }

            // List<Pagamenti__c> pagAll = new List<Pagamenti__c>();
            // for(List<Condizione_Opzionale__c> condlist : CondizioniOpzGroup.values())
            //     CondizioniOpzAll.addAll(condList);
            List<Pagamenti__c> pagAll = new List<Pagamenti__c>();
            for(List<Pagamenti__c> pg : PagamentiGroup.values())
                pagAll.addAll(pg);

            // insert pagamentiGroup.values();
            insert pagAll;


            //Aggiunto per rollup su rinnovi
            // if(condizioniPadre[0].Escludi_da_template__c){
                // qlList[0].Numero_Condizioni__c = condizioniPadre.size();
                // qlList[0].Numero_Finanziamenti__c = finanziamenti.size();
                // qlList[0].Numero_Pagamenti__c = pagAll.size();
                // update qllist;
            // }

            System.debug('@@@ Limits heap ' + Limits.getHeapSize());
            System.debug('@@@ Limits cpu ' + Limits.getCpuTime());

            SBQQ.TriggerControl.enable();

            InvocableCalcoloCondizione.ActionRequest action = new InvocableCalcoloCondizione.ActionRequest();
            action.quoteline = qlList[0].Id;
            InvocableCalcoloCondizione.CalcoloCondizione(new List<InvocableCalcoloCondizione.ActionRequest>{action});

            update pagAll;
            // update quote;

            // update pagAll;
            // update finanziamenti;

            // qlList[0].Numero_Condizioni__c = condizioniPadre.size();
            // qlList[0].Numero_Finanziamenti__c = finanziamenti.size();
            // qlList[0].Numero_Pagamenti__c = pagAll.size();

            //updateOfferta(qllist[0].Id, JSON.serialize(finanziamenti,false), JSON.serialize(condizioniPadre,false), JSON.serialize(pagAll,false));
            //TODO: da scommentare in fase di test
            // Database.rollback(sp);

            response.data = generateResponsePayload(quote, qlList[0], finanziamenti, condizioniPadre, CondizioniOpzAll, pagAll);

        } catch(Exception e){
            response.success = false;
            response.message = e.getMessage() + ' -- ' + e.getStackTraceString();
            Database.rollback(sp);
            System.debug('@@@ errore ' + e.getMessage() + ' -- ' + e.getStackTraceString());
        }

        // f.Disabilita_tutti_i_trigger__c = false;
        // update f;
        insert new Log__c(Success__c = response.success,
        Societa__c = 'WarrantHub',
        Source__c = 'IntegrazioneInfostore',
        Nome_Classe__c = 'RestInserimentoOffertaInfostore',
        ErrorMessage__c = String.valueOf(response.message),
        InputPayload__c = String.valueOf(req.requestBody.toString()),
        OutputPayload__c = String.valueOf(JSON.serializePretty(response,true))
        );

        return response;
    }

    private static Map<String,Object> generateResponsePayload(SBQQ__Quote__c quote, SBQQ__QuoteLine__c quoteline, List<Finanziamenti__c> finanziamenti, List<Condizioni__c> condizioni, List<Condizione_Opzionale__c> condizioniOpz, List<Pagamenti__c> pagamenti){
        Map<String,Object> response = new Map<String,Object>();

        //Workaround per il nome
        SBQQ__Quote__c newQuoteFields = [SELECT Name, SBQQ__Opportunity2__c, WRT_Codice_Opportunit_FORM__c FROM SBQQ__Quote__c WHERE Id =: quote.Id];
        Map<String,Object> quoteMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(quote, false));
        quoteMap.put('Name', newQuoteFields.Name);
        quoteMap.put('SBQQ__Opportunity2__c', newQuoteFields.SBQQ__Opportunity2__c);
        quoteMap.put('WRT_Codice_Opportunit_FORM__c', newQuoteFields.WRT_Codice_Opportunit_FORM__c);
        response.put('Quote', (Object)quoteMap);

        // response.put('Quote', (Object)quote);
        //Workaround per il nome
        SBQQ__QuoteLine__c newQuoteLineFields = [SELECT Name, Documenti_oppotunita_warranthub__c FROM SBQQ__QuoteLine__c WHERE Id =: quoteline.Id];
        Map<String,Object> quoteLineMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(quoteline, false));
        quoteLineMap.put('Name', newQuoteLineFields.Name);
        quoteLineMap.put('Documenti_oppotunita_warranthub__c', newQuoteLineFields.Documenti_oppotunita_warranthub__c);
        response.put('QuoteLine', (Object)quoteLineMap);

        // response.put('QuoteLine', (Object)quoteline);
        response.put('Finanziamenti', (Object)finanziamenti);

        Map<String,SObject> condizioniMap = (Map<String,SObject>) Utilities.keyBy(condizioni, 'Id');
        Map<Id,Condizioni__c> condizioniMapQuery = new Map<Id,Condizioni__c>([SELECT Id, Name FROM Condizioni__c WHERE Id IN: condizioniMap.keySet()]);
        List<Map<String,Object>> condizioniObjs = new List<Map<String,Object>>();
        for(SOBject s : condizioniMap.values()){
            Map<String,Object> m = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(s, false));
            condizioniObjs.add(m);
        }
        // List<Map<String,Object>> condizioniObjs = (List<Map<String,Object>>) JSON.deserializeStrict(JSON.serialize(condizioniMap.values(), false), List<Map<String,Object>>.Class);
        for(Map<String,Object> cMap : condizioniObjs){
            cMap.put('Name', condizioniMapQuery.get((Id)cMap.get('Id')).Name);
        }
        response.put('Condizioni', (Object)condizioniObjs);

        Map<String,SObject> condizioniOpzMap = (Map<String,SObject>) Utilities.keyBy(condizioniOpz, 'Id');
        Map<Id,Condizione_Opzionale__c> condizioniOpzMapQuery = new Map<Id,Condizione_Opzionale__c>([SELECT Id, Name FROM Condizione_Opzionale__c WHERE Id IN: condizioniOpzMap.keySet()]);
        List<Map<String,Object>> condizioniOpzObjs = new List<Map<String,Object>>();
        for(SOBject s : condizioniOpzMap.values()){
            Map<String,Object> m = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(s, false));
            condizioniOpzObjs.add(m);
        }
        // List<Map<String,Object>> condizioniOpzObjs = (List<Map<String,Object>>) JSON.deserializeStrict(JSON.serialize(condizioniOpzMap.values(), false), List<Map<String,Object>>.Class);
        for(Map<String,Object> cMap : condizioniOpzObjs){
            cMap.put('Name', condizioniOpzMapQuery.get((Id)cMap.get('Id')).Name);
        }
        response.put('Condizioni_Opzionali', (Object)condizioniOpzObjs);

        // response.put('Condizioni_Opzionali', (Object)condizioniOpz);
        response.put('Pagamenti', (Object)pagamenti);

        return response;
    }

    // @future
    // private static void updateOfferta(Id qlId, String finanziamenti, String condizioni, String pagamenti){

    //     SBQQ.TriggerControl.disable();
    //     List<Finanziamenti__c> finanziamentiList = (List<Finanziamenti__c>)JSON.deserializeStrict(finanziamenti, List<Finanziamenti__c>.Class);
    //     List<Condizioni__c> condizioniList = (List<Condizioni__c>)JSON.deserializeStrict(condizioni, List<Condizioni__c>.Class);
    //     List<Pagamenti__c> pagamentiList = (List<Pagamenti__c>)JSON.deserializeStrict(pagamenti, List<Pagamenti__c>.Class);

    //     SBQQ__QuoteLine__c ql = [SELECT Id, Numero_Finanziamenti__c, Numero_Condizioni__c, Numero_Pagamenti__c FROM SBQQ__QuoteLine__c WHERE Id =: qlId];
    //     ql.Numero_Finanziamenti__c = finanziamentiList.size();
    //     ql.Numero_Condizioni__c = condizioniList.size();
    //     ql.Numero_Pagamenti__c = pagamentiList.size();
    //     update ql;

    //     update finanziamentiList;
    //     // update condizioniList;
    //     update pagamentiList;
    //     SBQQ.TriggerControl.enable();
    // }
}