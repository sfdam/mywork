import { LightningElement,api, track, wire } from 'lwc';
import getLinee from '@salesforce/apex/CIB_SintesiSimulazioneController.getLinee';

// AL 2024-02-28 -- Aggiunta delle label
import piu30bps from '@salesforce/label/c.piu30bps';
import piu20bps from '@salesforce/label/c.piu20bps';
import piu10bps from '@salesforce/label/c.piu10bps';
import piu0bps from '@salesforce/label/c.piu0bps';
import meno10bps from '@salesforce/label/c.meno10bps';
import meno20bps from '@salesforce/label/c.meno20bps';
import meno30bps from '@salesforce/label/c.meno30bps';
import line_n_header from '@salesforce/label/c.line_n_header';
// AL 2024-02-28 -- Fine
// AL 2024-03-11 --Aggiunta delle label
import line_n_header_Sens from '@salesforce/label/c.line_n_header_Sens';
import RARORAC_header1 from '@salesforce/label/c.RARORAC_header1';
import RARORAC_header2 from '@salesforce/label/c.RARORAC_header2';
import RARORAC_header3 from '@salesforce/label/c.RARORAC_header3';
import RACE_header1 from '@salesforce/label/c.RACE_header1';
import RACE_header2 from '@salesforce/label/c.RACE_header2';
import RACE_header3 from '@salesforce/label/c.RACE_header3';
import Sintesi_singolaLinea_Header from '@salesforce/label/c.Sintesi_singolaLinea_Header';
import Sintesi_totali_Header from '@salesforce/label/c.Sintesi_totali_Header';
import TOTALE_headres from '@salesforce/label/c.TOTALE_headres';
import SviluppoAnno1_Header from '@salesforce/label/c.SviluppoAnno1_Header'; 
import Sintesi_singolaLinea_linea_1 from '@salesforce/label/c.Sintesi_singolaLinea_linea_1';
import Sintesi_singolaLinea_linea_2 from '@salesforce/label/c.Sintesi_singolaLinea_linea_2';
import Sintesi_singolaLinea_linea_3 from '@salesforce/label/c.Sintesi_singolaLinea_linea_3';
import Sintesi_singolaLinea_linea_4 from '@salesforce/label/c.Sintesi_singolaLinea_linea_4';
import Sintesi_singolaLinea_linea_5 from '@salesforce/label/c.Sintesi_singolaLinea_linea_5';
import Sintesi_singolaLinea_linea_6 from '@salesforce/label/c.Sintesi_singolaLinea_linea_6';
import Sintesi_singolaLinea_linea_7 from '@salesforce/label/c.Sintesi_singolaLinea_linea_7';
import Sintesi_singolaLinea_linea_8 from '@salesforce/label/c.Sintesi_singolaLinea_linea_8';
import Sintesi_singolaLinea_linea_9 from '@salesforce/label/c.Sintesi_singolaLinea_linea_9';
import Sintesi_singolaLinea_linea_10 from '@salesforce/label/c.Sintesi_singolaLinea_linea_10';
import Sintesi_singolaLinea_linea_11 from '@salesforce/label/c.Sintesi_singolaLinea_linea_11';
import Sintesi_singolaLinea_linea_12 from '@salesforce/label/c.Sintesi_singolaLinea_linea_12';
import Sintesi_singolaLinea_linea_13 from '@salesforce/label/c.Sintesi_singolaLinea_linea_13';
import Sintesi_singolaLinea_linea_14 from '@salesforce/label/c.Sintesi_singolaLinea_linea_14';
import Sintesi_singolaLinea_linea_15 from '@salesforce/label/c.Sintesi_singolaLinea_linea_15';
import Sintesi_singolaLinea_linea_16 from '@salesforce/label/c.Sintesi_singolaLinea_linea_16';
import Sintesi_singolaLinea_linea_17 from '@salesforce/label/c.Sintesi_singolaLinea_linea_17';
import Sintesi_singolaLinea_linea_18 from '@salesforce/label/c.Sintesi_singolaLinea_linea_18';
import Sintesi_singolaLinea_linea_19 from '@salesforce/label/c.Sintesi_singolaLinea_linea_19';
import Sintesi_singolaLinea_linea_20 from '@salesforce/label/c.Sintesi_singolaLinea_linea_20';
import Sintesi_singolaLinea_linea_21 from '@salesforce/label/c.Sintesi_singolaLinea_linea_21';
import Sintesi_singolaLinea_linea_22 from '@salesforce/label/c.Sintesi_singolaLinea_linea_22';
import Sintesi_singolaLinea_linea_23 from '@salesforce/label/c.Sintesi_singolaLinea_linea_23';
import Sintesi_singolaLinea_linea_24 from '@salesforce/label/c.Sintesi_singolaLinea_linea_24';
import Sintesi_singolaLinea_linea_25 from '@salesforce/label/c.Sintesi_singolaLinea_linea_25';
import Sintesi_singolaLinea_linea_26 from '@salesforce/label/c.Sintesi_singolaLinea_linea_26';
import Sintesi_singolaLinea_linea_27 from '@salesforce/label/c.Sintesi_singolaLinea_linea_27';
import Sintesi_singolaLinea_linea_28 from '@salesforce/label/c.Sintesi_singolaLinea_linea_28';
import Sintesi_singolaLinea_linea_29 from '@salesforce/label/c.Sintesi_singolaLinea_linea_29';
import Sintesi_singolaLinea_linea_30 from '@salesforce/label/c.Sintesi_singolaLinea_linea_30';
import Sintesi_singolaLinea_linea_31 from '@salesforce/label/c.Sintesi_singolaLinea_linea_31';
import Sintesi_singolaLinea_linea_32 from '@salesforce/label/c.Sintesi_singolaLinea_linea_32';
import Sintesi_singolaLinea_linea_33 from '@salesforce/label/c.Sintesi_singolaLinea_linea_33';
import Sintesi_singolaLinea_linea_34 from '@salesforce/label/c.Sintesi_singolaLinea_linea_34';
import Sintesi_singolaLinea_linea_35 from '@salesforce/label/c.Sintesi_singolaLinea_linea_35';
import Sintesi_singolaLinea_linea_36 from '@salesforce/label/c.Sintesi_singolaLinea_linea_36';
import Sintesi_singolaLinea_linea_37 from '@salesforce/label/c.Sintesi_singolaLinea_linea_37';
import Sintesi_singolaLinea_linea_38 from '@salesforce/label/c.Sintesi_singolaLinea_linea_38';
import Sintesi_totali_linea_1 from '@salesforce/label/c.Sintesi_totali_linea_1';
import Sintesi_totali_linea_2 from '@salesforce/label/c.Sintesi_totali_linea_2';
import Sintesi_totali_linea_3 from '@salesforce/label/c.Sintesi_totali_linea_3';
import Sintesi_totali_linea_4 from '@salesforce/label/c.Sintesi_totali_linea_4';
import Sintesi_totali_linea_5 from '@salesforce/label/c.Sintesi_totali_linea_5';
import Sintesi_totali_linea_6 from '@salesforce/label/c.Sintesi_totali_linea_6';
import Sintesi_totali_linea_7 from '@salesforce/label/c.Sintesi_totali_linea_7';
import Sintesi_totali_linea_8 from '@salesforce/label/c.Sintesi_totali_linea_8';
import Sintesi_totali_linea_9 from '@salesforce/label/c.Sintesi_totali_linea_9';
import Sintesi_totali_linea_10 from '@salesforce/label/c.Sintesi_totali_linea_10';
import Sintesi_totali_linea_11 from '@salesforce/label/c.Sintesi_totali_linea_11';
import Sintesi_totali_linea_12 from '@salesforce/label/c.Sintesi_totali_linea_12';
import Sintesi_totali_linea_13 from '@salesforce/label/c.Sintesi_totali_linea_13';
import Sintesi_totali_linea_14 from '@salesforce/label/c.Sintesi_totali_linea_14';
import Sintesi_totali_linea_15 from '@salesforce/label/c.Sintesi_totali_linea_15';
import Sintesi_totali_linea_16 from '@salesforce/label/c.Sintesi_totali_linea_16';
import Sintesi_totali_linea_17 from '@salesforce/label/c.Sintesi_totali_linea_17';
import Sintesi_totali_linea_18 from '@salesforce/label/c.Sintesi_totali_linea_18';
import Sintesi_totali_linea_19 from '@salesforce/label/c.Sintesi_totali_linea_19';
import Sintesi_totali_linea_20 from '@salesforce/label/c.Sintesi_totali_linea_20';
import Sintesi_totali_linea_21 from '@salesforce/label/c.Sintesi_totali_linea_21';
import Sintesi_totali_linea_22 from '@salesforce/label/c.Sintesi_totali_linea_22';
import Sintesi_totali_linea_23 from '@salesforce/label/c.Sintesi_totali_linea_23';
import Sintesi_totali_linea_24 from '@salesforce/label/c.Sintesi_totali_linea_24';
import Sintesi_totali_linea_25 from '@salesforce/label/c.Sintesi_totali_linea_25';
import SviluppoAnno1_linea1 from '@salesforce/label/c.SviluppoAnno1_linea1';
import SviluppoAnno1_linea_2 from '@salesforce/label/c.SviluppoAnno1_linea_2';
import SviluppoAnno1_linea_3 from '@salesforce/label/c.SviluppoAnno1_linea_3';
import SviluppoAnno1_linea_4 from '@salesforce/label/c.SviluppoAnno1_linea_4';
import SviluppoAnno1_linea_5 from '@salesforce/label/c.SviluppoAnno1_linea_5';
import SviluppoAnno1_linea_6 from '@salesforce/label/c.SviluppoAnno1_linea_6';
import SviluppoAnno1_linea_7 from '@salesforce/label/c.SviluppoAnno1_linea_7';
import SviluppoAnno1_linea_8 from '@salesforce/label/c.SviluppoAnno1_linea_8';
import SviluppoAnno1_linea_9 from '@salesforce/label/c.SviluppoAnno1_linea_9';
import SviluppoAnno1_linea_10 from '@salesforce/label/c.SviluppoAnno1_linea_10';
import SviluppoAnno1_linea_11 from '@salesforce/label/c.SviluppoAnno1_linea_11';
import SviluppoAnno1_linea_12 from '@salesforce/label/c.SviluppoAnno1_linea_12';
import SviluppoAnno1_linea_13 from '@salesforce/label/c.SviluppoAnno1_linea_13';
import SviluppoAnno1_linea_14 from '@salesforce/label/c.SviluppoAnno1_linea_14';
import SviluppoAnno1_linea_15 from '@salesforce/label/c.SviluppoAnno1_linea_15';
import SviluppoAnno1_linea_16 from '@salesforce/label/c.SviluppoAnno1_linea_16';
import SviluppoAnno1_linea_17 from '@salesforce/label/c.SviluppoAnno1_linea_17';
import SviluppoAnno1_linea_18 from '@salesforce/label/c.SviluppoAnno1_linea_18';
import SviluppoAnno1_linea_19 from '@salesforce/label/c.SviluppoAnno1_linea_19';
import SviluppoAnno1_linea_20 from '@salesforce/label/c.SviluppoAnno1_linea_20';
import SviluppoAnno1_linea_21 from '@salesforce/label/c.SviluppoAnno1_linea_21';
import SviluppoAnno1_linea_22 from '@salesforce/label/c.SviluppoAnno1_linea_22';
import SviluppoAnno1_linea_23 from '@salesforce/label/c.SviluppoAnno1_linea_23';
// AL 2024-03-11 -- Fine
//AD inizio
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import linea_OBJECT from "@salesforce/schema/Linea__c";  
//AD fine

