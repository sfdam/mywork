/**
 * @Group         : TEN Technology 
 * @CreateDate    : 2023-03-13
 * @Description   : Utility Class
 * 
 */
/**
     * @description                   Recupera dal CustomSetting TriggerSettings__c se il trigger è disattivo
     * @param  objectName             Nome del on del Trigger
     * @author 						  matteo loprevite
     */ 
@isTest
public with sharing class UtilityFunctions_Test {

    // @TestVisible virtual Utility__mdt getAllMetadata() {
    //     return [
    //         SELECT Id, DeveloperName, ValoreStringa__c,Language
    //         FROM Utility__mdt
    //         LIMIT 1
    //     ];
    // }

    @isTest
    static void UtilityFunctions_Test() {

        // Utility__mdt u = new Utility__mdt(
        //     DeveloperName ='Test',
        //     ValoreStringa__c='Test@Test.it',
        //     Language= 'en_US'
        // );

        // insert u;

        Utility__mdt u = [SELECT Id, DeveloperName, ValoreStringa__c,Language
        FROM Utility__mdt
        LIMIT 1];
        system.debug('@@@il metadato è' + u);

        TriggerSettings__c TS =  new TriggerSettings__c(
            Deactivate__c = false,
            UserName__c = 'Test@Test.it',
            Name = 'TriggerSettings'

        );
        insert TS;
        Test.startTest();

        Map<String, String> malResult = UtilityFunctions.givesValAttrGrouppedDevName_LIKESearch('%Test%');

        List<String> lString= new List<String>();
        lString.add('CopiaCommissioneDeFROM');
        lString.add('CopiaCommissioneDeInTO	');
        
        Map<String, Utility__mdt> MApSTUtility = UtilityFunctions.givesUtlGrouppedDevName(lString);

        Boolean isActive = UtilityFunctions.isTriggerDeactive('TriggerSettings');
        Test.stopTest();
    }
}