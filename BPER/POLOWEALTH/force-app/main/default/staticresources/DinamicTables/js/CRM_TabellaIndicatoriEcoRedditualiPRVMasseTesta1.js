{
  "thead": [
  {
      "tag": "tr",
      "key": "tr_1",
	  "class": "header-title",
      "thElements": [
        {
          "key": "th_1",
		  "apiName": "CRM_DataTabellaStock__c",
          "rowspan": "2",
          "colspan": "1",
          "class": "",
          "style": "background-color: white;font-size:12px;",
          "divElements": [
            {
              "key": "div_1",
              "class": "",
              "style": "",
              "value": ""
            }
          ]
        },
        {
          "key": "th_2",
		  "apiName": "",
          "rowspan": "1",
          "colspan": "2",
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center slds-p-left_x-small slds-p-right_x-small test-two",
              "style": "",
              "value": "PF"
            }
          ]
        },
        {
          "key": "th_3",
		  "apiName": "",
          "rowspan": "1",
          "colspan": "2",
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center slds-p-left_x-small slds-p-right_x-small test-two",
              "style": "",
              "value": "Quota parte CO"
            }
          ]
        },
        {
          "key": "th_4",
		  "apiName": "",
          "rowspan": "1",
          "colspan": "2",
          "class": "",
          "style": "",
          "divElements": [
            {
              "class": "slds-align_absolute-center slds-p-left_x-small slds-p-right_x-small test-two",
              "style": "",
              "value": "PF + Quota parte CO"
			   }
          ]
        }
      ]
    },
    {
      "tag": "tr",
      "key": "tr_2",
	  "class": "header-title",
      "thElements": [
        {
          "key": "th_1",
		  "apiName": "",
          "rowspan": "1",
          "colspan": "1",
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center slds-p-left_x-small slds-p-right_x-small test-two",
              "style": "",
              "value": "Giorno (t-1)"
            }
          ]
        },
        {
          "key": "th_2",
		  "apiName": "",
          "rowspan": "1",
          "colspan": "1",
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center slds-p-left_x-small slds-p-right_x-small test-two",
              "style": "",
              "value": "Variaz. % vs Fine Anno Prec."
            }
          ]
        },
        {
          "key": "th_3",
		  "apiName": "",
          "rowspan": "1",
          "colspan": "1",
          "class": "",
          "style": "",
          "divElements": [
            {
              "class": "slds-align_absolute-center slds-p-left_x-small slds-p-right_x-small test-two",
              "style": "",
              "value": "Giorno (t-1)"
            }
          ]
        },
        {
          "key": "th_4",
		  "apiName": "",
          "rowspan": "1",
          "colspan": "1",
          "class": "",
          "style": "",
          "divElements": [
            {
              "class": "slds-align_absolute-center slds-p-left_x-small slds-p-right_x-small test-two",
              "style": "",
              "value": "Variaz. % vs Fine Anno Prec."
            }
          ]
        },
        {
          "key": "th_5",
		  "apiName": "",
          "rowspan": "1",
          "colspan": "1",
          "class": "",
          "style": "",
          "divElements": [
            {
              "class": "slds-align_absolute-center slds-p-left_x-small slds-p-right_x-small test-two",
              "style": "",
              "value": "Giorno (t-1)"
			 }
          ]
        },
        {
          "key": "th_6",
		  "apiName": "",
          "rowspan": "1",
          "colspan": "1",
          "class": "",
          "style": "",
          "divElements": [
            {
              "class": "slds-align_absolute-center slds-p-left_x-small slds-p-right_x-small test-two",
              "style": "",
              "value": "Variaz. % vs Fine Anno Prec."
            }
          ]
        }
      ]
    }
  ],
  "tbody": [
    {
      "tag": "tr",
      "key": "tr_1",
      "class": "slds-hint-parent accordion",
      "style": "",
      "tdElements": [
        {
          "key": "td_1",
          "apiName": "",
          "value": "RACCOLTA COMPLESSIVA",
          "formatted": {
            "type": "text"
          },
          "class": "slds-is-relative",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "first-column-definition",
              "style": "",
              "buttonAccordion": true
            }
          ]
        },
        {
          "key": "td_2",
          "apiName": "CRM_RaccoltaComplessiva_t_1__c",
          "value": "",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_3",
          "apiName": "CRM_VariazioneRaccComplT_1VsAP__c",
          "value": "",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_4",
          "apiName": "",
          "value": "{tableValues.raccoltaCoGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_5",
          "apiName": "",
          "value": "{tableValues.raccoltaCoVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_6",
          "apiName": "",
          "value": "{tableValues.raccoltaTotGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
			   }
          ]
        },
        {
          "key": "td_7",
          "apiName": "",
          "value": "{tableValues.raccoltaTotVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        }
      ]
    },
    {
      "tag": "tr",
      "key": "tr_2",
      "class": "accordion_tr_1 slds-hide",
      "style": "background-color: white;",
      "tdElements": [
        {
          "key": "td_1",
          "apiName": "",
          "value": "Liquidità",
          "formatted": {
            "type": "text"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "first-column-definition",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_2",
          "apiName": "CRM_Liquidita_t_1__c",
          "value": "",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_3",
          "apiName": "CRM_VarLiquidita_t_1VSFinAP__c",
          "value": "",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_4",
          "apiName": "",
          "value": "{tableValues.liquiditaCoGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_5",
          "apiName": "",
          "value": "{tableValues.liquiditaCoVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_6",
          "apiName": "",
          "value": "{tableValues.liquiditaTotGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
			   }
          ]
        },
        {
          "key": "td_7",
          "apiName": "",
          "value": "{tableValues.liquiditaTotVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        }
      ]
    },
    {
      "tag": "tr",
      "key": "tr_3",
      "class": "accordion_tr_1 slds-hide",
      "style": "background-color: #efefef",
      "tdElements": [
        {
          "key": "td_1",
          "apiName": "",
          "value": "Raccolta Diretta",
          "formatted": {
            "type": "text"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "first-column-definition",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_2",
          "apiName": "CRM_RaccoltaDiretta_t_1__c",
          "value": "",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_3",
          "apiName": "Variazione_Racc_Diretta_t_1_Fine_AP__c",
          "value": "",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_4",
          "apiName": "",
          "value": "{tableValues.racDirCoGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_5",
          "apiName": "",
          "value": "{tableValues.racDirCoVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_6",
          "apiName": "",
          "value": "{tableValues.racDirTotGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
			   }
          ]
        },
        {
          "key": "td_7",
          "apiName": "",
          "value": "{tableValues.racDirTotVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        }
      ]
    },
    {
      "tag": "tr",
      "key": "tr_4",
      "class": "accordion_tr_1 slds-hide",
      "style": "background-color: white;",
      "tdElements": [
        {
          "key": "td_1",
          "apiName": "",
          "value": "Raccolta Amministrata",
          "formatted": {
            "type": "text"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "first-column-definition",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_2",
          "apiName": "CRM_RaccoltaAmministrata_t_1__c",
          "value": "",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_3",
          "apiName": "CRM_VariazRaccAmm_t_1VSFineAP__c",
          "value": "",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_4",
          "apiName": "",
          "value": "{tableValues.racAmmCoGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_5",
          "apiName": "",
          "value": "{tableValues.racAmmCoVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_6",
          "apiName": "",
          "value": "{tableValues.racAmmTotGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
			  }
          ]
        },
        {
          "key": "td_7",
          "apiName": "",
          "value": "{tableValues.racAmmTotVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        }
      ]
    },
	{
      "tag": "tr",
      "key": "tr_5",
      "class": "accordion_tr_1 slds-hide",
      "style": "background-color: #efefef",
      "tdElements": [
        {
          "key": "td_1",
          "apiName": "",
          "value": "Raccolta Gestita",
          "formatted": {
            "type": "text"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "first-column-definition",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_2",
          "apiName": "CRM_RaccoltaGestita_t_1__c",
          "value": "",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_3",
          "apiName": "CRM_VariazRaccGestita_t_1VSFineAP__c",
          "value": "",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_4",
          "apiName": "",
          "value": "{tableValues.racGestitaCoGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_5",
          "apiName": "",
          "value": "{tableValues.racGestitaCoVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_6",
          "apiName": "",
          "value": "{tableValues.racGestitaTotGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
			   }
          ]
        },
        {
          "key": "td_7",
          "apiName": "",
          "value": "{tableValues.racGestitaTotVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        }
      ]
    },
	{
      "tag": "tr",
      "key": "tr_6",
      "class": "accordion_tr_1 slds-hide",
      "style": "background-color: white",
      "tdElements": [
        {
          "key": "td_1",
          "apiName": "",
          "value": "Polizza Vita",
          "formatted": {
            "type": "text"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "first-column-definition",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_2",
          "apiName": "CRM_PolizzeVita_t_1__c",
          "value": "",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_3",
          "apiName": "CRM_VariazPolVita_t_1VSFineAP__c",
          "value": "",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_4",
          "apiName": "",
          "value": "{tableValues.polizzaCoGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_5",
          "apiName": "",
          "value": "{tableValues.polizzaCoVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_6",
          "apiName": "",
          "value": "{tableValues.polizzaTotGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
			   }
          ]
        },
        {
          "key": "td_7",
          "apiName": "",
          "value": "{tableValues.polizzaTotVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        }
      ]
    },
	{
      "tag": "tr",
      "key": "tr_7",
      "class": "slds-hint-parent accordion",
      "style": "",
      "tdElements": [
        {
          "key": "td_1",
          "apiName": "",
          "value": "IMPIEGHI",
          "formatted": {
            "type": "text"
          },
          "class": "slds-is-relative",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "first-column-definition",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_2",
          "apiName": "CRM_Impieghi_t_1__c",
          "value": "",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_3",
          "apiName": "CRM_VarImpieghi_t_1VsFinAP__c",
          "value": "",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_4",
          "apiName": "",
          "value": "{tableValues.ImpieghiCoGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_5",
          "apiName": "",
          "value": "{tableValues.ImpieghiCoVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        },
        {
          "key": "td_6",
          "apiName": "",
          "value": "{tableValues.ImpieghiTotGiorno}",
          "formatted": {
            "type": "number",
            "style": "currency"
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
			  }
          ]
        },
        {
          "key": "td_7",
          "apiName": "",
          "value": "{tableValues.ImpieghiTotVariazione}",
          "formatted": {
            "type": "text",
            "style": ""
          },
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center",
              "style": "",
              "buttonAccordion": false
            }
          ]
        }
      ]
    }
	
  ]
}