export default class CibAccordionSintesiSimulazione extends LightningElement {
    @api recordId;
    @api titleCard;
    @api tableType;
    @api objectApiName;

    @track records= [];
    @track mapping = [];
    @track tbl_columns_size = {
        1:"slds-size_1-of-12",
        2:"slds-size_6-of-12",
        3:"slds-size_4-of-12",
        4:"slds-size_3-of-12",
        6:"slds-size_2-of-12"
    };
    @track columns_size_class = "";

    @track mappingBySections = {
        RARORAC:[
            {
                // AL 2024-03-11 -- Use delle label per le label
                //header:"Sensitivity Margine",
                header:RARORAC_header1,
                // AL 2024-03-11 -- Fine 
                table: {
                    // AL 2024-02-28 -- Use delle label per le label
                    //headers:["LINEA 1","LINEA 2","LINEA 3","LINEA 4","LINEA 5"],
                    headers:[line_n_header_Sens.replace('n','1'),
                    line_n_header_Sens.replace('n','2'),
                    line_n_header_Sens.replace('n','3'),
                    line_n_header_Sens.replace('n','4'),
                    line_n_header_Sens.replace('n','5')],
                    // AL 2024-02-28 -- Fine
                    rows:[ // AL 2024-02-28 -- Utilizzo delle label 
                        {label:piu30bps,fieldName:"SensitivityMargineRARORACPiu30__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu20bps,fieldName:"SensitivityMargineRARORACPiu20__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu10bps,fieldName:"SensitivityMargineRARORACPiu10__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu0bps,fieldName:"Present_RARORAC__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno10bps,fieldName:"SensitivityMargineRARORACMeno10__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno20bps,fieldName:"SensitivityMargineRARORACMeno20__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno30bps,fieldName:"SensitivityMargineRARORACMeno30__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""}
                    ]
                }
            },
            {
                // AL 2024-03-11 -- Use delle label per le label
                //header:"Sensitivity CMU",
                header:RARORAC_header2,
                // AL 2024-03-11 -- Fine
                table: {
                    // AL 2024-02-28 -- Use delle label per le label
                    //headers:["LINEA 1","LINEA 2","LINEA 3","LINEA 4","LINEA 5"],
                    headers:[line_n_header_Sens.replace('n','1'),
                    line_n_header_Sens.replace('n','2'),
                    line_n_header_Sens.replace('n','3'),
                    line_n_header_Sens.replace('n','4'),
                    line_n_header_Sens.replace('n','5')],
                    // AL 2024-02-28 -- Fine
                    rows:[ // AL 2024-02-28 -- Utilizzo delle label 
                        {label:piu30bps,fieldName:"SensitivityCMURARORACPiu30__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu20bps,fieldName:"SensitivityCMURARORACPiu20__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu10bps,fieldName:"SensitivityCMURARORACPiu10__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu0bps,fieldName:"Present_RARORAC__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno10bps,fieldName:"SensitivityCMURARORACMeno10__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno20bps,fieldName:"SensitivityCMURARORACMeno20__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno30bps,fieldName:"SensitivityCMURARORACMeno30__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""}
                    ]
                }
            },
            {
                // AL 2024-03-11 -- Use delle label per le label
                header:"Sensitivity UP-Front",
                header:RARORAC_header3,
                // AL 2024-03-11 -- Fine
                table: {
                    // AL 2024-02-28 -- Use delle label per le label
                    //headers:["LINEA 1","LINEA 2","LINEA 3","LINEA 4","LINEA 5"],
                    headers:[line_n_header_Sens.replace('n','1'),
                    line_n_header_Sens.replace('n','2'),
                    line_n_header_Sens.replace('n','3'),
                    line_n_header_Sens.replace('n','4'),
                    line_n_header_Sens.replace('n','5')],
                    // AL 2024-02-28 -- Fine
                    rows:[ // AL 2024-02-28 -- Utilizzo delle label 
                        {label:piu30bps,fieldName:"SensitivityUPfrontRARORACPiu30__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu20bps,fieldName:"SensitivityUPfrontRARORACPiu20__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu10bps,fieldName:"SensitivityUPfrontRARORACPiu10__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu0bps,fieldName:"Present_RARORAC__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno10bps,fieldName:"SensitivityUPfrontRARORACMeno10__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno20bps,fieldName:"SensitivityUPfrontRARORACMeno20__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno30bps,fieldName:"SensitivityUPfrontRARORACMeno30__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""}
                    ]
                }
            }
        ],
        RACE:[
            {
                // AL 2024-03-11 -- Use delle label per le label
                //header:"Sensitivity Margine",
                header:RACE_header1,
                // AL 2024-03-11 -- Fine 
                table: {
                    // AL 2024-02-28 -- Use delle label per le label
                    //headers:["LINEA 1","LINEA 2","LINEA 3","LINEA 4","LINEA 5"],
                    headers:[line_n_header_Sens.replace('n','1'),
                        line_n_header_Sens.replace('n','2'),
                        line_n_header_Sens.replace('n','3'),
                        line_n_header_Sens.replace('n','4'),
                        line_n_header_Sens.replace('n','5')],
                    // AL 2024-02-28 -- Fine
                    rows:[ // AL 2024-02-28 -- Utilizzo delle label 
                        {label:piu30bps,fieldName:"SensitivityMargineRACEPiu30__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu20bps,fieldName:"SensitivityMargineRACEPiu20__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu10bps,fieldName:"SensitivityMargineRACEPiu10__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu0bps,fieldName:"Present_RACE__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno10bps,fieldName:"SensitivityMargineRACEMeno10__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno20bps,fieldName:"SensitivityMargineRACEMeno20__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno30bps,fieldName:"SensitivityMargineRACEMeno30__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""}
                    ]
                }
            },
            {
                // AL 2024-03-11 -- Use delle label per le label
                //header:"Sensitivity CMU",
                header:RACE_header2,
                // AL 2024-03-11 -- Fine
                table: {
                    // AL 2024-02-28 -- Use delle label per le label
                    //headers:["LINEA 1","LINEA 2","LINEA 3","LINEA 4","LINEA 5"],
                    headers:[line_n_header_Sens.replace('n','1'),
                    line_n_header_Sens.replace('n','2'),
                    line_n_header_Sens.replace('n','3'),
                    line_n_header_Sens.replace('n','4'),
                    line_n_header_Sens.replace('n','5')],
                    // AL 2024-02-28 -- Fine
                    rows:[ // AL 2024-02-28 -- Utilizzo delle label 
                        {label:piu30bps,fieldName:"SensitivityCMURACEPiu30__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu20bps,fieldName:"SensitivityCMURACEPiu20__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu10bps,fieldName:"SensitivityCMURACEPiu10__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu0bps,fieldName:"Present_RACE__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno10bps,fieldName:"SensitivityCMURACEMeno10__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno20bps,fieldName:"SensitivityCMURACEMeno20__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno30bps,fieldName:"SensitivityCMURACEMeno30__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""}
                    ]
                }
            },
            {
                // AL 2024-03-11 -- Use delle label per le label
                //header:"Sensitivity UP-Front",
                header:RACE_header3,
                // AL 2024-03-11 -- Fine
                table: {
                    // AL 2024-02-28 -- Use delle label per le label
                    //headers:["LINEA 1","LINEA 2","LINEA 3","LINEA 4","LINEA 5"],
                    headers:[line_n_header_Sens.replace('n','1'),
                        line_n_header_Sens.replace('n','2'),
                        line_n_header_Sens.replace('n','3'),
                        line_n_header_Sens.replace('n','4'),
                        line_n_header_Sens.replace('n','5')],
                    // AL 2024-02-28 -- Fine
                    rows:[ // AL 2024-02-28 -- Utilizzo delle label 
                        {label:piu30bps,fieldName:"SensitivityUpFrontRACEPiu30__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu20bps,fieldName:"SensitivityUpFrontRACEPiu20__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu10bps,fieldName:"SensitivityUpFrontRACEPiu10__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:piu0bps,fieldName:"Present_RACE__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno10bps,fieldName:"SensitivityUpFrontRACEMeno10__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno20bps,fieldName:"SensitivityUpFrontRACEMeno20__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},
                        {label:meno30bps,fieldName:"SensitivityUpFrontRACEMeno30__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""}
                    ]
                }
            }
        ],
        Sintesi_singolaLinea:[
            {
                // AL 2024-03-11 -- Use delle label per le label
                //header:"Sintesi",
                header:Sintesi_singolaLinea_Header,
                table: {
                    //headers:["LINEA 1","LINEA 2","LINEA 3","LINEA 4","LINEA 5"],
                    headers:[line_n_header.replace('n','1'),
                    line_n_header.replace('n','2'),
                    line_n_header.replace('n','3'),
                    line_n_header.replace('n','4'),
                    line_n_header.replace('n','5')],
                    // AL 2024-03-11 -- Fine
                    rows:[
                        {label:Sintesi_singolaLinea_linea_1,fieldName:"Formatecnica__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0 
                        {label:Sintesi_singolaLinea_linea_2,fieldName:"Tipo_di_ammortamento__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_3,fieldName:"Importo__c",fieldNameTotale:"",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_4,fieldName:"Tipo_funding__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_5,fieldName:"Valuta__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_6,fieldName:"Utilizzo__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0 // AL 2024-02-28 -- Sostituzione del campi in Utilizzo__c
                        {label:Sintesi_singolaLinea_linea_7,fieldName:"Durata__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_8,fieldName:"Duration_finanziaria_in_anni__c",fieldNameTotale:"",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_9,fieldName:"Periodicita_rata__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_10,fieldName:"PresenzaPreammortamento__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0  // AL 2024-02-28 -- Sostituzione del campi in PresenzaPreammortamento__c
                        {label:Sintesi_singolaLinea_linea_11,fieldName:"Periodi_di_preammortamento__c",fieldNameTotale:"",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_12,fieldName:"baloonFinalePercentuale__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_13,fieldName:"SAL__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_14,fieldName:"Numero_periodi_di_erogazione__c",fieldNameTotale:"",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_15,fieldName:"Tipo_tasso__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_16,fieldName:"Indicizzazionetassovariabile__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_17,fieldName:"Spread_TassoFisso_Commdifirma__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_18,fieldName:"Condizione_di_BE__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_19,fieldName:"Capvalore__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_20,fieldName:"Floorvalore__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_21,fieldName:"Intereststep__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_22,fieldName:"TIT_base_di_partenza__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_23,fieldName:"Up_Front_perc__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_24,fieldName:"Up_Front__c",fieldNameTotale:"",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_25,fieldName:"CMUannuale__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_26,fieldName:"Commissione_running_annuale_perc__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_27,fieldName:"Commissione_running_annuale__c",fieldNameTotale:"",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_28,fieldName:"Altro_es_derivato_perc__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_29,fieldName:"Altroesderivato__c",fieldNameTotale:"",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_30,fieldName:"Garanzia__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_31,fieldName:"Tipo_garanzia__c",fieldNameTotale:"",is_number:false,is_text:true,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_32,fieldName:"Valore_del_bene_ipotecato__c",fieldNameTotale:"",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_33,fieldName:"Valore_del_pegno_SACE__c",fieldNameTotale:"",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_34,fieldName:"Valore_del_PegnoSACE_Perc__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_35,fieldName:"commissioneDiFirma__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_36,fieldName:"commissioniUpFrontBpsMediLongLife__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_37,fieldName:"commissioniRunningBpsMediLongLife__c",fieldNameTotale:"",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_singolaLinea_linea_38,fieldName:"commissioniAddOnEuroLongLife__c",fieldNameTotale:"",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                    ]
                }
            }
        ],
        Sintesi_totali:[
            {
                // AL 2024-03-11 -- Use delle label per le label
                //header:"Sintesi",
                header:Sintesi_totali_Header,
                table: {
                    ///headers:["TOTALE","LINEA 1","LINEA 2","LINEA 3","LINEA 4","LINEA 5"],
                    headers:[TOTALE_headres,line_n_header.replace('n','1'),
                    line_n_header.replace('n','2'),
                    line_n_header.replace('n','3'),
                    line_n_header.replace('n','4'),
                    line_n_header.replace('n','5')],
                    // AL 2024-03-11 -- Fine
                    rows:[
                        {label:Sintesi_totali_linea_1,fieldName:"Interessi_attivi__c",fieldNameTotale:"Simulazione__r.Interessi_attivi_totali__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_2,fieldName:"Costo_del_funding__c",fieldNameTotale:"Simulazione__r.Costo_del_funding_totale__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_3,fieldName:"Margine_di_interesse__c",fieldNameTotale:"Simulazione__r.Margine_di_interesse_totale__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_4,fieldName:"Commissioni_up_front__c",fieldNameTotale:"Simulazione__r.Commissioni_Up_Front_Totale__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_5,fieldName:"Commissioni_running__c",fieldNameTotale:"Simulazione__r.Commissioni_Running_Totale__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_6,fieldName:"Commissioni_altro__c",fieldNameTotale:"Simulazione__r.Commissioni_Altro_Totale__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_7,fieldName:"Commissioni_Totali__c",fieldNameTotale:"Simulazione__r.Commissioni_Totali__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_8,fieldName:"Margine_di_intermediazione__c",fieldNameTotale:"Simulazione__r.Margine_di_intermediazione_Totale__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_9,fieldName:"Costo_del_rischio_lordo__c",fieldNameTotale:"Simulazione__r.Costo_del_Rischio_Lordo_Totale__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_10,fieldName:"Costo_del_capitale__c",fieldNameTotale:"Simulazione__r.Costo_del_capitale_totale__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_11,fieldName:"Costi_operativi__c",fieldNameTotale:"Simulazione__r.Costi_operativi_totali__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_12,fieldName:"Margine_operativo_netto__c",fieldNameTotale:"Simulazione__r.Margine_operativo_netto_totale__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_13,fieldName:"SML_annuo_medio__c",fieldNameTotale:"Simulazione__r.SML_annuo_medio_totale__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_14,fieldName:"EAD_annua_media__c",fieldNameTotale:"Simulazione__r.EAD_annua_media_totale__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_15,fieldName:"RWA_rischio_di_credito_annui_medi__c",fieldNameTotale:"Simulazione__r.rwa_Rischio_Di_Credito_Annuo_Medio__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_16,fieldName:"RWA_rischio_operativo_annui_medi__c",fieldNameTotale:"Simulazione__r.RWA_rischio_operativo_annui_medio__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_17,fieldName:"RWA_totali_annui_medi__c",fieldNameTotale:"Simulazione__r.RWA_totali_annui_medi_totale__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_18,fieldName:"Capitale_assorbito_medio__c",fieldNameTotale:"Simulazione__r.capitaleAssorbitoMedio__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_19,fieldName:"RWA_totali_annui_max__c",fieldNameTotale:"Simulazione__r.RWA_totali_annui_max__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_20,fieldName:"Capitale_assorbito_max__c",fieldNameTotale:"Simulazione__r.Capitale_assorbito_max__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_21,fieldName:"RWA_Medio__c",fieldNameTotale:"Simulazione__r.RWA_Medio_perc__c",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_22,fieldName:"Present_NOPAT__c",fieldNameTotale:"Simulazione__r.Present_NOPAT__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_23,fieldName:"Present_EVA__c",fieldNameTotale:"Simulazione__r.Present_EVA__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_24,fieldName:"Present_RACE__c",fieldNameTotale:"Simulazione__r.Present_RACE__c",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:Sintesi_totali_linea_25,fieldName:"Present_RARORAC__c",fieldNameTotale:"Simulazione__r.Present_RARORAC__c",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"}// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                    ]
                }
            }
        ],
        SviluppoAnno1:[
            {
                // AL 2024-03-11 -- Use delle label per le label
                //header:"Sviluppo Anno 1",
                header:SviluppoAnno1_Header,
                table: {
                    //headers:["TOTALE","LINEA 1","LINEA 2","LINEA 3","LINEA 4","LINEA 5"],
                    headers:[TOTALE_headres,line_n_header.replace('n','1'),
                    line_n_header.replace('n','2'),
                    line_n_header.replace('n','3'),
                    line_n_header.replace('n','4'),
                    line_n_header.replace('n','5')],
                    // AL 2024-03-11 -- Fine
                    rows:[
                        {label:SviluppoAnno1_linea1,fieldName:"Interessi_attivi_1anno__c",fieldNameTotale:"Simulazione__r.Interessi_attivi1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_2,fieldName:"Costo_del_funding_1anno__c",fieldNameTotale:"Simulazione__r.Costo_del_funding1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_3,fieldName:"Margine_di_interesse_1anno__c",fieldNameTotale:"Simulazione__r.Margine_di_interesse1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_4,fieldName:"Commissioni_up_front_1anno__c",fieldNameTotale:"Simulazione__r.Commissioni_up_front1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_5,fieldName:"Commissioni_running_1anno__c",fieldNameTotale:"Simulazione__r.Commissioni_running1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_6,fieldName:"Commissioni_altro_1anno__c",fieldNameTotale:"Simulazione__r.Commissioni_altro1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_7,fieldName:"CommissioniTotali1anno__c",fieldNameTotale:"Simulazione__r.Commissioni1__c",is_number:true,is_text:false,is_boolean:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0 // AL 2024-02-28 -- Sostituzione del campi in CommissioniTotali1anno__c
                        {label:SviluppoAnno1_linea_8,fieldName:"Margine_di_intermediazione_1anno__c",fieldNameTotale:"Simulazione__r.Margine_di_intermediazione1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_9,fieldName:"Costo_del_rischio_lordo_1anno__c",fieldNameTotale:"Simulazione__r.Costo_del_rischio_lordo1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_10,fieldName:"Costo_del_capitale_1anno__c",fieldNameTotale:"Simulazione__r.Costo_del_capitale1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_11,fieldName:"Costi_operativi_1anno__c",fieldNameTotale:"Simulazione__r.Costi_operativi1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_12,fieldName:"Margine_operativo_netto_1anno__c",fieldNameTotale:"Simulazione__r.Margine_operativo_netto1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_13,fieldName:"Erogato_1anno__c",fieldNameTotale:"Simulazione__r.Erogato1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_14,fieldName:"SML_1anno__c",fieldNameTotale:"Simulazione__r.SML1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_15,fieldName:"EAD__c",fieldNameTotale:"Simulazione__r.EAD1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_16,fieldName:"RWA_rischio_di_credito_1anno__c",fieldNameTotale:"Simulazione__r.RWA_rischio_di_credito1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_17,fieldName:"RWA_rischio_operativo_1anno__c",fieldNameTotale:"Simulazione__r.RWA_rischio_operativo1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_18,fieldName:"RWA_totale_1anno__c",fieldNameTotale:"Simulazione__r.RWA_totale1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_19,fieldName:"Capitale_Assorbito_1anno__c",fieldNameTotale:"Simulazione__r.Capitale_Assorbito1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_20,fieldName:"NOPAT_1anno__c",fieldNameTotale:"Simulazione__r.NOPAT_anno1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_21,fieldName:"EVA__c",fieldNameTotale:"Simulazione__r.EVA1__c",is_number:true,is_text:false,is_boolean:false,is_currency:false,is_percent:false,scale:0,css_header:"",css_row:""},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_22,fieldName:"RACE_1anno__c",fieldNameTotale:"Simulazione__r.RACE1__c",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"},// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                        {label:SviluppoAnno1_linea_23,fieldName:"RARORAC_1anno__c",fieldNameTotale:"Simulazione__r.RARORAC1__c",is_number:false,is_text:false,is_boolean:false,is_currency:false,is_percent:true,scale:0,css_header:"lutech_bold lutech_border_bottom",css_row:"lutech_bold lutech_border_bottom"}// AL 2024-03-11 -- Use delle label per le label e aggiunta del parametro scale:0
                    ]
                }
            }
        ]
    }

    //AD inizo
    @wire(getObjectInfo, { objectApiName: linea_OBJECT })
    wiredLinea;
    //AD fine
    @wire(getLinee, { recordId: "$recordId", objName : "$objectApiName"})
    wireGetLinee(data,error) {
        //debugger;
        if (this.recordId && this.wiredLinea) {//AD aggiungo la condizione se è popolato il wired di objectinfo sull'oggetto linea__c
            console.log('TEST 1 --> ' + JSON.stringify(data.data.lineas));
            this.records = this.flattenQueryResult(JSON.parse(JSON.stringify(data.data.lineas)));
            console.log('TEST 2 --> ' + JSON.stringify(this.records));
            if (this.mappingBySections[this.tableType]!=undefined) {
                let types = JSON.parse(JSON.stringify(this.mappingBySections[this.tableType]));
                //AD inizio
                /** predne il valore 'scale' dal wiredLinea e lo aggiungo alla variabile scale contenuta nella variabile 'types'*/
                console.log('AD wiredLinea : ' , this.wiredLinea);
                for( let i = 0; i< types.length ;i++ ){
                    types[i].table.rows.forEach(el=>{
                        let fieldName = el.fieldName;
                        el.scale = this.wiredLinea.data.fields[fieldName].scale
                    });
                }
                
                //AD fine
                for (let i=0; i<types.length; i++) {
                    let isTotale = false;
                    let t = types[i];
                    let table = t.table;
                    let rows = table.rows;
                    for (let j=0; j<rows.length; j++) {
                        if (rows[j]["records"]==undefined) {
                            rows[j]["records"] = [];
                            for (let k=0; k<table.headers.length; k++) {
                                //if(table.headers[k].includes("TOTALE")){
                                if(table.headers[k].includes(TOTALE_headres)){ // AL 2024-03-11 -- Use delle label per le label 
                                    isTotale = true;
                                }
                                rows[j]["records"].push({
                                    value:"",
                                    is_blank:true
                                });
                            }
                        }
                        for (let l=0; l<this.records.length; l++) {
                            if (isTotale) {
                                if (!this.isEmpty(this.records[l][rows[j]["fieldNameTotale"]]) || this.isBoolean(this.records[l][rows[j]["fieldNameTotale"]]))
                                {
                                    if (!this.isBoolean(this.records[l][rows[j]["fieldNameTotale"]])) {
                                        rows[j]["records"][0] = {
                                            value:this.records[l][rows[j]["fieldNameTotale"]],
                                            is_blank:false 
                                        };
                                    } else {
                                        rows[j]["records"][0] = {
                                            value:(this.records[l][rows[j]["fieldNameTotale"]] ? 'SI' : 'NO'),
                                            is_blank:false 
                                        };
                                    }
                                }
                                if (!this.isEmpty(this.records[l][rows[j]["fieldName"]]) || this.isBoolean(this.records[l][rows[j]["fieldName"]]))
                                {
                                    if (!this.isBoolean(this.records[l][rows[j]["fieldName"]])) {
                                        rows[j]["records"][l+1] = {
                                            value:this.records[l][rows[j]["fieldName"]],
                                            is_blank:false 
                                        };
                                    } else {
                                        rows[j]["records"][l+1] = {
                                            value:(this.records[l][rows[j]["fieldName"]] ? 'SI' : 'NO'),
                                            is_blank:false 
                                        };
                                    }
                                }
                            } else {
                                if (!this.isEmpty(this.records[l][rows[j]["fieldName"]]) || this.isBoolean(this.records[l][rows[j]["fieldName"]]))
                                {
                                    if (!this.isBoolean(this.records[l][rows[j]["fieldName"]])) {
                                        rows[j]["records"][l] = {
                                            value:this.records[l][rows[j]["fieldName"]],
                                            is_blank:false 
                                        };
                                    } else {
                                        rows[j]["records"][l] = {
                                            value:(this.records[l][rows[j]["fieldName"]] ? 'SI' : 'NO'),
                                            is_blank:false 
                                        };
                                    }
                                }
                            }
                        }
                    }
                }
                if (this.records.length>0) {
                    let numElemToDelete = 5-this.records.length;
                    types.forEach(type => {
                        type.table.headers.splice(type.table.headers.length-numElemToDelete,numElemToDelete);
                        // AL 2024-02-28 -- Tolgo le righe in più
                        type.table.rows.forEach(element => {
                            element.records.splice(element.records.length-numElemToDelete,numElemToDelete);
                        });    
                        // AL 2024-02-28 -- Fine
                        // AL 2024-02-28 -- Gestione degli header per la tabelle RARORAL e RECA
                        if(this.tableType==="RARORAC"||this.tableType==="RACE") {
                            this.records.forEach((record, index) => {
                                type.table.headers[index]+=(record.Sensitivity__c!=undefined?record.Sensitivity__c:0);
                            });                            
                        } 
                        // AL 2024-02-28 -- Fine
                    });
                    if (this.tbl_columns_size[types[0].table.headers.length+1]!=undefined) {
                        this.columns_size_class=this.tbl_columns_size[types[0].table.headers.length+1];
                    }
                }
                this.mapping = types;
                console.log(JSON.stringify(this.mapping));
            }
        }
    }

    flattenObject(propName, obj) {
        var flatObject = [];
        
        for(var prop in obj) {
            //if this property is an object, we need to flatten again
            var propIsNumber = isNaN(propName);
            var preAppend = propIsNumber ? propName+'.' : '';
            if(typeof obj[prop] == 'object') {
                flatObject[preAppend+prop] = Object.assign(flatObject, this.flattenObject(preAppend+prop,obj[prop]));
            }    
            else {
                flatObject[preAppend+prop] = obj[prop];
            }
        }
        return flatObject;
    } 
    flattenQueryResult(listOfObjects) {
        if(!Array.isArray(listOfObjects)) {
            var listOfObjects = [listOfObjects];
        }
        
        console.log('List of Objects is now....');
        console.log(listOfObjects);
        for(var i = 0; i < listOfObjects.length; i++) {
            var obj = listOfObjects[i];
            for(var prop in obj) {      
                if (!obj.hasOwnProperty(prop)) continue;
                if (typeof obj[prop] == 'object' && typeof obj[prop] != 'Array') {
                    obj = Object.assign(obj, this.flattenObject(prop,obj[prop]));
                }
                else if(typeof obj[prop] == 'Array') {
                    for(var j = 0; j < obj[prop].length; j++) {
                        obj[prop+'.'+j] = Object.assign(obj,this.flattenObject(prop,obj[prop]));
                    }
                }
            }
        }
        return listOfObjects;
    }

    isEmpty(value) {
        return (value == undefined || value == null || (typeof value === "string" && value.trim().length === 0));
    }
    isBoolean(value) {
        return (typeof value === "boolean");
    }
}