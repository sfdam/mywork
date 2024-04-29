({
	doInit : function(component, event, helper) {
		helper.setupTipoSubProduct(component);
		helper.setupData(component);
		helper.setupIcarManualiConfig(component);
		//SM - TEN: Setup BTN Visibility
		helper.setupBtnVisible(component);
        
        //A.M. Gestione Mutuo Veneto Sviluppo
        //let tipoSProdVs = component.get("v.tipoSubProduct");
        //console.log ('@@@A.M. tipoSProdVs:', tipoSProdVs);
        //if (tipoSProdVs.startsWith("VenetoSviluppo"))
        //{ 
        //    console.log('@@@A.M. doIniti VS');
            //helper.addSubProduct(component);
        //}
	},

	addSubProduct : function(component, event, helper) {
		helper.addSubProduct(component);
		// helper.fireChangeEvent(component, event);
	},

	delSubProduct : function(component, event, helper) {
		try {
			helper.delSubProduct(component);
			helper.fireChangeEvent(component, event);
		} catch (e) {
			console.log("WGC_SubProduct_WrapperController.delSubProduct ERROR: ", e.message);
		}
	},

	onCheckboxChange : function(component, event, helper) {
		helper.toggleRowSelection(component, event);
	},

	reloadOptions : function(component, event, helper) {
		try {
			helper.setupData(component, event, "options");
		} catch (e) {
			console.log("WGC_SubProduct_WrapperController.reloadOptions ERROR: ", e.message);
		}
	},

	reloadData : function(component, event, helper) {
		try {
			helper.setupData(component, event, "subproducts");
			helper.setupIcarManualiConfig(component);
			helper.reloadData(component);
		} catch (e) {
			console.log("WGC_SubProduct_WrapperController.reloadData ERROR: ", e.message);
		}
	},

	onChangeCheckboxField : function(component, event, helper) {
		helper.setCheckboxValue(component, event);
	},

	refreshTipoSubProduct : function(component, event, helper) {
		helper.setupTipoSubProduct(component, event);
		helper.setupBtnVisible(component);
	},

	onChangeData : function(component, event, helper) {
		helper.fireChangeEvent(component, event);
		helper.reloadData(component);
		helper.reloadData(component);
	},

	onToggleIcarManualiOptions : function(component, event, helper) {
		try {
			helper.toggleIcarManualiOptions(component, event);
			helper.fireChangeEvent(component, event);
			// helper.setupData(component);
		} catch (e) {
			console.log("WGC_SubProduct_WrapperController.onToggleIcarManualiOptions ERROR: ", e.message);
		}
	}
})