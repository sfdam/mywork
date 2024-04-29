{
  "thead": [
    {
      "tag": "tr",
      "key": "tr_1",
	  "class": "header-title",
      "thElements": [
        {
          "key": "th_1",
		  "apiName": "CRM_DataTabelle__c",
          "rowspan": "1",
          "colspan": "1",
          "class": "",
          "style": "background-color: white;font-size:12px",
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
          "colspan": "1",
          "class": "",
          "style": "",
          "divElements": [
            {
              "key": "div_1",
              "class": "slds-align_absolute-center slds-p-left_x-small slds-p-right_x-small test-two",
              "style": "",
              "value": "Mese Corrente"
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
              "key": "div_1",
              "class": "slds-align_absolute-center slds-p-left_x-small slds-p-right_x-small test-two",
              "style": "",
              "value": "Stesso Mese Anno Precedente"
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
              "value": "Variaz %"
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
              "value": "Fine Anno Precedente"
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
              "value": "Variaz %"
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
          "value": "MARGINE DI INTERMEDIAZIONE",
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
              "buttonAccordion": true,
			  "helpText": true,
			  "helpTextContent": "I dati fanno riferimento alla fine del mese precedente"
            }
          ]
        },
        {
          "key": "td_2",
          "apiName": "CRM_MargineIntermediazioneMeseCorrente__c",
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
          "apiName": "CRM_MargineIntermediazioneStessoMeseAP__c",
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
          "key": "td_4",
          "apiName": "CRM_VarMargineIntermVSSmAP__c",
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
          "key": "td_5",
          "apiName": "CRM_MargineIntermediazioneFineAP__c",
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
          "key": "td_6",
          "apiName": "CRM_VarMargServiziVSFinAP__c",
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
        }
      ]
    },
    {
      "tag": "tr",
      "key": "tr_2",
      "class": "accordion_tr_1 slds-hide",
      "style": "",
      "tdElements": [
        {
          "key": "td_1",
          "value": "Margine Finanziario",
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
          "apiName": "CRM_MargineFinanziarioMeseCorrente__c",
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
          "apiName": "CRM_MargineFinanziarioStessoMeseAP__c",
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
          "key": "td_4",
          "apiName": "CRM_MargFinVarSMAP__c",
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
          "key": "td_5",
          "apiName": "CRM_MargineFinanziarioFineAP__c",
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
          "key": "td_6",
          "apiName": "CRM_MargFinVarFineAP__c",
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
        }
      ]
    },
    {
      "tag": "tr",
      "key": "tr_3",
      "class": "accordion_tr_1 slds-hide",
      "style": "",
      "tdElements": [
        {
          "key": "td_1",
          "apiName": "",
          "value": "Margine da Servizi",
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
          "apiName": "CRM_MargineServiziMeseCorrente__c",
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
          "apiName": "CRM_MargineServiziStessoMeseAP__c",
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
          "key": "td_4",
          "apiName": "CRM_VarMargServVSsmAP__c",
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
          "key": "td_5",
          "apiName": "CRM_MargineServiziFineAP__c",
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
          "key": "td_6",
          "apiName": "CRM_VarMargServVsFinAP__c",
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
        }
      ]
    },
    {
      "tag": "tr",
      "key": "tr_4",
      "class": "accordion_tr_1 slds-hide",
      "style": "",
      "tdElements": [
        {
          "key": "td_1",
          "apiName": "",
          "value": "Margine Estero",
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
          "apiName": "CRM_MargEstMeseCorr__c",
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
          "apiName": "CRM_MargEstFineMP__c",
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
          "key": "td_4",
          "apiName": "CRM_MargEstVarSMAP__c",
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
          "key": "td_5",
          "apiName": "CRM_MargEstFineAP__c",
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
          "key": "td_6",
          "apiName": "CRM_MargEstVarFineAP__c",
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
        }
      ]
    },
    {
      "tag": "tr",
      "key": "tr_5",
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
          "apiName": "CRM_RaccoltaComplessivaMeseCorrente__c",
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
          "apiName": "CRM_RaccoltaComplessivaStessoMeseAP__c",
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
          "key": "td_4",
          "apiName": "CRM_VarRaccComplVSsmAP__c",
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
          "key": "td_5",
          "apiName": "CRM_RaccoltaComplessivaFineAnnoPrec__c",
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
          "key": "td_6",
          "apiName": "CRM_VarRaccComplVsFinAP__c",
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
        }
      ]
    },
    {
      "tag": "tr",
      "key": "tr_6",
      "class": "accordion_tr_5 slds-hide",
      "style": "",
      "tdElements": [
        {
          "key": "td_1",
          "apiName": "",
          "value": "Liquidità-SML",
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
          "apiName": "CRM_LiquiditaMeseCorrente__c",
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
          "apiName": "CRM_LiquiditaStessoMeseAP__c",
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
          "key": "td_4",
          "apiName": "CRM_VarLiquiditaMeseCorrenteVsmAP__c",
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
          "key": "td_5",
          "apiName": "CRM_LiquiditaFineAnnoPrecedente__c",
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
          "key": "td_6",
          "apiName": "CRM_VarLiquiditaVSFinAP__c",
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
        }
      ]
    },
    {
      "tag": "tr",
      "key": "tr_7",
      "class": "accordion_tr_5 slds-hide",
      "style": "",
      "tdElements": [
        {
          "key": "td_1",
          "apiName": "",
          "value": "Raccolta Diretta-SML",
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
          "apiName": "CRM_RaccoltaDirettaMeseCorrente__c",
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
          "apiName": "CRM_RaccoltaDirettaStessoMeseAP__c",
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
          "key": "td_4",
          "apiName": "CRM_RaccDirettaVarSMAP__c",
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
          "key": "td_5",
          "apiName": "CRM_RaccoltaDirettaFineAP__c",
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
          "key": "td_6",
          "apiName": "CRM_RaccDirettaVarFineAP__c",
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
        }
      ]
    },
    {
      "tag": "tr",
      "key": "tr_8",
      "class": "accordion_tr_5 slds-hide",
      "style": "",
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
          "apiName": "CRM_RaccoltaAmministrataMeseCorrente__c",
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
          "apiName": "CRM_RaccoltaAmministrataStessoMeseAP__c",
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
          "key": "td_4",
          "apiName": "CRM_RaccAmminVarSMAP__c",
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
          "key": "td_5",
          "apiName": "CRM_RaccoltaAmministrataFineAP__c",
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
          "key": "td_6",
          "apiName": "CRM_RaccAmminVarFineAP__c",
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
        }
      ]
    },
	{
      "tag": "tr",
      "key": "tr_9",
      "class": "accordion_tr_5 slds-hide",
      "style": "",
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
          "apiName": "CRM_RaccGestMeseCorrente__c",
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
          "apiName": "CRM_RaccGestStessoMeseAP__c",
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
          "key": "td_4",
          "apiName": "CRM_RaccGestVarSMAP__c",
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
          "key": "td_5",
          "apiName": "CRM_RaccGestFineAP__c",
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
          "key": "td_6",
          "apiName": "CRM_RaccGestVarFineAP__c",
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
        }
      ]
    },
	{
      "tag": "tr",
      "key": "tr_10",
      "class": "slds-hint-parent accordion",
      "style": "",
      "tdElements": [
        {
          "key": "td_1",
          "apiName": "",
          "value": "IMPIEGHI-SML",
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
          "apiName": "CRM_ImpieghiMeseCorrente__c",
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
          "apiName": "CRM_ImpieghiStessoMeseAP__c",
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
          "key": "td_4",
          "apiName": "CRM_VarImpieghiVsSmAP__c",
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
          "key": "td_5",
          "apiName": "CRM_ImpieghiFineAP__c",
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
          "key": "td_6",
          "apiName": "CRM_VarImpieghiVsFinAP__c",
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
        }
      ]
    }
	
  ]
}