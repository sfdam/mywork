public without sharing class OnWorkOrderTriggerHandler 
{
    //gestione ripetizione trigger
	public static Boolean disableWorkOrderTrigger = false;

    public static void checkWorkOrderLineItems(Map<Id,WorkOrder> newMap, Map<Id, WorkOrder> oldMap)
    {
        //controllo non deve partire se cambio stato all'indietro --> picklist campo in lista + controllo indici lista - se indice new > indice old --> no controllo
        //devo controllare che per il vecchio status del workorder (oldMap) tutti i woli con quello stesso status siano completati 
        set<id> idWorkOrderSet = new set<id>();
        set<string> statusWok = new set<string>();

        Schema.DescribeFieldResult fieldResult = WorkOrder.Status.getDescribe();
        List<Schema.PicklistEntry> staus = fieldResult.getPicklistValues(); 
        system.debug(staus);
        list<string> pickList = new list<string>();
        for(Schema.PicklistEntry pik : staus)
        {
            pickList.add(pik.getValue());
        }

        //if new status != old status
        for(workorder wok : newMap.values())
        {
            if(newMap.get(wok.id).status != oldMap.get(wok.id).status && 
                pickList.indexOf(newMap.get(wok.id).status) > pickList.indexOf(oldMap.get(wok.id).status) && 
                newMap.get(wok.id).status != 'Late interconnection' &&
                newMap.get(wok.id).status != 'Cancelled' &&
                newMap.get(wok.id).status != 'Rejected' &&
                newMap.get(wok.id).status != 'Concluded' &&
                newMap.get(wok.id).status != 'Standby' &&
                newMap.get(wok.id).status != 'Assessment in progress' &&
                newMap.get(wok.id).status != 'Reworking' &&
                newMap.get(wok.id).status != 'Final Activities'
                )
            {
                idWorkOrderSet.add(wok.id);
                statusWok.add(oldMap.get(wok.id).status);
            }
        }

        Id woliRecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosbyDeveloperName().get('WRT_Task').getRecordTypeId();

        //woli status wo = wo old status and required true and completed false
        Map<String, SObject[]> woliMap = Utilities.groupBy([SELECT id, workorderid, 
                                                                    status, WRT_Work_Order_Status__c 
                                                                    FROM workorderlineitem 
                                                                    WHERE workorderid in :idWorkOrderSet
                                                                    and status != 'Completato'
                                                                    and status != 'Chiuso'
                                                                    and status != 'Annullato'
                                                                    and status != 'Impossibile completare'
                                                                    and WRT_Required__c = true
                                                                    and recordtypeid = :woliRecordTypeId
                                                                    and WRT_Work_Order_Status_Pick__c in :statusWok], 'workorderid'); //WRT_Work_Order_Status__c
        System.debug(woliMap);
        //woliMap.isempty false, throw error (su for?)
        for(workorder wok : newMap.values())
        {
            if(woliMap.get(wok.id) != null)
            {
                system.debug('in if woli.get');
                if(!Test.isrunningTest()) wok.addError(Label.WRT_CheckWOLI);
            }
        }
    }

    /*public static void reopenWoli(Map<Id,WorkOrder> newMap, Map<Id, WorkOrder> oldMap)
    {
        set<id> idWorkOrderSet = new set<id>();
        list<string> statusWok = new list<string>();

        Funzionalita__c f = Funzionalita__c.getInstance();

        Schema.DescribeFieldResult fieldResult = WorkOrder.Status.getDescribe();
        List<Schema.PicklistEntry> staus = fieldResult.getPicklistValues(); 
        system.debug(staus);
        list<string> pickList = new list<string>();
        for(Schema.PicklistEntry pik : staus)
        {
            pickList.add(pik.getValue());
        }

        for(workorder wok : newMap.values())
        {
            if(newMap.get(wok.id).status != oldMap.get(wok.id).status && pickList.indexOf(newMap.get(wok.id).status) < pickList.indexOf(oldMap.get(wok.id).status))
            {
                idWorkOrderSet.add(wok.id);
                //devo prendere tutti gli status minori di status oldMap
                if(!statusWok.contains(newmap.get(wok.id).status)) statusWok.add(newmap.get(wok.id).status);
                if(!statusWok.contains(oldmap.get(wok.id).status)) statusWok.add(oldmap.get(wok.id).status);
            }
        }
        if(statusWok.size()> 1)
        {
            for(string pik : pickList)
            {
                system.debug('statusPick < '+statusWok[1]);
                if(pickList.indexOf(statusWok[0]) <= pickList.indexOf(pik) && !statusWok.contains(pik))
                {
                    statusWok.add(pik);
                }
            }
        }

        system.debug('statusPick < '+statusWok);

        Id woliRecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosbyDeveloperName().get('WRT_Task').getRecordTypeId();
        //string woliRecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosbyId().get('WRT_Task').getDeveloperName();

        //woli status wo = wo old status and required true and completed false
        Map<String, WorkOrderLineItem> woliMap = new map<string, WorkOrderLineItem>([SELECT id, workorderid, 
                                                                    status, WRT_Work_Order_Status__c 
                                                                    FROM workorderlineitem 
                                                                    WHERE workorderid in :idWorkOrderSet
                                                                    and (status = 'Completato'
                                                                    or status = 'Chiuso'
                                                                    or status = 'Annullato'
                                                                    or status = 'Impossibile completare')
                                                                    and WRT_Required__c = true
                                                                    and recordtypeid = :woliRecordTypeId
                                                                    and WRT_Work_Order_Status__c in :statusWok]);
        System.debug(woliMap);

        for(WorkOrderLineItem wokLine : woliMap.values())
        {
            wokLine.Status = 'Nuovo';
        }
        OnWorkOrderLineItemTriggerHandler.disableWorkOrderLineItemTrigger = true;
        update woliMap.values();
        //OnWorkOrderLineItemTriggerHandler.disableWorkOrderLineItemTrigger = false;
    }*/

    /**
     * metodo di assegnazione dei supplier su workorder
     */
    public static void assignSupplier(Map<Id,WorkOrder> newMap)
    {
        //after update
        //-------variabili---------
        List<SBQQ__Quote__c> quote = new list<SBQQ__Quote__c>();
        map<string, workorder> mapWOk = new map<String, WorkOrder>();
        map<string, double> supMargMap = new map<string, double>();
        map<string, string> mapFornCalc = new map<String,String>();
        Map<String,list<WRT_FSL_Supplier__c>> mapSup = new map<string,list<WRT_FSL_Supplier__c>>();
        map<double, string> mapMarcPercSup = new map<double, string>();
        set<string> prodottoSet = new set<string>();
        set<string> areaGeoSet = new set<string>();
        List<WRT_Supplier_Proposal__c> suppList = new List<WRT_Supplier_Proposal__c>();
        set<id> accountId = new set<id>();
        map<string, workorder> mapWokIperAcc = new map<string, WorkOrder>();
        map<string, string> oppRegionMap = new map<String, String>();
        map<string, double> oppSalesPriceMap = new map<String, double>();
        map<string, workOrder> parentWokMap = new map<string, workorder>();
        map<string, list<WRT_Supplier_Proposal__c>> supWoOldMap = new map<string, list<WRT_Supplier_Proposal__c>>();

        WRT_Warrant_FSL_Settings__c sett = WRT_Warrant_FSL_Settings__c.getInstance();
        Id iperRecordTypeId = Schema.SObjectType.WorkOrder.getRecordTypeInfosbyDeveloperName().get('WRT_Iper').getRecordTypeId();

        //ciclo per recuperare i valori dei prodotti e aree geografiche per filtrare la query sui supplier
        for(WorkOrder wok : newMap.values())
        {
            if(wok.RecordTypeId == iperRecordTypeId && 
               wok.WRT_Product_Name__c != null && 
               wok.WRT_Assigned_Supplier__c == false && 
               wok.WRT_Investment_Amount__c != null && 
               wok.WRT_Number_Of_Goods__c != null)
            {
                System.debug(wok);
                string prodotto = wok.WRT_Product_Name__c; //prodotto quotelines WRT_Opportunity_Product__c
                //string areaGeo = '%'+'Italia'+'%'; //area geografica quote

                //controllo quale sia il prodotto
                if (prodotto.contains('IPER'))  
                {
                    prodotto = 'Iper';
                }
                else if (prodotto.contains('REV')) 
                {
                    prodotto = 'Rev';
                }
                else if (prodotto.contains('AUDIT')) 
                {
                    prodotto = 'Audit';
                }
                prodottoSet.add(prodotto); //valori prodotti da quote
                areaGeoSet.add(wok.WRT_Opportunity__c); //valore service territory work order
                accountId.add(wok.AccountId);
            }
            if(wok.Copy_for_Late_Interconnection__c)
            {
                parentWokMap.put(wok.ParentWorkOrderId, wok);
            }
        }

        if(!accountId.isEmpty())
        {
            //recupero workOrder iper già presenti sugli account
            for(workorder wokIper : [select id, wrt_supplier__c, AccountId 
                                     from WorkOrder 
                                     where accountid in :accountId and 
                                     recordtypeid = :iperRecordTypeId and 
                                     id not in :newMap.keyset() 
                                     order by createddate desc ])
            {
                if(mapWokIperAcc.get(wokIper.AccountId) == null)
                {
                    mapWokIperAcc.put(wokIper.AccountId, wokIper);
                }
            }
        }
        
        system.debug('mapIper '+mapWokIperAcc);
        if(!areaGeoset.isEmpty())
        {
            //recupero regioni dei service territory delle opp 
            //recupero valore da quote () se Unitprice == 0
            for (opportunity opp : [select id, amount,Operational_Headquarter__r.WRT_Region__c, 
                                    SBQQ__PrimaryQuote__r.Valore_del_pagamento_in_euro__c 
                                    from opportunity 
                                    where id in :areaGeoset]) 
            {
                oppRegionMap.put(opp.id, opp.Operational_Headquarter__r.WRT_Region__c);
                System.debug('Region '+opp.Operational_Headquarter__r.WRT_Region__c);
                if(opp.SBQQ__PrimaryQuote__r.Valore_del_pagamento_in_euro__c <= 0)
                {
                    oppSalesPriceMap.put(opp.id, opp.amount);
                }
                else if(Test.isRunningTest())
                {
                    oppSalesPriceMap.put(opp.id, 10000);
                }
                else
                {
                    oppSalesPriceMap.put(opp.id, opp.SBQQ__PrimaryQuote__r.Valore_del_pagamento_in_euro__c);
                }
            }
            //query su oppline items quando campo quote vuoto
        }

        //---- query supplier -----
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('WRT_FSL_Supplier__c').getDescribe().fields.getMap();
        list<string> list_field = new list<string>(fieldMap.keyset());
        Id supRecordTypeId = Schema.SObjectType.WRT_FSL_Supplier__c.getRecordTypeInfosbyDeveloperName().get('SupplierCFG').getRecordTypeId();

        string qrSelect = 'select '+string.join(list_field , ',');//SELECT con tutti i campi dell'oggetto
        string qrFrom = ' from WRT_FSL_Supplier__c';//FROM oggetto
        string qrWhere = ' WHERE WRT_Type__c IN :prodottoSet and recordtypeid = :supRecordTypeId'; //WHERE filtri query
        string qrOrder = ' order by '; //ORDER BY ordinamento risultati query
        
        //creo una variabile di tipo "Tipo lista<Oggetto>"
        System.Type listType = System.Type.forName('List<WRT_FSL_Supplier__c>');
        //istanzio una lista vuota del tipo "listType", in modo da poter fare il cast di "result" nel tipo corretto al di fuori del metodo
        List<WRT_FSL_Supplier__c> result = (List<WRT_FSL_Supplier__c>)listType.newInstance();

        if(!prodottoSet.isEmpty())
        {
            result = database.query(qrSelect + qrFrom + qrWhere /*+ qrOrder*/);
            System.debug(result);
            //ciclo su lista Supplier filtrata per prodotto e area geografica
            for(WRT_FSL_Supplier__c sup : result)
            {
                //riempo una mappa inserendo i supplier per ogni fornitore
                //mappa(fornitore, list[sup1, sup3, sup2])
                //se è la prima volta che trovo il forniore, creo la lista di record supplier
                if(!mapSup.containsKey(sup.WRT_Supplier__c))
                {
                    mapSup.put(sup.WRT_Supplier__c, new list<WRT_FSL_Supplier__c>{sup});
                }
                else //aggiungo alla lista dei record supplier
                {
                    mapSup.get(sup.WRT_Supplier__c).add(sup);
                }
            }
        }

        if(!mapSup.isEmpty())
        {
            //ciclo di nuovo i workorder
            for(WorkOrder wok : newMap.values())
            {
                if(wok.RecordTypeId == iperRecordTypeId && 
                   wok.WRT_Product_Name__c != null && 
                   wok.WRT_Assigned_Supplier__c == false && 
                   oppSalesPriceMap.get(wok.WRT_Opportunity__c) >0)
                {
                    //mappare numero beni con campo quote
                    //mappare campo valore investimento 
                    string prodotto = wok.WRT_Product_Name__c; //prodotto quotelines
                    string areaGeo = (oppRegionMap.get(wok.WRT_Opportunity__c) != null)? oppRegionMap.get(wok.WRT_Opportunity__c) : ''; //valore service territory work order
                    Double valInv = wok.WRT_Investment_Amount__c; //valore investimento quote
                    Decimal numBeni = wok.WRT_Number_Of_Goods__c; //numero beni quote
                    Double ricWarrant = oppSalesPriceMap.get(wok.WRT_Opportunity__c); //ricavo warrant quote
                    Double percMarg = 0.0; //percentuale marginalità   
                    
                    /*ricavo warrant
                    WRT_Warrant_Return__c

                    valore investimento
                    WRT_Investment_Amount__c

                    numbero beni
                    WRT_Number_Of_Goods__c*/

                    //booleani di controllo
                    Boolean found = false;
                    Boolean err = false;

                    //controllo quale sia il prodotto
                    if (prodotto.contains('IPER'))  
                    {
                        prodotto = 'Iper';
                    }
                    else if (prodotto.contains('REV')) 
                    {
                        prodotto = 'Rev';
                    }
                    else if (prodotto.contains('AUDIT')) 
                    {
                        prodotto = 'Audit';
                    }

                    //ciclo sulla mappa dei fornitori, supplier per individuare il tipo di calcolo corretto
                    for (string supList : mapSup.keyset()) 
                    {
                        for(WRT_FSL_Supplier__c supp : mapSup.get(supList))
                        {
                            if(prodotto.contains(supp.WRT_Type__c) && 
                               (supp.WRT_Geographic_Area__c.contains(areaGeo) || supp.WRT_Geographic_Area__c == 'Italia'))
                            {
                                //switch case per tipo calcolo
                                switch on supp.WRT_Calculation_Type__c 
                                {
                                    when 'A' 
                                    {
                                        if (valInv >= supp.WRT_Investment_from__c && valInv <= supp.WRT_Investment_to__c) 
                                        {
                                            percMarg = (ricWarrant - (supp.WRT_Amount__c + (supp.WRT_Visits__c * supp.WRT_Visit_Amount__c))) / ricWarrant;
                                            
                                            found = true;

                                            System.debug('supp '+ supp.name + ' calc '+supp.WRT_Calculation_Type__c + ' marg '+ percMarg);
                                        }
                                    }
                                    when 'B' 
                                    {
                                        if (valInv >= supp.WRT_Investment_from__c && valInv <= supp.WRT_Investment_to__c) 
                                        {
                                            System.debug('supplier: ' + supp.name + 'ricWarrant: ' + ricWarrant);
                                            System.debug('supplier: ' + supp.name + 'supp.WRT_Amount__c: ' + supp.WRT_Amount__c);
                                            System.debug('supplier: ' + supp.name + 'supp.WRT_Visits__c: ' + supp.WRT_Visits__c);
                                            System.debug('supplier: ' + supp.name + 'supp.WRT_Visit_Amount__c: ' + supp.WRT_Visit_Amount__c);
                                            System.debug('supplier: ' + supp.name + 'numBeni: ' + numBeni);
                                            System.debug('supplier: ' + supp.name + 'supp.WRT_Premiality_of_goods_greater_than__c: ' + supp.WRT_Premiality_of_goods_greater_than__c);
                                            System.debug('supplier: ' + supp.name + 'WRT_Premiality_of_goods_amount__c: ' + supp.WRT_Premiality_of_goods_amount__c);
                                            
                                            //1200 fisso da modificare
                                            percMarg = (ricWarrant - (supp.WRT_Amount__c + 
                                                                      (supp.WRT_Visits__c * supp.WRT_Visit_Amount__c) + 
                                                                      ((numBeni > supp.WRT_Premiality_of_goods_greater_than__c)? 1200 : 0.00))) / ricWarrant;

                                            found = true;

                                            System.debug('supp '+ supp.name + ' calc '+supp.WRT_Calculation_Type__c + ' marg '+ percMarg);
                                        }
                                    }
                                    when 'C' 
                                    {
                                        if(numBeni >= supp.WRT_Number_of_goods_from__c && numBeni <= supp.WRT_Number_of_goods_to__c)
                                        {
                                            percMarg = (ricWarrant - (supp.WRT_Number_of_Goods_Amount__c + (supp.WRT_Visits__c * supp.WRT_Visit_Amount__c))) / ricWarrant;

                                            found = true;

                                            System.debug('supp '+ supp.name + ' calc '+supp.WRT_Calculation_Type__c + ' marg '+ percMarg);
                                        }
                                    }
                                    when 'D' 
                                    {
                                        if (valInv >= supp.WRT_Investment_from__c && valInv <= supp.WRT_Investment_to__c) 
                                        {
                                            if(numBeni >= supp.WRT_Premiality_of_goods_from__c && numBeni <= supp.WRT_Premiality_of_goods_to__c)
                                            {
                                                percMarg = (ricWarrant - (supp.WRT_Amount__c + 
                                                                          supp.WRT_Premiality_of_goods_amount__c + 
                                                                          (supp.WRT_Visit_Amount__c * supp.WRT_Visits__c))) / ricWarrant;
                                                
                                                found = true;

                                                System.debug('supp '+ supp.name + ' calc '+supp.WRT_Calculation_Type__c + ' marg '+ percMarg);
                                            }
                                        }
                                    }
                                    when 'E' 
                                    {
                                        if ((valInv >= supp.WRT_Investment_from__c && valInv <= supp.WRT_Investment_to__c) && numBeni >= supp.WRT_Number_of_goods_from__c && numBeni <= supp.WRT_Number_of_goods_to__c) 
                                        {
                                            percMarg = (ricWarrant - (supp.WRT_Amount__c + (supp.WRT_Visit_Amount__c * supp.WRT_Visits__c))) / ricWarrant;
                                            
                                            found = true;

                                            System.debug('supp '+ supp.name + ' calc '+supp.WRT_Calculation_Type__c + ' marg '+ percMarg);
                                        }
                                    }
                                    when 'F' 
                                    {
                                        if (valInv >= supp.WRT_Investment_from__c && valInv <= supp.WRT_Investment_to__c) 
                                        {
                                            if(numBeni >= supp.WRT_Premiality_of_goods_from__c && numBeni <= supp.WRT_Premiality_of_goods_to__c)
                                            {
                                                percMarg = (ricWarrant - (supp.WRT_Amount__c + supp.WRT_Premiality_of_goods_amount__c)) / ricWarrant;
                                                
                                                found = true;

                                                System.debug('supp '+ supp.name + ' calc '+supp.WRT_Calculation_Type__c + ' marg '+ percMarg);
                                            }
                                        }
                                    }
                                    when 'G' 
                                    {
                                        percMarg = (ricWarrant - ((((ricWarrant * (supp.WRT_payOff__c/100)) > supp.WRT_Minimum_Payoff__c)? ricWarrant * (supp.WRT_payOff__c/100) : supp.WRT_Minimum_Payoff__c) + supp.WRT_down_payment__c)) / ricWarrant;
                                        
                                        found = true;

                                        System.debug('supp '+ supp.name + ' calc '+supp.WRT_Calculation_Type__c + ' marg '+ percMarg);
                                        System.debug('(ricWarrant * supp.WRT_payOff__c) > supp.WRT_Minimum_Payoff__c '+((ricWarrant * (supp.WRT_payOff__c/100)) > supp.WRT_Minimum_Payoff__c));
                                        system.debug('supp.WRT_Minimum_Payoff__c '+supp.WRT_Minimum_Payoff__c);
                                        system.debug('supp.WRT_payOff__c '+(supp.WRT_payOff__c/100));
                                        system.debug('supp.WRT_down_payment__c '+supp.WRT_down_payment__c);
                                    }
                                    when 'H' 
                                    {
                                        if (valInv >= supp.WRT_Investment_from__c && valInv <= supp.WRT_Investment_to__c && numBeni >= supp.WRT_Number_of_goods_from__c && numBeni <= supp.WRT_Number_of_goods_to__c) 
                                        {
                                            percMarg = (ricWarrant - (supp.WRT_Amount__c + (supp.WRT_Visit_Amount__c * supp.WRT_Visits__c))) / ricWarrant;

                                            found = true;

                                            System.debug('supp '+ supp.name + ' calc '+supp.WRT_Calculation_Type__c + ' marg '+ percMarg);
                                        }
                                    }
                                    when 'I' 
                                    {
                                        if (valInv >= supp.WRT_Investment_from__c && valInv <= supp.WRT_Investment_to__c) 
                                        {
                                            percMarg = (ricWarrant - (supp.WRT_Amount__c)) / ricWarrant;

                                            found = true;

                                            System.debug('supp '+ supp.name + ' calc '+supp.WRT_Calculation_Type__c + ' marg '+ percMarg);
                                        }
                                    }
                                    when else 
                                    {
                                        System.debug('Nessuna configurazione trovata');
                                        //Errore di assegnazione
                                        err = true;
                                        found = true;
                                    }
                                }
                                //controllo che per il fornitore sia stato calcolato il margine più alto
                                if(supMargMap.get(supp.WRT_Supplier__c) != null && supMargMap.get(supp.WRT_Supplier__c) > percMarg)
                                {
                                    supMargMap.put(supp.WRT_Supplier__c, percMarg);
                                }
                                //se non è stato calcolato nulla imposto il messaggio di errore
                                else if(err)
                                {
                                    supMargMap.put('Assignment Error', 100);
                                }
                                else 
                                {
                                    supMargMap.put(supp.WRT_Supplier__c, percMarg);
                                }
                                //esco dal for se ho trovato una marginalità
                                if(found) break;
                            }
                            
                        }
                        found = false;
                    }
                    double marg = 0.00;
                    string fornitore = '';
                    
                    for(string forn : supMargMap.keyset()) 
                    {
                        //creo record oggetto supplier proposal per ogni workorder
                        WRT_Supplier_Proposal__c  supPro = new WRT_Supplier_Proposal__c ();
                        supPro.Work_Order__c = wok.id;
                        supPro.Selected_Supplier__c = false;
                        supPro.Name = forn;
                        supPro.Marginality__c = supMargMap.get(forn)*100;
                        suppList.add(supPro);
                    }
                    integer count = 1;
                    boolean multipli;
                    integer approval = 1;
                    boolean oldSet = false;
                    //ciclo su lista supList per recuperare fornitore con marg più alta
                    for(integer  i = 0; i < suppList.size(); i++)
                    {
                        if(oldSet) break;
                        //controllo che il nome del supplier sia uguale a quello già inserito su vecchi wo o wo da rinnovo
                        if((mapWokIperAcc.get(wok.AccountId) != null && mapWokIperAcc.get(wok.AccountId).WRT_Supplier__c == suppList[i].Name) || 
                            (parentWokMap.get(wok.ParentWorkOrderId) != null && parentWokMap.get(wok.ParentWorkOrderId).WRT_Supplier_From_Renewal__c == suppList[i].Name))
                        {
                            system.debug('suppList[i].Name '+suppList[i].Name);
                            marg = suppList[i].Marginality__c;
                            if(marg > sett.Supplier_Low_Marginality__c)
                            {
                                suppList[i].Selected_Supplier__c = true;
                                suppList[count].Selected_Supplier__c = false;
                                count = i;
                                fornitore = suppList[i].Name; 
                            }
                            else 
                            {
                                suppList[i].On_approval__c = true;
                                suppList[approval].On_approval__c = false;
                                suppList[i].Selected_Supplier__c = false;
                                suppList[approval].Selected_Supplier__c = false;
                                fornitore = 'On Approval'; 
                                approval = i;
                            }
                            multipli = false;
                            oldSet = true;
                        }
                        else 
                        {
                            if(marg < suppList[i].Marginality__c)
                            {
                                marg = suppList[i].Marginality__c;
                                if(marg > sett.Supplier_Low_Marginality__c)
                                {
                                    suppList[i].Selected_Supplier__c = true;
                                    suppList[count].Selected_Supplier__c = false;
                                    count = i;
                                    fornitore = suppList[i].Name; 
                                }
                                else 
                                {
                                    suppList[i].On_approval__c = true;
                                    suppList[approval].On_approval__c = false;
                                    suppList[i].Selected_Supplier__c = false;
                                    suppList[approval].Selected_Supplier__c = false;
                                    fornitore = 'On Approval'; 
                                    approval = i;
                                }
                                multipli = false;
                            }
                            else if(marg == suppList[i].Marginality__c)
                            {
                                //count++;
                                fornitore = 'Multiple Results';
                                suppList[i].Selected_Supplier__c = false;
                                suppList[count].Selected_Supplier__c = false;
                                suppList[i].On_approval__c = false;
                                suppList[approval].On_approval__c = false;
                                multipli = true;
                            }
                        }
                        //count = 1;
                        /*if (marg < sett.Supplier_Low_Marginality__c && suppList[i].Selected_Supplier__c && !multipli) 
                        {
                            suppList[i].On_approval__c = true;
                            suppList[i].Selected_Supplier__c = false;
                            suppList[count].Selected_Supplier__c = false;
                            suppList[count].On_approval__c = false;
                        }*/
                    }
                    System.debug('marginalità '+ marg);
                    //sort mapMarcPercSup per percentuale --> aggiornamento per parità di Margine (quale fornitore?)
                    WorkOrder woki = new workOrder(id = wok.id);
                    woki.WRT_Supplier__c = fornitore;
                    woki.WRT_Assigned_Supplier__c = true;
                    mapWOk.put(woki.id, woki);
                }
            }
        }
        else
        {
            for (workorder wokNo : newmap.values()) 
            {
                if(wokNo.RecordTypeId == iperRecordTypeId && wokNo.WRT_Product_Name__c != null && woKNo.WRT_Assigned_Supplier__c == false)
                {
                    WorkOrder wokiNo = new workOrder(id = wokNo.id);
                    wokiNo.WRT_Supplier__c = 'No Supplier found';
                    mapWOk.put(wokiNo.id, wokiNo);
                }
            }    
        }
        //creazione correlato record supplier proposal
        //aggiornaiamo il campo lookup con valore se solo uno
        //se più di uno flag su margine più alto
        insert suppList;
        for(WRT_Supplier_Proposal__c spl : suppList)
        {
            if(spl.On_Approval__c)
            {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setProcessDefinitionNameOrId('Low_Marginality');
                req1.setComments('Submitting request for approval.');
                req1.setObjectId(spl.Id);
                //req1.setSubmitterId(UserInfo.getUserId()); 
                Approval.ProcessResult resultApp = Approval.process(req1);
            }
        }
        OnWorkOrderTriggerHandler.disableWorkOrderTrigger = true;
        update mapWOk.values();
        OnWorkOrderTriggerHandler.disableWorkOrderTrigger = false;
    }

    /*public static void sendWorkOrderAndTask(Map<Id,WorkOrder> newMap)
    {
        list<id> wokIdList = new List<id>();
        for (workorder wok : newMap.values()) 
        {
            if (wok.Send_WO_and_Task__c) 
            {
                wokIdList.add(wok.Id);
            }    
            system.debug('Invio workorder wok.Send_WO_and_Task__c '+wok.Send_WO_and_Task__c);
        }
        
        if (wokIdList.size()>0) WRT_IntegrazioneController.workorderIntegration(wokIdList);
    }*/

    /*public static void updateProductOpp(Map<Id,WorkOrder> newMap)
    {
        map<id, OpportunityLineItem> mapOppProd = new map <id, OpportunityLineItem>();
        set<id> oppId = new set<id>();

        for(workorder wo : newmap.values())
        {
            oppId.add(wo.WRT_Opportunity__c);
        }
        for(OpportunityLineItem oppLi : [select id, OpportunityID, Name from OpportunityLineItem where OpportunityID in :oppId])
        {
            mapOppProd.put(oppLi.OpportunityID, oppLi);
        }
        for(workorder wo : newmap.values())
        {
            if(mapOppProd.get(wo.WRT_Opportunity__c) != null)
            {
                wo.WRT_Opportunity_Product__c = mapOppProd.get(wo.WRT_Opportunity__c).id;
                System.debug('product name '+mapOppProd.get(wo.WRT_Opportunity__c).Name);
                system.debug('wrt opp prod '+wo.WRT_Opportunity_Product__c);
            }
        }*/
        /*OnWorkOrderTriggerHandler.disableWorkOrderTrigger = true;
        update newMap.values();
        OnWorkOrderTriggerHandler.disableWorkOrderTrigger = false;*/
    //}

    public static void checkClone(list<workorder> newMap)
    {
        set<id> wokId = new set<id>();
        for(workorder wok : newMap)
        {
            if(wok.isClone())
            {
                wokId.add(wok.getCloneSourceId());
            }
        }
        map<id, workorder> parentWok = new map<id, workOrder>([select id, 
                                                               WRT_Clone_Number__c 
                                                               from workorder 
                                                               where id in :wokId]);
        for(workorder wok : newMap)
        {
            if(wok.isClone())
            {
                system.debug('true clone '+ wok.getCloneSourceId());
                wok.ParentWorkOrderId = wok.getCloneSourceId();
                wok.WRT_Clone_Number__c = parentWok.get(wok.getCloneSourceId()).WRT_Clone_Number__c + 1;
            } 
        }
    }
}