public class GenericDao {
    
    public static List<Account> getAllFieldsResultByCondition(String objectName, String key, Set<Id> value){
         Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
         System.debug('schemaMap:' + schemaMap);
         System.debug('schemaMap.get(objectName).getDescribe():' + schemaMap.get(objectName).getDescribe());
         System.debug('schemaMap.get(objectName).getDescribe().fields:' + schemaMap.get(objectName).getDescribe().fields);
         System.debug('schemaMap.get(objectName).getDescribe().fields.getMap():' + schemaMap.get(objectName).getDescribe().fields.getMap());

        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
 
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
 
        String query = 'Select ' + commaSepratedFields + ' From ' + objectName + ' Where ' + key + ' IN :value ';
 
        List<Account> l = Database.query( query );  //PRENDO TUTTI GLI ACCOUNT SELEZIONATI CON TUTTI I LORO CAMPI E  LI SPARO FUORI
         
        return l == null || l.isEmpty() ? null : l;
    }

}