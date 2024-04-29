import { LightningElement, api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getMultioptionsApprovalRequests from '@salesforce/apex/ART_MassiveApproveController.getMultioptionsApprovalRequests';
import approve from '@salesforce/apex/ART_MassiveApproveController.approve';
import reject from '@salesforce/apex/ART_MassiveApproveController.reject';

//AD custom labels
import ART_Advanced_Order_Order_Name        from '@salesforce/label/c.ART_Advanced_Order_Order_Name';
import ART_ID18			                    from '@salesforce/label/c.ART_ID18';
import ART_Customer			                from '@salesforce/label/c.ART_Customer';
import ART_Customer_Identification_Code     from '@salesforce/label/c.ART_Customer_Identification_Code';
import ART_Order_Template 		            from '@salesforce/label/c.ART_Order_Template';
import ART_Value_Recipt                     from '@salesforce/label/c.ART_Value_Recipt';
import ART_Order_Date			            from '@salesforce/label/c.ART_Order_Date';
import ART_Delivery_Date		            from '@salesforce/label/c.ART_Delivery_Date';
import ART_Advanced_Order_Owner_Name        from '@salesforce/label/c.ART_Advanced_Order_Owner_Name';
import ART_Delay_to_be_Approved             from '@salesforce/label/c.ART_Delay_to_be_Approved';
import ART_Delay_Days			            from '@salesforce/label/c.ART_Delay_Days';
import ART_Delivery_Recipient_Provincia     from '@salesforce/label/c.ART_Delivery_Recipient_Provincia';
import ART_Multiple_order_approval          from '@salesforce/label/c.ART_Multiple_order_approval';


const GENERIC_ERROR_MESSAGE = "Si è verificato un errore";
const GENERIC_SUCCESS_MESSAGE = "Operazione completata!";

export default class ArtMassiveApprove extends NavigationMixin(LightningElement) {

    @api recordId;
    loading = false;
    //columns = COLUMNS;
    rows = [];
    defaultSortDirection = "asc";
    sortDirection = "asc";
    sortedBy = "relatedTo";
    rowNumberOffset = 0;
    disableButtons = false;
    selectedRows = [];
    //approvalOptions = [];
    @track approvalOptions=[];
    headerLabel;

    label = {
        ART_Advanced_Order_Order_Name   ,
        ART_ID18			            ,   
        ART_Customer			        ,   
        ART_Customer_Identification_Code,
        ART_Order_Template 		       ,
        ART_Value_Recipt                ,
        ART_Order_Date			       ,
        ART_Delivery_Date		       ,
        ART_Advanced_Order_Owner_Name   ,
        ART_Delay_to_be_Approved        ,
        ART_Delay_Days			       ,
        ART_Delivery_Recipient_Provincia,
        ART_Multiple_order_approval 
    };

    @track columns = [
        {fieldName: "nameUrl", type: "url" ,typeAttributes:{label:{fieldName:"orderName"}}, label: this.label.ART_Advanced_Order_Order_Name, sortable: true},
        // {fieldName: "iD18", type: "text", label: this.label.ART_ID18, sortable: true},
        {fieldName: "customerName", type: "text", label: this.label.ART_Customer, sortable: true},
        {fieldName: "customerIdentificationCode", type: "text", label: this.label.ART_Customer_Identification_Code, sortable: true},
        {fieldName: "deliveryRecipientProvincia", type: "text", label:this.label.ART_Delivery_Recipient_Provincia, sortable: true},
        {fieldName: "orderTamplate", type: "text", label: this.label.ART_Order_Template, sortable: true},
        {fieldName: "valueReceipt", type: "currency", label: this.label.ART_Value_Recipt, sortable: true, typeAttributes: { maximumFractionDigits: 2}, cellAttributes: { alignment: 'left' }},
        {fieldName: "orderDate", type: "text", label: this.label.ART_Order_Date, sortable: true},
        {fieldName: "deliveryDate", type: "text", label: this.label.ART_Delivery_Date, sortable: true},
        {fieldName: "ownerName", type: "text", label: this.label.ART_Advanced_Order_Owner_Name, sortable: true},
        {fieldName: "dilazione", type: "boolean", label: this.label.ART_Delay_to_be_Approved, sortable: true},
        {fieldName: "delayDays", type: "text", label: this.label.ART_Delay_Days, sortable: true},
    ];


    connectedCallback(){

        console.log('START ArtMassiveApprove connectedCallBack');
        this.init();

    }
    
    //AD task:DE-065  05 10 2023

    async init() {
        try {

            let nameUrl;
            this.loading = true;
            this.disableButtons = true;
            this.rows = [];
            const multioptionsApprovalRequests = await getMultioptionsApprovalRequests();
            console.log(multioptionsApprovalRequests?.processInstanceWorkitems);
            for (let workitem of multioptionsApprovalRequests?.processInstanceWorkitems) {
                const currentOrder = multioptionsApprovalRequests.orders.find(orderItem => orderItem.Id === workitem.ProcessInstance.TargetObject.Id);//AD

                console.log('AD currentOrder : ' , currentOrder);
                const search = this.rows.find(currentRow => currentRow.idOrder === currentOrder.Id );
                
                //AD task:DE-065 controllo se negli ordini è presente il condition payment (cgcloud__Payer__r) e gli assegno a determinate varibili
                const payerCheck = Object.hasOwn(currentOrder,'cgcloud__Payer__r');
                let paymentConditionFarma = '';
                let paymentConditionDerma = '';
                let paymentConditionOTC   = '';
                if(payerCheck){
                    paymentConditionFarma = currentOrder.cgcloud__Payer__r.ART_PaymentCondition_Farma__c;
                    paymentConditionDerma = currentOrder.cgcloud__Payer__r.ART_PaymentCondition_Derma__c;
                    paymentConditionOTC   = currentOrder.cgcloud__Payer__r.ART_PaymentCondition_OTC__c;
                }

                //AD task:DE-065 per evitare i duplicati degli ordini effettuo il seguente controllo 
                //se è gia peresente un ordine nel mio array "rows" in base al find di "idOrder" (variabile : "search")
                //non faccio l'inserimento
                
                if(!search){
                    this.rows.push({
                        Id: workitem.Id,
                        orderName : currentOrder.Name,
                        iD18 : currentOrder.ID18__c,
                        customerName: currentOrder.cgcloud__Order_Account__r.Name,
                        customerIdentificationCode : currentOrder.ART_Customer_identification_code__c,
                        orderTamplate : currentOrder.cgcloud__Order_Template__r.Name,
                        valueReceipt : Number(parseFloat(currentOrder.cgcloud__Value__c)),
                        orderDate : currentOrder.cgcloud__Order_Date__c,
                        deliveryDate : currentOrder.cgcloud__Delivery_Date__c,
                        ownerName : currentOrder.Owner.Name,
                        dilazione : currentOrder.ART_Dilazione_da_approvare__c,
                        delayDays : Number(currentOrder.ART_Delay_days__c),
                        // deliveryRecipientProvincia : currentOrder.ART_Delivery_Recipient_Provincia__c,
                        deliveryRecipientProvincia : currentOrder.Delivery_Recipient_Provincia__c,
                        submitterApprovalOptions: currentOrder.cgcloud__Phase__c,
                        paymentConditionFarma : paymentConditionFarma ? paymentConditionFarma:"",
                        paymentConditionDerma : paymentConditionDerma ? paymentConditionDerma:"",
                        paymentConditionOTC   : paymentConditionOTC ? paymentConditionOTC:"",
                        idOrder : currentOrder.Id
                    })
                }
                
                
            }

            //gestione order name cliccabile
            if(this.rows.length > 0){
                let tempRecApp=[];

                this.rows.forEach((record)=>{   
                    let tempRec = Object.assign({},record);
                    tempRec.nameUrl='/'+tempRec.idOrder;
                    tempRecApp.push(tempRec);
                })

                this.rows = tempRecApp;

                console.log('AD rows after map : ' , this.rows);
            }
            this.rows.sort( this.sortBy( this.sortedBy, this.sortDirection === 'asc' ? 1 : -1 ) );
            // this.rows.sort((rowA, rowB) => rowA[this.sortedBy] == null ? 1 : rowA[this.sortedBy].localeCompare(rowB[this.sortedBy], undefined, {sensitivity: 'base'}));
            this.headerLabel = `${this.rows.length} elementi • 0 selezionati`;
            
        }
        catch (error) {
            //this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}));//AD 
            console.log('DK error:', error);
            this.dispatchEvent(new CustomEvent(
                'toastdata', 
                {
                    detail: { variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}
                }
            ));//AD 
        }
        finally {
            this.loading = false;
        }
    }

    handleRowActions(event) {
        // TODO
    }

    /*handleSort(event) {

        try {
            
            this.loading = true;
            this.sortedBy = event.detail.fieldName === "caseLink" ? "relatedTo" : event.detail.fieldName;
            this.sortDirection = this.sortedBy === "relatedTo" ? (this.sortDirection === "asc" ? "desc" : "asc") : event.detail.sortDirection;
            console.log('DK this.sortedBy:', this.sortedBy);
            if(this.rows?.length > 0) {
                const rows = [...this.rows];
                rows.sort((rowA, rowB) => rowA[this.sortedBy] == null ? 1 : rowA[this.sortedBy].localeCompare(rowB[this.sortedBy], undefined, {sensitivity: 'base'}));
                this.rows = this.sortDirection === "asc" ? rows : rows.reverse();
                this.loading = false;
            }
        } catch (error) {
            console.log('DK error', error);
        }
    }*/

    handleSort( event ) {
        console.log('DK event.detail.fieldName', event.detail.fieldName);
        this.loading = true;
        this.sortedBy = event.detail.fieldName === "caseLink" ? "relatedTo" : event.detail.fieldName === 'nameUrl' ? 'orderName' : event.detail.fieldName;
        console.log('DK sortedBy', this.sortedBy);
        this.sortDirection = this.sortedBy === "relatedTo" || this.sortedBy === "orderName" ? (this.sortDirection === "asc" ? "desc" : "asc") : event.detail.sortDirection;
        console.log('DK sortDirection', this.sortDirection);
        
        const cloneData = [...this.rows];
        cloneData.sort( this.sortBy( this.sortedBy, this.sortDirection === 'asc' ? 1 : -1 ) );
        // this.data = cloneData;
        this.rows = cloneData;
        this.loading = false;
        // this.setPages(this.filteredData);
    }

    sortBy( field, reverse, primer ) {

        const key = primer
            ? function( x ) {
                  return primer(x[field]);
              }
            : function( x ) {
                  return x[field];
              };

        return function( a, b ) {
            a = key(a);
            b = key(b);
            let ascending = reverse == 1;
            // equal items sort equally
            if (a === b) {
                return 0;
            }
            // nulls sort after anything else
            else if (!Boolean(a)) {
                return 1;
            }
            else if (!Boolean(b)) {
                return -1;
            }
            // otherwise, if we're ascending, lowest sorts first
            else if (ascending) {
                return a < b ? -1 : 1;
            }
            // if descending, highest sorts first
            else { 
                return a < b ? 1 : -1;
            }
        };

    }

    handleRowSelection(event) {
        this.selectedRows = this.template.querySelector("lightning-datatable")?.getSelectedRows();
        const groupOptions = this.selectedRows?.map(row => row.submitterApprovalOptions?.split(';')?.filter(option => option?.length > 0));
        // AD this.approvalOptions combo box attualmente commentata perché non richiesta
        // AD this.approvalOptions = groupOptions?.length > 0 ? groupOptions.reduce((accumulator, currentValue) => accumulator.filter(option => currentValue.includes(option)))?.map(option => {return {label: option, value: option}}) : [];
        this.disableButtons = this.selectedRows?.length === 0;
        this.headerLabel = `${this.rows.length} elementi • ${this.selectedRows.length} selezionati`;
    }

    closeModal(event) {
        this.template.querySelector(`.${event.currentTarget.name}`).closeModal();
    }

    openApproveModal(event) {
        this.template.querySelector(".approve-modal").openModal();
    }

    openRejectModal(event) {
        this.template.querySelector(".reject-modal").openModal();
    }

    openReassignModal(event) {
        this.template.querySelector(".reassign-modal").openModal();
    }

    async approveHandler(event) {
        try {
            this.loading = true;
            //AD task:DE-065 approvalOptionComboBox gestione preliveo dati combo box non necessaria attualmente
            //const approvalOptionComboBox = this.template.querySelector(".approvalOptions lightning-combobox");
            const commentsLightningTextarea = this.template.querySelector(".comments lightning-textarea");
            
            const processInstanceWorkitemIds = this.selectedRows.map(row => row.Id);
            //AD controllo se sono presenti i payment condition negli ordini selezionati 
            const orderWithOutPaymentCondition = this.selectedRows.filter(row => row.paymentConditionFarma ==='' && row.paymentConditionDerma ==='' && row.paymentConditionOTC ==='');
            console.log('AD orderWithOutPaymentCondition : ' , orderWithOutPaymentCondition.length);
            let arrayOrder='';
            //AD se trova degli ordini senza payment condition blocca il processo di approvazione e invia un alert
            if(orderWithOutPaymentCondition.length>0){
                arrayOrder= orderWithOutPaymentCondition.map(row => row.orderName);
                let messaggeToast = 'Attenzione non sono presenti le condizioni di pagamento nei seguenti ordini : ' + arrayOrder.toString()
                
                    this.dispatchEvent(new CustomEvent(
                        'toastdata', 
                        {
                            detail: { variant: "error", title: "Error", message: messaggeToast}
                        }
                    ));//AD 
                    // this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: 'errore nel order'}));
            }
            
            
            // approvalOptionComboBox commentata non neccessaria al momento 04 10 2023
            // AD approvalOptionComboBox.reportValidity() &&  commentsLightningTextarea.reportValidity()*/
            if(commentsLightningTextarea.reportValidity() && orderWithOutPaymentCondition.length ==0) {
                console.log('AD vado in approvazione ');
                const processInstanceWorkitemIds = this.selectedRows.map(row => row.Id);
                // AD parte combobox attualmente non usata
                // AD const comments = (approvalOptionComboBox.value?.length > 0 ? approvalOptionComboBox.value : "") + (commentsLightningTextarea.value?.length > 0 ? (" - " + commentsLightningTextarea.value) : "");
                const comments = "" + (commentsLightningTextarea.value?.length > 0 ? (" - " + commentsLightningTextarea.value) : "");//AD
                const result = JSON.parse(await approve({processInstanceWorkitemIds: processInstanceWorkitemIds, comments: comments}));
                
                const notApprovedCaseIds = result.filter(item => item.success === false)?.map(item => item.entityId);

                if(notApprovedCaseIds?.length > 0) {
                    throw new Error(GENERIC_ERROR_MESSAGE);
                    console.error(notApprovedCaseIds);
                }
                else {
                    //this.dispatchEvent(new ShowToastEvent({variant: "success", title: "Success", message: GENERIC_SUCCESS_MESSAGE}));//AD 
                    this.dispatchEvent(new CustomEvent(
                        'toastdata', 
                        {
                            detail: { variant: "success", title: "Success", message: GENERIC_SUCCESS_MESSAGE}
                        }
                    ));//AD 
                }

                await this.init();
                this.template.querySelector(".approve-modal").closeModal();
            } 
            
        }
        catch (error) {
            console.log('AD error save approval : ' , error );
            //this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}));/AD 
            this.dispatchEvent(new CustomEvent(
                'toastdata', 
                {
                    detail: { variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}
                }
            ));//AD 
            await this.init();
            this.template.querySelector(".approve-modal").closeModal();
        }
        finally {
            this.loading = false;
        }
    }

    async rejectHandler(event) {
        try {
            this.loading = true;
            const commentsLightningTextarea = this.template.querySelector(".comments lightning-textarea");

            if(commentsLightningTextarea.reportValidity()) {
                const processInstanceWorkitemIds = this.selectedRows.map(row => row.Id);
                const result = JSON.parse(await reject({processInstanceWorkitemIds: processInstanceWorkitemIds, comments: (commentsLightningTextarea.value?.length > 0 ? commentsLightningTextarea.value : "")}));
                console.log('AD rejectHandler result : ' , result);
                const notRejectedCaseIds = result.filter(item => item.success === false)?.map(item => item.entityId);

                if(notRejectedCaseIds?.length > 0) {
                    throw new Error(GENERIC_ERROR_MESSAGE);
                    console.error(notRejectedCaseIds);
                }
                else {
                    //this.dispatchEvent(new ShowToastEvent({variant: "success", title: "Success", message: GENERIC_SUCCESS_MESSAGE}));//AD
                    this.dispatchEvent(new CustomEvent(
                        'toastdata', 
                        {
                            detail: { variant: "success", title: "Success", message: GENERIC_SUCCESS_MESSAGE}
                        }
                    ));//AD 
                }

                await this.init();
                this.template.querySelector(".reject-modal").closeModal();
            }
        }
        catch (error) {
            //this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}));//AD
            this.dispatchEvent(new CustomEvent(
                'toastdata', 
                {
                    detail: { variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}
                }
            ));//AD 
            await this.init();
            this.template.querySelector(".reject-modal").closeModal();
        }
        finally {
            this.loading = false;
        }
    }

    reassignUser;
    disableReassignButton = true;

    selectHandler(event) {
        this.reassignUser = event.detail;
        this.disableReassignButton = this.reassignUser == null;
    }

    removeHandler(event) {
        this.reassignUser = null;
        this.disableReassignButton = true;
    }

}