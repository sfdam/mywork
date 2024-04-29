import { LightningElement, api, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import getChartDataGeneric from '@salesforce/apex/WGC_Chart_Controller.getChartDataGeneric';
import getChartsMetadata from '@salesforce/apex/WGC_Chart_Controller.getChartsMetadata';
import { NavigationMixin } from 'lightning/navigation';

const APEXCLASSNAME = 'WGC_Chart_Callable';

export default class Wgc_chart_container extends NavigationMixin(LightningElement) {
    
    @api recordId;
    @api chartTitle;
    @track showButton = false;
    @track _chartName;
    // @api methodName = 'Account_Posizione_Monitoraggio';

    @api title = 'POSIZIONE';
    @api iconName = 'utility:graph';
    @api showIcon = false;

    @api collapsed = false;
    @api enableAccordion = false;
    @api isHomePage = false;
    @api enableDetail = false;
    @track cssClassContainer;

    //Attributo per il component chart_button
    @track buttons = [];
    @track selectedBtn;

    @track isLoaded = false;
    @track showError = false;
    @track chartMetaConfiguration;

    // @track chartDataTest = false;
    // @track apexData;
    @track graphs = [];

    connectedCallback(){
        //this.initialize();
    }

    initialize(){
        this.isLoaded = false;
        getChartsMetadata({ apiNameMetadato: this.chartName }).then(res => {
            this.chartMetaConfiguration = res;
            this.prepareButtons();
            // this.prepareLayout();
            this.loadGraphData(this.selectedBtn);
            this.isLoaded = true;
        }).catch(err => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: "ERRORE!",
                    message: err.body.message,
                    variant: "error",
                })
            );
            
            this.isLoaded = true;
            this.showError = true;
        });
    }

    loadGraphData(graphName){
        this.isLoaded = false;
        // this.chartDataTest = false;
        let recordId = this.recordId;
        let component = this.chartMetaConfiguration.name;
        let apexMethod = graphName != undefined && this.selectedBtn != undefined ? component + '_' + graphName : component; //'Account_Posizione_Cliente';
        //Example: 'Account_Posizione_Cliente'
        this.prepareLayout();
        let generatedParams = this.generateParams();
        getChartDataGeneric({apexClass: APEXCLASSNAME, apexMethod: apexMethod, params: generatedParams }).then((response) => {
            if(response.success){
                let newGraphs = [];
                let i = 0;
                let h = this;
                this.graphs.forEach(g => {
                    let newG = {...g};
                    if(newG.isVisible){
                        if(newG.apexData == undefined)
                            newG.apexData = response.data[i];
                        
                        if(newG.isTable){
                            newG.tableData = h.generateTableData(newG.apexData);
                        }
                        i++;
                    }

                    newGraphs.push(newG);
                })

                this.graphs = newGraphs;
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Errore!",
                        message: "Errore durante il caricamento del grafico",
                        variant: "error"
                    })
                )
            }
            this.isLoaded = true;
        }).catch(err => {
            console.log('@@@ err ' , err);
            alert(err.message);
            this.isLoaded = true;
        })
    }

    //Creo la griglia ed il parametro contente l'array di grafici con gli attributi necessari
    prepareLayout(){
        let chartInfos = JSON.parse(this.chartMetaConfiguration.informazioniGrafici);
        let graphs = [];

        for(let key in chartInfos){
            chartInfos[key].forEach((item, i) => {
                let newGraph = { id: i.toString(), chartType: item.chartType, height: item.height, cssClass: 'slds-col slds-size_'+item.columnSize+'-of-12', isVisible: this.selectedBtn != undefined ? key == this.selectedBtn : true, backgroundColor: item.backgroundColor, borderColor: item.borderColor, params: item.params, isTable: item.chartType == 'table', tableColumns: item.tableColumns, tableData: [] };
                graphs.push(newGraph);
                i++;
            });
        }

        this.graphs = graphs;

    }

    //Funzione utilizzata per gestire i bottoni con le informazioni prese dal metadato
    prepareButtons(){
        //&& Array.isArray(this.chartMetaConfiguration.btnLabel)
        if(this.chartMetaConfiguration.btnLabel != undefined){
            let btns = this.chartMetaConfiguration.btnLabel;
            //Indice utilizzato come id per i pulsanti di primo livello
            let i = 0;
            //Indice utilizzato come id per i pulsanti di secondo livello
            let ii = 0;
            //Array che contiene i pulsanti generati per il componente figlio
            let newBtns = [];
            //Condizione che verifica la presenza di bottoni di primo livello
            //i bottoni sono gestiti con una Map<String,List<String>>; 
            //la chiave della mappa contiene il pulsante di primo livello se presente, altrimenti contiene il nome del metadato
            //Se la chiave con il nome del metadato è inesistente allora sono presenti i pulsanti di primo livello
            if(btns[this._chartName] == undefined){
                //Primo livello
                for(let key in btns){
                    let newBtn = { id: i.toString(), label: key, cssClass: 'cstm-button' + (i == 0 ? ' selected' : ''), value: btns[key] };
                    newBtns.push(newBtn);
                    i++;
                }

                //Secondo livello
                //Indice utilizzato per recuperare il nome dell'azione da eseguire dall'array btnActions
                let actionIndex = 0;
                i = 0;
                for(let key in btns){
                    ii = 0;
                    btns[key].forEach(btn => {
                        let newBtn = { id: i+'_'+ii, label: btn, cssClass: 'cstm-button' + (ii == 0 ? ' selected' : ''), value: this.chartMetaConfiguration.btnActions[actionIndex] };
                        newBtns.push(newBtn);

                        if(newBtn.cssClass.includes('selected') && this.selectedBtn == undefined){
                            this.selectedBtn = this.chartMetaConfiguration.btnActions[actionIndex];
                        }

                        ii++;
                        actionIndex ++;
                    })
                    i++;
                }
            } else {
                //Solo secondo livello
                btns[this._chartName].forEach(btn => {
                    let newBtn = { id: i.toString(), label: btn, cssClass: 'cstm-button' + (i == 0 ? ' selected' : ''), value: this.chartMetaConfiguration.btnActions[i] };
                    newBtns.push(newBtn);
                    if(newBtn.cssClass.includes('selected') && this.selectedBtn == undefined)
                        this.selectedBtn = this.chartMetaConfiguration.btnActions[i];

                    i++;
                });
            }

            this.buttons = newBtns;

            if(this.buttons.length > 0)
                this.showButton = true;
        }
        
    }

    handleChangeGraphics(event){
        let graphName = event.detail.graph;
        this.selectedBtn = event.detail.graph;
        this.loadGraphData(graphName);
    }

    handleCollapse(event){
        event.preventDefault();
        let btn = this.template.querySelector('button[data-btn="collapse"]');
        btn.classList.toggle('cstm-open');
        if(this.buttons.length > 0)
            this.showButton = !this.showButton;
        let chartContainer = this.template.querySelector('div[data-id="chart-container"]');
        // chartContainer.classList.toggle('slds-hide');
        chartContainer.classList.toggle('cstm-chart-opened');
        chartContainer.classList.toggle('cstm-chart-collapsed');
        this.cssClassContainer = chartContainer.className; 

        let intervalBtn = setInterval(function(){
            let chart = this.template.querySelector('div[data-id="chart"]');
            chart.classList.toggle('slds-hide');
            clearInterval(intervalBtn);
        }.bind(this), 300);
    }

    goToDetail(evt){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'WGC_Base_Clienti'
            }
        });
    }

    generateParams(){
        let generatedParams = {};
        let visibleCharts = this.graphs.find(g => { return g.isVisible; });
        if(visibleCharts != undefined){
            let params = {};
            if(Array.isArray(visibleCharts)){
                params = visibleCharts[0].params;
            } else {
                params = visibleCharts.params;
            }

            if(params != undefined){
                for (const [key, value] of Object.entries(params)) {
                    if(value.includes('###')){
                        generatedParams[key] = this[value.replaceAll('###','')];
                    } else
                        generatedParams[key] = value;
                }
            }
        }
        return generatedParams;
    }

    generateTableData(data){
        let tableData = [];
        if(data != undefined){
            for (const [key, value] of Object.entries(data.data)) {
                let newRow = { Mese__c: value[0].Mese__c };
                let actualPortafoglio = 0;
                let actualNewBusiness = 0;
                value.forEach(v => {
                    if(v.Tipo_busuness__c == 'Portafoglio')
                        actualPortafoglio += parseFloat(v.Actual__c);
                    if(v.Tipo_busuness__c == 'New Business'){
                        actualNewBusiness += parseFloat(v.Actual__c);
                    }
                })
                newRow.ActualPortafoglio = actualPortafoglio;
                newRow.ActualNewBusiness = actualNewBusiness;
                newRow.ActualTotale = actualPortafoglio + actualNewBusiness;
                tableData.push(newRow);
            }
        }

        return tableData;
    }

    //Attributo ereditato dal parent oppure da lightning page
    @api
    get chartName(){
        return this._chartName;
    }

    set chartName(chartName){
        this._chartName = chartName;
        this.initialize();
    }

    get cssChartContainer(){
        var cssClass = this.enableAccordion ? 'slds-card slds-var-m-top_medium cstm-chart-container cstm-chart-collapsed' : 'slds-card slds-var-m-top_medium cstm-chart-container cstm-chart-opened';

        if(this.isHomePage)
            cssClass = cssClass.replace('slds-var-m-top_medium','');

        return cssClass;
    }

    get cssChart(){
        return this.enableAccordion ? 'slds-col slds-size_1-of-1 slds-hide' : 'slds-col slds-size_1-of-1';
    }
}