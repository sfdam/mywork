import { LightningElement, api, track } from "lwc";
import chartjs from "@salesforce/resourceUrl/WGC_ChartJs";
//import pluginlabel from '@salesforce/resourceUrl/chartjs_pluginlabel';
import { loadScript } from "lightning/platformResourceLoader";
import {
  datasetExample,
  pluginDonutText,
  generateCanvas,
  getCanvasContext,
  generateDatasetBar,
  generateDatasetBarMultiple,
  generateOptionsStackedBar,
  generateDatasetStackedBar,
  generateDatasetSingleDoughnut,
  generateOptionsDoughnut,
} from "c/wgc_chart_utility";

export default class Wgc_canvas_chart extends LightningElement {
  //Contains the dataset for the graphics
  @api chartData = [];
  //Contains data for chart
  @track _apexData;
  //Contiene l'oggetto Chart di chartjs
  @track chart;
  //Tipo di grafico ereditato dal parent
  @api chartType;
  //Altezza della canvas ereditata dal parent
  @api height;

  //Colori di esempio
  @api backgroundColor = [
    "rgba(56, 134, 197, 0.2)",
    "rgba(223, 222, 222, 0.2)",
  ];
  @api borderColor = ["rgba(56, 134, 197, 1)", "rgba(223, 222, 222, 1)"];

  //Carico la libreria chartjs e inizializzo canvas e grafico
  connectedCallback() {
    // loadScript(this, chartjs).then(() => {
    //     return loadScript(this,pluginlabel);
    //   })
    //   .then(() => {
    //     const canvas = generateCanvas(parseInt(this.height));
    //     this.appendCanvas(".chart", canvas);
    //     if (this._apexData != undefined && this._apexData != null)
    //       this.generateChart();
    //   })
    //   .catch((err) => {
    //       console.log('@@@ err ' , err);
    //   });
    loadScript(this, chartjs).then(() => {
      const canvas = generateCanvas(parseInt(this.height));
      this.appendCanvas(".chart", canvas);
      if (this._apexData != undefined && this._apexData != null)
        this.generateChart();
    })
    .catch((err) => {
        console.log('@@@ err ' , err);
    });
  }

  /* Function - START */

  appendCanvas(parentCssClass, canvas) {
    this.template.querySelector(parentCssClass).appendChild(canvas);
  }

  generateChart() {
    let data = this.generateDatasetByType();
    if (data == null) return;
    let options = this.generateOptionsByType();
    let dataGeneric = datasetExample();
    dataGeneric.type = this.chartType;
    console.log("@@@ data ", data);
    dataGeneric.data.datasets = data.datasets;
    dataGeneric.data.labels = data.labels;
    if (
      this._apexData.groupedBy != undefined &&
      this._apexData.groupedBy.includes("CountID")
    )
      dataGeneric.data.labels.push("Totale");
    dataGeneric.options = options;
    if(this.chartType == "bar"){   
      dataGeneric.options.plugins = {
        datalabels: {
          color: 'black',
          // display: function(context) {
          // },
          font: {
            weight: 'bold'
          },
          formatter: (value, context) => {
            console.log('@@@ context ' , context);
            let format = new Intl.NumberFormat('it-IT', { maximumSignificantDigits: 4 }).format(value);
            format = format.replaceAll('.','');
            if(format.charAt(0) == '-'){
                if(format.length >= 11 && format.length <= 13){
                    if(format.length == 13)
                        format = format.substring(0,4);
                    if(format.length == 12)
                        format = format.substring(0,3);
                    if(format.length == 11){
                        if(format.charAt(1) != '0'){
                            format = format.substring(0,2) + '.' + format.substring(2);
                            format = format.substring(0, 4);
                        } else
                            format = format.substring(0,2);
                    }

                    return format + 'B'; 
                } else if(format.length >= 8 && format.length <= 10){
                    if(format.length == 10)
                        format = format.substring(0,4);
                    if(format.length == 9)
                        format = format.substring(0,3);
                    if(format.length == 8){
                        if(format.charAt(1) != '0'){
                            format = format.substring(0,2) + '.' + format.substring(2);
                            format = format.substring(0, 4);
                        } else
                            format = format.substring(0,2);
                    }

                    format = format + 'M';
                    return format;
                } else if(format.length >= 5 && format.length <=7){
                    if(format.length == 7)
                        format = format.substring(0,4);
                    if(format.length == 6)
                        format = format.substring(0,3);
                    if(format.length == 5){
                        if(format.charAt(1) != '0'){
                            format = format.substring(0,2) + '.' + format.substring(2);
                            format = format.substring(0, 4);
                        } else
                            format = format.substring(0,2);
                    }
                    
                    format = format + 'K';
                    return format;
                    // return format + 'K';
                }
            } else {
                if(format.length >= 10 && format.length <= 12){
                    if(format.length == 12)
                        format = format.substring(0,3);
                    if(format.length == 11)
                        format = format.substring(0,2);
                    if(format.length == 10){
                        if(format.charAt(1) != '0'){
                            format = format.substring(0,1) + '.' + format.substring(1);
                            format = format.substring(0, 3);
                        } else
                            format = format.substring(0,1);
                    }
                        
                    return format + 'B'; 
                } else if(format.length >= 7 && format.length <= 9){
                    if(format.length == 9)
                        format = format.substring(0,3);
                    if(format.length == 8)
                        format = format.substring(0,2);
                    if(format.length == 7){
                        if(format.charAt(1) != '0'){
                            format = format.substring(0,1) + '.' + format.substring(1);
                            format = format.substring(0, 3);
                        } else
                            format = format.substring(0,1);
                    }

                    format = format + 'M';
                    return format;
                } else if(format.length >= 4 && format.length <= 6){
                    if(format.length == 6)
                        format = format.substring(0,3);
                    if(format.length == 5)
                        format = format.substring(0,2);
                    if(format.length == 4){
                        if(format.charAt(1) != '0'){
                            format = format.substring(0,1) + '.' + format.substring(1);
                            format = format.substring(0, 3);
                        } else
                            format = format.substring(0,1);
                    }

                    format = format + 'K';
                    return format;
                }
            }

            return format;
          }
        }
      }
    } else if (this.chartType == "doughnut") {
      dataGeneric.plugins.push({
        beforeDraw: pluginDonutText(
          this._apexData.subtitle,
          this._apexData.data
        ),
      });
    } 
    
    if(this.chartType != 'bar'){
      dataGeneric.options.plugins = {
        datalabels: {
          formatter: function(value, context) {
              return '';
          }
        }
      }
    }
    let canvas = this.template.querySelector("canvas");
    //Aggiorno il grafico nel caso sia stato già generato e la canvas è presente
    if (this.chart != undefined && canvas != null) {
      this.chart.type = this.chartType;
      this.chart.data.labels = data.labels;
      this.chart.data.datasets = data.datasets;
      this.chart.options = options;
      this.chart.update();
    } else if (canvas != null && data.labels.length > 0) {
      //Genero un nuovo grafico da zero con le opzioni ed i dati generati
    //   Chart.plugins.unregister(ChartDataLabels);
      this.chart = new Chart(getCanvasContext(canvas), dataGeneric);
    }
  }

