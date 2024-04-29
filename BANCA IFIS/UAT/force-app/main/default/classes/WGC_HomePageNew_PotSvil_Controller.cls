public class WGC_HomePageNew_PotSvil_Controller {
    
    @AuraEnabled
    public static WrapperData getData(){
        WrapperData wData = new WrapperData();

        try {
            Date date24mesi = Date.today().addMonths(24);
            Date date12mesi = Date.today().addMonths(12);

            //Lista Account 
            List<Account> accountList = [SELECT Id, Potenzialit_di_sviluppo__c, WGC_Qualifica_Corporate__c, WGC_Data_ultima_attivita_SvilCommFiliali__c, TAG_Controllante__c FROM Account WHERE Potenzialit_di_sviluppo__c = true AND WGC_Qualifica_Corporate__c  IN ('Debitore attivo','Prospect','Ex cliente','Debitore inattivo','Debitore dormiente','Debitore in avvio','Debitore non operante','Ex debitore') AND WGC_Specialista_Factoring__c = :UserInfo.getUserId()];
            System.debug(LoggingLevel.DEBUG,'@@ WGC_HeaderPotenzialitaSviluppoController|getData accountList: '+accountList);

            List<Account> lead24mesiList = new List<Account>();
            List<Account> aziende1324mesiList = new List<Account>();
            List<Account> clientiAltreBUList = new List<Account>();
            List<Account> exClientiList = new List<Account>();
            List<Account> debitoriList = new List<Account>();
            Set<Id> accountIdSet = new Set<Id>();

            for(Account acc : accountList){
                accountIdSet.add(acc.Id);
                if(acc.WGC_Data_ultima_attivita_SvilCommFiliali__c > date24mesi || acc.WGC_Data_ultima_attivita_SvilCommFiliali__c == null){
                    lead24mesiList.add(acc);
                }
                if(acc.WGC_Data_ultima_attivita_SvilCommFiliali__c > date12mesi && acc.WGC_Data_ultima_attivita_SvilCommFiliali__c < date24mesi && acc.WGC_Qualifica_Corporate__c.equals('Prospect')){
                    aziende1324mesiList.add(acc);
                }
                if(acc.WGC_Qualifica_Corporate__c.equals('Prospect')){
                    clientiAltreBUList.add(acc);
                }
                if(acc.WGC_Qualifica_Corporate__c.contains('Debitore') || acc.WGC_Qualifica_Corporate__c.contains('debitore')){
                    debitoriList.add(acc);
                }
                if(acc.WGC_Qualifica_Corporate__c.equals('Ex cliente')){
                    exClientiList.add(acc);
                }
            }
            
            System.debug(LoggingLevel.DEBUG,'@@ WGC_HeaderPotenzialitaSviluppoController|getData lead24Mesi: '+lead24MesiList);                                      
            System.debug(LoggingLevel.DEBUG,'@@ WGC_HeaderPotenzialitaSviluppoController|getData aziende1324Mesi: '+aziende1324mesiList);
            System.debug(LoggingLevel.DEBUG,'@@ WGC_HeaderPotenzialitaSviluppoController|getData ClientiAltreBU: '+clientiAltreBUList);    
            System.debug(LoggingLevel.DEBUG,'@@ WGC_HeaderPotenzialitaSviluppoController|getData ex clienti: '+exClientiList);
            System.debug(LoggingLevel.DEBUG,'@@ WGC_HeaderPotenzialitaSviluppoController|getData debitori: '+debitoriList);  
            
            //Recupero prodotti legati alle anagrafiche
            List<WGC_Linea_Prodotto__c> listaProdottiCedente = [SELECT Id, Name, Anagrafica__c FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN: accountIdSet AND (RecordType.DeveloperName = 'FACTORINGCEDENTE' OR RecordType.DeveloperName = 'FACTORINGFISCALE') AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE')];
            List<WGC_Linea_Prodotto__c> lstProdottiFactoringDeb = [SELECT Id, Name, Anagrafica__c FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN: accountIdSet AND RecordType.DeveloperName = 'FACTORINGDEBITORE' AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE')];
            List<WGC_Linea_Prodotto__c> lstProdottiLeasing = [SELECT Id, Name, Anagrafica__c FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN: accountIdSet AND RecordType.DeveloperName = 'LEASING' AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE')];
            List<WGC_Linea_Prodotto__c> lstProdottiFinanziamento = [SELECT Id, Name, Anagrafica__c FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN: accountIdSet AND RecordType.DeveloperName = 'FINANZIAMENTI' AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE')];
            List<WGC_Linea_Prodotto__c> lstProdottiAltro = [SELECT Id, Name, Anagrafica__c FROM WGC_Linea_Prodotto__c WHERE Anagrafica__c IN: accountIdSet AND (Stato__c = 'Attivo' OR Stato__c = 'ACTIVE') AND (RecordType.DeveloperName = 'GARANZIE' OR  RecordType.DeveloperName = 'CREDITIPROBLEMATICI' OR  RecordType.DeveloperName = 'SERVIZIBANCARI' OR  RecordType.DeveloperName = 'CREDITIDIFIRMA' OR RecordType.DeveloperName = 'NPL' OR RecordType.DeveloperName = 'CREDITIERARIALI' OR RecordType.DeveloperName = 'Anticipo_Fatture' OR RecordType.DeveloperName = 'Portafoglio_Commerciale')];

            Map<String,List<WGC_Linea_Prodotto__c>> prodottiCedenteMap = getMapProdottiCedente(listaProdottiCedente);
            Map<String,List<WGC_Linea_Prodotto__c>> prodottiDebitoreMap = getMapProdottiDebitore(lstProdottiFactoringDeb);
            Map<String,List<WGC_Linea_Prodotto__c>> prodottiLeasingMap = getMapProdottiLeasing(lstProdottiLeasing);
            Map<String,List<WGC_Linea_Prodotto__c>> prodottiFianziamentoMap = getMapProdottiFinanziamento(lstProdottiFinanziamento);
            Map<String,List<WGC_Linea_Prodotto__c>> prodottiAltroMap = getMapProdottiAltro(lstProdottiAltro);

            System.debug(LoggingLevel.DEBUG,'@@ WGC_HeaderPotenzialitaSviluppoController|getData prodotti cedente: '+prodottiCedenteMap); 
            System.debug(LoggingLevel.DEBUG,'@@ WGC_HeaderPotenzialitaSviluppoController|getData prodotti debitore: '+prodottiDebitoreMap); 
            System.debug(LoggingLevel.DEBUG,'@@ WGC_HeaderPotenzialitaSviluppoController|getData prodotti leasing: '+prodottiLeasingMap); 
            System.debug(LoggingLevel.DEBUG,'@@ WGC_HeaderPotenzialitaSviluppoController|getData prodotti finanziamento: '+prodottiFianziamentoMap); 
            System.debug(LoggingLevel.DEBUG,'@@ WGC_HeaderPotenzialitaSviluppoController|getData prodotti altro: '+prodottiAltroMap); 

            //Lead attività > 24 mesi
            wData.numLead = lead24MesiList.size();
            
            for(Account acc : lead24MesiList){
                if(acc.TAG_Controllante__c != null){
                    wData.numLeadCampaign += 1;
                }
            }

            //Aziende attività 13-24 mesi
            for(Account acc : aziende1324mesiList){
                if(prodottiCedenteMap != null && prodottiCedenteMap.get(acc.Id) != null){
                    wData.numAziende1324mesi += 1;
                    if(acc.TAG_Controllante__c != null){
                        wData.numAziende1324mesiCampaign += 1;
                    }
                }
            }

            //Clienti altre BU
            for(Account acc : clientiAltreBUList){
                if(prodottiCedenteMap != null && prodottiDebitoreMap != null && prodottiFianziamentoMap != null && prodottiLeasingMap != null && prodottiAltroMap != null && prodottiCedenteMap.get(acc.Id) == null && (prodottiAltroMap.get(acc.Id) != null || prodottiDebitoreMap.get(acc.Id) != null|| prodottiFianziamentoMap.get(acc.Id) != null || prodottiLeasingMap.get(acc.Id) != null) && acc.WGC_Data_ultima_attivita_SvilCommFiliali__c > date12mesi){
                    wData.numClientiAltreBu += 1;
                    if(acc.TAG_Controllante__c != null){
                        wData.numClientiAltreBuInCampaign += 1;
                    }
                }
            }

            //Ex clienti
            for(Account acc : exClientiList){
                if(prodottiAltroMap != null && prodottiDebitoreMap != null && prodottiFianziamentoMap != null && prodottiLeasingMap != null && prodottiAltroMap.get(acc.Id) == null && prodottiDebitoreMap.get(acc.Id) == null && prodottiFianziamentoMap.get(acc.Id) == null && prodottiLeasingMap.get(acc.Id) == null && acc.WGC_Data_ultima_attivita_SvilCommFiliali__c > date12mesi){
                    wData.numExClienti += 1;
                    if(acc.TAG_Controllante__c != null){
                        wData.numExClientiCampaign += 1;
                    }
                }
            }

            //Debitori
            for(Account acc : debitoriList){
                if(prodottiAltroMap != null && prodottiFianziamentoMap != null && prodottiLeasingMap != null && prodottiAltroMap.get(acc.Id) == null && prodottiFianziamentoMap.get(acc.Id) == null && prodottiLeasingMap.get(acc.Id) == null && acc.WGC_Data_ultima_attivita_SvilCommFiliali__c > date12mesi){
                    wData.numDebitori += 1;
                    if(acc.TAG_Controllante__c != null){
                        wData.numDebitoriCampaign += 1;
                    }
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,'@@ WGC_HeaderPotenzialitaSviluppoController|getData error - exception at line: '+e.getLineNumber()+' message: '+e.getMessage());
        }

        return wData;
    }

    private static Map<String,List<WGC_Linea_Prodotto__c>> getMapProdottiCedente(List<WGC_Linea_Prodotto__c> listaProdottiCedente){
        Map<String,List<WGC_Linea_Prodotto__c>> prodottiCedenteMap = new Map<String,List<WGC_Linea_Prodotto__c>>();
        if(listaProdottiCedente.size() > 0){
            for(WGC_Linea_Prodotto__c prod: listaProdottiCedente){
                if(!prodottiCedenteMap.containsKey(prod.Anagrafica__c)){
                    prodottiCedenteMap.put(prod.Anagrafica__c, new List<WGC_Linea_Prodotto__c>());
                }
                prodottiCedenteMap.get(prod.Anagrafica__c).add(prod);
            }
        }
        return prodottiCedenteMap;
    }

    private static Map<String,List<WGC_Linea_Prodotto__c>> getMapProdottiDebitore(List<WGC_Linea_Prodotto__c> lstProdottiFactoringDeb){
        Map<String,List<WGC_Linea_Prodotto__c>> prodottiDebitoreMap = new Map<String,List<WGC_Linea_Prodotto__c>>();
        if(lstProdottiFactoringDeb.size() > 0){
            for(WGC_Linea_Prodotto__c prod: lstProdottiFactoringDeb){
                if(!prodottiDebitoreMap.containsKey(prod.Anagrafica__c)){
                    prodottiDebitoreMap.put(prod.Anagrafica__c, new List<WGC_Linea_Prodotto__c>());
                }
                prodottiDebitoreMap.get(prod.Anagrafica__c).add(prod);
            }
        }
        return prodottiDebitoreMap;
    }

    private static Map<String,List<WGC_Linea_Prodotto__c>> getMapProdottiLeasing(List<WGC_Linea_Prodotto__c> lstProdottiLeasing){
        Map<String,List<WGC_Linea_Prodotto__c>> prodottiLeasingMap = new Map<String,List<WGC_Linea_Prodotto__c>>();
        if(lstProdottiLeasing.size() > 0){
            for(WGC_Linea_Prodotto__c prod: lstProdottiLeasing){
                if(!prodottiLeasingMap.containsKey(prod.Anagrafica__c)){
                    prodottiLeasingMap.put(prod.Anagrafica__c, new List<WGC_Linea_Prodotto__c>());
                }
                prodottiLeasingMap.get(prod.Anagrafica__c).add(prod);
            }
        }
        return prodottiLeasingMap;
    }

    private static Map<String,List<WGC_Linea_Prodotto__c>> getMapProdottiFinanziamento(List<WGC_Linea_Prodotto__c> lstProdottiFinanziamento){
        Map<String,List<WGC_Linea_Prodotto__c>> prodottiFianziamentoMap = new Map<String,List<WGC_Linea_Prodotto__c>>();
        if(lstProdottiFinanziamento.size() > 0){
            for(WGC_Linea_Prodotto__c prod: lstProdottiFinanziamento){
                if(!prodottiFianziamentoMap.containsKey(prod.Anagrafica__c)){
                    prodottiFianziamentoMap.put(prod.Anagrafica__c, new List<WGC_Linea_Prodotto__c>());
                }
                prodottiFianziamentoMap.get(prod.Anagrafica__c).add(prod);
            }
        }
        return prodottiFianziamentoMap;
    }

    private static Map<String,List<WGC_Linea_Prodotto__c>> getMapProdottiAltro(List<WGC_Linea_Prodotto__c> lstProdottiAltro){
        Map<String,List<WGC_Linea_Prodotto__c>> prodottiAltroMap = new Map<String,List<WGC_Linea_Prodotto__c>>();
        if(lstProdottiAltro.size() > 0){
            for(WGC_Linea_Prodotto__c prod: lstProdottiAltro){
                if(!prodottiAltroMap.containsKey(prod.Anagrafica__c)){
                    prodottiAltroMap.put(prod.Anagrafica__c, new List<WGC_Linea_Prodotto__c>());
                }
                prodottiAltroMap.get(prod.Anagrafica__c).add(prod);
            }
        }
        return prodottiAltroMap;
    }
    public class WrapperData {
        @AuraEnabled
        public Integer numLead = 0;
        @AuraEnabled
        public Integer numLeadCampaign = 0;
        @AuraEnabled
        public Integer numAziende1324mesi = 0;
        @AuraEnabled
        public Integer numAziende1324mesiCampaign = 0;
        @AuraEnabled
        public Integer numExClienti = 0;
        @AuraEnabled
        public Integer numExClientiCampaign = 0;
        @AuraEnabled
        public Integer numDebitori = 0;
        @AuraEnabled
        public Integer numDebitoriCampaign = 0;
        @AuraEnabled
        public Integer numClientiAltreBu = 0;
        @AuraEnabled
        public Integer numClientiAltreBuInCampaign = 0;
    }
}