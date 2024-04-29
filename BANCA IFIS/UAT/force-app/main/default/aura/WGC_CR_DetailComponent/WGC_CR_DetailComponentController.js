({
  doInit: function (component, event, helper) {
    helper.configureWizard(component, event);
    var accId = component.get('v.recordId');
    var allData;

    var arrayAccordatoTOTIfis = [];
    var arrayAccordatoTOTSistema = [];
    var arrayUtilizzatoTOTIfis = [];
    var arrayUtilizzatoTOTSistema = [];
    var arrayTOTIfis = [];
    var arrayTOTSistema = [];
    var arrayAccordatoTOTIfisSistema = [];
    var arrayUtilizzatoTOTIfisSistema = [];

    var arrayAccordatoAutoliquidantiIfis = [];
    var arrayAccordatoAutoliquidantiSistema = [];
    var arrayUtilizzatoAutoliquidantiIfis = [];
    var arrayUtilizzatoAutoliquidantiSistema = [];
    var arrayAutoliquidantiIfis = [];
    var arrayAutoliquidantiSistema = [];
    var arrayAccordatoAutoliquidantiIfisSistema = [];
    var arrayUtilizzatoAutoliquidantiIfisSistema = [];

    var arrayAccordatoRevocaIfis = [];
    var arrayAccordatoRevocaSistema = [];
    var arrayUtilizzatoRevocaIfis = [];
    var arrayUtilizzatoRevocaSistema = [];
    var arrayRevocaIfis = [];
    var arrayRevocaSistema = [];
    var arrayAccordatoRevocaIfisSistema = [];
    var arrayUtilizzatoRevocaIfisSistema = [];

    var arrayAccordatoFirmaIfis = [];
    var arrayAccordatoFirmaSistema = [];
    var arrayUtilizzatoFirmaIfis = [];
    var arrayUtilizzatoFirmaSistema = [];
    var arrayFirmaIfis = [];
    var arrayFirmaSistema = [];
    var arrayAccordatoFirmaIfisSistema = [];
    var arrayUtilizzatoFirmaIfisSistema = [];

    var arrayAccordatoScadenzaIfis = [];
    var arrayAccordatoScadenzaSistema = [];
    var arrayUtilizzatoScadenzaIfis = [];
    var arrayUtilizzatoScadenzaSistema = [];
    var arrayScadenzaIfis = [];
    var arrayScadenzaSistema = [];
    var arrayAccordatoScadenzaIfisSistema = [];
    var arrayUtilizzatoScadenzaIfisSistema = [];


    var nuoviAffidanti    = component.get('v.NuoviAffidanti');
    var primaInfo         = component.get('v.PrimaInfo');
    var segnalanti        = component.get('v.Segnalanti');
    
    var sofferenzeIfis    = component.get('v.SofferenzeIfis');
    var sofferenzeSistema = component.get('v.SofferenzeSistema');

    var arraySconfinoAutoliquidantiIfis = component.get('v.SconfinoAutoliquidantiIfis');
    var arraySconfinoAutoliquidantiSistema = component.get('v.SconfinoAutoliquidantiSistema');
    var arraySconfinoScadenzaIfis = component.get('v.SconfinoScadenzaIfis');
    var arraySconfinoScadenzaSistema = component.get('v.SconfinoScadenzaSistema');
    var arraySconfinoRevocaIfis = component.get('v.SconfinoRevocaIfis');
    var arraySconfinoRevocaSistema = component.get('v.SconfinoRevocaSistema');
    var arraySconfinoFirmaIfis = component.get('v.SconfinoFirmaIfis');
    var arraySconfinoFirmaSistema = component.get('v.SconfinoFirmaSistema');
      
    var arraySconfinoAutoliquidantiIfis_helper = component.get('v.SconfinoAutoliquidantiIfis_helper');
    var arraySconfinoAutoliquidantiSistema_helper = component.get('v.SconfinoAutoliquidantiSistema_helper');
    var arraySconfinoScadenzaIfis_helper = component.get('v.SconfinoScadenzaIfis_helper');
    var arraySconfinoScadenzaSistema_helper = component.get('v.SconfinoScadenzaSistema_helper');
    var arraySconfinoRevocaIfis_helper = component.get('v.SconfinoRevocaIfis_helper');
    var arraySconfinoRevocaSistema_helper = component.get('v.SconfinoRevocaSistema_helper');
    var arraySconfinoFirmaIfis_helper = component.get('v.SconfinoFirmaIfis_helper');
    var arraySconfinoFirmaSistema_helper = component.get('v.SconfinoFirmaSistema_helper');

    var sumCompleto = 0;
    var sumAutoliquidanti = 0;
    var sumRevoca = 0;
    var sumScadenza = 0;
    var sumFirma = 0;

    let debsColumns = [
      {label: $A.get("$Label.c.WGC_Cart_CRDebsTable_Debitore"), fieldName: "debitore", type: "text"},
      {label: $A.get("$Label.c.WGC_Cart_CRDebsTable_DataUltimaRilevazione"), fieldName: "dataUltimaRilevazione", type: "date"},
      {label: $A.get("$Label.c.WGC_Cart_CRDebsTable_DataRichiestaPrimaInfo"), fieldName: "dataRichiesta", type: "date"}
    ];

    component.set("v.debsColumns", debsColumns);

    helper.apex(component, event, 'getAllData', { accountId: accId })
      .then(function (result) {
        console.log('SV result AllData CR: ', result);
        allData = result.data;

        if(result.data.length > 0){
          component.set('v.dataultimaCR', allData[0].dataultimaCR);
          var sumPresenzaSegnalazioni = 0;
          allData.forEach(function(element) {
            console.log('SV PARSE: ', parseInt(element.mese) - 1);
            sumPresenzaSegnalazioni = sumPresenzaSegnalazioni + element.presenza_segnalazioni;
                // code block
                arrayAccordatoTOTIfis[parseInt(element.mese) - 1] = element.ifis.Accordato_TOT_IFIS;
                arrayAccordatoTOTSistema[parseInt(element.mese) - 1] = element.sistema.Accordato_TOT_Sistema;
                arrayUtilizzatoTOTIfis[parseInt(element.mese) - 1] = element.ifis.Utilizzato_TOT_IFIS;
                arrayUtilizzatoTOTSistema[parseInt(element.mese) - 1] = element.sistema.Utilizzato_TOT_Sistema;
                arrayTOTIfis[parseInt(element.mese) - 1] = (element.ifis.Accordato_TOT_IFIS != 0) ? element.ifis.Utilizzato_TOT_IFIS / element.ifis.Accordato_TOT_IFIS * 100 : null;
                arrayTOTSistema[parseInt(element.mese) - 1] = (element.sistema.Accordato_TOT_Sistema != 0) ? element.sistema.Utilizzato_TOT_Sistema / element.sistema.Accordato_TOT_Sistema * 100 : null;
                arrayAccordatoTOTIfisSistema[parseInt(element.mese) - 1] = (element.sistema.Accordato_TOT_Sistema != 0) ? element.ifis.Accordato_TOT_IFIS / element.sistema.Accordato_TOT_Sistema * 100 : null;
                arrayUtilizzatoTOTIfisSistema[parseInt(element.mese) - 1] = (element.sistema.Utilizzato_TOT_Sistema != 0) ? element.ifis.Utilizzato_TOT_IFIS / element.sistema.Utilizzato_TOT_Sistema * 100 : null;
  
                arrayAccordatoAutoliquidantiIfis[parseInt(element.mese) - 1] = element.ifis.Accordato_Autoliquidanti_IFIS;
                arrayAccordatoAutoliquidantiSistema[parseInt(element.mese) - 1] = element.sistema.Accordato_Autoliquidanti_Sistema;
                arrayUtilizzatoAutoliquidantiIfis[parseInt(element.mese) - 1] = element.ifis.Utilizzato_Autoliquidanti_IFIS;
                arrayUtilizzatoAutoliquidantiSistema[parseInt(element.mese) - 1] = element.sistema.Utilizzato_Autoliquidanti_Sistema;
                arrayAutoliquidantiIfis[parseInt(element.mese) - 1] = (element.ifis.Accordato_Autoliquidanti_IFIS != 0) ? element.ifis.Utilizzato_Autoliquidanti_IFIS / element.ifis.Accordato_Autoliquidanti_IFIS * 100 : null;
                arrayAutoliquidantiSistema[parseInt(element.mese) - 1] = (element.sistema.Accordato_Autoliquidanti_Sistema != 0) ? element.sistema.Utilizzato_Autoliquidanti_Sistema / element.sistema.Accordato_Autoliquidanti_Sistema * 100 : null;
                arrayAccordatoAutoliquidantiIfisSistema[parseInt(element.mese) - 1] = (element.sistema.Accordato_Autoliquidanti_Sistema != 0) ? element.ifis.Accordato_Autoliquidanti_IFIS / element.sistema.Accordato_Autoliquidanti_Sistema * 100 : null;
                arrayUtilizzatoAutoliquidantiIfisSistema[parseInt(element.mese) - 1] = (element.sistema.Utilizzato_Autoliquidanti_Sistema != 0) ? element.ifis.Utilizzato_Autoliquidanti_IFIS / element.sistema.Utilizzato_Autoliquidanti_Sistema * 100 : null;
  
                arrayAccordatoRevocaIfis[parseInt(element.mese) - 1] = element.ifis.Accordato_Revoca_IFIS;
                arrayAccordatoRevocaSistema[parseInt(element.mese) - 1] = element.sistema.Accordato_Revoca_Sistema;
                arrayUtilizzatoRevocaIfis[parseInt(element.mese) - 1] = element.ifis.Utilizzato_Revoca_IFIS;
                arrayUtilizzatoRevocaSistema[parseInt(element.mese) - 1] = element.sistema.Utilizzato_Revoca_Sistema;
                arrayRevocaIfis[parseInt(element.mese) - 1] = (element.ifis.Accordato_Revoca_IFIS != 0) ? element.ifis.Utilizzato_Revoca_IFIS / element.ifis.Accordato_Revoca_IFIS * 100 : null;
                arrayRevocaSistema[parseInt(element.mese) - 1] = (element.sistema.Accordato_Revoca_Sistema != 0) ? element.sistema.Utilizzato_Revoca_Sistema / element.sistema.Accordato_Revoca_Sistema * 100 : null;
                arrayAccordatoRevocaIfisSistema[parseInt(element.mese) - 1] = (element.sistema.Accordato_Revoca_Sistema != 0) ? element.ifis.Accordato_Revoca_IFIS / element.sistema.Accordato_Revoca_Sistema * 100 : null;
                arrayUtilizzatoRevocaIfisSistema[parseInt(element.mese) - 1] = (element.sistema.Utilizzato_Revoca_Sistema != 0) ? element.ifis.Utilizzato_Revoca_IFIS / element.sistema.Utilizzato_Revoca_Sistema * 100 : null;
  
                arrayAccordatoFirmaIfis[parseInt(element.mese) - 1] = element.ifis.Accordato_Firma_IFIS;
                arrayAccordatoFirmaSistema[parseInt(element.mese) - 1] = element.sistema.Accordato_Firma_Sistema;
                arrayUtilizzatoFirmaIfis[parseInt(element.mese) - 1] = element.ifis.Utilizzato_Firma_IFIS;
                arrayUtilizzatoFirmaSistema[parseInt(element.mese) - 1] = element.sistema.Utilizzato_Firma_Sistema;
                arrayFirmaIfis[parseInt(element.mese) - 1] = (element.ifis.Accordato_Firma_IFIS != 0) ? element.ifis.Utilizzato_Firma_IFIS / element.ifis.Accordato_Firma_IFIS * 100 : null;
                arrayFirmaSistema[parseInt(element.mese) - 1] = (element.sistema.Accordato_Firma_Sistema != 0) ? element.sistema.Utilizzato_Firma_Sistema / element.sistema.Accordato_Firma_Sistema * 100 : null;
                arrayAccordatoFirmaIfisSistema[parseInt(element.mese) - 1] = (element.sistema.Accordato_Firma_Sistema != 0) ? element.ifis.Accordato_Firma_IFIS / element.sistema.Accordato_Firma_Sistema * 100 : null;
                arrayUtilizzatoFirmaIfisSistema[parseInt(element.mese) - 1] = (element.sistema.Utilizzato_Firma_Sistema != 0) ? element.ifis.Utilizzato_Firma_IFIS / element.sistema.Utilizzato_Firma_Sistema * 100 : null;
  
                arrayAccordatoScadenzaIfis[parseInt(element.mese) - 1] = element.ifis.Accordato_Scadenza_IFIS;
                arrayAccordatoScadenzaSistema[parseInt(element.mese) - 1] = element.sistema.Accordato_Scadenza_Sistema;
                arrayUtilizzatoScadenzaIfis[parseInt(element.mese) - 1] = element.ifis.Utilizzato_Scadenza_IFIS;
                arrayUtilizzatoScadenzaSistema[parseInt(element.mese) - 1] = element.sistema.Utilizzato_Scadenza_Sistema;
                arrayScadenzaIfis[parseInt(element.mese) - 1] = (element.ifis.Accordato_Scadenza_IFIS != 0) ? element.ifis.Utilizzato_Scadenza_IFIS / element.ifis.Accordato_Scadenza_IFIS * 100 : null;
                arrayScadenzaSistema[parseInt(element.mese) - 1] = (element.sistema.Accordato_Scadenza_Sistema != 0) ? element.sistema.Utilizzato_Scadenza_Sistema / element.sistema.Accordato_Scadenza_Sistema * 100 : null;
                arrayAccordatoScadenzaIfisSistema[parseInt(element.mese) - 1] = (element.sistema.Accordato_Scadenza_Sistema != 0) ? element.ifis.Accordato_Scadenza_IFIS / element.sistema.Accordato_Scadenza_Sistema * 100 : null;
                arrayUtilizzatoScadenzaIfisSistema[parseInt(element.mese) - 1] = (element.sistema.Utilizzato_Scadenza_Sistema != 0) ? element.ifis.Utilizzato_Scadenza_IFIS / element.sistema.Utilizzato_Scadenza_Sistema * 100 : null;
  				
                                arraySconfinoAutoliquidantiIfis[parseInt(element.mese) - 1] = element.ifis.Sconfino_Autoliquidanti_IFIS;
                arraySconfinoAutoliquidantiSistema[parseInt(element.mese) - 1] = element.sistema.Sconfino_Autoliquidanti_Sistema;
                arraySconfinoScadenzaIfis[parseInt(element.mese) - 1] = element.ifis.Sconfino_Scadenza_IFIS;
                arraySconfinoScadenzaSistema[parseInt(element.mese) - 1] = element.sistema.Sconfino_Scadenza_Sistema;
                arraySconfinoRevocaIfis[parseInt(element.mese) - 1] = element.ifis.Sconfino_Revoca_IFIS;
                arraySconfinoRevocaSistema[parseInt(element.mese) - 1] = element.sistema.Sconfino_Revoca_Sistema;
                arraySconfinoFirmaIfis[parseInt(element.mese) - 1] = element.ifis.Sconfino_Firma_IFIS;
                arraySconfinoFirmaSistema[parseInt(element.mese) - 1] = element.sistema.Sconfino_Firma_Sistema;
              
               	arraySconfinoAutoliquidantiIfis_helper[parseInt(element.mese) - 1] = new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(element.ifis.Sconfino_Autoliquidanti_IFIS);	
                arraySconfinoAutoliquidantiSistema_helper[parseInt(element.mese) - 1] = new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(element.sistema.Sconfino_Autoliquidanti_Sistema);
                arraySconfinoScadenzaIfis_helper[parseInt(element.mese) - 1] = new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(element.ifis.Sconfino_Scadenza_IFIS);
                arraySconfinoScadenzaSistema_helper[parseInt(element.mese) - 1] = new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(element.sistema.Sconfino_Scadenza_Sistema);
                arraySconfinoRevocaIfis_helper[parseInt(element.mese) - 1] = new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(element.ifis.Sconfino_Revoca_IFIS);
                arraySconfinoRevocaSistema_helper[parseInt(element.mese) - 1] = new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(element.sistema.Sconfino_Revoca_Sistema);
                arraySconfinoFirmaIfis_helper[parseInt(element.mese) - 1] = new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(element.ifis.Sconfino_Firma_IFIS);
                arraySconfinoFirmaSistema_helper[parseInt(element.mese) - 1] = new Intl.NumberFormat('it-IT', { style: 'currency', currency: 'EUR' }).format(element.sistema.Sconfino_Firma_Sistema);
  
              
                nuoviAffidanti[parseInt(element.mese) - 1] = (element.nuoviAffidanti == 0) ? '' : element.nuoviAffidanti;
                primaInfo[parseInt(element.mese) - 1]      = (element.primaInfo == 0) ? '' : element.primaInfo;
                segnalanti[parseInt(element.mese) - 1]     = (element.segnalanti== 0) ? '' : element.segnalanti;
  
                sofferenzeIfis[parseInt(element.mese) - 1] = element.ifis.Sofferenze_IFIS_frm;
                sofferenzeSistema[parseInt(element.mese) - 1] = element.sistema.Sofferenze_Sistema_frm;
  
                sumCompleto = sumCompleto + element.sistema.Accordato_TOT_Sistema;
                sumAutoliquidanti = sumAutoliquidanti + element.sistema.Accordato_Autoliquidanti_Sistema;
                sumScadenza = sumScadenza + element.sistema.Accordato_Scadenza_Sistema;
                sumRevoca = sumRevoca + element.sistema.Accordato_Revoca_Sistema;
                sumFirma = sumFirma + element.sistema.Accordato_Firma_Sistema;
  
                console.log('SV sumCompleto: ', sumCompleto);
                console.log('SV sumAutoliquidanti: ', sumAutoliquidanti);
                console.log('SV sumScadenza: ', sumScadenza);
                console.log('SV sumFirma: ', sumFirma);
                console.log('SV sumRevoca: ', sumRevoca);
  
          });

        }

        
        component.set('v.PresenzaSegnalazione', sumPresenzaSegnalazioni);
        console.log('SV SEGNALATI: ', segnalanti);
        // CHART 1
        component.set('v.AccordatoComplessivoIfis', arrayAccordatoTOTIfis);
        component.set('v.AccordatoComplessivoSistema', arrayAccordatoTOTSistema);
        component.set('v.UtilizzatoComplessivoIfis', arrayUtilizzatoTOTIfis);
        component.set('v.UtilizzatoComplessivoSistema', arrayUtilizzatoTOTSistema);

        component.set('v.AccordatoAutoliquidantiIfis', arrayAccordatoAutoliquidantiIfis);
        component.set('v.AccordatoAutoliquidantiSistema', arrayAccordatoAutoliquidantiSistema);
        component.set('v.UtilizzatoAutoliquidantiIfis', arrayUtilizzatoAutoliquidantiIfis);
        component.set('v.UtilizzatoAutoliquidantiSistema', arrayUtilizzatoAutoliquidantiSistema);

        component.set('v.AccordatoScadenzaIfis', arrayAccordatoScadenzaIfis);
        component.set('v.AccordatoScadenzaSistema', arrayAccordatoScadenzaSistema);
        component.set('v.UtilizzatoScadenzaIfis', arrayUtilizzatoScadenzaIfis);
        component.set('v.UtilizzatoScadenzaSistema', arrayUtilizzatoScadenzaSistema);

        component.set('v.AccordatoRevocaIfis', arrayAccordatoRevocaIfis);
        component.set('v.AccordatoRevocaSistema', arrayAccordatoRevocaSistema);
        component.set('v.UtilizzatoRevocaIfis', arrayUtilizzatoRevocaIfis);
        component.set('v.UtilizzatoRevocaSistema', arrayUtilizzatoRevocaSistema);

        component.set('v.AccordatoFirmaIfis', arrayAccordatoFirmaIfis);
        component.set('v.AccordatoFirmaSistema', arrayAccordatoFirmaSistema);
        component.set('v.UtilizzatoFirmaIfis', arrayUtilizzatoFirmaIfis);
        component.set('v.UtilizzatoFirmaSistema', arrayUtilizzatoFirmaSistema);

       
        // CHART 2
        component.set('v.ComplessivoIfis', arrayTOTIfis);
        component.set('v.ComplessivoSistema', arrayTOTSistema);

        component.set('v.AutoliquidantiIfis', arrayAutoliquidantiIfis);
        component.set('v.AutoliquidantiSistema', arrayAutoliquidantiSistema);

        component.set('v.ScadenzaIfis', arrayScadenzaIfis);
        component.set('v.ScadenzaSistema', arrayScadenzaSistema);

        component.set('v.RevocaIfis', arrayRevocaIfis);
        component.set('v.RevocaSistema', arrayRevocaSistema);

        component.set('v.FirmaIfis', arrayFirmaIfis);
        component.set('v.FirmaSistema', arrayFirmaSistema);


        // CHART 4
        component.set('v.AccordatoComplessivoIfisSistema', arrayAccordatoTOTIfisSistema);

        component.set('v.AccordatoAutoliquidantiIfisSistema', arrayAccordatoAutoliquidantiIfisSistema);

        component.set('v.AccordatoRevocaIfisSistema', arrayAccordatoRevocaIfisSistema);

        component.set('v.AccordatoScadenzaIfisSistema', arrayAccordatoScadenzaIfisSistema);

        component.set('v.AccordatoFirmaiIfisSistema', arrayAccordatoFirmaIfisSistema);


        // CHART 3
        component.set('v.UtilizzatoComplessivoIfisSistema', arrayUtilizzatoTOTIfisSistema);

        component.set('v.UtilizzatoAutoliquidantiIfisSistema', arrayUtilizzatoAutoliquidantiIfisSistema);

        component.set('v.UtilizzatoRevocaIfisSistema', arrayUtilizzatoRevocaIfisSistema);

        component.set('v.UtilizzatoScadenzaIfisSistema', arrayUtilizzatoScadenzaIfisSistema);

        component.set('v.UtilizzatoFirmaIfisSistema', arrayUtilizzatoFirmaIfisSistema);


        // SCONFINO
        component.set('v.SconfinoAutoliquidantiIfis_helper', arraySconfinoAutoliquidantiIfis_helper);
        component.set('v.SconfinoAutoliquidantiSistema_helper', arraySconfinoAutoliquidantiSistema_helper);
        component.set('v.SconfinoScadenzaIfis_helper', arraySconfinoScadenzaIfis_helper);
        component.set('v.SconfinoScadenzaSistema_helper', arraySconfinoScadenzaSistema_helper);
        component.set('v.SconfinoRevocaIfis_helper', arraySconfinoRevocaIfis_helper);
        component.set('v.SconfinoRevocaSistema_helper', arraySconfinoRevocaSistema_helper);
        component.set('v.SconfinoFirmaIfis_helper', arraySconfinoFirmaIfis_helper);
        component.set('v.SconfinoFirmaSistema_helper', arraySconfinoFirmaSistema_helper);
          
        component.set('v.SconfinoAutoliquidantiIfis', arraySconfinoAutoliquidantiIfis);
        component.set('v.SconfinoAutoliquidantiSistema', arraySconfinoAutoliquidantiSistema);
        component.set('v.SconfinoScadenzaIfis', arraySconfinoScadenzaIfis);
        component.set('v.SconfinoScadenzaSistema', arraySconfinoScadenzaSistema);
        component.set('v.SconfinoRevocaIfis', arraySconfinoRevocaIfis);
        component.set('v.SconfinoRevocaSistema', arraySconfinoRevocaSistema);
        component.set('v.SconfinoFirmaIfis', arraySconfinoFirmaIfis);
        component.set('v.SconfinoFirmaSistema', arraySconfinoFirmaSistema);
        // RAPPORTO CON GLI ISTITUTI DI CREDITO
        component.set('v.NuoviAffidanti', nuoviAffidanti);
        component.set('v.PrimaInfo', primaInfo);
        component.set('v.Segnalanti', segnalanti);
        // SOFFERENZE
        component.set('v.SofferenzeIfis', sofferenzeIfis);
        component.set('v.SofferenzeSistema', sofferenzeSistema); 
        
        component.set('v.wizardItems[1].valPerc', sumCompleto > 0 ? parseFloat((sumAutoliquidanti / sumCompleto) * 100).toFixed(1) : null);
        component.set('v.wizardItems[2].valPerc', sumCompleto > 0 ? parseFloat((sumScadenza / sumCompleto) * 100).toFixed(1) : null);
        component.set('v.wizardItems[3].valPerc', sumCompleto > 0 ? parseFloat((sumRevoca / sumCompleto) * 100).toFixed(1) : null);
        component.set('v.wizardItems[4].valPerc', sumCompleto > 0 ? parseFloat((sumFirma / sumCompleto) * 100).toFixed(1) : null);

        // component.set('v.wizardItems[1].disabled', parseFloat((sumAutoliquidanti / sumCompleto) * 100).toFixed(1) > 0 ? false : true);
        // component.set('v.wizardItems[2].disabled', parseFloat((sumScadenza / sumCompleto) * 100).toFixed(1) > 0 ? false : true);
        // component.set('v.wizardItems[3].disabled', parseFloat((sumRevoca / sumCompleto) * 100).toFixed(1) > 0 ? false : true);
        // component.set('v.wizardItems[4].disabled', parseFloat((sumFirma / sumCompleto) * 100).toFixed(1) > 0 ? false : true);

      }).finally($A.getCallback(function () {

        helper.generateChart(helper.dataChart('Autoliquidanti', 1, component, event), helper.optionsChart('Autoliquidanti', 1, component, event), 'bar', 'chartJS_1', component, event);
        helper.generateChart(helper.dataChart('Autoliquidanti', 2, component, event), helper.optionsChart('Autoliquidanti', 2, component, event), 'line', 'chartJS_2', component, event);
        helper.generateChart(helper.dataChart('Autoliquidanti', 3, component, event), helper.optionsChart('Autoliquidanti', 3, component, event), 'line', 'chartJS_3', component, event);
        helper.generateChart(helper.dataChart('Autoliquidanti', 4, component, event), helper.optionsChart('Autoliquidanti', 4, component, event), 'line', 'chartJS_4', component, event);

      }));

      //SM - 19/04/2019
      //Funzione aggiunta per generare i dati della tabella in fondo al componente CR
      helper.generateTable(component, event, helper);
    
  },

  selectWizardItem: function (component, event, helper) {
    helper.selectWizardItem(component, event.getSource().get("v.name"));
  },

  handleToggleChange: function (component, event, helper) {

    var tipoCRTabella = component.get('v.tipoCR');
    if(tipoCRTabella){
    } else {
      var data = {
        labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
        datasets: [
          {
            label: "Africa",
            backgroundColor: 'rgba(73, 144, 226, 0.75)',
            borderColor: 'rgba(73, 144, 226, 1)',
            fill: false,
            data: [15, 25, 53, 23, 38, 17, 33, 21, 11, 10]
          }, {
            label: "Europe",
            backgroundColor: 'rgba(187, 187, 187, 0.75)',
            borderColor: 'rgba(187, 187, 187, 1)',
            fill: false,
            lineTension: 0.3,
            data: [15, 25, 53, 23, 38, 17, 33, 21, 11, 10]
          }
        ]
      };
  
      var chartOptions = {
        responsive: true,
        maintainAspectRatio: false,
        layout: { padding: { top: 0, right: 0, down: 0, lefth: 0 } },
        legend: {
          display: false,
        },
        scales: {
          yAxes: [{
            display: false,
            ticks: {
              reverse: false,
            }
          }],
          xAxes: [{
            display: true,
            gridLines: {
              offsetGridLines: false
            }
          }],
  
        }
      };
  
      var data_2 = {
        labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
        datasets: [
          {
            label: "Africa",
            backgroundColor: 'rgba(73, 144, 226, 0.75)',
            borderColor: 'rgba(73, 144, 226, 1)',
            borderDash: [],
            borderDashOffset: 0.0,
            borderJoinStyle: 'miter',
            pointBorderColor: "rgba(73, 144, 226, 0.75)",
            pointBackgroundColor: "#fff",
            pointBorderWidth: 1,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: "rgba(73, 144, 226, 0.75)",
            pointHoverBorderColor: "rgba(220,220,220,1)",
            pointHoverBorderWidth: 2,
            pointRadius: 5,
            pointHitRadius: 10,
            fill: false,
            data: [15, 25, 53, 23, 38, 17, 33, 21, 11, 10]
          },
          {
            label: "Asia",
            backgroundColor: 'rgba(187, 187, 187, 0.75)',
            borderColor: 'rgba(187, 187, 187, 1)',
            borderDash: [],
            borderDashOffset: 0.0,
            borderJoinStyle: 'miter',
            pointBorderColor: "rgba(187, 187, 187, 0.75)",
            pointBackgroundColor: "#fff",
            pointBorderWidth: 1,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: "rgba(187, 187, 187, 0.75)",
            pointHoverBorderColor: "rgba(220,220,220,1)",
            pointHoverBorderWidth: 2,
            pointRadius: 5,
            pointHitRadius: 10,
            fill: false,
            data: [33, 12, 8, 17, 22, 34, 26, 11, 21, 10]
          }
        ]
      };
  
      var chartOptions_2 = {
        responsive: true,
        maintainAspectRatio: false,
        layout: { padding: { top: 0, right: 30, down: 0, left: 30 } },
        legend: {
          display: false,
        },
        scales: {
          yAxes: [{
            includeZero: false,
            display: false,
            ticks: {
              reverse: true,
            }
          }],
          xAxes: [{
            display: true,
            position: 'top',
            gridLines: {
              offsetGridLines: false
            },
            ticks: {
              display: false //this will remove only the label
            }
          }],
  
        }
      };
  
      var data_3 = {
        labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
        datasets: [
          {
            label: "Utilizzato",
            backgroundColor: 'rgba(73, 144, 226, 0.75)',
            borderColor: 'rgba(73, 144, 226, 1)',
            borderDash: [],
            borderDashOffset: 0.0,
            borderJoinStyle: 'miter',
            pointBorderColor: "rgba(73, 144, 226, 0.75)",
            pointBackgroundColor: "#fff",
            pointBorderWidth: 1,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: "rgba(73, 144, 226, 0.75)",
            pointHoverBorderColor: "rgba(220,220,220,1)",
            pointHoverBorderWidth: 2,
            pointRadius: 5,
            pointHitRadius: 10,
            fill: true,
            data: [15, 25, 53, 23, 38, 17, 33, 21, 11, 10]
          }
        ]
      };
  
      var chartOptions_3 = {
        responsive: true,
        maintainAspectRatio: false,
        layout: { padding: { top: 0, right: 30, down: 0, left: 30 } },
        legend: {
          display: false,
        },
        scales: {
          yAxes: [{
            display: false,
            ticks: {
              reverse: false,
            }
          }],
          xAxes: [{
            display: true,
            gridLines: {
              offsetGridLines: false
            }
          }],
  
        }
      };
  
      var data_4 = {
        labels: [$A.get("$Label.c.WGC_Gennaio"), $A.get("$Label.c.WGC_Febbraio"), $A.get("$Label.c.WGC_Marzo"), $A.get("$Label.c.WGC_Aprile"), $A.get("$Label.c.WGC_Maggio"), $A.get("$Label.c.WGC_Giugno"), $A.get("$Label.c.WGC_Luglio"), $A.get("$Label.c.WGC_Agosto"), $A.get("$Label.c.WGC_Settembre"), $A.get("$Label.c.WGC_Ottobre"), $A.get("$Label.c.WGC_Novembre"), $A.get("$Label.c.WGC_Dicembre")],
        datasets: [
          {
            label: "Accordato",
            backgroundColor: 'rgba(73, 144, 226, 0.75)',
            borderColor: 'rgba(73, 144, 226, 1)',
            borderDash: [],
            borderDashOffset: 0.0,
            borderJoinStyle: 'miter',
            pointBorderColor: "rgba(73, 144, 226, 0.75)",
            pointBackgroundColor: "#fff",
            pointBorderWidth: 1,
            pointHoverRadius: 5,
            pointHoverBackgroundColor: "rgba(73, 144, 226, 0.75)",
            pointHoverBorderColor: "rgba(220,220,220,1)",
            pointHoverBorderWidth: 2,
            pointRadius: 5,
            pointHitRadius: 10,
            fill: true,
            data: [15, 25, 53, 23, 38, 17, 33, 21, 11, 10]
          }
        ]
      };
  
      var chartOptions_4 = {
        responsive: true,
        maintainAspectRatio: false,
        layout: { padding: { top: 0, right: 30, down: 0, left: 30 } },
        legend: {
          display: false,
        },
        scales: {
          yAxes: [{
            display: false,
            ticks: {
              reverse: true,
            },
            // grid line settings
            gridLines: {
              drawOnChartArea: false
            }
          }],
          xAxes: [{
            display: true,
            position: 'top',
            gridLines: {
              offsetGridLines: false
            },
            ticks: {
              display: false //this will remove only the label
            }
          }],
        }
      };
      
      helper.generateChart(data, chartOptions, 'bar', 'chartJS_1', component, event);
      helper.generateChart(data_2, chartOptions_2, 'line', 'chartJS_2', component, event);
      helper.generateChart(data_3, chartOptions_3, 'line', 'chartJS_3', component, event);
      helper.generateChart(data_4, chartOptions_4, 'line', 'chartJS_4', component, event);
    }
  },

  //SM - 19/04/2019
  //Funzione che gestisce l'apertura della tabella
  collapse : function (component, event, helper){
		component.set("v.IsCollapsed", !component.get("v.IsCollapsed"));
  },
    
  goToUrl: function (component, event, helper) {
    var ndg = component.get('v.currentAccount').NDGGruppo__c;

    
    // http://sulboafe/app/rire/#?archLndWks=2033387718&ndg=200933

    var navService = component.find("navService");
    var pageReference = {
      type: "standard__webPage",
      attributes: {
        url: $A.get("$Label.c.WGC_CR_DetailComponent_InfoCR_URL") + ndg
      }
    };
    navService.navigate(pageReference);


  },  

})