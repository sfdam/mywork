({
	doInit: function (component, event, helper) {
		component.set('v.accountId', component.get("v.options")[0].accountId);
		component.set('v.contactId', component.get("v.options")[0].contactId);

		// SOLUZIONE CHECK BOX
		// helper.apex(component, event, 'getInformationContact', { contactId: component.get("v.options")[0].contactId, accountId: component.get("v.options")[0].accountId })
		// 	.then(function (result) {
		// 		console.log(result);
		// 		component.set('v.rolesList', result.data[0].accContactRelationList[0].WGC_Ruolo__c != null ? result.data[0].accContactRelationList[0].WGC_Ruolo__c.split(';') : []);
		// 		component.set('v.contactNDG', result.data[0].accContactRelationList[0].Contact.hasOwnProperty('NDGGruppo__c') ? result.data[0].accContactRelationList[0].Contact.NDGGruppo__c : null);

		// 	}).finally($A.getCallback(function () {
		// 		helper.hideSpinner(component);
		// 		var contactNDG = component.get('v.contactNDG');
		// 		if(contactNDG == null){
		// 			var toastEvent = $A.get("e.force:showToast");
        //                     toastEvent.setParams({
        //                         "title": "Error!",
        //                         "message": $A.get("$Label.c.WGC_EditRolesModal_Body_ErrorMessage"),
        //                         "type": "error"
        //                     });
		// 				toastEvent.fire();
		// 				helper.closeAction(component, event, 'cancel');
		// 		}
		// 		let roles = component.get('v.rolesList');
		// 		var ruoli = [];
		// 		roles.forEach(function (element) {
		// 			// console.log("element.Name: ", element.Name);
		// 			// console.log("objSelected.BillingCity: ", objSelected.BillingCity);
		// 			ruoli.push(element);
		// 		});

		// 		component.set('v.rolesListSet', ruoli);

		// 		var optsList = [];

		// 		// if(!(roles.includes('J') || roles.includes('J1'))){
		// 		optsList.push({
		// 			label: $A.get("$Label.c.WGC_EditRolesModal_Body_TE"),
		// 			valueId: 'J',
		// 			value: 'J',
		// 			checked: (roles.includes('J') || roles.includes('J1')) ? 'true' : '',
		// 			disabled: (roles.includes('J') || roles.includes('J1')) ? true : false
		// 		});
		// 		// }

		// 		// if(!roles.includes('Z1')){
		// 		optsList.push({
		// 			label: $A.get("$Label.c.WGC_EditRolesModal_Body_Esecutore"),
		// 			valueId: 'Z1',
		// 			value: 'Z1',
		// 			checked: (roles.includes('Z1')) ? 'true' : '',
		// 			disabled: (roles.includes('Z1')) ? true : false,
		// 		});
		// 		// }

		// 		component.set("v.optionsCheck", optsList);

		// 		component.set("v.valueCheck", roles);


		// 	}));

		// SOLUZIONE MULTI PICKLIST SELECTION
		var ruoli = [];
		var contactCensimento;
		var accountCensimento;
		helper.apex(component, event, 'getInformationContact', { contactId: component.get("v.options")[0].contactId, accountId: component.get("v.options")[0].accountId })
			.then($A.getCallback(function (result) {
				console.log('SV Contact result: ', result);
				console.log('SV Contact result: ', result.data[0].accContactRelationList[0].Contact.Censimento__c);

				ruoli = result.data[0].accContactRelationList[0].hasOwnProperty('WGC_Ruolo__c') ? result.data[0].accContactRelationList[0].WGC_Ruolo__c.split(';') : [];
				contactCensimento =  result.data[0].accContactRelationList[0].Contact.hasOwnProperty('Censimento__c') ? result.data[0].accContactRelationList[0].Contact.Censimento__c : null;
				component.set('v.contactCensimento', contactCensimento);

				if(contactCensimento == null || !contactCensimento.includes('Completo')){
								var toastEvent = $A.get("e.force:showToast");
					                    toastEvent.setParams({
					                        "title": "Error!",
					                        "message": $A.get("$Label.c.WGC_EditRolesModal_Body_ErrorMessage"),
					                        "type": "error"
					                    });
									toastEvent.fire();
									helper.closeAction(component, event, 'cancel');

							}

					return helper.apex(component, event, 'getOriginAccount', { accountId: component.get("v.options")[0].accountId })
                })).then($A.getCallback(function (result) {
                    console.log('SV Account result: ', result);
					component.set('v.accountSelected', result);
					
					accountCensimento =  result.hasOwnProperty('WGC_Censimento__c') ? result.WGC_Censimento__c : null;
					if(accountCensimento == null || !accountCensimento.includes('Completo')){
						var toastEvent = $A.get("e.force:showToast");
								toastEvent.setParams({
									"title": "Error!",
									"message": $A.get("$Label.c.WGC_EditRolesModal_Body_ErrorMessage"),
									"type": "error"
								});
							toastEvent.fire();
							helper.closeAction(component, event, 'cancel');

					}

                    return helper.apex(component, event, 'getCompatibleRoles', { naturaGiuridica: result.NaturaGiuridica__c })
                })).then($A.getCallback(function (result) {
					console.log('RUOLI COMPATIBILI: ', result);
					console.log('RUOLI SELEZIONATI: ', ruoli);			

                    var opts = [];
    
                    for (var k in result) {
                        opts.push({
							class: "",
							selected: ruoli.includes(k),
							disabled: ruoli.includes(k),
                            label: result[k],
                            value: k
                        });
					}

					var elemFirstChar;
            		var elem;

            		var organoProcedura;
					ruoli.forEach(function(element) {
						if(element != 'J' && element != 'J1' && element != 'Z' && element != 'T'  && element != 'W2'  && element != 'L2'  && element != 'Y1'){
							elemFirstChar = element.charAt(0);
                            elem = element;
						}else if (element == 'W2'  || element == 'L2' || element == 'Y1'){
							//PALUMBO 03/02/2020 - inserita logica per organo della procedura
							organoProcedura = element;
							component.set("v.organoProcedura",true);
						}
					});
            
            		console.log('elem', elem);
            		console.log('elem in ruoli', elem in result);
            		console.log('opts', opts);

					for (var k in opts) {                        
						if(opts[k].value != 'J' && opts[k].value != 'U' && (opts[k].value.charAt(0) == elemFirstChar && elem in result)){
							opts[k].disabled = true;
						} else if(opts[k].value != 'J' && opts[k].value != 'U'){
							opts[k].disabled = false;
						}

						//check organo procedura
						//PALUMBO 03/02/2020 - inserita logica per organo della procedura
						if (organoProcedura != undefined){
							if (opts[k].value == 'W2' || opts[k].value == 'L2' || opts[k].value == 'Y1'){
								opts[k].disabled = true;
							}
						}
					}

                    component.set("v.InputPicklistRuolo", opts);
                    return null;
                })).finally($A.getCallback(function () {
					helper.hideSpinner(component);                    
                }));

	},

	handleChange: function (cmp, event) {
		// var changeValue = event.getParam("value");
		let roles = cmp.get('v.rolesList');
		var changeValue = event.getSource().get('v.value');
		var checked = event.getSource().get('v.checked');

		if (checked) {
			roles.push(changeValue);
		} else {
			var index = roles.indexOf(changeValue);
			if (index > -1) {
				roles.splice(index, 1);
			}
		}

		console.log(roles);

		cmp.set('v.rolesList', roles);



	},

	closeError: function (component, event) {
		// for Hide/Close Model,set the "isOpen" attribute to "Fasle"

		var cmpTarget = component.find('errors-container');
		$A.util.addClass(cmpTarget, 'transit');
		component.set("v.errors", null);
	},

	manageF2B: function (component, event, helper) {
		// manage Footer event
		helper.showSpinner(component);
        var json = JSON.parse(event.getParam("json"));
        var currentContact = component.get('v.currentContact');

        switch (json.action) {
            
            case 'cancel':
                helper.closeAction(component, event, json.action);
                break;
            case 'submit':
                console.log('JSON: ', json);
				// helper.submit(component, json);
				var accountId = component.get('v.accountId');
				var contactId = component.get('v.contactId');
				var rolesList = component.get("v.mySelectedItems");
				// <aura:attribute name="accountId" type="String" />
				// <aura:attribute name="contactId" type="String" />
				// <aura:attribute name="rolesList" type="String[]" />
				
				console.log('rolesList', rolesList);
                helper.apex(component, event, 'updateRole', { accountId: accountId, contactId: contactId,  rolesList: rolesList })
                    .then($A.getCallback(function (result) {
						console.log(result);
						if (result.success) {
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								"title": "Success!",
								"message": $A.get("$Label.c.WGC_EditRolesModal_Body_SuccessMessage"),
								"type": "success"
							});
							toastEvent.fire();
							helper.closeAction(component, event, json.action);
							
						} else {
							component.set("v.errors", result.msg);							
						}
                    })).finally($A.getCallback(function () {
							helper.hideSpinner(component);
                    }));
                break;
        }
	},
	
	//changes filter parameters
    handleSelectChangeEvent: function (component, event, helper) {
        var items = component.get("v.mySelectedItems");
		items = event.getParam("values");
		
		console.log('EVENT items: ', items);

		var elem;
		var organoProcedura;
		var precompiledOrganoProcedura = component.get("v.organoProcedura");
		items.forEach(function(element) {
			if(element.includes('Z') || element.includes('T')){
				elem = element;
			}else if (element.includes('W2')  || element.includes('L2') || element.includes('Y1')){
				//PALUMBO 03/02/2020 - inserita logica per organo della procedura
				organoProcedura = element;
			}
		});

		var opt = component.get("v.InputPicklistRuolo");
		
		for (var k in opt) {
			if(opt[k].value != 'J' && opt[k].value != 'U' && elem != undefined && opt[k].value != elem){
				opt[k].disabled = true;
			} else if(opt[k].value != 'J' && opt[k].value != 'U' && elem == undefined){
				opt[k].disabled = false;
			}

			//check organo procedura
			//PALUMBO 03/02/2020 - inserita logica per organo della procedura
			if (precompiledOrganoProcedura) {
				if (opt[k].value == 'L2' || opt[k].value == 'Y1' || opt[k].value == 'W2'){
					opt[k].disabled = true;
				}
			}else {
				if (organoProcedura != undefined){
					switch (organoProcedura){
						case 'W2':
							if (opt[k].value == 'L2' || opt[k].value == 'Y1'){
								opt[k].disabled = true;
							}else if (opt[k].value == 'W2'){
								opt[k].disabled = false;
							}
							break;
						case 'L2':
							if (opt[k].value == 'W2' || opt[k].value == 'Y1'){
								opt[k].disabled = true;
							}else if (opt[k].value == 'L2'){
								opt[k].disabled = false;
							}
							break;
						case 'Y1':
							if (opt[k].value == 'W2' || opt[k].value == 'L2' ){
								opt[k].disabled = true;
							}else if (opt[k].value == 'Y1' ){
								opt[k].disabled = false;
							}
							break;
					}
				}else {
					if (opt[k].value == 'W2' || opt[k].value == 'L2' || opt[k].value == 'Y1'){
						opt[k].disabled = false;
					}
				}
			}
		}

		component.set("v.InputPicklistRuolo", opt);
		component.set("v.mySelectedItems", items);
		
	}
})