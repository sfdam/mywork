import { LightningElement, wire, api, track } from 'lwc';
import WGC_HOMEPAGE_CHANNEL from '@salesforce/messageChannel/wgcHomePageFilter__c';
import VisiteCompletate from '@salesforce/apex/WGC_Contatti_Visite_Controller.VisiteCompletate';
import Contatti from '@salesforce/apex/WGC_Contatti_Visite_Controller.Contatti';

// chartjs lib block
import chartjs from "@salesforce/resourceUrl/WGC_ChartJs";
import { loadScript } from "lightning/platformResourceLoader";
// chartjs lib block


export default class wgcContattiVisiteCompletateChart extends LightningElement {

    @api apexmethod;
    @api charttitle;
    @api tipoFiltro;
    @api filterValue;
    // chartjs lib block
    //Tipo di grafico
    @track chartType = "line";
    //Altezza della canvas

    //Colori di esempio
    @track backgroundColor = ['#ffc000','#ed7d31','#a5a5a5','#4472c4'];

    @api borderColor = ["rgba(56, 134, 197, 1)", "rgba(223, 222, 222, 1)","rgba(56, 134, 197, 1)", "rgba(223, 222, 222, 1)","rgba(56, 134, 197, 1)", "rgba(223, 222, 222, 1)","rgba(56, 134, 197, 1)", "rgba(223, 222, 222, 1)","rgba(56, 134, 197, 1)", "rgba(223, 222, 222, 1)"];

    //CHART
    chart;
    intcolors = 0;
    chartjsInitialized = false;
    isChartCreated = false;
    isChartRendered = false;
    config = {
        
        type: this.chartType,
        data: {
            labels: ['Gennaio','Febbraio','Marzo','Aprile','Maggio','Giugno','Luglio','Agosto','Settembre','Ottobre','Novembre', 'Dicembre'],
            datasets: [
            ]
        },
        options: {
            title: {
                display: false,
                text: this.charttitle
            },
            legend: {
                position: "bottom",
                align: "middle",
                labels: {
                    usePointStyle: true,
                    fontSize: 10,
                }
            },
            scales: {
                xAxes: [{
                    display: true,
                    scaleLabel: {
                        display: true,
                        labelString: 'Mese'
                    },
                    ticks: {
                        beginAtZero: true,
                        steps: 12,
                        autoSkip: false
                    }
                    
                }],
                yAxes: [{
                    display: true,
                    ticks: {
                        beginAtZero: true,
                        steps: 12,
                        stepValue: 5
                        // ,
                        // max: 60
                    }
                }]
            },
            events: ['click'],
            onClick: function(a, b){
                console.log('@@@ a ' , a);
                console.log('@@@ b ' , b);
            }
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

    getRandomInt(max) {
        return Math.floor(Math.random() * max);
    }

    handlechart(val, linelabel){
        let datachart = [];
        if(val.length > 0 && this.isChartRendered == false){
            for(let key in val) {
                console.debug("!Contatti_Visite_Completate: "+linelabel+" "+val[key].count);
                let gmonth = val[key].value * 5;
                datachart.push({ y: val[key].count, x: gmonth}); // this.getRandomInt(60)
            }
            this.updateChart(datachart, linelabel);
        }
        return true;
    }

    updateChart(datachart, label)
    {
        let dsColor = this.backgroundColor[this.intcolors];
        this.intcolors++;
        let newDataset = {
            label: label,
            fill: false,
            backgroundColor: dsColor,
            borderColor: dsColor,
            pointBackgroundColor: dsColor,
            pointBorderColor: 'gray',
            data: datachart,
        };
        console.debug('newDataset: '+JSON.stringify(newDataset))
        this.chart.data.datasets.push(newDataset);
        this.chart.update();
    }

    Contatti = function(){
        Contatti({filter: this.tipoFiltro, value: this.filterValue}).then(result => {
            console.debug("Apex params: "+this.tipoFiltro+" "+this.filterValue);
            console.debug("Apex result: "+JSON.stringify(result));
            this.handlechart(result, 'Contatti');

        }).catch(error => {
            console.debug("Apex Error: "+JSON.stringify(error));
        });
    };

    VisiteCompletate = function(){
        VisiteCompletate({filter: this.tipoFiltro, value: this.filterValue}).then(result => {
            console.debug("Apex params: "+this.tipoFiltro+" "+this.filterValue);
            console.debug("Apex result: "+JSON.stringify(result));
            this.handlechart(result, 'Visite Completate');

        }).catch(error => {
            console.debug("Apex Error: "+JSON.stringify(error));
        });
    };

    
    doselect(){
        this.template.querySelector('canvas.chart').height = '34vh';
        // this.template.querySelector('canvas.chart').style.height = '200px';
        let ctx = this.template.querySelector('canvas.chart').getContext('2d');
        this.chart = new Chart(ctx, this.config);
        this.isChartCreated = true;

        let apexmethods = this.apexmethod.split(';');
        for(let key in apexmethods) {
            this[apexmethods[key]]();
        }
    }


    chartclick(event) {
        //alert(JSON.stringify(event.currentTarget));
    }

}