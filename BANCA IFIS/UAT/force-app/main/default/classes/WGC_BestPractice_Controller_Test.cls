@isTest
public with sharing class WGC_BestPractice_Controller_Test {
    @isTest
    public static void Test_metodi(){
    
        
        WGC_AllDataFactory.createBestPractice(5,false);
        WGC_AllDataFactory.createUtenzaDefault(); 
        
        Test.startTest();
        WGC_BestPractice_Controller.callBestPractice();
        Test.stopTest();
        
    }
    @isTest
    public static void Test_metodi2(){
        WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createUtenzaDefault(); 
        List<Event> listEvent = WGC_AllDataFactory.createEvent(1,true);
        Contact c = [SELECT Id, Lastname, AccountId FROM Contact Limit 1];
        Account a = [SELECT Id,WGC_Specialista_Factoring__c, WGC_Qualifica_Corporate__c FROM Account Limit 1];
        a.WGC_Specialista_Factoring__c = UserInfo.getUserId() ;
        a.WGC_Qualifica_Corporate__c = 'Cliente Attivo';
        update a;

        List<Opportunity> listOpp = WGC_AllDataFactory.createOpportunity2(2);
        listOpp.get(0).AccountId = a.Id;
        
        insert listOpp;
        
        List<Task> listTask = WGC_AllDataFactory.createTask(1);
        listTask.get(0).WhoId = c.Id;
        listTask.get(0).WhatId = c.AccountId;
        insert listTask;

    
        // Opportunity o = WGC_AllDataFactory.createOpportunity(2,true).get(0);
        
        // Account a = [SELECT Id,WGC_Specialista_Factoring__c, WGC_Qualifica_Corporate__c FROM Account Limit 1];
        // a.WGC_Specialista_Factoring__c = UserInfo.getUserId() ;
        // a.WGC_Qualifica_Corporate__c = 'Cliente Attivo';
        // update a;
        // Event e = WGC_AllDataFactory.createEvent2(1);
        //insert o;

        Test.startTest();
        WGC_BestPractice_Controller.callBestPractice();
        Test.stopTest();
        
    }

    @isTest
    public static void test_metodo3(){
        

        WGC_AllDataFactory.createUtenzaDefault();
        List<WGC_New_Business__c> bp = WGC_AllDataFactory.createNewBusiness(5,false);
        List<Account> acc = WGC_AllDataFactory.createAccount(1, false);
        acc.get(0).WGC_StatoAnagraficaCed__c = 'Cliente Attivo';

        insert acc;

        User u = [SELECT Id, Name, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];

        for(Integer i = 0; i < bp.size(); i++){
            
            bp[i].Anagrafica__c = acc.get(0).Id;
            bp[i].NDG_Settorista__c = u.NDGGruppo__c;

            if(Math.mod(i, 2) == 0){
                bp[i].Data_New_Business__c = System.Today().addYears(-1);
            }
            else{
                bp[i].Data_New_Business__c = System.Today();
            }
        }

        System.debug('@@@ bp ' + JSON.serialize(bp));

        insert bp;

        // NDG_Settorista__c =: user.NDGGruppo__c AND NDG_Settorista__c != '' 
        //                         AND (Anagrafica__r.WGC_StatoAnagraficaCed__c IN ('Cliente Attivo', 'Prospect')
        //                             OR (Anagrafica__r.WGC_StatoAnagraficaCed__c = 'Ex Cliente' 
        //                             AND  Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c >= LAST_N_YEARS:2))
        //                         AND Data_New_Business__c >= LAST_N_YEARS:2 

        Test.startTest();
        WGC_BestPractice_Controller.callBestPractice();
        Test.stopTest();
    }

}