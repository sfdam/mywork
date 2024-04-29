@isTest 
private class TXT_FastManagerController_Test {
    @testSetup static void setup() {
        Funzionalita__c x= new Funzionalita__c();
        x.Disabilita_tutti_i_trigger__c=true;
        x.Bypass_Validation_Rules__c = true;
        insert x;
        
        /*user us = TestDataFactory.create_User(UserInfo.getProfileId());
        insert us;*/
        
       List<Account> accList = TestDataFactory.createAccounts(1);   
        accList[0].Codice_fiscale__c = '29384729837';
       	accList[0].Partita_iva__c = '29384729837';
        accList[0].Stato__c = 'Prospect';
        insert accList;
        
        List<Lead> leadList = TestDataFactory.createLeadsInnolva(1);   
        leadList[0].Codice_Fiscale__c = '29384729837';
       	leadList[0].Partiva_Iva__c = '29384729837';
        insert leadList;
        
        // List<Coverage_Team_Member__c> ctmList = new List<Coverage_Team_Member__c>();
        //     ctmList = TestDataFactory.createCoverageTeamMember(accList);
        //         ctmList[0].Ruolo_Coverage_Team__c = 'Responsabile account';
        // insert ctmList;

       List<Event> eventList = TestDataFactory.createEvent(accList);
        insert eventList;
       List<Task> taskList =TestDataFactory.createTask(accList);
        insert taskList;
       List<Opportunity> oppList = TestDataFactory.createOpportunity(accList);
        insert oppList;
        
        /*List<Coverage_Team_Member__c> ctmList = TestDataFactory.createCoverageTeamMember(accList);
        insert ctmList;*/
        
        x.Disabilita_tutti_i_trigger__c=false;
        update x;        
    }
    
    @isTest static void testGetDataList(){
        
        

        TXT_FastManagerController.WrapperObj wrap = new TXT_FastManagerController.WrapperObj();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];

        List<Coverage_Team_Member__c> ctmList = new List<Coverage_Team_Member__c>();


        Test.startTest();
        Funzionalita__c x= [select id from Funzionalita__c ];
        x.Disabilita_tutti_i_trigger__c=true;
        x.Disabilita_Integrazione__c = false;
        x.Disabilita_tutti_i_process_builder__c = true;
        x.Disabilita_tutti_i_workflow__c = true;
        update x;
        
        /*ctmList = TestDataFactory.createCoverageTeamMember(accList);
            ctmList[0].Ruolo_Coverage_Team__c = 'Responsabile account';
        Test.stopTest();*/

        
        //User current = [SELECT Id FROM User LIMIT 1];
        
        /*System.runAs(current){*/
            //insert ctmList;

            List<Lead> leadList = [SELECT Id FROM Lead LIMIT 1];
            User u = TXT_FastManagerController.getUserInfo();
            TXT_FastManager_User__c FMU = new TXT_FastManager_User__c();

            FMU.Richiesta_Approvatore__c = u.Id;
            FMU.Richiesta_Approvatore_Account__c = u.Id;
            insert FMU;
    
            wrap = TXT_FastManagerController.getDataList('29384729837', '29384729837', 'Innolva', 'tutte società');
            wrap = TXT_FastManagerController.getDataList('', '29384729837', 'Innolva', 'tutte società');
            wrap = TXT_FastManagerController.getDataList('29384729837', '', 'Innolva', 'singola societa');
                Task taskAcc = TXT_FastManagerController.createNewTask(u, accList[0].Id, 'Account', null, 'test');
            Task taskLead = TXT_FastManagerController.createNewTask(u, leadList[0].Id, 'Lead', null, 'test');
        //}
    }

    @isTest 
    static void testUserHasAccessToRecord(){
        List<Account> listAcc = TestDataFactory.createAccounts(1);
        insert listAcc;

    Test.startTest();
    Boolean acces = TXT_FastManagerController.userHasAccessToRecord(listAcc[0].id);

    Test.stopTest();

    }



    @isTest //(SeeAllData=true)
    static void testSection (){
        
        User newUser = TestDataFactory.create_User(UserInfo.getProfileId());
        newUser.Username = 'ten@tinexta.it.testclass';
        newUser.Macro_Area_FastManager__c = 'Direzione Sales e Marketing di Gruppo';
        newUser.Tinexta__c = false;
        insert newUser; 

        System.runAs(newUser){ 
            List<Account> listAcc = TestDataFactory.createAccounts(1);
            insert listAcc;
    
            List<Coverage_Team_Member__c> listCoverage = TestDataFactory.createCoverageTeamMember(listAcc);
            insert listCoverage;
    
            List<Opportunity> listOpp = TestDataFactory.createOpportunity(listAcc);
            insert listOpp;

            Test.startTest();

            Map<String,Object> mapVisibility = TXT_FastManagerController.getVisibilitaSection();

            for (String KeyMap : mapVisibility.keySet()){
                if(KeyMap=='metadati'){
                    List<Area_Visibilita_FastManager__mdt> obj =(List<Area_Visibilita_FastManager__mdt>)mapVisibility.get(KeyMap);

                    
                    for(Area_Visibilita_FastManager__mdt meta : obj){
                        List<String> listField = meta.fields__c.split(';');

                        if(meta.objectName__c != 'Account'){
                            TXT_FastManagerController.recuperoDati(meta.objectName__c, listField, listAcc[0].id);
                        }
                    }

                
                }
            }

            TXT_FastManagerController.recuperaNomeUser(UserInfo.getUserId());
            
            Test.stopTest();

        }
    }
}