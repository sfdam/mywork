({
    getUserInfo: function (component, event) {
        //Setting the Callback
        var action = component.get("c.getUserInfo");

        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                var today = new Date(Date.now());
                var d = new Date();
                d.setHours(0,0,0);
                var mond = this.getMonday(d);

                var result = response.getReturnValue();
                console.log(result);

                component.set('v.budgetList', result.data[0].budgetList);
                var budgetListAttiviMounth = [0,0,0,0,0,0,0,0,0,0,0,0];
                result.data[0].budgetList.forEach(function (element) {
                    if (element.Mese__c - 1 <= today.getMonth()){
                        budgetListAttiviMounth[element.Mese__c - 1] = element.Clienti_avviati__c;
                        if(element.Mese__c - 1 == today.getMonth()){
                            component.set('v.budgetMounth', element);
                        }
                    }
                });

                component.set('v.accountList', result.data[0].accountList);
                var mounthClient = 0;
                var weekClient = 0;
                var accountListAttiviMounth = [0,0,0,0,0,0,0,0,0,0,0,0];
                result.data[0].accountList.forEach(function (element) {
                    var CreatedDate = new Date(element.Data_New_Business__c);
                        accountListAttiviMounth[CreatedDate.getMonth()]++;
                        if (today.getMonth() === CreatedDate.getMonth() && CreatedDate.getDate() >= mond.getDate() && CreatedDate.getDate() <= mond.getDate() + 5) {
                            weekClient++;
                        }
                        if (today.getMonth() === CreatedDate.getMonth()) {
                            mounthClient++;
                        }

                });
                component.set('v.clientiAttiviMounth', mounthClient);
                component.set('v.clientiAttiviWeek', weekClient);

                var accountInVisId_Month = [];
                var mounthEvent = 0;
                var weekEvent = 0;
                result.data[0].eventList.forEach(function (element) {
                    var oncomingEvent = new Date(element.Data_Inizio__c);
                    if (!accountInVisId_Month.includes(element.AccountId) && today.getMonth() === oncomingEvent.getMonth()) {
                        if (oncomingEvent.getDate() >= mond.getDate() && oncomingEvent.getDate() <= mond.getDate() + 5) {
                            weekEvent ++;
                        }

                        mounthEvent++;
                        accountInVisId_Month.push(element.AccountId);
                    }
                });
                component.set('v.weekEvent', weekEvent);
                component.set('v.mounthEvent', mounthEvent);

                var accountInOppId_Month = [];
                var mounthOpp = 0;
                var weekOpp = 0;
                result.data[0].opportunityList.forEach(function (element) {
                    var oncomingopp = new Date(element.Data_Inizio__c);
                    if (!accountInOppId_Month.includes(element.AccountId) && today.getMonth() === oncomingopp.getMonth()) {
                        if (oncomingopp.getDate() >= mond.getDate() && oncomingopp.getDate() <= mond.getDate() + 5) {
                            weekOpp ++;
                        }

                        mounthOpp++;
                        accountInOppId_Month.push(element.AccountId);
                    }
                });
                
                component.set('v.weekOpp', weekOpp);
                component.set('v.mounthOpp', mounthOpp);

                this.generateChart(today, accountListAttiviMounth, budgetListAttiviMounth, component, event);


            } else if (state == "ERROR") {
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },

    getMonday: function (d) {
        d = new Date(d);
        var day = d.getDay(),
            diff = d.getDate() - day + (day == 0 ? -6 : 1); // adjust when day is sunday
        return new Date(d.setDate(diff));
    },

    generateChart: function(date, accountList, budgetList, component, event){
        console.log('generateChart:  ' + date.getMonth());

        var data = {
            labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
            datasets: [{
                label: "Actual",
                backgroundColor: "#0064B5",
                borderColor: "#0064B5",
                borderWidth: 1,
                data: accountList
                }, {
                label: "Passo",
                backgroundColor: "rgb(216,216,216)",
                borderColor: "rgb(216,216,216)",
                borderWidth: 1,
                data: budgetList
                }
            ]
        };

        var chartOptions = {
            responsive: true,
            maintainAspectRatio: false,
            legend: {
                
                position: "top",
                labels: {
                    boxWidth: 10
                }
            },
            title: {
                display: false,
                text: "Chart.js Bar Chart"
            },
            scales: {
                yAxes: [{
                    ticks: {
                        display: false,
                        beginAtZero: true
                    },
                    gridLines: {
                        display: false,
                        drawBorder: false,
                    }
                }],
                xAxes: [{
                    ticks: {

                    },
                    gridLines: {
                        display: false
                    }
                }]
            },
            tooltips: {
                mode: 'label',
                callbacks: {
                    label: function(tooltipItem, data) {
                        var corporation = data.datasets[tooltipItem.datasetIndex].label;
                        var valor = data.datasets[tooltipItem.datasetIndex].data[tooltipItem.index];
                        var total = 0;
                        total = data.datasets[0].data[tooltipItem.index] - data.datasets[1].data[tooltipItem.index];
                        if (tooltipItem.datasetIndex != data.datasets.length - 1) {
                            return corporation + " : " + valor.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,');
                        } else {
                            return [corporation + " : " + valor.toFixed(2).replace(/(\d)(?=(\d{3})+\.)/g, '$1,'), "Total : " + total];
                        }
                    }
                }
            },
        };

        Chart.Bar('chartJS_Home_NB', {
            options: chartOptions,
            data: data
        });
    }

})