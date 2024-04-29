({
	doInit : function(component, event, helper) {
		this.setColumns(component, event, helper)
		this.getRelatedAccounts(component, event, helper)
	},
	getRelatedAccounts: function(component, event, helper) {
		this.setMwColumns(component, event, helper)
		var action = component.get("c.getRelatedNDGs");
		action.setParams({recordId: component.get('v.recordId')})
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
				component.set('v.ndgs', response.getReturnValue())
            }
            else {
                console.log("Failed with state: " + state);
            }
        })
		$A.enqueueAction(action);
	},
	nextPressed: function(component, event, helper) {
		let sampleAccount = component.find('ndgsTable') && component.find('ndgsTable').getSelectedRows().length > 0 
								? component.find('ndgsTable').getSelectedRows()[0]
								: null
		if (sampleAccount) {
			//selectedNDGs
			component.set('v.selectedNDGs', component.find('ndgsTable').getSelectedRows())
			var action = component.get("c.getMicroWallets");
			action.setParams({
				filiale: sampleAccount.Filiale__c,
				modello: sampleAccount.ModelloDiServizio__c
			})
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state == "SUCCESS") {
					//Owner.Name
					let mws = response.getReturnValue()
					const newArray = mws.map(a => Object.assign({}, a));
					newArray.forEach(item => item.Gestore = item.Owner.Name)
					component.set('v.microWallets', newArray)
				}
				else {
					console.log("Failed with state: " + state);
				}
			})
			$A.enqueueAction(action);
			component.set('v.showNDGs', false)
		}
	},
	previousSelected: function(component, event) {
		component.set('v.showNDGs', true)
	},
	assignNDGs: function(component, event, helper) {
		let mwSelected = component.find('mwTable') && component.find('mwTable').getSelectedRows().length > 0 
							? component.find('mwTable').getSelectedRows()[0].Id
							: null
		if (mwSelected) {
			var that = this
			let ndgs = component.get('v.selectedNDGs').map(ndg => ndg.Id)
			var action = component.get("c.executeAssignment");
			var params = {
				ndgIds: ndgs,
				mwId: mwSelected
			}
			action.setParams({params: JSON.stringify(params)})
			action.setCallback(this, function(response) {
				var state = response.getState();
				if (state == "SUCCESS") {
					that.showToast(component, event, helper)
					$A.get('e.force:refreshView').fire();
					component.set('v.showNDGs', true)
					that.getRelatedAccounts(component, event, helper)
				}
				else {
					console.log("Failed with state: " + state);
				}
			})
			$A.enqueueAction(action);
		}
	},
	showToast : function(component, event, helper) {
		var toastEvent = $A.get("e.force:showToast");
		if (toastEvent) {
			toastEvent.setParams({
				"title": "Successo!",
				"message": "Gli NDG sono stati assegnati con successo al Micro-Portafoglio selezionato",
				"type": "success"
			});
			toastEvent.fire();
		}
	},
	setMwColumns: function (component, event, helper) {
		let cols = [{
			label: 'Nome Micro-Portafoglio',
			fieldName: 'Name',
			type: 'text',
			sortable: true
		},
		{
			label: 'Modello di Servizio',
			fieldName: 'PTF_ModelloDiServizio__c',
			type: 'text',
			sortable: true
		},
		{
			label: 'Filiale',
			fieldName: 'PTF_Filiale__c',
			type: 'text',
			sortable: true
		},
		{
			label: 'Gestore',
			fieldName: 'Gestore',
			type: 'text',
			sortable: true
		},
	];
	component.set('v.mwColumns', cols)
	},
	setColumns: function (component, event, helper) {
		let cols = [{
				label: 'Name',
				fieldName: 'Name',
				type: 'text',
				sortable: true
			},
			{
				label: 'NDG',
				fieldName: 'CRM_NDG__c',
				type: 'text',
				sortable: true
			},
			{
				label: 'P.IVA',
				fieldName: 'CRM_VAT__c',
				type: 'text',
				sortable: true
			},
			{
				label: 'Filiale',
				fieldName: 'Filiale__c',
				type: 'text',
				sortable: true
			},
			{
				label: 'Modello di servizio',
				fieldName: 'ModelloDiServizio__c',
				type: 'text',
				sortable: true
			},
			{
				label: 'Natura Giuridica',
				fieldName: 'NaturaGiuridica__c',
				type: 'text',
				sortable: true
			},
			{
				label: 'Gruppo Gestionale',
				fieldName: 'PTF_GruppoGestionale__c',
				type: 'text',
				sortable: true
			},
		];
		component.set('v.columns', cols)
	},
})