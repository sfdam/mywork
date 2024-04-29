({
	doInit : function(component, event, helper) { 
        var flip = component.get('v.Flip');
        if(flip == 'disattivo') component.set('v.IsCollapsed', false);
        component.set('v.currentYear', $A.localizationService.formatDate(new Date(), "YYYY"));
        component.set("v.currentUser", $A.get("$SObjectType.CurrentUser.Id"));
        
        helper.CountNumberOfTab(component);
        // console.log("HP_ANAL_GRAPH");
        // document.addEventListener("scroll", function(e){
        //     console.log("event: ", e);
        //     console.log("y: " + window.scrollY);
        // });
	},
    
    navigateToMyComponent : function(component, event, helper) {
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:BaseClienti_DetailComponent",
            componentAttributes: {

            }
        });
        evt.fire();
    },

    onWaveChange : function() {
    },

    collapse: function (component, event, helper) {
        component.set("v.IsCollapsed", !component.get("v.IsCollapsed"));
    },
})