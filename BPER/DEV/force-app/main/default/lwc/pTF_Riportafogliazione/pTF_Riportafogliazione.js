import { LightningElement, api, track  } from 'lwc';

const COLUMNS = [
    {
        label: 'NDG',
        initialWidth: 100,
        fieldName: 'NDG__c',
        type: 'text'
    },
    {
        label: 'Denominazione',
        initialWidth: 200,
        fieldName: 'Denominazione',
        type: 'text'
    },
    {
        label: 'Portafoglio di partenza',
        initialWidth: 200,
        fieldName: 'Portafoglio_Di_Partenza__c',
        type: 'text'
    },
    {
        label: 'MMDS',
        initialWidth: 100,
        fieldName: 'MMDS__c',
        type: 'text'
    },
    {
        label: 'Patrimonio',
        initialWidth: 150,
        fieldName: 'Patrimonio',
        type: 'currency'
    },
    {
        label: 'Fatturato',
        initialWidth: 150,
        fieldName: 'Fatturato',
        type: 'currency'
    },
    {
        label: 'Accordato',
        initialWidth: 150,
        fieldName: 'Accordato',
        type: 'currency'
    },
    {
        label: 'Utilizzato',
        initialWidth: 150,
        fieldName: 'Utilizzato',
        type: 'currency'
    },
    {
        label: 'MMDS Obiettivo',
        initialWidth: 150,
        fieldName: 'MMDS_Obiettivo__c',
        type: 'text'
    },
    {
        label: 'Portafoglio di destinazione',
        initialWidth: 200,
        fieldName: 'Portafoglio_Di_Destinazione__c',
        type: 'text'
    },
    {
        label: 'Stato Spostamento',
        fieldName: 'stato',
        initialWidth: 200,
        type: 'text',
        editable: true 
    },
    {
        label: 'Motivo di rifiuto',
        initialWidth: 200,
        fieldName: 'Motivo_di_rifiuto__c',
        type: 'text', 
        editable: true 
    },
    {
        label: 'Portafoglio alternativo',
        initialWidth: 200,
        fieldName: 'Portafoglio_Alternativo_Name__c',
        type: 'text', 
        editable: true 
    },
    {
        label: 'Altro',
        initialWidth: 300,
        fieldName: 'Altro__c',
        type: 'text', 
        editable: true 
    },
];

const COLUMNS_GESTIONE = [
    {
        label: 'Direzione Territoriale',
        fieldName: 'DT',
        type: 'text'
    },
    {
        label: 'Id Ced',
        fieldName: 'IdCed',
        type: 'text'
    },
    {
        label: 'ABI',
        fieldName: 'ABI',
        type: 'text'
    },
    {
        label: 'Tipologia Spostamento',
        fieldName: 'tipoSpostamento',
        type: 'text'
    },
    {
        label: 'Percentuale Affinamento',
        fieldName: 'percAff',
        type: 'percent',
        editable: true
    },
    
];

export default class PTF_Riportafogliazione extends LightningElement {
    columns=COLUMNS;
    columnsGestione=COLUMNS_GESTIONE;
    currentPageData =[
        {
            "NDG__c": 209128,
            "Denominazione":"Account 1",
            "Portafoglio_Di_Partenza__c":"PTF-FA-05387-0000-00001",
            "MMDS__c":"Family",
            "Patrimonio":100000,
            "Fatturato":100000,
            "Accordato":100000,
            "Utilizzato":100000,
            "MMDS_Obiettivo__c":"Personal",
            "Portafoglio_Di_Destinazione__c":"PTF-PE-05387-0100-00001",
            "stato":"ACCETTATO",
            "Motivo_di_rifiuto__c":"",
            "Portafoglio_Alternativo_Name__c":"",
            "Altro__c":""

        },
        {
            "NDG__c": 209129,
            "Denominazione":"Account 2",
            "Portafoglio_Di_Partenza__c":"PTF-PE-05387-0082-00001",
            "MMDS__c":"Personal",
            "Patrimonio":100000,
            "Fatturato":100000,
            "Accordato":100000,
            "Utilizzato":100000,
            "MMDS_Obiettivo__c":"Private",
            "Portafoglio_Di_Destinazione__c":"PTF-PR-05387-0100-00001",
            "stato":"RIFIUTATO",
            "Motivo_di_rifiuto__c":"Portafoglio Differente",
            "Portafoglio_Alternativo_Name__c":"PTF-PR-05387-0100-00002",
            "Altro__c":"ok allo spostamento ma PTF da modificare"
        }];

    currentPageDataGestione =[
            {
                "DT": "LAZIO",
                "IdCed":"1077",
                "ABI":"05387",
                "tipoSpostamento":"UPGRADE",
                "percAff":0.05
    
            },
            {
                "DT": "LAZIO",
                "IdCed":"1077",
                "ABI":"05387",
                "tipoSpostamento":"DOWNGRADE",
                "percAff":0.05
    
            },
            {
                "DT": "CAMPANIA",
                "IdCed":"1076",
                "ABI":"05387",
                "tipoSpostamento":"UPGRADE",
                "percAff":0.05
    
            },
            {
                "DT": "CAMPANIA",
                "IdCed":"1076",
                "ABI":"05387",
                "tipoSpostamento":"DOWNGRADE",
                "percAff":0.05
    
            }];
}