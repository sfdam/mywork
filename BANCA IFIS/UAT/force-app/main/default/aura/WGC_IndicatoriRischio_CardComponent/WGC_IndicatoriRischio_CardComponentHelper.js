({
	getAccountInfo: function (component, event) {

        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 
            
            var action = component.get("c.getAccountInfo");
            action.setParams({
                "accountId": component.get("v.recordId")
            });
    
            action.setCallback(this, function (response) {
                //get the response state
                var state = response.getState();
    
                //check if result is successfull
                if (state == "SUCCESS") {
                    var result = response.getReturnValue();
    
                    if(result.data[0].account != null || result.data[0].account != undefined){
                        component.set('v.accountData', result.data[0].account);
                        var acc = result.data[0].account;
                        if(acc.EventiNegativiProtesti__c == 'V' && acc.EventiNegativiProcedureConcorsuali__c == 'V' &&
                            acc.EventiNegativiPregiudizievoli__c == 'V' && acc.EventiNegativiCIGS__c == 'V' &&
                            acc.EventiNegativiAllarmiQuote__c == 'V' && acc.EventiNegativiGlobale__c == 'V'){
                            
                            component.set("v.eventiNegativiStatus", true);
                        }
                        else if(acc.EventiNegativiProtesti__c == 'G' || acc.EventiNegativiProcedureConcorsuali__c == 'G' ||
                                acc.EventiNegativiPregiudizievoli__c == 'G' || acc.EventiNegativiCIGS__c == 'G' ||
                                acc.EventiNegativiAllarmiQuote__c == 'G' || acc.EventiNegativiGlobale__c == 'G'){
                            
                            component.set("v.eventiNegativiStatus", false);
                        }
    
                        var rischioAbb = { color : 'grey', status : ' - '};
                        if(acc.WGC_Qualifica_Corporate__c == 'Prospect' || acc.WGC_Qualifica_Corporate__c == 'Ex-Cliente'){
                            rischioAbb.color = 'grey';
                        } else {
                            if((acc.hasOwnProperty('WGC_StatoAnagraficaCed__c') && (acc.WGC_StatoAnagraficaCed__c == 'Cliente Dormiente' || acc.WGC_StatoAnagraficaCed__c == 'Cliente Inattivo')) || (acc.hasOwnProperty('WGC_StatoAnagraficaDeb__c') && (acc.WGC_StatoAnagraficaDeb__c == 'Debitore Dormiente' || acc.WGC_StatoAnagraficaDeb__c == 'Debitore Inattivo'))){
                                rischioAbb.color = 'red';
                                if(acc.WGC_StatoAnagraficaCed__c == 'Cliente Dormiente' || acc.WGC_StatoAnagraficaCed__c == 'Cliente Inattivo'){
                                    rischioAbb.status = acc.WGC_StatoAnagraficaCed__c;
                                } else {
                                    rischioAbb.status = acc.WGC_StatoAnagraficaDeb__c;
                                }
                            } else if(acc.hasOwnProperty('WGC_StatoAnagraficaCed__c') || acc.hasOwnProperty('WGC_StatoAnagraficaDeb__c')){
                                rischioAbb.color = 'green';
                                rischioAbb.status = '';
                            }
                        }
    
                        component.set('v.rischioAbb', rischioAbb);
                        
                        var lastTaskDate = null;
                        var lastEventDate = null;
                        
                        if(result.data[0].taskList[0] != undefined && result.data[0].taskList.length > 0){
                             component.set('v.lastContactStatus', true);
                             //Se non è vuota la activityDate allora la imposto
                             lastTaskDate = result.data[0].taskList[0].Data_Inizio__c != null ? result.data[0].taskList[0].Data_Inizio__c : '';
                             lastTaskDate = new Date(lastTaskDate).toLocaleDateString('it-IT', {day: 'numeric', month: 'short', year: 'numeric'});
                             component.set('v.lastTaskDate', lastTaskDate);
                        }
                        
                        // MARCO BONIN - CR 199
                        
                        if(result.data[0].eventList[0] != undefined && result.data[0].eventList.length > 0){
                             component.set('v.lastEventStatus', true);
                             //Se non è vuota la activityDate allora la imposto
                             lastEventDate = result.data[0].eventList[0].ActivityDateTime != null ? result.data[0].eventList[0].ActivityDateTime : '';
                             lastEventDate = new Date(lastEventDate).toLocaleDateString('it-IT', {day: 'numeric', month: 'short', year: 'numeric'});
                             component.set('v.lastEventDate', lastEventDate);
                        }  
                        
                        // UNA SOLA DATA, NEL CASO DEVE ANDARE A FRONTEND

						var lastOccurenceDate = null;
						
                        if(lastTaskDate == null && lastEventDate == null)
							component.set('v.lastOccurenceDate', lastOccurenceDate);
                        
                        if(lastTaskDate == null && lastEventDate != null)
							component.set('v.lastOccurenceDate', lastEventDate);
                        
                        if(lastTaskDate != null && lastEventDate == null)
							component.set('v.lastOccurenceDate', lastTaskDate);                        
                        
                        if(lastTaskDate != null && lastEventDate != null){
                           if(lastTaskDate > lastEventDate) 
                            	component.set('v.lastOccurenceDate', lastTaskDate); 
                            else
                            	component.set('v.lastOccurenceDate', lastEventDate);  
                        }
                        
                        
                        component.set('v.sconfino', (result.data[0].crList[0] == undefined) ? 'null' : (result.data[0].crList.length > 0) ? result.data[0].crList[0].Sconfino_TOT_IFIS__c : 0);
                        component.set('v.sofferenze', (result.data[0].crList.length > 0 && result.data[0].crList[0].Sofferenze_IFIS_frm__c) ? result.data[0].crList[0].Sofferenze_IFIS_frm__c.toUpperCase() : '-');
                                                    
                    }
    
                } else if (state == "ERROR") {
                    console.log("ERROR");
                    console.log(result);
                    // alert('Error in calling server side action');
                }
            });
            $A.enqueueAction(action);
        }));     
        
        return promise;              
    },

    getDocStatus : function(component, event, helper){
        var recordId = component.get("v.recordId");
        var action = component.get("c.checkStatusDoc");
        action.setParams({
            "objectId" : recordId
        });
        action.setCallback(this, (response) =>{
            if(response.getState() == "SUCCESS"){
                var risposta = response.getReturnValue()

                if(risposta.success){
                    if(risposta.msg == 'OK'){
                        component.set("v.statusDoc", true);
                    }
                    else{
                        component.set("v.statusDoc", false);
                    }
                }
                else{
                    console.log('@@@ not success docStatus ' + risposta.msg );
                }
            }
            else{
                console.log('@@@ errore docStatus ' , response.getError());
            }
        });
        $A.enqueueAction(action);
    },
})