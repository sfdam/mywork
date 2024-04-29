/**
* Controller of multipleAssignement LWC
*
* @author  Dam Kebe @Lutech
* @version 1.0
* @since   2020-07-27
*/
public with sharing class AllDataFactory {

    public static String ORG_NAME {
        
        get{
            if(!String.isBlank(ORG_NAME)){
                
                return ORG_NAME;
            }
            Organization org = [select Name, IsSandbox from Organization where Id =:UserInfo.getOrganizationId()];
            ORG_NAME = org.Name.replaceAll( '\\s+', '');
            if(org.IsSandbox){
                
                ORG_NAME += 'isTest';
            }
            return ORG_NAME;
        }set;
    }
    
    public static Account getAccount(String suffix, String recordTypeDeveloperName){
        
        Account account = new Account(
            RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', recordTypeDeveloperName)
            );
        
        if(recordTypeDeveloperName == 'PersonAccount'){
            
            account.FirstName = 'FirstName' + suffix;
            account.LastName = 'LastName' + suffix;
        }else{
            
            account.Name = 'Account' + suffix;
            account.PTF_BranchTypology__c = 'A';
        }
        return account;
    }

    public static FinServ__FinancialAccount__c getFinancialAccount(String recordTypeDeveloperName, String suffix, String accountId){

        return new FinServ__FinancialAccount__c(
            Name = 'FinancialAccount' + suffix,
            FinServ__PrimaryOwner__c = accountId,
            RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('FinServ__FinancialAccount__c', recordTypeDeveloperName)
        );
    }
    
    public static FinServ__FinancialAccountRole__c getFinancialAccountRole(String recordTypeDeveloperName, String financialAccountId, String relatedlAccountId, String role){
        
        return new FinServ__FinancialAccountRole__c(
            FinServ__FinancialAccount__c = financialAccountId,
            FinServ__RelatedAccount__c = relatedlAccountId,
            FinServ__Role__c = role,
            RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('FinServ__FinancialAccountRole__c', recordTypeDeveloperName)
        );
    }
    
    public static Contact getContact(String suffix, String userId, String accountId){
        
        return new Contact(
            FirstName = 'FirstName' + suffix,
            LastName = 'LastName' + suffix,
            Email = 'email' + suffix + '@test.com',
            PTF_User__c = userId,
            AccountId = accountId
        );
    }
    
    public static Wallet__c getWallet(string recordTypeDeveloperName, String filiale, String modelloDiServizio){

        return new Wallet__c(
            RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Wallet__c', recordTypeDeveloperName),
            PTF_Filiale__c = SV_Utilities.getType(filiale) == 'Id' ? filiale : null,
            PTF_ModelloDiServizio__c = modelloDiServizio
        );
    }

    public static Assignment__c getAssignment(String recordTypeDeveloperName, String microPortafoglioId, String gestoreId){

        return new Assignment__c(
            RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Assignment__c', recordTypeDeveloperName),
            PTF_MicroWallet__c = microPortafoglioId,
            PTF_Gestore__c = gestoreId
        );
    }

    public static User getUser(String suffix, String profileId, String modelloDiServizio){
        
        return new User(
            LastName = 'Test' + suffix,
            Email = 'test' + suffix + '@test.com',
            ModelloDiServizio__c = modelloDiServizio,
            PTF_RegistrationNumber__c = suffix,
            Alias = 'code' + suffix,
            Username = 'test' + suffix + ORG_NAME + '@test.com',
            CommunityNickname = 'test' + suffix,
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            ProfileID = profileId,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
        );
    }

    public static Account getPersonAccount(String suffix){
        
        return new Account(
            LastName = 'Person' + suffix,
            RecordTypeId = SV_Utilities.getRecordTypeByDeveloperName('Account', 'PersonAccount')
        );
    }
    
    public static FinServ__FinancialAccountTransaction__c getFinancialAccountTransaction(String financialAccountId, String Ttype, String Tstatus){
        
        return new FinServ__FinancialAccountTransaction__c(
            FinServ__FinancialAccount__c = financialAccountId,
            FinServ__TransactionStatus__c = Tstatus,
            FinServ__TransactionType__c = Ttype,
            FinServ__TransactionDate__c = Date.today(),
            FinServ__Amount__c = 50
        );
    }
    
    public static Case getCase(){
        
        return new Case(
            CRM_Area__c = 'Digital Services',
            CRM_Scope__c = 'Internet Banking'
        );
    }

    public static Campaign getCampaign(String suffix, String ownerId, String recordTypeId){
        
        return new Campaign(
            Name = 'Campaign' + suffix,
            CRM_NomeAttributo1__c = 'Data di nascita',
            CRM_NomeAttributo2__c = 'Transato POS',
            OwnerId = ownerId,
            CRM_TipologiaClientela__c = 'Tutti',
            RecordTypeId = recordTypeId,
            CRM_Organizzazione__c = 'BPER',
            CRM_OwnerSystem__c = 'Siebel',
            IsActive = true
        );
    }

    public static CampaignMember getCampaignMember(String suffix, String campaignId, String contactId, String assegnatario){
        
        return new CampaignMember(
            Campaignid = campaignId,
            ContactId = contactId,
            Status = 'Da contattare',
            CRM_StatoAssegnazione__c = 'Assegnato',
            CRM_Assegnatario__c = assegnatario
        );
    }

    public static Opportunity getOpportunity(String suffix, String ownerId, Date closeDate){
        
        return new Opportunity(
            OwnerId = ownerId,
            Name = 'Opportunity' + suffix,
            StageName = 'Da contattare',
            CloseDate = closeDate
        );
    }
}