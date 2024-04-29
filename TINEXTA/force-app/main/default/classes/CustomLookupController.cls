public with sharing class CustomLookupController {

    @AuraEnabled public String objId;
    @AuraEnabled public String sObjectName;
    @AuraEnabled public String iconName;
    @AuraEnabled public String name;

    public CustomLookupController() {
        this.objId = '';
        this.sObjectName = 'Opportunity';
        this.iconName = 'standard:opportunity';
        this.name = 'Nome Opportunità';
    }

    public CustomLookupController(String objId, String sObjectName, String iconName, String name) {
        this.objId = objId;
        this.sObjectName = sObjectName;
        this.iconName = iconName;
        this.name = name;
    }

    @AuraEnabled
    public static List<CustomLookupController> getSearchResult(String strSearch, String sObjectName, String iconName, String condition){
        List<CustomLookupController> results = new List<CustomLookupController>();
        String query = '';

        if(String.isBlank(strSearch))
            return results;

        //TODO Migliora mettendo la lista di campi da cercare
        query = 'SELECT Id, Name FROM '+ sObjectName + ' WHERE Name LIKE \'%'+ strSearch +'%\' ';

        if(condition != null && String.isNotBlank(condition))
            query += 'AND (' + condition + ' )';
            
        System.debug('@@@ final query ' + query);
        List<SObject> sobjectList = Database.query(query);

        for(SObject obj : sobjectList){
            CustomLookupController res = new CustomLookupController((Id)obj.get('Id'), sObjectName, iconName, String.valueOf(obj.get('Name')));
            results.add(res);
        }

        return results;
    }
}