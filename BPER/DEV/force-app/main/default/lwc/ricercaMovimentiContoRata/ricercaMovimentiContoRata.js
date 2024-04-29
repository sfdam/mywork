import { LightningElement, track, api, wire } from 'lwc';

import getCustomMetadata from '@salesforce/apex/ricercaMovimentiContoRataController.getCustomMetadata';

export default class RicercaMovimentiContoRata extends LightningElement {
  

    @api recordId;
    @api apiRequests;
    @api certificateName;
    @api disableLog;
    @api requestOnConnectCallback;
    @api jsonParams;
    @api title;
    @api iconName;
    @api isRendered;
    @api isRenderedDataTable=false;    
    @api responseData = [];    
    @api responseColumns;    
    @api rowOffset = 0;
    @api numRows;
    @api numPage;
    @api buttonX= false;
    @api buttonXName;
    @api requestChild;
    @api buttonPage = false;
    @api disabledButtonAvanti = false;
    @api disabledButtonIndietro = false;
    @api buttonCalcolaRata;
    @api buttonRata;
    @api getAllParams;
   
    data = true;
    movimenti=[];
    error;
    date4Month;
  

  entrata = [
      { label: 'Contabile', fieldName:'dataContabile', type:'date-local'},
      { label: 'Valuta', fieldName: 'dataValuta', type:'date-local' },
      { label: 'Movimento', fieldName: 'numeroMovimento', type:'number' },
      { label: 'Causale', fieldName: 'codiceCausale', type:'number' },
      { label: 'Descrizione', fieldName: 'descrizione', type:'text' },
      { label: 'Importo', fieldName: 'importo', type:'number' }
  ];

  uscita = [
    { label: 'Contabile', fieldName: 'dataContabile', type:'date-local' },
      { label: 'Valuta', fieldName: 'dataValuta', type:'date-local' },
      { label: 'Movimento', fieldName: 'numeroMovimento' , type:'number'},
      { label: 'Causale', fieldName: 'codiceCausale', type:'number' },
      { label: 'Descrizione', fieldName: 'descrizione', type:'text' },
      { label: 'Importo', fieldName: 'importo', type:'number' }
];

