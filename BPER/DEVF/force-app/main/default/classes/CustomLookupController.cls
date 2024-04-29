public with sharing class CustomLookupController {

    @AuraEnabled public String objId;
    @AuraEnabled public String sObjectName;
    @AuraEnabled public String iconName;
    @AuraEnabled public SObject obj;
    @AuraEnabled public String name;

    public CustomLookupController(String objId, String sObjectName, String iconName, String name, SObject obj) {
        this.objId = objId;
        this.sObjectName = sObjectName;
        this.iconName = iconName;
        this.name = name;
        this.obj = obj;
    }

    @AuraEnabled
    public static List<CustomLookupController> getSearchResult(String strSearch, String fieldAlternativeInLabel, String otherFieldToQuery, String fieldToLike, String sObjectName, String iconName, String condition, List<String> recordIdList){
        System.debug('AD getSearchResult');
        List<CustomLookupController> results = new List<CustomLookupController>();
        String query = '';
        System.debug('DK recordIdList' + JSON.serialize(recordIdList));

        if(String.isBlank(strSearch))
            return results;

        if(!String.isBlank(otherFieldToQuery)){
            otherFieldToQuery = ', ' + otherFieldToQuery;
    
        }

        List<String> fieldToLikeList = fieldToLike.split(',');

            //TODO Migliora mettendo la lista di campi da cercare
            query = 'SELECT Id, Name ' + String.escapeSingleQuotes(otherFieldToQuery) + ' FROM '+ String.escapeSingleQuotes(sObjectName) + ' WHERE ';

                Integer count = 0;
                for(String field : fieldToLikeList){
                    if(count <= 0){
                        query = query + '(' +  String.escapeSingleQuotes(field) +' LIKE \'%'+ String.escapeSingleQuotes(strSearch) +'%\' ';
                    } else {
                        query = query + 'OR ' +  String.escapeSingleQuotes(field) +' LIKE \'%'+ String.escapeSingleQuotes(strSearch) +'%\' ';

                    }
                    count++;
                }
                query = query + ') ';

                if(condition != null && String.isNotBlank(condition))
                    query += 'AND (' + condition + ' )';

                //DK START DE-067
                if(recordIdList != null && !recordIdList.isEmpty())
                query += 'AND Id IN: recordIdList';
                //DK END DE-067
            
                
            System.debug('@@@ final query ' + query);
            List<SObject> sobjectList = Database.query(query);

            List<String> fieldAlternativeList = new List<String>();
            if(!String.isBlank(fieldAlternativeInLabel)){
                fieldAlternativeList = fieldAlternativeInLabel.split(',');
                
            }
            
            for(SObject obj : sobjectList){
                List<String> valueAlternativeList = new List<String>();
                Map<String, Object> objMap = obj.getPopulatedFieldsAsMap();
                System.debug('DK objMap' + JSOn.serialize(objMap));
                String x_name = (String)objMap.get('Name');
                
                if(fieldAlternativeList.size() == 0){
                    x_name = x_name;
                }
                else{
                    for(Integer i = 0;i<fieldAlternativeList.size();i++){
                        //DK START DE-041_042
                        if(!fieldAlternativeList[i].contains('.')){
                            if(objMap.get(fieldAlternativeList[i]) != null)valueAlternativeList.add(String.valueOf(objMap.get(fieldAlternativeList[i])));
                        }else{
                            List<String> fieldAlternativeKeys = fieldAlternativeList[i].split('\\.');
                            integer fieldAlternativeKeysSize = fieldAlternativeKeys.size();
                            Map<String, Object> currentMap = ((SObject)objMap.get(fieldAlternativeKeys[0])).getPopulatedFieldsAsMap();
                            for(Integer k = 1; k < fieldAlternativeKeysSize - 1; k++){
                                currentMap = ((SObject)currentMap.get(fieldAlternativeKeys[k])).getPopulatedFieldsAsMap();
                            }
                            if(currentMap.get(fieldAlternativeKeys[fieldAlternativeKeysSize-1]) != null)valueAlternativeList.add(String.valueOf(currentMap.get(fieldAlternativeKeys[fieldAlternativeKeysSize-1])));
                        }
                        //DK END DE-041_042
                    }
                    
                    if(!fieldAlternativeList.isEmpty())x_name = x_name + ' (' + String.join(valueAlternativeList, ', ') + ')';

                    //x_name = x_name + ')';
                }
                CustomLookupController res = new CustomLookupController((Id)objMap.get('Id'), sObjectName, iconName, x_name, obj);
                results.add(res);
            }    
        
        return results;
    }
}