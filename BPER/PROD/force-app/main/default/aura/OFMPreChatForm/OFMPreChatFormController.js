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
        var prechatFieldComponentsMap = hlp.getPrechatFieldAttributesArray(cmp, prechatFields);
        $A.createComponents(
            prechatFieldComponentsMap.get('Privati'),
           function(components, status, errorMessage) {
               if (status === "SUCCESS") {
                   cmp.set("v.prechatPrivatiComponents", components)
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

    openTabPrivati: function(cmp, evt, hlp) {
        hlp.openTab(evt,'Privati');
        cmp.set("v.isPrivati", true);
    },

    doneRendering: function(cmp, evt, hlp) {
        var isPrivati = cmp.get("v.isPrivati");
        var isLoggedUser = cmp.get("v.isLoggedUser");
        var hasLoadedStyle = cmp.get('v.hasLoadedStyle');

        if(!(isPrivati) && !isLoggedUser){
            document.getElementById("defaultOpenSfdc").click();
            cmp.set("v.isPrivati", true);
        }
        if(isLoggedUser && !hasLoadedStyle){
            hlp.applyLoggedStyle(cmp,evt,hlp);
        }

        if(isLoggedUser && !hasLoadedStyle){
            hlp.applyLoggedStyle(cmp,evt,hlp);
        }

    }


});