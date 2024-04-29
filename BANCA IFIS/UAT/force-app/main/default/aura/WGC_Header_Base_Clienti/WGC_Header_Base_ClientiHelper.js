({
	getAccountInfo: function (component, event) {
        //Setting the Callback
        var action = component.get("c.getAccountInfo");

        action.setCallback(this, function (response) {
            //get the response state
            var state = response.getState();

            //check if result is successfull
            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('@@@ result clienti ' , result);
				
				var clientiAttivatiHold = 0;
				var clientiAttivatiThis = 0;
				var clientiIncertiHold  = 0;
				var clientiIncertiThis  = 0;
				var clientiDormientiHold  = 0;
				var clientiDormientiThis  = 0;
				var clientiInattiviHold  = 0;
				var clientiInattiviThis  = 0;
				var clientiRevocatiHold  = 0;
				var clientiRevocatiThis  = 0;
				//var currentYear = (new Date()).getFullYear();
				for(var key in result.data[0]){
					result.data[0][key].forEach(function (element) {
						console.log('@@@ element ' , element);
						console.log('@@@ key ' , key);

						switch (key){
							case 'accountIncerti':
								clientiIncertiThis = element.conteggio;
								break;
							case 'accountDormienti':
								clientiDormientiThis = element.conteggio;
								break;
							case 'accountInattivi':
								clientiInattiviThis = element.conteggio;
								break;
							case 'accountPersi':
								clientiRevocatiThis = element.conteggio;
								break;	
						}

						
					});
				}

				component.set('v.clientiAttivi', clientiAttivatiThis);
				component.set('v.clientiIncerti', clientiIncertiThis);
				component.set('v.clientiDormienti', clientiDormientiThis);
				component.set('v.clientiInattivi', clientiInattiviThis);
				component.set('v.clientiRevocati', clientiRevocatiThis);

				// console.log('@@@ clientiAttivatiThis ' , clientiAttivatiThis);
				// console.log('@@@ clientiIncertiThis ' , clientiIncertiThis);
				// console.log('@@@ clientiDormientiThis ' , clientiDormientiThis);
				// console.log('@@@ clientiInattiviThis ' , clientiInattiviThis);
				// console.log('@@@ clientiRevocatiThis ' , clientiRevocatiThis);

				if(clientiAttivatiHold <= clientiAttivatiThis) component.set('v.clientiAttiviDiff', true);
				if(clientiIncertiHold <= clientiIncertiThis) component.set('v.clientiIncertiDiff', true);
				if(clientiDormientiHold <= clientiDormientiThis) component.set('v.clientiDormientiDiff', true);
				if(clientiInattiviHold <= clientiInattiviThis) component.set('v.clientiInattiviDiff', true);
				if(clientiRevocatiHold <= clientiRevocatiThis) component.set('v.clientiRevocatiDiff', true);
                

            } else if (state == "ERROR") {
				console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
            }
        });
        $A.enqueueAction(action);
    },
})