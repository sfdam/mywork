({
    /**
     * On initialization of this component, set the prechatFields attribute and render pre-chat fields.
     * 
     * @param cmp - The component for this state.
     * @param evt - The Aura event.
     * @param hlp - The helper for this state.
     */
	onInit: function(cmp, evt, hlp) {

        // Get pre-chat fields defined in setup using the prechatAPI component
        var prechatFields = cmp.find("prechatAPI").getPrechatFields();
        console.log("prechatfields = "+JSON.stringify(prechatFields))
        // Get pre-chat field types and attributes to be rendered
        //var prechatFieldComponentsArray = hlp.getPrechatFieldAttributesArray(cmp, prechatFields);
        var prechatFieldComponentsMap = hlp.getPrechatFieldAttributesArray(cmp, prechatFields);
        $A.createComponents(
            prechatFieldComponentsMap.get('Privati'),
           function(components, status, errorMessage) {
               if (status === "SUCCESS") {
                   cmp.set("v.prechatPrivatiComponents", components)
               }
           } 
        )

        $A.createComponents(
            prechatFieldComponentsMap.get('Imprese'),
            function(components, status, errorMessage) {
                if (status === "SUCCESS") {
                    cmp.set("v.prechatImpreseComponents", components)
                }
            } 
         )

    },


    
    /**
     * Event which fires when start button is clicked in pre-chat
     * 
     * @param cmp - The component for this state.
     * @param evt - The Aura event.
     * @param hlp - The helper for this state.
     */
    handleStartButtonClick: function(cmp, evt, hlp) {
        hlp.onStartButtonClick(cmp);
    },
    /*onCheck: function(cmp, evt) {
        cmp.set("v.policyAcceptance", document.getElementById("policyAcceptance").value);
     },*/
    motivoSelezionato: function(cmp, evt) {
        cmp.set("v.motivoSelected", document.getElementById("motiviSfdc").value);
        
    },

    openTabPrivati: function(cmp, evt, hlp) {
        hlp.openTab(evt,'Privati');
        cmp.set("v.isPrivati", true);
        cmp.set("v.isImprese", false);
    },

    openTabImprese: function(cmp, evt, hlp) {
        hlp.openTab(evt,'Imprese');
        cmp.set("v.isImprese", true);
        cmp.set("v.isPrivati", false);
    },

    doneRendering: function(cmp, evt, hlp) {
        var isImprese = cmp.get("v.isImprese");
        var isPrivati = cmp.get("v.isPrivati");
        var isLoggedUser = cmp.get("v.isLoggedUser");
        var hasLoadedStyle = cmp.get('v.hasLoadedStyle');

        if(!(isImprese || isPrivati) && !isLoggedUser){
            document.getElementById("defaultOpenSfdc").click();
            cmp.set("v.isPrivati", true);
        }
        if(isLoggedUser && !hasLoadedStyle){
            hlp.applyLoggedStyle(cmp,evt,hlp);
        }
    }


});