public with sharing class LookupComboboxController {

    public class Option {
        @AuraEnabled public String label {get; set;}
        @AuraEnabled public String value {get; set;}

        public Option(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    @AuraEnabled
    public static List<Option> getOptions(String targetObject, String targetField, String searchValue, String queryLimit) {
        List<Option> options = new List<Option>();
        String query = 'SELECT Id, ' + String.escapeSingleQuotes(targetField) +
                ' FROM ' + String.escapeSingleQuotes(targetObject) +
                ' WHERE ' + String.escapeSingleQuotes(targetField) + ' LIKE ' + '\'%' + String.escapeSingleQuotes(searchValue) + '%\'' +
                ' ORDER BY ' + String.escapeSingleQuotes(targetField) +
                ' LIMIT ' + String.escapeSingleQuotes(queryLimit);

        System.debug('LookupComboboxController getOptions query: ' + query);

        for(SObject obj : Database.query(query)){
            options.add(new Option((String) obj.get(targetField), obj.Id));
        }

        return options;
    }
}