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
        var prechatFieldComponentsArray = hlp.getPrechatFieldAttributesArray(cmp, prechatFields);
        //var motivoChat = prechatFieldComponentsArray.pop()

        // Make asynchronous Aura call to create pre-chat field components        
        /* $A.createComponents(
            prechatFieldComponentsArray,
            function(components, status, errorMessage) {
                if(status === "SUCCESS") {
                    cmp.set("v.prechatFieldComponents", components);
                    console.log("components = "+cmp.get("v.prechatFieldComponents"))
                    $A.createComponents(
                        [
                            [
                                motivoChat[0], motivoChat[1]
                            ],
                            [
                                "option", { value: "Attivazione nuovo Internet Banking", label: "Attivazione nuovo Internet Banking" }
                            ],
                            [
                                "option", { value: "Carte di pagamento", label: "Carte di pagamento" }
                            ],
                            [
                                "option", { value: "Conto corrente", label: "Conto corrente" }
                            ],
                            [
                                "option", { value: "Conto corrente", label: "Condizioni economiche" }
                            ],
                            [
                                "option", { value: "Altri prodotti e servizi", label: "Altri prodotti e servizi" }
                            ],
                        ],
                            function(components) {
                                components[0].set("v.body", [components[1], components[2], components[3], components[4], components[5]])
                                let updated = cmp.get("v.prechatFieldComponents")
                                updated.push(components[0])
                                cmp.set("v.prechatFieldComponents", updated)
                            }                
                    )
                }
            }
        ); */

        $A.createComponents(
           prechatFieldComponentsArray,
           function(components, status, errorMessage) {
               if (status === "SUCCESS") {
                   cmp.set("v.prechatFieldComponents", components)
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
    onCheck: function(cmp, evt) {
        cmp.set("v.policyAcceptance", (evt.getSource().get('v.value')))
     },
    motivoSelezionato: function(cmp, evt) {
        cmp.set("v.motivoSelected", document.getElementById("motivi").value)
        
    }
});