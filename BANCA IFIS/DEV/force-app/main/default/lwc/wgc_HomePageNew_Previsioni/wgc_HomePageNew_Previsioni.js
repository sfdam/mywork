import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/WGC_ChartJs';

//CUSTOM LABELS
//METHODS

export default class Wgc_HomePageNew_Previsioni extends NavigationMixin(LightningElement) {

    @api title;
    @api iconName;
    chart;
    chartjsInitialized;

    connectedCallback(){

        // init()
        // .then(response =>{
        //     console.log('SV init.response', response);

        // })
        // .catch(error =>{
        //     console.error('SV init.error', error);
        // })
        //const labels = 1;
        const data = {
            labels: ["In attesa", "1", "2", "3"],
            datasets: [{
                label: 'Sviluppo attesa',
                backgroundColor: "#021f59",
                data: [12, 59, 5, 56, 58,12, 59, 87, 45],
            }, {
                label: 'Iniziative direzione',
                backgroundColor: "#76ded9",
                data: [12, 59, 5, 56, 58,12, 59, 85, 23],
            }, {
                label: 'Segnalazioni esterne',
                backgroundColor: "#7030a0",
                data: [12, 59, 5, 56, 58,12, 59, 65, 51],
            }],
        }

        this.config = {
            type: 'bar',
            data: data,
            options: {
              plugins: {
                title: {
                  display: true,
                  text: 'Chart.js Bar Chart - Stacked'
                },
              },
              responsive: true,
              interaction: {
                intersect: false,
              },
              scales: {
                xAxes: [{
                    stacked: true
                  }],
                yAxes: [{
                stacked: true
                }]
              }
            }
          };
          //var ctx = document.getElementById("myChart4").getContext('2d');
          //var myChart = new Chart(ctx, config)
    }

    renderedCallback(){

        try {
            
            if(this.chartjsInitialized){
                return;
            }
            this.chartjsInitialized = true;
            Promise.all([loadScript(this,chartjs)])
            .then(() =>{
                const ctx = this.template.querySelector('canvas.donut').getContext('2d');
                this.chart = new window.Chart(ctx, this.config);
                console.log('DK Promise.this.chart', this.chart);
            })
            .catch(error =>{
                console.error('DK renderedCallback.error', error);
            })
            .finally(() =>{
                console.log('DK this.chart', this.chart);
            });
        } catch (error) {
            console.error('DK renderedCallback.error', error);
        }
    }
}