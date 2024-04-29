({
    doInit : function(component, event, helper) {

        var notifiLib = component.find("notifLib");
        var action = component.get("c.profilesList");

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state==="SUCCESS") {
                var retValue = response.getReturnValue();

                component.set("v.profilesList",retValue);
                
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

    },

    selectedProfile : function(component,event,helper){

        var notifiLib = component.find("notifLib");
        component.set("v.showFreezeUsers",true);

        component.set('v.mycolumns', [
            {label: 'Profile', fieldName: 'linkName', type: 'text', typeAttributes: {label: { fieldName: "ProfileName"}}},
            {label: 'Name',fieldName:'Name',type: 'text'},
            {label: 'Matricola', fieldName: 'PTF_RegistrationNumber__c', type: 'text'},
            {label: 'Abi',fieldName: 'abi__c', type:'text'}
            ]);

        let profileId
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
    updateSelectedUnfreezeUsers : function(component,event,helper){
        var selectedRows = event.getParam('selectedRows');
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            
            setRows.push(selectedRows[i]);

        }

        component.set("v.selectedUsersToFreeze", setRows);
    },
    updateSelectedFreezeUsers : function(component,event,helper){
        var selectedRows = event.getParam('selectedRows');
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            
            setRows.push(selectedRows[i]);
        }
        
        component.set("v.selectedUsersToUnfreeze",setRows);
    },
    freezeUsers : function(component,event,helper){
        
        var notifiLib = component.find("notifLib");
        var selectedSize = component.get("v.selectedUsersToFreeze");
        var tmpUsers = [];
        
        if(selectedSize.length == 0){
            notifiLib.showToast({
                title:"Errore!",
                message:"selezionare almeno un utente!",
                variant:"error"
            });
                return;       
        }
        helper.recursiveFreezeUnfreeze(component,event,helper,selectedSize,"c.freeze");
        /*else if(selectedSize.length > 10000){
            for(var i =0;i<10000;i++){
                tmpUsers.push(selectedSize.shift());
                
            }
            component.set("v.tmpSelectedUsers",selectedSize);

        }
        else {
        tmpUsers =  selectedSize;
        }
        var action = component.get("c.freeze");

        action.setParams({"users": JSON.stringify(tmpUsers)});

        action.setCallback(this, function(response) {
            //component.set("v.spinner", false);
            var state = response.getState();
            if (state==="SUCCESS") {
                if(component.get("v.tmpSelectedUsers").length > 0){
                    helper.recursiveFreeze(component,event,helper,component.get("v.tmpSelectedUsers"));
                }
                helper.refreshTable(component,event,helper);
                
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
        component.set("v.spinner", true);*/
    },
    unfreezeUsers : function(component,event,helper){

        var notifiLib = component.find("notifLib");
        var selectedSize = component.get("v.selectedUsersToUnfreeze");
        var tmpUsers = [];
        
        if(selectedSize.length == 0){
            notifiLib.showToast({
                title:"Errore!",
                message:"selezionare almeno un utente!",
                variant:"error"
            });
                return;       
        }
        helper.recursiveFreezeUnfreeze(component,event,helper,selectedSize,"c.unfreeze");
        
        
    },
    
    searchTableUnfreeze : function(component,event,helper) {
        var allRecords = component.get("v.unfreezeUsers");
        var searchFilter = event.getSource().get("v.value").toUpperCase();
        
        var tempArray = [];
        var i;

        for(i=0; i < allRecords.length; i++){
            if((allRecords[i].Name && allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1) ||
               (allRecords[i].PTF_RegistrationNumber__c && allRecords[i].PTF_RegistrationNumber__c.toUpperCase().indexOf(searchFilter) != -1 ) ||
               (allRecords[i].abi__c && allRecords[i].abi__c.toUpperCase().indexOf(searchFilter) != -1 ))
            {
                tempArray.push(allRecords[i]);
            }
        }
        component.set("v.filteredDataUnfreeze",tempArray);
    },
    searchTableFreeze : function(component,event,helper) {
        var allRecords = component.get("v.freezeUsers");
        var searchFilter = event.getSource().get("v.value").toUpperCase();
        
        var tempArray = [];
        var i;

        for(i=0; i < allRecords.length; i++){
            if((allRecords[i].Name && allRecords[i].Name.toUpperCase().indexOf(searchFilter) != -1) ||
               (allRecords[i].PTF_RegistrationNumber__c && allRecords[i].PTF_RegistrationNumber__c.toUpperCase().indexOf(searchFilter) != -1 ) ||
               (allRecords[i].abi__c && allRecords[i].abi__c.toUpperCase().indexOf(searchFilter) != -1 ) )
            {
                tempArray.push(allRecords[i]);
            }
        }
        component.set("v.filteredDataFreeze",tempArray);
    },


})