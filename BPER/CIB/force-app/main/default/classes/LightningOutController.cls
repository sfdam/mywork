public with sharing class LightningOutController {
    
    // public String abi = ApexPages.currentPage().getParameters().get('abi');
    // public String ndg = ApexPages.currentPage().getParameters().get('ndg');

    @AuraEnabled
    public static Map<String,Object> verifyNDG (String ndg, String abi){

        list<CampaignMember> cm = [SELECT Id, Name,Contact.Account.PTF_ModelloDiServizio__c,
                                          Contact.Account.PTF_Portafoglio__r.Name,Contact.Account.id,
                                          Contact.Account.CRM_ReferenteNameFormula__c
                                   FROM CampaignMember WHERE Contact.Account.CRM_NDG__c  =: ndg AND Contact.Account.FinServ__BankNumber__c =: abi];
       
        List<CRM_Memo__c> mms = [SELECT Id, Cliente__r.Name, Cliente__c, Cliente__r.PTF_ModelloDiServizio__c, Cliente__r.PTF_Portafoglio__c,Cliente__r.PTF_Portafoglio__r.Name,Cliente__r.CRM_ReferenteNameFormula__c, Name,CRM_Titolo__c, CRM_Note__c, CRM_FineValidita__c, Autore__c FROM CRM_Memo__c WHERE Cliente__r.CRM_Ndg__c =:ndg AND Cliente__r.FinServ__BankNumber__c =:abi  AND  CRM_StatoMemo__c != 'Scaduto' AND CRM_PopupCassa__c = true AND CRM_FineValidita__c >= TODAY];
        if(cm.size()>0 ){

            return new Map<String,Object> {
                'hasCampaigns' => true,
                'accountInfo' => cm
            };
        } else if(mms.size()>0) {
            return new Map<String,Object> {
                'hasMemo' => true,
                'accountInfo' => mms
            };
        } else{

            List<Account> acc = [SELECT ID , NAME,CRM_ReferenteNameFormula__c,PTF_Portafoglio__r.Name,PTF_ModelloDiServizio__c FROM Account WHERE CRM_NDG__C =: ndg AND FinServ__BankNumber__c =: abi];

            return new Map<String,Object> {
                'hasCampaigns' => false,
                'accountInfo' => acc
            };
        }   
    }

    @AuraEnabled
    public static String getAllData(String ndg, String abi) {

        System.debug('ndg: ' + ndg);

        Date lastThirtyDays = Date.today().addDays(-30);
        System.debug('Date.today(): ' + Date.today() );
        System.debug('lastThirtyDays : ' + lastThirtyDays  );

        Account account = [SELECT Id, Name, CRM_NDG__c, PTF_ModelloDiServizio__c, PTF_Portafoglio__r.Name FROM Account WHERE CRM_NDG__c =: ndg AND FinServ__BankNumber__c=: abi];
        Contact contact = [SELECT Id from Contact WHERE AccountId =: account.id];
        List<CampaignMember> campaignMember = [SELECT Id, CRM_AssegnatarioFormula__c, CampaignId, Campaign.Tipologia_Azione__c, Campaign.Type, Campaign.Name, Campaign.StartDate, Campaign.EndDate, CRM_Esito__c,Status FROM CampaignMember WHERE ContactId =: contact.Id AND CRM_EsitoDefinitivo__c= false AND Campaign.CRM_CampagnaInCorso__c = true];
        List<Event> events = [SELECT Id,Subject, Owner.Name, Type, CRM_Canale__c, CRM_EventStatus__c, ServiceAppointment.Status  FROM Event WHERE AccountId =: account.Id AND EndDate >= TODAY ]; //AND ServiceAppointment.Status = 'Programmato'];
        List<Opportunity> opportunities = [SELECT Id, Name, Referente__c, CRM_Oggetto__c, StageName, CRM_Canale__c, CRM_Bisogno__c FROM Opportunity WHERE AccountId =: account.Id AND CRM_EsitoContatto__c != 'Prodotto venduto' AND CRM_EsitoContatto__c != 'Prodotto non venduto' AND CRM_FaseFormula__c != 'Scaduta' AND CloseDate > TODAY];
        //List<FinServ__Alert__c> scadenze = [SELECT Id, FinServ__FinancialAccount__r.Name, CRM_Importo__c, CRM_FormulaData__c, CRM_Bisogno__c, CRM_InfoProdottoBisogno__c,CRM_EsitoContatto__c, CRM_DataScadenza__c FROM FinServ__Alert__c WHERE FinServ__Account__c =: account.Id AND (CRM_DataScadenza__c >: Date.today() OR (CRM_DataScadenza__c <: Date.today() AND CRM_DataScadenza__c >=: lastThirtyDays))];
        List<FinServ__Alert__c> scadenze = [SELECT Id, FinServ__FinancialAccount__r.Name, CRM_Importo__c, CRM_FormulaData__c, CRM_Bisogno__c, CRM_InfoProdottoBisogno__c,CRM_EsitoContatto__c, CRM_DataScadenza__c FROM FinServ__Alert__c WHERE FinServ__Account__c =: account.Id AND (CRM_DataScadenza__c >: Date.today() OR (CRM_DataScadenza__c <: Date.today() AND CRM_DataScadenza__c >=: lastThirtyDays)) AND CRM_IsVisible__c = true and FinServ__FinancialAccount__c IN (select FinServ__FinancialAccount__c 
                from FinServ__FinancialAccountRole__c 
                where FinServ__RelatedAccount__c =:account.Id
                and (FinServ__Role__c = 'Primary Owner' or FinServ__Role__c = 'Cointestatario') 
                and FinServ__Active__c = true)];
        List<CRM_Memo__c> memos = [SELECT Id, Name,CRM_Titolo__c, CRM_Note__c, CRM_FineValidita__c, Autore__c FROM CRM_Memo__c WHERE Cliente__c =:account.Id AND  CRM_StatoMemo__c != 'Scaduto' AND CRM_PopupCassa__c = true AND CRM_FineValidita__c >= TODAY];

        return JSON.serialize(new Map<String,Object>{
            'account' => account,
            'events' => events,
            'campaigns' => campaignMember,
            'opportunities' => opportunities,
            'scadenze' => scadenze,
            'memos' => memos
        });
    }
}