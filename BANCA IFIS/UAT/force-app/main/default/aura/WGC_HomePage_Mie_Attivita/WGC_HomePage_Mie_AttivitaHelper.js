({
    getUserEvent: function (component, event) {
        //Setting the Callback
        var action = component.get("c.getActivityUser");

        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                var today = new Date(Date.now());
                console.log(result);
                component.set('v.userEvent', result.data[0].eventList);
                component.set('v.userTask', result.data[0].taskList);

                var dailyTask = result.data[0].todayTask;
                component.set('v.dailyTask', dailyTask);

                var mounthEvent = 0;
                var daysInMounth = this.getDaysInMonth(today.getMonth(), today.getFullYear());
                var daysEventArray = new Map();
                var setOnComingEvent = false;
                result.data[0].eventList.forEach(function (element) {
                    var oncomingEvent = new Date(element.ActivityDateTime);
                    if (oncomingEvent >= today && !setOnComingEvent) {
                        setOnComingEvent = true;
                        component.set('v.oncomingDateEvent', oncomingEvent.getDate() + "/" + (oncomingEvent.getMonth() + 1) + "/" + oncomingEvent.getFullYear());
                        component.set('v.oncomingTimeEvent', oncomingEvent.getHours() + ':' + ((oncomingEvent.getMinutes() == '0') ? '00' : oncomingEvent.getMinutes()));
                        component.set('v.oncomingNameEvent', (element.Account != undefined && element.Account.Name != undefined) ? element.Account.Name : ''  );
                    }

                    if (today.getMonth() === oncomingEvent.getMonth()) {
                        mounthEvent++;
                        daysEventArray.set(oncomingEvent.getDate(), true);
                    }
                });
                component.set('v.mounthEvent', mounthEvent);
                component.set('v.dayInMounthFreeEvent', daysInMounth - daysEventArray.size);

                var before30Day = new Date(new Date().setDate(today.getDate() - 30));
                var after30Date = new Date(new Date().setDate(today.getDate() + 30));
        
                var numScadutiLIR = result.data[0].lir.numScadutiLIR;
                var numAScadereLIR = result.data[0].lir.numAScadereLIR;

                var numScadutiLP = result.data[0].lp.numScadutiLP;
                var numAScadereLP = result.data[0].lp.numAScadereLP;

                var numScadutiQQ = result.data[0].qq.numScadutiQQ;
                var numAScadereQQ = result.data[0].qq.numAScadereQQ;


                component.set('v.numScaduti', numScadutiLIR + numScadutiLP + numScadutiQQ);
                component.set('v.numAScadere', numAScadereLIR + numAScadereLP + numAScadereQQ);

                component.set('v.numLIR', numScadutiLIR + numAScadereLIR);
                component.set('v.numLP', numScadutiLP + numAScadereLP);
                component.set('v.numQQ', numScadutiQQ + numAScadereQQ);


            } else if (state == "ERROR") {
                alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },


    /*
    getDaysInMonth: function (month, year) {
        console.log('month: ' + month);
        console.log('year: ' + year);
        // Here January is 1 based
        //Day 0 is the last day in the previous month
        return new Date(year, month, 0).getDate();
        // Here January is 0 based
        // return new Date(year, month+1, 0).getDate();
    }
    */

    getDaysInMonth: function (month, year) {

        var date = new Date(year, month, 1);
        var days = [];
        while (date.getMonth() === month) {

            // Exclude weekends
            var tmpDate = new Date(date);
            var weekDay = tmpDate.getDay(); // week day
            var day = tmpDate.getDate(); // day

            if (weekDay % 6) { //  0=All Week *** 6=Week without Weekend
                days.push(day);
            }

            date.setDate(date.getDate() + 1);
        }

        if (days.length === 0) return new Date(year, month, 0).getDate();

        return days.length;
    }
})