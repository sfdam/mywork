import { LightningElement, track, api } from "lwc";

// Import ToastEvent
import { ShowToastEvent } from "lightning/platformShowToastEvent";

// Import Controller Methods
import getDate from "@salesforce/apex/ReadCSVFileController.getDate";
import saveRecords from "@salesforce/apex/ReadCSVFileController.saveRecords";
import saveLeads from "@salesforce/apex/ReadCSVFileController.saveLeads";

// Import custom labels
import infoLoad from "@salesforce/label/c.ReadCSVFileInfoLoad";
import errorCSV from "@salesforce/label/c.ReadCSVFileErrorCSV";
import buttonCreateRecord from "@salesforce/label/c.ReadCSVFileButtonCreateRecord";
import buttonCreateLead from "@salesforce/label/c.ReadCSVFileButtonCreateLead";
import titleTableRecord from "@salesforce/label/c.ReadCSVFileTitleTableRecord";
import titleTableLead from "@salesforce/label/c.ReadCSVFileTitleTableLead";

// Import Navigation
import { NavigationMixin } from "lightning/navigation";

export default class ReadCSVFile extends NavigationMixin(LightningElement) {
  @api recordId;

  actions = [{ label: "Mostra Dettaglio", name: "show_details" }];

  @track columns = [
    {
      label: "Id",
      fieldName: "id",
      type: "text",
      sortable: false
    },
    {
      label: "Name",
      fieldName: "name",
      type: "text",
      sortable: true
    },
    {
      label: "Codice Fiscale",
      fieldName: ["codice_fiscale__c"],
      type: "text",
      sortable: true
    },
    {
      label: "Partita Iva",
      fieldName: "partita_iva__c",
      type: "text",
      sortable: true
    },
    {
      label: "Responsabile",
      fieldName: "responsabile",
      type: "text",
      sortable: true
    },
    {
      label: "Object",
      fieldName: "ObjectType",
      type: "text",
      sortable: true
    },
    {
      label: "N. Eventi",
      fieldName: "numevent",
      type: "number",
      sortable: true
    },
    {
      label: "Data Ultimo Evento",
      fieldName: "eventlastdate",
      type: "date-local",
      typeAttributes: {
        month: "2-digit",
        day: "2-digit"
      },
      sortable: true
    },
    {
      label: "N. Opp Vinte",
      fieldName: "numoppwon",
      type: "number",
      sortable: true
    },
    {
      label: "N. Opp Perse",
      fieldName: "numopplost",
      type: "number",
      sortable: true
    },
    {
      label: "N. Opp Aperte",
      fieldName: "numoppopen",
      type: "number",
      sortable: true
    },
    {
      type: "action",
      typeAttributes: { rowActions: this.actions }
    }
  ];

  @track leftOverColumns = [
    {
      label: "Nome",
      fieldName: "nome",
      type: "text",
      sortable: false
    },
    {
      label: "Cognome",
      fieldName: "cognome",
      type: "text",
      sortable: false
    },
    {
      label: "Company",
      fieldName: "company",
      type: "text",
      sortable: false
    },
    {
      label: "Partita Iva",
      fieldName: "iva",
      type: "text",
      sortable: false
    },
    {
      label: "Codici Fiscali",
      fieldName: "cf",
      type: "text",
      sortable: false
    }
  ];

  @track CFcolumns = [
    {
      label: "Codici Fiscali non trovati",
      fieldName: "codiceFiscale",
      type: "text",
      sortable: false,
      fixedWidth: "474px"
    }
  ];

  @track error;
  @track isButtonDisabled = false;
  @track data;
  @track loaded = true;

  @track leftOver;
  @track selectedRows;

  // Expose the labels to use in the template.
  label = {
    infoLoad,
    errorCSV,
    buttonCreateRecord,
    buttonCreateLead,
    titleTableRecord,
    titleTableLead
  };

  // accepted parameters
  get acceptedFormats() {
    return [".csv"];
  }

