//Funzione per creare un grafico di esempio
const datasetExample = () => {
    return {
        type: 'line',
        data: {
            labels: ['Red', 'Blue', 'Yellow', 'Green', 'Purple', 'Orange'],
            datasets: [{
                label: '# of Votes',
                data: [12, 19, 3, 5, 2, 3],
                backgroundColor: [
                    'rgba(255, 99, 132, 0.2)',
                    'rgba(54, 162, 235, 0.2)',
                    'rgba(255, 206, 86, 0.2)',
                    'rgba(75, 192, 192, 0.2)',
                    'rgba(153, 102, 255, 0.2)',
                    'rgba(255, 159, 64, 0.2)'
                ],
                borderColor: [
                    'rgba(255, 99, 132, 1)',
                    'rgba(54, 162, 235, 1)',
                    'rgba(255, 206, 86, 1)',
                    'rgba(75, 192, 192, 1)',
                    'rgba(153, 102, 255, 1)',
                    'rgba(255, 159, 64, 1)'
                ],
                borderWidth: 1
            }]
        },
        options: {
            // responsive: true,
            mantainAspectRatio: false, 
            legend: {
                display:true,
                position: 'bottom'
            },
            scales: {
                yAxes: [{
                    display:true,
                    ticks: {
                        beginAtZero: true,
                        // autoSkip: true,
                        maxTicksLimit: 5,
                        callback: function(value, index, values) {
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
                    },
                    gridLines: {
                        display: false,
                    }
                }],
                xAxes: [{
                    beginAtZero: true,
                    ticks: {
                        autoSkip: false
                    },
                    gridLines: {
                        display: false,
                    }
                }]
            }
        },
        plugins: []
    }
}

//Funzione per scrivere sulla canvas un testo a piacimento all'interno del grafico di tipo donut
//Eventualmente estendibile per poter scrivere altro testo all'interno di un qualsiasi grafico
const pluginDonutText = (subtitle, data) => {
    // Chart.pluginService.register({
        // beforeDraw: 
        return function (chart) {
          var width = chart.chart.width,
              height = chart.chart.height,
              ctx = chart.chart.ctx;
      
          ctx.restore();
          var fontSize = (height / 200).toFixed(2);
          ctx.font = fontSize + "em sans-serif";
          ctx.textBaseline = "middle";
      
          var text = data,
              textX = Math.round((width - ctx.measureText(text).width) / 2),
              textY = height / 1.9;
      
          ctx.fillText(text, textX, textY);

          ctx.restore();
          ctx.font = '10px sans-serif';
          ctx.fillText(subtitle, 20, 40);
          ctx.save();
        }

    // });
};

/*
* @param parentCssClass, css class name from parent html element that need to append generated canvas
* @param height, height of the canvas, default 60vh
* Genera un elemento di tipo canvas e setta l'altezza
*/
const generateCanvas = function(height){
    const canvas = document.createElement('canvas');
    canvas.height = height != undefined && height != null ? height + 'px' : "60vh";
    canvas.style.width = '100%';
    canvas.style.height = this.height + 'px';
    return canvas;
};

/*
* @param canvas, canvas element to get Context
* ritorna il context della canvas per poter generare il grafico tramite chartjs
*/

const getCanvasContext = (canvas) => {
    return canvas.getContext("2d");
}


const generateDatasetBar = (data, properties, backgroundColor, borderColor) => {
    if(data != undefined){
        let datamap = new Map(Object.entries(data));
        let response = {};
        response.labels = Array.from(datamap.keys());
        response.datasets = [];
        properties.forEach((p,index) => {
            var allCount = 0;
            var modifiedP = '';
            if(p != 'CountID')
                modifiedP = p.substring(0,p.length - 3).replace('_', ' ');
            var newDataset = { data: [], 
                                label: modifiedP, 
                                backgroundColor: backgroundColor[index],
                                borderColor: borderColor[index],
                                borderWidth: 1,
                                datalabels: {
                                    // align: 'start',
                                    align: 'center',
                                    // anchor: 'end'
                                    anchor: 'center',
                                }
                                };
            response.labels.forEach(l => {
                let singleData = 0;
                if(p == 'CountID'){
                    singleData += datamap.get(l).length;
                    allCount += datamap.get(l).length;
                }else
                    datamap.get(l).forEach(d => {
                        singleData += parseFloat(d[p]);
                    })
                singleData = singleData.toFixed(2);
                newDataset.data.push(singleData);
            });
            if(p == 'CountID' && allCount > 0){
                newDataset.data.push(allCount);
            }
            response.datasets.push(newDataset);
        })
        console.log('@@@ response ' , response);
        return response;
    } else
        return null;
}

const generateDatasetBarMultiple = (data, properties, backgroundColor, borderColor) => {
    if(data != undefined){
        let datamap = new Map(Object.entries(data));
        let response = {};
        response.labels = Array.from(datamap.keys());
        response.datasets = [];
        var prevyear = new Date().getFullYear() - 1;
        var year = new Date().getFullYear();

        var dataset1 = {
            data: [], 
            label: prevyear, 
            backgroundColor: backgroundColor[0],
            borderColor: borderColor[0],
            borderWidth: 1,
            datalabels: {
                align: 'start',
                anchor: 'end'
            }
        };
        var dataset2 = {
            data: [], 
            label: year, 
            backgroundColor: backgroundColor[0],
            borderColor: borderColor[0],
            borderWidth: 1,
            datalabels: {
                align: 'center',
                anchor: 'center'
            }
        };
        response.labels.forEach((l, index) => {
            var data1 = 0;
            var data2 = 0;
            datamap.get(l).forEach(d => {
                if(d[properties[0]] == prevyear && d.Mese__c == l)
                    data1++;
                
                if(d[properties[0]] == year && d.Mese__c == l)
                    data2++;
            });

            dataset1.data.push(data1);
            dataset2.data.push(data2);
        });

        response.datasets.push(dataset1);
        response.datasets.push(dataset2);
        response.labels.sort();
        return response;
    } else
        return null;
}

const generateDatasetStackedBar = (data, properties, backgroundColor, borderColor) => {
    let datamap = new Map(Object.entries(data));
    let response = {};
    response.labels = Array.from(datamap.keys());
    response.datasets = [];

    let datasetTypes = new Set();
    response.labels.forEach(l => {
        datamap.get(l).forEach(d => {
            datasetTypes.add(d[properties[0]]);
        });
    })

    datasetTypes = Array.from(datasetTypes);

    datasetTypes.forEach((dt, index) => {
        dt = dt.toString();
        var newDataset = { data: [], 
            label: dt.replace('_',' '), 
            backgroundColor: backgroundColor[index],
            borderColor: borderColor[index],
            borderWidth: 1};
        response.labels.forEach(l => {
            var singleData = 0;
            datamap.get(l).forEach(d => {
                if(d[properties[0]] == dt)
                    singleData += parseFloat(d[properties[1]]);
            });
            singleData = singleData.toFixed(2);
            newDataset.data.push(singleData);
        });
        response.datasets.push(newDataset);
    });

    response.labels = response.labels.map(l => { return l = l.replace('_', ' '); });
    return response;
};

const generateDatasetSingleDoughnut = (data, backgroundColor, borderColor) => {
    if(data != undefined){
        let response = {};
        response.labels = [''];
        response.datasets = [];

        let newDataset = { data: [], 
                label: '', 
                backgroundColor: backgroundColor,
                borderColor: borderColor,
                // backgroundColor: 'rgba(199, 99, 222, 0.2)',
                // borderColor: 'rgba(199, 99, 222, 1)',
                borderWidth: 1,
                // weight: 2
        };
        newDataset.data.push(data);
        response.datasets.push(newDataset);
        return response;
    } else  
        return null;
}

const generateOptionsStackedBar = (options) => {
    if(options != undefined){
        options.scales.xAxes[0].stacked = true;
        options.scales.yAxes[0].stacked = true;
    }
    return options;
}

const generateOptionsDoughnut = (options, title) => {
    if(options != undefined){
        options.legend.display = false;
        options.title = {};
        options.title.display = true;
        options.title.text = title;
        options.cutoutPercentage = 90;
        options.scales.yAxes[0].display = false;
    }

    return options;
}

export { datasetExample, pluginDonutText, generateCanvas, getCanvasContext, generateDatasetBar, generateDatasetBarMultiple, generateOptionsStackedBar, generateDatasetStackedBar, generateDatasetSingleDoughnut, generateOptionsDoughnut };