public class WGC_Sfida_FD_Detail_Controller {

	@AuraEnabled
	public static WrapperResponse getAllData(Integer mese, String anno) {
		WrapperResponse response = new WrapperResponse();
		Result res = new Result();

		try {
			//Wrapper di appoggio per informazioni sull'utente
			WrapperUtente utente = new WrapperUtente();
			String nomeTeamU = '';

			String filtro = 'month';

			List<WGC_Andamentale__c> allAndamentale = new List<WGC_Andamentale__c> ();
			// if(filtro == 'month'){
			//     allAndamentale = [SELECT Id, Operatore__c, Operatore__r.Name, Data__c, CT_Budget__c, CT_Actual__c, VC_Budget__c, VC_Actual__c, Team__c, Mese_frm__c FROM WGC_Andamentale__c WHERE Data__c = THIS_MONTH AND Data__c <= TODAY ORDER BY Data__c ASC];
			//     System.debug('@@@ andamentale ' + JSON.serialize(allAndamentale));
			// }
			if (anno == 'year') {
				allAndamentale = [SELECT Id, Operatore__c, Operatore__r.Name, Data__c, CT_Budget__c, CT_Actual__c, VC_Budget__c, VC_Actual__c, Team__c, Mese_frm__c FROM WGC_Andamentale__c WHERE CALENDAR_MONTH(Data__c) = :mese AND Data__c = THIS_YEAR AND Data__c <= TODAY ORDER BY Data__c ASC];
				System.debug('@@@ andamentale ' + JSON.serialize(allAndamentale));
			}
			else if (anno == 'lastyear') {
				allAndamentale = [SELECT Id, Operatore__c, Operatore__r.Name, Data__c, CT_Budget__c, CT_Actual__c, VC_Budget__c, VC_Actual__c, Team__c, Mese_frm__c FROM WGC_Andamentale__c WHERE CALENDAR_MONTH(Data__c) = :mese AND Data__c = LAST_YEAR ORDER BY Data__c ASC];
				System.debug('@@@ andamentale ' + JSON.serialize(allAndamentale));
			}
			else {
				allAndamentale = [SELECT Id, Operatore__c, Operatore__r.Name, Data__c, CT_Budget__c, CT_Actual__c, VC_Budget__c, VC_Actual__c, Team__c, Mese_frm__c FROM WGC_Andamentale__c WHERE Data__c = THIS_MONTH AND Data__c <= TODAY ORDER BY Data__c ASC];
				System.debug('@@@ andamentale ' + JSON.serialize(allAndamentale));
			}

			Integer annoToConsider;
			if (anno == 'year') {
				annoToConsider = System.Today().Year();
			} else if (anno == 'lastyear') {
				annoToConsider = System.Today().addYears(- 1).Year();
			}

			List<WGC_Andamentale__c> andamentaleMonth = new List<WGC_Andamentale__c> ();
			andamentaleMonth = [SELECT Id, Operatore__c, Operatore__r.Name, Data__c, CT_Budget__c, CT_Actual__c, VC_Budget__c, VC_Actual__c, Team__c, Mese_frm__c FROM WGC_Andamentale__c WHERE CALENDAR_MONTH(Data__c) = :mese AND CALENDAR_YEAR(Data__c) = :annoToConsider];

			List<WGC_Andamentale__c> andamentaleVariazione = new List<WGC_Andamentale__c> ();
			if (anno == 'year') {
				andamentaleVariazione = [SELECT Id, Operatore__c, Operatore__r.Name, Data__c, CT_Budget__c, CT_Actual__c, VC_Budget__c, VC_Actual__c, Team__c, Mese_frm__c FROM WGC_Andamentale__c WHERE Data__c = LAST_YEAR AND CALENDAR_MONTH(Data__c) = :mese];
			} else if (anno == 'lastyear') {
				Integer annoToConsider2 = System.Today().addYears(- 2).Year();
				andamentaleVariazione = [SELECT Id, Operatore__c, Operatore__r.Name, Data__c, CT_Budget__c, CT_Actual__c, VC_Budget__c, VC_Actual__c, Team__c, Mese_frm__c FROM WGC_Andamentale__c WHERE CALENDAR_YEAR(Data__c) = :annoToConsider AND CALENDAR_MONTH(Data__c) = :mese];
			}
			System.debug('@@@ andamentaleVariazione ' + JSON.serialize(andamentaleVariazione));

			Decimal countVisiteVariazione = 0;
			for (WGC_Andamentale__c andamento : andamentaleVariazione) {
				countVisiteVariazione += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
			}

			// List<Event> appuntamentiMese = new List<Event>();
			// appuntamentiMese = [SELECT Id, Subject, CreatoDaFiloDiretto__c, CreatedDate FROM Event WHERE CreatedDate = THIS_MONTH AND CreatoDaFiloDiretto__c = true];

			// List<Task> contattiMese = new List<Task>();
			// contattiMese = [SELECT Id, Subject, DiFiloDiretto__c FROM Task WHERE LastModifiedDate = THIS_MONTH AND DiFiloDiretto__c = true AND Status = 'Chiuso'];

			Decimal countContattiMese = 0;
			Decimal countAppuntamentiMese = 0;

			for (WGC_Andamentale__c andamento : andamentaleMonth) {
				countContattiMese += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
				countAppuntamentiMese += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
			}

			//Recupero le info sui colori dei team
			List<WGC_Team_Filo_Diretto__mdt> teamXColore = new List<WGC_Team_Filo_Diretto__mdt> ();
			teamXColore = [SELECT Id, MasterLabel, DeveloperName, Colore_Team__c FROM WGC_Team_Filo_Diretto__mdt];

			// List<Event> visiteOggi = new List<Event>();
			// for(Event e : appuntamentiMese){
			//     if(e.CreatedDate == System.Today()){
			//         visiteOggi.add(e);
			//     }
			// }

			Decimal countVisiteMese = 0;
			for (WGC_Andamentale__c andamento : andamentaleMonth) {
				//if(andamento.Data__c == System.Today()){
				countVisiteMese += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
				//}
			}



			List<String> dates = new List<String> ();
			for (WGC_Andamentale__c andamento : allAndamentale) {
				dates.add(String.valueOf(andamento.Data__c));
				// if(filtro == 'month' || String.isBlank(filtro)){
				//     dates.add(String.valueOf(andamento.Data__c));
				// } else {
				//     dates.add(String.valueOf(andamento.Data__c.Month()));
				// }
			}

			Set<String> datesSet = new Set<String> (dates);

			List<WGC_Andamentale__c> andamentaleOggi = new List<WGC_Andamentale__c> ();
			Decimal countCTActual = 0;
			Decimal countVCActual = 0;

			for (WGC_Andamentale__c andamento : allAndamentale) {
				andamentaleOggi.add(andamento);
				if (andamento.Data__c == System.Today()) {
					countCTActual += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
					countVCActual += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
				}
			}

			// if(filtro == 'month'){
			//     andamentaleXData = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(allAndamentale, 'Data__c');
			// }
			// else if(filtro == 'year'){
			//     andamentaleXData = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(allAndamentale, 'Mese_frm__c');
			// }
			// else if(filtro == 'lastyear'){
			//     andamentaleXData = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(allAndamentale, 'Mese_frm__c');
			// }
			// else{
			//     andamentaleXData = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(allAndamentale, 'Data__c');
			// }


			//Mi genero il wrapper dati per il grafico
			Map<String, List<WGC_Andamentale__c>> andamentaleXData = new Map<String, List<WGC_Andamentale__c>> ();
			andamentaleXData = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(allAndamentale, 'Data__c');

			Map<String, List<GraphResult>> mappaFinal = new Map<String, List<GraphResult>> ();
			List<GraphResult> gList = new List<GraphResult> ();

			List<Decimal> successList = new List<Decimal> ();
			List<SuccessGraphResult> datiGraficoSuccessoTeam = new List<SuccessGraphResult> ();
			List<SuccessGraphResult> datiGraficoSuccessoTot = new List<SuccessGraphResult> ();

			for (String key : andamentaleXData.keySet()) {
				Map<String, List<WGC_Andamentale__c>> temp = new Map<String, List<WGC_Andamentale__c>> ();
				temp = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(andamentaleXData.get(key), 'Team__c');

				Decimal countCTSuccess = 0;
				Decimal countVCSuccess = 0;
				Decimal successoMedioGraph = 0;
				for (String team : temp.keySet()) {
					// gList.clear();
					Decimal countVCGraph = 0;
					Decimal myCountVCGraph = 0;

					//Contatori per grafico del successo
					Decimal countCTSuccessGraph = 0;
					Decimal countVCSuccessGraph = 0;
					for (WGC_Andamentale__c andamento : temp.get(team)) {
						countVCGraph += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;

						//Calcolo i dati per il successio medio del giorno
						countCTSuccess += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
						countVCSuccess += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;

						//Calcolo il successo medio per team
						countCTSuccessGraph += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
						countVCSuccessGraph += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;

						if (andamento.Operatore__c == UserInfo.getUserId()) {
							myCountVCGraph += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
							// Popolo il wrapper con le info dell'utente
							// utente.nomeTeam = andamento.Team__c;
							nomeTeamU = andamento.Team__c;
						}
					}

					String coloreTeam = '';
					for (WGC_Team_Filo_Diretto__mdt teamC : teamXColore) {
						if (teamC.MasterLabel == team) {
							coloreTeam = teamC.Colore_Team__c;
						}
					}

					GraphResult g = new GraphResult(team, countVCGraph, key.substring(0, 10), myCountVCGraph, coloreTeam);
					gList.add(g);

					//genero le informazioni del grafico di successo suddiviso per team
					SuccessGraphResult sg = new SuccessGraphResult(team, key.substring(0, 10), countCTSuccessGraph > 0 ? ((countVCSuccessGraph / countCTSuccessGraph) * 100).setScale(2) : 0, coloreTeam);
					datiGraficoSuccessoTeam.add(sg);
				}

				successoMedioGraph = countCTSuccess > 0 ? ((countVCSuccess / countCTSuccess) * 100).setScale(2) : 0;
				successList.add(successoMedioGraph);

				SuccessGraphResult sg = new SuccessGraphResult('Obiettivo Totale', key.substring(0, 10), countCTSuccess > 0 ? ((countVCSuccess / countCTSuccess) * 100).setScale(2) : 0, '#4a90e2');
				datiGraficoSuccessoTot.add(sg);
			}

			System.debug('@@@ gList ' + JSON.serialize(gList));

			//Popolo il wrapper con le info dell'utente
			utente.nomeUtente = UserInfo.getName();
			utente.nomeTeam = nomeTeamU;

			//Genero le date necessarie
			String oggi;
			String domani;
			String inizioMese;
			Integer numeroGiorni;
			String fineMese;

			if (mese == System.Today().Month() && anno == 'year') {
				oggi = System.Today().format();
				domani = Date.parse(oggi).addDays(1).format();
				inizioMese = Date.parse(oggi).toStartOfMonth().format();
				numeroGiorni = Date.daysInMonth(Date.parse(oggi).Year(), Date.parse(oggi).Month());
				fineMese = Date.newInstance(Date.parse(oggi).Year(), Date.parse(oggi).Month(), numeroGiorni).format();
			} else if (mese == System.Today().Month() && anno == 'lastyear') {
				oggi = System.Today().addYears(- 1).format();
				domani = Date.parse(oggi).addDays(1).format();
				inizioMese = Date.parse(oggi).toStartOfMonth().format();
				numeroGiorni = Date.daysInMonth(Date.parse(oggi).Year(), Date.parse(oggi).Month());
				fineMese = Date.newInstance(Date.parse(oggi).Year(), Date.parse(oggi).Month(), numeroGiorni + 1).format();
			} else if (anno == 'year') {
				oggi = Date.newInstance(System.Today().Year(), mese, System.Today().Day()).format();
				domani = Date.parse(oggi).addDays(1).format();
				inizioMese = Date.parse(oggi).toStartOfMonth().format();
				numeroGiorni = Date.daysInMonth(Date.parse(oggi).Year(), Date.parse(oggi).Month());
				fineMese = Date.newInstance(Date.parse(oggi).Year(), Date.parse(oggi).Month(), numeroGiorni + 1).format();
			} else if (anno == 'lastyear') {
				oggi = Date.newInstance(System.Today().addYears(- 1).Year(), mese, System.Today().Day()).format();
				domani = Date.parse(oggi).addDays(1).format();
				inizioMese = Date.parse(oggi).toStartOfMonth().format();
				numeroGiorni = Date.daysInMonth(Date.parse(oggi).Year(), Date.parse(oggi).Month());
				fineMese = Date.newInstance(Date.parse(oggi).Year(), Date.parse(oggi).Month(), numeroGiorni + 1).format();
			}

			res.allAndamentale = allAndamentale;
			res.appuntamentiMese = countAppuntamentiMese;
			res.contattiMese = countContattiMese;
			//res.appuntamentiMediGiorno = Math.round(( countVisiteMese / getWorkingDaysPassed() ));
			res.appuntamentiMediGiorno = (mese == System.Today().Month() && anno == 'year') ? Math.round((countVisiteMese / U.getWorkingDays(inizioMese, domani))) : Math.round((countVisiteMese / U.getWorkingDays(inizioMese, fineMese)));
			//res.successoMedio = countCTActual > 0 ? ( ( countVCActual / countCTActual ) ) : 0;
			res.successoMedio = countAppuntamentiMese > 0 ? (countAppuntamentiMese / countContattiMese) : 0;
			res.dates = new List<String> (datesSet);
			res.grafico = gList;
			res.utente = utente;
			res.successoGrafico = successList;
			//res.previsione = Math.round((countVisiteMese / getWorkingDaysPassed()) * (getWorkingDaysPassed() + getWorkingDaysRemaining()));
			res.previsione = (mese == System.Today().Month() && anno == 'year') ? Math.round((countVisiteMese / U.getWorkingDays(inizioMese, domani)) * (U.getWorkingDays(inizioMese, domani) + U.getWorkingDays(domani, fineMese))) : Math.round((countVisiteMese / U.getWorkingDays(inizioMese, fineMese)) * U.getWorkingDays(inizioMese, fineMese));
			//res.variazione = countVisiteVariazione > 0 ? (((countVisiteMese / getWorkingDaysPassed()) * (getWorkingDaysPassed() + getWorkingDaysRemaining())) - countVisiteVariazione) / countVisiteVariazione : 0;
			res.variazione = countVisiteVariazione > 0 ? (mese == System.Today().Month() && anno == 'year') ? (((countVisiteMese / U.getWorkingDays(inizioMese, domani)) * (U.getWorkingDays(inizioMese, domani) + U.getWorkingDays(domani, fineMese))) - countVisiteVariazione) / countVisiteVariazione : (((countVisiteMese / U.getWorkingDays(inizioMese, fineMese)) * (U.getWorkingDays(inizioMese, fineMese))) - countVisiteVariazione) / countVisiteVariazione : 0;
			res.graficoSuccesso = datiGraficoSuccessoTeam;
			res.graficoSuccessoTot = datiGraficoSuccessoTot;

			response.data.add(res);
		}
		catch(Exception e) {
			System.debug('@@@ exception e ' + e.getMessage() + ' -- ' + e.getLineNumber() + ' -- ' + e.getStackTraceString());
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
	//     // giorni.add(fineMese);

	//     for(Integer i = 0; i < daysBtw; i++){
	//         Date newDay = oggi.addDays(i);
	//         Date inizioSettimana = newDay.toStartOfWeek();
	//         if(Math.Mod(inizioSettimana.daysBetween(newDay) , 7) != 5 && Math.Mod(inizioSettimana.daysBetween(newDay) , 7) != 6 && newDay.Month() == System.Today().Month()){
	//             giorni.add(newDay);
	//         }
	//     }

	//     return giorni.size();
	// }

	@AuraEnabled
	public static WrapperResponse getTablesData() {
		WrapperResponse response = new WrapperResponse();

		try {
			List<WGC_Andamentale__c> andamentaleTotal = new List<WGC_Andamentale__c> ();
			andamentaleTotal = [SELECT Id, Name, Team__c, Operatore__r.Name, Operatore__c, Data__c, VC_Actual__c, CT_Actual__c, VC_Budget__c, CT_Budget__c, Budget__c, Ore_Actual__c, Motivo_Actual__c, Motivo_Budget__c FROM WGC_Andamentale__c WHERE Data__c = TODAY OR Data__c = TOMORROW ORDER BY Data__c ASC];
			List<WGC_Andamentale__c> oggi = new List<WGC_Andamentale__c> ();
			List<WGC_Andamentale__c> domani = new List<WGC_Andamentale__c> ();
			List<TabellaTeam> teamsOggi = new List<TabellaTeam> ();
			List<TabellaTeam> teamsDomani = new List<TabellaTeam> ();

			Decimal BudgetTot = 0;
			Decimal CT_BudgetTot = 0;
			Decimal VC_BudgetTot = 0;
			Decimal Ore_ActualTot = 0;
			Decimal CT_ActualTot = 0;
			Decimal VC_ActualTot = 0;
			//Domani
			Decimal Budget_DomaniTot = 0;
			Decimal CT_Budget_DomaniTot = 0;
			Decimal VC_Budget_DomaniTot = 0;
			Decimal Ore_Actual_DomaniTot = 0;
			Decimal CT_Actual_DomaniTot = 0;
			Decimal VC_Actual_DomaniTot = 0;

			for (WGC_Andamentale__c andamento : andamentaleTotal) {
				if (andamento.Data__c == System.Today()) {
					oggi.add(andamento);

					BudgetTot += andamento.Budget__c != null ? andamento.Budget__c : 0;
					CT_BudgetTot += andamento.CT_Budget__c != null ? andamento.CT_Budget__c : 0;
					VC_BudgetTot += andamento.VC_Budget__c != null ? andamento.VC_Budget__c : 0;
					Ore_ActualTot += andamento.Ore_Actual__c != null ? andamento.Ore_Actual__c : 0;
					CT_ActualTot += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
					VC_ActualTot += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
				}
				else if (andamento.Data__c == System.Today().addDays(1)) {
					domani.add(andamento);

					Budget_DomaniTot += andamento.Budget__c != null ? andamento.Budget__c : 0;
					CT_Budget_DomaniTot += andamento.CT_Budget__c != null ? andamento.CT_Budget__c : 0;
					VC_Budget_DomaniTot += andamento.VC_Budget__c != null ? andamento.VC_Budget__c : 0;
					Ore_Actual_DomaniTot += andamento.Ore_Actual__c != null ? andamento.Ore_Actual__c : 0;
					CT_Actual_DomaniTot += andamento.CT_Actual__c != null ? andamento.CT_Actual__c : 0;
					VC_Actual_DomaniTot += andamento.VC_Actual__c != null ? andamento.VC_Actual__c : 0;
				}
			}



			Map<String, List<WGC_Andamentale__c>> teamsMap = (Map<String, List<WGC_Andamentale__c>>) U.groupBy(andamentaleTotal, 'Team__c');
			for (String s : teamsMap.keySet()) {
				// TabellaTeam tbTeam = new TabellaTeam();
				Decimal Budget = 0;
				Decimal CT_Budget = 0;
				Decimal VC_Budget = 0;
				Decimal Ore_Actual = 0;
				Decimal CT_Actual = 0;
				Decimal VC_Actual = 0;
				//Domani
				Decimal Budget_Domani = 0;
				Decimal CT_Budget_Domani = 0;
				Decimal VC_Budget_Domani = 0;
				Decimal Ore_Actual_Domani = 0;
				Decimal CT_Actual_Domani = 0;
				Decimal VC_Actual_Domani = 0;

				for (WGC_Andamentale__c anda : teamsMap.get(s)) {
					if (anda.Data__c == System.Today()) {
						Budget += anda.Budget__c != null ? anda.Budget__c : 0;
						CT_Budget += anda.CT_Budget__c != null ? anda.CT_Budget__c : 0;
						VC_Budget += anda.VC_Budget__c != null ? anda.VC_Budget__c : 0;
						Ore_Actual += anda.Ore_Actual__c != null ? anda.Ore_Actual__c : 0;
						CT_Actual += anda.CT_Actual__c != null ? anda.CT_Actual__c : 0;
						VC_Actual += anda.VC_Actual__c != null ? anda.VC_Actual__c : 0;
					}

					if (anda.Data__c == System.Today().addDays(1)) {
						Budget_Domani += anda.Budget__c != null ? anda.Budget__c : 0;
						CT_Budget_Domani += anda.CT_Budget__c != null ? anda.CT_Budget__c : 0;
						VC_Budget_Domani += anda.VC_Budget__c != null ? anda.VC_Budget__c : 0;
						Ore_Actual_Domani += anda.Ore_Actual__c != null ? anda.Ore_Actual__c : 0;
						CT_Actual_Domani += anda.CT_Actual__c != null ? anda.CT_Actual__c : 0;
						VC_Actual_Domani += anda.VC_Actual__c != null ? anda.VC_Actual__c : 0;
					}
				}

				TabellaTeam tbTeamOggi = new TabellaTeam(System.Today(), s, Budget, CT_Budget, VC_Budget, Ore_Actual, CT_Actual, VC_Actual);
				teamsOggi.add(tbTeamOggi);

				TabellaTeam tbTeamDomani = new TabellaTeam(System.Today().addDays(1), s, Budget_Domani, CT_Budget_Domani, VC_Budget_Domani, Ore_Actual_Domani, CT_Actual_Domani, VC_Actual_Domani);
				teamsDomani.add(tbTeamDomani);

			}

			TabellaTeam tbTotaleOggi = new TabellaTeam(System.Today(), 'Totale', BudgetTot, CT_BudgetTot, VC_BudgetTot, Ore_ActualTot, CT_ActualTot, VC_ActualTot);
			TabellaTeam tbTotaleDomani = new TabellaTeam(System.Today().addDays(1), 'Totale', Budget_DomaniTot, CT_Budget_DomaniTot, VC_Budget_DomaniTot, Ore_Actual_DomaniTot, CT_Actual_DomaniTot, VC_Actual_DomaniTot);

			//ordino M.N.
			WGC_AndamentaleWrapper[] andamentoList = new List<WGC_AndamentaleWrapper> ();
			for (WGC_Andamentale__c og : oggi) {
				andamentoList.add(new WGC_AndamentaleWrapper(og));
			}
			andamentoList.sort();
			for (Integer i = 0; i<oggi.size(); i++) {
				oggi[i] = andamentoList[i].andamentale;
			}
			//oggi.sort();

			WGC_AndamentaleWrapper[] andamentoListDomani = new List<WGC_AndamentaleWrapper> ();
			for (WGC_Andamentale__c doma : domani) {
				andamentoListDomani.add(new WGC_AndamentaleWrapper(doma));
			}
			andamentoListDomani.sort();
			for (Integer i = 0; i<domani.size(); i++) {
				domani[i] = andamentoListDomani[i].andamentale;
			}

			//domani.sort();

			response.data.add(oggi);
			response.data.add(domani);
			response.data.add(teamsOggi);
			response.data.add(teamsDomani);
			response.data.add(tbTotaleOggi);
			response.data.add(tbTotaleDomani);
		}
		catch(Exception e) {
			response.message = e.getMessage();
			response.success = false;
		}

		return response;
	}

	public class WrapperResponse {
		@AuraEnabled public List<Object> data;
		@AuraEnabled public String message;
		@AuraEnabled public Boolean success;

		public WrapperResponse() {
			this.data = new List<Object> ();
			this.message = '';
			this.success = true;
		}
	}

	public class Result {
		@AuraEnabled public List<WGC_Andamentale__c> allAndamentale;
		@AuraEnabled public Decimal contattiMese;
		@AuraEnabled public Decimal appuntamentiMese;
		@AuraEnabled public Decimal appuntamentiMediGiorno;
		@AuraEnabled public Decimal previsione;
		@AuraEnabled public Decimal successoMedio;
		@AuraEnabled public Decimal variazione;
		@AuraEnabled public List<String> dates;
		@AuraEnabled public List<GraphResult> grafico;
		@AuraEnabled public List<SuccessGraphResult> graficoSuccesso;
		@AuraEnabled public List<SuccessGraphResult> graficoSuccessoTot;
		@AuraEnabled public List<Decimal> successoGrafico;
		@AuraEnabled public WrapperUtente utente;

		public Result() {
			this.allAndamentale = new List<WGC_Andamentale__c> ();
			this.contattiMese = 0;
			this.appuntamentiMese = 0;
			this.appuntamentiMediGiorno = 0;
			this.previsione = 0;
			this.successoMedio = 0;
			this.variazione = 0;
		}
	}

	public class GraphResult {
		@AuraEnabled public String nomeTeam;
		@AuraEnabled public Decimal visiteFissate;
		@AuraEnabled public String data;
		@AuraEnabled public Decimal myVisiteFissate;
		@AuraEnabled public String colore;

		public GraphResult() {
			this.nomeTeam = '';
			this.visiteFissate = 0;
			this.data = String.valueOf(System.Today());
		}

		public GraphResult(String nome, Decimal count, String dataD, Decimal myVisite, String coloreTeam) {
			this.nomeTeam = nome;
			this.visiteFissate = count;
			this.data = dataD;
			this.myVisiteFissate = myVisite == 0 ? null : myVisite;
			this.colore = coloreTeam;
		}
	}

	public class SuccessGraphResult {
		@AuraEnabled public String nomeTeam;
		@AuraEnabled public Decimal successo;
		@AuraEnabled public String data;
		@AuraEnabled public String colore;

		public SuccessGraphResult(String nome, String data, Decimal success, String colore) {
			this.nomeTeam = nome;
			this.successo = success;
			this.data = data;
			this.colore = colore;
		}
	}

	public class WrapperUtente {
		@AuraEnabled public String nomeUtente;
		@AuraEnabled public String nomeTeam;

		public WrapperUtente() {
			this.nomeUtente = '';
			this.nomeTeam = '';
		}

		public WrapperUtente(String utente, String team) {
			this.nomeUtente = utente;
			this.nomeTeam = team;
		}
	}

	public class TabellaTeam {
		@AuraEnabled public Date Data;
		@AuraEnabled public String Team;
		@AuraEnabled public Decimal Budget;
		@AuraEnabled public Decimal CT_Budget;
		@AuraEnabled public Decimal VC_Budget;
		@AuraEnabled public Decimal Ore_Actual;
		@AuraEnabled public Decimal CT_Actual;
		@AuraEnabled public Decimal VC_Actual;

		public TabellaTeam() {
			this.Data = Data;
			this.Team = Team;
			this.Budget = Budget;
			this.CT_Budget = CT_Budget;
			this.VC_Budget = VC_Budget;
			this.Ore_Actual = Ore_Actual;
			this.CT_Actual = CT_Actual;
			this.VC_Actual = VC_Actual;
		}

		public TabellaTeam(Date Data, String Team, Decimal Budget, Decimal CT_Budget, Decimal VC_Budget, Decimal Ore_Actual, Decimal CT_Actual, Decimal VC_Actual) {
			this.Data = Data;
			this.Team = Team;
			this.Budget = Budget;
			this.CT_Budget = CT_Budget;
			this.VC_Budget = VC_Budget;
			this.Ore_Actual = Ore_Actual;
			this.CT_Actual = CT_Actual;
			this.VC_Actual = VC_Actual;
		}
	}
}