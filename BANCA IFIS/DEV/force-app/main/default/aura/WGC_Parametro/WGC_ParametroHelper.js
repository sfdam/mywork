({
	setupPicklistOptions : function(component) {
		var param = component.get("v.parameter");
		let value = component.get("v.value");
		var options = [];

		if (param.tipologia == 'Picklist' || param.tipologia == 'Multi-picklist') {
			var domini = (param.dominioVal ? param.dominioVal.split(";") : []);

			if (param.tipologia == 'Picklist')
				options.push({ label: "--seleziona--", value: null });
			// console.log("value: ", value);
			// console.log("domini: ", domini);
			for (var d in domini) {
				// console.log("domini[d] == param.defaultval: ", domini[d] == param.defaultval);
				// console.log("domini[d]: ", domini[d]);
				// console.log("param.defaultval: ", param.defaultval);
				if (domini[d].indexOf(":") < 0)
					options.push({ label: domini[d], value: domini[d], selected: ( value != "" ? domini[d] == value : domini[d] == param.defaultval ) });
				else {
					var values = domini[d].split(":");
					options.push({ label: values[0], value: values[1], selected: ( value != "" ? values[1] == value : values[1] == param.defaultval ) });
				}
			}
		}

		component.set("v.options", options);
	},

	setDefaultValue : function(component, event) {
		var param = (event ? event.getParam("value") : component.get("v.parameter"));

		if (event && !event.getParam("value").hasOwnProperty("value"))
			param = component.get("v.parameter");

		if (param == undefined || param == null)
			return;

		var value = param.value;
		// let defaultval = null;
		if (param.codice == "C165")
			console.log("param.value: ", param.value);
		// if (param.codice == "003")
			// console.log("PARAM: --code: "+param.codice+" --defaultval: ", (param.tipologia == "Percentuale" ? parseInt(param.defaultval)/100 : param.defaultval));
		if (param.tipologia == 'Multi-picklist' && typeof value == "string")
			value = value.split(";");
		
		if (value == null || value == "" || value == undefined) {
			if (param.codice == "C165")
				console.log("value: ", value);
			/*
			console.log("param.defaultval: ", param.defaultval);
			if (param.defaultval.startsWith("$")) {
				let formula = param.defaultval.substring(2, param.defaultval.length-1).replace(/VV_/g, "params.VV_").replace(/LL_/g, "lineaFlags.");
				console.log("formula: ", formula);
				defaultval = eval(formula);
				console.log("defaultval: ", defaultval);
				if (typeof defaultval == "boolean")
					defaultval = defaultval.toString();
				console.log("defaultval: ", defaultval);
				value = defaultval;
				debugger;
			} else 
			*/
			if (param.tipologia != 'Multi-picklist' && component.get("v.value") == "" && !param.defaultval.startsWith("$") && param.defaultval != "") {
				value = ( param.tipologia == "Percentuale" ? parseFloat(param.defaultval) : param.defaultval );
			} else if (component.get("v.isDashboard"))
				value = null;
		} else if (param.tipologia == "Flag") {
			value = value.toUpperCase();
		} else if (value == "BLANK") {
			value = "";
		}

		param.value = value;
		component.set("v.value", value);
		//SM - TENAM-216
		if(param.tipologia == 'Multi-picklist')
			component.set("v.valueForListbox", value);
		component.set("v.param", param);
	},

	setReadOnlyValue : function(component, event) {
		var param = (event ? event.getParam("value") : component.get("v.parameter"));
		// console.log("event.parameters: ", JSON.stringify(event.getParams()));

		if (event && !event.getParam("value").hasOwnProperty("value"))
			param = component.get("v.parameter");

		if (param == undefined || param == null || param.isFixedValue)
			return;

		var value = param.value;

		if (param.readonly || (event && !event.getParam("value").hasOwnProperty("value") && value != component.get("v.value"))) {
			if (value == null || value == "" || value == undefined) {
				if (param.tipologia != 'Multi-picklist' && component.get("v.value") == "" && !param.defaultval.startsWith("$") && param.defaultval != "") {
					value = ( param.tipologia == "Percentuale" ? parseFloat(param.defaultval) : param.defaultval );
				} else if (component.get("v.isDashboard"))
					value = null;
			} else if (param.tipologia == "Flag") {
				value = value.toUpperCase();
			} else if (value == "BLANK") {
				value = "";
			}
		} else return;

		param.value = value;
		component.set("v.value", value);
		component.set("v.param", param);
	},

	reloadPreview : function(component) {
		let param = component.get("v.parameter");

		if (param.tipologia == "Importo" || param.tipologia == "Divisa") {
			component.set("v.preview", new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(param.value));
		}
	},

	setPrecisioneDecimali : function(component) {
		let precisioneDecimali;
		let parameter = component.get("v.parameter");

		if (parameter.precisioneDecimali != null && parameter.precisioneDecimali != undefined && typeof parameter.precisioneDecimali == "number") {
			precisioneDecimali = 1 / Math.pow(10, parameter.precisioneDecimali);
		} else {
			precisioneDecimali = 0.01;
		}

		component.set("v.precisioneDecimali", precisioneDecimali);
	}
})