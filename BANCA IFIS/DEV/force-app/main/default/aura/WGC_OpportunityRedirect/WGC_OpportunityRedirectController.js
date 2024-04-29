({
    doInit: function(component, event, helper) {
        let opportunityId = component.get("v.recordId");
        // helper.callServerSync(component, "c.isUserOwner", {
        helper.callServerSync(component, "c.isOpportunityVisible", {
            opportunityId: opportunityId
        }).then(function(result){
            if (result === true)
                return helper.callServerSync(component, "c.getOpportunityRecordType", {
                    opportunityId: opportunityId
                });
            else {
                component.find('overlayLib').showCustomModal({
                    header: 'Attenzione!',
                    body: $A.get("$Label.c.WGC_NotOwnerOpportunity"),
                    showCloseButton: true,
                    cssClass: "slds-text-align_center",
                    closeCallback: function() {
                        window.history.back();
                    }
                });
                return null;
            }
        })
        .then(function(result){
            var cmpName;
            var navService = component.find("navService");

            if (result !== null){
                if (result.RecordType.DeveloperName == "IFISOpportunitaFactoring" || result.RecordType.DeveloperName == "IFIS_Rinnovo" || result.RecordType.DeveloperName == 'WGC_IFIS_Oppotunita_Crediti_Erariali') {     
                    cmpName = "c__AccountOpportunity_Detail";
                } else if(result.RecordType.DeveloperName == "IFISOpportunitaFastFinance"){
                    cmpName = "c__WGC_PC_Cart_Container";
                }

                if(cmpName != null && cmpName != undefined){
                    var pageReference = {    
                        "type": "standard__component",
                        "attributes": {
                            "componentName": cmpName
                        },    
                        "state": {
                            "c__opportunityId" : opportunityId
                        }
                    };
                    navService.navigate(pageReference);
                    //Serve per refreshare il altrimenti errore sul find
                    let ms = 5;
                    window.setTimeout($A.getCallback(function(){
                        $A.get('e.force:refreshView').fire();
                    }),ms);
                }
            }
        });
    },

    checkFactoringForRedirect : function(component, event, helper) {
        let record = event.getParam("value");
        let opportunityId = component.get("v.recordId");

        if (record.RecordType.DeveloperName == "IFISOpportunitaFactoring" || record.RecordType.DeveloperName == "IFIS_Rinnovo") {
            // let evt = $A.get("e.force:navigateToComponent");
            // evt.setParams({
            //     componentDef : "c:AccountOpportunity_Detail",
            //     componentAttributes: {
            //         opportunityId : opportunityId
            //     }
            // });
            // evt.fire();
            
            // History.replaceState({}, "BACK", "/");
            
            var navService = component.find("navService");
            var pageReference = {    
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__AccountOpportunity_Detail"
                },    
                "state": {
                    "c__opportunityId" : opportunityId
                }
            };

            navService.navigate(pageReference);
            //Serve per refreshare il altrimenti errore sul find
            let ms = 5;
            window.setTimeout($A.getCallback(function(){
                $A.get('e.force:refreshView').fire();
            }),ms);
        }
    },

    // onRender : function(component, event, helper) {
    //     console.log("RENDER REDIRECT");
    //     if (window.lasthash)
    //         alert(window.lasthash);
    // }
})