({  
    doInit: function(component,event, helper) {

      
 
        
        let action = component.get("c.RecuperoInfo");
        let action2 = component.get("c.RecuperoInfo2");
        let action3 = component.get("c.RecuperoInfo3");
       
        action.setParams({
            "qlid": component.get("v.recordId")
        });
        
        action2.setParams({
            "qlid": component.get("v.recordId")
            
        });
          
        
         action3.setParams({
            "qlid": component.get("v.recordId")
            
        });
        
        
        
        
        
       
        // Add callback behavior for when response is received
        // AZIONE 1
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                //component.set("v.treegrid", response.getReturnValue());
                component.set("v.treegrid", JSON.parse(response.getReturnValue()));               
               // console.log(component.get("v.treegrid"));
                //console.log (component.get("v.recordId"));
            }
            else {
                //console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action);
          
        //AZIONE 2
        action2.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.CondPag", response.getReturnValue());
                
               



               // console.log(JSON.stringify(component.get("v.FinanziamentiArray")));
               // console.log (component.get("v.recordId"));
            }
            else {
                //console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action2);
        
        
        
        //ACTION 3
       
         action3.setCallback(this, function(response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.disaccoppiamento", response.getReturnValue());
                
               



               // console.log(JSON.stringify(component.get("v.FinanziamentiArray")));
               // console.log (component.get("v.recordId"));
            }
            else {
                //console.log("Failed with state: " + state);
            }
        });
        // Send action off to be executed
        $A.enqueueAction(action3);
        
        
   
        
        
        
        
        
        
        
        
        
        
    }, //FINE DELLA FUNCTION DO INIT
 //_____________________________________________________________________________________________________________________________   
 // funzioni dei pulsanti
    
    
    // crea Fin legato a Qline 
    createRecordFin : function (component, event, helper) {
        
       
        
        var recordId = component.get("v.recordId");
        let action = component.get("c.RecuperoInfo");
     
        action.setParams({
            "qlid": component.get("v.recordId")
        });
                  
     var createFin = $A.get("e.force:createRecord");
        var LOOKUP = 'LOOKUP'; 
createFin.setParams({
    "entityApiName": "Finanziamenti__c",
    "navigationLocation":LOOKUP,
    "defaultFieldValues": {
        
        'Quote_Line__c' : recordId
    }
});
createFin.fire();
        
},
//______________________________________________________________________________________________
//Crea Cond secca    

       createRecordCondSingola : function (component, event, helper) {
        var recordId = component.get("v.recordId");
        let action = component.get("c.RecuperoInfo");
     
        action.setParams({
            "qlid": component.get("v.recordId")
        });
                     
     var createCondSingola = $A.get("e.force:createRecord");
            var LOOKUP = 'LOOKUP'; 
createCondSingola.setParams({
    "entityApiName": "Condizioni__c",
     "navigationLocation":LOOKUP,
    "defaultFieldValues": {
        
        'Quote_Line__c' : recordId
    }
});
createCondSingola.fire();
             
},
    
    
    
    
//_________________________________________________________________________________________
    //crea Cond collegata a fin & a qline
    
      createRecordCond : function (component, event, helper) {                        
        var recordId = component.get("v.recordId");
        var createCond = $A.get("e.force:createRecord");
           var LOOKUP = 'LOOKUP'; 
          
        var selectedItem = event.currentTarget;
        var recId = selectedItem.dataset.record;

createCond.setParams({
    "entityApiName": "Condizioni__c",
     "navigationLocation":LOOKUP,
    "defaultFieldValues": {
        
        'Quote_Line__c' : recordId ,
        'Finanziamento__c' : recId
    }
});
createCond.fire();
             
},
//_________________________________________________________________________________________________________________    
//crea Pag collegato a Cond & a Qline

    createRecordPag : function (component, event, helper) {                        
        var recordId = component.get("v.recordId");
        var createPag = $A.get("e.force:createRecord");
          var LOOKUP = 'LOOKUP';
          
        var selectedItem = event.currentTarget;
        var recId = selectedItem.dataset.record;
        
         var selectedItem2 = event.currentTarget;
        var recId2 = selectedItem2.dataset.record2;
        
         var selectedItem3 = event.currentTarget;
        var recId3 = selectedItem3.dataset.record3;
createPag.setParams({
    "entityApiName": "Pagamenti__c",
    "navigationLocation":LOOKUP,
    "defaultFieldValues": {
        
        'Quote_Line__c' : recordId ,
        'Condizione_WarrantCPQ__c' : recId,
        'SingoloProdotto_WarrantCPQ__c' : recId2,
        'Tipo_pagamento_WarrantCPQ__c': recId3
    }
});
createPag.fire();
             
},
//_______________________________________________________________________________________________________________ 
   //crea Cond Opz collegata a Cond & a Qline

    createRecordOpz : function (component, event, helper) {                        
        var recordId = component.get("v.recordId");
        var createOpz = $A.get("e.force:createRecord");
        var LOOKUP = 'LOOKUP';
          
        var selectedItem = event.currentTarget;
        var recId = selectedItem.dataset.record;

createOpz.setParams({
    "entityApiName": "Condizione_Opzionale__c",
     "navigationLocation":LOOKUP,
    "defaultFieldValues": {
        
    'CondizionePadre_WarrantCPQ__c' : recId
    }
});
createOpz.fire();
             
},

    
//________________________________________________________________________________________________________________
    //handle edit for everyone 
     handleEdit : function(component, event, helper) {
        
         
         
        var selectedItem = event.currentTarget;
        var recId = selectedItem.dataset.record;
        
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            "recordId": recId
        });
        editRecordEvent.fire();
       //var a = component.get('c.echo');
       // $A.enqueueAction(a);
        
          
    },
   
