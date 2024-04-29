({
    setupFields : function(component, event, helper) {
        // var record = component.get("v.records").filter(r => { return r.tipo })
        // var fields = [];
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
        });

        component.set("v.fields " , fields);
    },
})