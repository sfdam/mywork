({
	initData : function(component) {
		let crossSelling = (component.get("v.crossSelling") ? component.get("v.crossSelling") : {});
		let activeItem = component.get("v.items").find(i => { return i.isActive; });
		let picklistOptions = component.get("v.picklistOptions");
		let tipologie = [];
		let businesses = [];

		if (this.isBlank(crossSelling.closeDate))
			crossSelling.closeDate = component.get("v.opportunityRecord").CloseDate;
		
		// CR Lotto 4.2 Id 157
		if (this.isBlank(crossSelling.finalita_finance))
			crossSelling.finalita_finance = component.get("v.opportunityRecord").WGC_Finalita_Finance__c;

		picklistOptions.find(po => {return po.field == "Opportunity.WGC_Tipologia_CrossSelling__c";}).options.forEach(opt => {
			if (opt.includes(":"))
				tipologie.push({value:opt.split(":")[0], label:opt.split(":")[1]});
			else
				tipologie.push({value:opt, label:opt});
		});
		
		picklistOptions.find(po => {return po.field == "Opportunity.WGC_Business_CrossSelling__c";}).options.forEach(opt => {
			if (opt.includes(":"))
				businesses.push({value:opt.split(":")[0], label:opt.split(":")[1]});
			else
				businesses.push({value:opt, label:opt});
		});
		
		component.set("v.crossSelling", crossSelling);
		component.set("v.activeItem", activeItem);
		component.set("v.tipologie", tipologie);
		component.set("v.businesses", businesses);
	},

	refreshActiveItem : function(component, event) {
		component.set("v.activeItem", event.getParam("value").find(i => { return i.isActive; }));
	},

	// initCrossSelling : function(component) {
	// 	let opportunityRecord = component.get("v.opportunityRecord");
	// 	let crossSelling = {};

	// 	crossSelling.closeDate = opportunityRecord.CloseDate;
	// 	crossSelling.amount = 0;
	// 	crossSelling.tipologia = "";
	// 	crossSelling.business = "";
	// 	crossSelling.referente = "";
	// 	crossSelling.note = "";

	// 	component.set("v.crossSelling", crossSelling);
	// },

	reloadReferenti : function(component) {
		let accountId = component.get("v.accountId");
		let appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        appEvent.setParams({ "method": "c.getReferenti", "params": {accountId: accountId} });
        appEvent.fire();
	}
})