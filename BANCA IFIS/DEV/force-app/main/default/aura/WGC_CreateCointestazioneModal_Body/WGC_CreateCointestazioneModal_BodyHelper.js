({
	pollingCointestazioni : function(component) {
		let h = this;
		
		// $A.util.removeClass(component.find("spinner"), "slds-hide");
		this.renderCointestazioni(component);
        
        //execute callApexMethod() again after 5 sec each
        let polling = window.setInterval(
            $A.getCallback(function() { 
				if (component.get("v.waiting"))
					h.renderCointestazioni(component);
            }), component.get("v.TIME_INTERVAL")
		);
		
		component.set("v.polling", polling);
	},
	
	renderCointestazioni : function(component) {
		let MAX_ITERATIONS = component.get("v.MAX_ITERATIONS");
		let pollingIteration = component.get("v.pollingIteration");
		let polling = component.get("v.polling");
		let retry = component.get("v.retry");
		console.log("processId: ", component.get("v.processId"));
		$A.util.removeClass(component.find("spinner"), "slds-hide");

		this.callServer(component, "c.recuperaCointestazioni", function(result) {
			console.log("POLLING: ", result);
			if (result && result.status == "Completed") {
				clearInterval(polling);
				component.set("v.waiting", false);
				$A.util.addClass(component.find("spinner"), "slds-hide");
				component.set("v.cointestazioni", result.cointestazioni);
			} else {
				if (pollingIteration >= MAX_ITERATIONS && !retry) {
					clearInterval(polling);
					component.set("v.retry", true);
				} else
					component.set("v.pollingIteration", pollingIteration++);
			}
		}, {
			processId: component.get("v.processId"),
			riepilogoCointestazioni: false,
			sObjectId: component.get("v.sObjectId")
		});
	},

	closeAction : function(component) {
		this.resolveAction("cancel", null, false);
		component.find('overlayLib').notifyClose();
	},

	submitAction : function(component) {
		this.resolveAction("submit", component.get("v.resultSelected"), false);
		component.find('overlayLib').notifyClose();
	},

	resolveAction : function(action, data, cointestazione) {
		this.fireEvent(JSON.stringify({ "action": action, "data": data, "cointestazione": cointestazione }), 'WGC_CreateCointestazioneResolveEvent');
	},

	fireEvent: function (response, whatEvent) {
        var B2F = $A.get("e.c:" + whatEvent);
        B2F.setParams({ "json": response });
        B2F.fire();
    },

})