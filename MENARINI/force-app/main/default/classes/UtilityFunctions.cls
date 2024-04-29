/**
 * @Group         : TEN Technology 
 * @CreateDate    : 2023-03-13
 * @Description   : Utility Class
 * @TestClass     : UtilityFunctions_Test
 */
public with sharing class UtilityFunctions {

    /**
     * - Map<String, String> givesValAttrGrouppedDevName_LIKESearch(queryLIKEWhere)
     * - Map<String, Utility__mdt> givesUtlGrouppedDevName(devNames)
     */

    /*
     * @CreateDate    : 2023-03-13
     * @Description   : Restituisce una mappa raggruppata per DeveloperName, per avere gli oggetti Utility__mdt 
     * 				 con il DeveloperName e ValoreStringa__c a seguitoto di una LIKE Research sul DeveloperName.
     */
    public static Map<String, String> givesValAttrGrouppedDevName_LIKESearch(String queryLIKEWhere) {
        Map<String, String> result = new Map<String, String>();
        if(queryLIKEWhere != '' && queryLIKEWhere.contains('%')) {
            String query = 'SELECT DeveloperName, ValoreStringa__c FROM Utility__mdt WHERE DeveloperName LIKE \'' + queryLIKEWhere + '\'';
            
            for(Utility__mdt utl : Database.query(query)) {
                result.put(utl.DeveloperName, utl.ValoreStringa__c);
            }
        }
        return result;
    }

    /*
     * @CreateDate    : 2023-03-20
     * @Description   : Restituisce una mappa raggruppata per DeveloperName, per avere i relativi valori.
     */
    public static Map<String, Utility__mdt> givesUtlGrouppedDevName(List<String> devNames) {
        Map<String, Utility__mdt> result = new Map<String, Utility__mdt>();
        
        for(Utility__mdt utl : Database.query('SELECT DeveloperName, ValoreStringa__c, CampoMail__c FROM Utility__mdt WHERE DeveloperName IN :devNames')) {
            result.put(utl.DeveloperName, utl);
        }

        return result;
    }
     /**
     * @description                   Recupera dal CustomSetting TriggerSettings__c se il trigger è disattivo
     * @param  objectName             Nome del on del Trigger
     * @author 						  roberto.murgia
     */ 
    public static Boolean isTriggerDeactive (String objectName){
        TriggerSettings__c triggSet = TriggerSettings__c.getInstance(objectName);
        if(triggSet != null && UserInfo.getUserName() == triggSet.UserName__c && triggSet.Deactivate__c){
            return true;
        }
        return false;
    }
}