/*
 * @Author        : Alessandro Di Nardo @ten
 * @Name		  : ART_DeleteAccountTeamBatch 
 * @CreateDate    : 2023-09-08
 * @Description   : eliminazione dei record di AccountTeamMember  e cgcloud__Account_Manager__c
 * 					
 * @ClassTest     : ART_DeleteAccountTeamBatchTest
 */
global with sharing  class ART_DeleteAccountTeamBatch implements Database.Batchable<sObject>, Database.Stateful {

    global String sobjectName;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        
        System.debug('AD start ART_DeleteAccountTeamBatch');
        // List<sObject> twoObjects = new List<sObject>();
        // twoObjects.addAll([SELECT Id FROM AccountTeamMember WHERE UserId IN (SELECT cgcloud__User__c FROM cgcloud__Org_Unit_User__c )]);
        // twoObjects.addAll([SELECT Id FROM cgcloud__Account_Manager__c WHERE cgcloud__User__c IN (SELECT cgcloud__User__c FROM cgcloud__Org_Unit_User__c )]);
        return Database.getQueryLocator('SELECT Id FROM ' + sobjectName + ' WHERE ' + (sobjectName == 'AccountTeamMember' ? 'UserId' : 'cgcloud__User__c') + ' IN (SELECT cgcloud__User__c FROM cgcloud__Org_Unit_User__c )');
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        
        System.debug('AD execute ART_DeleteAccountTeamBatch');
        System.debug('AD ART_DeleteAccountTeamBatch scope : ' + scope);
        delete scope;
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('AD method finish ART_DeleteAccountTeamBatch');
    }
}