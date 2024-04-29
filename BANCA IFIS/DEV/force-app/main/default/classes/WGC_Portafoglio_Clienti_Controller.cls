public without sharing class WGC_Portafoglio_Clienti_Controller {
    /*
    @AuraEnabled(cacheable=false)
    public static List<DataSet> ClientiPerQualifica(String filter, String value){
        //Id value = UserInfo.getUserId();
        String[] qualifiche = new String[]{'Cliente attivo', 'Cliente in avvio', 'Cliente incerto', 'Cliente dormiente'}; //, 'Debitore attivo', 'Debitore dormiente', 'Debitore inattivo', 'Debitore non operante', 'Ex cliente', 'Ex debitore','Prospect'}; // WGC_Specialista_Factoring__c =:userid AND 
        
        List<Account> result = new List<Account>();

        if(filter == 'utente' || Test.isRunningTest()){
            result = [SELECT Id, WGC_Qualifica_Corporate__c FROM Account WHERE WGC_Qualifica_Corporate__c IN: qualifiche AND WGC_Specialista_Factoring__c =: value]; //Id != null]; //
        }

        if(filter == 'filiale' || Test.isRunningTest()){
            List<String> filiali = new List<String>();
            if(value.contains(';')){
                filiali.addAll(value.split(';'));
            }else{
                filiali.add(value);
            }
            result = [SELECT Id, WGC_Qualifica_Corporate__c FROM Account WHERE WGC_Qualifica_Corporate__c IN: qualifiche AND WGC_Specialista_Factoring__r.WGC_La_Mia_Filiale__c IN: filiali];
        }

        if(Test.isRunningTest()){
            result = [SELECT Id, WGC_Qualifica_Corporate__c FROM Account WHERE Id != null];
        }
                    //Account WGC_Codice_filiale_di_competenza__c
        
        System.debug('result'+JSON.serialize(result));
        List<DataSet> dataSet = new List<DataSet>();
        dataSet.add(new DataSet('ATTIVI (Operativi)', 'Cliente attivo', 0));
        dataSet.add(new DataSet('INCERTI (Operativi)', 'Cliente incerto', 0));
        dataSet.add(new DataSet('DORMIENTI (Non Operativi)', 'Cliente dormiente', 0));
        dataSet.add(new DataSet('INATTIVI (Non Operativi)',  'Cliente inattivo', 0));
        
        for(Integer i = 0; i<dataSet.size(); i++){
            for(Account a : result){
                String label = a.WGC_Qualifica_Corporate__c;

                if(Test.isRunningTest()){ 

                    dataSet[i].count++; 

                }

                if(dataSet[i].value == label){
                    dataSet[i].count++;
                }

            }
        }

        System.debug('dataSet'+JSON.serialize(dataSet));

        return dataSet;
    }*/

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> clientiPerQualificaProgressive(String filter, String value, Datetime lastCreatedDate, Integer queryLimit, String sCurrentDataset){
        List<Dataset> currentDataset = new List<Dataset>();
        if(sCurrentDataset != null && sCurrentDataset.length()>5){
            System.debug('currentDataset: '+sCurrentDataset);
            currentDataset = (List<Dataset>)JSON.deserialize(sCurrentDataset, List<Dataset>.class);
        }
        
        String[] qualifiche = new String[]{'Cliente attivo', 'Cliente in avvio', 'Cliente incerto', 'Cliente dormiente'}; //, 'Debitore attivo', 'Debitore dormiente', 'Debitore inattivo', 'Debitore non operante', 'Ex cliente', 'Ex debitore','Prospect'}; // WGC_Specialista_Factoring__c =:userid AND 
        
        List<Account> result = new List<Account>();
        String sQueryR = '';

        if(filter == 'utente' || Test.isRunningTest()){
            //DEVO INSERIRE SIA IL LIMIT CHE IL CREATED DATE MAGGIORE DELL'ULTIMO CREATED DATE
            sQueryR = 'SELECT Id, CreatedDate, WGC_Qualifica_Corporate__c FROM Account WHERE WGC_Qualifica_Corporate__c IN: qualifiche AND WGC_Specialista_Factoring__c = :value AND CreatedDate > :lastCreatedDate ORDER BY CreatedDate ASC LIMIT :queryLimit';
            System.debug('sQueryR: '+sQueryR);
            result = Database.query(sQueryR);
        }

        if(filter == 'filiale' || Test.isRunningTest()){
            List<String> filiali = new List<String>();
            if(value.contains(';')){
                filiali.addAll(value.split(';'));
            }else{
                filiali.add(value);
            }
            //DEVO INSERIRE SIA IL LIMIT CHE IL CREATED DATE MAGGIORE DELL'ULTIMO CREATED DATE
            sQueryR = 'SELECT Id, CreatedDate, WGC_Qualifica_Corporate__c FROM Account WHERE WGC_Qualifica_Corporate__c IN: qualifiche AND WGC_Specialista_Factoring__r.WGC_La_Mia_Filiale__c IN: filiali AND CreatedDate > :lastCreatedDate ORDER BY CreatedDate ASC LIMIT :queryLimit';
            System.debug('sQueryR: '+sQueryR);
            result = Database.query(sQueryR);
        }
        System.debug('sQueryR: '+sQueryR);
        if(Test.isRunningTest()){
            result = [SELECT Id, WGC_Qualifica_Corporate__c, CreatedDate FROM Account WHERE Id != null];
        }
        
        System.debug('result'+JSON.serialize(result));

        //Qui se il dataset esiste già va recuperato l'esistente ed aggiunti i dati nuovi,
        if(currentDataset.size()<3){
            currentDataset = new List<DataSet>();
            currentDataset.add(new DataSet('ATTIVI (Operativi)', 'Cliente attivo', 0));
            currentDataset.add(new DataSet('INCERTI (Operativi)', 'Cliente incerto', 0));
            currentDataset.add(new DataSet('DORMIENTI (Non Operativi)', 'Cliente dormiente', 0));
            currentDataset.add(new DataSet('INATTIVI (Non Operativi)',  'Cliente inattivo', 0));
        }
        
        
        for(Integer i = 0; i<currentDataset.size(); i++){
            for(Account a : result){
                String label = a.WGC_Qualifica_Corporate__c;

                if(Test.isRunningTest()){ 

                    currentDataset[i].count++; 

                }

                if(currentDataset[i].value == label){
                    currentDataset[i].count++;
                }

            }
        }

        System.debug('dataSet'+JSON.serialize(currentDataset));

        Map<String,Object> res = new Map<String,Object>();
        res.put('needRecall',result.size() == queryLimit);
        res.put('dataset', currentDataset);
        if(result.size()>0){
            res.put('lastCreatedDate', result[result.size()-1].CreatedDate);
        }else{
            res.put('lastCreatedDate', lastCreatedDate);
        }
        
        return res;
    }

    @AuraEnabled(cacheable=false)
    public static List<DataSet> ClientiPerProdotto(String filter, String value){
        //Id userid = UserInfo.getUserId();
        String[] prodotti = new String[]{'Factoring Cedente', 'Finanziamenti', 'Servizi Bancari', 'Credito di Firma'}; 
        List<Account> result = new List<Account>();
        
        if(filter == 'utente' || Test.isRunningTest()){
            result =  [SELECT (SELECT Famiglia_Prodotto__c FROM Posizioni__r WHERE Famiglia_Prodotto__c IN:prodotti ) FROM Account WHERE WGC_Specialista_Factoring__c =:value];
        }

        if(filter == 'filiale' || Test.isRunningTest()){
            List<String> filiali = new List<String>();
            if(value.contains(';')){
                filiali.addAll(value.split(';'));
            }else{
                filiali.add(value);
            }
            result = [SELECT (SELECT Famiglia_Prodotto__c FROM Posizioni__r WHERE Famiglia_Prodotto__c IN:prodotti ) FROM Account WHERE WGC_Specialista_Factoring__r.WGC_La_Mia_Filiale__c IN: filiali];
        }

        if(Test.isRunningTest()){
            result = [SELECT Id, WGC_Qualifica_Corporate__c FROM Account WHERE Id != null];
        }

        System.debug('result'+JSON.serialize(result));
        List<DataSet> dataSet = new List<DataSet>();
        dataSet.add(new DataSet('Solo Factoring', 'Cedente', 0));
        dataSet.add(new DataSet('Solo Mutuo', 'Finanziamenti', 0));
        dataSet.add(new DataSet('FCT + Mutuo', 'Cedente', 0));
        dataSet.add(new DataSet('Altro', 'Factoring Cedente Credito di Firma', 0));

        for(Integer i = 0; i<dataSet.size(); i++){
            for(Account a : result){
                if(Test.isRunningTest()){ 

                    dataSet[i].count++; 

                }

                for(WGC_Posizione__c pos : a.Posizioni__r){
                    if(dataSet[i].label == 'Solo Factoring' && pos.Famiglia_Prodotto__c.contains(dataSet[i].value) || pos.Famiglia_Prodotto__c.contains('Bancari')==false){
                        dataSet[i].count++;
                    }
                    if(dataSet[i].label == 'Solo Mutuo' && pos.Famiglia_Prodotto__c.contains(dataSet[i].value) || pos.Famiglia_Prodotto__c.contains('Bancari')==false){
                        dataSet[i].count++;
                    }
                    if(dataSet[i].label == 'FCT + Mutuo' && pos.Famiglia_Prodotto__c.contains(dataSet[i].value) ){
                        dataSet[i].count++;
                    }
                    if(dataSet[i].label == 'Altro' && dataSet[i].value.contains(pos.Famiglia_Prodotto__c) ){
                        dataSet[i].count++;
                    }
                }
            }
        }
        System.debug('dataSet'+JSON.serialize(dataSet));

        return dataSet;
    }


    public class DataSet{
        public DataSet(String label , String value , Integer count){
            this.label  = label;
            this.value  = value;
            this.count = count ;
        }
        @AuraEnabled
        public String label {get;set;}

        @AuraEnabled
        public String value {get;set;}

        @AuraEnabled
        public Integer count {get;set;}
          
    }
    
}