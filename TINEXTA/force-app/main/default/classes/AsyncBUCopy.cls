public class AsyncBUCopy implements Queueable{
    //Private per registrare gli ID di ingresso
    private Set<Id> BUIds;
    private Set<Id> Idquote;
    private String rt;
    private Set<Id> idf;
    private Set<Id> idc;
    private Set<Id> idpag;

    public AsyncBUCopy(Set<Id> Id_ba, Set<Id>Quote, String rt,Set<Id> IdFin, Set<Id> Idcon, Set<Id> Idpag) {
    //PONGO IL SET DI MASTER ID UGUALE A QUELLO CHE MI è STATO PASSATO
        this.BUIds = Id_ba; 
        this.Idquote= Quote;
        this.rt=rt;
        this.idf = IdFin;
        this.idc=Idcon;
        this.idpag=idpag;
        system.debug('BUIds : in Queueable '+ BUIds);            
    }
    
    public void execute(QueueableContext context) {
            
        system.debug('Quote'+Idquote);
        system.debug('Finanziamento'+ idf);
        system.debug('Condizione' + idc);
        system.debug('Record Type' + rt);
        system.debug('Pagamenti' + idpag);

        //Mappa Business Area Warrant
        String queryArea = Utilities.selectAllField('Business_Area_Warrant__c') + ' WHERE Id IN : BUIds';
        system.debug('queryArea : '+queryArea);
        Map<String,sObject> AreaMap = Utilities.keyBy(Database.query(queryArea), 'Id');

        //Devo usare il return solo se entrambe sono vuote           
        /*if(AreaMap.isEmpty()){
            system.debug('return');
            //return;
        }*/

        //Mappa Pagamenti

        String queryAreap = Utilities.selectAllField('Business_Area_Warrant__c') + ' WHERE Id IN : Idpag';
        system.debug('queryAreap : '+queryAreap);
        Map<String,sObject> PAreaMap = Utilities.keyBy(Database.query(queryAreap), 'Id');

        // solo se entrambe sono vuote blocco il processo
        if(PAreaMap.isEmpty()&& AreaMap.isEmpty()){
            system.debug('return');
            return;
        }

      //mappe sugli input
        Map<Id,SBQQ__QuoteLine__c> QuoteMap = new Map <Id,SBQQ__QuoteLine__c>([SELECT Id,SBQQ__Product__c,Account_Id__c FROM SBQQ__QuoteLine__c WHERE Id IN:Idquote]);
         system.debug('map quote' + QuoteMap);       

        Map <Id, Finanziamenti__c> FinMap= new Map<Id, Finanziamenti__c> ([SELECT Id, Quote_Line__c,Formula_Id_Prodotto__c,Chiave_Esterna__c FROM Finanziamenti__c WHERE Id in:Idf]);
        system.debug('FinArea : '+FinMap);

        Map <Id, Condizioni__c> ConMap= new Map<Id, Condizioni__c> ([SELECT Id,WRT_Fisso_Listino__c,WRT_Percentuale_Listino__c,Inizio_Validit_Campo_appoggio__c, Quote_Line__c,ID_Prodotto_Formula__c,Chiave_Esterna__c,AccountId__c FROM Condizioni__c WHERE Id in:Idc]);
        system.debug('ConArea : '+ConMap);

        Set <Id> AccId = New Set<Id>();    

        for(Id ql:ConMap.keyset()){
            AccId.add(ConMap.get(ql).Quote_Line__c);
        }

        Map <Id, SBQQ__QuoteLine__c> AccMap = new Map <Id, SBQQ__QuoteLine__c> ([SELECT Id, WRT_Modalita_pagamento__c,WRT_codice_ordine_cliente__c FROM SBQQ__QuoteLine__c WHERE Id IN:AccId]);
        system.debug('AccMap : '+AccMap);


        //Mappa BU
        Map <String, Schema.SObjectType> schemaMapArea = Schema.getGlobalDescribe();
        String objectName='Business_Area_Warrant__c';
        Map<String, Schema.SObjectField> fieldMapArea = schemaMapArea.get(ObjectName).getDescribe().fields.getMap();

        //stringhe er capire il recordtype senza query
        String Finanziamenti='fin';
        String Condizioni='cond';
        String Opzionali = 'op';
        String Pagamenti = 'pag';


    //METODO PER FINANZIAMENTI
        If(rt.contains(Finanziamenti)){
            
            //Creo mappa finanziamenti
            Map <String, Schema.SObjectType> schemaMapFinanziamenti = Schema.getGlobalDescribe();
            String objectNameFin='Finanziamenti__c';
            Map<String, Schema.SObjectField> fieldMapFinanziamenti = schemaMapFinanziamenti.get(objectNameFin).getDescribe().fields.getMap();

            list<Finanziamenti__c> ListFin = new list<Finanziamenti__c>();
            System.debug('dentro if');

            //Per tutte le BU, per tutte le quoteline, solo se stiamo parlando dello stesso prodotto creo un finanziamento
            for (String BAWId : AreaMap.keyset()){
             System.debug('for Area');
             for (Id q: QuoteMap.keyset()){
                If((Id)AreaMap.get(BAWId).get('SingoloProdotto_WarrantCPQ__c') == QuoteMap.get(q).SBQQ__Product__c){
                    sObject newf = Schema.getGlobalDescribe().get('Finanziamenti__c').newSObject();
                    sObject cloneArea = AreaMap.get(BAWId);

                    System.debug('QuoteMap'+ QuoteMap);
                
                  // questo for serve per copiare i campi con gli stessi API
                 for(String x : fieldMapFinanziamenti.keySet()){
                    Boolean containsA = fieldMapFinanziamenti.containsKey(x.replace('__c', '').replace('_', ''));
                    Boolean containsB = fieldMapFinanziamenti.containsKey(x);
                    if(containsB && fieldMapFinanziamenti.get(x).getDescribe().isAccessible()){
                        //if(x == 'Name')newf.put(x, cloneArea.get(x));
                        For(String y:fieldMapArea.keyset()){
                        if(x.contains('__c') && y == x && fieldMapArea.get(y).getDescribe().isAccessible()){
                            If(!x.contains('formula')){
                            newf.put(x, cloneArea.get(x));
                            }
                        }
                        }

                    System.debug('EU containsB: ' + x +'---'+fieldMapFinanziamenti.get(x).getDescribe().isAccessible() + '---' + fieldMapFinanziamenti.get(x).getDescribe().isUpdateable());
                            
                    }else if (containsA && fieldMapFinanziamenti.get(x).getDescribe().isAccessible()){
                            // Campi che hanno stessa api name (WITHOUT __c AND _)
                            System.debug('Ak x: ' + x);

                            newf.put(x, cloneArea.get(x.replace('__c', '').replace('_', '')));
                            System.debug('Ak containsA: ' + x + ' ' + x.replace('__c', '').replace('_', '') + ' ' + cloneArea.get(x.replace('__c', '').replace('_', '')));
                            
                    }else if(fieldMapFinanziamenti.get(x).getDescribe().isAccessible()) {
                            // Campi che non hanno stessa api name
                    }                          
                }  
                
                //Aggiungo la quoteline
                newf.put('Quote_Line__c',QuoteMap.get(q).Id);
                newf.put('Formula_Semaforo_Trigger__c',true);
                newf.put('Chiave_Esterna__c', AreaMap.get(BAWId).get('Id'));
                System.debug('newFinanziamento : '+newf);
                ListFin.add((Finanziamenti__c)newf);
                }
            }
        }
        

            if(ListFin.size()>0){
                System.debug('Insert Finanziamento');      
                insert ListFin;
            }
        }

        //METODO PER CONDIZIONI

        If(rt.contains(Condizioni)){

            //mappa condizioni vuota
            Map <String, Schema.SObjectType> schemaMapCondizioni = Schema.getGlobalDescribe();
            String objectNameCon='Condizioni__c';
            Map<String, Schema.SObjectField> fieldMapCondizioni = schemaMapCondizioni.get(objectNameCon).getDescribe().fields.getMap();

            //Set<Condizioni__c> ListCcon = new Set<Condizioni__c>();
            Map <Id,Condizioni__c> addConMap= new Map<Id,Condizioni__c>();

            //Per tutte le BU, per tutte i finanziamenti, solo se stiamo parlando dello stesso prodotto creo una condizione
            for (String BAW : AreaMap.keyset()){
                for (Id f: FinMap.keyset()){
                    sObject newcc = Schema.getGlobalDescribe().get('Condizioni__c').newSObject();
                    sObject cloneAreaC = AreaMap.get(BAW);
                
			    If(AreaMap.get(BAW).get('SingoloProdotto_WarrantCPQ__c') == FinMap.get(f).Formula_Id_Prodotto__c && AreaMap.get(BAW).get('Fin_Associato__c') == FinMap.get(f).Chiave_Esterna__c){
                    //questo for serve per copiare i campi con gli stessi API
                    for(String x : fieldMapCondizioni.keySet()){
                        Boolean containsA = fieldMapCondizioni.containsKey(x.replace('__c', '').replace('_', ''));
                        Boolean containsB = fieldMapCondizioni.containsKey(x);
                        if(containsB && fieldMapCondizioni.get(x).getDescribe().isAccessible()){
                            
                            //if(x == 'Name')newcc.put(x, cloneAreaC.get(x));
                            For(String y:fieldMapArea.keyset()){
                            if(x.contains('__c')&& y == x && fieldMapArea.get(y).getDescribe().isAccessible()){
                            If(!x.contains('formula')){
                            newcc.put(x, cloneAreaC.get(x));
                            }
                            }
                        }

                        System.debug('EU containsB: ' + x +'---'+fieldMapCondizioni.get(x).getDescribe().isAccessible() + '---' + fieldMapCondizioni.get(x).getDescribe().isUpdateable());
                            
                    }else if (containsA && fieldMapCondizioni.get(x).getDescribe().isAccessible()){
                            // Campi che hanno stessa api name (WITHOUT __c AND _)
                            System.debug('Ak x: ' + x);

                            newcc.put(x, cloneAreaC.get(x.replace('__c', '').replace('_', '')));
                            System.debug('Ak containsA: ' + x + ' ' + x.replace('__c', '').replace('_', '') + ' ' + cloneAreaC.get(x.replace('__c', '').replace('_', '')));
                            
                    }else if(fieldMapCondizioni.get(x).getDescribe().isAccessible()) {
                            // Campi che non hanno stessa api name
                    }  
                     
                } 
                
                newcc.put('Finanziamento__c',FinMap.get(f).Id);
                newcc.put('Quote_Line__c',FinMap.get(f).Quote_Line__c);
                newcc.put('Formula_Semaforo_Trigger__c', true);
                newcc.put('WRT_Fisso_Listino__c', AreaMap.get(BAW).get('Fisso_WarrantCPQ__c'));
                //newcc.put('WRT_Fisso_Listino__c', 1000);
                newcc.put('WRT_Percentuale_Listino__c', AreaMap.get(BAW).get('Percentuale_WarrantCPQ__c'));   

                //Qui salvo l'Id del listino correlato
                newcc.put('Chiave_Esterna__c',AreaMap.get(BAW).get('Id'));
                System.debug('newCondizione : '+newcc);
                //ListCcon.add((Condizioni__c)newcc);
                addConMap.put((Id)AreaMap.get(BAW).get('Id'), (Condizioni__c)newcc);
                }
            }
            }        
        system.debug('NEW ' + addConMap);
        if(!addConMap.isEmpty()){
            System.debug('Insert Condizione');
            try{
                insert addConMap.values();
            }catch(DmlException e){

            }
        }
    }

        //METODO PER OPZIONALI

         If(rt.contains(Opzionali)){
            //parte relativa alle condizioni opzionali
            Map <String, Schema.SObjectType> schemaMapOpzioni = Schema.getGlobalDescribe();
            String objectNameOp='Condizione_Opzionale__c';
            Map<String, Schema.SObjectField> fieldMapOpzioni = schemaMapOpzioni.get(objectNameOp).getDescribe().fields.getMap();

            //list<Condizione_Opzionale__c> Listop = new list<Condizione_Opzionale__c>();
            Map <Id,Condizione_Opzionale__c> addOpzMap= new Map<Id,Condizione_Opzionale__c>();

            //Parte per i pagamenti

            Map <String, Schema.SObjectType> schemaMapPagamenti = Schema.getGlobalDescribe();
            String objectNamePag='Pagamenti__c';
            Map<String, Schema.SObjectField> fieldMapPagamenti = schemaMapPagamenti.get(objectNamePag).getDescribe().fields.getMap();

            //list<Pagamenti__c> Listpag = new list<Pagamenti__c>();
            Map <Id,Pagamenti__c> addPagMap= new Map<Id,Pagamenti__c>();

            //per tutte le Bu, per tutte le condizioni solo se hanno lo stesso prodotto creo le condizioni opzionali
            for (String BAWId : AreaMap.keyset()){
             for (String c: ConMap.keyset()){
                If(AreaMap.get(BAWId).get('SingoloProdotto_WarrantCPQ__c') == ConMap.get(c).ID_Prodotto_Formula__c && AreaMap.get(BAWId).get('Cond_Associata__c') == ConMap.get(c).Chiave_Esterna__c){
                sObject newo = Schema.getGlobalDescribe().get('Condizione_Opzionale__c').newSObject();
                sObject cloneArea = AreaMap.get(BAWId);
                
                //questo for serve per copiare i campi con gli stessi API
                for(String x : fieldMapOpzioni.keySet()){
                    Boolean containsA = fieldMapOpzioni.containsKey(x.replace('__c', '').replace('_', ''));
                    Boolean containsB = fieldMapOpzioni.containsKey(x);
                    if(containsB && fieldMapOpzioni.get(x).getDescribe().isAccessible()){
                       // if(x == 'Name')newo.put(x, cloneArea.get(x));
                        For(String y:fieldMapArea.keyset()){
                            if(x.contains('__c')&& y == x && fieldMapArea.get(y).getDescribe().isAccessible()){
                            If(!x.contains('formula')){
                            newo.put(x, cloneArea.get(x));
                            }
                        }
                        }

                        System.debug('EU containsB: ' + x +'---'+fieldMapOpzioni.get(x).getDescribe().isAccessible() + '---' + fieldMapOpzioni.get(x).getDescribe().isUpdateable());
                            
                    }else if (containsA && fieldMapOpzioni.get(x).getDescribe().isAccessible()){
                            // Campi che hanno stessa api name (WITHOUT __c AND _)
                            System.debug('Ak x: ' + x);

                            newo.put(x, cloneArea.get(x.replace('__c', '').replace('_', '')));
                            System.debug('Ak containsA: ' + x + ' ' + x.replace('__c', '').replace('_', '') + ' ' + cloneArea.get(x.replace('__c', '').replace('_', '')));
                            
                    }else if(fieldMapOpzioni.get(x).getDescribe().isAccessible()) {
                            // Campi che non hanno stessa api name
                    }

                        
                } 

 
                newo.put('CondizionePadre_WarrantCPQ__c',ConMap.get(c).Id);
                newo.put('Formula_Semaforo_Trigger__c',true);
                newo.put('Chiave_Esterna__c',AreaMap.get(BAWId).get('Id') );
                newo.put('WRT_Fisso_Listino__c', AreaMap.get(BAWId).get('Fisso_WarrantCPQ__c'));
                //newo.put('WRT_Fisso_Listino__c ', 1000);
                newo.put('WRT_Percentuale_Listino__c', AreaMap.get(BAWId).get('Percentuale_WarrantCPQ__c'));  

                    
                System.debug('newOpzionale : '+newo);
                //Listop.add((Condizione_Opzionale__c)newo);
                addOpzMap.put((Id)AreaMap.get(BAWId).get('Id'), (Condizione_Opzionale__c)newo);
                }
             }
            }

        system.debug('NEW ' + addOpzMap);
        if(!addOpzMap.isEmpty()){
            System.debug('Insert Condizione Opzionale');
            try{
                insert addOpzMap.values();
            }catch(DmlException e){

            }
        }


            //Sottometodo Pagamenti
            //Per tutti le BU per tutte le condizioni se hanno lo stesso prodotto creo un pagamento
            //for (String cmap: ConMap.keyset()){
            for (String Pag : PAreaMap.keyset()){

                sObject newpag = Schema.getGlobalDescribe().get('Pagamenti__c').newSObject();
                sObject cloneAreap = PAreaMap.get(Pag);   
              for (String cmap: ConMap.keyset()){
                  System.debug('for pagamenti' + PAreaMap.get(Pag).get('RecordTypeId'));

                If(PAreaMap.get(Pag).get('SingoloProdotto_WarrantCPQ__c') == ConMap.get(cmap).ID_Prodotto_Formula__c && PAreaMap.get(Pag).get('Cond_Associata__c') == ConMap.get(cmap).Chiave_Esterna__c){
             //   If(ConMap.get(cmap).ID_Prodotto_Formula__c == PAreaMap.get(Pag).get('SingoloProdotto_WarrantCPQ__c')){
                //questo for serve per copiare i campi con gli stessi API
                system.debug('Dentro if');
                 for(String y : fieldMapPagamenti.keySet()){
                    Boolean containsA = fieldMapPagamenti.containsKey(y.replace('__c', '').replace('_', ''));
                    Boolean containsB = fieldMapPagamenti.containsKey(y);
                    if(containsB && fieldMapPagamenti.get(y).getDescribe().isAccessible()){
                        //if(y == 'Name')newpag.put(y, cloneAreap.get(y));
                        For(String yy:fieldMapArea.keyset()){
                            if(y.contains('__c')&& yy == y && fieldMapArea.get(yy).getDescribe().isAccessible()){
                            If(!y.contains('formula')){
                            newpag.put(y, cloneAreap.get(y));
                            }
                            }
                        }

                        System.debug('EU containsB: ' + y +'---'+fieldMapPagamenti.get(y).getDescribe().isAccessible() + '---' + fieldMapPagamenti.get(y).getDescribe().isUpdateable());
                            
                    }else if (containsA && fieldMapPagamenti.get(y).getDescribe().isAccessible()){
                            // Campi che hanno stessa api name (WITHOUT __c AND _)
                            System.debug('Ak x: ' + y);

                            newpag.put(y, cloneAreap.get(y.replace('__c', '').replace('_', '')));
                            System.debug('Ak containsA: ' + y + ' ' + y.replace('__c', '').replace('_', '') + ' ' + cloneAreap.get(y.replace('__c', '').replace('_', '')));
                            
                    }else if(fieldMapPagamenti.get(y).getDescribe().isAccessible()) {
                            // Campi che non hanno stessa api name
                    }                          
                } 


                newpag.put('Condizione_WarrantCPQ__c',ConMap.get(cmap).Id);
                newpag.put('Quote_Line__c',ConMap.get(cmap).Quote_Line__c);
                newpag.put('Formula_Semaforo_Trigger__c',true);
                newpag.put('Chiave_Esterna__c', PAreaMap.get(Pag).get('Id'));
                    
                Date datanuova = system.today();
                if(PAreaMap.get(Pag).get('Mesi_da_aggiungere_alla_Scadenza__c') == null)
                {
                    datanuova = null;
                }
                else
                {
                    Integer scadenza = Integer.valueOf(PAreaMap.get(Pag).get('Mesi_da_aggiungere_alla_Scadenza__c'));
                
                    if(scadenza != 0) datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(scadenza);
                    if(scadenza == 0) datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c;
                }
                
                    
                /*switch on (scadenza){
                when null {datanuova = null;}
                when '0' {datanuova = system.today();}
                when '1' {datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(1);}
                when '2' {datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(2);}
                when '3' {datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(3);}
                when '4' {datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(4);}
                when '5' {datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(5);}
                when '6' {datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(6);}
                when '7' {datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(7);}
                when '8' {datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(8);}
                when '9' {datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(9);}
                when '10' {datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(10);}
                when '11' {datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(11);}
                when '12' {datanuova= ConMap.get(cmap).Inizio_Validit_Campo_appoggio__c.addmonths(12);}
                 }*/

                newpag.put('Scadenza_WarrantCPQ__c', datanuova);

                System.debug('newPagamenti : '+newpag);
               // Listpag.add((Pagamenti__c)newpag);
                if(PAreaMap.get(Pag).get('Tipo_pagamento_WarrantCPQ__c') == null){
                    system.debug('Null Tipo Pag');
                    for(Id a:AccMap.keyset()){
                        system.debug('for Account');
                        newpag.put('Codice_Ordine_Cliente_WarrantCPQ__c', AccMap.get(a).WRT_codice_ordine_cliente__c);
                        If(ConMap.get(cmap).Quote_Line__c == AccMap.get(a).Id){
                            system.debug('Acc'+ AccMap.get(a).Id);
                            newpag.put('Tipo_pagamento_WarrantCPQ__c', AccMap.get(a).WRT_Modalita_pagamento__c);
                            system.debug('Tipo pag' + AccMap.get(a).WRT_Modalita_pagamento__c);
                        }
                    }
                }


                addPagMap.put((Id)PAreaMap.get(Pag).Id, (Pagamenti__c)newpag);
            }
        }
            
      }

        system.debug('NEW ' + addPagMap);
        if(!addPagMap.isEmpty()){
            System.debug('Insert Pagamenti');
            try{
                insert addPagMap.values();
            }catch(DmlException e){

            }
        }
    }           
  }      
}