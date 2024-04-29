public with sharing class ClonaQuote {
    @AuraEnabled
    public static Map<String, String> ottieniDati(String recordId){
        try {
            List<SBQQ__Quote__c> q = [SELECT Id, Name, Numero_Identificativo__c, SBQQ__Type__c,Numero_amend__c, SBQQ__Status__c, SBQQ__Account__c, SBQQ__Account__r.Name, SBQQ__Account__r.BillingCountry, SBQQ__PriceBook__c, SBQQ__PricebookId__c 
                                      FROM SBQQ__Quote__c 
                                      WHERE Id = :recordId 
                                      LIMIT 1];
            Map<String, String> data = new Map<String, String>();
            SBQQ__LookupData__c lkData = [SELECT Price_Book__c, Price_Book__r.Type__c 
                                            FROM SBQQ__LookupData__c 
                                            WHERE Active__c = true AND Default__c = true 
                                            AND SVG_Country__c = :q[0].SBQQ__Account__r.BillingCountry 
                                            AND Lookup_Data_Type__c = 'Price Book Assignment' 
                                            LIMIT 1];
            String role = [SELECT Name FROM UserRole WHERE Id = :UserInfo.getUserRoleId()]?.Name;
            String disable = 'false';
            if(String.isNotBlank(role) && (role?.containsignoreCase('Territory Manager') || role?.containsignoreCase('PM Locale'))){
                disable = 'true';
            }
            data.put('Nome Quote', q[0].Name);
            data.put('Status Quote', q[0].SBQQ__Status__c);
            data.put('Type',q[0].SBQQ__Type__c);
            data.put('Account', (String)q[0].SBQQ__Account__c);
            data.put('Pricebook', q[0].SBQQ__PriceBook__c);
            data.put('Disable', disable);
            data.put('defaultAccount', JSON.serialize(new Account(Id=(String)q[0].SBQQ__Account__c, Name=(String)q[0].SBQQ__Account__r.Name)));
            if(String.isNotBlank(lkData?.Price_Book__c)){
                data.put('DefaultPricebook', JSON.serialize([SELECT Id, Name FROM Pricebook2 WHERE Id = :lkData.Price_Book__c LIMIT 1]));
            }
            data.put('country', q[0].SBQQ__Account__r.BillingCountry);
           

            return data;
        } catch (Exception e) {
            System.debug('Errore Ottieni Dati' + e.getMessage() + ' StackTrace ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static SBQQ__Quote__c clonaQuoteAmend(String idQuote, String idOldListino, String idNewListino){
        try{
            Map<String, Schema.SobjectField> mappaFields = new Map<String, Schema.SobjectField>(Schema.getGlobalDescribe().get('SBQQ__Quote__c').getDescribe().fields.getMap());
            String query = 'SELECT ';
            for(String s : mappaFields.keySet()){
                query += mappaFields.get(s) + ',';
            }
            query = query.substring(0,query.length()-1);
            query += ' FROM SBQQ__Quote__c WHERE Id = \'' + idQuote + '\'';

            SBQQ__Quote__c oldQuote = Database.query(query);
            SBQQ__Quote__c newQuote = oldQuote.clone(false, false, false, false);

            if(String.isNotBlank(idNewListino)){
                newQuote.SBQQ__PricebookId__c = idNewListino;
            }
            newQuote.SBQQ__Source__c = oldQuote.Id; 
            newQuote.SBQQ__Status__c = 'Draft';
            newQuote.Numero_amend__c = newQuote.Numero_amend__c + 1;
            newQuote.SBQQ__Type__c = 'Amendment';

            if(newQuote.Numero_amend__c == 1){
                newQuote.Numero_Identificativo__c = oldQuote.name + '_' + String.valueOf(newQuote.Numero_amend__c);
            }else{
                newQuote.Numero_Identificativo__c = newQuote.Numero_Identificativo__c.split('_')[0] + '_' + String.valueOf(newQuote.Numero_amend__c);
            }
            //Inserisco la nuova Quote di tipo Amend
            Database.insert(newQuote);

            mappaFields = new Map<String, Schema.SObjectField>(Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap());
            query = 'SELECT ';
            for(String s : mappaFields.keySet()){
                query += mappaFields.get(s)+ ',';
            }
            query = query.substring(0, query.length() - 1);
            query += ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = \'' + idQuote + '\'';

            List<SBQQ__QuoteLine__c> qli = database.query(query);

            List<SBQQ__QuoteLine__c> cloneQli = new List<SBQQ__QuoteLine__c>();

            for(SBQQ__QuoteLine__c currentQuoteLineItem : qli){
                SBQQ__QuoteLine__c ClonedQuoteLineItem = currentQuoteLineItem.clone(false, false, false, false);
                ClonedQuoteLineItem.SBQQ__Quote__c = newQuote.Id;
                ClonedQuoteLineItem.SBQQ__RequiredBy__c='';
                cloneQli.add(ClonedQuoteLineItem);
            }

            Database.insert(cloneQli);

            return newQuote;
        }catch (Exception e) {
            System.debug('Errore Clona Quote ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static SBQQ__Quote__c clonaQuoteWithRelated(String idQuote, String idOldAccount, String idNewAccount){
        try{
            Map<String, Schema.SobjectField> mappaFields = new Map<String, Schema.SobjectField>(Schema.getGlobalDescribe().get('SBQQ__Quote__c').getDescribe().fields.getMap());
            String query = 'SELECT ';
            for(String s : mappaFields.keySet()){
                query += mappaFields.get(s) + ',';
            }
            query = query.substring(0,query.length()-1);
            query += ' FROM SBQQ__Quote__c WHERE Id = \'' + idQuote + '\'';

            SBQQ__Quote__c oldQuote = Database.query(query);
            SBQQ__Quote__c newQuote = oldQuote.clone(false, false, false, false);

            /*if(String.isNotBlank(idNewListino)){
                newQuote.SBQQ__PricebookId__c = idNewListino;
            }*/
            if(!idOldAccount?.equalsIgnoreCase(idNewAccount)){
                newQuote.SBQQ__Account__c = idNewAccount;
            }
            Pricebook2 oldQuotePB = [SELECT Id, IsActive FROM Pricebook2 WHERE Id = :oldQuote.SBQQ__PricebookId__c LIMIT 1];
            Account newAccount = [SELECT Id, BillingCountry FROM Account WHERE Id = :idNewAccount LIMIT 1];
            SBQQ__LookupData__c lkData = [SELECT Price_Book__c, Price_Book__r.Type__c 
                                            FROM SBQQ__LookupData__c 
                                            WHERE Active__c = true AND Default__c = true 
                                            AND SVG_Country__c = :newAccount.BillingCountry 
                                            AND Lookup_Data_Type__c = 'Price Book Assignment' 
                                            LIMIT 1];

            if(!oldQuotePB.IsActive || (!(String.valueOf(oldQuotePB.Id))?.equalsIgnoreCase(String.valueOf(lkData?.Price_Book__c)) && !idOldAccount?.equalsIgnoreCase(idNewAccount))){
                //Cercare default value con lookup date e settare nuovo listino attivo
                newQuote.SBQQ__PricebookId__c = lkData.Price_Book__c;
            }
            newQuote.SBQQ__Source__c = oldQuote.Id; 
            newQuote.SBQQ__Status__c = 'Draft';
            newQuote.Numero_amend__c = newQuote.Numero_amend__c + 1;

            if(newQuote.Numero_amend__c == 1){
                newQuote.Numero_Identificativo__c = oldQuote.name + '_' + String.valueOf(newQuote.Numero_amend__c);
            }else{
                newQuote.Numero_Identificativo__c = newQuote.Numero_Identificativo__c.split('_')[0] + '_' + String.valueOf(newQuote.Numero_amend__c);
            }
            //Inserisco la nuova Quote di tipo Amend
            Database.insert(newQuote);

            mappaFields = new Map<String, Schema.SObjectField>(Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c').getDescribe().fields.getMap());
            query = 'SELECT ';
            for(String s : mappaFields.keySet()){
                query += mappaFields.get(s)+ ',';
            }
            query = query.substring(0, query.length() - 1);
            query += ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = \'' + idQuote + '\'';

            List<SBQQ__QuoteLine__c> qli = database.query(query);

            List<SBQQ__QuoteLine__c> cloneQli = new List<SBQQ__QuoteLine__c>();

            for(SBQQ__QuoteLine__c currentQuoteLineItem : qli){
                SBQQ__QuoteLine__c ClonedQuoteLineItem = currentQuoteLineItem.clone();
                ClonedQuoteLineItem.SBQQ__Quote__c = newQuote.Id;
                cloneQli.add(ClonedQuoteLineItem);
            }

            Database.insert(cloneQli);

            return newQuote;
        }catch (Exception e) {
            System.debug('Errore Clona Quote ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}