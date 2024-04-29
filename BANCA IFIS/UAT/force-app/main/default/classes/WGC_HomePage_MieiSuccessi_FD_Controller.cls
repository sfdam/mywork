public class WGC_HomePage_MieiSuccessi_FD_Controller {


    @AuraEnabled
    public static WrapperResponse getData(Boolean isDirezioneFD){
        WrapperResponse response = new WrapperResponse();

        try{
            Result results = new Result();
            List<WGC_Andamentale__c> obiettivoTotal = new List<WGC_Andamentale__c>();
            Map<String, List<WGC_Andamentale__c>> mappaTeam = new Map<String, List<WGC_Andamentale__c>>();
            Map<String, List<WGC_Andamentale__c>> mappaOperatore = new Map<String, List<WGC_Andamentale__c>>();

            //Recupero le info sui colori dei team
            List<WGC_Team_Filo_Diretto__mdt> teamXColore = new List<WGC_Team_Filo_Diretto__mdt>([SELECT Id, MasterLabel, DeveloperName, Colore_Team__c FROM WGC_Team_Filo_Diretto__mdt]);

            //Recupero il mio team per fare raggruppamento per la barra gialla del grafico
            User myUser = [SELECT Id, Name, WGC_Team_Filo_Diretto__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            results.team.nomeMyTeam = String.isBlank(myUser.WGC_Team_Filo_Diretto__c) ? 'All' : myUser.WGC_Team_Filo_Diretto__c;
            results.performer.myName = myUser.Name;

            //Recupero le segnalazioni chiuse oggi dall'utente
            List<Task> segnalazioni = new List<Task>();
            if(isDirezioneFD){
                segnalazioni = [SELECT Id, Subject FROM Task WHERE ActivityDate =: System.Today() AND Status = 'Chiuso' AND RecordType.DeveloperName = 'WGC_Segnalazione'];
            } else {
                segnalazioni = [SELECT Id, Subject FROM Task WHERE OwnerId =: UserInfo.getUserId() AND ActivityDate =: System.Today() AND Status = 'Chiuso' AND RecordType.DeveloperName = 'WGC_Segnalazione'];
            }
            // Query per recuperare i dati dell'obiettivo del grafico
            obiettivoTotal = [SELECT Id, VC_Budget__c, VC_Actual__c, Operatore__c, Operatore__r.Name, Team__c, CT_Actual__c FROM WGC_Andamentale__c WHERE Data__c =: System.Today() ORDER BY CT_Actual__c];

            // Raggruppo per team
            mappaTeam = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(obiettivoTotal, 'Team__c');

            // Raggruppo per operatore
            mappaOperatore = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(obiettivoTotal, 'Operatore__r.Name');

            Decimal mioObiettivoGrafico = 0;
            Decimal mioActualGrafico = 0;

            //Setto il valore delle visite create in data odierna da me e dal mio team
            if(isDirezioneFD){
                for(WGC_Andamentale__c andamento : obiettivoTotal){
                    //Counter per le visite del mio team
                    //if(andamento.Team__c == myUser.WGC_Team_Filo_Diretto__c){
                        results.team.visiteMyTeam += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;  
                    //}

                    //Counter per le mie visite
                    // if(andamento.Operatore__c == myUser.Id){
                        results.performer.myVisite += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                        results.performer.myObiettivo += andamento.VC_Budget__c != null ? andamento.VC_Budget__c : 0;

                        mioObiettivoGrafico += andamento.VC_Budget__c != null ? andamento.VC_Budget__c : 0;
                        mioActualGrafico += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                    // }
                }
            } else {
                for(WGC_Andamentale__c andamento : obiettivoTotal){
                    //Counter per le visite del mio team
                    if(andamento.Team__c == myUser.WGC_Team_Filo_Diretto__c){
                        results.team.visiteMyTeam += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;  
                    }

                    //Counter per le mie visite
                    if(andamento.Operatore__c == myUser.Id){
                        results.performer.myVisite = andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                        results.performer.myObiettivo = andamento.VC_Budget__c != null ? andamento.VC_Budget__c : 0;

                        mioObiettivoGrafico = andamento.VC_Budget__c != null ? andamento.VC_Budget__c : 0;
                        mioActualGrafico = andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                    }
                }
            }

            //Mi genero i dati del mio grafico
            // GraphData mioGrafico = new GraphData(myUser.WGC_Team_Filo_Diretto__c, mioObiettivoGrafico, mioActualGrafico, 'orange', true);

            Map<String, Decimal> counterForTeam = new Map<String, Decimal>();
            List<GraphData> datiGrafico = new List<GraphData>();
            // datiGrafico.add(mioGrafico);
            //Conteggio le visite per ogni team e poi calcolo il migliore
            for(String team : mappaTeam.keySet()){
                Decimal counterVC = 0;
                Decimal counterBudgetAllTeam = 0;

                for(WGC_Andamentale__c andamentaleTeam : mappaTeam.get(team)){
                    counterVC += andamentaleTeam.VC_Actual__c != null ? andamentaleTeam.VC_Actual__c : 0;
                    counterBudgetAllTeam += andamentaleTeam.VC_Budget__c != null ? andamentaleTeam.VC_Budget__c : 0;
                }

                String coloreTeam = '';
                for(WGC_Team_Filo_Diretto__mdt teamMDT : teamXColore){
                    if(teamMDT.MasterLabel == team){
                        coloreTeam = teamMDT.Colore_Team__c;
                    }
                }

                GraphData g = new GraphData(team, counterBudgetAllTeam, counterVC, coloreTeam, false);
                datiGrafico.add(g);
                counterForTeam.put(team, counterVC);                
            }

            Decimal bestResult = 0;
            String bestTeam = '';
            //Se tutti e 3 i team si eguagliano allora setto il miglior team come il mio stesso team
            for(String team : counterForTeam.keySet()){
                bestTeam = counterForTeam.get(team) > bestResult ? team : bestTeam;
                bestResult = counterForTeam.get(team) > bestResult ? counterForTeam.get(team) : bestResult;

            }

            //Se entro con l'utenza di direzione commerciale FD
            bestTeam = String.isBlank(bestTeam) ? String.isBlank(myUser.WGC_Team_Filo_Diretto__c) ? teamXColore[0].MasterLabel : myUser.WGC_Team_Filo_Diretto__c : bestTeam ;

            Map<String, Decimal> counterForOperatore = new Map<String, Decimal>();
            Decimal bestResultPerformer = 0;
            String bestPerformerName = '';
            for(String operatore : mappaOperatore.keySet()){
                bestPerformerName = mappaOperatore.get(operatore)[0].VC_Actual__c > bestResultPerformer ? String.valueOf(operatore) : bestPerformerName;
                bestResultPerformer = mappaOperatore.get(operatore)[0].VC_Actual__c > bestResultPerformer ? mappaOperatore.get(operatore)[0].VC_Actual__c : bestResultPerformer;
            }

            bestPerformerName = String.isBlank(bestPerformerName) ? myUser.Name : bestPerformerName;

            //Assegno
            results.andamentaleTotale = obiettivoTotal;
            //results.obiettivo = counterBudgetAllTeam;
            //Assegno team
            results.team.nomeBestTeam = bestTeam;
            results.team.visiteBestTeam = bestResult;
            //Assegno operatore
            results.performer.nomeBestPerformer = bestPerformerName;
            results.performer.visiteBestPerformer = bestResultPerformer;
            //Assegno segnalazioni
            results.segnalazioni = segnalazioni.size();
            //Assegno i dati del grafico
            results.grafico = datiGrafico;

            response.data.add(results);

        }catch(Exception e){
            response.message = e.getMessage();
            response.success = false;
        }

        return response;
    }

    @AuraEnabled
    public static WrapperResponse getDataFiltered(String userId, String teamName, Boolean isAllUser){
       WrapperResponse response = new WrapperResponse();

       try{
            if(String.isNotBlank(userId)){
                Result results = new Result();
                List<WGC_Andamentale__c> obiettivoTotal = new List<WGC_Andamentale__c>();
                Map<String, List<WGC_Andamentale__c>> mappaTeam = new Map<String, List<WGC_Andamentale__c>>();
                Map<String, List<WGC_Andamentale__c>> mappaOperatore = new Map<String, List<WGC_Andamentale__c>>();

                //Recupero le info sui colori dei team
                List<WGC_Team_Filo_Diretto__mdt> teamXColore = new List<WGC_Team_Filo_Diretto__mdt>();
                teamXColore = [SELECT Id, MasterLabel, DeveloperName, Colore_Team__c FROM WGC_Team_Filo_Diretto__mdt];

                //Recupero il mio team per fare raggruppamento per la barra gialla del grafico
                User myUser = [SELECT Id, Name, WGC_Team_Filo_Diretto__c FROM User WHERE Id =: userId LIMIT 1];
                results.team.nomeMyTeam = myUser.WGC_Team_Filo_Diretto__c;
                results.performer.myName = myUser.Name;

                //Recupero le segnalazioni chiuse oggi dall'utente
                List<Task> segnalazioni = new List<Task>();
                segnalazioni = [SELECT Id, Subject FROM Task WHERE OwnerId =: UserInfo.getUserId() AND ActivityDate =: System.Today() AND Status = 'Chiuso' AND RecordType.DeveloperName = 'WGC_Segnalazione'];
                
                // Query per recuperare i dati dell'obiettivo del grafico
                obiettivoTotal = [SELECT Id, VC_Budget__c, VC_Actual__c, Operatore__c, Operatore__r.Name, Team__c, CT_Actual__c FROM WGC_Andamentale__c WHERE Data__c =: System.Today() ORDER BY CT_Actual__c];

                // Raggruppo per team
                mappaTeam = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(obiettivoTotal, 'Team__c');

                // Raggruppo per operatore
                mappaOperatore = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(obiettivoTotal, 'Operatore__r.Name');

                Decimal mioObiettivoGrafico = 0;
                Decimal mioActualGrafico = 0;

                //Setto il valore delle visite create in data odierna da me e dal mio team
                for(WGC_Andamentale__c andamento : obiettivoTotal){
                    //Counter per le visite del mio team
                    if(andamento.Team__c == myUser.WGC_Team_Filo_Diretto__c){
                        results.team.visiteMyTeam += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;  
                    }

                    //Counter per le mie visite
                    if(andamento.Operatore__c == myUser.Id){
                        results.performer.myVisite = andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                        results.performer.myObiettivo = andamento.VC_Budget__c != null ? andamento.VC_Budget__c : 0;

                        mioObiettivoGrafico = andamento.VC_Budget__c != null ? andamento.VC_Budget__c : 0;
                        mioActualGrafico = andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                    }
                }

                //Mi genero i dati del mio grafico
                // GraphData mioGrafico = new GraphData(myUser.WGC_Team_Filo_Diretto__c, mioObiettivoGrafico, mioActualGrafico, 'orange', true);

                Map<String, Decimal> counterForTeam = new Map<String, Decimal>();
                List<GraphData> datiGrafico = new List<GraphData>();
                // datiGrafico.add(mioGrafico);
                //Conteggio le visite per ogni team e poi calcolo il migliore
                for(String team : mappaTeam.keySet()){
                    Decimal counterVC = 0;
                    Decimal counterBudgetAllTeam = 0;

                    for(WGC_Andamentale__c andamentaleTeam : mappaTeam.get(team)){
                        counterVC += andamentaleTeam.VC_Actual__c != null ? andamentaleTeam.VC_Actual__c : 0;
                        counterBudgetAllTeam += andamentaleTeam.VC_Budget__c != null ? andamentaleTeam.VC_Budget__c : 0;
                    }

                    String coloreTeam = '';
                    for(WGC_Team_Filo_Diretto__mdt teamMDT : teamXColore){
                        if(teamMDT.MasterLabel == team){
                            coloreTeam = teamMDT.Colore_Team__c;
                        }
                    }

                    GraphData g = new GraphData(team, counterBudgetAllTeam, counterVC, coloreTeam, false);
                    datiGrafico.add(g);
                    counterForTeam.put(team, counterVC);                
                }

                Decimal bestResult = 0;
                String bestTeam = '';
                //Se tutti e 3 i team si eguagliano allora setto il miglior team come il mio stesso team
                for(String team : counterForTeam.keySet()){
                    bestTeam = counterForTeam.get(team) > bestResult ? team : bestTeam;
                    bestResult = counterForTeam.get(team) > bestResult ? counterForTeam.get(team) : bestResult;

                }

                bestTeam = String.isBlank(bestTeam) ? myUser.WGC_Team_Filo_Diretto__c : bestTeam ;

                Map<String, Decimal> counterForOperatore = new Map<String, Decimal>();
                Decimal bestResultPerformer = 0;
                String bestPerformerName = '';
                for(String operatore : mappaOperatore.keySet()){
                    bestPerformerName = mappaOperatore.get(operatore)[0].VC_Actual__c > bestResultPerformer ? String.valueOf(operatore) : bestPerformerName;
                    bestResultPerformer = mappaOperatore.get(operatore)[0].VC_Actual__c > bestResultPerformer ? mappaOperatore.get(operatore)[0].VC_Actual__c : bestResultPerformer;
                }

                bestPerformerName = String.isBlank(bestPerformerName) ? myUser.Name : bestPerformerName;

                //Assegno
                results.andamentaleTotale = obiettivoTotal;
                //results.obiettivo = counterBudgetAllTeam;
                //Assegno team
                results.team.nomeBestTeam = bestTeam;
                results.team.visiteBestTeam = bestResult;
                //Assegno operatore
                results.performer.nomeBestPerformer = bestPerformerName;
                results.performer.visiteBestPerformer = bestResultPerformer;
                //Assegno segnalazioni
                results.segnalazioni = segnalazioni.size();
                //Assegno i dati del grafico
                results.grafico = datiGrafico;

                response.data.add(results);
            } else if(String.isNotBlank(teamName)){
                Result results = new Result();
                List<WGC_Andamentale__c> obiettivoTotal = new List<WGC_Andamentale__c>();
                Map<String, List<WGC_Andamentale__c>> mappaTeam = new Map<String, List<WGC_Andamentale__c>>();
                Map<String, List<WGC_Andamentale__c>> mappaOperatore = new Map<String, List<WGC_Andamentale__c>>();

                //Recupero le info sui colori dei team
                List<WGC_Team_Filo_Diretto__mdt> teamXColore = new List<WGC_Team_Filo_Diretto__mdt>();
                teamXColore = [SELECT Id, MasterLabel, DeveloperName, Colore_Team__c FROM WGC_Team_Filo_Diretto__mdt];

                //Recupero il mio team per fare raggruppamento per la barra gialla del grafico
                User myUser = [SELECT Id, Name, WGC_Team_Filo_Diretto__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
                results.team.nomeMyTeam = teamName;
                results.performer.myName = myUser.Name;

                Map<Id,User> usersFD = new Map<Id,User>([SELECT Id, Name, WGC_Team_Filo_Diretto__c FROM User WHERE WGC_Team_Filo_Diretto__c != null AND WGC_Team_Filo_Diretto__c =: teamName AND IsActive = true]);

                //Recupero le segnalazioni chiuse oggi dall'utente
                List<Task> segnalazioni = new List<Task>();
                segnalazioni = [SELECT Id, Subject FROM Task WHERE OwnerId IN: usersFD.keySet() AND ActivityDate =: System.Today() AND Status = 'Chiuso' AND RecordType.DeveloperName = 'WGC_Segnalazione'];
                
                // Query per recuperare i dati dell'obiettivo del grafico
                obiettivoTotal = [SELECT Id, VC_Budget__c, VC_Actual__c, Operatore__c, Operatore__r.Name, Team__c, CT_Actual__c FROM WGC_Andamentale__c WHERE Data__c =: System.Today() ORDER BY CT_Actual__c];

                // Raggruppo per team
                mappaTeam = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(obiettivoTotal, 'Team__c');

                // Raggruppo per operatore
                mappaOperatore = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(obiettivoTotal, 'Operatore__r.Name');

                Decimal mioObiettivoGrafico = 0;
                Decimal mioActualGrafico = 0;

                //Setto il valore delle visite create in data odierna da me e dal mio team
                for(WGC_Andamentale__c andamento : obiettivoTotal){
                    //Counter per le visite del mio team
                    if(andamento.Team__c == teamName){
                        results.team.visiteMyTeam += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                        results.performer.myVisite = andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                        results.performer.myObiettivo = andamento.VC_Budget__c != null ? andamento.VC_Budget__c : 0;
                    }

                    //Counter per le mie visite
                    if(andamento.Operatore__c == myUser.Id){
                        mioObiettivoGrafico = andamento.VC_Budget__c != null ? andamento.VC_Budget__c : 0;
                        mioActualGrafico = andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                    }
                }

                //Mi genero i dati del mio grafico
                // GraphData mioGrafico = new GraphData(myUser.WGC_Team_Filo_Diretto__c, mioObiettivoGrafico, mioActualGrafico, 'orange', true);

                Map<String, Decimal> counterForTeam = new Map<String, Decimal>();
                List<GraphData> datiGrafico = new List<GraphData>();
                // datiGrafico.add(mioGrafico);
                //Conteggio le visite per ogni team e poi calcolo il migliore
                for(String team : mappaTeam.keySet()){
                    Decimal counterVC = 0;
                    Decimal counterBudgetAllTeam = 0;

                    for(WGC_Andamentale__c andamentaleTeam : mappaTeam.get(team)){
                        if(andamentaleTeam.Team__c == team){
                            counterVC += andamentaleTeam.VC_Actual__c != null ? andamentaleTeam.VC_Actual__c : 0;
                            counterBudgetAllTeam += andamentaleTeam.VC_Budget__c != null ? andamentaleTeam.VC_Budget__c : 0;
                        }
                    }

                    String coloreTeam = '';
                    for(WGC_Team_Filo_Diretto__mdt teamMDT : teamXColore){
                        if(teamMDT.MasterLabel == team){
                            coloreTeam = teamMDT.Colore_Team__c;
                        }
                    }

                    GraphData g = new GraphData(team, counterBudgetAllTeam, counterVC, coloreTeam, false);
                    datiGrafico.add(g);
                    counterForTeam.put(team, counterVC);                
                }

                Decimal bestResult = 0;
                String bestTeam = '';
                //Se tutti e 3 i team si eguagliano allora setto il miglior team come il mio stesso team
                for(String team : counterForTeam.keySet()){
                    bestTeam = counterForTeam.get(team) > bestResult ? team : bestTeam;
                    bestResult = counterForTeam.get(team) > bestResult ? counterForTeam.get(team) : bestResult;

                }

                bestTeam = String.isBlank(bestTeam) ? teamName : bestTeam ;

                Map<String, Decimal> counterForOperatore = new Map<String, Decimal>();
                Decimal bestResultPerformer = 0;
                String bestPerformerName = '';
                for(String operatore : mappaOperatore.keySet()){
                    bestPerformerName = mappaOperatore.get(operatore)[0].VC_Actual__c > bestResultPerformer ? String.valueOf(operatore) : bestPerformerName;
                    bestResultPerformer = mappaOperatore.get(operatore)[0].VC_Actual__c > bestResultPerformer ? mappaOperatore.get(operatore)[0].VC_Actual__c : bestResultPerformer;
                }

                bestPerformerName = String.isBlank(bestPerformerName) ? myUser.Name : bestPerformerName;

                //Assegno
                results.andamentaleTotale = obiettivoTotal;
                //results.obiettivo = counterBudgetAllTeam;
                //Assegno team
                results.team.nomeBestTeam = bestTeam;
                results.team.visiteBestTeam = bestResult;
                //Assegno operatore
                results.performer.nomeBestPerformer = bestPerformerName;
                results.performer.visiteBestPerformer = bestResultPerformer;
                //Assegno segnalazioni
                results.segnalazioni = segnalazioni.size();
                //Assegno i dati del grafico
                results.grafico = datiGrafico;

                response.data.add(results);
            } else if(isAllUser){
                Result results = new Result();
                List<WGC_Andamentale__c> obiettivoTotal = new List<WGC_Andamentale__c>();
                Map<String, List<WGC_Andamentale__c>> mappaTeam = new Map<String, List<WGC_Andamentale__c>>();
                Map<String, List<WGC_Andamentale__c>> mappaOperatore = new Map<String, List<WGC_Andamentale__c>>();

                //Recupero le info sui colori dei team
                List<WGC_Team_Filo_Diretto__mdt> teamXColore = new List<WGC_Team_Filo_Diretto__mdt>();
                teamXColore = [SELECT Id, MasterLabel, DeveloperName, Colore_Team__c FROM WGC_Team_Filo_Diretto__mdt];

                //Recupero il mio team per fare raggruppamento per la barra gialla del grafico
                User myUser = [SELECT Id, Name, WGC_Team_Filo_Diretto__c FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
                results.team.nomeMyTeam = myUser.WGC_Team_Filo_Diretto__c;
                results.performer.myName = myUser.Name;

                Map<Id,User> usersFD = new Map<Id,User>([SELECT Id, Name, WGC_Team_Filo_Diretto__c FROM User WHERE WGC_Team_Filo_Diretto__c != null AND IsActive = true]);

                //Recupero le segnalazioni chiuse oggi dall'utente
                List<Task> segnalazioni = new List<Task>();
                segnalazioni = [SELECT Id, Subject FROM Task WHERE OwnerId IN: usersFD.keySet() AND ActivityDate =: System.Today() AND Status = 'Chiuso' AND RecordType.DeveloperName = 'WGC_Segnalazione'];
                
                // Query per recuperare i dati dell'obiettivo del grafico
                obiettivoTotal = [SELECT Id, VC_Budget__c, VC_Actual__c, Operatore__c, Operatore__r.Name, Team__c, CT_Actual__c FROM WGC_Andamentale__c WHERE Data__c =: System.Today() ORDER BY CT_Actual__c];

                // Raggruppo per team
                mappaTeam = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(obiettivoTotal, 'Team__c');

                // Raggruppo per operatore
                mappaOperatore = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(obiettivoTotal, 'Operatore__r.Name');

                Decimal mioObiettivoGrafico = 0;
                Decimal mioActualGrafico = 0;

                //Setto il valore delle visite create in data odierna da me e dal mio team
                for(WGC_Andamentale__c andamento : obiettivoTotal){
                    //Counter per le visite del mio team
                    //if(andamento.Team__c == myUser.WGC_Team_Filo_Diretto__c){
                        results.team.visiteMyTeam += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;  
                    //}

                    //Counter per le mie visite
                    //if(andamento.Operatore__c == myUser.Id){
                        results.performer.myVisite = andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                        results.performer.myObiettivo = andamento.VC_Budget__c != null ? andamento.VC_Budget__c : 0;

                        mioObiettivoGrafico = andamento.VC_Budget__c != null ? andamento.VC_Budget__c : 0;
                        mioActualGrafico = andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
                    //}
                }

                //Mi genero i dati del mio grafico
                // GraphData mioGrafico = new GraphData(myUser.WGC_Team_Filo_Diretto__c, mioObiettivoGrafico, mioActualGrafico, 'orange', true);

                Map<String, Decimal> counterForTeam = new Map<String, Decimal>();
                List<GraphData> datiGrafico = new List<GraphData>();
                // datiGrafico.add(mioGrafico);
                //Conteggio le visite per ogni team e poi calcolo il migliore
                for(String team : mappaTeam.keySet()){
                    Decimal counterVC = 0;
                    Decimal counterBudgetAllTeam = 0;

                    for(WGC_Andamentale__c andamentaleTeam : mappaTeam.get(team)){
                        if(andamentaleTeam.Team__c == team){
                            counterVC += andamentaleTeam.VC_Actual__c != null ? andamentaleTeam.VC_Actual__c : 0;
                            counterBudgetAllTeam += andamentaleTeam.VC_Budget__c != null ? andamentaleTeam.VC_Budget__c : 0;
                        }
                    }

                    String coloreTeam = '';
                    for(WGC_Team_Filo_Diretto__mdt teamMDT : teamXColore){
                        if(teamMDT.MasterLabel == team){
                            coloreTeam = teamMDT.Colore_Team__c;
                        }
                    }

                    GraphData g = new GraphData(team, counterBudgetAllTeam, counterVC, coloreTeam, false);
                    datiGrafico.add(g);
                    counterForTeam.put(team, counterVC);                
                }

                Decimal bestResult = 0;
                String bestTeam = '';
                //Se tutti e 3 i team si eguagliano allora setto il miglior team come il mio stesso team
                for(String team : counterForTeam.keySet()){
                    bestTeam = counterForTeam.get(team) > bestResult ? team : bestTeam;
                    bestResult = counterForTeam.get(team) > bestResult ? counterForTeam.get(team) : bestResult;

                }

                bestTeam = String.isBlank(bestTeam) ? myUser.WGC_Team_Filo_Diretto__c : bestTeam ;

                Map<String, Decimal> counterForOperatore = new Map<String, Decimal>();
                Decimal bestResultPerformer = 0;
                String bestPerformerName = '';
                for(String operatore : mappaOperatore.keySet()){
                    bestPerformerName = mappaOperatore.get(operatore)[0].VC_Actual__c > bestResultPerformer ? String.valueOf(operatore) : bestPerformerName;
                    bestResultPerformer = mappaOperatore.get(operatore)[0].VC_Actual__c > bestResultPerformer ? mappaOperatore.get(operatore)[0].VC_Actual__c : bestResultPerformer;
                }

                bestPerformerName = String.isBlank(bestPerformerName) ? myUser.Name : bestPerformerName;

                //Assegno
                results.andamentaleTotale = obiettivoTotal;
                //results.obiettivo = counterBudgetAllTeam;
                //Assegno team
                results.team.nomeBestTeam = bestTeam;
                results.team.visiteBestTeam = bestResult;
                //Assegno operatore
                results.performer.nomeBestPerformer = bestPerformerName;
                results.performer.visiteBestPerformer = bestResultPerformer;
                //Assegno segnalazioni
                results.segnalazioni = segnalazioni.size();
                //Assegno i dati del grafico
                results.grafico = datiGrafico;

                response.data.add(results);
            }
       } catch(exception e){
           response.message = e.getMessage() + ' -- ' + e.getLineNumber();
           response.success = false;
       }

       return response;
    }  

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
        @AuraEnabled public List<WGC_Andamentale__c> andamentaleTotale;
        @AuraEnabled public Decimal obiettivo;
        @AuraEnabled public Integer segnalazioni;
        @AuraEnabled public Team team;
        @AuraEnabled public Performer performer;
        @AuraEnabled public List<GraphData> grafico;

        public Result(){
            this.andamentaleTotale = new List<WGC_Andamentale__c>();
            this.obiettivo = 0;
            this.team = new Team();
            this.performer = new Performer();
        }
    }

    public class Team{
        @AuraEnabled public String nomeBestTeam;
        @AuraEnabled public Decimal visiteBestTeam;
        @AuraEnabled public String nomeMyTeam;
        @AuraEnabled public Decimal visiteMyTeam;

        public Team(){
            //this.nomeBestTeam = '';
            //this.visiteBestTeam = 0;
            this.nomeMyTeam = '';
            this.visiteMyTeam = 0;
        }
    }

    public class Performer{
        @AuraEnabled public String nomeBestPerformer;
        @AuraEnabled public Decimal visiteBestPerformer;
        @AuraEnabled public String myName;
        @AuraEnabled public Decimal myVisite;
        @AuraEnabled public Decimal myObiettivo;

        public Performer(){
            //this.nomeBestPerformer = '';
            //this.visiteBestPerformer = null;
            this.myName = '';
            this.myVisite = 0;
            this.myObiettivo = 0;
        }
    }

    public class GraphData{
        @AuraEnabled public String nomeTeam;
        @AuraEnabled public Decimal obiettivo;
        @AuraEnabled public Decimal actual;
        @AuraEnabled public String coloreTeam;
        @AuraEnabled public Boolean isUser;
        
        public GraphData(){
            this.nomeTeam = '';
            this.obiettivo = 0;
            this.actual = 0;
            this.coloreTeam = '';
            this.isUser = false;
        }

        public GraphData(String nomeTeam, Decimal ob, Decimal ac, String colore, Boolean isUser){
            this.nomeTeam = nomeTeam;
            this.obiettivo = ob;
            this.actual = ac;
            this.coloreTeam = colore;
            this.isUser = isUser;
        }
    }
}