 dataEntrate = [];
 entrataMovimenti=[];
 uscitaMovimenti=[];
reddito;
@track today;
@track fourMonthsAgo;
@track isRenderdDataRapporto=false;
uscitaMovimenti10=[];
entrataMovimenti10=[];
@track openmodel=false;
@track rapportoStimato;
@track rataStimata;



    
    connectedCallback(){

      console.log('sono nella call:');
      getCustomMetadata({})
      .then(result=>{
        console.log('ccc1 '+ JSON.stringify(result));
        this.movimenti=result;
        console.log('movimenti lista33: ' + result);
        console.log('movimenti lista22: ' + this.movimenti[0].TipoMovimento__c);

      }).catch(error => {
        alert('ERROR');
        this.error = error;
        console.log('SV ERROR', error);
        this.isRendered = true;
      }).finally(() => {
      
        let entrate=[];
        let uscite=[];
       
        this.movimenti.forEach(element => {
          element.TipoMovimento__c === 'Entrata'? entrate.push(element.CodiceCasuale__c):uscite.push(element.CodiceCasuale__c);
        });
        console.log('entrata: '+ entrate);
        console.log('uscita: '+ uscite);

        let entrataMovimenti=[];
        let uscitaMovimenti=[];
        let reddito=0;
        let contatorePerMedia=0;
        let redditoMedia=0;
        let entrataMovimenti10=[];
        let uscitaMovimenti10=[];
        let contatoreEntrataMovimenti10=0;
        let contatoreUscitaMovimenti10=0;
        
        

        this.allParams.listaMovimentiConto.movimentiConto.forEach(element => {
          if(entrate.indexOf(element.codiceCausale) > -1 ){
            if(element.codiceCausale === '00048'|| element.codiceCausale === '00005' ){
              
              reddito = reddito + element.importo;
              contatorePerMedia++;
              console.log('sono nell if per cod causale  ');
            }
            if(contatoreEntrataMovimenti10 <= 9){
              contatoreEntrataMovimenti10++;
              entrataMovimenti10.push(element);
            }
            entrataMovimenti.push(element);
            
          }else if(uscite.indexOf(element.codiceCausale) >-1){
            if(contatoreUscitaMovimenti10 <= 9){
              contatoreUscitaMovimenti10++;
              uscitaMovimenti10.push(element);
            }
            uscitaMovimenti.push(element);
            
          }
           
          });

          if(contatorePerMedia > 0){

            this.isRenderdDataRapporto= true;

          }

          console.log('contatoreEntrataMov '+contatoreEntrataMovimenti10);
          console.log('contatoreUscitaMov '+contatoreUscitaMovimenti10);
          redditoMedia= reddito/contatorePerMedia;
          this.rapportoStimato = this.rataStimata/redditoMedia;

          console.log('redditoMedia '+redditoMedia);
          console.log('reddito '+reddito);
          console.log('contatorePerMedia '+contatorePerMedia);
          
          this.entrataMovimenti = entrataMovimenti;
          this.uscitaMovimenti = uscitaMovimenti;
          this.entrataMovimenti10 = entrataMovimenti10;
          this.uscitaMovimenti10 = uscitaMovimenti10;

          console.log('entrata movimenti ' + JSON.stringify(entrataMovimenti));
          console.log('uscita movimenti ' + JSON.stringify(uscitaMovimenti));
         
            console.log('data quattro mesi fa: '+ this.fourMonthsAgo);
            console.log('oggi: '+ this.today);

        

      });

      let todayDate = new Date();
      this.today=todayDate.getFullYear()  + "-" + (todayDate.getMonth()+1) + "-" + todayDate.getDate();
      let fourMonthsAgoDate = new Date();
      fourMonthsAgoDate.setMonth(fourMonthsAgoDate.getMonth() - 4);
      this.fourMonthsAgo = fourMonthsAgoDate.getFullYear() + "-" + (fourMonthsAgoDate.getMonth() + 1) + "-" + fourMonthsAgoDate.getDate();

      
    }


    

    handleSendRequest(event){
      console.log('sono dentro handle send requedst');
      this.isRenderedDataTable= true;

    
    }

    openModal() {
      this.openmodel = true;
  }

  closeModal() {
      this.openmodel = false;
  } 


    handleRefresh(event){
      console.log('X', this.getAllParams);
      console.log('Y', JSON.parse(this.jsonParams));
      let restore = JSON.parse(this.jsonParams);
      restore.forEach(element => {
        this.template.querySelector("[data-item='" + element.key + "']").value = element.hasOwnProperty('value') ? element.value : null;
        this.getAllParams.forEach(par => {
          if(par.key == element.key) par.value = element.hasOwnProperty('value') ? element.value : null;
        });
      });
    }


