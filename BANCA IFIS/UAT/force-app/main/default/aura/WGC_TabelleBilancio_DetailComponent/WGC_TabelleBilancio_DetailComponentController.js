({
	init : function(component, event, helper) {
		var tipoBilancio = component.get("v.tipoBilancio");
		if(tipoBilancio == 'Consolidato' || tipoBilancio == 'Controllante'){
			console.log('@@@ tipo bilancio ' , component.get('v.tipoBilancio'));
			helper.callBilancioSpecial(component, event, helper);
		}
		helper.loadTables(component, event, helper);

		helper.apex(component, event, 'getDataFromAccount', { ndgGruppo : component.get('v.ndgGruppo') })
        .then($A.getCallback(function (result) {
			console.log('result getDataFromAccount', result);

			component.set('v.columnsXXX', [
				{label: 'Descrizione', fieldName: 'desc', type: 'string', /*initialWidth: 530,*/ cellAttributes:{ class:{ fieldName:"cellClass" } }},
				//{label: '' , fieldName: 'val', type: 'boolean', cellAttributes:{ class:{ fieldName:"col1" } }},
				{label: 'Valore' , fieldName: 'string', type: 'string', cellAttributes:{ class:{ fieldName:"col2" } }}
			  ]);
	  
			  var results = [];
	  
			  var descriptions = [$A.get("$Label.c.WGC_Fascia_MCC_Anagrafica"),
			  						    $A.get("$Label.c.WGC_Fascia_MCC_BilancioMaxAnno"),
										$A.get("$Label.c.WGC_Fascia_MCC_FlagDimensionale"),
										$A.get("$Label.c.WGC_Fascia_MCC_Motivo_NumEsercizioBilancio"),'',
								  $A.get("$Label.c.WGC_Fascia_MCC_Segnalazioni"),
										$A.get("$Label.c.WGC_Fascia_MCC_SP14_SP23"),
										$A.get("$Label.c.WGC_Fascia_MCC_SP16_CE25"),
										$A.get("$Label.c.WGC_Fascia_MCC_Motivo_Fatturato"),
										$A.get("$Label.c.WGC_Fascia_MCC_Motivo_Estero"),
										$A.get("$Label.c.WGC_Fascia_MCC_Motivo_NumEsercizi"),
										$A.get("$Label.c.WGC_Fascia_MCC_Motivo_NaturaGiuridica"),
										$A.get("$Label.c.WGC_Fascia_MCC_Motivo_Ateco"),
										$A.get("$Label.c.WGC_Fascia_MCC_Motivo_AtecoNonValutabile"),'',
								  $A.get("$Label.c.WGC_Fascia_MCC_ScoreBilancio"),
										$A.get("$Label.c.WGC_Fascia_MCC_BilancioKPI"),
										$A.get("$Label.c.WGC_Fascia_MCC_BilancioCodFascia"),
										$A.get("$Label.c.WGC_Fascia_MCC_BilancioValorePD"),'',
								  $A.get("$Label.c.WGC_Fascia_MCC_ScoreCR"),
								  	    $A.get("$Label.c.WGC_Fascia_MCC_CRKPI"),
										$A.get("$Label.c.WGC_Fascia_MCC_CRCodFascia"),
										$A.get("$Label.c.WGC_Fascia_MCC_CRValorePD"),'',
								  $A.get("$Label.c.WGC_Fascia_MCC"),
										$A.get("$Label.c.WGC_Fascia_MCC_Valore"),
										$A.get("$Label.c.WGC_Fascia_MCC_CodFascia")
								  ];

									results.push(
										{ desc: descriptions[0], val : '', string : '' },
										{ desc: descriptions[1], val : '', string : result.WGC_Max_Anno_Bilancio__c},
										{ desc: descriptions[2], val : result.WGC_Flag_dimensionale_KPI_Bilancio__c, string : (result.WGC_Flag_dimensionale_KPI_Bilancio__c) ? 'Si' : 'No' },
										{ desc: descriptions[3], val : '', string : result.WGC_Numero_Bilanci__c },
										{ desc: descriptions[4], val : '', string : '' },

										{ desc: descriptions[5], val : '', string : '' },
										{ desc: descriptions[6], val : result.WGC_Motivo_flag_SP14_SP23__c, string : (result.WGC_Motivo_flag_SP14_SP23__c) ? 'Si' : 'No' },
										{ desc: descriptions[7], val : result.WGC_Motivo_flag_SP16_CE25__c, string : (result.WGC_Motivo_flag_SP16_CE25__c) ? 'Si' : 'No' },
										{ desc: descriptions[8], val : result.WGC_Motivo_flag_fatturato__c, string : (result.WGC_Motivo_flag_fatturato__c) ? 'Si' : 'No' },
										{ desc: descriptions[9], val : result.WGC_Motivo_flag_estero__c, string : (result.WGC_Motivo_flag_estero__c) ? 'Si' : 'No' },
										{ desc: descriptions[10], val : result.WGC_Motivo_flag_numero_esercizi__c, string : (result.WGC_Motivo_flag_numero_esercizi__c) ? 'Si' : 'No' },
										{ desc: descriptions[11], val : result.WGC_Motivo_flag_natura_giuridica__c, string : (result.WGC_Motivo_flag_natura_giuridica__c) ? 'Si' : 'No' },
										{ desc: descriptions[12], val : result.WGC_Motivo_flag_Ateco_non_presente__c, string : (result.WGC_Motivo_flag_Ateco_non_presente__c) ? 'Si' : 'No' },
										{ desc: descriptions[13], val : result.WGC_Motivo_flag_Ateco_non_valutabile__c, string : (result.WGC_Motivo_flag_Ateco_non_valutabile__c) ? 'Si' : 'No' },
										{ desc: descriptions[14], val : '', string : '' },

										{ desc: descriptions[15], val : '', string : '' },
										{ desc: descriptions[16], val : '', string : result.WGC_Codice_classe_KPI_Bilancio__c },
										{ desc: descriptions[17], val : '', string : (result.WGC_Codice_fascia_MCC_Bilancio__c == null || result.WGC_Codice_fascia_MCC_Bilancio__c == '') ? ' - ' : result.WGC_Codice_fascia_MCC_Bilancio__c },
										{ desc: descriptions[18], val : '', string : result.WGC_Valore_PD_Bilancio__c },
										{ desc: descriptions[19], val : '', string : '' },

										{ desc: descriptions[20], val : '', string : '' },
										{ desc: descriptions[21], val : '', string : result.WGC_Codice_classe_KPI_CR__c },
										{ desc: descriptions[22], val : '', string : (result.WGC_Codice_fascia_MCC_CR__c == null || result.WGC_Codice_fascia_MCC_CR__c == '') ? ' - ' : result.WGC_Codice_fascia_MCC_CR__c },
                                        { desc: descriptions[23], val : '', string : result.hasOwnProperty('WGC_Valore_PD_CR__c') ? result.WGC_Valore_PD_CR__c.toString() : ''},
										{ desc: descriptions[24], val : '', string : '' },

										{ desc: descriptions[25], val : '', string : '' },
										{ desc: descriptions[26], val : '', string : result.WGC_Codice_classe_valore_MCC__c },
										{ desc: descriptions[27], val : '', string : (result.Fascia_MCC__c == null || result.Fascia_MCC__c == '') ? ' - ' : result.Fascia_MCC__c.toString() }
																				
									);
						  
									//results = this.soglie(component, event, results);

			// Fascia MCC
			results[0].cellClass = 'bold-desc';
			results[2].col1 = result.WGC_Flag_dimensionale_KPI_Bilancio__c ? 'red bold-desc' : 'bold-desc';
			results[2].col2 = result.WGC_Flag_dimensionale_KPI_Bilancio__c ? 'red bold-desc' : 'bold-desc';
			results[3].col2 = parseInt(result.WGC_Numero_Bilanci__c) <= 1 ? 'red bold-desc' : 'green bold-desc';

			results[5].cellClass = 'bold-desc';
			results[6].col1 = result.WGC_Motivo_flag_SP14_SP23__c ? 'red bold-desc' : 'green bold-desc';
			results[6].col2 = result.WGC_Motivo_flag_SP14_SP23__c ? 'red bold-desc' : 'green bold-desc';
			results[7].col1 = result.WGC_Motivo_flag_SP16_CE25__c ? 'red bold-desc' : 'green bold-desc';
			results[7].col2 = result.WGC_Motivo_flag_SP16_CE25__c ? 'red bold-desc' : 'green bold-desc';
			results[8].col1 = result.WGC_Motivo_flag_fatturato__c ? 'red bold-desc' : 'green bold-desc';
			results[8].col2 = result.WGC_Motivo_flag_fatturato__c ? 'red bold-desc' : 'green bold-desc';
			results[9].col1 = result.WGC_Motivo_flag_estero__c ? 'red bold-desc' : 'green bold-desc';
			results[9].col2 = result.WGC_Motivo_flag_estero__c ? 'red bold-desc' : 'green bold-desc';
			results[10].col1 = result.WGC_Motivo_flag_numero_esercizi__c ? 'red bold-desc' : 'green bold-desc';
			results[10].col2 = result.WGC_Motivo_flag_numero_esercizi__c ? 'red bold-desc' : 'green bold-desc';
			results[11].col1 = result.WGC_Motivo_flag_natura_giuridica__c ? 'red bold-desc' : 'green bold-desc';
			results[11].col2 = result.WGC_Motivo_flag_natura_giuridica__c ? 'red bold-desc' : 'green bold-desc';
			results[12].col1 = result.WGC_Motivo_flag_Ateco_non_presente__c ? 'red bold-desc' : 'green bold-desc';
			results[12].col2 = result.WGC_Motivo_flag_Ateco_non_presente__c ? 'red bold-desc' : 'green bold-desc';
			results[13].col1 = result.WGC_Motivo_flag_Ateco_non_valutabile__c ? 'red bold-desc' : 'green bold-desc';
			results[13].col2 = result.WGC_Motivo_flag_Ateco_non_valutabile__c ? 'red bold-desc' : 'green bold-desc';

			results[15].cellClass = 'bold-desc';
			results[17].col1 = result.WGC_Codice_fascia_MCC_Bilancio__c == '5' ? 'red bold-desc' : (result.WGC_Codice_fascia_MCC_Bilancio__c == null || result.WGC_Codice_fascia_MCC_Bilancio__c == '') ? 'bold-desc' : 'green bold-desc';
			results[17].col2 = result.WGC_Codice_fascia_MCC_Bilancio__c == '5' ? 'red bold-desc' : (result.WGC_Codice_fascia_MCC_Bilancio__c == null || result.WGC_Codice_fascia_MCC_Bilancio__c == '') ? 'bold-desc' : 'green bold-desc';
			
			results[20].cellClass = 'bold-desc';
			results[22].col1 = result.WGC_Codice_fascia_MCC_CR__c == '5' ? 'red bold-desc' : (result.WGC_Codice_fascia_MCC_CR__c == null || result.WGC_Codice_fascia_MCC_CR__c == '') ? 'bold-desc' : 'green bold-desc';
			results[22].col2 = result.WGC_Codice_fascia_MCC_CR__c == '5' ? 'red bold-desc' : (result.WGC_Codice_fascia_MCC_CR__c == null || result.WGC_Codice_fascia_MCC_CR__c == '') ? 'bold-desc' : 'green bold-desc';

			results[25].cellClass = 'bold-desc';
			results[27].col1 = result.Fascia_MCC__c == '5' ? 'red bold-desc' : (result.Fascia_MCC__c == null || result.Fascia_MCC__c == '') ? 'bold-desc' : 'green bold-desc';
			results[27].col2 = result.Fascia_MCC__c == '5' ? 'red bold-desc' : (result.Fascia_MCC__c == null || result.Fascia_MCC__c == '') ? 'bold-desc' : 'green bold-desc';
			
			component.set('v.dataXXX', results);
					
        })).finally($A.getCallback(function () {

        }));
	},

	collapse : function (component, event, helper){
		component.set("v.IsCollapsed", !component.get("v.IsCollapsed"));
	},

	collapse2 : function (component, event, helper){
		component.set("v.IsCollapsed2", !component.get("v.IsCollapsed2"));
	},

	collapse3 : function (component, event, helper){
		component.set("v.IsCollapsed3", !component.get("v.IsCollapsed3"));
	},

	collapse4 : function (component, event, helper){
		component.set("v.IsCollapsed4", !component.get("v.IsCollapsed4"));
	},
})