//_________________________________________________________________________________________________________


    "cancellaFin" : function (cmp,event){
        
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    var recId = id_str;
     
 var msg ='Sicuro di voler cancellare il Finanziamento?';
        if (!confirm(msg)) {
            console.log('No');
            return false;
        } else {
            console.log('Yes');
            //Write your confirmed logic
        
        
        
        
        
        var action = cmp.get("c.cancellareFin");
        action.setParams({ "rectodelete" : recId,
                         "qlid" : cmp.get("v.recordId")});
        
        
        action.setCallback(this, function(response) {
               
              $A.get('e.force:refreshView').fire();
            
            var state = response.getState();
            if (state === "SUCCESS") {
               
                if(response.getReturnValue() != 'ok'){
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({
                        title: 'ERRORE',
                        message: response.getReturnValue() == '' || response.getReturnValue() == 'error ws' ? 'Errore nella cancellazione del finanziamento su Infostore' : response.getReturnValue(),
                        type: 'error'
                    })
                    msg.fire();
                }
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
 
        // optionally set storable, abortable, background flag here
 
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    }
        
        
    },
//___________________________________________________________________________________________________________

    
  "cancellaCond" : function (cmp,event){
        
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    var recId = id_str;
     
     var msg ='Sicuro di voler cancellare la Condizione?';
        if (!confirm(msg)) {
            console.log('No');
            return false;
        } else {
            console.log('Yes');   
        
        var action = cmp.get("c.cancellareCond");
        action.setParams({ "rectodelete" : recId,
                         "qlid" : cmp.get("v.recordId")});
        
        
        action.setCallback(this, function(response) {
               
              $A.get('e.force:refreshView').fire();
            
            var state = response.getState();
            if (state === "SUCCESS") {
               
                if(response.getReturnValue() != 'ok'){
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({
                        title: 'ERRORE',
                        message: response.getReturnValue() == '' || response.getReturnValue() == 'error ws' ? 'Errore nella cancellazione della condizione su Infostore' : response.getReturnValue(),
                        type: 'error'
                    })
                    msg.fire();
                }
                // Alert the user with the value returned 
                // from the server
               // alert("Calcolo completato!");
               
 
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
 
        // optionally set storable, abortable, background flag here
 
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
        }
        
        
    },  
//______________________________________________________________________________________________________
    
  "cancellaPag" : function (cmp,event){
        
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    var recId = id_str;
     
    var msg ='Sicuro di voler cancellare il Pagamento?';
        if (!confirm(msg)) {
            console.log('No');
            return false;
        } else {
            console.log('Yes');    
        
        var action = cmp.get("c.cancellarePag");
        action.setParams({ "rectodelete" : recId});
        
        
        action.setCallback(this, function(response) {
               
              $A.get('e.force:refreshView').fire();
            
            var state = response.getState();
            if (state === "SUCCESS") {
               
                if(response.getReturnValue() != 'ok'){
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({
                        title: 'ERRORE',
                        message: response.getReturnValue() == '' || response.getReturnValue() == 'error ws' ? 'Errore nella cancellazione del pagamento su Infostore' : response.getReturnValue(),
                        type: 'error'
                    })
                    msg.fire();
                }
                // Alert the user with the value returned 
                // from the server
               // alert("Calcolo completato!");
               
 
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
 
        // optionally set storable, abortable, background flag here
 
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    
        }        
        
    },  
       
//_____________________________________________________________________________________________________
  "cancellaOpz" : function (cmp,event){
        
    var ctarget = event.currentTarget;
    var id_str = ctarget.dataset.value;
    var recId = id_str;
     
       var msg ='Sicuro di voler cancellare la Cond Opzionale?';
        if (!confirm(msg)) {
            console.log('No');
            return false;
        } else {
            console.log('Yes'); 
        
        var action = cmp.get("c.cancellareOpz");
        action.setParams({ "rectodelete" : recId,
                         "qlid" : cmp.get("v.recordId")});
        
        
        action.setCallback(this, function(response) {
               
              $A.get('e.force:refreshView').fire();
            
            var state = response.getState();
            if (state === "SUCCESS") {
               
                if(response.getReturnValue() != 'ok'){
                    var msg = $A.get("e.force:showToast");
                    msg.setParams({
                        title: 'ERRORE',
                        message: response.getReturnValue() == '' || response.getReturnValue() == 'error ws' ? 'Errore nella cancellazione della condizione su Infostore' : response.getReturnValue(),
                        type: 'error'
                    })
                    msg.fire();
                }
                // Alert the user with the value returned 
                // from the server
               // alert("Calcolo completato!");
               
 
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
 
        // optionally set storable, abortable, background flag here
 
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
        }
        
        
    },      
    
    
  
    
    
//___________________________________________________________________________________________________________    
    
  "echo" : function(cmp) {
        // create a one-time use instance of the serverEcho action
        // in the server-side controller
        var action = cmp.get("c.CalcoloImportoCondizione");
        action.setParams({ "qlid" : cmp.get("v.recordId") });
 
        // Create a callback that is executed after 
        // the server-side action returns
        action.setCallback(this, function(response) {
               
              $A.get('e.force:refreshView').fire();
            
            var state = response.getState();
            if (state === "SUCCESS") {
               
                // Alert the user with the value returned 
                // from the server
               // alert("Calcolo completato!");
               
 
                // You would typically fire a event here to trigger 
                // client-side notification that the server-side 
                // action is complete
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
 
        // optionally set storable, abortable, background flag here
 
        // A client-side action could cause multiple events, 
        // which could trigger other events and 
        // other server-side action calls.
        // $A.enqueueAction adds the server-side action to the queue.
        $A.enqueueAction(action);
    
    },
 
//______________________________________________________________________________________________________________________________    
    
showSpinner: function(component, event, helper) {
        // make Spinner attribute true for displaying loading spinner 
        component.set("v.spinner", true); 
    },
     
    // function automatic called by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hiding loading spinner    
        component.set("v.spinner", false);
    },
    
    
    
   
    
    
})