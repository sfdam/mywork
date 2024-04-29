({
    doInit: function (component, event, helper) {
        helper.apex(component, event, 'getUserInfo', {  })
        .then($A.getCallback(function (result) {
            console.log('Call getUserInfo result: ', result);
            component.set('v.userInfo', result);

            return helper.apex(component, event, 'getAllData', {})
            
            
        })).then($A.getCallback(function (result) {
                console.log('SV result ', result);
                component.set('v.allDataValue', result);

                helper.generateChart(helper.dataChart('thisYear', result, component, event), helper.optionsChart(component, event), 'bar', 'chartJS_Opp', component, event);

            })).finally($A.getCallback(function () {

                // var result = component.get('v.allDataValue');
                // console.log('SV result ', result);
                // var numCampOpenTaskClose = 0;
                // var numCampOpenTaskOpen = 0;
                // var numCampCloseTaskOpen = 0;
                // result.taskListIC.forEach(function (element) {
                //     if (element.Status == 'Chiuso') {
                //         if (element.Campagna__r != undefined && element.Campagna__r.Status == 'In Progress') {
                //             numCampOpenTaskClose++;
                //         }
                //     } else {
                //         if (element.Campagna__r != undefined && element.Campagna__r.Status != 'In Progress') {
                //             numCampCloseTaskOpen++;
                //         } else if (element.Campagna__r != undefined && element.Campagna__r.Status != 'Completed') {
                //             numCampOpenTaskOpen++;
                //         }
                //     }
                // });
                // component.set('v.numCampOpenTaskClose', numCampOpenTaskClose);
                // component.set('v.numCampOpenTaskOpen', numCampOpenTaskOpen);
                // component.set('v.numCampCloseTaskOpen', numCampCloseTaskOpen);

                var today = new Date();
                var yearDate = today.getFullYear();
                var monthDate = today.getMonth() + 1;
        
                var resultList = component.get('v.allDataValue').data[0];
                console.log('RESULT LIST : ', resultList);

                
		        var userInfo = component.get('v.userInfo');

                if(userInfo.Qualifica_Utente__c == 'Filo Diretto'){

                } else {

                    var sumDiffOppAccountDateThis = 0;
                    var sumDiffOppAccountDateLast = 0;

                    component.set('v.Valore1', resultList.valCampagna);
                    component.set('v.Valore2', resultList.valCampaignMember);
                    component.set('v.Valore3', resultList.valOpportunity);

                    resultList.accountList.forEach(function (element) {
                        let elementYear = new Date(element.Data_New_Business__c).getFullYear();
                        if(elementYear == yearDate){
                            if (!element.Anagrafica__r.WGC_Originator__c == 'Diretto') {
                                var o = resultList.opportunityList.find(o => {return element.Anagrafica__r.AccountId == o.AccountId });
                                if(o){
                                    if(!o.Originator__c == 'Diretto' && o.StageName != 'In Istruttoria'){
                                        let opportunityDate = new Date(o.Data_Inizio__c);
                                        let accountDate = new Date(element.Anagrafica__r.CreatedDate);
                                        sumDiffOppAccountDateThis = sumDiffOppAccountDateThis + (opportunityDate.getDate() - accountDate.getDate() > 0 ? opportunityDate.getDate() - accountDate.getDate() : 0);
                                    }
                                }
                            }
                        } else {
                            if (!element.Anagrafica__r.WGC_Originator__c == 'Diretto') {
                                var o = resultList.opportunityList.find(o => {return element.Anagrafica__r.AccountId == o.AccountId });
                                if(o){
                                    if(!o.Originator__c == 'Diretto' && o.StageName != 'In Istruttoria'){
                                        let opportunityDate = new Date(o.Data_Inizio__c);
                                        let accountDate = new Date(element.Anagrafica__r.CreatedDate);
                                        sumDiffOppAccountDateLast = sumDiffOppAccountDateLast + (opportunityDate.getDate() - accountDate.getDate() > 0 ? opportunityDate.getDate() - accountDate.getDate() : 0);
                                    }
                                }
                            }
                        }
                    });

                    component.set('v.oppAccountTimeThis', sumDiffOppAccountDateThis / monthDate);                
                    component.set('v.oppAccountTimeLast', sumDiffOppAccountDateLast / monthDate);
                    
                    var sumDiffEventOpportunityDateThis = 0;
                    var sumDiffEventOpportunityDateLast = 0;
                    resultList.opportunityList.forEach(function (element) {
                        let elementYear = new Date(element.Data_Inizio__c).getFullYear();
                        if(elementYear == yearDate){
                            if (!(element.Originator__c == 'Diretto')) {
                                var e = resultList.eventList.find(e => {return element.AccountId == e.AccountId });
                                if(e){
                                    if(!(e.Originator__c == 'Diretto')){
                                        let opportunityDate = new Date(element.Data_Inizio__c);
                                        let eventDate = new Date(e.Data_Inizio__c);
                                        sumDiffEventOpportunityDateThis = sumDiffEventOpportunityDateThis + (opportunityDate.getDate() - eventDate.getDate() > 0 ? opportunityDate.getDate() - eventDate.getDate() : 0);
                                    }
                                }
                            }
                        } else {
                            if (!element.Originator__c == 'Diretto') {
                                var e = resultList.eventList.find(e => {return element.AccountId == e.AccountId });
                                if(e){
                                    if(!e.Originator__c == 'Diretto'){
                                        let opportunityDate = new Date(element.Data_Inizio__c);
                                        let eventDate = new Date(e.Data_Inizio__c);
                                        sumDiffEventOpportunityDateLast = sumDiffEventOpportunityDateLast + (opportunityDate.getDate() - eventDate.getDate() > 0 ? opportunityDate.getDate() - eventDate.getDate() : 0);
                                    }
                                }
                            }
                        }
                    });

                    component.set('v.eventOppTimeThis', sumDiffEventOpportunityDateThis / monthDate);                
                    component.set('v.eventOppTimeLast', sumDiffEventOpportunityDateLast / monthDate);

                    var sumDiffTaskEventDateThis = 0;
                    var sumDiffTaskEventDateLast = 0;
                    resultList.eventList.forEach(function (element) {
                        let elementYear = new Date(element.Data_Inizio__c).getFullYear();
                        if(elementYear == yearDate){
                            if (!(element.Originator__c == 'Diretto')) {
                                var t = resultList.taskList.find(t => {return element.AccountId == t.AccountId });
                                if(t){
                                    if(!(t.Originator__c == 'Diretto')){
                                        let eventDate = new Date(element.Data_Inizio__c);
                                        let taskDate = new Date(t.Data_Inizio__c);
                                        sumDiffTaskEventDateThis = sumDiffTaskEventDateThis + (eventDate.getDate() - taskDate.getDate() > 0 ? eventDate.getDate() - taskDate.getDate() : 0);
                                    }
                                }
                            }
                        } else {
                            if (!element.Originator__c == 'Diretto') {
                                var t = resultList.taskList.find(t => {return element.AccountId == t.AccountId });
                                if(t){
                                    if(!t.Originator__c == 'Diretto'){
                                        let eventDate = new Date(element.Data_Inizio__c);
                                        let taskDate = new Date(t.Data_Inizio__c);
                                        sumDiffTaskEventDateLast = sumDiffTaskEventDateLast + (eventDate.getDate() - taskDate.getDate() > 0 ? eventDate.getDate() - taskDate.getDate() : 0);
                                    }
                                }
                            }
                        }
                    });

                    component.set('v.taskEventTimeThis', sumDiffTaskEventDateThis / monthDate);                
                    component.set('v.taskEventTimeLast', sumDiffTaskEventDateLast / monthDate);

                    var redemptionBP_This_Year = 0;
                    var convertionBP_This_Year = 0;
                    var redemptionBP_Last_Year = 0;
                    var convertionBP_Last_Year = 0;
                    var qualitaBP_This_Year = 0;
                    var qualitaBP_Last_Year = 0;
                    resultList.bestPracticeList.forEach(function (element) {
                        if(element.Year__c == 'Corrente'){
                            console.log(element);
                            redemptionBP_This_Year = parseFloat(redemptionBP_This_Year) + parseFloat(element.Redemption_Dettaglio__c);
                            convertionBP_This_Year = parseFloat(convertionBP_This_Year) + parseFloat(element.Convertion_Dettaglio__c);
                            qualitaBP_This_Year = parseFloat(qualitaBP_This_Year) + parseFloat(element.Qualita_Dettaglio__c);
                        } else {
                            redemptionBP_Last_Year = parseFloat(redemptionBP_Last_Year) + parseFloat(element.Redemption_Dettaglio__c);
                            convertionBP_Last_Year = parseFloat(convertionBP_Last_Year) + parseFloat(element.Convertion_Dettaglio__c);
                            qualitaBP_Last_Year = parseFloat(qualitaBP_Last_Year) + parseFloat(element.Qualita_Dettaglio__c);
                        }
                    });

                    redemptionBP_This_Year = parseFloat(redemptionBP_This_Year) / parseFloat((resultList.bestPracticeList.length / 2));
                    convertionBP_This_Year = parseFloat(convertionBP_This_Year) / parseFloat((resultList.bestPracticeList.length / 2));
                    redemptionBP_Last_Year = parseFloat(redemptionBP_Last_Year) / parseFloat((resultList.bestPracticeList.length / 2));
                    convertionBP_Last_Year = parseFloat(convertionBP_Last_Year) / parseFloat((resultList.bestPracticeList.length / 2));
                    qualitaBP_This_Year = parseFloat(qualitaBP_This_Year) / parseFloat((resultList.bestPracticeList.length / 2));
                    qualitaBP_Last_Year = parseFloat(qualitaBP_Last_Year) / parseFloat((resultList.bestPracticeList.length / 2));

                    component.set('v.bestPractice_Redemption_ThisYear', parseFloat(redemptionBP_This_Year / 100));
                    component.set('v.bestPractice_Convertion_ThisYear', parseFloat(convertionBP_This_Year / 100));
                    component.set('v.bestPractice_Redemption_LastYear', parseFloat(redemptionBP_Last_Year / 100));
                    component.set('v.bestPractice_Convertion_LastYear', parseFloat(convertionBP_Last_Year / 100));
                    component.set('v.bestPractice_Qualita_ThisYear', parseFloat(qualitaBP_This_Year / 100));
                    component.set('v.bestPractice_Qualita_LastYear', parseFloat(qualitaBP_Last_Year / 100));


                    // SET ID DASHBOARD
                    component.set('v.idDashboard', component.get("v.pageReference").state.c__idDashboard);
                    
                }
                
            }));

        // component.set('v.columns', [
        //     { label: '', fieldName: 'classification', type: 'text' },
        //     { label: 'Lead', fieldName: 'leadNumber', type: 'text' },
        //     { label: 'Avvio - Termine', fieldName: 'startEnd', type: 'text' },
        //     { label: 'Contatti', fieldName: 'contacts', type: 'text' },
        //     { label: 'Visite', fieldName: 'visits', type: 'text' },
        //     { label: 'Opportunità', fieldName: 'opportunity', type: 'text' },
        //     { label: 'Attivazioni', fieldName: 'activations', type: 'text' }
        // ]);

        // var fetchData = {
        //     classification: "classification",
        //     leadNumber: "leadNumber",
        //     startEnd: "startEnd",
        //     contacts: "contacts",
        //     visits: "visits",
        //     opportunity: "opportunity",
        //     activations: "activations"
        // };

        // component.set('v.data', [{
        //     classification: "Logistica",
        //     leadNumber: "8",
        //     startEnd: "06 Gen 2018 - 04 Mag 2018",
        //     contacts: "60 | 75%",
        //     visits: "6",
        //     opportunity: "5",
        //     activations: "4"
        // },
        // {
        //     classification: "Portafoglio",
        //     leadNumber: "2",
        //     startEnd: "06 Feb 2018 - 15 Giu 2018",
        //     contacts: "60 | 50%",
        //     visits: "1",
        //     opportunity: "1",
        //     activations: "2"
        // }]);
    },

    navigateToMyComponent: function (component, event, helper) {

        var navService = component.find("navService");
        var pageReference = {
            "type": "standard__namedPage",
            "attributes": {
                "pageName": "home"
            }
        }

        navService.navigate(pageReference);
    },

    navigateToDashboard: function (component, event, helper) {

        var navService = component.find("navService");
        var pageReference = {    
            "type": "standard__recordPage",
            "attributes": {
                "recordId": component.get("v.idDashboard"),
                "objectApiName": "Dashboard",
                "actionName": "view"
            }
        };

        navService.navigate(pageReference);
    },

    selectPeriodo: function (component, event, helper) {
        var year = event.getParam('value');
        var result = component.get('v.allDataValue');
        helper.generateChart(helper.dataChart(year, result, component, event), helper.optionsChart(component, event), 'bar', 'chartJS_Opp', component, event);

    },

})