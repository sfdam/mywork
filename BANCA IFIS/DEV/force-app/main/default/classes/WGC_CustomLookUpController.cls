public class WGC_CustomLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String fields) {
        return fetchLookUpValues(searchKeyWord, ObjectName, fields, false, '');
    }
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String fields, Boolean soqlSearch, String whereCondition) {
        system.debug('ObjectName-->' + ObjectName);
        system.debug('fields-->' + fields);
        system.debug('searchKeyWord-->' + searchKeyWord);
        system.debug('soqlSearch-->' + soqlSearch);
        system.debug('whereCondition-->' + whereCondition);        
        
        String searchKey = searchKeyWord.replace('\'','\\\'') + '%';
        

        String objectFields = 'Id, Name';
        if(fields != ''){
            objectFields = fields;
        }

        String fildsOrder = objectFields.replace('Id,', '');
        
        String whereContainer = 'Name LIKE \'' + searchKey + '\'';
        String apiNameForLike = '';
        String otherCondition = '';
        if(whereCondition != ''){
            apiNameForLike = whereCondition.substringAfter('###');
            apiNameForLike = apiNameForLike.substringBefore('###');
            
            whereContainer = whereCondition.replace('###' + apiNameForLike + '###', apiNameForLike + ' LIKE \'' + searchKey  + '\'');

        }
        
        system.debug('whereContainer-->' + whereContainer);
        
        List < sObject > returnList = new List < sObject > ();

        if(soqlSearch){ // SOQL
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        	// String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        	// whereCondition = ###Name### AND ..........
        	// --> converted ###Name### -> Name LIKE searchKey
            String sQuery = 'SELECT ' + objectFields + ' FROM ' + ObjectName;
            sQuery = sQuery + ' WHERE ' + whereContainer;
            sQuery = sQuery + ' ORDER BY ' + fildsOrder + ' ASC LIMIT 5';
            System.debug('SV sQuery: ' + sQuery);
            List < sObject > lstOfRecords = Database.query(sQuery);
            
            System.debug('SV lstOfRecords: ' + lstOfRecords);
            //List<List <sObject>> lstOfRecords = search.query(sQuery);
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            } 
        } else { // FIND
            // Create a Dinamic SOSL QUERY FIND {COLTIVAZIONI} IN ALL FIELDS RETURNING Ateco__c(Id, Name, Descrizione__c)
            String sQuery = 'FIND \'' + searchKeyWord + '*\' IN ALL FIELDS RETURNING ' + ObjectName + '(' + objectFields + ') LIMIT 5';
            // List < sObject > lstOfRecords = Database.query(sQuery);
            List<List <sObject>> lstOfRecords = search.query(sQuery);
            for (sObject obj: lstOfRecords.get(0)) {
                returnList.add(obj);
            }            
        }
        
        System.debug('SV returnList: ' + returnList);
   
        return returnList;
    }
}