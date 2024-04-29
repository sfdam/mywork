import { LightningElement, wire, api, track } from 'lwc';
import WGC_HOMEPAGE_CHANNEL from '@salesforce/messageChannel/wgcHomePageFilter__c';
import ClientiPerProdotto from '@salesforce/apex/WGC_Portafoglio_Clienti_Controller.ClientiPerProdotto';
import clientiPerQualificaProgressive from '@salesforce/apex/WGC_Portafoglio_Clienti_Controller.clientiPerQualificaProgressive';
import WGC_Chart_NoData from '@salesforce/label/c.wgc_chart_nodata';
// chartjs lib block
import chartjs from "@salesforce/resourceUrl/WGC_ChartJs";
import { loadScript } from "lightning/platformResourceLoader";
// chartjs lib block


export default class wgcPortafoglioClientiChart extends LightningElement {

    @api apexmethod;
    @api charttitle;
    @api tipoFiltro;
    @api filterValue;
    @api lastCreatedDate = '1900-07-20T01:02:03Z';
    @api QUERY_LIMIT = 50000;
    @api currentDataset;
    @api initCalled = false;

    // chartjs lib block
    //Tipo di grafico
    @track chartType = "doughnut";
    @track hasdata = true;
    @track nodatatxt = WGC_Chart_NoData;
    //Altezza della canvas

    //Colori di esempio
    @track backgroundColor = ['#ffc000','#a5a5a5','#4472c4','#ed7d31'];

    @api borderColor = ["rgba(56, 134, 197, 1)", "rgba(223, 222, 222, 1)"];

    //CHART
    chart;
    chartjsInitialized = false;
    isChartCreated = false;
    isChartRendered = false;
    config = {
        type: this.chartType,
        data: {
            datasets: [{
                data: [],
                backgroundColor: this.backgroundColor,
                label: this.title
            }],
            labels: []
        },
        options: {
            responsive: true,
            legend: {
                position: "bottom",
                align: "middle",
                labels: {
                    usePointStyle: true,
                    fontSize: 10,
                }
            },
            animation: {
                animateScale: true,
                animateRotate: true
            },
        }
    };
    // chartjs lib block


    renderedCallback(){

        if (this.chartjsInitialized == true) {
            return;
        }
        this.chartjsInitialized = true;
        Promise.all([
            loadScript(this, chartjs)
        ]).then(() => {
            this.doselect();
            /*
            let val = [];
            val.push({label: "SOLO FACTORING", count: 10});
            val.push({label: "SOLO MUTUO", count: 30});
            val.push({label: "FCT+MUTUO", count: 40});
            val.push({label: "ALTRO", count: 20});

            this.handlechart('chart', val, 'Distribuzione per Prodotti');

            this.isChartRendered = true;
            console.log('rendered completed');
            */
        })

    }

    handlechart(canvasid, val, texttitle){
        let ctx = this.template.querySelector('canvas.'+canvasid).getContext('2d');
        this.chart = new Chart(ctx, this.config);
        this.isChartCreated = true;
        let hasdatacheck = false;

        if(val.length > 0 && this.isChartRendered == false){
            for(let key in val) {
                console.debug("!Portafoglio_Clienti: "+val[key].label+" "+val[key].count);
                if(val[key].count>0){
                    hasdatacheck = true;
                }
                this.updateChart(val[key].count, val[key].label, texttitle);
            }
        }
        if(hasdatacheck){ this.hasdata = true;}else{this.hasdata = false;}
        return true;
    }

    updateChart(count, label, texttitle)
    {
        let tempLabels = [];
        tempLabels = this.chart.data.labels;
        tempLabels.push(label);
        this.chart.data.labels = tempLabels;
        this.chart.options.title = {
                            position: "top",
                            display: true,
                            text: texttitle,
                            fontSize: 10,
                        };
        let tempData = [];
        this.chart.data.datasets.forEach((dataset) => {
            tempData = dataset.data;
            tempData.push(count);
            dataset.data = tempData;
        });
        this.chart.update();
    }

    ClientiPerQualifica = function(){
        /*ClientiPerQualifica({filter: this.tipoFiltro, value: this.filterValue}).then(result => {
            console.debug("Apex params: "+this.tipoFiltro+" "+this.filterValue);
            console.debug("Apex result: "+JSON.stringify(result));
            this.handlechart('chart', result, this.charttitle);

            this.isChartRendered = true;
            console.log('rendered completed');

        }).catch(error => {
            console.debug("Apex Error: "+JSON.stringify(error));
        });*/
        this.getClientiPerQualifica();
    };

    getClientiPerQualifica(){
        clientiPerQualificaProgressive({ filter: this.tipoFiltro
                                        ,value: this.filterValue
                                        ,lastCreatedDate: this.lastCreatedDate
                                        ,queryLimit: this.QUERY_LIMIT
                                        ,sCurrentDataset: JSON.stringify(this.currentDataset)
        }).then(result => {


            //S:Riepio i valori
            this.lastCreatedDate = result['lastCreatedDate']/*.replace('.000','')*/;
            //alert('DATA: ' + this.lastCreatedDate );
            this.currentDataset = result['dataset'];

            //E:Riepio i valori
            
            if(result['needRecall']){
                
                this.getClientiPerQualifica();
            }
            else{
                this.onCompleteGetClientiPerQualifica();
            }

        }).catch(error => {
            console.error("Apex Error: "+JSON.stringify(error));
        });
    }

    onCompleteGetClientiPerQualifica(){
        this.handlechart('chart', this.currentDataset, this.charttitle);
    }

    ClientiPerProdotto = function(){
        ClientiPerProdotto({filter: this.tipoFiltro, value: this.filterValue}).then(result => {
            console.debug("Apex params: "+this.tipoFiltro+" "+this.filterValue);
            console.debug("Apex result: "+JSON.stringify(result));
            this.handlechart('chart', result, this.charttitle);

            this.isChartRendered = true;
            console.log('rendered completed');

        }).catch(error => {
            console.debug("Apex Error: "+JSON.stringify(error));
        });
    };

    
    doselect(){
        if(!this.initCalled){
            let apexmethod = this.apexmethod;
            this[apexmethod]();
            this.initCalled = true;
        }
    }
}