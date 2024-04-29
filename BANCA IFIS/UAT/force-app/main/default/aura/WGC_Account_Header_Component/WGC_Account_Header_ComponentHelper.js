({
	getAccountData : function(component, event) {

		var action = component.get("c.getPositionRecords");
        
        //Setting the Callback
        action.setCallback(this,function(a){
            //get the response state
            var state = a.getState();
            
            //check if result is successfull
            if(state == "SUCCESS"){
                console.log("SUCCESS");
                var result = a.getReturnValue();
                console.log(result);
                if(!$A.util.isEmpty(result) && !$A.util.isUndefined(result))
                    component.set("v.inputObject",result);
            } else if(state == "ERROR"){
                console.log('Error in calling server side action: ', result);
                // alert('Error in calling server side action');
            }
        });
        
        //adds the server-side action to the queue        
        $A.enqueueAction(action);
		
    },
    
    getOtherAccountData : function(component, event, helper){
        var action = component.get("c.getAccountHeaderData");
        action.setParams({
            accountId : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() == "SUCCESS"){
                var risposta = response.getReturnValue();
                console.log('@@@ accountHeaderData RISPOSTA: ', risposta);
                //Setto risposta iniziale
                component.set("v.accountHeaderData", risposta);
                //Converto la data del task nel formato corretto
                if(risposta.data[0].lstT.length > 0){
                    var strDataTask = risposta.data[0].lstT[0].Data_Inizio__c;
                    if(strDataTask != null){
                    //Converto da stringa in data
                    var dataTask = new Date(strDataTask);
                    //Prendo il giorno
                    var giornoTask = risposta.data[0].lstT[0].Data_Inizio__c.substring(8,10);
                    //Converto in lettere il mese
                    var meseTask = dataTask.toLocaleString('it-IT', { month: 'short' });
                    //Setto la data del task formattata
                    risposta.data[0].lstT[0].Data_Inizio__c = giornoTask + ' ' + meseTask;
                    }
                }
                if(risposta.data[0].lstE.length > 0){

                    var strDataEvent = risposta.data[0].lstE[0].ActivityDateTime;
                    //Converto da stringa in data
                    var dataEvent = new Date(strDataEvent);
                    //Prendo il giorno
                    var giornoEvent = risposta.data[0].lstE[0].ActivityDateTime.substring(8,10);
                    //Converto in lettere il mese
                    var meseEvent = dataEvent.toLocaleString('it-IT', { month: 'short' });
                    //Setto la data del task formattata
                    risposta.data[0].lstE[0].ActivityDateTime = giornoEvent + ' ' + meseEvent;
                }
                //Setto la risposta dopo aver modificato le date
                component.set("v.accountHeaderData", risposta);
                helper.isFastFinanceProfile(component);
            }
            else{
                alert('error');
            }
        });
        $A.enqueueAction(action);
    },

    setupIcons: function(component, event) {
        let isLegalEntityNot881 = false;
        let isLegalEntity881 = false;
        let h = this;

        console.log("NDG: ", component.get("v.accountRecord").NDG__c);
        console.log("CodIst: ", component.get("v.accountRecord").CodiceIstituto3N__c);

        this.callServer(component, "c.getLegalEntities", function(result) {
            if (result.success) {
                if (result.data) {
                    result.data.forEach(d => {
                        if (d.CodiceIstituto3N__c == "881")
                            isLegalEntity881 = true;
                        if (d.CodiceIstituto3N__c != "881")
                            isLegalEntityNot881 = true;
                    });
                } else {
                    isLegalEntityNot881 = (component.get("v.accountRecord").CodiceIstituto3N__c != "881");
                    isLegalEntity881 = (component.get("v.accountRecord").CodiceIstituto3N__c == "881");
                }
                
                component.set("v.isLegalEntityNot881", isLegalEntityNot881);
                component.set("v.isLegalEntity881", isLegalEntity881);
            } else
                h.showToast(component, "Errore", result.msg, "error");
        }, { ndg: component.get("v.accountRecord").NDG__c, codiceIstituto: component.get("v.accountRecord").CodiceIstituto3N__c });
    },

    checkRinnovoAvailable: function(component) {
        //SM - TEN: CR 403 disabilita sempre il rinnovo
        // this.callServer(component, "c.checkRinnovoAvailable", function(result) {
        //     component.set("v.isRinnovoAvailable", result);
        // }, { accountId: component.get("v.recordId") });
        component.set("v.isRinnovoAvailable", false);
    },

    isFastFinanceProfile: function (component){
        var action = component.get("c.getUserProfile");
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var risposta = response.getReturnValue();
                if(risposta.includes("Valutazione Fast Finance")){
                    component.set("v.isFastFinance",true);
                }
            }
        });

        $A.enqueueAction(action);
    }
})