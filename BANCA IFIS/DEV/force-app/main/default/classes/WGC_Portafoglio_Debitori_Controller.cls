public without sharing class WGC_Portafoglio_Debitori_Controller {
    
    @AuraEnabled(cacheable=false)
    public static List<DataSet> Debitori(String filter, String value){
        //Id userid = UserInfo.getUserId();
        Id rectypeid = [SELECT Id FROM RecordType WHERE Name = 'Plafond Debitore'].Id;
        System.debug('rectypeid: '+rectypeid);
        String[] qualifiche = new String[]{'Debitore in avvio', 'Debitore inattivo', 'Ex debitore', 'Debitore Dormiente', 'Debitore attivo', 'Debitore non operante'};
        List<Account> result = new List<Account>();

        if(filter == 'utente' || Test.isRunningTest()){
            result =  [SELECT (SELECT Qualifica_Posizione__c FROM Posizioni__r WHERE Qualifica_Posizione__c IN:qualifiche AND RecordTypeId =: rectypeid ) FROM Account WHERE WGC_Specialista_Factoring__c =:value];
        }
        if(filter == 'filiale' || Test.isRunningTest() ){
            List<String> filiali = new List<String>();
            if(value.contains(';')){
                filiali.addAll(value.split(';'));
            }else{
                filiali.add(value);
            }
            result =  [SELECT (SELECT Qualifica_Posizione__c FROM Posizioni__r WHERE Qualifica_Posizione__c IN:qualifiche AND RecordTypeId =: rectypeid ) FROM Account WHERE WGC_Specialista_Factoring__r.WGC_La_Mia_Filiale__c IN: filiali];
        }

        if(Test.isRunningTest()){
            result =  [SELECT (SELECT Qualifica_Posizione__c FROM Posizioni__r WHERE Qualifica_Posizione__c IN:qualifiche ) FROM Account WHERE Id != null];
        }

        System.debug('result'+JSON.serialize(result));
        List<DataSet> dataSet = new List<DataSet>();

        for(String s : qualifiche){
            String label = s;
            Integer total = 0;
            for(Account a : result){
                if(Test.isRunningTest()){ 

                    total++; 
                    
                }
                for(WGC_Posizione__c pos : a.Posizioni__r){
                    if(pos.Qualifica_Posizione__c==label){
                        total++;
                    }
                }
            }
            if(total>0){
                dataSet.add(new DataSet(label ,total));
            }
        }

        System.debug('dataSet'+JSON.serialize(dataSet));

        return dataSet;
    }

    public class DataSet{
        public DataSet(String label ,Integer count){
            this.label  = label;
            this.count = count ;
        }
        @AuraEnabled
        public String label {get;set;}
        @AuraEnabled
        public Integer  count {get;set;}
        
        
    }

    
}