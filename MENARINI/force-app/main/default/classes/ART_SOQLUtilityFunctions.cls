/**
 * @Group         : TEN Technology
 * @Name          : ART_SOQLUtilityFunctions 
 * @CreateDate    : 2023-03-13
 * @Description   : Classe helper per avere le query piu' comuni effettuare nel SW
 * @TestClass     : SV_Utilities_Test           --  Classe di test per gli HelperMeethod del SW Framework 
 * @TestMethod    : testART_SOQLUtilityFunctionsClass
 */
public inherited sharing class ART_SOQLUtilityFunctions {

    /**
     *                              Metodi di query sull'oggetto Utility__mdt: 
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
    
    /*
     * @CreateDate    : 2023-04-18
     * @Description   : Restituisce una mappa raggruppata per DeveloperName, per avere i relativi valori.
     */
    public static Map<String, ART_SalesRepProfile__mdt> givesAllSalesRepProfiles() {
        Map<String, ART_SalesRepProfile__mdt> result = new Map<String, ART_SalesRepProfile__mdt>();
        
        for(ART_SalesRepProfile__mdt utl : Database.query('select id, ART_ProfileName__c, DeveloperName, Label, MasterLabel from ART_SalesRepProfile__mdt')) {
            result.put(utl.DeveloperName, utl);
        }

        return result;
    }    
}