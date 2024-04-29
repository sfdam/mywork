({
    initialize: function(component, event, helper) {
        console.log('START');
        

        var ndg = component.get("v.ndg");
        var abi = component.get("v.abi");
        var action = component.get("c.verifyNDG");

        action.setParams({ndg:ndg, abi:abi});
        action.setCallback(this, function(response){
                var state = response.getState();
                if (state==="SUCCESS") {
                var result = response.getReturnValue();
                console.log('RESULT ',result["hasCampaigns"]);
                if(result["hasCampaigns"] == true){
                    
                    component.set("v.CampaignFound",true);
                    component.set("v.ndgName", result["accountInfo"][0].Name);
                    component.set("v.ndgUrl","/lightning/r/Account/"+ result["accountInfo"][0].Contact.Account.Id+"/view");
                    component.set("v.modelloDiServizio", result["accountInfo"][0].Contact.Account.PTF_ModelloDiServizio__c);
                    if(result["accountInfo"][0].Contact.Account.PTF_Portafoglio__c)
                        component.set("v.ptfName", result["accountInfo"][0].Contact.Account.PTF_Portafoglio__r.Name)
                    component.set("v.referenteName", result["accountInfo"][0].Contact.Account.CRM_ReferenteNameFormula__c )
                    helper.getAlldataHelper(component, event, helper);   
                } else if (result["hasMemo"] == true) {
                    component.set("v.CampaignFound",true);
                    component.set("v.ndgName", result["accountInfo"][0].Cliente__r.Name);
                    component.set("v.ndgUrl","/lightning/r/Account/"+ result["accountInfo"][0].Cliente__r.Id+"/view");
                    component.set("v.modelloDiServizio", result["accountInfo"][0].Cliente__r.PTF_ModelloDiServizio__c);
                    if(result["accountInfo"][0].Cliente__r.PTF_Portafoglio__c)
                        component.set("v.ptfName", result["accountInfo"][0].Cliente__r.PTF_Portafoglio__r.Name)
                    component.set("v.referenteName", result["accountInfo"][0].Cliente__r.CRM_ReferenteNameFormula__c )
                    helper.getAlldataHelper(component, event, helper); 
                }
                else{
                    if(result["accountInfo"].length == 0){

                        component.set("v.noNdg",true);

                    }else{
                        component.set("v.noCampaignFound",true);
                        component.set("v.ndgName", result["accountInfo"][0].Name);
                        component.set("v.ndgUrl","/lightning/r/Account/"+ result["accountInfo"][0].Id+"/view");
                        component.set("v.modelloDiServizio",result["accountInfo"][0].PTF_ModelloDiServizio__c);
                        if(result["accountInfo"][0].PTF_Portafoglio__c!=null)
                            component.set("v.ptfName",result["accountInfo"][0].PTF_Portafoglio__r.Name);
                        component.set("v.referenteName",result["accountInfo"][0].CRM_ReferenteNameFormula__c);
                    }

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

    },
})