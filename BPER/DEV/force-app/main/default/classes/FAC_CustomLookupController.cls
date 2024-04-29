public with sharing class FAC_CustomLookupController {

    @AuraEnabled public String objId;
    @AuraEnabled public String sObjectName;
    @AuraEnabled public String iconName;
    @AuraEnabled public SObject obj;
    @AuraEnabled public String name;

    /*public FAC_CustomLookupController() {
        this.objId = '';
        this.sObjectName = 'Opportunity';
        this.iconName = 'standard:opportunity';
        this.name = 'Nome Opportunità';
        this.obj = Schema.getGlobalDescribe().get('Opportunity').newSObject();
    }*/

    public FAC_CustomLookupController(String objId, String sObjectName, String iconName, String name, SObject obj) {
        this.objId = objId;
        this.sObjectName = sObjectName;
        this.iconName = iconName;
        this.name = name;
        this.obj = obj;
    }

    @AuraEnabled
    public static List<FAC_CustomLookupController> getSearchResult(String strSearch, String fieldAlternativeInLabel, String otherFieldToQuery, String fieldToLike, String sObjectName, String iconName, String condition){
        List<FAC_CustomLookupController> results = new List<FAC_CustomLookupController>();
        String query = '';


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
            
                
            System.debug('@@@ final query ' + query);
            List<SObject> sobjectList = Database.query(query);

            List<String> fieldAlternativeList = new List<String>();
            if(!String.isBlank(fieldAlternativeInLabel)){
                fieldAlternativeList = fieldAlternativeInLabel.split(',');
                
            }
            
            for(SObject obj : sobjectList){
                
                String x_name = (String)obj.get('Name');
                
                if(fieldAlternativeList.size() == 0){
                    x_name = x_name;

                }
                else{
                    x_name = x_name + ' (';
                    for(Integer i = 0;i<fieldAlternativeList.size();i++){
                            
                            if(i == 0){
                            x_name = x_name + obj.get(fieldAlternativeList[i]);
                            }
                            else{
                                if(obj.get(fieldAlternativeList[i])==null)
                                    x_name = x_name + ')';
                                else 
                                    x_name = x_name+ ', ' + obj.get(fieldAlternativeList[i])+')';    
                            }             
                    }
                    //x_name = x_name + ')';
                }


                FAC_CustomLookupController res = new FAC_CustomLookupController((Id)obj.get('Id'), sObjectName, iconName, x_name, obj);
                results.add(res);
            }    
        
        return results;
    }
}