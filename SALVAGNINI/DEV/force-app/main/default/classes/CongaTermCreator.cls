public without sharing class CongaTermCreator {
    
    public static boolean hasAlreadyRan = false;

    @future
    public static void createConditions (string quoteString, Set<Id> QuoteIds){
        
        //List<SBQQ__QuoteLine__c> quoteLines = getAllQuoteLines(QuoteIds);
        //List<SBQQ__Quote__c> quoteList = (List<SBQQ__Quote__c>)JSON.deserialize(quoteListString, List<SBQQ__Quote__c>.class);
        SBQQ__Quote__c JSONquote = (SBQQ__Quote__c)JSON.deserialize(quoteString, SBQQ__Quote__c.class);
        List<String> quoteFields = getAllFieldApiForSObject('SBQQ__Quote__c');
        String query = 'SELECT ' + String.join((Iterable<String>)quoteFields, ',') + ' FROM SBQQ__Quote__c WHERE Id = \''+JSONquote.Id+'\' LIMIT 1';
        SBQQ__Quote__c quote = Database.query(query);
        //SBQQ__Quote__c quote = [SELECT FIELDS(ALL) FROM SBQQ__Quote__c WHERE Id = :JSON.Id LIMIT 1];
        List<Sales_Conditions__c> previousConditions = [SELECT Id FROM Sales_Conditions__c WHERE Quote__c = :quote.Id];
        database.delete(previousConditions);
        //List<SBQQ__QuoteTerm__c> allTerms = [SELECT Id , SBQQ__Body__c, SBQQ__ConditionsMet__c,Body_CHN__c,Body_DEU__c,Body_ESP__c,Body_FRA__c,Body_ITA__c,Body_POL__c,Body_PT__c,Body_RUS__c,(SELECT id,Tested_Object__c,SBQQ__Operator__c,SBQQ__TestedField__c,SBQQ__Value__c FROM SBQQ__UseConditions__r) FROM SBQQ__QuoteTerm__c WHERE SBQQ__Active__c = true AND SBQQ__Status__c = 'Approved' ORDER BY SBQQ__PrintOrder__c asc]; //AND Id IN (SELECT SBQQ__QuoteTerm__c FROM SBQQ__TermCondition__c)
        List<Sales_Conditions__c> ConditionsToInsert = new List<Sales_Conditions__c>();
            integer conditionNumber = 1;
            for(SBQQ__QuoteTerm__c singleTerm : [SELECT Id , SBQQ__Body__c, SBQQ__ConditionsMet__c,Body_CHN__c,Body_DEU__c,Body_ESP__c,Body_FRA__c,Body_ITA__c,Body_POL__c,Body_PT__c,Body_RUS__c,(SELECT id,Tested_Object__c,SBQQ__Operator__c,SBQQ__TestedField__c,SBQQ__Value__c FROM SBQQ__UseConditions__r) FROM SBQQ__QuoteTerm__c WHERE SBQQ__Active__c = true AND SBQQ__Status__c = 'Approved' ORDER BY SBQQ__PrintOrder__c asc]){
                integer conditionsMet = 0;
                integer conditionTotal = singleTerm.SBQQ__UseConditions__r.size();
                for(SBQQ__TermCondition__c singleCondition : singleTerm.SBQQ__UseConditions__r ){
                    if(singleCondition.Tested_Object__c == 'SBQQ__Quote__c'){
                        system.debug('singleCondition ENTRATA : '+singleCondition);
                        system.debug('Campo su term : '+singleCondition.SBQQ__TestedField__c);
                        //string singleCondition.SBQQ__TestedField__c = getFieldAPIName('SBQQ__Quote__c',singleCondition.SBQQ__TestedField__c);
                        system.debug('Campo su term : '+singleCondition.SBQQ__TestedField__c);
                        //system.debug('Campo da controllare: ' + singleCondition.SBQQ__TestedField__c + ', Valore campo: ' + quote.get(singleCondition.SBQQ__TestedField__c) + ', Condizione: ' + singleCondition.SBQQ__Operator__c+ ', Valore regola: '+ singleCondition.SBQQ__Value__c);
                        
                        switch on singleCondition.SBQQ__Operator__c {
                            when 'equals' {
                                if(singleCondition.SBQQ__Value__c == string.valueof(quote.get(singleCondition.SBQQ__TestedField__c))){
                                    conditionsMet ++;
                                    system.debug('regola raggiunta');
                                }
                                else{
                                    system.debug('regola '+singleCondition.Id+' NON raggiunta valore condition:: '+singleCondition.SBQQ__Value__c+' Operatore:: '+singleCondition.SBQQ__Operator__c+' Dato su quote:: '+string.valueof(quote.get(singleCondition.SBQQ__TestedField__c)));
                                }
                            }
                            when 'not equals' {
                                if(singleCondition.SBQQ__Value__c != string.valueof(quote.get(singleCondition.SBQQ__TestedField__c))){
                                    conditionsMet ++;
                                    system.debug('regola raggiunta');
                                }
                                else{
                                    system.debug('regola '+singleCondition.Id+' NON raggiunta valore condition:: '+singleCondition.SBQQ__Value__c+' Operatore:: '+singleCondition.SBQQ__Operator__c+' Dato su quote:: '+string.valueof(quote.get(singleCondition.SBQQ__TestedField__c)));
                                }
                            }
                            when 'less than' {
                                if(Double.valueof(singleCondition.SBQQ__Value__c) > (double)quote.get(singleCondition.SBQQ__TestedField__c)){
                                    conditionsMet ++;
                                    system.debug('regola raggiunta');
                                }
                                else{
                                    system.debug('regola '+singleCondition.Id+' NON raggiunta valore condition:: '+singleCondition.SBQQ__Value__c+' Operatore:: '+singleCondition.SBQQ__Operator__c+' Dato su quote:: '+string.valueof(quote.get(singleCondition.SBQQ__TestedField__c)));
                                }
                            }
                            when 'less or equals' {
                                if(Double.valueof(singleCondition.SBQQ__Value__c) >= (double)quote.get(singleCondition.SBQQ__TestedField__c)){
                                    conditionsMet ++;
                                    system.debug('regola raggiunta');
                                }
                                else{
                                    system.debug('regola '+singleCondition.Id+' NON raggiunta valore condition:: '+singleCondition.SBQQ__Value__c+' Operatore:: '+singleCondition.SBQQ__Operator__c+' Dato su quote:: '+string.valueof(quote.get(singleCondition.SBQQ__TestedField__c)));
                                }
                            }
                            when 'greater than' {
                                if(Double.valueof(singleCondition.SBQQ__Value__c) < (double)quote.get(singleCondition.SBQQ__TestedField__c)){
                                    conditionsMet ++;
                                    system.debug('regola raggiunta');
                                }
                                else{
                                    system.debug('regola '+singleCondition.Id+' NON raggiunta valore condition:: '+singleCondition.SBQQ__Value__c+' Operatore:: '+singleCondition.SBQQ__Operator__c+' Dato su quote:: '+string.valueof(quote.get(singleCondition.SBQQ__TestedField__c)));
                                }
                            }
                            when 'greater or equals' {
                                if(Double.valueof(singleCondition.SBQQ__Value__c) <= (double)quote.get(singleCondition.SBQQ__TestedField__c)){
                                    conditionsMet ++;
                                    system.debug('regola raggiunta');
                                }
                                else{
                                    system.debug('regola '+singleCondition.Id+' NON raggiunta valore condition:: '+singleCondition.SBQQ__Value__c+' Operatore:: '+singleCondition.SBQQ__Operator__c+' Dato su quote:: '+string.valueof(quote.get(singleCondition.SBQQ__TestedField__c)));
                                }
                            }
                            when 'starts with' {
                                string toCheck =(string)quote.get(singleCondition.SBQQ__TestedField__c);
                                if(toCheck != null && toCheck.startsWith(singleCondition.SBQQ__Value__c)){
                                    conditionsMet ++;
                                    system.debug('regola raggiunta');
                                }
                                else{
                                    system.debug('regola '+singleCondition.Id+' NON raggiunta valore condition:: '+singleCondition.SBQQ__Value__c+' Operatore:: '+singleCondition.SBQQ__Operator__c+' Dato su quote:: '+string.valueof(quote.get(singleCondition.SBQQ__TestedField__c)));
                                }
                            }
                            when 'ends with' {
                                string toCheck =(string)quote.get(singleCondition.SBQQ__TestedField__c);
                                if(toCheck != null && toCheck.endsWith(singleCondition.SBQQ__Value__c)){
                                    conditionsMet ++;
                                    system.debug('regola raggiunta');
                                }
                                else{
                                    system.debug('regola '+singleCondition.Id+' NON raggiunta valore condition:: '+singleCondition.SBQQ__Value__c+' Operatore:: '+singleCondition.SBQQ__Operator__c+' Dato su quote:: '+string.valueof(quote.get(singleCondition.SBQQ__TestedField__c)));
                                }
                            }
                            when 'contains' {
                                string toCheck =(string)quote.get(singleCondition.SBQQ__TestedField__c);
                                if(toCheck != null && toCheck.contains(singleCondition.SBQQ__Value__c)){
                                    conditionsMet ++;
                                    system.debug('regola raggiunta');
                                }
                                else{
                                    system.debug('regola '+singleCondition.Id+' NON raggiunta valore condition:: '+singleCondition.SBQQ__Value__c+' Operatore:: '+singleCondition.SBQQ__Operator__c+' Dato su quote:: '+string.valueof(quote.get(singleCondition.SBQQ__TestedField__c)));
                                }
                            }
                            when else {
                                
                            }
                        }
                        
                    }
                    /*else if(singleCondition.Tested_Object__c == 'SBQQ__QuoteLine__c'){
                        boolean conditionMet = false;
                        for(SBQQ__QuoteLine__c singleLine : quoteLines){
                            string singleCondition.SBQQ__TestedField__c = getFieldAPIName('SBQQ__QuoteLine__c',singleCondition.SBQQ__TestedField__c);
                            system.debug('Campo su term : '+singleCondition.SBQQ__TestedField__c);
                            system.debug('Campo da controllare: ' + singleCondition.SBQQ__TestedField__c + ', Valore campo: ' + quote.get(singleCondition.SBQQ__TestedField__c) + ', Condizione: ' + singleCondition.SBQQ__Operator__c+ ', Valore regola: '+ singleCondition.SBQQ__Value__c);
                            if(singleCondition.SBQQ__TestedField__c != null && singleCondition.SBQQ__TestedField__c != ''){
                                switch on singleCondition.SBQQ__Operator__c {
                                    when 'equals' {
                                        if(singleCondition.SBQQ__Value__c == (string)quote.get(singleCondition.SBQQ__TestedField__c)){
                                            conditionMet = true;
                                            system.debug('regola raggiunta');
                                        }
                                    }
                                    when 'not equals' {
                                        if(singleCondition.SBQQ__Value__c != (string)quote.get(singleCondition.SBQQ__TestedField__c)){
                                            conditionMet = true;
                                            system.debug('regola raggiunta');
                                        }
                                    }
                                    when 'less than' {
                                        if(Double.valueof(singleCondition.SBQQ__Value__c) > (double)quote.get(singleCondition.SBQQ__TestedField__c)){
                                            conditionMet = true;
                                            system.debug('regola raggiunta');
                                        }
                                    }
                                    when 'less or equals' {
                                        if(Double.valueof(singleCondition.SBQQ__Value__c) >= (double)quote.get(singleCondition.SBQQ__TestedField__c)){
                                            conditionMet = true;
                                            system.debug('regola raggiunta');
                                        }
                                    }
                                    when 'greater than' {
                                        if(Double.valueof(singleCondition.SBQQ__Value__c) < (double)quote.get(singleCondition.SBQQ__TestedField__c)){
                                            conditionMet = true;
                                            system.debug('regola raggiunta');
                                        }
                                    }
                                    when 'greater or equals' {
                                        if(Double.valueof(singleCondition.SBQQ__Value__c) <= (double)quote.get(singleCondition.SBQQ__TestedField__c)){
                                            conditionMet = true;
                                            system.debug('regola raggiunta');
                                        }
                                    }
                                    when 'starts with' {
                                        string toCheck =(string)quote.get(singleCondition.SBQQ__TestedField__c);
                                        if(toCheck.startsWith(singleCondition.SBQQ__Value__c)){
                                            conditionMet = true;
                                            system.debug('regola raggiunta');
                                        }
                                    }
                                    when 'ends with' {
                                        string toCheck =(string)quote.get(singleCondition.SBQQ__TestedField__c);
                                        if(toCheck.endsWith(singleCondition.SBQQ__Value__c)){
                                            conditionMet = true;
                                            system.debug('regola raggiunta');
                                        }
                                    }
                                    when 'contains' {
                                        string toCheck =(string)quote.get(singleCondition.SBQQ__TestedField__c);
                                        if(toCheck.contains(singleCondition.SBQQ__Value__c)){
                                            conditionMet = true;
                                            system.debug('regola raggiunta');
                                        }
                                    }
                                    when else {
                                        
                                    }
                                }
                            }
                        }
                        if(conditionMet){
                            conditionsMet ++;
                            system.debug('regola raggiunta LIST');
                        }
                    }*/
                }
                system.debug('ConditionsMetRichiesto: '+singleTerm.SBQQ__ConditionsMet__c+ 'Condizioni raggiunte: ' + conditionsMet + 'Condizioni necessarie in caso di ALL: '+conditionTotal);
                if((singleTerm.SBQQ__ConditionsMet__c == 'Any' && conditionsMet >= 1) || (singleTerm.SBQQ__ConditionsMet__c == 'All' && conditionsMet == conditionTotal)){
                    Sales_Conditions__c newCondition = new Sales_Conditions__c();
                    newCondition.name = 'Condition ' + String.valueof(conditionNumber);
                    conditionNumber++;
                    newCondition.Quote__c = quote.Id;
                    newCondition.Quote_Term__c = singleTerm.Id;
                    string primaryLanguageBody = '';
                    switch on quote.SBQQ__QuoteLanguage__c {
                        when  'Italian'{
                            primaryLanguageBody = singleTerm.Body_ITA__c;
                        }
                        when  'English'{
                            primaryLanguageBody = singleTerm.SBQQ__Body__c;
                        }
                        when  'Spanish'{
                            primaryLanguageBody = singleTerm.Body_ESP__c;
                        }
                        when  'German'{
                            primaryLanguageBody = singleTerm.Body_DEU__c;
                        }
                        when  'French'{
                            primaryLanguageBody = singleTerm.Body_FRA__c;
                        }
                        when  'Russian'{
                            primaryLanguageBody = singleTerm.Body_RUS__c;
                        }
                        when  'Chinese'{
                            primaryLanguageBody = singleTerm.Body_CHN__c;
                        }
                        when  'Polish'{
                            primaryLanguageBody = singleTerm.Body_POL__c;
                        }
                        when  'Portuguese'{
                            primaryLanguageBody = singleTerm.Body_PT__c;
                        }
                        when else {
                            
                        }
                    }
                    string secondLanguageBody = '';
                    switch on quote.Quote_Secondary_Language__c {
                        when  'Italian'{
                            secondLanguageBody = singleTerm.Body_ITA__c;
                        }
                        when  'English'{
                            secondLanguageBody = singleTerm.SBQQ__Body__c;
                        }
                        when  'Spanish'{
                            secondLanguageBody = singleTerm.Body_ESP__c;
                        }
                        when  'German'{
                            secondLanguageBody = singleTerm.Body_DEU__c;
                        }
                        when  'French'{
                            secondLanguageBody = singleTerm.Body_FRA__c;
                        }
                        when  'Russian'{
                            secondLanguageBody = singleTerm.Body_RUS__c;
                        }
                        when  'Chinese'{
                            secondLanguageBody = singleTerm.Body_CHN__c;
                        }
                        when  'Polish'{
                            secondLanguageBody = singleTerm.Body_POL__c;
                        }
                        when  'Portuguese'{
                            secondLanguageBody = singleTerm.Body_PT__c;
                        }
                        when else {
                            
                        }
                    }
                    string newBody = dynamicBodyAdapter(primaryLanguageBody, quote);
                    string newBodySecondLanguage = dynamicBodyAdapter(secondLanguageBody, quote);
                    newCondition.Body__c = newBody;
                    newCondition.Body_Secondary_Language__c = newBodySecondLanguage;

                    ConditionsToInsert.add(newCondition);
                }
            }
        
        insert ConditionsToInsert;
    }
    
    public static string dynamicBodyAdapter (string body, SBQQ__Quote__c quote){
        string newBody = body;
        system.debug('NewBodySTART: ' + newBody);
        while(true){
            if(newBody == null || newBody.substringBetween('{|','|}') == null || newBody.substringBetween('{|','|}') == '') {
                break;
            }
            string fieldAPIName = newBody.substringBetween('{|','|}').replaceAll('<\\/?[^>]+(>|$)', '');
            string rightHTML = newBody.substringBetween('{|',fieldAPIName);
            string leftHTML = newBody.substringBetween(fieldAPIName,'|}');
            system.debug('fieldAPIName: ' + fieldAPIName);
            system.debug('rightHTML: ' + rightHTML);
            system.debug('leftHTML: ' + leftHTML);
            string stringToSubstitute = '{|'+rightHTML+fieldAPIName+leftHTML+'|}';
            string fieldValue = (string)quote.get(fieldAPIName);
            system.debug('Sostituire: ' + stringToSubstitute + ' con ' + fieldValue);
            if(fieldValue != null){
                newBody = newBody.replace(stringToSubstitute, fieldValue);
            }
            else{
                newBody = newBody.replace(stringToSubstitute, '');
            }
            system.debug('NewBodyCYCLE: ' + newBody);
            system.debug('NEXT FIELD: ' + newBody.substringBetween('{|','|}'));
            
        }
        return newBody;
    }
    

    public static List<String> getAllFieldApiForSObject(String SObjectName) {
        Set<String> fieldSet = Schema.getGlobalDescribe().get(SObjectName).getDescribe().fields.getMap().keySet();
        List<String> retAsList = new List<String>();
        retAsList.addAll(fieldSet);
        return retAsList;
    }

    //Comentata da Matteo le righe dov'è usata la funzione sono tutte commentate impossibilità di coprire il codice
    // public static String getFieldAPIName (String objectName, String fieldLabel){
    //     SObjectType type = Schema.getGlobalDescribe().get(objectName);
    //     Map<String,Schema.SObjectField> mfields = type.getDescribe().fields.getMap();
    //     //POSSIBILE RISPARMIO DI UN FOR
    //     for(String strField:mfields.keySet())
    //     {
    //         SObjectField fl = mfields.get(strField);
    //         if(fieldLabel == fl.getDescribe().getlabel())
    //         {
    //             return strField;
    //         }
    //     }
    //     return null;
    // }

    /*public static List<SBQQ__QuoteLine__c> getAllQuoteLines(Set<Id> QuoteIds){
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('SBQQ__QuoteLine__c').getDescribe().fields.getMap();
 
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
 
        String query = 'Select ' + commaSepratedFields + ' From SBQQ__QuoteLine__c Where Id IN :QuoteIds FOR UPDATE';

        System.debug('getAllFieldsResultByIds query: ' + query);
 
        List<SBQQ__QuoteLine__c> l = Database.query( query );
		 
		return l;
    }   

    public static String getEvaluedFieldsFromConditionPicklist (String objectName, String fieldLabel){
        String objectName = 'SBQQ__TermCondition__c';
        String fieldName ='SBQQ__TestedField__c';

        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        String fieldCommaSeparatedList = 'Id';
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
            if(pickListVal.getValue().contains('__') ){
                fieldCommaSeparatedList = fieldCommaSeparatedList + ', ' +pickListVal.getValue();
            }
            else if(pickListVal.getValue().contains('.')){
                string realAPIName = getFieldAPIName(pickListVal.getValue().split('r.')[0]+'c',pickListVal.getValue().split('r.')[1]);
                fieldCommaSeparatedList = fieldCommaSeparatedList + ', ' +realAPIName
            }
            else{
                string realAPIName = getFieldAPIName('SBQQ__Quote__c',pickListVal.getValue());
                fieldCommaSeparatedList = fieldCommaSeparatedList + ', ' +realAPIName
            }
        }
        system.debug(fieldCommaSeparatedList);
        return fieldCommaSeparatedList;
    }*/
}