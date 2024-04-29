public class RedirectNDGController {
    
    public String abi = ApexPages.currentPage().getParameters().get('abi');
    public String ndg = ApexPages.currentPage().getParameters().get('ndg');

    public String ERRORMESSAGE {get;set;}
    public PageReference urlRedirection() {

        List<Account> account = [SELECT id FROM Account WHERE FinServ__BankNumber__c =: abi AND CRM_NDG__c =: ndg];
        if(!account.isEmpty() && !String.isBlank(abi) && !String.isBlank(ndg)){

            string url = '/' + account[0].Id;
    
            PageReference page = new PageReference(url);
            page.setRedirect(true);
            return page;
        }else{
            if(String.isBlank(abi) || String.isBlank(ndg)){

                ERRORMESSAGE = 'ERRORE - VALORIZZA ENTRAMBI I PARAMETRI(NDG, ABI)';
            }else{

                ERRORMESSAGE = 'ERRORE - NDG NON TROVATO';
            }
            return null;
        }
    }
}