  //Funzione per generare il dataset in base al tipo di grafico
  generateDatasetByType() {
    switch (this.chartType) {
      case "bar":
        if (this._apexData.isStacked)
          return generateDatasetStackedBar(
            this._apexData.data,
            this._apexData.groupedBy,
            this.backgroundColor,
            this.borderColor
          );
        else if (this._apexData.multiplebar)
          return generateDatasetBarMultiple(
            this._apexData.data,
            this._apexData.groupedBy,
            this.backgroundColor,
            this.borderColor
          );
        else
          return generateDatasetBar(
            this._apexData.data,
            this._apexData.groupedBy,
            this.backgroundColor,
            this.borderColor
          );
      case "doughnut":
        return generateDatasetSingleDoughnut(
          this._apexData.data,
          this.backgroundColor,
          this.borderColor
        );
      default:
        return generateDatasetBar(
          this._apexData.data,
          this._apexData.groupedBy,
          this.backgroundColor,
          this.borderColor
        );
    }
  }

  //Funzione per generare le opzioni in base al tipo di grafico
  generateOptionsByType() {
    switch (this.chartType) {
      case "bar":
        if (this._apexData.isStacked)
          return generateOptionsStackedBar(datasetExample().options);
        else {
          let options = datasetExample().options;
          options.title = {};
          options.title.text =
            this._apexData.title != undefined ? this._apexData.title : "";
          options.title.display = this._apexData.title != undefined;
          options.legend.display = this._apexData.groupedBy.includes("CountID")
            ? false
            : true;
          // if(this._apexData.groupedBy.includes('CountID')){
          //     options.scales.yAxes[0].stacked = true;
          //     options.scales.yAxes[0].stacked = false;
          // }
          // options.title.position = 'left';
          return options;
          // return datasetExample().options;
        }
      case "doughnut":
        return generateOptionsDoughnut(
          datasetExample().options,
          this._apexData.title
        );
      default:
        return datasetExample().options;
    }
  }

  /* Function - END */

  /* GETTER & SETTER - START */

  get noData() {
    return (
      this.chart == null ||
      this.chart == undefined ||
      this._apexData == null ||
      this._apexData == undefined ||
      this.chart.data.labels.length == 0
    );
  }

  @api get apexData() {
    return this._apexData;
  }

  set apexData(value) {
    this._apexData = value;
    if (value != null && value != undefined) {
      this.generateChart();
    }
  }

  get chartHeight() {
    return "height: " + this.height + "px;";
  }

  /* GETTER & SETTER - END */
}