({
    refreshTable : function(component, event, helper) {



        let profileId
        var notifiLib = component.find("notifLib");
		profileId = component.find("Name").get("v.value");


        var action = component.get("c.getUsers");

        action.setParams({"profileId": profileId});

        action.setCallback(this, function(response) {
            component.set("v.spinner", false);
            var state = response.getState();
            if (state==="SUCCESS") {
                var results = response.getReturnValue();

                results.unfreeze.forEach(function(record){
                    if(record.Profile)
                    record.linkName = record.Profile.Name;
                });

                results.freeze.forEach(function(record){
                    if(record.Profile)
                    record.linkName = record.Profile.Name;
                });



                component.set("v.unfreezeUsers",results.unfreeze);
                component.set("v.filteredDataUnfreeze",results.unfreeze);
                component.set("v.freezeUsers",results.freeze);
                component.set("v.filteredDataFreeze",results.freeze);
                console.log('COLONNE' +JSON.stringify(component.get('v.mycolumns')));
                
            }
            if (state==="ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        notifiLib.showToast({
                        	title:"Errore!",
                        	message:errors[0].message,
                        	variant:"error"
                    	});
                    }
                } else {
                    notifiLib.showToast({
                        title:"Errore!",
                        message:"unknown error",
                        variant:"error"
                    });
                }
            }
        });
        $A.enqueueAction(action);
        component.set("v.spinner", true);

    },
    recursiveFreezeUnfreeze : function(component,event,helper,listaUtenti,metodo){

        var tmpUsers = [];

        if(listaUtenti.length>10000){
            for(var i =0;i<10000;i++){
                tmpUsers.push(listaUtenti.shift());
                
            }
            component.set("v.tmpSelectedUsers",listaUtenti);
        }
        else{
            tmpUsers = listaUtenti;
            component.set("v.tmpSelectedUsers",[]);
        }
        var action = component.get(metodo);

        action.setParams({"users": JSON.stringify(tmpUsers)});

        action.setCallback(this, function(response) {
            //component.set("v.spinner", false);
            var state = response.getState();
            if (state==="SUCCESS") {
                if(component.get("v.tmpSelectedUsers").length >0){
                    helper.recursiveFreeze(component,event,helper,component.get("v.tmpSelectedUsers"));
                }
                else{
                helper.refreshTable(component,event,helper);

                }
                
            }
            if (state==="ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        notifiLib.showToast({
                        	title:"Errore!",
                        	message:errors[0].message,
                        	variant:"error"
                    	});
                    }
                } else {
                    notifiLib.showToast({
                        title:"Errore!",
                        message:"unknown error",
                        variant:"error"
                    });
                }
            }
        });
        
        $A.enqueueAction(action);
        component.set("v.spinner", true);
    }
})