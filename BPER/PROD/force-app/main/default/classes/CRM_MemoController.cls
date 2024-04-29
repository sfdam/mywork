public with sharing class CRM_MemoController {
    
    @AuraEnabled
    public static User getUserInfo() {
        return [ SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId() ];
        
    }

    @AuraEnabled
    public static List<MemoWrapper> getAllData(Id recordId){
        
        System.debug('CRM_MemoController getAllData recordId: ' + recordId);

        List<CRM_Memo__c> memoList = [SELECT Id, 
                                                Cliente__c, 
                                                Name, 
                                                CRM_Tipologia__c, 
                                                CRM_FineValidita__c, 
                                                CRM_PopupCassa__c  
                                                FROM CRM_Memo__c 
                                                WHERE Cliente__c = :recordId 
                                                AND CRM_IsPrivateMemoVisible__c = TRUE 
                                                AND (CRM_FineValidita__c = NULL OR CRM_FineValidita__c >= TODAY)];

        List<CH_Memo__c> chMemoList = [SELECT Id, 
                                                CRM_Account__c, 
                                                Name, 
                                                CRM_Tipologia__c, 
                                                CRM_FineValidita__c, 
                                                CRM_PopupCassa__c  
                                                FROM CH_Memo__c 
                                                WHERE CRM_Account__c =: recordId 
                                                AND (CRM_FineValiditaFormula__c = NULL OR CRM_FineValiditaFormula__c >= TODAY)];

        List<MemoWrapper> wrapperList = new List<MemoWrapper>();
        try{

            for(CRM_Memo__c memo : memoList){
                wrapperList.add(new MemoWrapper(memo.Name, memo.CRM_Tipologia__c, memo.CRM_FineValidita__c, memo.CRM_PopupCassa__c,memo.Id));
            }

            Date validitaMemo;
            for(CH_Memo__c memo : chMemoList){
                validitaMemo = memo.CRM_FineValidita__c == null ? null : date.valueOf(memo.CRM_FineValidita__c);
                wrapperList.add(new MemoWrapper(memo.Name, memo.CRM_Tipologia__c, validitaMemo, memo.CRM_PopupCassa__c,memo.Id));
            }
            System.debug('CRM_MemoController wrapperList: ' + wrapperList);
            System.debug('CRM_MemoController wrapperList size: ' + wrapperList.size());
    
        }catch(Exception e){
            System.debug('CRM_MemoController exception: '+e.getStackTraceString() );
        }

        //if(!wrapperList.isEmpty()) wrapperList.sort();

        return wrapperList;

    }


    public class MemoWrapper {

        @AuraEnabled 
        public String titolo;
        @AuraEnabled 
        public String tipologia;
        @AuraEnabled 
        public Date fineValidita;
        @AuraEnabled 
        public Boolean popupCassa;
        @AuraEnabled 
        public String elementId;

            
        // Constructor
        public MemoWrapper(String titolo, String tipologia, Date fineValidita, Boolean popupCassa,String elementId) {
            this.titolo = titolo;
            this.tipologia = tipologia;
            this.fineValidita = fineValidita;
            this.popupCassa = popupCassa;
            this.elementId = elementId;
        }
    
    }
}