import { LightningElement, track, wire, api } from 'lwc';

import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import { loadScript } from 'lightning/platformResourceLoader';
import chartjs from '@salesforce/resourceUrl/WGC_ChartJs';

import getPieChartValues from '@salesforce/apex/WGC_AttivitaOdierneController.getPieChartValues';
export default class Wgc_attivita_odierne_pie_chart extends NavigationMixin(LightningElement) {

    // PIE CHART
    @track iniziativeDirezione = 0;
    @track sviluppoDiretto = 0;
    @track showPieChart = false;
    @track loadedPieChart = false;

    @track hrefReport = '';

    currentPageReference;
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
            this.currentPageReference = currentPageReference;
       }
    }

    connectedCallback(){
        try {
            
            console.log('DK currentPageReference', this.currentPageReference.state);
            let idReportSviluppoDiretto = this.currentPageReference.state.c__idReportSD;
            let idReportIniziativeDirezione = this.currentPageReference.state.c__idReportID;
            let navigationmixin = (reportId) => {
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: reportId,
                        objectApiName: 'Report',
                        actionName: 'view'
                    }
                });
            };
            this.config = {
                type : 'doughnut',
                data :{
                    datasets :[{
                        data: [
                        ],
                        backgroundColor :[
                            'rgb(255,99,132)',
                            'rgb(255,159,64)',
                            'rgb(255,205,86)',
                            'rgb(75,192,192)',
                        ],
                        label:'Dataset 1'
                    }],
                    labels:[]
                },
                options: {
                    responsive : true,
                    legend : {
                        position :'bottom',
                        onClick : function (evt, item) {
                            try {
                                let reportId = item.text === 'Sviluppo Diretto' ? idReportSviluppoDiretto : idReportIniziativeDirezione;
                                console.log('DK reportId', reportId);
                                if(reportId){
                                    navigationmixin(reportId);
                                }
                            } catch (error) {
                                console.log('Dk error', error);
                            }
                        }
                    },
                    animation:{
                        animateScale: true,
                        animateRotate : true
                    }
                }
            };
        } catch (error) {
            console.log('Dk error', error);
        }
    }

    chart;
    chartjsInitialized = false;
    config = {};

    handleOnlickEvent(evt, item){
        console.log('DK evt', evt);
        console.log('DK item', item);
    }
    
    @track hasData;
    @wire (getPieChartValues) getDataFunction({error,data}){
        try {
            console.log('DK data', data);
            if(data && data.length > 0){   
                data.forEach(element => {
                    if(element.campagna){
                        this.sviluppoDiretto += element.tot;
                    }else{
                        this.iniziativeDirezione += element.tot;
                    }
                });
                this.updateChart(this.iniziativeDirezione, 'Iniziative Direzione');
                this.updateChart(this.sviluppoDiretto, 'Sviluppo Diretto');
                this.hasData = true;
                this.loadedPieChart = true;
            }else{
                this.hasData = false;
            }
        } catch (error) {
            console.error('DK getPieChartValues.error', error);
        }
    }

    renderedCallback(){
        try {
            
            if(this.chartjsInitialized){
                return;
            }
            this.chartjsInitialized = true;
            Promise.all([loadScript(this,chartjs)])
            .then(() =>{
                const ctx = this.template.querySelector('canvas.donut')
                .getContext('2d');
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

    updateChart(count,label){

        this.chart.data.labels.push(label);
        this.chart.data.datasets.forEach((dataset) => {
        dataset.data.push(count);
        });
        this.chart.update();
    }


    handleGetBack(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'WGC_New_HomePage',
            }
        });
    }
}