  handleUploadFinished(event) {
    // Get the list of uploaded files
    this.loaded = !this.loaded;

    var sal = this;
    const uploadedFiles = event.detail.files;

    console.log(uploadedFiles);
    var tabledata = [];
    var reader = new FileReader();
    reader.readAsText(uploadedFiles[0], "UTF-8");

    reader.onload = function (event) {
      var csv = event.target.result;
      var rows = csv.split("\n"); //righe

      var trimrow = rows[0]
        .replace("__c", "")
        .replace(/[^a-zA-Z,]/g, "")
        .split(",");
      console.log("trimrow: ", trimrow);

      var cfIvaObj = [];
      var codFisc = [];
      var pIva = [];
      var idCF_PIvaList = [];
      var cfIndex = null;
      var piIndex = null;
      var nomeIndex = null;
      var cognomeIndex = null;
      var companyIndex = null;
      for (var i = 0; i < trimrow.length; i++) {
        if (trimrow[i].toLowerCase() == "codicefiscale") {
          cfIndex = i;
        }
        if (trimrow[i].toLowerCase() == "partitaiva") {
          piIndex = i;
        }
        if (trimrow[i].toLowerCase() == "nome") {
          nomeIndex = i;
        }
        if (trimrow[i].toLowerCase() == "cognome") {
          cognomeIndex = i;
        }
        if (trimrow[i].toLowerCase() == "company") {
          companyIndex = i;
        }
      }

      if (
        cfIndex == null ||
        piIndex == null ||
        cognomeIndex == null ||
        companyIndex == null
      ) {
        sal.error = sal.label.errorCSV;
        sal.isButtonDisabled = true;
      } else {
        sal.error = null;
        sal.isButtonDisabled = false;
      }

      for (var j = 1; j < rows.length - 1; j++) {
        var cells = rows[j].split(",");
        cfIvaObj.push({
          iva:
            piIndex != null ? cells[piIndex].replace(/[^a-zA-Z0-9,]/g, "") : "",
          cf:
            cfIndex != null ? cells[cfIndex].replace(/[^a-zA-Z0-9,]/g, "") : "",
          nome:
            nomeIndex != null
              ? cells[nomeIndex].replace(/[^a-zA-Z0-9,]/g, "")
              : "",
          cognome:
            cognomeIndex != null
              ? cells[cognomeIndex].replace(/[^a-zA-Z0-9,]/g, "")
              : "",
          company:
            companyIndex != null
              ? cells[companyIndex].replace(/[^a-zA-Z0-9,]/g, "")
              : ""
        });

        if (cfIndex != null)
          codFisc.push(cells[cfIndex].replace(/[^a-zA-Z0-9,]/g, ""));
        if (piIndex != null)
          pIva.push(cells[piIndex].replace(/[^a-zA-Z0-9,]/g, ""));
        idCF_PIvaList.push(
          cells[cfIndex].replace(/[^a-zA-Z0-9,]/g, "") +
            "_" +
            cells[piIndex].replace(/[^a-zA-Z0-9,]/g, "")
        );
      }

      pIva = pIva.filter(Boolean);
      codFisc = codFisc.filter(Boolean);

      console.log("idCF_PIvaList: ", idCF_PIvaList);
      // calling apex class
      // getDate({idCFList : codFisc, idPIvaList : pIva})
      getDate({ idCF_PIvaList: idCF_PIvaList })
        .then((result) => {
          console.log("result: ", result);
          var dataList = [];
          for (var key in result.mergeMap) {
            // skip loop if the property is from prototype
            if (!result.mergeMap.hasOwnProperty(key)) continue;

            var obj = result.mergeMap[key];
            obj.Responsabile = obj.Owner.Name;

            var numEvents = 0;
            var numOppOpen = 0;
            var numOppWon = 0;
            var numOppLost = 0;
            var EventLastDate = null;
            if (obj.Id.startsWith("001")) {
              if (obj.Partita_iva__c == null || obj.Partita_iva__c == undefined)
                obj.Partita_iva__c = "";
              if (
                obj.Codice_fiscale__c == null ||
                obj.Codice_fiscale__c == undefined
              )
                obj.Codice_fiscale__c = "";

              if (cfIvaObj.findIndex((x) => x.iva == obj.Partita_iva__c) != -1)
                cfIvaObj.splice(
                  cfIvaObj.findIndex((x) => x.iva == obj.Partita_iva__c),
                  1
                );
              if (
                cfIvaObj.findIndex((x) => x.cf == obj.Codice_fiscale__c) != -1
              )
                cfIvaObj.splice(
                  cfIvaObj.findIndex((x) => x.cf == obj.Codice_fiscale__c),
                  1
                );
              if (codFisc.indexOf(obj.Codice_fiscale__c) != -1)
                codFisc.splice(codFisc.indexOf(obj.Codice_fiscale__c), 1);
              if (pIva.indexOf(obj.Partita_iva__c) != -1)
                pIva.splice(pIva.indexOf(obj.Partita_iva__c), 1);

              for (var keyOpp in result.oppToAccMap) {
                if (keyOpp.includes(key)) {
                  if (result.oppToAccMap[keyOpp].IsWon) numOppWon++;
                  else if (
                    result.oppToAccMap[keyOpp].IsClosed &&
                    !result.oppToAccMap[keyOpp].IsWon
                  )
                    numOppLost++;
                  else if (!result.oppToAccMap[keyOpp].IsClosed) numOppOpen++;
                }
              }

              var execute = false;
              for (var keyEvent in result.eToAccMap) {
                if (keyEvent.includes(key)) {
                  numEvents++;
                  if (!execute) {
                    EventLastDate = result.eToAccMap[keyEvent].ActivityDateTime;
                    //EventLastDate = result.eToAccMap[keyEvent].ActivityDateTime.getDate() +'/'+result.eToAccMap[keyEvent].ActivityDateTime.getMonth()+'/'+result.eToAccMap[keyEvent].ActivityDateTime.getFullYear();
                    execute = true;
                  }
                }
              }
              // obj.NumOpp = numOppWon+ ' Vinte\n'+numOppOpen+ ' Aperte\n' + numOppLost+' Perse';
              obj.numOppWon = numOppWon;
              obj.numOppOpen = numOppOpen;
              obj.numOppLost = numOppLost;
            } else {
              if (obj.Partiva_Iva__c == null || obj.Partiva_Iva__c == undefined)
                obj.Partiva_Iva__c = "";
              if (
                obj.Codice_Fiscale__c == null ||
                obj.Codice_Fiscale__c == undefined
              )
                obj.Codice_Fiscale__c = "";

              if (cfIvaObj.findIndex((x) => x.iva == obj.Partiva_Iva__c) != -1)
                cfIvaObj.splice(
                  cfIvaObj.findIndex((x) => x.iva == obj.Partiva_Iva__c),
                  1
                );
              if (
                cfIvaObj.findIndex((x) => x.cf == obj.Codice_Fiscale__c) != -1
              )
                cfIvaObj.splice(
                  cfIvaObj.findIndex((x) => x.cf == obj.Codice_Fiscale__c),
                  1
                );
              if (codFisc.indexOf(obj.Codice_Fiscale__c) != -1)
                codFisc.splice(codFisc.indexOf(obj.Codice_Fiscale__c), 1);
              if (pIva.indexOf(obj.Partiva_Iva__c) != -1)
                pIva.splice(pIva.indexOf(obj.Partiva_Iva__c), 1);

              var EventLastDate;
              var execute = false;
              for (var keyEvent in result.eToLeadMap) {
                if (keyEvent.includes(key)) {
                  numEvents++;
                  if (!execute) {
                    EventLastDate =
                      result.eToLeadMap[keyEvent].ActivityDateTime;
                    //EventLastDate = result.eToLeadMap[keyEvent].ActivityDateTime.getDate() +'/'+result.eToLeadMap[keyEvent].ActivityDateTime.getMonth()+'/'+result.eToLeadMap[keyEvent].ActivityDateTime.getFullYear();
                    execute = true;
                  }
                }
              }
            }
            obj.NumEvent = numEvents;
            obj.EventLastDate = EventLastDate;
            console.log("cfIvaObj: ", cfIvaObj);

            for (var prop in obj) {
              // skip loop if the property is from prototype
              if (!obj.hasOwnProperty(prop)) continue;
              if (prop == "Id") {
                if (obj[prop].startsWith("001")) {
                  obj["ObjectType"] = "Account";
                } else {
                  obj["ObjectType"] = "Lead";
                }
              }

              obj[prop.toLowerCase().replace("partiva_iva", "partita_iva")] =
                obj[prop];
              delete obj[prop];
            }
            dataList.push(obj);
          }
          sal.data = dataList;
          sal.leftOver = cfIvaObj;
          sal.loaded = !sal.loaded;
        })
        .catch((error) => {
          console.log(error);
          console.log("@ERROR");
          const event = new ShowToastEvent({
            variant: "error",
            title: "Error!",
            message: error.body.message
          });
          sal.dispatchEvent(event);
          sal.loaded = !sal.loaded;
        });
    };
  }

