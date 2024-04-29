public class WGC_Chart_Controller {

    public static User currentUser = [SELECT Id, Name, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
    /* UTILITY METHOD - START */

    @AuraEnabled
    public static WGC_Chart_Callable.CallableResponse getChartDataGeneric(String apexClass, String apexMethod, Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();
        try{
            Callable callableClass = (Callable)Type.forName(apexClass).newInstance();

            response = (WGC_Chart_Callable.CallableResponse)callableClass.call(apexMethod, params);
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }

        return response;
    }

    @AuraEnabled
    public static ChartMetadata getChartsMetadata(String apiNameMetadato){
        try{
            WGC_Chart__mdt metadato = [SELECT DeveloperName, MasterLabel, Titolo__c, Label_pulsanti__c, Azioni_pulsanti__c, Informazioni_Grafici__c FROM WGC_Chart__mdt WHERE DeveloperName =: apiNameMetadato];

            ChartMetadata response = new ChartMetadata();
            response.codice = metadato.DeveloperName;
            response.name = metadato.DeveloperName;
            response.titolo = metadato.Titolo__c;

            Map<String,List<String>> mapBtnLabel = new Map<String,List<String>>();

            if(metadato.Label_pulsanti__c != null){
                //Controllo se contiene due livelli, il separatore - è utilizzato per dividerli
                if(metadato.Label_pulsanti__c.contains('-')){
                    List<String> btnLabels = metadato.Label_pulsanti__c.split('-');
                    //Per ogni pulsante di primo livello creo una chiave nella mappa con la prima parte di label
                    //Separata da i : e i restanti pulsanti associati in un array separati da ;
                    for(String label : btnLabels){
                        List<String> tmpLabel = label.split(':');
                        mapBtnLabel.put(tmpLabel[0], tmpLabel[1].split(';'));
                    }
                } else {
                    //Se non ho due livelli utilizzo il nome del metadato come chiave per la lista di pulsanti
                    mapBtnLabel.put(apiNameMetadato, metadato.Label_pulsanti__c.split(';'));
                }
            }
            response.btnLabel = mapBtnLabel;
            if(metadato.Azioni_pulsanti__c != null)
                response.btnActions = metadato.Azioni_pulsanti__c.split(';');

            response.informazioniGrafici = metadato.Informazioni_Grafici__c;

            return response;
        } catch(Exception e){
            System.debug('@@@ ecc ' + e.getMessage() + ' -- ' + e.getStackTraceString());
            throw new AuraHandledException('Nessun grafico configurato');
        }
    }

    /* UTILITY METHOD - END */

    /* CHART METHOD - START */

    public static WGC_Chart_Callable.CallableResponse Account_Posizione_Cliente(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            Id accountId = (Id)params.get('accountId');
            Map<String, List<WGC_Posizione__c>> posizioniAccount = U.groupBy([SELECT Id, Famiglia_Prodotto__c, Accordato__c, Impiego__c  FROM WGC_Posizione__c WHERE Anagrafica__c =: accountId ORDER BY Famiglia_Prodotto__c], 'Famiglia_Prodotto__c');

            ChartInfo ci = new ChartInfo();
            ci.data = posizioniAccount;
            ci.groupedBy = new String[]{'Accordato__c','Impiego__c'};
            response.data.add(ci);
            
        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }

        return response;
    }

    public static WGC_Chart_Callable.CallableResponse Account_Posizione_OutstandingDeb(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            Account currentAccount = [SELECT Id, Name, Tempi_medi_di_pagamento__c, Tempi_medi_di_riconoscimento__c FROM Account WHERE Id=: (Id)params.get('accountId')];
            Map<String, List<WGC_Posizione_Debitore__c>> allPosition = U.groupBy([SELECT Id, Name, Aggregato__c, Importo__c, Tipo_Importo__c FROM WGC_Posizione_Debitore__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND ( Tipo_Importo__c = 'ATD' OR Tipo_Importo__c = 'DFO' OR Tipo_Importo__c = 'notnot' OR Tipo_importo__c = 'Mat' ) ORDER BY Aggregato__c], 'Aggregato__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = allPosition;
            ci1.groupedBy = new String[]{'Tipo_importo__c', 'Importo__c'};
            ci1.isStacked = true;

            ChartInfo ci2 = new ChartInfo();
            ci2.data = currentAccount.Tempi_medi_di_pagamento__c;
            // ci2.title = Schema.SObjectType.Account.fields.Tempi_medi_di_pagamento__c.getLabel();
            ci2.title = new List<String>{'Pagamento'};
            ci2.subtitle = '(Tempo medio gg)';

            ChartInfo ci3 = new ChartInfo();
            ci3.data = currentAccount.Tempi_medi_di_riconoscimento__c;
            // ci3.title = Schema.SObjectType.Account.fields.Tempi_medi_di_riconoscimento__c.getLabel();
            ci3.title = new List<String>{'Riconoscimento'};
            ci3.subtitle = '(Tempo medio gg)';
 

            response.data.add(ci1);
            response.data.add(ci2);
            response.data.add(ci3);

        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }

        return response;
    }

    public static WGC_Chart_Callable.CallableResponse Account_Posizione_PlafondDeb(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            Account currentAccount = [SELECT Id, Name, Tempi_medi_di_pagamento__c, Tempi_medi_di_riconoscimento__c FROM Account WHERE Id=: (Id)params.get('accountId')];
            Map<String, List<WGC_Posizione_Debitore__c>> allPosition = U.groupBy([SELECT Id, Name, Aggregato__c, Importo__c, Tipo_Importo__c FROM WGC_Posizione_Debitore__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND ( Tipo_Importo__c = 'Plafond' OR Tipo_Importo__c = 'prosoluto' OR Tipo_Importo__c = 'utilizzato_totale' OR Tipo_Importo__c = 'Utilizzato_Totale') ORDER BY Aggregato__c], 'Aggregato__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = allPosition;
            ci1.groupedBy = new String[]{'Tipo_importo__c', 'Importo__c'};
            ci1.isStacked = true;
            // ci1.isStacked = false;

            ChartInfo ci2 = new ChartInfo();
            ci2.data = currentAccount.Tempi_medi_di_pagamento__c;
            // ci2.title = Schema.SObjectType.Account.fields.Tempi_medi_di_pagamento__c.getLabel();
            ci2.title = new List<String>{'Pagamento'};
            ci2.subtitle = '(Tempo medio gg)';

            ChartInfo ci3 = new ChartInfo();
            ci3.data = currentAccount.Tempi_medi_di_riconoscimento__c;
            // ci3.title = Schema.SObjectType.Account.fields.Tempi_medi_di_riconoscimento__c.getLabel();
            ci3.title = new List<String>{'Riconoscimento'};
            ci3.subtitle = '(Tempo medio gg)';
 

            response.data.add(ci1);
            response.data.add(ci2);
            response.data.add(ci3);

        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }

        return response;
    }

    public static WGC_Chart_Callable.CallableResponse Account_Monitoraggio_Impiego(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            Account currentAccount = [SELECT Id, Name, Tempi_medi_di_pagamento__c, Tempi_medi_di_riconoscimento__c FROM Account WHERE Id=: (Id)params.get('accountId')];
            Map<String, List<WGC_Performance__c>> allPosition = U.groupBy([SELECT Id, Name, Actual__c, Actual_PY__c, Mese__c FROM WGC_Performance__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND RecordType.DeveloperName = 'Impiego' AND Anno__c =: String.valueOf(System.Today().year()) ORDER BY Mese__c ASC], 'Mese__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = allPosition;
            ci1.groupedBy = new String[]{'Actual__c', 'Actual_PY__c'};
            ci1.isStacked = false;

            response.data.add(ci1);

        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }

        return response;
    }

    public static WGC_Chart_Callable.CallableResponse Account_Monitoraggio_Mdi(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            Account currentAccount = [SELECT Id, Name, Tempi_medi_di_pagamento__c, Tempi_medi_di_riconoscimento__c FROM Account WHERE Id=: (Id)params.get('accountId')];
            Map<String, List<WGC_Performance__c>> allPosition = U.groupBy([SELECT Id, Name, Actual__c, Actual_PY__c, Mese__c FROM WGC_Performance__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND RecordType.DeveloperName = 'MDI' AND Anno__c =: String.valueOf(System.Today().year()) ORDER BY Mese__c ASC], 'Mese__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = allPosition;
            ci1.groupedBy = new String[]{'Actual__c', 'Actual_PY__c'};
            ci1.isStacked = false;

            response.data.add(ci1);

        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }

        return response;
    }

    public static WGC_Chart_Callable.CallableResponse Account_Monitoraggio_TurnoverCliente(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            Account currentAccount = [SELECT Id, Name, Tempi_medi_di_pagamento__c, Tempi_medi_di_riconoscimento__c FROM Account WHERE Id=: (Id)params.get('accountId')];
            Map<String, List<WGC_Performance__c>> allPosition = U.groupBy([SELECT Id, Name, Actual__c, Actual_PY__c, Mese__c FROM WGC_Performance__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND RecordType.DeveloperName = 'Turnover' AND Anno__c =: String.valueOf(System.Today().year()) ORDER BY Mese__c ASC], 'Mese__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = allPosition;
            ci1.groupedBy = new String[]{'Actual__c', 'Actual_PY__c'};
            ci1.isStacked = false;

            response.data.add(ci1);

        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }

        return response;
    }

    public static WGC_Chart_Callable.CallableResponse Account_Monitoraggio_Outstanding(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            Account currentAccount = [SELECT Id, Name, Tempi_medi_di_pagamento__c, Tempi_medi_di_riconoscimento__c FROM Account WHERE Id=: (Id)params.get('accountId')];
            Map<String, List<WGC_Performance__c>> allPosition = U.groupBy([SELECT Id, Name, Actual__c, Actual_PY__c, Mese__c FROM WGC_Performance__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND RecordType.DeveloperName = 'Outstanding' AND Anno__c =: String.valueOf(System.Today().year()) ORDER BY Mese__c ASC], 'Mese__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = allPosition;
            ci1.groupedBy = new String[]{'Actual__c', 'Actual_PY__c'};
            ci1.isStacked = false;

            response.data.add(ci1);

        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }

        return response;
    }

    public static WGC_Chart_Callable.CallableResponse Account_Monitoraggio_Plafond(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            Account currentAccount = [SELECT Id, Name, Tempi_medi_di_pagamento__c, Tempi_medi_di_riconoscimento__c FROM Account WHERE Id=: (Id)params.get('accountId')];
            Map<String, List<WGC_Performance__c>> allPosition = U.groupBy([SELECT Id, Name, Actual__c, Actual_PY__c, Mese__c FROM WGC_Performance__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND RecordType.DeveloperName = 'Plafond' AND Anno__c =: String.valueOf(System.Today().year()) ORDER BY Mese__c ASC], 'Mese__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = allPosition;
            ci1.groupedBy = new String[]{'Actual__c', 'Actual_PY__c'};
            ci1.isStacked = false;

            response.data.add(ci1);

        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }

        return response;
    }

    public static WGC_Chart_Callable.CallableResponse Account_Monitoraggio_TurnoverDebitore(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            Account currentAccount = [SELECT Id, Name, Tempi_medi_di_pagamento__c, Tempi_medi_di_riconoscimento__c FROM Account WHERE Id=: (Id)params.get('accountId')];
            Map<String, List<WGC_Performance__c>> allPosition = U.groupBy([SELECT Id, Name, Actual__c, Actual_PY__c, Mese__c FROM WGC_Performance__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND RecordType.DeveloperName = 'Tournover Debitore' AND Anno__c =: String.valueOf(System.Today().year()) ORDER BY Mese__c ASC], 'Mese__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = allPosition;
            ci1.groupedBy = new String[]{'Actual__c', 'Actual_PY__c'};
            ci1.isStacked = false;

            response.data.add(ci1);

        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }

        return response;
    }

    public static WGC_Chart_Callable.CallableResponse Opportunity_Monitoraggio_Redditivita(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            Account currentAccount = [SELECT Id, Name, Tempi_medi_di_pagamento__c, Tempi_medi_di_riconoscimento__c FROM Account WHERE Id=: (Id)params.get('accountId')];
            Map<String, List<WGC_Performance__c>> allPosition = U.groupBy([SELECT Id, Name, Actual__c, Actual_PY__c, Mese__c FROM WGC_Performance__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND RecordType.DeveloperName = 'MDI' AND Anno__c =: String.valueOf(System.Today().year()) ORDER BY Mese__c ASC], 'Mese__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = allPosition;
            ci1.groupedBy = new String[]{'Actual__c', 'Actual_PY__c'};
            ci1.isStacked = false;

            response.data.add(ci1);

        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }

        return response;
    }

    public static WGC_Chart_Callable.CallableResponse Opportunity_Monitoraggio_Volumi(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            Account currentAccount = [SELECT Id, Name, Tempi_medi_di_pagamento__c, Tempi_medi_di_riconoscimento__c FROM Account WHERE Id=: (Id)params.get('accountId')];

            List<WGC_Performance__c> positionImpiego = new List<WGC_Performance__c>([SELECT Id, Name, Actual__c, Actual_PY__c, Mese__c FROM WGC_Performance__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND RecordType.DeveloperName = 'Impiego' AND Anno__c =: String.valueOf(System.Today().year()) ORDER BY Mese__c ASC]);
            // positionImpiego = U.filter(positionImpiego, 'RecordType.DeveloperName', 'Impiego');
            Map<String, List<WGC_Performance__c>> mapPositionImpiego = U.groupBy(positionImpiego, 'Mese__c');

            List<WGC_Performance__c> positionTurnover = new List<WGC_Performance__c>([SELECT Id, Name, Actual__c, Actual_PY__c, Mese__c FROM WGC_Performance__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND RecordType.DeveloperName = 'Turnover' AND Anno__c =: String.valueOf(System.Today().year()) ORDER BY Mese__c ASC]);
            // positionImpiego = U.filter(positionImpiego, 'RecordType.DeveloperName', 'Turnover');
            Map<String, List<WGC_Performance__c>> mapPositionTurnover = U.groupBy(positionTurnover, 'Mese__c');

            List<WGC_Performance__c> positionOutstanding = new List<WGC_Performance__c>([SELECT Id, Name, Actual__c, Actual_PY__c, Mese__c FROM WGC_Performance__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND RecordType.DeveloperName = 'Outstanding' AND Anno__c =: String.valueOf(System.Today().year()) ORDER BY Mese__c ASC]);
            // positionImpiego = U.filter(positionImpiego, 'RecordType.DeveloperName', 'Outstanding');
            Map<String, List<WGC_Performance__c>> mapPositionOutstanding = U.groupBy(positionOutstanding, 'Mese__c');

            // Map<String, List<WGC_Performance__c>> allPosition = U.groupBy([SELECT Id, Name, Actual__c, Actual_PY__c, Mese__c FROM WGC_Performance__c WHERE Anagrafica__c =: (Id)params.get('accountId') AND RecordType.DeveloperName = 'MDI' AND Anno__c =: String.valueOf(System.Today().year()) ORDER BY Mese__c ASC], 'Mese__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = mapPositionImpiego;
            ci1.groupedBy = new String[]{'Actual__c', 'Actual_PY__c'};
            ci1.isStacked = false;
            // ci1.title.add('Impiego');
            ci1.title = new String[]{'Impiego'};

            ChartInfo ci2 = new ChartInfo();
            ci2.data = mapPositionTurnover;
            ci2.groupedBy = new String[]{'Actual__c', 'Actual_PY__c'};
            ci2.isStacked = false;
            // ci2.title.add('Turnover');
            ci2.title = new String[]{'Turnover'};


            ChartInfo ci3 = new ChartInfo();
            ci3.data = mapPositionOutstanding;
            ci3.groupedBy = new String[]{'Actual__c', 'Actual_PY__c'};
            ci3.isStacked = false;
            // ci3.title.add('Outstanding');
            ci3.title = new String[]{'Outstanding'};

            response.data.add(ci1);
            response.data.add(ci2);
            response.data.add(ci3);

        } catch (Exception e){
            System.debug('@@@ exc ' + e.getStackTraceString() + ' -- ' + e.getMessage());
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static WGC_Chart_Callable.CallableResponse Tab_Monitoraggio_Impiego(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            if(currentUser.NDGGruppo__c == null)
                throw new AuraHandledException('Too many records');

            List<WGC_Performance__c> allPerformance = new List<WGC_Performance__c>([SELECT Id, Anagrafica__r.Name, Mese__c, Actual__c, Anno__c, Famiglia__c, Codice_Tipo_Importo__c, Tipo_busuness__c, RecordType.DeveloperName FROM WGC_Performance__c WHERE RecordType.DeveloperName = 'Impiego' AND Anno__c =: String.valueOf(System.Today().Year()) AND NDG_Settorista__c =: currentUser.NDGGruppo__c ORDER BY Famiglia__c, Mese__c]);

            Map<String,List<WGC_Performance__c>> mapImpiegoPerformance = U.groupBy(allPerformance, 'Anno__c');
            Map<String,List<WGC_Performance__c>> mapPortafoglioPerformance = U.groupBy(allPerformance, 'Mese__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = mapImpiegoPerformance;
            ci1.groupedBy = new String[]{'Famiglia__c', 'Actual__c'};
            ci1.isStacked = true;
            ci1.title = new List<String>{''};

            ChartInfo ci2 = new ChartInfo();
            ci2.data = mapPortafoglioPerformance;
            ci2.groupedBy = new String[]{'Tipo_busuness__c','Actual__c'};
            ci2.isStacked = true;
            ci2.title = new List<String>{''};

            response.data.add(ci1);
            response.data.add(ci2);
            //Aggiunto per gestire la tabella
            response.data.add(ci2);
        } catch(AuraHandledException exc){
            response.msg = 'Grafico contenente troppi record';
            response.success = false;
        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }
    
        return response;
    }

    @AuraEnabled
    public static WGC_Chart_Callable.CallableResponse Tab_Monitoraggio_Turnover(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            if(currentUser.NDGGruppo__c == null)
                throw new AuraHandledException('Too many records');

            List<WGC_Performance__c> allPerformance = new List<WGC_Performance__c>([SELECT Id, Anagrafica__r.Name, Mese__c, Actual__c, Anno__c, Famiglia__c, Codice_Tipo_Importo__c, Tipo_busuness__c, RecordType.DeveloperName FROM WGC_Performance__c WHERE RecordType.DeveloperName = 'Turnover' AND Anno__c =: String.valueOf(System.Today().Year()) AND NDG_Settorista__c =: currentUser.NDGGruppo__c ORDER BY Famiglia__c, Mese__c]);

            Map<String,List<WGC_Performance__c>> mapImpiegoPerformance = U.groupBy(allPerformance, 'Anno__c');
            Map<String,List<WGC_Performance__c>> mapPortafoglioPerformance = U.groupBy(allPerformance, 'Mese__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = mapImpiegoPerformance;
            ci1.groupedBy = new String[]{'Famiglia__c', 'Actual__c'};
            ci1.isStacked = true;
            ci1.title = new List<String>{''};

            ChartInfo ci2 = new ChartInfo();
            ci2.data = mapPortafoglioPerformance;
            ci2.groupedBy = new String[]{'Tipo_busuness__c','Actual__c'};
            ci2.isStacked = true;
            ci2.title = new List<String>{''};

            response.data.add(ci1);
            response.data.add(ci2);
            //Aggiunto per gestire la tabella
            response.data.add(ci2);
        } catch(AuraHandledException exc){
            response.msg = 'Grafico contenente troppi record';
            response.success = false;
        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }
    
        return response;
    }

    @AuraEnabled
    public static WGC_Chart_Callable.CallableResponse Tab_Monitoraggio_MDI(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            if(currentUser.NDGGruppo__c == null)
                throw new AuraHandledException('Troppi record');
                
            List<WGC_Performance__c> allPerformance = new List<WGC_Performance__c>([SELECT Id, Anagrafica__r.Name, Mese__c, Actual__c, Anno__c, Famiglia__c, Codice_Tipo_Importo__c, Tipo_busuness__c, RecordType.DeveloperName FROM WGC_Performance__c WHERE RecordType.DeveloperName = 'MDI'AND Anno__c =: String.valueOf(System.Today().Year()) AND NDG_Settorista__c =: currentUser.NDGGruppo__c  ORDER BY Famiglia__c, Mese__c]);

            Map<String,List<WGC_Performance__c>> mapImpiegoPerformance = U.groupBy(allPerformance, 'Anno__c');
            Map<String,List<WGC_Performance__c>> mapPortafoglioPerformance = U.groupBy(allPerformance, 'Mese__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = mapImpiegoPerformance;
            ci1.groupedBy = new String[]{'Famiglia__c', 'Actual__c'};
            ci1.isStacked = true;
            ci1.title = new List<String>{''};

            ChartInfo ci2 = new ChartInfo();
            ci2.data = mapPortafoglioPerformance;
            ci2.groupedBy = new String[]{'Tipo_busuness__c','Actual__c'};
            ci2.isStacked = true;
            ci2.title = new List<String>{''};

            response.data.add(ci1);
            response.data.add(ci2);
            //Aggiunto per gestire la tabella
            response.data.add(ci2);
        } catch(AuraHandledException exc){
            response.msg = 'Grafico contenente troppi record';
            response.success = false;
        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }
    
        return response;
    }

    @AuraEnabled
    public static WGC_Chart_Callable.CallableResponse Base_Clienti_HP(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            // if(currentUser.NDGGruppo__c == null)
            //     throw new AuraHandledException('Troppi record');
                
            Map<String, List<WGC_Base_Clienti__c>> records = U.groupBy([SELECT Id, Base_clienti__c FROM WGC_Base_Clienti__c WHERE (Anno__c =: String.valueOf(System.Today().year()) OR Anno__c =: String.valueOf(System.Today().addYears(-1).year())) AND Base_Clienti__c != null AND Anagrafica__r.WGC_Specialista_Factoring__c =: UserInfo.getUserId() AND WGC_Factoring_Attivo__c = true ORDER BY Base_Clienti__c], 'Base_clienti__c');

            // List<WGC_Performance__c> allPerformance = new List<WGC_Performance__c>([SELECT Id, Anagrafica__r.Name, Mese__c, Actual__c, Anno__c, Famiglia__c, Codice_Tipo_Importo__c, Tipo_busuness__c, RecordType.DeveloperName FROM WGC_Performance__c WHERE RecordType.DeveloperName = 'MDI'AND Anno__c =: String.valueOf(System.Today().Year()) AND NDG_Settorista__c =: currentUser.NDGGruppo__c  ORDER BY Famiglia__c, Mese__c]);

            // Map<String,List<WGC_Performance__c>> mapImpiegoPerformance = U.groupBy(allPerformance, 'Anno__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = records;
            ci1.groupedBy = new String[]{'CountID'};
            ci1.isStacked = false;
            ci1.title = new List<String>{''};

            response.data.add(ci1);
            
        } catch(AuraHandledException exc){
            response.msg = 'Grafico contenente troppi record';
            response.success = false;
        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }
    
        return response;
    }

    @AuraEnabled
    public static WGC_Chart_Callable.CallableResponse Clienti_Operativi_Factoring(Map<String,Object> params){
        WGC_Chart_Callable.CallableResponse response = new WGC_Chart_Callable.CallableResponse();

        try{
            // if(currentUser.NDGGruppo__c == null)
            //     throw new AuraHandledException('Troppi record');
                
            Map<String, List<WGC_Base_Clienti__c>> records = U.groupBy([SELECT Id, Base_clienti__c, Anno__c, Mese__c FROM WGC_Base_Clienti__c WHERE (Anno__c =: String.valueOf(System.Today().year()) OR Anno__c =: String.valueOf(System.Today().addYears(-1).year())) AND Base_Clienti__c != null AND Anagrafica__r.WGC_Specialista_Factoring__c =: UserInfo.getUserId() AND WGC_Factoring_Attivo__c = true AND FlagOperativo__c = true ORDER BY Mese__c, Anno__c], 'Mese__c');

            ChartInfo ci1 = new ChartInfo();
            ci1.data = records;
            ci1.groupedBy = new String[]{'Anno__c'};
            ci1.multiplebar = true;
            ci1.isStacked = false;
            ci1.title = new List<String>{''};

            response.data.add(ci1);
            
        } catch(AuraHandledException exc){
            response.msg = 'Grafico contenente troppi record';
            response.success = false;
        } catch (Exception e){
            response.msg = e.getMessage() + ' -- ' + e.getStackTraceString() + ' -- ' + e.getCause();
            response.success = false;
        }
    
        return response;
    }

    @AuraEnabled(cacheable=true)
    public static List<WGC_Base_Clienti__c> getDataBaseclientiTable(){
        return [SELECT Id, Base_clienti__c, Anno__c, Mese__c, FlagOperativo__c FROM WGC_Base_Clienti__c WHERE Anno__c =: String.valueOf(System.Today().year()) AND Base_Clienti__c != null AND Anagrafica__r.WGC_Specialista_Factoring__c =: UserInfo.getUserId() AND WGC_Factoring_Attivo__c = true ORDER BY Mese__c, Anno__c];
    }

    /* CHART METHOD - END */

    /* UTILITY CLASS - START */

    public class ChartMetadata{
        @AuraEnabled public String codice;
        @AuraEnabled public String name;
        @AuraEnabled public String titolo;
        @AuraEnabled public Map<String, List<String>> btnLabel;
        @AuraEnabled public List<String> btnActions;
        @AuraEnabled public String informazioniGrafici;

        public ChartMetadata(){
            this.codice = '';
            this.name = '';
            this.btnLabel = new Map<string, List<String>>();
            this.btnActions = new List<String>();
            this.informazioniGrafici = '';
        }
    }

    public class ChartInfo{
        @AuraEnabled public Object data;
        @AuraEnabled public List<String> groupedBy;
        @AuraEnabled public Boolean isStacked;
        @AuraEnabled public List<String> title;
        @AuraEnabled public String subtitle;
        @AuraEnabled public String[] backgroundColor;
        @AuraEnabled public String[] borderColor;
        @AuraEnabled public Boolean multiplebar;
        // @AuraEnabled public String centerText;
    }

    /* UTILITY CLASS - END */
}