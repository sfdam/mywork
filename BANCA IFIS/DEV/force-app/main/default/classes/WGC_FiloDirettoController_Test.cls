@isTest
public with sharing class WGC_FiloDirettoController_Test {
    /*@isTest
    public static void Test_WGC_FiloDirettoController(){
        WGC_AllDataFactory.disattivaTrigger();
        List<User> listUser = WGC_AllDataFactory.createUSer(3,true);
        List<Task> listTask = WGC_AllDataFactory.createTask(10,true);
        List<Contact> listContact = WGC_AllDataFactory.createContact(1,true);
        List<Campaign> listCampaign = WGC_AllDataFactory.createCampaign(15,true);
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        List<Account> listAcc = WGC_AllDataFactory.createAccount(1,true);
        List<Event> listEvent = WGC_AllDataFactory.createEvent(1,true);
        Comune__C comune = WGC_AllDataFactory.createComune('Roma','RM','00100');
        String sUser = '['+JSON.serialize(listUser.get(0))+','
                            +JSON.serialize(listUser.get(1))+','
                            +JSON.serialize(listUser.get(2))+']';
        listEvent.get(0).Id = null;
        String strEvent = JSON.serialize(listEvent.get(0));

        Test.startTest();
        WGC_FiloDirettoController.getTasks();
        WGC_FiloDirettoController.generaTaskInbound(listContact.get(0).Id);
        WGC_FiloDirettoController.getCampaign();
        WGC_FiloDirettoController.getContactInformation(listTask.get(0).Id);
        //WGC_FiloDirettoController.getPicklistValues(listTask.get(0).RecordTypeId);
        WGC_FiloDirettoController.getAssegnatari(listAcc.get(0).Id,comune.Id);
        WGC_FiloDirettoController.getVisite(Date.today(),sUser);
        //WGC_FiloDirettoController.saveTask();
        WGC_FiloDirettoController.saveVisita(strEvent);
        Test.stopTest();
    }

    @isTest
    public static void Test_WGC_FiloDirettoController(){
        //WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createUtenzaDefault();
        
        List<User> listUser = WGC_AllDataFactory.createUSer(3,true);
        List<Task> listTask = WGC_AllDataFactory.createTask(10,true);
        String strTask = JSON.serialize(listTask.get(0));
        List<Contact> listContact = WGC_AllDataFactory.createContact(1,true);
        List<Campaign> listCampaign = WGC_AllDataFactory.createCampaign(15,true);
        List<Account> listAcc = [SELECT Id,Name FROM Account LIMIT 1];
        
        Comune__C comune = WGC_AllDataFactory.createComune('Roma','RM','00100');
        String sUser = JSON.serialize(listUser);
        
       
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_FiloDirettoController.getTasks();
        //WGC_FiloDirettoController.generaTaskInbound(listContact.get(0).Id);
        WGC_FiloDirettoController.updateTaskCampaign(strTask);

        //WGC_FiloDirettoController.getCampaign();
        WGC_FiloDirettoController.getContactInformation(listTask.get(0).Id);
        //WGC_FiloDirettoController.getPicklistValues('Contatto Telefonico - Commercial Lending');
        WGC_FiloDirettoController.getAssegnatari(listAcc.get(0).Id,comune.Id);
        WGC_FiloDirettoController.getVisite(Date.today(),sUser);
        //WGC_FiloDirettoController.saveTask();
        
       
        Test.stopTest();
    }
    @isTest
    public static void Test_WGC_FiloDirettoController2(){
        //WGC_AllDataFactory.disattivaTrigger();
        WGC_AllDataFactory.createUtenzaDefault();
        
        List<Contact> listContact = WGC_AllDataFactory.createContact(1,true);
        
        List<Account> listAcc = [SELECT Id,Name FROM Account LIMIT 1];
        List<Event> listEvent = WGC_AllDataFactory.createEvent(1,true);
        Comune__C comune = WGC_AllDataFactory.createComune('Roma','RM','00100');
        
        String strEvent = JSON.serialize(listEvent.get(0));
        Event e = listEvent.get(0);

        System.debug('Query: '+[SELECT Id, Name, Email, ManagerId, Manager.Email FROM User WHERE Id = :e.OwnerId]);
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        
        WGC_FiloDirettoController.updateTaskCampaign(strEvent);
        WGC_FiloDirettoController.saveVisita(strEvent);
        
        //WGC_FiloDirettoController.inviaMail(listEvent.get(0));
        Test.stopTest();
    }*/
    @isTest
    public static void Test_WGC_FiloDirettoController_Task(){
        WGC_AllDataFactory.createUtenzaDefault();
       
        List<Campaign> listCampaign = WGC_AllDataFactory.createCampaign(10,true);
        Task t = WGC_AllDataFactory.createTask(1,true).get(0);
        // Task t = [SELECT Id,Status,DiFiloDiretto__c,RecordTypeId,RecordType.DeveloperName FROM Task LIMIT 1];
        
        Contact c = [SELECT Id,LastName,AccountId FROM Contact LIMIT 1];
        
        Account a = [SELECT Id,Name FROM Account LIMIT 1];
        
        t.Campagna__c = listCampaign.get(0).Id;
        String strTask = JSON.serialize(t);
        Comune__C comune = WGC_AllDataFactory.createComune('Roma','RM','00100');
        Comune__C com = [SELECT Id,Name FROM Comune__C LIMIT 1];

        
        Test.startTest();
        WGC_FiloDirettoController.getTasks(); // Manca il campo DiFiloDiretto__c sui task
        WGC_FiloDirettoController.updateTaskCampaign(strTask);
        WGC_FiloDirettoController.updateTaskCampaign('strTask');
        WGC_FiloDirettoController.getContactInformation(t.Id);
        WGC_FiloDirettoController.getAssegnatari(a.Id, com.Id);

        // Map<String,Object> m = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(listTask.get(0)));
        // Map<String,String> m2 = new Map<String,String>();

        // for(String key : m.keySet()){
        //     m2.put(key, String.valueOf(m.get(key)));
        // }

        // WGC_FiloDirettoController.saveTask(m2);

        WGC_FiloDirettoController.saveTask(t);

        Task t1=[SELECT Id, WhatId FROM Task WHERE EsitoLivello1__c = null AND WhatId =: c.AccountId];
        //delete t1;
        WGC_FiloDirettoController.getTaskData(t1.Id);
        WGC_FiloDirettoController.generaTaskInbound(c.Id);
        Map<String,String> labels = WGC_FiloDirettoController.getObjectLabels('Task');
        Test.stopTest();

    }
    @isTest
    public static void Test_saveTask2(){
        WGC_AllDataFactory.createUtenzaDefault();
        UserRole ur =[SELECT DeveloperName,Id FROM UserRole WHERE DeveloperName = 'ResponsabileFiloDiretto'];
        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Direzione Commerciale']; 
        User u = new User(Alias = 'TestIFIS', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com');
        u.UserRole=ur;
        insert u;

        System.debug('role: '+u.UserRole.DeveloperName);
        System.runAs(u) {
            Test.startTest();
            Task t = WGC_AllDataFactory.createTask(1).get(0);
            List<Campaign> listCampaign = WGC_AllDataFactory.createCampaign(10,true);
            WGC_FiloDirettoController.saveTask(t);
            WGC_FiloDirettoController.getTasks();
            WGC_FiloDirettoController.getTasks(0,25);
            WGC_FiloDirettoController.filterTask(true, true, '1. Web', '', '',  1, 25);
            Test.stopTest();
        }
    }
    @isTest
    public static void Test_WGC_FiloDirettoController_Campaign(){
        WGC_AllDataFactory.createUtenzaDefault();
        List<Campaign> listCampaign = WGC_AllDataFactory.createCampaign(10,true);
        List<Task> listTask = WGC_AllDataFactory.createTask(1);
        List<Account> accList = WGC_AllDataFactory.createAccount(1);

        Insert accList;

        for(Task t : listTask){
            t.Campagna__c = listCampaign[0].Id;
            t.WhatId = accList[0].Id;
        }

        Insert listTask;

        Test.startTest();
        WGC_FiloDirettoController.getCampaign();
        Test.stopTest();

    }

    @isTest
    public static void Test_WGC_FiloDirettoController_Mock(){
        Id recordTypeID1 = [SELECT Id FROM RecordType WHERE DeveloperName = 'ContattoTelefonicoDiretto'].Id;
        Test.setMock(HttpCalloutMock.class, new WGC_HttpRequestController_MockImpl());
        Test.startTest();
        WGC_FiloDirettoController.getPicklistValues(recordTypeID1);
        Test.stopTest();

    }

    @isTest
    public static void Test_WGC_FiloDirettoController_Event1(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createImpostazioni();
        List<Event> listEvent = WGC_AllDataFactory.createEvent(3,true);
        List<User> lstUSer = WGC_AllDataFactory.createUser(3,true);
        String strLstUSer = JSON.serialize(lstUSer);
        
        Date d = Date.today();
        Test.startTest();
        WGC_FiloDirettoController.getVisite(d,strLstUSer); 
        
        Test.stopTest();

    }
    @isTest
    public static void Test_WGC_FiloDirettoController_Event2(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createImpostazioni();

        UserRole ur =[SELECT DeveloperName,Id FROM UserRole WHERE DeveloperName = 'ResponsabileFiloDiretto'];
        Profile p = [SELECT Id FROM Profile WHERE Name='IFIS - Direzione Commerciale']; 
        User u = new User(Alias = 'TestIFIS', Email='TestIFIS@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='TestIFIS@testorg.com', Qualifica_Utente__c = 'Sviluppo_Commerciale_Filiali');
        u.UserRole=ur;
        insert u;

        List<Account> accList = WGC_AllDataFactory.createAccount(1);
        Insert accList;
        
        List<Event> eList = WGC_AllDataFactory.createEvent(1);
        eList[0].OwnerId = u.Id;
        eList[0].WhatId = accList[0].Id;
        String strEvent = JSON.serialize(eList[0]);

        List<Task> tList = WGC_AllDataFactory.createTask(1);
        Insert tList;

        // List<Task> tList = new List<Task>([SELECT Id, Subject, OwnerId, WhatId, TipoAttivita__c, EsitoLivello1__c, EsitoLivello2__c, ActivityDate, Campagna__c FROM Task WHERE DiFiloDiretto__c = true AND Status = 'Aperto']);
        
        Test.startTest(); 
        WGC_FiloDirettoController.WrapperResponse wp = WGC_FiloDirettoController.saveVisita(strEvent, tList[0]);
        Integer i = WGC_FiloDirettoController.numeroTaskFD(true, false, '1. Web', '', 'CT_Oggi');
        Integer i2 = WGC_FiloDirettoController.numeroTaskFD(false, true, '1. Web', '', 'CT_Scaduti');
        Test.stopTest();
        System.debug('WP: '+wp);

    }

    @isTest
    public static void Test_Task_Originator(){
        WGC_AllDataFactory.createUtenzaDefault();
        WGC_AllDataFactory.createImpostazioni();

        List<Task> taskList = WGC_AlldataFactory.createTask(2);
        List<Event> eventList = WGC_AlldataFactory.createEvent(1);
        List<Opportunity> oppList = WGC_AllDataFactory.createOpportunity2(1);
        List<Account> accList = WGC_AllDataFactory.createAccount(1, true);

        for(Opportunity opp : oppList){
            opp.AccountId = accList[0].Id;
        }

        Task t = taskList.get(0);
        t.WhatId = accList.get(0).Id;
        // t.CreatedDate = System.Today();
        t.WGC_Forzatura__c = false;

        insert t;
        
        eventList[0].WhatId = oppList[0].AccountId = accList[0].Id;
        eventList[0].Originator__c = oppList[0].Originator__c = 'Diretto';
        eventList[0].Originator_di_dettaglio__c = oppList[0].Originator_di_dettaglio__c = 'Rete Commerciale Italia';

        taskList[1].WhatId = accList[0].Id;
        oppList[0].Tipologia_Opportunit__c = 'CONC';
        insert oppList;
        insert eventList;

        WGC_TrgActivity.excuteInTest = true;
        
        List<Task> copyT = new List<Task>();
        copyT.add(taskList[1]);

        insert copyT;
        
    }

}