  handleCreateRecords(event) {
    this.loaded = false;
    // calling apex class
    saveRecords({ records: JSON.stringify(this.data) })
      .then((result) => {
        console.log(result);
        if (result.success) {
          this[NavigationMixin.GenerateUrl]({
            type: "standard__objectPage",
            attributes: {
              objectApiName: "WRT_CSV_File__c",
              actionName: "list"
            },
            state: {
              filterName: "Recent"
            }
          }).then((url) => {
            const event = new ShowToastEvent({
              variant: "success",
              title: "Success!",
              message:
                "Record creati su {0}! Guarda gli ultimi inserimenti {1}!",
              messageData: [
                "Salesforce",
                {
                  url,
                  label: "qua"
                }
              ]
            });
            this.dispatchEvent(event);
          });
        } else {
          const event = new ShowToastEvent({
            variant: "error",
            title: "Error!",
            message: result.msg
          });
          this.dispatchEvent(event);
        }

        this.loaded = true;
      })
      .catch((error) => {
        console.log(error);
        console.log("ERROR");
        const event = new ShowToastEvent({
          variant: "error",
          title: "Error!",
          message: error.body.message
        });
        this.dispatchEvent(event);
        this.loaded = !this.loaded;
      });
  }

  handleCreateLeads(event) {
    this.loaded = false;
    var el = this.template.querySelector(
      "lightning-datatable[data-id=datatableLeads]"
    );
    var selected = el.getSelectedRows();
    console.log(JSON.stringify(selected));

    saveLeads({ leads: JSON.stringify(selected) })
      .then((result) => {
        console.log(result);
        if (result.success) {
          this[NavigationMixin.GenerateUrl]({
            type: "standard__objectPage",
            attributes: {
              objectApiName: "Lead",
              actionName: "list"
            },
            state: {
              filterName: "Recent"
            }
          }).then((url) => {
            const event = new ShowToastEvent({
              variant: "success",
              title: "Success!",
              message:
                "Record creati su {0}! Guarda gli ultimi inserimenti {1}!",
              messageData: [
                "Salesforce",
                {
                  url,
                  label: "qua"
                }
              ]
            });
            this.dispatchEvent(event);
          });
        } else {
          const event = new ShowToastEvent({
            variant: "error",
            title: "Error!",
            message: result.msg
          });
          this.dispatchEvent(event);
        }

        this.loaded = true;
      })
      .catch((error) => {
        console.log(error);
        this.loaded = true;
      });
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    switch (actionName) {
      case "show_details":
        this[NavigationMixin.Navigate]({
          type: "standard__recordPage",
          attributes: {
            recordId: row.id,
            objectApiName: row.ObjectType,
            actionName: "view"
          }
        });
        break;
      default:
    }
  }
}