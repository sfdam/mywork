({
	doInit : function(component, event, helper) {
		helper.pollingCointestazioni(component);
	},
	
    handleRowSelection: function (component, event, helper) {
        let selected = event.currentTarget.id;
        let selectedSplit = selected.split("_");
        console.log(selectedSplit);

        let result = component.get('v.cointestazioni');
        console.log(result.length);

        for (let i = 0; i < result.length; i++) {
            let element = document.getElementById(selectedSplit[0] + '_' + i);
            element.classList.remove("selected");
        }

        let element = document.getElementById(selected);
        element.classList.add("selected");

        let resultSelected = result[selectedSplit[1]];
        console.log(resultSelected);

        component.set('v.resultSelected', resultSelected);
	},
	
	retry : function(component, event, helper) {
		helper.renderCointestazioni(component);
	},
	
	manageF2B : function (component, event, helper) {
		// manage Footer event
        var json = JSON.parse(event.getParam("json"));
        console.log(json);

        switch (json.action) {
			case 'cancel':
			helper.closeAction(component);
			break;
			case 'submit':
			helper.submitAction(component);
		}
	}

})