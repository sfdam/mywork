({
    getData : function(component,event,helper) {
        var action = component.get("c.getData");

        action.setCallback(this, function(response) {
            var state = response.getState();

            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('result: ',result);
                component.set("v.lead24mesi",result.numLead);
                component.set("v.lead24mesiCampagne", result.numLeadCampaign);
                component.set("v.aziende1324mesi", result.numAziende1324mesi);
                component.set("v.aziende1324mesiCampagne", result.numAziende1324mesiCampaign);
                component.set("v.clientiBu", result.numClientiAltreBu);
                component.set("v.clientiBuCampagne", result.numClientiAltreBuInCampaign);
                component.set("v.exClienti", result.numExClienti);
                component.set("v.exClientiCampagne", result.numExClientiCampaign);
                component.set("v.debitori", result.numDebitori);
                component.set("v.debitoriCampagne", result.numDebitoriCampaign);
            }else if(state === "ERROR"){
                console.log('error: ',result);
            }
        });
        $A.enqueueAction(action);
    }
})