    allParams= 
    {
      "paginazione" : {
        "NumeroMaxElementiPerPagina" : 50,
        "numeroPagina" : 1
      },
      "dataAggiornamento" : "2023-01-12T00:11:41.000+01:00",
      "saldoFinale" : 0.000,
      "saldoIniziale" : 0.000,
      "listaMovimentiConto" : {
        "movimentiConto" : [ {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00045",
          "descrizione" : "PAGAMENTO CARTA DI CREDITO ADDEBITO E/C DEL 30.11.2021 PER LA CARTA N. 4117********7778",
          "dataValuta" : "2021-12-13T00:00:00.000+01:00",
          "importo" : -1798.800,
          "numeroMovimento" : "497918600000001",
          "dataContabile" : "2021-12-13T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00446",
          "descrizione" : "COMM. BON. ISTANTANEO a favore di Alessandro Pizzileo EUR 250,00 ricarica Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213446066006260-641290512900IT05387-RIF. 21344/6006263",
          "dataValuta" : "2021-12-10T00:00:00.000+01:00",
          "importo" : -0.900,
          "numeroMovimento" : "652449300000001",
          "dataContabile" : "2021-12-10T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00626",
          "descrizione" : "DISPOSIZIONE BONIFICO ISTANTANEO a favore di Alessandro Pizzileo EUR 250,00 ricarica Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213446066006260-641290512900IT05387-RIF. 21344/6006263",
          "dataValuta" : "2021-12-10T00:00:00.000+01:00",
          "importo" : -250.000,
          "numeroMovimento" : "652449200000001",
          "dataContabile" : "2021-12-10T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: SASSUOLO PADEL MDS S.R.L.SASSUOLO IT in data:30/11/2021 rif. 7493500133518356881",
          "dataValuta" : "2021-11-30T00:00:00.000+01:00",
          "importo" : -11.000,
          "numeroMovimento" : "585955700000001",
          "dataContabile" : "2021-12-03T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00048",
          "descrizione" : "BONIFICO o/c: PIZZILEO ALESSANDRO ABI-CAB: 36081-05138 a favore di Alessandro Pizzileo Beatrice Magnin Num. Bon.Sepa 213361000153469giroconto 1.976,00 EUR Spese: 0,00 EUR -RIF. 21336/0219417",
          "dataValuta" : "2021-12-02T00:00:00.000+01:00",
          "importo" : 1976.000,
          "numeroMovimento" : "394303600000001",
          "dataContabile" : "2021-12-02T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: FARMACIA CENTRO COMME.. MODENA IT in data:30/11/2021 rif. 7416590133505591779",
          "dataValuta" : "2021-11-30T00:00:00.000+01:00",
          "importo" : -15.000,
          "numeroMovimento" : "236991700000001",
          "dataContabile" : "2021-12-02T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: LA BARACCHINA SNC MODENA IT in data:30/11/2021 rif. 7416590133505591764",
          "dataValuta" : "2021-11-30T00:00:00.000+01:00",
          "importo" : -18.500,
          "numeroMovimento" : "236991600000001",
          "dataContabile" : "2021-12-02T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: COUNTRY SPORT VILLAGE PADERNO DUGNAIT in data:27/11/2021 rif. 7413507133311300013",
          "dataValuta" : "2021-11-27T00:00:00.000+01:00",
          "importo" : -8.000,
          "numeroMovimento" : "746798500000001",
          "dataContabile" : "2021-12-01T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: COUNTRY SPORT VILLAGE PADERNO DUGNAIT in data:28/11/2021 rif. 7413507133327600011",
          "dataValuta" : "2021-11-28T00:00:00.000+01:00",
          "importo" : -24.000,
          "numeroMovimento" : "746798400000001",
          "dataContabile" : "2021-12-01T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: COUNTRY SPORT VILLAGE PADERNO DUGNAIT in data:28/11/2021 rif. 7413507133327600011",
          "dataValuta" : "2021-11-28T00:00:00.000+01:00",
          "importo" : -6.500,
          "numeroMovimento" : "746798300000001",
          "dataContabile" : "2021-12-01T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: PASTICCERIA SAN CARLO DI BRESCIA IT in data:27/11/2021 rif. 7413507133305900010",
          "dataValuta" : "2021-11-27T00:00:00.000+01:00",
          "importo" : -30.500,
          "numeroMovimento" : "746798200000001",
          "dataContabile" : "2021-12-01T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: COUNTRY SPORT VILLAGE PADERNO DUGNAIT in data:27/11/2021 rif. 7413507133311300013",
          "dataValuta" : "2021-11-27T00:00:00.000+01:00",
          "importo" : -3.500,
          "numeroMovimento" : "746798100000001",
          "dataContabile" : "2021-12-01T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: COUNTRY SPORT VILLAGE PADERNO DUGNAIT in data:28/11/2021 rif. 7493500133318335462",
          "dataValuta" : "2021-11-28T00:00:00.000+01:00",
          "importo" : -6.500,
          "numeroMovimento" : "746798000000001",
          "dataContabile" : "2021-12-01T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: FARMACIA BUATIER SNC TEL BRESCIA IT in data:27/11/2021 rif. 7434898133202100275",
          "dataValuta" : "2021-11-27T00:00:00.000+01:00",
          "importo" : -15.000,
          "numeroMovimento" : "277002000000001",
          "dataContabile" : "2021-11-30T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00012",
          "descrizione" : "ADDEBITO SDD TELEPASS PAY N: 754262775/10 ID:CGBUR40000000224178084 SALDO DOCUM.029373635,029508369DEL 30.11.202 1 DEB: PIZZILEO ALESSANDRO",
          "dataValuta" : "2021-11-30T00:00:00.000+01:00",
          "importo" : -341.060,
          "numeroMovimento" : "219196300000001",
          "dataContabile" : "2021-11-30T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00012",
          "descrizione" : "ADDEBITO SDD TELEPASS PAY N: 754254069/02 ID:CGBUR40000000224199999 SALDO DOCUM.029168357DEL 30.11.2021 DEB: MAGNINO BEATRICE",
          "dataValuta" : "2021-11-30T00:00:00.000+01:00",
          "importo" : -1.240,
          "numeroMovimento" : "219196200000001",
          "dataContabile" : "2021-11-30T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00043",
          "descrizione" : "PAGAMENTO CIRC. PAGOBANCOMAT Operazione Carta nr:02222063 eseguita il 28/11/2021 alle ore 12:28 c/o:47653 BRESCIA - VIA DUC, BRESCIA BS",
          "dataValuta" : "2021-11-28T00:00:00.000+01:00",
          "importo" : -49.750,
          "numeroMovimento" : "938648400000001",
          "dataContabile" : "2021-11-29T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00446",
          "descrizione" : "COMM. BON. ISTANTANEO a favore di Alessandro Pizzileo EUR 500,00 posta Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213336061852922-641290512900IT05387-RIF. 21333/6852925",
          "dataValuta" : "2021-11-28T00:00:00.000+01:00",
          "importo" : -0.900,
          "numeroMovimento" : "733459900000001",
          "dataContabile" : "2021-11-29T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00626",
          "descrizione" : "DISPOSIZIONE BONIFICO ISTANTANEO a favore di Alessandro Pizzileo EUR 500,00 posta Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213336061852922-641290512900IT05387-RIF. 21333/6852925",
          "dataValuta" : "2021-11-28T00:00:00.000+01:00",
          "importo" : -500.000,
          "numeroMovimento" : "733459800000001",
          "dataContabile" : "2021-11-29T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00446",
          "descrizione" : "COMM. BON. ISTANTANEO a favore di Alessandro Pizzileo EUR 300,00 giroconto Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213336062247028-641290512900IT05387-RIF. 21333/6247031",
          "dataValuta" : "2021-11-29T00:00:00.000+01:00",
          "importo" : -0.900,
          "numeroMovimento" : "149283600000001",
          "dataContabile" : "2021-11-29T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00626",
          "descrizione" : "DISPOSIZIONE BONIFICO ISTANTANEO a favore di Alessandro Pizzileo EUR 300,00 giroconto Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213336062247028-641290512900IT05387-RIF. 21333/6247031",
          "dataValuta" : "2021-11-29T00:00:00.000+01:00",
          "importo" : -300.000,
          "numeroMovimento" : "149283500000001",
          "dataContabile" : "2021-11-29T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00446",
          "descrizione" : "COMM. BON. ISTANTANEO a favore di Alessandro Pizzileo EUR 300,00 postepay Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213306061507789-641290512900IT05387-RIF. 21330/6507792",
          "dataValuta" : "2021-11-26T00:00:00.000+01:00",
          "importo" : -0.900,
          "numeroMovimento" : "538639000000001",
          "dataContabile" : "2021-11-26T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00626",
          "descrizione" : "DISPOSIZIONE BONIFICO ISTANTANEO a favore di Alessandro Pizzileo EUR 300,00 postepay Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213306061507789-641290512900IT05387-RIF. 21330/6507792",
          "dataValuta" : "2021-11-26T00:00:00.000+01:00",
          "importo" : -300.000,
          "numeroMovimento" : "538638900000001",
          "dataContabile" : "2021-11-26T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: SASSUOLO PADEL MDS S.R.L.SASSUOLO IT in data:22/11/2021 rif. 7493500132718276545",
          "dataValuta" : "2021-11-22T00:00:00.000+01:00",
          "importo" : -11.000,
          "numeroMovimento" : "967170600000001",
          "dataContabile" : "2021-11-25T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: VIAEMILIA PADEL ACADEMY SMODENA IT in data:22/11/2021 rif. 7493500132713276808",
          "dataValuta" : "2021-11-22T00:00:00.000+01:00",
          "importo" : -27.000,
          "numeroMovimento" : "967170500000001",
          "dataContabile" : "2021-11-25T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: LA BARACCHINA SNC MODENA IT in data:23/11/2021 rif. 7416590132805544984",
          "dataValuta" : "2021-11-23T00:00:00.000+01:00",
          "importo" : -15.000,
          "numeroMovimento" : "967170400000001",
          "dataContabile" : "2021-11-25T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00446",
          "descrizione" : "COMM. BON. ISTANTANEO a favore di Alessandro Pizzileo EUR 300,00 postepay Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213296061142841-641290512900IT05387-RIF. 21329/6142844",
          "dataValuta" : "2021-11-25T00:00:00.000+01:00",
          "importo" : -0.900,
          "numeroMovimento" : "128417400000001",
          "dataContabile" : "2021-11-25T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00626",
          "descrizione" : "DISPOSIZIONE BONIFICO ISTANTANEO a favore di Alessandro Pizzileo EUR 300,00 postepay Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213296061142841-641290512900IT05387-RIF. 21329/6142844",
          "dataValuta" : "2021-11-25T00:00:00.000+01:00",
          "importo" : -300.000,
          "numeroMovimento" : "128417300000001",
          "dataContabile" : "2021-11-25T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00048",
          "descrizione" : "BONIFICO o/c: GABBIANI LAURA ABI-CAB: 05387-11210 a favore di Alessandro Pizzileo Beatrice Magnin Num. Bon.Sepa 213296061026486Aggiunta bonifico precedente 2.500,00 EUR Spese: 0,00 EUR -RIF. 21329/6026487",
          "dataValuta" : "2021-11-25T00:00:00.000+01:00",
          "importo" : 2500.000,
          "numeroMovimento" : "128417200000001",
          "dataContabile" : "2021-11-25T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00446",
          "descrizione" : "COMM. BON. ISTANTANEO a favore di Alessandro Pizzileo EUR 100,00 saldo Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213286060759793-641290512900IT05387-RIF. 21328/6759796",
          "dataValuta" : "2021-11-23T00:00:00.000+01:00",
          "importo" : -0.900,
          "numeroMovimento" : "724420200000001",
          "dataContabile" : "2021-11-24T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00626",
          "descrizione" : "DISPOSIZIONE BONIFICO ISTANTANEO a favore di Alessandro Pizzileo EUR 100,00 saldo Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213286060759793-641290512900IT05387-RIF. 21328/6759796",
          "dataValuta" : "2021-11-23T00:00:00.000+01:00",
          "importo" : -100.000,
          "numeroMovimento" : "724420100000001",
          "dataContabile" : "2021-11-24T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: PANINO GIUSTO V.MALPIGHI MILANO IT in data:21/11/2021 rif. 7434495132516991817",
          "dataValuta" : "2021-11-21T00:00:00.000+01:00",
          "importo" : -21.900,
          "numeroMovimento" : "413682000000001",
          "dataContabile" : "2021-11-23T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00446",
          "descrizione" : "COMM. BON. ISTANTANEO a favore di Alessandro Pizzileo EUR 200,00 giro Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213266060022295-641290512900IT05387-RIF. 21326/6022298",
          "dataValuta" : "2021-11-21T00:00:00.000+01:00",
          "importo" : -0.900,
          "numeroMovimento" : "943172200000001",
          "dataContabile" : "2021-11-22T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00626",
          "descrizione" : "DISPOSIZIONE BONIFICO ISTANTANEO a favore di Alessandro Pizzileo EUR 200,00 giro Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213266060022295-641290512900IT05387-RIF. 21326/6022298",
          "dataValuta" : "2021-11-21T00:00:00.000+01:00",
          "importo" : -200.000,
          "numeroMovimento" : "943172100000001",
          "dataContabile" : "2021-11-22T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: POLIAMBULATORIO CASTELLO CASTELFRANCO IT in data:17/11/2021 rif. 7493500132218226257",
          "dataValuta" : "2021-11-17T00:00:00.000+01:00",
          "importo" : -20.700,
          "numeroMovimento" : "930434700000001",
          "dataContabile" : "2021-11-22T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00043",
          "descrizione" : "PAGAMENTO CIRC. PAGOBANCOMAT Operazione Carta nr:02222063 eseguita il 19/11/2021 alle ore 20:05 c/o:TAMOIL 2090, MODENA",
          "dataValuta" : "2021-11-19T00:00:00.000+01:00",
          "importo" : -51.520,
          "numeroMovimento" : "223140100000001",
          "dataContabile" : "2021-11-22T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00087",
          "descrizione" : "PRELIEVO ATM AZIENDALE Carta nr:02222063 eseguito il 19/11/2021 alle ore 13:03 c/o:MODENA AG. 7",
          "dataValuta" : "2021-11-19T00:00:00.000+01:00",
          "importo" : -320.000,
          "numeroMovimento" : "099005300000001",
          "dataContabile" : "2021-11-22T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00446",
          "descrizione" : "COMM. BON. ISTANTANEO a favore di Alessandro Pizzileo EUR 300,00 carta Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213236069541438-641290512900IT05387-RIF. 21323/6541445",
          "dataValuta" : "2021-11-18T00:00:00.000+01:00",
          "importo" : -0.900,
          "numeroMovimento" : "635079800000001",
          "dataContabile" : "2021-11-19T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00626",
          "descrizione" : "DISPOSIZIONE BONIFICO ISTANTANEO a favore di Alessandro Pizzileo EUR 300,00 carta Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213236069541438-641290512900IT05387-RIF. 21323/6541445",
          "dataValuta" : "2021-11-18T00:00:00.000+01:00",
          "importo" : -300.000,
          "numeroMovimento" : "635079700000001",
          "dataContabile" : "2021-11-19T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: FARMACIA CENTRO COMMERCIAMODENA IT in data:16/11/2021 rif. 7493500132113216851",
          "dataValuta" : "2021-11-16T00:00:00.000+01:00",
          "importo" : -15.000,
          "numeroMovimento" : "613937000000001",
          "dataContabile" : "2021-11-19T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: SUPERMERCATO COOP MODENA-MODENA IT in data:16/11/2021 rif. 7493500132118216282",
          "dataValuta" : "2021-11-16T00:00:00.000+01:00",
          "importo" : -15.480,
          "numeroMovimento" : "613936900000001",
          "dataContabile" : "2021-11-19T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: PASTICCERIA REMONDINI MODENA IT in data:14/11/2021 rif. 7493500131918195333",
          "dataValuta" : "2021-11-14T00:00:00.000+01:00",
          "importo" : -13.700,
          "numeroMovimento" : "087006000000001",
          "dataContabile" : "2021-11-17T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00446",
          "descrizione" : "COMM. BON. ISTANTANEO a favore di Alessandro Pizzileo EUR 250,00 giroconto Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213206068775612-641290512900IT05387-RIF. 21320/6775615",
          "dataValuta" : "2021-11-16T00:00:00.000+01:00",
          "importo" : -0.900,
          "numeroMovimento" : "956073900000001",
          "dataContabile" : "2021-11-16T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00626",
          "descrizione" : "DISPOSIZIONE BONIFICO ISTANTANEO a favore di Alessandro Pizzileo EUR 250,00 giroconto Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213206068775612-641290512900IT05387-RIF. 21320/6775615",
          "dataValuta" : "2021-11-16T00:00:00.000+01:00",
          "importo" : -250.000,
          "numeroMovimento" : "956073800000001",
          "dataContabile" : "2021-11-16T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00043",
          "descrizione" : "PAGAMENTO CIRC. PAGOBANCOMAT Operazione Carta nr:02222063 eseguita il 15/11/2021 alle ore 20:29 c/o:DISTRIBUTORE SELF AREA, FORMIGINE",
          "dataValuta" : "2021-11-15T00:00:00.000+01:00",
          "importo" : -44.640,
          "numeroMovimento" : "905286300000001",
          "dataContabile" : "2021-11-16T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00196",
          "descrizione" : "PAGAMENTO SU CIRCUITO INTERNAZIONALE Carta nr:02222063 c/o: RISTORANTE UVA D'ORO S.R.MODENA IT in data:14/11/2021 rif. 7413507131906800018",
          "dataValuta" : "2021-11-14T00:00:00.000+01:00",
          "importo" : -60.000,
          "numeroMovimento" : "686498200000001",
          "dataContabile" : "2021-11-16T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00446",
          "descrizione" : "COMM. BON. ISTANTANEO a favore di Alessandro Pizzileo EUR 250,00 giroconto carta Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213156067247717-641290512900IT05387-RIF. 21315/6247720",
          "dataValuta" : "2021-11-11T00:00:00.000+01:00",
          "importo" : -0.900,
          "numeroMovimento" : "655673900000001",
          "dataContabile" : "2021-11-11T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00626",
          "descrizione" : "DISPOSIZIONE BONIFICO ISTANTANEO a favore di Alessandro Pizzileo EUR 250,00 giroconto carta Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213156067247717-641290512900IT05387-RIF. 21315/6247720",
          "dataValuta" : "2021-11-11T00:00:00.000+01:00",
          "importo" : -250.000,
          "numeroMovimento" : "655673800000001",
          "dataContabile" : "2021-11-11T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00045",
          "descrizione" : "PAGAMENTO CARTA DI CREDITO ADDEBITO E/C DEL 29.10.2021 PER LA CARTA N. 4117********7778",
          "dataValuta" : "2021-11-11T00:00:00.000+01:00",
          "importo" : -2020.040,
          "numeroMovimento" : "082548700000001",
          "dataContabile" : "2021-11-11T00:00:00.000+01:00"
        }, {
          "codiceCategoria" : null,
          "nota" : null,
          "progressivo" : null,
          "descrizioneTipo" : null,
          "codiceTipo" : null,
          "codiceCausale" : "00446",
          "descrizione" : "COMM. BON. ISTANTANEO a favore di Alessandro Pizzileo EUR 250,00 giroconto Comm. di maggiorazione : 0,90 EUR Num. Bonifico 213136066365045-641290522700IT05387-RIF. 21313/6365048",
          "dataValuta" : "2021-11-09T00:00:00.000+01:00",
          "importo" : -0.900,
          "numeroMovimento" : "808906200000001",
          "dataContabile" : "2021-11-09T00:00:00.000+01:00"
        } ],
        "numeroElementiTotali" : 114
      }
    }
  }