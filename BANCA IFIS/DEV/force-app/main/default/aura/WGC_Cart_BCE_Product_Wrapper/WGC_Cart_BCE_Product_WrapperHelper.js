({
    setupData : function(component, event, helper) {
        helper.reloadData(component, event, helper);
    },

    fireChangeEvent : function(component, event, helper){
        var sObjectEvent = component.getEvent("subProductChange");
        sObjectEvent.setParams({
			"isChanging": true,
			"fieldName": event.getSource().get("v.name"),
			"fieldValue": event.getSource().get("v.value")
        });
        sObjectEvent.fire();
    },

    reloadData : function(component, event, helper){
        console.log('@@@ fields ' , component.get("v.fields"));
        let fields = component.get("v.fields");
        let items = component.get("v.items");
        let prodSelected;

        items.forEach(item => {
            if(item.isActive) prodSelected = item.subProductForm;
        });

        window.DATA = {};
        fields.forEach(f => {
            window.DATA[f.name] = f.value;
        });

        console.log('@@@ window.DATA ' , JSON.stringify(window.DATA));
        fields.forEach(f => {
            if(f.hasOwnProperty('visibility') && f.prodId == prodSelected)
                f.visible = eval(f.visibility);
            if(f.hasOwnProperty('formulaLabel') && f.prodId == prodSelected)
                f.label = eval(f.formulaLabel);
        });

        component.set("v.fields " , fields);
    },

    calculateVisibility : function(mainData, option, i) {
		let visible = true;
		if (option.visible !== null) {
			if (this.isBlank(option.visibility))
				visible = option.visible;
			else
				visible = this.evalFormula(mainData, option.visibility, i);
		}

		return visible;
	},

	evalFormula : function(data, formula, index) {
		window.ROWDATA = data;
		window.ROWDATA_INDEX = index;
		return eval(formula);
	},
})