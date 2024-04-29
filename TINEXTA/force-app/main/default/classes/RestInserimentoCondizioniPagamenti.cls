@RestResource(urlMapping='/v1.0/InserimentoCondizioniPagamenti')
global without sharing class RestInserimentoCondizioniPagamenti {
    
    @HttpPost
    global static ResponseWrapper doPost(/*List<Map<String,Object>> Condizioni, List<SObject> Pagamenti*/){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        ObjectResponseWrapper response = new ObjectResponseWrapper();

        Savepoint sp = Database.SetSavepoint();

        try{

            System.debug('@@@ req.requestBody ' + req.requestBody.toString());
            Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(req.requestBody.toString());
            List<Map<String,Object>> Condizioni = new List<Map<String,Object>>();
            List<Object> condizioniObjList = (List<Object>) body.get('Condizioni');
            for(Object o : condizioniObjList){
                Map<String,Object> tmpCond = (Map<String,Object>) o;
                Condizioni.add(tmpCond);
            }

            // List<Map<String,Object>> Condizioni = (List<Map<String,Object>>) JSON.deserializeStrict(JSON.serialize(body.get('Condizioni'), false), List<Map<String,Object>>.Class);
            List<SObject> Pagamenti = (List<SObject>) JSON.deserializeStrict(JSON.serialize(body.get('Pagamenti'), false), List<SObject>.Class);
            
            SBQQ.TriggerControl.disable();
            Boolean checkQuoteLine = false;
            Boolean checkFinanziamenti = false;

            for(Map<String,Object> record : Condizioni){
                if(record.get('Quote_Line__c') == null){
                    checkQuoteLine = true;
                    break;
                }
                if(record.get('Finanziamento__c') == null){
                    checkFinanziamenti = true;
                    break;
                }
            }

            if(checkQuoteLine){
                response.message = 'Campo obbligatorio mancante: Quote_Line__c su uno o più oggetti condizioni';
                response.success = false;
            } else if(checkFinanziamenti){
                response.message = 'Campo obbligatorio mancante: Finanziamento__c su uno o più oggetti condizioni';
                response.success = false;
            }

            if(checkQuoteLine || checkFinanziamenti)
                return response;

            List<Condizioni__c> condizioniPadre = new List<Condizioni__c>();

            Map<String,List<Map<String,Object>>>  FF_CondizioniMap = new Map<String,List<Map<String,Object>>>();
            String keyPattern = '{FF_WarrantCPQ__c}_{Progressivo__c}';
            Map<String, String> pattern2FieldMap = new Map<String, String>();

            Pattern pat = Pattern.compile('\\{[^\\}]+\\}');
            Matcher m = pat.matcher(keyPattern);
            while(m.find()) {
                System.debug('@@@ m ' + m.group());
              String f = m.group().substringAfter('{').substringBeforeLast('}');
              System.debug('@@@ ff ' + f);
              pattern2FieldMap.put(m.group(), f);
            }
        
            System.debug('@@@ pattern2FieldMap ' + pattern2FieldMap);
            for(Map<String,Object> obj : condizioni) {
              String compiledPattern = keyPattern;
              for(String p : pattern2FieldMap.values()) {
                  System.debug('@@@ compiledPattern ' + compiledPattern);
                  System.debug('@@@ obj ' + obj.get(compiledPattern));
                String value = String.valueOf(obj.get(p));
                compiledPattern = compiledPattern.replace(p, value == null ? 'null' : value);
              }
              String key = compiledPattern.replace('{', '').replace('}', ''); //('{').substringBeforeLast('}');
              if(!FF_CondizioniMap.containsKey(key))
                FF_CondizioniMap.put(key, new List<Map<String,Object>>());
              FF_CondizioniMap.get(key).add(obj);
              //addToGMap(res, compiledPattern, obj);
            }
        
            
            //Map<String,List<SObject>> FF_CondizioniMap = (Map<String,List<SObject>>) Utilities.groupBy(condizioni, '{FF_WarrantCPQ__c}_{Progressivo__c}', true);

            System.debug('@@@ FF_CondizioniMap ' + JSON.serialize(FF_CondizioniMap));

            for(String key : FF_CondizioniMap.keySet()){
                if(key == 'false_false'){
                    for(Map<String,Object> sobj : FF_CondizioniMap.get(key)){
                        Condizioni__c c = (Condizioni__c)JSON.deserializeStrict(JSON.serialize(sobj), Condizioni__c.Class);
                        system.debug('@@@ c ' + JSON.serialize(c));
                        System.debug('@@@ c.Tipo_WarrantCPQ__c ' + c.Tipo_WarrantCPQ__c);
                        // Condizioni__c c = new Condizioni__c(Finanziamento__c = (Id)tipoFinMap.get(String.valueOf(sobj.get('Tipologia_Finanziamento_WarrantCPQ__c'))), Quote_Line__c = qlList[0].Id, );
                        // c.Finanziamento__c = (Id)tipoFinMap.get((String)sobj.get('Tipologia_Finanziamento_WarrantCPQ__c')).get('Id');
                        //c.Finanziamento__c = tipoFinMap.get((String)sobj.get('Tipologia_Finanziamento_WarrantCPQ__c')) != null ? (Id)tipoFinMap.get((String)sobj.get('Tipologia_Finanziamento_WarrantCPQ__c')).get('Id') : null;
                        //c.Quote_Line__c = qlList[0].Id;
                        // c.Tipo_WarrantCPQ__c = c.Progressivo__c ? 'Progressivo' : 'Alternativo';
                        // c.Tipo_WarrantCPQ__c = 'FISSO';
                        condizionipadre.add(c);
                    }
                }
            }

            System.debug('@@@ condizioniPadre1 ' + JSON.serialize(condizioniPadre));

            // insert condizioniPadre;

            // System.debug('@@@ condizioniPadre ' + JSON.serialize(condizioniPadre));


            List<Map<String,Object>> CondizioniConPadri = new List<Map<String,Object>>();

            if(FF_CondizioniMap.get('true_false') != null)
                CondizioniConPadri.addAll(FF_CondizioniMap.get('true_false'));
            if(FF_CondizioniMap.get('false_true') != null)
                CondizioniConPadri.addAll(FF_CondizioniMap.get('false_true'));


            Map<String,List<Map<String,Object>>> CondizioniOpzGroup = new Map<String,List<Map<String,Object>>>(); //Utilities.groupBy(CondizioniConPadri, 'Pag_WarrantCPQ__c');

            String keyPatternOpz = '{Pag_WarrantCPQ__c}';
            Map<String, String> pattern2FieldMapOpz = new Map<String, String>();

            Pattern patOpz = Pattern.compile('\\{[^\\}]+\\}');
            Matcher mOpz = pat.matcher(keyPattern);
            while(mOpz.find()) {
                String f = mOpz.group().substringAfter('{').substringBeforeLast('}');
                pattern2FieldMap.put(mOpz.group(), f);
            }
        
            for(Map<String,Object> obj : CondizioniConPadri) {
                String compiledPattern = keyPattern;
                for(String p : pattern2FieldMap.values()) {
                String value = String.valueOf(obj.get(p));
                compiledPattern = compiledPattern.replace(p, value == null ? 'null' : value);
                }
                String key = compiledPattern.replace('{', '').replace('}', ''); //('{').substringBeforeLast('}');
                if(!CondizioniOpzGroup.containsKey(key))
                    CondizioniOpzGroup.put(key, new List<Map<String,Object>>());
                CondizioniOpzGroup.get(key).add(obj);
                //addToGMap(res, compiledPattern, obj);
            }

            // Map<String,List<Condizione_Opzionale__c>> CondizioniOpzGroup2 = (Map<String,List<Condizione_Opzionale__c>>)Utilities.groupBy(FF_CondizioniMap.get('true'), 'Tipologia_Finanziamento_WarrantCPQ__c');

            System.debug('@@@ condizioniOpzGroup ' + JSON.serialize(CondizioniOpzGroup));

            // List<Condizioni__c> condizioniPadre = new List<Condizioni__c>();
            for(String key : CondizioniOpzGroup.keySet()){
                System.debug('@@@ key ' + key);
                System.debug('@@@ CondizioniOpzGroup.get(key) ' + CondizioniOpzGroup.get(key));
                Condizioni__c c = new Condizioni__c(
                    //Quote_Line__c = qlList[0].Id,
                    Quote_Line__c = (Id)CondizioniOpzGroup.get(key)[0].get('Quote_Line__c'),
                    Pag_WarrantCPQ__c = (String)CondizioniOpzGroup.get(key)[0].get('Pag_WarrantCPQ__c'),
                    // Tipo_WarrantCPQ__c = CondizioniOpzGroup.get(key)[0].Tipo_WarrantCPQ__c.toUpperCase(),
                    Tipo_WarrantCPQ__c = (Boolean)CondizioniOpzGroup.get(key)[0].get('Progressivo__c') ? 'Progressivo' : 'Alternativo',
                    Finanziamento__c = (Id)CondizioniOpzGroup.get(key)[0].get('Finanziamento__c')
                );
                condizioniPadre.add(c);
            }

            System.debug('@@@ condizioniPadre ' + JSON.serialize(condizioniPadre));
            insert condizioniPadre;

            // Map<String,SObject> CondizioniPadreGroup = (Map<String,SObject>)Utilities.keyBy(condizioniPadre, 'Tipologia_Finanziamento_WarrantCPQ__c');
            Map<String,SObject> CondizioniPadreGroup = (Map<String,SObject>) Utilities.keyBy(condizioniPadre, 'Pag_WarrantCPQ__c');

            List<Condizione_Opzionale__c> CondizioniOpzAll = new List<Condizione_Opzionale__c>();
            for(List<Map<String,Object>> condOpzList : CondizioniOpzGroup.values()){
                for(Map<String,Object> tmpCondOpz : condOpzList){
                    tmpCondOpz.remove('Finanziamento__c');
                    Condizione_Opzionale__c condOpz = (Condizione_Opzionale__c) JSON.deserializeStrict(JSON.serialize(tmpCondOpz, false), Condizione_Opzionale__c.Class);
                    condOpz.CondizionePadre_WarrantCPQ__c = (Id)CondizioniPadreGroup.get(condOpz.Pag_WarrantCPQ__c).get('Id');
                    CondizioniOpzAll.add(condOpz);
                }
            }

            update CondizioniPadreGroup.values();
            System.debug('@@@ condizioniOpzGroup ' + JSON.serialize(condizioniOpzGroup.values()));

            System.debug('@@@ CondizioniOpzAll ' + JSON.serialize(CondizioniOpzAll));
            insert CondizioniOpzAll;

            List<Pagamenti__c> pagamentiList = (List<Pagamenti__c>) Pagamenti;

            System.debug('@@@ pagamentiList ' + JSON.serialize(pagamentiList));

            // Map<String,SObject> condizioniMap = (Map<String,SObject>) Utilities.keyBy(condizioniList, 'Pag_WarrantCPQ__c');
            // System.debug('@@@ condizioniMap ' + JSON.serialize(condizioniMap));
            Map<String,SObject> condizioniMap = (Map<String,SObject>) Utilities.keyBy(condizioniPadre, 'Pag_WarrantCPQ__c');
            System.debug('@@@ condizioniMap ' + JSON.serialize(condizioniMap));

            for(Pagamenti__c p : pagamentiList){
                p.Condizione_WarrantCPQ__c = (Id)condizioniMap.get(p.Pag_WarrantCPQ__c).get('Id');
                if(p.Quote_Line__c == null)
                    p.Quote_Line__c = (Id)condizioniMap.get(p.Pag_WarrantCPQ__c).get('Quote_Line__c');
            }

            insert pagamentiList;

            System.debug('@@@ pagamentiList ' + JSON.serialize(pagamentiList));


            List<Map<String,Object>> condizioniAll = new List<Map<String,Object>>();

            Map<String,SObject> condizioniIdsMap = (Map<String,SObject>) Utilities.keyBy(condizioniPadre, 'Id');
            Map<String,SObject> condizioniOpzIdsMap = (Map<String,SObject>) Utilities.keyBy(condizioniOpzAll, 'Id');

            Map<Id,Condizioni__c> condizioniNames = new Map<Id,Condizioni__c>([SELECT Id, Name FROM Condizioni__c WHERE Id IN: condizioniIdsMap.keySet()]);
            Map<Id,Condizione_Opzionale__c> condizioniOpzNames = new Map<Id,Condizione_Opzionale__c>([SELECT Id, Name FROM Condizione_Opzionale__c WHERE Id IN: condizioniOpzIdsMap.keySet()]);

            for(Condizioni__c c : condizioniPadre){
                Map<String,Object> tmp = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(c));
                tmp.put('Name', (String)condizioniNames.get(c.Id).get('Name'));
                condizioniAll.add(tmp);
                //c = (Condizioni__c)JSON.deserializeStrict(JSON.serialize(tmp), Condizioni__c.Class);
                // c.put('Name', (String)condizioniNames.get(c.Id).get('Name'));
            }

            for(Condizione_Opzionale__c c : condizioniOpzAll){
                Map<String,Object> tmp = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(c));
                tmp.put('Name', (String)condizioniOpzNames.get(c.Id).get('Name'));
                condizioniAll.add(tmp);
                //c = (Condizione_Opzionale__c)JSON.deserializeStrict(JSON.serialize(tmp), Condizione_Opzionale__c.Class);
                // c.put('Name', (String)condizioniOpzNames.get(c.Id).get('Name'));
            }

            List<Map<String,Object>> pagamentiObjs = new List<Map<String,Object>>();

            Map<String,SObject> pagamentiIdsMap = (Map<String,SObject>) Utilities.keyBy(pagamentiList, 'Id');

            Map<Id,Pagamenti__c> pagamentiNames = new Map<Id,Pagamenti__c>([SELECT Id, Name FROM Pagamenti__c WHERE Id IN: pagamentiIdsMap.keySet()]);

            for(Pagamenti__c p : pagamentiList){
                Map<String,Object> tmp = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(p));
                tmp.put('Name', (String)pagamentiNames.get(p.Id).get('Name'));
                pagamentiObjs.add(tmp);
            }

            // List<SObject> condizioniAll = new List<SObject>();
            // condizioniAll.addAll(condizioniPadre);
            // condizioniAll.addAll(condizioniOpzAll);
            
            SBQQ.TriggerControl.enable();

            update pagamentiList[0];

            response.data = new Map<String,Object>{
                'Condizioni' => condizioniAll,
                'Pagamenti' => pagamentiObjs
            };

        } catch(Exception e){
            response.message = e.getMessage() + ' -- ' + e.getStackTraceString();
            response.success = false;
            System.debug('@@@ errore ' + e.getMessage() + ' -- ' + e.getStackTraceString());
            Database.rollback(sp);
        }

        String jsonString = String.valueOf(req.requestBody.toString());
        insert new Log__c(
            Success__c = response.success,
            Societa__c = 'WarrantHub',
            Source__c = 'Infostore',
            Nome_Classe__c = 'RestInserimentoCondizioniPagamenti',
            //ID_Record__c = recordIDLog,
            ErrorMessage__c = String.valueOf(response.message),
            InputPayload__c = jsonString,
            OutputPayload__c = String.valueOf(JSON.serializePretty(response,true))
        );

        return response;
    } 
}