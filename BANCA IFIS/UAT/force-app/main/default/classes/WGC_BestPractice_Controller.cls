public class WGC_BestPractice_Controller {

    @AuraEnabled
    public static WrapperResponse callBestPractice(){

        Id profileId = userinfo.getProfileId();
        User user = [ SELECT Id, NDGGruppo__c FROM User WHERE Id =: UserInfo.getUserId()];
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;

        WrapperResponse result = new WrapperResponse();
        WrapperRecords records = new WrapperRecords();
        
        try{

            Map<String, SObject> cMap = U.keyBy([
                    SELECT Id, OwnerId, LastModifiedDate, Redemption_Dettaglio__c, Convertion_Dettaglio__c, T0_Dettaglio__c, T1_Dettaglio__c, Qualita_Dettaglio__c, 
                                                            Year__c, Week__c, Month__c, Task__c, Visite__c, Opportunita__c, Clienti_Attivati__c, Prodotti_venduti__c 
                    FROM WGC_Best_Practice__c
                    WHERE OwnerId =: UserInfo.getUserId()
                    ORDER BY Week__c
                    LIMIT 7
            ], 'Week__c');

            System.debug('SV BEST PRACTICE MAP: ' + cMap);

            if(cMap.size() == 7){
                System.debug('SV DENTRO == 7');
                DateTime lastMod = (DateTime)cMap.get('1').get('LastModifiedDate');
                if(Date.newinstance(lastMod.year(), lastMod.month(), lastMod.day()) == 
                    Date.newinstance(Date.today().year(), Date.today().month(), Date.today().day())){
                    result.success = true; 
                    result.msg = 'BEST PRACTICE AGGIORNATA';
                    return result;
                }
            } 

            if(cMap.size() < 7){
                System.debug('SV DENTRO < 7');
                List<WGC_Best_Practice__c> bpList = new List<WGC_Best_Practice__c>();
                if(!cMap.containsKey('1')){
                    System.debug('SV DENTRO 1');
                    WGC_Best_Practice__c bp1 = new WGC_Best_Practice__c();
                    bp1.Redemption_Dettaglio__c = 0;
                    bp1.Convertion_Dettaglio__c = 0;
                    bp1.Qualita_Dettaglio__c = 0;
                    bp1.T0_Dettaglio__c = 0;
                    bp1.T1_Dettaglio__c = 0;
                    bp1.Task__c = 0;
                    bp1.Visite__c = 0;
                    bp1.Opportunita__c = 0;
                    bp1.Clienti_Attivati__c = 0;
                    bp1.Prodotti_venduti__c = 0;
                    bp1.Month__c = String.valueOf(Date.today().month());
                    bp1.Week__c = '1';
                    bpList.add(bp1);
                    cMap.put('1', bp1);
                }
                if(!cMap.containsKey('2')){
                    WGC_Best_Practice__c bp2 = new WGC_Best_Practice__c();
                    bp2.Redemption_Dettaglio__c = 0;
                    bp2.Convertion_Dettaglio__c = 0;
                    bp2.Qualita_Dettaglio__c = 0;
                    bp2.T0_Dettaglio__c = 0;
                    bp2.T1_Dettaglio__c = 0;
                    bp2.Task__c = 0;
                    bp2.Visite__c = 0;
                    bp2.Opportunita__c = 0;
                    bp2.Clienti_Attivati__c = 0;
                    bp2.Prodotti_venduti__c = 0;
                    bp2.Month__c = String.valueOf(Date.today().month());
                    bp2.Week__c = '2';
                    bpList.add(bp2);
                    cMap.put('2', bp2);
                }
                if(!cMap.containsKey('3')){
                    WGC_Best_Practice__c bp3 = new WGC_Best_Practice__c();
                    bp3.Redemption_Dettaglio__c = 0;
                    bp3.Convertion_Dettaglio__c = 0;
                    bp3.Qualita_Dettaglio__c = 0;
                    bp3.T0_Dettaglio__c = 0;
                    bp3.T1_Dettaglio__c = 0;
                    bp3.Task__c = 0;
                    bp3.Visite__c = 0;
                    bp3.Opportunita__c = 0;
                    bp3.Clienti_Attivati__c = 0;
                    bp3.Prodotti_venduti__c = 0;
                    bp3.Month__c = String.valueOf(Date.today().month());
                    bp3.Week__c = '3';
                    bpList.add(bp3);
                    cMap.put('3', bp3);
                }
                if(!cMap.containsKey('4')){
                    WGC_Best_Practice__c bp4 = new WGC_Best_Practice__c();
                    bp4.Redemption_Dettaglio__c = 0;
                    bp4.Convertion_Dettaglio__c = 0;
                    bp4.Qualita_Dettaglio__c = 0;
                    bp4.T0_Dettaglio__c = 0;
                    bp4.T1_Dettaglio__c = 0;
                    bp4.Task__c = 0;
                    bp4.Visite__c = 0;
                    bp4.Opportunita__c = 0;
                    bp4.Clienti_Attivati__c = 0;
                    bp4.Prodotti_venduti__c = 0;
                    bp4.Month__c = String.valueOf(Date.today().month());
                    bp4.Week__c = '4';
                    bpList.add(bp4);
                    cMap.put('4', bp4);
                }
                if(!cMap.containsKey('5')){
                    WGC_Best_Practice__c bp5 = new WGC_Best_Practice__c();
                    bp5.Redemption_Dettaglio__c = 0;
                    bp5.Convertion_Dettaglio__c = 0;
                    bp5.Qualita_Dettaglio__c = 0;
                    bp5.T0_Dettaglio__c = 0;
                    bp5.T1_Dettaglio__c = 0;
                    bp5.Task__c = 0;
                    bp5.Visite__c = 0;
                    bp5.Opportunita__c = 0;
                    bp5.Clienti_Attivati__c = 0;
                    bp5.Prodotti_venduti__c = 0;
                    bp5.Month__c = String.valueOf(Date.today().month());
                    bp5.Week__c = '5';
                    bpList.add(bp5);
                    cMap.put('5', bp5);
                }
                if(!cMap.containsKey('0')){
                    WGC_Best_Practice__c bpx = new WGC_Best_Practice__c();
                    bpx.Redemption_Dettaglio__c = 0;
                    bpx.Convertion_Dettaglio__c = 0;
                    bpx.Qualita_Dettaglio__c = 0;
                    bpx.T0_Dettaglio__c = 0;
                    bpx.T1_Dettaglio__c = 0;
                    bpx.Task__c = 0;
                    bpx.Visite__c = 0;
                    bpx.Opportunita__c = 0;
                    bpx.Clienti_Attivati__c = 0;
                    bpx.Prodotti_venduti__c = 0;
                    bpx.Week__c = '0';
                    bpx.Year__c = 'Corrente';
                    bpList.add(bpx);
                    cMap.put('0', bpx);
                }
                if(!cMap.containsKey('-1')){
                    WGC_Best_Practice__c bpx_1 = new WGC_Best_Practice__c();
                    bpx_1.Redemption_Dettaglio__c = 0;
                    bpx_1.Convertion_Dettaglio__c = 0;
                    bpx_1.Qualita_Dettaglio__c = 0;
                    bpx_1.T0_Dettaglio__c = 0;
                    bpx_1.T1_Dettaglio__c = 0;
                    bpx_1.Task__c = 0;
                    bpx_1.Visite__c = 0;
                    bpx_1.Opportunita__c = 0;
                    bpx_1.Clienti_Attivati__c = 0;
                    bpx_1.Prodotti_venduti__c = 0;
                    bpx_1.Week__c = '-1';
                    bpx_1.Year__c = 'Precedente';
                    bpList.add(bpx_1);
                    cMap.put('-1', bpx_1);
                }

                insert bpList;
                System.debug('SV BEST PRACTICE bpList: ' + bpList);
            }

            System.debug('SV BEST PRACTICE MAP AFTER: ' + cMap);

            List<WGC_New_Business__c> accList = new List<WGC_New_Business__c>();
            if(profileName.contains('Filo Diretto')){
                accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c   
                            FROM WGC_New_Business__c
                            WHERE NDG_Filo_Diretto__c =: user.NDGGruppo__c AND
                                Data_New_Business__c >= LAST_N_YEARS:2 ];
            } else {
                accList = [ SELECT Id, Anagrafica__r.Id, Anagrafica__r.Name, Anagrafica__r.StatoCensimento__c, Anagrafica__r.WGC_Qualifica_Corporate__c, 
                                   Anagrafica__r.WGC_Specialista_Factoring__c, Anagrafica__r.WGC_Factoring_Attivo__c, Anagrafica__r.CreatedDate, 
                                   Anagrafica__r.WGC_Originator__c, Data_New_Business__c, Anagrafica__r.WGC_StatoAnagraficaCed__c, Anagrafica__r.WGC_Data_Ex_Cliente_SvilCommFiliali__c   
                            FROM WGC_New_Business__c
                            WHERE NDG_Settorista__c =: user.NDGGruppo__c AND NDG_Settorista__c != ''
                                AND Data_New_Business__c >= LAST_N_YEARS:2 ];                
            }
            System.debug('accList: '+accList);
            List<Opportunity> oppList = new List<Opportunity>();
            if(profileName.contains('Filo Diretto')){

            } else {
                oppList = [ SELECT Id, AccountId, OwnerId, StageName, CreatedDate, Data_Inizio__c                                         
                            FROM Opportunity 
                            WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId()
                                AND OwnerId =: UserInfo.getUserId() 
                                AND Data_Inizio__c > LAST_N_YEARS:2 ];
            }
            System.debug('oppList: '+oppList);
            List<Event> eventList = new List<Event>();
            if(profileName.contains('Filo Diretto')){
                eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, Originator__c, WGC_Macro_Esito__c, CreatedDate, Data_Inizio__c                                              
                              FROM Event 
                              WHERE Account.WGC_Specialista_Filo_Diretto__c =: UserInfo.getUserId() 
                                AND Account.WGC_Filo_Diretto_Attivo__c = TRUE
                                AND CreatoDaFiloDiretto__c = TRUE
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND CreatedDate > LAST_N_YEARS:2 ];
            } else {
                eventList = [ SELECT Id, AccountId, OwnerId, Stato__c, CreatedDate, Data_Inizio__c                                                          
                              FROM Event 
                              WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId()
                                AND OwnerId =: UserInfo.getUserId() 
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND Data_Inizio__c > LAST_N_YEARS:2 ];                
            }
            System.debug('eventList: '+eventList);
            List<Task> taskList = new List<Task>();
            if(profileName.contains('Filo Diretto')){
                // taskList = [ SELECT Id, AccountId, OwnerId, Stato__c, CreatedDate, RecordType.DeveloperName, Data_Inizio__c                       
                //              FROM Task 
                //              WHERE Account.WGC_Specialista_Filo_Diretto__c =: UserInfo.getUserId() 
                //                 AND Account.WGC_Filo_Diretto_Attivo__c = TRUE
                //                 AND CreatoDaFiloDiretto__c = TRUE
                //                 AND RecordType.DeveloperName != 'Promemoria'
                //                 AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                //                 AND Data_Inizio__c > LAST_N_YEARS:2 ];

            } else {
                taskList = [ SELECT Id, AccountId, OwnerId, Stato__c, CreatedDate, RecordType.DeveloperName, Data_Inizio__c                       
                             FROM Task 
                             WHERE Account.WGC_Specialista_Factoring__c =: UserInfo.getUserId() 
                                AND OwnerId =: UserInfo.getUserId()
                                AND RecordType.DeveloperName != 'Promemoria'
                                AND (NOT RecordType.DeveloperName LIKE '%Diario%')
                                AND Data_Inizio__c > LAST_N_YEARS:2 ];
                
            }
            System.debug('taskList: '+taskList);
            // component.set('v.redemption', clientiAvviati / (taskApertoDiretto + taskAperto));
		    // component.set('v.convertion', clientiAvviati / (evnApertoDiretto + evnAperto));
		    // component.set('v.qualita', (oppInRedazioneContrattiDiretto + oppInRedazioneContratti) / (oppInValutazionePraticaDiretto + oppInValutazionePratica));
            
            List<WGC_Linea_Prodotto__c> productList = new List<WGC_Linea_Prodotto__c>();
            if(profileName.contains('Filo Diretto')){
                productList = [ SELECT Id, NDG_Filo_Diretto__c, Anagrafica__c, Data_attivazione_linea__c, Data_Ultima_Cessione__c                                              
                              FROM WGC_Linea_Prodotto__c 
                              WHERE NDG_Filo_Diretto__c =: user.NDGGruppo__c
                                AND Data_attivazione_linea__c > LAST_N_YEARS:2 ];
            } else {
                
            }
            System.debug('productList: '+productList);

            Integer clientiAvviatiThisYear = 0;
            Integer clientiAvviatiLastYear = 0;
            Integer clientiAvviati1 = 0;
            Integer clientiAvviati2 = 0;
            Integer clientiAvviati3 = 0;
            Integer clientiAvviati4 = 0;
            Integer clientiAvviati5 = 0;
            Set<Id> clientiIdThisYear = new Set<Id>();
            Set<Id> clientiIdLastYear = new Set<Id>();
            for(WGC_New_Business__c acc : accList){
                Date create = Date.newinstance(acc.Data_New_Business__c.year(), acc.Data_New_Business__c.month(), acc.Data_New_Business__c.day());
                if(acc.Data_New_Business__c.year() == Date.today().year()){
                    if(acc.Data_New_Business__c.month() == Date.today().month()){
                        if(currentWeekOfMonth(create) == 1) clientiAvviati1++;
                        if(currentWeekOfMonth(create) == 2) clientiAvviati2++;
                        if(currentWeekOfMonth(create) == 3) clientiAvviati3++;
                        if(currentWeekOfMonth(create) == 4) clientiAvviati4++;
                        if(currentWeekOfMonth(create) == 5) clientiAvviati5++;
                    }
                    if(!clientiIdThisYear.contains(acc.Id)){
                        clientiIdThisYear.add(acc.Id);
                        clientiAvviatiThisYear++;
                    }
                } else {
                    if(!clientiIdLastYear.contains(acc.Id)){
                        clientiIdLastYear.add(acc.Id);
                        clientiAvviatiLastYear++;
                    }   
                }
            }
            List<Integer> clientiAvviatiMonth = new List<Integer>{clientiAvviati1, clientiAvviati2, clientiAvviati3, clientiAvviati4, clientiAvviati5};

            Integer taskThisYearNB = 0;
            Integer taskLastYearNB = 0;
            Integer taskThisYear = 0;
            Integer taskLastYear = 0;
            Integer task1 = 0;
            Integer task2 = 0;
            Integer task3 = 0;
            Integer task4 = 0;
            Integer task5 = 0;
            for(Task task : taskList){
                Date create = Date.newinstance(task.CreatedDate.year(), task.CreatedDate.month(), task.CreatedDate.day());
                if(task.CreatedDate.year() == Date.today().year()){
                    taskThisYearNB++;
                    if(task.CreatedDate.month() == Date.today().month()){
                        if(currentWeekOfMonth(create) == 1) task1++;
                        if(currentWeekOfMonth(create) == 2) task2++;
                        if(currentWeekOfMonth(create) == 3) task3++;
                        if(currentWeekOfMonth(create) == 4) task4++;
                        if(currentWeekOfMonth(create) == 5) task5++;
                    } 
                    if(!clientiIdThisYear.contains(task.AccountId)){
                        clientiIdThisYear.add(task.AccountId);
                        taskThisYear++;
                    }
                } else {
                    taskLastYearNB++;
                    if(!clientiIdLastYear.contains(task.AccountId)){
                        clientiIdLastYear.add(task.AccountId);
                        taskLastYear++;
                    }
                }
            }
            List<Integer> taskMonth = new List<Integer>{task1, task2, task3, task4, task5};

            Integer eventThisYearNB = 0;
            Integer eventLastYearNB = 0;
            Integer eventThisYear = 0;
            Integer eventLastYear = 0;
            Integer event1 = 0;
            Integer event2 = 0;
            Integer event3 = 0;
            Integer event4 = 0;
            Integer event5 = 0;
            for(Event event : eventList){
                if(profileName.contains('Filo Diretto')){
                    Date create = Date.newinstance(event.CreatedDate.year(), event.CreatedDate.month(), event.CreatedDate.day());
                    if(event.CreatedDate.year() == Date.today().year()){
                        eventThisYearNB++;
                        if(event.CreatedDate.month() == Date.today().month()){
                            if(currentWeekOfMonth(create) == 1) event1++;
                            if(currentWeekOfMonth(create) == 2) event2++;
                            if(currentWeekOfMonth(create) == 3) event3++;
                            if(currentWeekOfMonth(create) == 4) event4++;
                            if(currentWeekOfMonth(create) == 5) event5++;
                        } 
                        if(!clientiIdThisYear.contains(event.AccountId)){
                            clientiIdThisYear.add(event.AccountId);
                            eventThisYear++;
                        }
                    } else {
                        eventLastYearNB++;
                        if(!clientiIdLastYear.contains(event.AccountId)){
                            clientiIdLastYear.add(event.AccountId);
                            eventLastYear++;
                        }
                    }
                } else {
                    Date create = Date.newinstance(event.Data_Inizio__c.year(), event.Data_Inizio__c.month(), event.Data_Inizio__c.day());
                    if(event.Data_Inizio__c.year() == Date.today().year()){
                        eventThisYearNB++;
                        if(event.Data_Inizio__c.month() == Date.today().month()){
                            if(currentWeekOfMonth(create) == 1) event1++;
                            if(currentWeekOfMonth(create) == 2) event2++;
                            if(currentWeekOfMonth(create) == 3) event3++;
                            if(currentWeekOfMonth(create) == 4) event4++;
                            if(currentWeekOfMonth(create) == 5) event5++;
                        } 
                        if(!clientiIdThisYear.contains(event.AccountId)){
                            clientiIdThisYear.add(event.AccountId);
                            eventThisYear++;
                        }
                    } else {
                        eventLastYearNB++;
                        if(!clientiIdLastYear.contains(event.AccountId)){
                            clientiIdLastYear.add(event.AccountId);
                            eventLastYear++;
                        }
                    }                    
                }
                
            }
            List<Integer> eventMonth = new List<Integer>{event1, event2, event3, event4, event5};

            Integer oppInRedazioneContrattiThisYear  = 0;
            Integer oppInRedazioneContrattiLastYear  = 0;
            Integer oppInRedazioneContratti1 = 0;
            Integer oppInRedazioneContratti2 = 0;
            Integer oppInRedazioneContratti3 = 0;
            Integer oppInRedazioneContratti4 = 0;
            Integer oppInRedazioneContratti5 = 0;

            Integer oppInValutazionePraticaThisYear  = 0;
            Integer oppInValutazionePraticaLastYear  = 0;
            Integer oppInValutazionePratica1 = 0;
            Integer oppInValutazionePratica2 = 0;
            Integer oppInValutazionePratica3 = 0;
            Integer oppInValutazionePratica4 = 0;
            Integer oppInValutazionePratica5 = 0;

            Integer oppThisYear = 0;
            Integer oppLastYear = 0;
            Integer opp1 = 0;
            Integer opp2 = 0;
            Integer opp3 = 0;
            Integer opp4 = 0;
            Integer opp5 = 0;
            for(Opportunity opp : oppList){
                Date create = Date.newinstance(opp.Data_Inizio__c.year(), opp.Data_Inizio__c.month(), opp.Data_Inizio__c.day());
                if(opp.Data_Inizio__c.year() == Date.today().year()){
                    oppThisYear++;
                    if(opp.Data_Inizio__c.month() == Date.today().month()){
                        if(currentWeekOfMonth(create) == 1) opp1++;
                        if(currentWeekOfMonth(create) == 2) opp2++;
                        if(currentWeekOfMonth(create) == 3) opp3++;
                        if(currentWeekOfMonth(create) == 4) opp4++;
                        if(currentWeekOfMonth(create) == 5) opp5++;
                        if(opp.StageName.equals('Perfezionamento Contratto')){
                            if(currentWeekOfMonth(create) == 1) oppInRedazioneContratti1++;
                            if(currentWeekOfMonth(create) == 2) oppInRedazioneContratti2++;
                            if(currentWeekOfMonth(create) == 3) oppInRedazioneContratti3++;
                            if(currentWeekOfMonth(create) == 4) oppInRedazioneContratti4++;
                            if(currentWeekOfMonth(create) == 5) oppInRedazioneContratti5++;
                        } 
                        if(!opp.StageName.equals('In Istruttoria')){
                            if(currentWeekOfMonth(create) == 1) oppInValutazionePratica1++;
                            if(currentWeekOfMonth(create) == 2) oppInValutazionePratica2++;
                            if(currentWeekOfMonth(create) == 3) oppInValutazionePratica3++;
                            if(currentWeekOfMonth(create) == 4) oppInValutazionePratica4++;
                            if(currentWeekOfMonth(create) == 5) oppInValutazionePratica5++;
                        } 
                    } 
                    if(!clientiIdThisYear.contains(opp.AccountId)){
                        clientiIdThisYear.add(opp.AccountId);
                        if(opp.StageName.equals('Perfezionamento Contratto')){
                            oppInRedazioneContrattiThisYear++;
                        } 
                        if(!opp.StageName.equals('In Istruttoria')){
                            oppInValutazionePraticaThisYear++;
                        } 
                    }
                } else {
                    oppLastYear++;
                    if(!clientiIdLastYear.contains(opp.AccountId)){
                        clientiIdLastYear.add(opp.AccountId);
                        if(opp.StageName.equals('Perfezionamento Contratto')){
                            oppInRedazioneContrattiLastYear++;
                        } 
                        if(!opp.StageName.equals('In Istruttoria')){
                            oppInValutazionePraticaLastYear++;
                        } 
                    }
                }
            }
            List<Integer> oppMonth = new List<Integer>{opp1, opp2, opp3, opp4, opp5};

            Integer prodThisYear = 0;
            Integer prodLastYear = 0;
            Integer prod1 = 0;
            Integer prod2 = 0;
            Integer prod3 = 0;
            Integer prod4 = 0;
            Integer prod5 = 0;
            for(WGC_Linea_Prodotto__c prodotto : productList){
                Date create = Date.newinstance(prodotto.Data_attivazione_linea__c.year(), prodotto.Data_attivazione_linea__c.month(), prodotto.Data_attivazione_linea__c.day());
                if(prodotto.Data_attivazione_linea__c.year() == Date.today().year()){
                    prodThisYear++;
                    if(prodotto.Data_attivazione_linea__c.month() == Date.today().month()){
                        if(currentWeekOfMonth(create) == 1) prod1++;
                        if(currentWeekOfMonth(create) == 2) prod2++;
                        if(currentWeekOfMonth(create) == 3) prod3++;
                        if(currentWeekOfMonth(create) == 4) prod4++;
                        if(currentWeekOfMonth(create) == 5) prod5++;
                    }
                } else {
                    prodLastYear++;
                }
            }
            List<Integer> prodMonth = new List<Integer>{prod1, prod2, prod3, prod4, prod5};


            records.clientiAvviatiMonth = clientiAvviatiMonth;
            records.clientiAvviatiThisYear = clientiAvviatiThisYear;
            records.clientiAvviatiLastYear = clientiAvviatiLastYear;

            records.taskMonth = taskMonth;
            records.taskThisYear = taskThisYear;
            records.taskLastYear = taskLastYear;

            records.eventMonth = eventMonth;
            records.eventThisYear = eventThisYear;
            records.eventLastYear = eventLastYear;

            records.oppMonth = oppMonth;
            records.oppThisYear = oppThisYear;
            records.oppLastYear = oppLastYear;

            records.prodMonth = prodMonth;
            records.prodThisYear = prodThisYear;
            records.prodLastYear = prodLastYear;
            
            Decimal redemptionThisYear = (taskThisYear > 0) ? ((Decimal)clientiAvviatiThisYear / (Decimal)taskThisYear) * 100 : 0;
            Decimal redemptionLastYear = (taskLastYear > 0) ? ((Decimal)clientiAvviatiLastYear / (Decimal)taskLastYear) * 100 : 0;

            Decimal redemption1 = (task1 > 0) ? ((Decimal)clientiAvviati1 / (Decimal)task1) * 100 : 0;
            Decimal redemption2 = (task2 > 0) ? ((Decimal)clientiAvviati2 / (Decimal)task2) * 100 : 0;
            Decimal redemption3 = (task3 > 0) ? ((Decimal)clientiAvviati3 / (Decimal)task3) * 100 : 0;
            Decimal redemption4 = (task4 > 0) ? ((Decimal)clientiAvviati4 / (Decimal)task4) * 100 : 0;
            Decimal redemption5 = (task5 > 0) ? ((Decimal)clientiAvviati5 / (Decimal)task5) * 100 : 0;
            List<Decimal> redemptionMonth = new List<Decimal>{redemption1, redemption2, redemption3, redemption4, redemption5};

            Decimal convertionThisYear = (eventThisYear > 0) ? ((Decimal)clientiAvviatiThisYear / (Decimal)eventThisYear) * 100 : 0;
            Decimal convertionLastYear = (eventLastYear > 0) ? ((Decimal)clientiAvviatiLastYear / (Decimal)eventLastYear) * 100 : 0;

            Decimal convertion1 = (event1 > 0) ? ((Decimal)clientiAvviati1 / (Decimal)event1) * 100 : 0;
            Decimal convertion2 = (event2 > 0) ? ((Decimal)clientiAvviati2 / (Decimal)event2) * 100 : 0;
            Decimal convertion3 = (event3 > 0) ? ((Decimal)clientiAvviati3 / (Decimal)event3) * 100 : 0;
            Decimal convertion4 = (event4 > 0) ? ((Decimal)clientiAvviati4 / (Decimal)event4) * 100 : 0;
            Decimal convertion5 = (event5 > 0) ? ((Decimal)clientiAvviati5 / (Decimal)event5) * 100 : 0;
            List<Decimal> convertionMonth = new List<Decimal>{convertion1, convertion2, convertion3, convertion4, convertion5};

            Decimal qualitaThisYear = (oppInValutazionePraticaThisYear > 0) ? ((Decimal)oppInRedazioneContrattiThisYear / (Decimal)oppInValutazionePraticaThisYear) * 100 : 0;
            Decimal qualitaLastYear = (oppInValutazionePraticaLastYear > 0) ? ((Decimal)oppInRedazioneContrattiLastYear / (Decimal)oppInValutazionePraticaLastYear) * 100 : 0;

            Decimal qualita1 = (oppInValutazionePratica1 > 0) ? ((Decimal)oppInRedazioneContratti1 / (Decimal)oppInValutazionePratica1) * 100 : 0;
            Decimal qualita2 = (oppInValutazionePratica2 > 0) ? ((Decimal)oppInRedazioneContratti2 / (Decimal)oppInValutazionePratica2) * 100 : 0;
            Decimal qualita3 = (oppInValutazionePratica3 > 0) ? ((Decimal)oppInRedazioneContratti3 / (Decimal)oppInValutazionePratica3) * 100 : 0;
            Decimal qualita4 = (oppInValutazionePratica4 > 0) ? ((Decimal)oppInRedazioneContratti4 / (Decimal)oppInValutazionePratica4) * 100 : 0;
            Decimal qualita5 = (oppInValutazionePratica5 > 0) ? ((Decimal)oppInRedazioneContratti5 / (Decimal)oppInValutazionePratica5) * 100 : 0;
            List<Decimal> qualitaMonth = new List<Decimal>{qualita1, qualita2, qualita3, qualita4, qualita5};


            records.redemptionMonth = redemptionMonth;
            records.redemptionThisYear    = redemptionThisYear;
            records.redemptionLastYear    = redemptionLastYear;

            records.convertionMonth = convertionMonth;
            records.convertionThisYear    = convertionThisYear;
            records.convertionLastYear    = convertionLastYear;

            records.qualitaMonth   = qualitaMonth;
            records.qualitaThisYear    = qualitaThisYear;
            records.qualitaLastYear    = qualitaLastYear;

            records.week       = currentWeekOfMonth(Date.today());
            records.month      = Date.today().month();

            result.data.add(records);

            for (String week : cMap.keySet()) {
                SObject bp = cMap.get(week);
                System.debug('SV bp BEFORE: ' + bp);
                if(Integer.valueof(week) > 0){
                    bp.put('Redemption_Dettaglio__c', redemptionMonth.get(Integer.valueof(week) - 1));
                    bp.put('Convertion_Dettaglio__c', convertionMonth.get(Integer.valueof(week) - 1));
                    bp.put('Qualita_Dettaglio__c', qualitaMonth.get(Integer.valueof(week) - 1));
                    bp.put('T0_Dettaglio__c', 0);
                    bp.put('T1_Dettaglio__c', 0);
                    bp.put('Task__c', taskMonth.get(Integer.valueof(week) - 1));
                    bp.put('Visite__c', eventMonth.get(Integer.valueof(week) - 1));
                    bp.put('Opportunita__c',  oppMonth.get(Integer.valueof(week) - 1));
                    bp.put('Clienti_Attivati__c', clientiAvviatiMonth.get(Integer.valueof(week) - 1));
                    bp.put('Prodotti_venduti__c', prodMonth.get(Integer.valueof(week) - 1));
                    bp.put('Month__c', String.valueOf(Date.today().month()));
                } else {
                    if(Integer.valueof(week) == 0){
                        bp.put('Redemption_Dettaglio__c', redemptionThisYear);
                        bp.put('Convertion_Dettaglio__c', convertionThisYear);
                        bp.put('Qualita_Dettaglio__c', qualitaThisYear);
                        bp.put('T0_Dettaglio__c', 0);
                        bp.put('T1_Dettaglio__c', 0);
                        bp.put('Task__c', taskThisYearNB);
                        bp.put('Visite__c', eventThisYearNB);
                        bp.put('Opportunita__c',  oppThisYear);
                        bp.put('Clienti_Attivati__c', clientiAvviatiThisYear);
                        bp.put('Prodotti_venduti__c', prodThisYear);
                    } else {
                        bp.put('Redemption_Dettaglio__c', redemptionLastYear);
                        bp.put('Convertion_Dettaglio__c', convertionLastYear);
                        bp.put('Qualita_Dettaglio__c', qualitaLastYear);
                        bp.put('T0_Dettaglio__c', 0);
                        bp.put('T1_Dettaglio__c', 0);
                        bp.put('Task__c', taskLastYearNB);
                        bp.put('Visite__c', eventLastYearNB);
                        bp.put('Opportunita__c',  oppLastYear);
                        bp.put('Clienti_Attivati__c', clientiAvviatiLastYear);
                        bp.put('Prodotti_venduti__c', prodLastYear);
                    }
                }

                System.debug('SV bp AFTER: ' + bp);

                upsert bp;
            }

        } catch(exception e){
            result.success = false; 
            result.msg = e.getMessage();
        }

        return result;
    }

    /*..........................................*/
    /* Wrapper class to display Position       */
    /*.........................................*/
    
    public class WrapperRecords {
        @AuraEnabled public List<Decimal> clientiAvviatiMonth;
        @AuraEnabled public Decimal clientiAvviatiThisYear;
        @AuraEnabled public Decimal clientiAvviatiLastYear;

        @AuraEnabled public List<Decimal> taskMonth;
        @AuraEnabled public Decimal taskThisYear;
        @AuraEnabled public Decimal taskLastYear;

        @AuraEnabled public List<Decimal> eventMonth;
        @AuraEnabled public Decimal eventThisYear;
        @AuraEnabled public Decimal eventLastYear;

        @AuraEnabled public List<Decimal> oppMonth;
        @AuraEnabled public Decimal oppThisYear;
        @AuraEnabled public Decimal oppLastYear;

        @AuraEnabled public List<Decimal> prodMonth;
        @AuraEnabled public Decimal prodThisYear;
        @AuraEnabled public Decimal prodLastYear;

        @AuraEnabled public List<Decimal> redemptionMonth;
        @AuraEnabled public Decimal redemptionThisYear;
        @AuraEnabled public Decimal redemptionLastYear;

        @AuraEnabled public List<Decimal> convertionMonth;
        @AuraEnabled public Decimal convertionThisYear;
        @AuraEnabled public Decimal convertionLastYear;

        @AuraEnabled public List<Decimal> qualitaMonth;
        @AuraEnabled public Decimal qualitaThisYear;
        @AuraEnabled public Decimal qualitaLastYear;

        @AuraEnabled public Integer week;
        @AuraEnabled public Integer month;
    }

    /*..........................................*/
    /* Wrapper class to display Response       */
    /*.........................................*/
    
    public class WrapperResponse {
        
        @AuraEnabled public Boolean success;
        @AuraEnabled public String msg;
        @AuraEnabled public List<Object> data;
        
        public WrapperResponse(){
            success = true;
            msg = '';
            data = new List<Object>();
        }
    }

    public static Integer currentWeekOfMonth( Date todaysDate){
        Date currentDate = todaysDate;
        Integer weekCount = 0;
        Integer startWeekResidue = 0;
        Integer endWeekResidue = 0;
        Date dt = currentDate.toStartOfMonth().addDays(-1);
        Date dtFirstWeekend = dt.toStartOfWeek().addDays(6);
        startWeekResidue = dt.daysBetween(dtFirstWeekend); 
        Date dtLastWeekend = currentDate.toStartOfWeek().addDays(-1);
        endWeekResidue = dtLastWeekend.daysBetween(currentDate);
        weekCount = (currentDate.day() - (startWeekResidue + endWeekResidue))/7;
        weekCount += (startWeekResidue > 0 ? 1:0)+(endWeekResidue > 0 ? 1:0);
        return weekCount;
    }

}