public with sharing class ClickToDial_Controller {
    @AuraEnabled
    public static void updateUser(User currentUser) {

        try {
            update currentUser;
        }catch (Exception e) {
            throw new AuraHandledException('Errore updateUser: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean getOrgId() {

        Organization org = [select Name, IsSandbox from Organization where Id =:UserInfo.getOrganizationId()];
        if(org.IsSandbox){ 
            return true; 
        }
        return false; 
    }

    @AuraEnabled
    public static Object getPhoneNumbers(String AccountId) {
        Map<String, String> phoneRecordsMap = new Map<String, String>();
        Map<String, String> phoneLabelOrder = new Map<String, String>{
            'Cellulare certificato' => '1',
            'Telefono account' => '2',
            'Telefono 1' => '3',
            'Telefono 2' => '4'
        };

        String query = 'SELECT ';
        Schema.DescribeSObjectResult accountObj = Account.sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = accountObj.fields.getMap();

        for (String fieldApiName : fieldsMap.keySet()) {
            Schema.DescribeFieldResult fieldResult = fieldsMap.get(fieldApiName).getDescribe();
            if (fieldResult.getType() == Schema.DisplayType.PHONE) {
                query += fieldApiName + ', ';
            }
        }
        query = query.substring(0, query.length() - 2);
        query += ' FROM Account WHERE Id = :AccountId';
        List<Account> accounts = Database.query(query);

        if (!accounts.isEmpty()) {
            Account acc = accounts[0];
            for (String fieldApiName : fieldsMap.keySet()) {
                Schema.DescribeFieldResult fieldResult = fieldsMap.get(fieldApiName).getDescribe();
                if (fieldResult.getType() == Schema.DisplayType.PHONE) {
                    String phoneValue = String.valueOf(acc.get(fieldApiName));
                    if (phoneValue != null) {
                        String label = fieldResult.getLabel();
                        String phoneOrder = phoneLabelOrder.get(label);
                        if (phoneOrder == null) {
                            phoneOrder = String.valueOf(phoneLabelOrder.size() + 1);
                        }
                        phoneRecordsMap.put(phoneOrder + label, phoneValue);
                    }
                }
            }
        }
        List<String> orderKeys = new List<String>(phoneRecordsMap.keySet());
        orderKeys.sort();

        Map<String, String> orderPhoneRecordsMap = new Map<String, String>();
        for (String key : orderKeys) {
            orderPhoneRecordsMap.put(key.substring(1), phoneRecordsMap.get(key));
        }

        return orderPhoneRecordsMap;
    }
}