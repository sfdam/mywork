import {LightningElement, api} from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import getStandardApprovalRequests from '@salesforce/apex/MultioptionsApprovalRequests.getStandardApprovalRequests';
import approve from '@salesforce/apex/MultioptionsApprovalRequests.approve';
import reject from '@salesforce/apex/MultioptionsApprovalRequests.reject';
import reassign from '@salesforce/apex/MultioptionsApprovalRequests.reassign';

const COLUMNS = [
    {fieldName: "caseLink", type: "url", label: "Related To", sortable: true, typeAttributes: {label: {fieldName: "relatedTo", type: "text"}, target: '_blank', tooltip: "Case details"}},
    {fieldName: "type", type: "text", label: "Type", sortable: true,},
    {fieldName: "submittedBy", type: "text", label: "Submitted By", sortable: true,},
    {fieldName: "dateSubmitted", type: "date", label: "Date Submitted", sortable: true, typeAttributes:{year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit"}},
    {fieldName: "submitterComments", type: "text", label: "Submitter Comments", sortable: true,},
];

const GENERIC_ERROR_MESSAGE = "Si è verificato un errore";
const GENERIC_SUCCESS_MESSAGE = "Operazione completata!";

export default class StandardApprovalRequests extends NavigationMixin(LightningElement) {
    loading = false;
    columns = COLUMNS;
    rows = [];
    defaultSortDirection = "asc";
    sortDirection = "asc";
    sortedBy = "relatedTo";
    rowNumberOffset = 0;
    disableButtons = false;
    selectedRows = [];
    headerLabel;

    connectedCallback() {
        this.init();
    }

    async init() {
        try {
            this.loading = true;
            this.disableButtons = true;
            this.rows = [];
            const standardApprovalRequests = await getStandardApprovalRequests();
            //console.log(JSON.stringify(standardApprovalRequests));

            for (let workitem of standardApprovalRequests?.processInstanceWorkitems) {
                this.rows.push({
                    Id: workitem.Id,
                    processInstanceId: workitem.ProcessInstanceId,
                    caseId: workitem.ProcessInstance.TargetObject.Id,
                    caseLink: await this[NavigationMixin.GenerateUrl]({type: "standard__recordPage", attributes: {recordId: workitem.ProcessInstance.TargetObject.Id, actionName: "view"}}),
                    relatedTo: workitem.ProcessInstance.TargetObject.Name,
                    type: workitem.ProcessInstance.TargetObject.Type,
                    submittedBy: workitem.ProcessInstance.SubmittedBy.Name,
                    submitterComments: standardApprovalRequests.processInstanceSteps.find(step => step.ProcessInstanceId === workitem.ProcessInstanceId && step.ActorId === workitem.ProcessInstance.SubmittedBy.Id)?.comments,
                    dateSubmitted: workitem.ProcessInstance.CreatedDate
                });
            }

            this.rows.sort((rowA, rowB) => rowA[this.sortedBy] == null ? 1 : rowA[this.sortedBy].localeCompare(rowB[this.sortedBy], undefined, {sensitivity: 'base'}));
            this.headerLabel = `${this.rows.length} elementi • 0 selezionati`;
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}));
        }
        finally {
            this.loading = false;
        }
    }

    handleRowActions(event) {
        // TODO
    }

    handleSort(event) {
        this.loading = true;
        this.sortedBy = event.detail.fieldName === "caseLink" ? "relatedTo" : event.detail.fieldName;
        this.sortDirection = this.sortedBy === "relatedTo" ? (this.sortDirection === "asc" ? "desc" : "asc") : event.detail.sortDirection;

        if(this.rows?.length > 0) {
            const rows = [...this.rows];
            rows.sort((rowA, rowB) => rowA[this.sortedBy] == null ? 1 : rowA[this.sortedBy].localeCompare(rowB[this.sortedBy], undefined, {sensitivity: 'base'}));
            this.rows = this.sortDirection === "asc" ? rows : rows.reverse();
            this.loading = false;
        }
    }

    handleRowSelection(event) {
        this.selectedRows = this.template.querySelector("lightning-datatable")?.getSelectedRows();
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
            const commentsLightningTextarea = this.template.querySelector(".comments lightning-textarea");

            if(commentsLightningTextarea.reportValidity()) {
                const processInstanceWorkitemIds = this.selectedRows.map(row => row.Id);
                const result = JSON.parse(await approve({processInstanceWorkitemIds: processInstanceWorkitemIds, comments: (commentsLightningTextarea.value?.length > 0 ? commentsLightningTextarea.value : "")}));
                const notApprovedCaseIds = result.filter(item => item.success === false)?.map(item => item.entityId);

                if(notApprovedCaseIds?.length > 0) {
                    throw new Error(GENERIC_ERROR_MESSAGE);
                    console.error(notApprovedCaseIds);
                }
                else {
                    this.dispatchEvent(new ShowToastEvent({variant: "success", title: "Success", message: GENERIC_SUCCESS_MESSAGE}));
                }

                await this.init();
                this.template.querySelector(".approve-modal").closeModal();
            }
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}));
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
                const notRejectedCaseIds = result.filter(item => item.success === false)?.map(item => item.entityId);

                if(notRejectedCaseIds?.length > 0) {
                    throw new Error(GENERIC_ERROR_MESSAGE);
                    console.error(notRejectedCaseIds);
                }
                else {
                    this.dispatchEvent(new ShowToastEvent({variant: "success", title: "Success", message: GENERIC_SUCCESS_MESSAGE}));
                }

                await this.init();
                this.template.querySelector(".reject-modal").closeModal();
            }
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}));
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

    async reassignHandler(event) {
        try {
            this.loading = true;
            if(this.reassignUser?.value) {
                const processInstanceWorkitemIds = this.selectedRows.map(row => row.Id);
                await reassign({processInstanceWorkitemIds: processInstanceWorkitemIds, userId: this.reassignUser.value});
                this.dispatchEvent(new ShowToastEvent({variant: "success", title: "Success", message: GENERIC_SUCCESS_MESSAGE}));
            }
            else {
                throw new Error(GENERIC_ERROR_MESSAGE);
            }
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}));
        }
        finally {
            await this.init();
            this.loading = false;
            this.template.querySelector(".reassign-modal").closeModal();
        }
    }
}