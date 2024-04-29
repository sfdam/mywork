public class WGC_LegalEntity_Utility {

    @AuraEnabled
    public static List<Account> getLinkLegalEntity(String ndg, String codiceIstituto){
        
        //Record contente il link tra le due legal entity
        List<WGC_Link_Legal_Entity__c> linkLegalEntity889 = new List<WGC_Link_Legal_Entity__c>();
        List<WGC_Link_Legal_Entity__c> linkLegalEntity881 = new List<WGC_Link_Legal_Entity__c>();

        //Lista di anagrafiche corrispondenti trovate
        List<Account> Accounts = new List<Account>();

        if(codiceIstituto != '881'){
            linkLegalEntity889 = [SELECT Id, Name, NDG__c, NDG_Collegato__c, Anagrafica__c, Anagrafica_collegata__c, Cod_ist__c, Cod_ist_collegato__c, KEY_ETL__c
            FROM WGC_Link_Legal_Entity__c 
            WHERE NDG_collegato__c =: ndg AND Cod_ist_collegato__c =: codiceIstituto];
            
            if(!linkLegalEntity889.isEmpty()){
                Accounts = getAllAccount(linkLegalEntity889.get(0).NDG__c, linkLegalEntity889.get(0).Cod_ist__c);
                return Accounts;
            }
            else{
                //Eccezioni
                return null;
            }
        }
        else{
            Accounts = getAllAccount(ndg, codiceIstituto);
            return Accounts;
        }
        /*
        else if(codiceIstituto == '881'){
            Accounts = getAllAccount(ndg, codiceIstituto);
            return Accounts;
        }
        */
    }
    
    @TestVisible
    private static List<Account> getAllAccount(String ndg, String codiceIstituto){
        List<WGC_Link_Legal_Entity__c> listaLink = [SELECT Id, NDG__c, Cod_ist__c, NDG_Collegato__c, Cod_ist_collegato__c, Anagrafica__c, Anagrafica_collegata__c FROM WGC_Link_Legal_Entity__c WHERE NDG__c =: ndg AND Cod_ist__c =: codiceIstituto];
        System.debug('@@@ link legal entity in metodo privato ' + JSON.serialize(listaLink));

        //Set che contiene la lista di id da cercare nelle anagrafiche
        Set<Id> setAccId = new Set<Id>();

        for(WGC_Link_Legal_Entity__c item : listaLink){
            setAccId.add(item.Anagrafica__c);
            setAccId.add(item.Anagrafica_collegata__c);
        }
        System.debug('@@@ setAccId ' + setAccId);
        //trovo l'anagrafica corrispondente in base all'ndg trovato nella link legal entity
        List<Account> listaAccount = [SELECT 
                Id, Name, NDGGruppo__c, CodiceIstituto3N__c,
                //Campi Extra utilizzati da WGC_TeamIFIS
                WGC_Specialista_Crediti_Erariali__c,  
                WGC_Specialista_Factoring__c, WGC_Factoring_Attivo__c, 
                WGC_Specialista_IFIS_International__c,
                WGC_Specialista_Filo_Diretto__c, WGC_Filo_Diretto_Attivo__c,
                WGC_Specialista_Finanza_Strutturata__c,
                WGC_Specialista_IFIS_Finance__c,
                WGC_Specialista_Leasing__c, WGC_Specialista_Leasing_TR__c,
                WGC_Gestore_Cliente__c, WGC_Gestore_Debitore__c, WGC_Specialista_Pharma__c,
                Presentatore__c
                //
                FROM Account 
                WHERE Id IN: setAccId];

        System.debug('@@@ lista di account collegati trovati ' + JSON.serialize(listaAccount));

        if(!listaAccount.isEmpty()){
            return listaAccount;
        }
        else{
            return null;
        }
        
    }
}