public with sharing class AccountController {
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getAccounts() {
        Map<String, List<Contact>> accountContactsMap = new Map<String, List<Contact>>();
        List<Account> accountList = [
            SELECT Name, AnnualRevenue, Industry, (SELECT id, FirstName, LastName FROM Contacts)
            FROM Account
            WITH SECURITY_ENFORCED
            ORDER BY Name
        ];
        for(Account account : accountList){

            accountContactsMap.put(account.Id, account.contacts);
        }

        return new Map<String,Object> {
            'accountList' => accountList,
            'accountContactsMap' => accountContactsMap
        };
    }
}