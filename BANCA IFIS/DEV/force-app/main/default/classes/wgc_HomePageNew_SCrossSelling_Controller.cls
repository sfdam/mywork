public with sharing class wgc_HomePageNew_SCrossSelling_Controller {
    
    public wgc_HomePageNew_SCrossSelling_Controller() {
    }

    @AuraEnabled
    public static List<Opportunity> countSegnalazioni()
    {
        return
        [
            SELECT Id, StageName, CloseDate from Opportunity WHERE 
            Originator__c='Cross Selling' AND
            RecordType.Developername='WGC_IFIS_Leasing' AND
            Account.WGC_Specialista_Factoring__c = :UserInfo.getUserId()
        ];
    }

}