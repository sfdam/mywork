public class WGC_HomePage_Sfida_Controller {

    @AuraEnabled
    public static WrapperResponse getAllData(){
        WrapperResponse response = new WrapperResponse();
        Result res = new Result();

        try{
            //Wrapper di appoggio per informazioni sull'utente
            WrapperUtente utente = new WrapperUtente();
            String nomeTeamU = '';

            List<WGC_Andamentale__c> allAndamentale = new List<WGC_Andamentale__c>();
            allAndamentale = [SELECT Id, Operatore__c, Operatore__r.Name, Data__c, CT_Budget__c, CT_Actual__c, VC_Budget__c, VC_Actual__c, Team__c FROM WGC_Andamentale__c WHERE Data__c = LAST_N_DAYS:6 AND Data__c <= TODAY ORDER BY Data__c ASC];
            System.debug('@@@ andamentale ' + JSON.serialize(allAndamentale));

            List<WGC_Andamentale__c> andamentaleMonth = new List<WGC_Andamentale__c>();
            andamentaleMonth = [SELECT Id, Operatore__c, Operatore__r.Name, Data__c, CT_Budget__c, CT_Actual__c, VC_Budget__c, VC_Actual__c, Team__c FROM WGC_Andamentale__c WHERE Data__c = THIS_MONTH];

            System.debug('@@@ andamentaleMonth ' + JSON.serialize(andamentaleMonth));

            List<WGC_Andamentale__c> andamentaleVariazione = new List<WGC_Andamentale__c>();
            andamentaleVariazione = [SELECT Id, Operatore__c, Operatore__r.Name, Data__c, CT_Budget__c, CT_Actual__c, VC_Budget__c, VC_Actual__c, Team__c FROM WGC_Andamentale__c WHERE Data__c = LAST_YEAR AND CALENDAR_MONTH(Data__c) =: System.Today().Month() ];

            System.debug('@@@ andamentaleVariazione ' + JSON.serialize(andamentaleVariazione));

            Decimal countVisiteVariazione = 0;
            for(WGC_Andamentale__c andamento : andamentaleVariazione){
                countVisiteVariazione += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
            }

            // List<Event> appuntamentiMese = new List<Event>();
            // appuntamentiMese = [SELECT Id, Subject, CreatoDaFiloDiretto__c, CreatedDate FROM Event WHERE CreatedDate = THIS_MONTH AND CreatoDaFiloDiretto__c = true];

            // List<Task> contattiMese = new List<Task>();
            // contattiMese = [SELECT Id, Subject, DiFiloDiretto__c FROM Task WHERE LastModifiedDate = THIS_MONTH AND DiFiloDiretto__c = true AND Status = 'Chiuso'];

            Decimal countContattiMese = 0;
            Decimal countAppuntamentiMese = 0;

            for(WGC_Andamentale__c andamento : andamentaleMonth){
                countContattiMese += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
                countAppuntamentiMese += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
            }

            //Recupero le info sui colori dei team
            List<WGC_Team_Filo_Diretto__mdt> teamXColore = new List<WGC_Team_Filo_Diretto__mdt>();
            teamXColore = [SELECT Id, MasterLabel, DeveloperName, Colore_Team__c FROM WGC_Team_Filo_Diretto__mdt];

            // List<Event> visiteOggi = new List<Event>();
            // for(Event e : appuntamentiMese){
            //     if(e.CreatedDate == System.Today()){
            //         visiteOggi.add(e);
            //     }
            // }

            Decimal countVisiteMese = 0;
            for(WGC_Andamentale__c andamento : andamentaleMonth){
                //if(andamento.Data__c == System.Today()){
                    countVisiteMese += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                //}
            }



            List<Date> dates = new List<Date>();
            for(WGC_Andamentale__c andamento : allAndamentale){
                dates.add(andamento.Data__c);
            }

            Set<Date> datesSet = new Set<Date>(dates);

            List<WGC_Andamentale__c> andamentaleOggi = new List<WGC_Andamentale__c>();
            Decimal countCTActual = 0;
            Decimal countVCActual = 0;

            for(WGC_Andamentale__c andamento : allAndamentale){
                andamentaleOggi.add(andamento);
                if(andamento.Data__c == System.Today()){
                    countCTActual += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
                    countVCActual += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                }
            }

            //Mi genero il wrapper dati per il grafico
            Map<String, List<WGC_Andamentale__c>> andamentaleXData = new Map<String, List<WGC_Andamentale__c>>();
            andamentaleXData = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(allAndamentale, 'Data__c');

            Map<String, List<GraphResult>> mappaFinal = new Map<String, List<GraphResult>>();
            List<GraphResult> gList = new List<GraphResult>();

            List<Decimal> successList = new List<Decimal>();

            for(String key : andamentaleXData.keySet()){
                Map<String, List<WGC_Andamentale__c>> temp = new Map<String, List<WGC_Andamentale__c>>();
                temp = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(andamentaleXData.get(key), 'Team__c');

                // Decimal countCTSuccess = 0;
                // Decimal countVCSuccess = 0;
                Decimal successoMedioGraph = 0;
                for(String team : temp.keySet()){
                    // gList.clear();
                    Decimal countVCGraph = 0;
                    Decimal countCTGraph = 0;
                    //Decimal myCountVCGraph = 0;
                    for(WGC_Andamentale__c andamento : temp.get(team)){
                        countVCGraph += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                        countCTGraph += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;

                        //Calcolo i dati per il successio medio del giorno
                        // countCTSuccess += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
                        // countVCSuccess += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                        
                        if(andamento.Operatore__c == UserInfo.getUserId()){
                            //myCountVCGraph += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                            // Popolo il wrapper con le info dell'utente
                            // utente.nomeTeam = andamento.Team__c;
                            nomeTeamU = andamento.Team__c;
                        }
                    }

                    String coloreTeam = '';
                    for(WGC_Team_Filo_Diretto__mdt teamC : teamXColore){
                        if(teamC.MasterLabel == team){
                            coloreTeam = teamC.Colore_Team__c;
                        }
                    }

                    Decimal success = countCTGraph > 0 ? ( (countVCGraph / countCTGraph) * 100 ).setScale(2) : 0;

                    GraphResult g = new GraphResult(team, key.substring(0,10), coloreTeam, success);
                    gList.add(g);
                }

                //successoMedioGraph = countCTSuccess > 0 ? ( (countVCSuccess / countCTSuccess) * 100 ).setScale(2) : 0;
                //successList.add(successoMedioGraph);
            }

            System.debug('@@@ gList ' + JSON.serialize(gList));

            //Popolo il wrapper con le info dell'utente
            utente.nomeUtente = UserInfo.getName();
            utente.nomeTeam = nomeTeamU;

            //Genero le date necessarie
            String oggi = System.Today().format();
            String domani = Date.parse(oggi).addDays(1).format();
            String inizioMese = Date.parse(oggi).toStartOfMonth().format();
            Integer numeroGiorni = Date.daysInMonth(Date.parse(oggi).Year(), Date.parse(oggi).Month());
            String fineMese = Date.newInstance(Date.parse(oggi).Year(), Date.parse(oggi).Month(), numeroGiorni).format();

            res.allAndamentale = allAndamentale;
            res.appuntamentiMese = countAppuntamentiMese;
            res.contattiMese = countContattiMese;
            //res.appuntamentiMediGiorno = Math.round(( countVisiteMese / getWorkingDaysPassed() ));
            res.appuntamentiMediGiorno = Math.round(( countVisiteMese / U.getWorkingDays(inizioMese, domani) ) );
            //res.successoMedio = countVCActual > 0 ? ( ( countVCActual / countCTActual ) ) : 0;
            res.successoMedio = countAppuntamentiMese > 0 ? ( countAppuntamentiMese / countContattiMese ) : 0;
            res.dates = new List<Date>(datesSet);
            res.grafico = gList;
            res.utente = utente;
            // res.successoGrafico = successList;
            //res.previsione = Math.round((countVisiteMese / getWorkingDaysPassed()) * (getWorkingDaysPassed() + getWorkingDaysRemaining()));
            res.previsione = Math.round((countVisiteMese / U.getWorkingDays(inizioMese, domani)) * (U.getWorkingDays(inizioMese, domani) + U.getWorkingDays(domani , fineMese) ));
            //res.variazione = countVisiteVariazione > 0 ? (((countVisiteMese / getWorkingDaysPassed()) * (getWorkingDaysPassed() + getWorkingDaysRemaining())) - countVisiteVariazione) / countVisiteVariazione : 0;
            res.variazione = countVisiteVariazione > 0 ? (((countVisiteMese / U.getWorkingDays(inizioMese, domani)) * (U.getWorkingDays(inizioMese, domani) + U.getWorkingDays(domani, fineMese))) - countVisiteVariazione) / countVisiteVariazione : 0; 

            response.data.add(res);
        }
        catch(Exception e){
            System.debug('@@@ exception e ' + e.getMessage() + ' -- ' + e.getLineNumber() + ' -- ' + e.getStackTraceString() );
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    // public static Integer getWorkingDaysPassed(){
    //     Date oggi = System.Today();

    //     Date inizioMese = oggi.toStartOfMonth();

    //     Integer daysBtw = 0;

    //     daysBtw = inizioMese.daysBetween(oggi);

    //     List<Date> giorni = new List<Date>();
    //     giorni.add(inizioMese);

    //     for(Integer i = 0; i < daysBtw; i++){
    //         Date newDay = inizioMese.addDays(i);
    //         Date inizioSettimana = newDay.toStartOfWeek();
    //         if(Math.Mod(inizioSettimana.daysBetween(newDay) , 7) != 5 && Math.Mod(inizioSettimana.daysBetween(newDay) , 7) != 6){
    //             giorni.add(newDay);
    //         }
    //     }

    //     return giorni.size();
    // }

    // public static Integer getWorkingDaysRemaining(){
    //     Date oggi = System.Today();

    //     Integer fineMese = Date.daysInMonth(oggi.year(), oggi.month());
    //     Date giornoFineMese = Date.newInstance(oggi.year(), oggi.month(), fineMese);

    //     Integer daysBtw = 0;

    //     daysBtw = oggi.daysBetween(giornoFineMese);

    //     List<Date> giorni = new List<Date>();
    //     // giorni.add(fineMese);r

    //     for(Integer i = 0; i < daysBtw; i++){
    //         Date newDay = oggi.addDays(i);
    //         Date inizioSettimana = newDay.toStartOfWeek();
    //         if(Math.Mod(inizioSettimana.daysBetween(newDay) , 7) != 5 && Math.Mod(inizioSettimana.daysBetween(newDay) , 7) != 6 && newDay.Month() == System.Today().Month()){
    //             giorni.add(newDay);
    //         }
    //     }

    //     return giorni.size();
    // }

    public class WrapperResponse{
        @AuraEnabled public List<Object> data;
        @AuraEnabled public String message;
        @AuraEnabled public Boolean success;

        public WrapperResponse(){
            this.data = new List<Object>();
            this.message = '';
            this.success = true;
        }
    }

    public class Result{
        @AuraEnabled public List<WGC_Andamentale__c> allAndamentale;
        @AuraEnabled public Decimal contattiMese;
        @AuraEnabled public Decimal appuntamentiMese;
        @AuraEnabled public Decimal appuntamentiMediGiorno;
        @AuraEnabled public Decimal previsione;
        @AuraEnabled public Decimal successoMedio;
        @AuraEnabled public Decimal variazione;
        @AuraEnabled public List<Date> dates;
        @AuraEnabled public List<GraphResult> grafico;
        // @AuraEnabled public List<Decimal> successoGrafico;
        @AuraEnabled public WrapperUtente utente;

        public Result(){
            this.allAndamentale = new List<WGC_Andamentale__c>();
            this.contattiMese = 0;
            this.appuntamentiMese = 0;
            this.appuntamentiMediGiorno = 0;
            this.previsione = 0;
            this.successoMedio = 0;
            this.variazione = 0;
        }
    }

    public class GraphResult{
        @AuraEnabled public String nomeTeam;
        @AuraEnabled public String data;
        @AuraEnabled public String colore;
        @AuraEnabled public Decimal successoMedio;
        
        public GraphResult(){
            this.nomeTeam = '';
            this.data = String.valueOf(System.Today());
            this.colore = '';
            this.successoMedio = 0;
        }

        public GraphResult(String nome, String dataD, String coloreTeam, Decimal successo){
            this.nomeTeam = nome;
            this.data = dataD;
            this.colore = coloreTeam;
            this.successoMedio = successo;
        }
    }

    public class WrapperUtente{
        @AuraEnabled public String nomeUtente;
        @AuraEnabled public String nomeTeam;

        public WrapperUtente(){
            this.nomeUtente = '';
            this.nomeTeam = '';
        }

        public WrapperUtente(String utente, String team){
            this.nomeUtente = utente;
            this.nomeTeam = team;
        }
    }
}