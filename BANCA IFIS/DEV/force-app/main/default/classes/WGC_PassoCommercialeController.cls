public with sharing class WGC_PassoCommercialeController {
    
    @AuraEnabled
    public static List <Passo_Commerciale__c> GetPassoCommercialeData() {
    
        Integer CurrentMonth = Date.Today().Month();
        Integer CurrentYear = Date.Today().year();

           list <Passo_commerciale__c> passoCommercialeList =
            [
                SELECT Actual_Pratiche__c, Actual_visite__c, Mese__c, Anno__c,Passo_Pratiche__c,Passo_Visite__c 
                FROM Passo_commerciale__c
                WHERE 
                Utente__c = :UserInfo.getUserId()
                AND 
                Mese__c = :String.valueOf(CurrentMonth)
                AND
                Anno__c = :String.valueOf(CurrentYear) 
            ]; 

        return passoCommercialeList;
    
    }   
}