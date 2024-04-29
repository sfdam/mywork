({
	setupData : function(component, event, eventType) {
		let subproducts = (eventType == "subproducts" && Array.isArray(event.getParam("value")) ? event.getParam("value") : component.get("v.subproducts"));
		let options = (eventType == "options" ? event.getParam("value") : component.get("v.options"));
		let optionsMap = new Map();
		let rows = [];
		let tipo = component.get("v.tipoSubProduct");
		let icarManuali = component.get("v.icarManuali");
		
		options.forEach(opt => { optionsMap.set(opt.name, opt); });                       
		
		if (subproducts.reduce((start, sp) => {return start || sp.tipo !== undefined;}, false))
            //A.M. Gestione Mutuo Veneto Sviluppo                    
			subproducts = subproducts.filter(sp => {return (sp.tipo == tipo || (sp.tipo.startsWith("IfisImpresa") && tipo.startsWith("IfisImpresa")) || sp.tipo.startsWith("Mutuo") || (sp.tipo.startsWith("VenetoSviluppo") && tipo.startsWith("VenetoSviluppo")));});        

		if (icarManuali) {
			subproducts.forEach(sp => {
				sp.icarManuali.forEach((im, n) => {
					let columns = [];
					let iter = optionsMap.keys();
					let optName;

					while (optName = iter.next().value) {
						columns.push({
							id: optionsMap.get(optName).id,
							type: optionsMap.get(optName).type,
							name: optionsMap.get(optName).name,
							label: optionsMap.get(optName).label,
							order: optionsMap.get(optName).order + ((n+1) * 100),
							disabled: optionsMap.get(optName).disabled,
							step: optionsMap.get(optName).step,
							visible: optionsMap.get(optName).visible != null ? optionsMap.get(optName).visible : true,//(eventType == "subproducts" ? this.calculateVisibility(sp, optionsMap.get(optName)) : (optionsMap.get(optName).visible != null ? optionsMap.get(optName).visible : true)),
							options: optionsMap.get(optName).options,
							value: this.getIcarManualiValueFromOption(sp, im, optName, optionsMap)
						});
					}
				    
					rows.push({tipo: tipo, columns: columns.sort((a, b) => {return a.order - b.order;}), id: (n+1) * 100, selected: false});
				});
			});
		} else {
			subproducts.forEach(sp => {
				let columns = [];
				let iter = optionsMap.keys();
				let optName;
	
				while (optName = iter.next().value) {
					columns.push({
						id: optionsMap.get(optName).id,
						type: optionsMap.get(optName).type,
						name: optionsMap.get(optName).name,
						label: optionsMap.get(optName).label,
						order: optionsMap.get(optName).order,
						disabled: optionsMap.get(optName).disabled,
						step: optionsMap.get(optName).step,
						visible: optionsMap.get(optName).visible != null ? optionsMap.get(optName).visible : true,//(eventType == "subproducts" ? this.calculateVisibility(sp, optionsMap.get(optName)) : (optionsMap.get(optName).visible != null ? optionsMap.get(optName).visible : true)),
						options: optionsMap.get(optName).options,
						value: sp[optName] ? sp[optName] : (optionsMap.get(optName).type == "toggle" ? false : null)
					});
				}
				rows.push({tipo: tipo, columns: columns.sort((a, b) => {return a.order - b.order;}), id: sp.id, selected: false});
			});
		}

		if (rows.length == 0)
			rows.push({tipo: tipo, columns: JSON.parse(JSON.stringify(options)), selected: false});
		
		// console.log("rows: ", rows);
		component.set("v.rows", rows);
	},

	setupTipoSubProduct : function(component, event) {
		if ( (event ? event.getParam("value").find(i => {return  i.isActive}) : component.get("v.items").find(i => {return  i.isActive})) ) {
			let tipoSubProduct = (event ? event.getParam("value").find(i => {return  i.isActive}).codice : component.get("v.items").find(i => {return  i.isActive}).codice);
			component.set("v.tipoSubProduct", tipoSubProduct);
		}
	},

	setupIcarManualiConfig : function(component) {
		let rows = component.get("v.rows");
		let toggleIcarManualiOptions = false;
		let options = component.get("v.options");
		let icarManuali = component.get("v.icarManuali");
		let icarValues = null;

		if (!icarManuali) return;

		if (rows.length > 0) {
			if ( this.isBlank(rows[0].columns.find(c => {return c.name == "dataEmissioneDa";}).value) && !this.isBlank(rows[0].columns.find(c => {return c.name == "numeroFatturaDa";}).value) ) {
				toggleIcarManualiOptions = true;
				icarValues = "numeri";
			}
			else if (!this.isBlank(rows[0].columns.find(c => {return c.name == "dataEmissioneDa";}).value))
				icarValues = "date";
		}

		options.forEach(o => {
			if (o.name != "debitore")
				o.visible = (toggleIcarManualiOptions ? !o.visible : o.visible);
		});

		component.set("v.toggleIcarManualiOptions", toggleIcarManualiOptions);
		component.set("v.disableAddAndRemove", toggleIcarManualiOptions);
		component.set("v.options", options);
		component.set("v.icarValues", icarValues);
	},

	addSubProduct : function(component) {
		let options = component.get("v.options");
		let rows = component.get("v.rows");
		let tipo = component.get("v.items").find(i => {return  i.isActive}).codice;

        console.log('@@@A.M. addOptions: ', options);

		rows.push({tipo: tipo, columns: JSON.parse(JSON.stringify(options)), selected: false});

		component.set("v.rows", rows);
	},

	delSubProduct : function(component) {
		let rows = component.get("v.rows");
		let subproducts = component.get("v.subproducts");
		let icarManuali = component.get("v.icarManuali");
		// let subproductsMap = new Map();

		// subproducts.forEach(sp => {subproductsMap.set(sp.id, sp);});

		if (icarManuali)
			rows = rows.filter(r => { return !r.selected; });
		else
			rows.forEach(r => {
				if (r.selected) {
					if (r.id != undefined && r.id != null)
						subproducts = subproducts.filter(sp => {return sp.id != r.id;});
				}
			});
		
		component.set("v.rows", rows);
		component.set("v.subproducts", subproducts);
		component.set("v.anySelectedRow", false);
	},

	toggleRowSelection : function(component, event) {
		let rows = component.get("v.rows");
		let index = parseInt(event.getSource().get("v.name").replace("sp-id-", ""));
		
		rows[index].selected = !rows[index].selected;
		this.setAnySelectedRowFlag(component, rows);

		component.set("v.rows", rows);
	},

	setAnySelectedRowFlag : function(component, rows) {
		component.set("v.anySelectedRow", rows.reduce((start, r) => {return start || r.selected;}, false));
	},

	setCheckboxValue : function(component, event) {
		// event.preventDefault();
		let index = parseInt(event.currentTarget.getAttribute("data-index").replace("checkbox-id-", ""));
		let name = event.currentTarget.name;
		let value = event.currentTarget.checked;
		let rows = component.get("v.rows");
		
		rows[index].columns.find(c => {return c.name == name;}).value = value;
		
		component.set("v.rows", rows);
	},

	fireChangeEvent : function(component, event) {
		var sObjectEvent = component.getEvent("subProductChange");
        sObjectEvent.setParams({
			"isChanging": true,
			"fieldName": event.getSource().get("v.name"),
			"fieldValue": event.getSource().get("v.value")
        });
        sObjectEvent.fire();
	},

	toggleIcarManualiOptions : function(component, event) {
		let options = component.get("v.options");
		let toggleIcarManualiOptions = event.getSource().get("v.checked");
		let icarValues = component.get("v.icarValues");

		options.forEach(o => {
			if (o.name != "debitore")
				o.visible = !o.visible;
		});
// console.log("options: ", options);
		component.set("v.disableAddAndRemove", toggleIcarManualiOptions);
		component.set("v.options", options);
		// component.set("v.subproducts", []);
		if (( toggleIcarManualiOptions == true && icarValues == "numeri" ) || ( toggleIcarManualiOptions == false && icarValues == "date" ))
			this.setupData(component);
		else {
			let rows = component.get("v.rows");
			rows.forEach(r => {
				r.columns.forEach(c => {
					if (c.name != "debitore")
						c.value = "";
				});
			});
			component.set("v.rows", rows);
		}
	},

	reloadData : function(component) {
		let rows = component.get("v.rows");
		let options = component.get("v.options");
		let optionsMap = new Map();
		let mainData = [];
		let tipo = component.get("v.tipoSubProduct");
        
		options.forEach(opt => { optionsMap.set(opt.name, opt); });
		
		rows.forEach(r => {
			let data = {};
			r.columns.forEach(c => {Object.defineProperty(data, c.name, {value: c.value});});
			mainData.push(data);
		});

		rows.forEach((r, i) => {
			let data = {};
			r.columns.forEach(c => {Object.defineProperty(data, c.name, {value: c.value});});
			r.columns.forEach(c => {
				c.visible = this.calculateVisibility(mainData, optionsMap.get(c.name), i);
				//SM - TEN: CR 212 gestione pre ammortamento				
				if(optionsMap.get(c.name).formulaLabel != undefined)
					c.label = this.evalFormula(mainData, optionsMap.get(c.name).formulaLabel, i);
				if (!this.isBlank(optionsMap.get(c.name).disabledIf))
					c.disabled = this.evalFormula(mainData, optionsMap.get(c.name).disabledIf, i);
				if (!this.isBlank(optionsMap.get(c.name).formula))
					c.value = this.evalFormula(mainData, optionsMap.get(c.name).formula, i);
				if (c.type == "select" && c.visible)
					c.options.forEach(o => {
						if (!this.isBlank(o.disabledIf))
							o.disabled = this.evalFormula(mainData, o.disabledIf, i);
						if (c.value == o.value && o.disabled)
							c.value = null;
					});
			});
		});

		if (rows.length == 0)
			rows.push({tipo: tipo, columns: JSON.parse(JSON.stringify(options)), selected: false});

		component.set("v.rows", rows);
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

	getIcarManualiValueFromOption : function(sp, im, optName, optionsMap) {
		if (optName == "debitore")
			return sp[optName];
		else if (optName == "dataEmissioneDa" || optName == "dataEmissioneA") {
			let dateField = new Date(im[optName]);
			return (!this.isBlank(im[optName]) ? dateField.getFullYear() + "-" + (dateField.getMonth()+1) + "-" + dateField.getDate() : null);
		}
		else
			return im[optName] ? im[optName] : (optionsMap.get(optName).type == "toggle" ? false : null);
	},

	//SM - TEN: Banca Corporate Setup BTN Visibility
	setupBtnVisible : function(component){
		let tipoSubProduct = component.get("v.tipoSubProduct");
		let check = ( tipoSubProduct != undefined && !tipoSubProduct.startsWith('IfisImpresa') );
		component.set("v.isBtnVisible", check);
	}
})