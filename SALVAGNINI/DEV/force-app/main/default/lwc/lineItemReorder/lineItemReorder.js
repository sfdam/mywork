import { LightningElement, wire, api, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { CloseActionScreenEvent } from 'lightning/actions';
import getQuoteLines from "@salesforce/apex/lineItemReorderController.getQuoteLines";
import submit from "@salesforce/apex/lineItemReorderController.submit";
import submitName from "@salesforce/apex/lineItemReorderController.submitName";
import getAlternativeLines from "@salesforce/apex/lineItemReorderController.getAlternativeLines";
import mergeLines from "@salesforce/apex/lineItemReorderController.mergeLines";
import unMergeLines from "@salesforce/apex/lineItemReorderController.unMergeLines";
import getQuoteGroups from "@salesforce/apex/lineItemReorderController.getQuoteGroups";
import changeGroup from "@salesforce/apex/lineItemReorderController.changeGroup";
import changeGroupName from "@salesforce/apex/lineItemReorderController.changeGroupName";
import { updateRecord } from 'lightning/uiRecordApi';
import HIDE from '@salesforce/schema/SBQQ__QuoteLine__c.MERGE_Hide_Line__c';
import ID_FIELD from '@salesforce/schema/SBQQ__QuoteLine__c.Id';


export default class DataTableDragable extends LightningElement {
  @api recordId;
  @track groupId = '';
  @wire(getQuoteGroups,{recordId: '$recordId'})
  quoteGroups;
  @wire(getQuoteLines,{recordId: '$recordId',groupId: '$groupId'})
  users;
  

  @api
  get disabledButton() {
      return this.groupName == 'Default Group';
  }
  @api
  get disabledButtonList() {
      return this.quoteGroups.data == undefined || this.quoteGroups.data == null || this.quoteGroups.data.length < 2 ;
  }
  @api
  get disabledButtonPrev() {
    return this.groupIndex < 1  ;
  }
  @api
  get disabledButtonNext() {
    return this.quoteGroups.data == undefined || this.quoteGroups.data == null || this.quoteGroups.data.length == 0 || this.groupIndex  ==  this.quoteGroups.data.length -1 ;
  }

  error = false;
  mergeLineSave = false;
  hideQuantity = false;
  hideDiscount = false;
  hidePrice = false;
  @track isModalOpen = false;
  @track isModalOpenChangeName = false;
  @track isModalOpenChangeGroup = false;
  @api userMap;
  @api dragMap;
  options;
  optionsMap;
  optionsGroup;
  optionsGroupMap;
  selectedLineToMerge = [];
  selectedGroupId;
  @track selectedLineName = '';
  @track selectedLineName2 = '';
  @track selectedTotalLabel = 'Grand Total';
  @track selectedDiscountLabel = 'Price for You';
  lineToMerge;
  fullLineToMerge;
  @track isLoading = false;
  @track isLoadingModal = false;
  currentGroup;
  @track groupName = 'Default Group';
  @track groupIndex = -1;
  

  renderedCallback() {
    if (!!this.users && !!this.users.data) {
      this.userMap = new Map();
      let tempArray = JSON.parse(JSON.stringify(this.users.data));
      tempArray.forEach((arrayElement, index) => {
        arrayElement.index = index;
        this.userMap.set(arrayElement.Id, arrayElement);
      });
      
      this.users.data = JSON.parse(JSON.stringify(tempArray));
    }
    
  }

 /*async refreshTable (){
   const lineResponse = await getQuoteLines({recordId : this.recordId});
   console.log("lineResponse: "+JSON.stringify(lineResponse));
   this.data= lineResponse;
    this.userMap = new Map();
    let tempArray = JSON.parse(JSON.stringify(this.data));
    tempArray.forEach((arrayElement, index) => {
      arrayElement.index = index;
      this.userMap.set(arrayElement.Id, arrayElement);
    });
    this.data = JSON.parse(JSON.stringify(tempArray));
  
 }*/

 async handleSubmit() {
    this.isLoading = true;
    console.log("in submit method");
    let data = this.users.data;
    console.log(": ----------------------------------------------");
    console.log(
      "DataTableDragable -> handleSubmit -> data",
      JSON.stringify(data)
    );
    //data.sort((a,b) => a.index - b.index);
    //data.forEach(element => element.Item_Print_Order__c = element.index);
    console.log("data sorted: "+JSON.stringify(data));
    const submitResponse = await submit({linesToSave : data});
    if(submitResponse == 'OK'){
        this.isLoading = false;
        console.log("OK");
        this.showToast('Success!','Ordine linee salvato con successo.','success');
        refreshApex(this.users);
        if(!this.mergeLineSave){
            this.closeQuickAction();
        }
    }
    else{
        console.log("KO");
        this.isLoading = false;
        this.showToast('Error','Qualcosa è andato storto, contattare l\'amministratore: '+submitResponse,'error');
    }
    
  }

  async handleSubmitName() {
    this.isLoading = true;
    console.log("in submit method name");
    let data = this.users.data;
    console.log(": ----------------------------------------------");
    console.log(
      "DataTableDragable -> handleSubmit -> data",
      JSON.stringify(data)
    );
    //data.sort((a,b) => a.index - b.index);
    data.forEach(element => element.Item_Print_Order__c = element.index);
    console.log("data sorted: "+JSON.stringify(data));
    const submitResponse = await submit({linesToSave : data});
    if(submitResponse == 'OK'){
        this.isLoading = false;
        console.log("OK");
        this.showToast('Success!','Ordine linee salvato con successo.','success');
        refreshApex(this.users);
        if(!this.mergeLineSave){
            this.closeQuickAction();
        }
    }
    else{
        console.log("KO");
        this.isLoading = false;
        this.showToast('Error','Qualcosa è andato storto, contattare l\'amministratore: '+submitResponse,'error');
    }
    
  }
  

  processRowNumbers() {
    const trs = this.template.querySelectorAll(".myIndex");
    const ids = this.template.querySelectorAll(".myId");
    for (let i = 0; i < trs.length; i++) {
      let currentRowId = ids[i].innerText;
      let currentRowRef = this.userMap.get(currentRowId);
      currentRowRef.Item_Print_Order__c = i;
      this.userMap.set(currentRowId, currentRowRef);
      trs[i].innerText = i;
      console.log("currentRowId: "+currentRowId);
      console.log("currentRowRef: "+currentRowRef);
    }
    this.users.data = Array.from(this.userMap.values());
  }

  onDragStart(evt) {
    const inputs = this.template.querySelectorAll(".mychkbox");
    this.dragMap = new Map();

    if (inputs) {
      for (let i = 0; i < inputs.length; i++) {
        if (inputs[i].checked) {
          let currentRow = inputs[i].parentNode.parentNode;
          let currentDragId = currentRow.dataset.dragId;
          this.dragMap.set(currentDragId, currentRow);
          //currentRow.classList.add("grabbed");
        }
      }
    }

    let eventRowDataId = evt.currentTarget.dataset.dragId;
    evt.dataTransfer.setData("dragId", eventRowDataId);
    evt.dataTransfer.setData("sy", evt.pageY);
    evt.dataTransfer.effectAllowed = "move";
    evt.currentTarget.classList.add("grabbed");

    if (this.dragMap.has(eventRowDataId)) {
      this.dragMap.forEach((value) => value.classList.add("grabbed"));
    }
  }

  onDragOver(evt) {
    evt.preventDefault();
    evt.dataTransfer.dropEffect = "move";
  }

  onDrop(evt) {
    evt.preventDefault();
    let sourceId = evt.dataTransfer.getData("dragId");

    const sy = evt.dataTransfer.getData("sy");
    const cy = evt.pageY;

    if (sy > cy) {
      if (this.dragMap.has(sourceId)) {

        Array.from(this.dragMap).reverse().forEach( element => {
          let key = element[0];
          const elm = this.template.querySelector(`[data-drag-id="${key}"]`);
          if (!!elm) {
            elm.classList.remove("grabbed");
          }
          evt.currentTarget.parentElement.insertBefore(elm, evt.currentTarget);
        });
      } else {
        const elm = this.template.querySelector(`[data-drag-id="${sourceId}"]`);
        if (!!elm) {
          elm.classList.remove("grabbed");
        }
        evt.currentTarget.parentElement.insertBefore(elm, evt.currentTarget);
      }
    } else {
      if (this.dragMap.has(sourceId)) {
        this.dragMap.forEach((value, key, map) => {
          const elm = this.template.querySelector(`[data-drag-id="${key}"]`);
          if (!!elm) {
            elm.classList.remove("grabbed");
          }
          evt.currentTarget.parentElement.insertBefore(
            elm,
            evt.currentTarget.nextElementSibling
          );
        });
      } else {
        const elm = this.template.querySelector(`[data-drag-id="${sourceId}"]`);
        if (!!elm) {
          elm.classList.remove("grabbed");
        }
        evt.currentTarget.parentElement.insertBefore(
          elm,
          evt.currentTarget.nextElementSibling
        );
      }
    }
    this.processRowNumbers();
  }

  async handleMerge(event){
    this.mergeLineSave = true;
    this.handleSubmit();
    const itemIndex = event.currentTarget.dataset.index;
    const rowData = this.users.data[itemIndex];
    
    // eslint-disable-next-line no-console
    console.log(rowData);
    this.lineToMerge = rowData.Id;
    this.fullLineToMerge = rowData;
    this.selectedLineName = rowData.MERGE_Name__c;
    this.selectedLineName2 = rowData.MERGE_Secondary_Name__c;
    this.hideQuantity = rowData.MERGE_Hide_Quantity__c;
    this.isModalOpen = true;
    var optional=rowData.OptionalLine__c;
    const altLines = await getAlternativeLines({recordId : this.recordId, selectedLineId : rowData.Id, groupId : this.groupId, opt:optional});
    console.log('altLines: '+JSON.stringify(altLines));
    var newLineList = [];
    var newLineMap = new Map();
    altLines.forEach(element => {
        var singleObject = {};
        singleObject.label = element.MERGE_Name__c;
        singleObject.value = element.Id;
        newLineList.push(singleObject);
        if(element?.SVG_Type__c != undefined){
          newLineMap[element.Id] = element.MERGE_Name__c+element?.SVG_Type__c;
        }else{
          newLineMap[element.Id] = element.MERGE_Name__c;
        }
        

    });
    this.options = newLineList;
    this.optionsMap = newLineMap;
    }

    async handleChangeName(event){
        this.mergeLineSave = true;
        this.handleSubmit();
        /*const itemIndex = event.currentTarget.dataset.index;
        const rowData = this.users.data[itemIndex];
        
        // eslint-disable-next-line no-console
        console.log(rowData);
        this.lineToMerge = rowData.Id;
        this.fullLineToMerge = rowData;
        this.selectedLineName = rowData.MERGE_Name__c;
        this.selectedLineName2 = rowData.MERGE_Secondary_Name__c;
        this.hideQuantity = rowData.MERGE_Hide_Quantity__c;*/
        this.isModalOpenChangeName = true;
    }
    async handleChangeGroup(event){
        this.mergeLineSave = true;
        this.handleSubmit();
        const itemIndex = event.currentTarget.dataset.index;
        const rowData = this.users.data[itemIndex];
        
        // eslint-disable-next-line no-console
        console.log(rowData);
        this.lineToMerge = rowData.Id;
        this.fullLineToMerge = rowData;
        this.isModalOpenChangeGroup = true;
        var newLineList = [];
        var newLineMap = new Map();
        this.quoteGroups.data.forEach(element => {
            var singleObject = {};
            singleObject.label = element.Name;
            singleObject.value = element.Id;
            newLineList.push(singleObject);
            newLineMap[element.Id] = element.Name;
    
        });
        this.optionsGroup = newLineList;
        this.optionsGroupMap = newLineMap;
        }
    handleHideLine(event){
        //this.mergeLineSave = true;
        //this.handleSubmit();
        const itemIndex = event.currentTarget.dataset.index;
        const rowData = this.users.data[itemIndex];
        rowData.MERGE_Hide_Line__c= !rowData.MERGE_Hide_Line__c;
        this.users.data[itemIndex]=rowData;
        const fields = {};
        fields[ID_FIELD.fieldApiName] = rowData.Id;
        fields[HIDE.fieldApiName] = rowData.MERGE_Hide_Line__c;
        const recordInput = { fields };
        updateRecord(recordInput)
        .then(() => {
          console.log('OK then');
          // Display fresh data in the form
          return refreshApex(this.users);
      })
      .catch(error => {
          this.dispatchEvent(
              new ShowToastEvent({
                  title: 'Error creating record',
                  message: error.body.message,
                  variant: 'error'
              })
          );
      });
        
        // eslint-disable-next-line no-console
        console.log(this.users.data[itemIndex]);
        //this.lineToMerge = rowData.Id;
        //this.fullLineToMerge = rowData;
        //this.isModalOpenChangeGroup = true;
          
          
    }
    closeModal() {
        this.isModalOpen = false;
        this.isModalOpenChangeName = false;
        this.isModalOpenChangeGroup = false;
        this.mergeLineSave = false;
    }

    async mergeLines() {
        this.mergeLineSave = false;
        var inputCmp = this.template.querySelector('lightning-input');
        var checkboxCmp = this.template.querySelector('lightning-checkbox-group');
        inputCmp.setCustomValidity(''); 
        checkboxCmp.setCustomValidity('');
        inputCmp.reportValidity();
        checkboxCmp.reportValidity();
        if(this.selectedLineToMerge.length > 0 && this.selectedLineName != null && this.selectedLineName != ''){
            this.isLoadingModal = true;
            console.log('recordId selected: '+this.selectedLineToMerge);
            console.log('recordId to merge: '+this.lineToMerge);
            console.log('hideQuantity '+this.hideQuantity);
            console.log('line Name'+this.selectedLineName);
            console.log('sec Name'+this.selectedLineName2);
            const mergeResponse = await mergeLines({mergeIds : this.selectedLineToMerge, mainLineId : this.lineToMerge, lineName : this.selectedLineName, secondaryName : this.selectedLineName2, hideQuantity : this.hideQuantity});
            if(mergeResponse == 'OK'){
                this.isModalOpen = false;
                this.showToast('Success!','Linee unite con successo.','success');
                //this.refreshTable();
                refreshApex(this.users);
                this.isLoadingModal = false;
            }
            else{
                console.log("KO");
                this.isLoadingModal = false;
                this.showToast('Error','Qualcosa è andato storto, contattare l\'amministratore: '+mergeResponse,'error');
            }
        }
        else{
            if(this.selectedLineToMerge.length == 0){
                checkboxCmp.setCustomValidity('Selezionare almeno una riga');
                checkboxCmp.reportValidity();
                //this.showToast('Error','Si prega di selezionare almeno una riga da unire ','error');
            }
            else if(this.selectedLineName == null || this.selectedLineName == ''){
                inputCmp.setCustomValidity('Inserire un nome');
                inputCmp.reportValidity();
                //this.showToast('Error','Si prega di inserire un nome per la nuova riga unita ','error');
            }
            /*else if(this.selectedLineName2 == null || this.selectedLineName2 == ''){
                inputCmp.setCustomValidity('Inserire un nome secondario');
                inputCmp.reportValidity();
                //this.showToast('Error','Si prega di inserire un nome per la nuova riga unita ','error');
            }*/
        }

    }

    async saveName() {
        this.mergeLineSave = false;
        /*var inputCmp = this.template.querySelector('lightning-input');
        inputCmp.setCustomValidity(''); 
        inputCmp.reportValidity();*/
        if(this.selectedLineName != null && this.selectedLineName != ''){
            this.isLoadingModal = true;
            console.log('recordId selected: '+this.selectedLineToMerge);
            console.log(' selectedLineName2: '+this.selectedLineName2);
            console.log('recordId to merge: '+this.lineToMerge);
            console.log(' selectedTotalLabel: '+this.selectedTotalLabel);
            console.log(' selectedDiscountLabel: '+this.selectedDiscountLabel);
            console.log('hidePrice '+this.hidePrice);
            console.log('hideDiscount '+this.hideDiscount);
            const mergeResponse = await changeGroupName({newName : this.selectedLineName,newName2 : this.selectedLineName2, groupId : this.groupId, hidePrice: this.hidePrice, hideDiscount: this.hideDiscount, totalLabel: this.selectedTotalLabel, discountLabel: this.selectedDiscountLabel});
            if(mergeResponse == 'OK'){
                this.isModalOpenChangeName = false;
                this.selectedTotalLabel = 'Grand Total';
                this.selectedDiscountLabel = 'Price for You';
                this.groupName = this.selectedLineName;
                this.showToast('Success!','Gruppo salvato con successo.','success');
                //this.refreshTable();
                refreshApex(this.quoteGroups);
                this.isLoadingModal = false;
            }
            else{
                console.log("KO");
                this.isLoadingModal = false;
                this.showToast('Error','Qualcosa è andato storto, contattare l\'amministratore: '+mergeResponse,'error');
            }
        }
        else{
            if(this.selectedLineName == null || this.selectedLineName == ''){
                inputCmp.setCustomValidity('Inserire un nome primario');
                inputCmp.reportValidity();
                //this.showToast('Error','Si prega di inserire un nome per la nuova riga unita ','error');
            }
            /*else if(this.selectedLineName2 == null || this.selectedLineName2 == ''){
                inputCmp.setCustomValidity('Inserire un nome secondario');
                inputCmp.reportValidity();
                //this.showToast('Error','Si prega di inserire un nome per la nuova riga unita ','error');
            }*/
        }

    }

    async changeGroup() {
        this.mergeLineSave = false;
        /*var inputCmp = this.template.querySelector('lightning-input');
        inputCmp.setCustomValidity(''); 
        inputCmp.reportValidity();*/
        console.log('group selected: '+this.selectedGroupId);
        if(this.selectedGroupId != null && this.selectedGroupId != ''){
            this.isLoadingModal = true;
            console.log('group selected: '+this.selectedGroupId);
            console.log('line selected: '+this.lineToMerge);
            const mergeResponse = await changeGroup({mainLineId : this.lineToMerge, groupId : this.selectedGroupId});
            if(mergeResponse == 'OK'){
                this.isModalOpenChangeGroup = false;
                this.showToast('Success!','Gruppo salvato con successo.','success');
                //this.refreshTable();
                refreshApex(this.users);
                this.isLoadingModal = false;
            }
            else{
                console.log("KO");
                this.isLoadingModal = false;
                this.showToast('Error','Qualcosa è andato storto, contattare l\'amministratore: '+mergeResponse,'error');
            }
        }
        else{
            if(this.selectedGroupId == null || this.selectedGroupId == ''){
                
                this.showToast('Error','Si prega di selezionare il nuovo gruppo ','error');
            }
            /*else if(this.selectedLineName2 == null || this.selectedLineName2 == ''){
                inputCmp.setCustomValidity('Inserire un nome secondario');
                inputCmp.reportValidity();
                //this.showToast('Error','Si prega di inserire un nome per la nuova riga unita ','error');
            }*/
        }

    }

    handleRadioChange(event) {
        this.selectedLineToMerge = event.detail.value;
        var concatNames = '';
        this.selectedLineToMerge.forEach(element => {
            concatNames = concatNames + '+' + this.optionsMap[element];
        });
        if(this.fullLineToMerge.SVG_Type__c!=undefined){
          this.selectedLineName = this.fullLineToMerge.SBQQ__Product__r.Name +this.fullLineToMerge.SVG_Type__c+ concatNames;
          this.selectedLineName2 = this.fullLineToMerge.SBQQ__Product__r.Name +this.fullLineToMerge.SVG_Type__c+ concatNames;
        }else{
          this.selectedLineName = this.fullLineToMerge.SBQQ__Product__r.Name + concatNames;
          this.selectedLineName2 = this.fullLineToMerge.SBQQ__Product__r.Name + concatNames;
        }
        
    }
    handleRadioChangeGroup(event) {
        this.selectedGroupId = event.detail.value;
    }

    async handleUnmerge(event) {
        this.isLoading = true;
        const unmergeResponse = await unMergeLines({recordId : this.recordId});
        if(unmergeResponse == 'OK'){
            this.showToast('Success!','Linee separate con successo.','success');
            //this.refreshTable();
            refreshApex(this.users);
            this.isLoading = false;
        }
        else{
            console.log("KO");
            this.isLoading = false;
            this.showToast('Error','Qualcosa è andato storto, contattare l\'amministratore: '+unmergeResponse,'error');
        }
        
    }

    showToast(title,message,variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handleInputChange(event) {
        this.selectedLineName = event.detail.value;
    }
    handleInputChange2(event) {
        this.selectedLineName2 = event.detail.value;
    }
    handleInputChangeTotal(event) {
        this.selectedTotalLabel = event.detail.value;
    }
    handleInputChangeDiscount(event) {
        this.selectedDiscountLabel = event.detail.value;
    }
    handleInputChangeHideQuantity(event) {
        console.log('hideQuantity '+this.hideQuantity);
        this.hideQuantity = event.detail.checked;
    }
    handleInputChangeHideDiscount(event) {
        console.log('hideDiscount '+this.hideDiscount);
        this.hideDiscount = event.detail.checked;
    }
    handleInputChangeHidePrice(event) {
        console.log('hidePrice '+this.hidePrice);
        this.hidePrice = event.detail.checked;
    }

    handleNext() {
        console.log(JSON.stringify(this.quoteGroups.data));
        
        this.groupIndex++;
        console.log(this.groupIndex);
        this.currentGroup = this.quoteGroups.data[this.groupIndex];
        console.log(JSON.stringify(this.currentGroup));
        this.groupId = this.currentGroup.Id;
        this.groupName = this.currentGroup.Name;
        console.log(JSON.stringify(this.groupId));
        console.log(JSON.stringify(this.groupName));
        refreshApex(this.users);
    }
    handlePrev() {
        console.log(JSON.stringify(this.quoteGroups.data));
        
        this.groupIndex--;
        console.log(this.groupIndex);
        this.currentGroup = this.quoteGroups.data[this.groupIndex];
        console.log(JSON.stringify(this.currentGroup));
        this.groupId = this.currentGroup.Id;
        this.groupName = this.currentGroup.Name;
        console.log(JSON.stringify(this.groupId));
        console.log(JSON.stringify(this.groupName));
        refreshApex(this.users);
    }
   
}