import { LightningElement, wire, api, track } from 'lwc';
import WGC_HOMEPAGE_CHANNEL from '@salesforce/messageChannel/wgcHomePageFilter__c';
import Debitori from '@salesforce/apex/WGC_Portafoglio_Debitori_Controller.Debitori';
import WGC_Chart_NoData from '@salesforce/label/c.wgc_chart_nodata';

// chartjs lib block
import chartjs from "@salesforce/resourceUrl/WGC_ChartJs";
import { loadScript } from "lightning/platformResourceLoader";
// chartjs lib block


export default class wgcPortafoglioDebitoriChart extends LightningElement {

    @api apexmethod;
    @api charttitle;
    @api tipoFiltro;
    @api filterValue;
    // chartjs lib block
    //Tipo di grafico
    @track hasdata = true;
    @track nodatatxt = WGC_Chart_NoData;

    @track chartType = "doughnut";
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
                console.debug("!Portafoglio_Debitori: "+val[key].label+" "+val[key].count);
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
                            text: '',
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

    Debitori = function(){
        Debitori({filter: this.tipoFiltro, value: this.filterValue}).then(result => {
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
        let apexmethod = this.apexmethod;
        this[apexmethod]();
    }
}