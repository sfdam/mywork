({
    getUserInfo: function (component, event) {
        //Setting the Callback
        var action = component.get("c.getUserInfo");

        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('SV PIPELINE: ', result);

                var accountId = [];
                var clientiAvviati = 0;
                result.data[0].accountList.forEach(function (element) {
                    if (true) {
                        clientiAvviati++;
                        accountId.push(element.Anagrafica__r.Id);
                    }
                });

                component.set('v.account', clientiAvviati);
                console.log('clientiAvviati: ' + clientiAvviati);


                var oppInRedazioneContratti = 0;
                var oppVP = 0;
                var oppAll = 0;
                result.data[0].opportunityList.forEach(function (element) {
                    if (element.StageName == 'Perfezionamento Contratto' || (element.hasOwnProperty('FaseDiCaduta__c') && element.FaseDiCaduta__c == 'Perfezionamento Contratto')) {
                        if (!accountId.includes(element.AccountId)) {
                            accountId.push(element.AccountId);
                            oppInRedazioneContratti++;
                        }
                    }
                });

                oppInRedazioneContratti = oppInRedazioneContratti + clientiAvviati;
                component.set('v.opportunitaD', oppInRedazioneContratti);
                console.log('oppD: ' + oppInRedazioneContratti);

                result.data[0].opportunityList.forEach(function (element) {
                    if (element.StageName == 'Valutazione Pratica') {
                        if (!accountId.includes(element.AccountId)) {
                            accountId.push(element.AccountId);
                            oppVP++;
                        }
                    }
                });

                oppVP = oppVP + oppInRedazioneContratti;
                component.set('v.opportunita', oppVP);
                console.log('oppVP: ' + oppVP);

                result.data[0].opportunityList.forEach(function (element) {
                    if (element.StageName == 'In Istruttoria') {
                        if (!accountId.includes(element.AccountId)) {
                            accountId.push(element.AccountId);
                            oppAll++;
                        }
                    }
                });

                oppAll = oppAll + oppVP;
                console.log('oppAll: ' + oppAll);

                var eventC = 0;
                result.data[0].eventList.forEach(function (element) {
                    if (element.Stato__c.indexOf('alt="Chiuso"') != -1) {
                        if (!accountId.includes(element.AccountId)) {
                            accountId.push(element.AccountId);
                            eventC++;
                        }
                    }
                });

                eventC = eventC + oppAll;
                component.set('v.aziendeVisitate', eventC);
                console.log('eventC: ' + eventC);

                var eventA = 0;
                result.data[0].eventList.forEach(function (element) {
                    if (element.Stato__c.indexOf('alt="Aperto"') != -1) {
                        if (!accountId.includes(element.AccountId)) {
                            accountId.push(element.AccountId);
                            eventA++;
                        }
                    }
                });

                eventA = eventA + eventC;
                console.log('eventA: ' + eventA);

                var task = 0;
                var numCampOpenTaskClose = 0;
                var numCampOpenTaskOpen = 0;
                var numCampCloseTaskOpen = 0;
                result.data[0].taskList.forEach(function (element) {
                    if (!accountId.includes(element.AccountId)) {
                        if (element.RecordType.DeveloperName != 'Promemoria') {
                            if (element.Status == 'Chiuso') {
                                console.log(element.AccountId);
                                accountId.push(element.AccountId);
                                task++;
                            }
                        }
                    }


                    if(element.Status == 'Chiuso'){
                        if(element.Campagna__r != undefined && element.Campagna__r.Status == 'In Progress'){
                            numCampOpenTaskClose ++;
                        }
                    } else {
                        if(element.Campagna__r != undefined  && element.Campagna__r.Status != 'In Progress'){
                            numCampCloseTaskOpen ++;
                        } else if(element.Campagna__r != undefined  && element.Campagna__r.Status != 'Completed') {
                            numCampOpenTaskOpen ++;
                        }
                    }
                });

                task = task + eventA;
                component.set('v.aziendeContattate', task);
                component.set('v.numCampOpenTaskClose', numCampOpenTaskClose);
                component.set('v.numCampOpenTaskOpen', numCampOpenTaskOpen);
                component.set('v.numCampCloseTaskOpen', numCampCloseTaskOpen);

                // The percentage increase from 30 to 40 is:  

                var percentTaskOpen = 90;
                var percentTaskClose = 90;
                if(numCampOpenTaskClose == 0){
                    if(numCampOpenTaskOpen != 0){
                        percentTaskClose = 0;
                    }
                }

                if(numCampOpenTaskOpen == 0){
                    if(numCampOpenTaskClose != 0){
                        percentTaskOpen = 0;
                    } 
                } 

                if(numCampOpenTaskOpen == 0 && numCampOpenTaskClose == 0){
                    percentTaskOpen = 90;
                    percentTaskClose = 45;
                }

                if(numCampOpenTaskOpen != 0 && numCampOpenTaskClose != 0){
                    if(numCampOpenTaskOpen == numCampOpenTaskClose){
                        percentTaskOpen = 90;
                        percentTaskClose = 45;
                    } else {
                        var x = 0;
                        if(numCampOpenTaskOpen > numCampOpenTaskClose){
                            x = (numCampOpenTaskClose / numCampOpenTaskOpen) * 100;
                            percentTaskClose = this.neighbor(x);
                            percentTaskOpen = 100 - percentTaskClose;
                        } else {
                            x = (numCampOpenTaskOpen / numCampOpenTaskClose) * 100;
                            percentTaskClose = this.neighbor(x);
                            percentTaskOpen = 100 - percentTaskClose;
                        }
                    }
                } 

                component.set('v.percentTaskOpen', percentTaskOpen);
		        component.set('v.percentTaskClose', percentTaskClose);

                component.set('v.redemption', (task > 0) ? clientiAvviati / task : 0);
                component.set('v.convertion', (eventC > 0) ? clientiAvviati / eventC : 0);
                
                var redemptionBP = 0;
                var convertionBP = 0;
                result.data[0].bestPracticeList.forEach(function (element) {
                    redemptionBP = parseFloat(redemptionBP) + parseFloat(element.Redemption_Dettaglio__c);
                    convertionBP = parseFloat(convertionBP) + parseFloat(element.Convertion_Dettaglio__c);
                });

                redemptionBP = parseFloat(redemptionBP / result.data[0].bestPracticeList.length);
                convertionBP = parseFloat(convertionBP / result.data[0].bestPracticeList.length);

                component.set('v.bestPractice_Redemption', parseFloat(redemptionBP / 100));
                component.set('v.bestPractice_Convertion', parseFloat(convertionBP / 100));



            } else if (state == "ERROR") {
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },

    neighbor: function (value) {
        var y= 0;
        if(value >= 15 && value < 30){
            y = 15;
        } else if(value >= 30 && value < 45){
            y = 30;
        } else if(value >= 45 && value < 60){
            y = 45;
        } else if(value >= 60 && value < 75){
            y = 60;
        } else if(value >= 75){
            y = 75;
        }
        return y;
    }
})