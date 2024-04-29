import { LightningElement, track, api, wire } from 'lwc';
import {reduceErrors} from 'c/utils';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getEnhancedRecordList from '@salesforce/apex/EnhancedRecordListControllerWithS.getEnhancedRecordList';
import getTotalRecords from '@salesforce/apex/EnhancedRecordListControllerWithS.getTotalRecords';

const CUSTOM_VIEW = "Custom View";

export default class EnhancedRecordList extends LightningElement {

    /***********************************************************************
    *  TABLE
    ************************************************************************/
    loaded = false;
    configurationData;
    columns = [];
    rows = [];
    objectLabel;
    objectLabelPlural;
    totalLabel;
    fieldUrlColumns = [];


    @api hideViewSelection = false;

    @api
    get configuration() {
        return this.configurationData;
    }

    set configuration(value) {
        if(value) {
            this.configurationData = {
                targetObject: value?.targetObject,
                targetFields: value?.targetFields ?? [],
                distinctTargetOrderByField: value?.distinctTargetOrderByField ?? "Id",
                targetOrderByField: value?.targetOrderByField ?? "Id",
                ascending: value?.ascending ?? false,
                entriesForPage: value?.entriesForPage ?? 25,
                showRowActions: value?.showRowActions ?? false,
                actions: value?.actions ?? [],
                filterGroups: value?.filterGroups ?? [],
                nullsFirst: value?.nullsFirst ?? false,
                viewOptions: value?.viewOptions ?? [],
                currentView: value?.currentView,
                forEachRow: value?.forEachRow,
                totalLabel: value?.totalLabel
            }

            if(this.configurationData.targetObject && this.configurationData.targetObject.length > 0) {
                this.init();
            }
        }
    }

    async init() {
        try {
            this.loaded = false;

            /* NULL VALUE FILTER FOR SORTING FIELDS *******************************************************************/
            const filterGroups = [...this.configuration.filterGroups];

            filterGroups.push({
                logicalOperator: "AND",
                filters: [{fieldName: this.configuration.distinctTargetOrderByField, fieldValue: null, filterType: 'NOT_EQUAL'}, {fieldName: this.configuration.targetOrderByField, fieldValue: null, filterType: 'NOT_EQUAL'}]
            });
            /**********************************************************************************************************/

            await this.initTable(this.configuration.targetObject, this.configuration.targetFields, filterGroups, this.configuration.distinctTargetOrderByField, this.configuration.targetOrderByField, this.configuration.ascending, this.configuration.entriesForPage, [], [], this.configuration.actions, this.configuration.showRowActions, this.configuration.nullsFirst, this.configuration.viewOptions, this.configuration.currentView);
            this.initSearchFilter();
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: 'error', title: 'Error', message: `${reduceErrors(error)}`}));
        }
        finally {
            this.loaded = true;
        }
    }

    async initTable(targetObject, targetFields, filterGroups, distinctTargetOrderByField, targetOrderByField, ascending, entriesForPage, firstValueOfSortedFields, lastValueOfSortedFields, actions, showRowActions, nullsFirst, viewOptions, currentView) {
        this.pagination = {
            totalEntries: await getTotalRecords({targetObject: targetObject, filterGroups: filterGroups}),
            entriesForPage: entriesForPage,
            currentPage: 1
        };

        this.rowNumberOffset = 0;

        const enhancedRecordList = await getEnhancedRecordList({targetObject: targetObject, targetFields: targetFields, filterGroups: filterGroups, distinctTargetOrderByField: distinctTargetOrderByField, targetOrderByField: targetOrderByField, ascending: ascending, entriesForPage: entriesForPage, firstValueOfSortedFields: firstValueOfSortedFields, lastValueOfSortedFields: lastValueOfSortedFields, nullsFirst: nullsFirst});
        this.objectLabel = enhancedRecordList.objectLabel ?? "Entry";
        this.objectLabelPlural = enhancedRecordList.objectLabelPlural ?? "Entries";
        this.totalLabel = this.configurationData.totalLabel ?? this.objectLabelPlural;

        this.currentView = currentView;
        this.viewOptions = JSON.parse(JSON.stringify(viewOptions));
        this.customViewOptions = enhancedRecordList.columns.map(column => {return {label: column.label, value: column.fieldName};});
        const customView = this.viewOptions.find(view => view.value === CUSTOM_VIEW);
        this.customViewFields = customView.fields;
        this.showRowActionButton = customView.showRowActionButton;

        if(this.viewOptions?.length > 0) {
            const viewOption = viewOptions.find(view => view.value === currentView) ?? viewOptions[0];
            this.columns = viewOption.fields.map(field => enhancedRecordList.columns.find(column => column.fieldName === field));
        }
        else {
            this.columns = [...enhancedRecordList.columns];
        }

        this.fieldUrlColumns = [];

        this.columns.forEach(column => {
            if(column.isLinkable) {
                column.typeAttributes = {label: {fieldName: column.fieldName, type: column.type}, target: '_blank', tooltip: `${column.tooltipLabel} detail`};
                column.type = "url";
                column.fieldName = `${column.fieldName}-${column.fieldUrl}`;
                this.fieldUrlColumns.push({column: column.fieldName, fieldUrl: column.fieldUrl});
            }
        });

        this.rows = [...enhancedRecordList.rows];

        if(this.configurationData.forEachRow) {
            this.rows.forEach(row => this.configurationData.forEachRow(row));
        }

        if(this.fieldUrlColumns.length > 0) {
            this.rows.forEach(row => this.fieldUrlColumns.forEach(fieldUrlColumn => row[fieldUrlColumn.column] = `/${row[fieldUrlColumn.fieldUrl]}`));
        }

        if(showRowActions && (this.currentView !== CUSTOM_VIEW || (this.currentView === CUSTOM_VIEW && this.showRowActionButton))) {
            this.columns.push({type: "action", typeAttributes: {rowActions: actions}});
        }

        this.defaultSortDirection = ascending ? "asc" : "desc";
        this.sortDirection = this.defaultSortDirection;
        this.sortedBy = targetOrderByField;
    }

    initSearchFilter() {
        const searchableLabels = [];
        this.searchableFilters = [];
        this.searchFilterInput = "";
        this.searchTooltipText = "";

        this.configuration.targetFields.forEach(field => {
            if(this.columns.some(column => column.searchable === true && ((column.fieldName === field.fieldName && column.type === 'text') || (column.isLinkable && column.typeAttributes.label.fieldName === field.fieldName && column.typeAttributes.label.type === 'text')))) {
                this.searchableFilters.push(field.fieldName);

                const fieldLabel = this.columns.find(column => (column.fieldName === field.fieldName && column.type === 'text') || (column.isLinkable && column.typeAttributes.label.fieldName === field.fieldName && column.typeAttributes.label.type === 'text'))?.label;

                if(fieldLabel) {
                    searchableLabels.push(fieldLabel);
                }
            }
        });

        if(searchableLabels.length > 0) {
            this.searchTooltipText = `${searchableLabels.join(", ")} ${searchableLabels.length === 1 ? "is" : "are"} the only searchable ${searchableLabels.length === 1 ? "field" : "fields"}.`
        }
    }

    /***********************************************************************
    *  ROW ACTIONS
    ************************************************************************/
    handleRowActions(event) {
        this.dispatchEvent(new CustomEvent('rowactions', {detail: event.detail}));
    }

    /***********************************************************************
    *  SEARCH
    ************************************************************************/
    searchFilterInput;
    searchTooltipText;
    searchableFilters;

    async searchHandler(event) {
        try {
            event.stopPropagation();
            this.loaded = false;
            this.searchFilterInput = event?.target?.value; //event?.detail?.value;

            //if ((this.searchableFilters != null && this.searchableFilters.length > 0) && (this.searchFilterInput == null || this.searchFilterInput?.length === 0 || this.searchFilterInput?.length >= 3)) {
            if (this.searchableFilters != null && this.searchableFilters.length > 0) {
                const filterGroups = [...this.configuration.filterGroups];

                if(this.searchFilterInput?.length > 0) {
                    filterGroups.push({
                        logicalOperator: "OR",
                        filters: this.searchableFilters.map(searchableFilter => {return {fieldName: searchableFilter, fieldValue: this.searchFilterInput, filterType: 'LIKE'}})
                    });
                }

                /* NULL VALUE FILTER FOR SORTING FIELDS ***************************************************************/
                filterGroups.push({
                    logicalOperator: "AND",
                    filters: [{fieldName: this.configuration.distinctTargetOrderByField, fieldValue: null, filterType: 'NOT_EQUAL'}, {fieldName: this.configuration.targetOrderByField, fieldValue: null, filterType: 'NOT_EQUAL'}]
                });
                /******************************************************************************************************/

                await this.initTable(this.configuration.targetObject, this.configuration.targetFields, filterGroups, this.configuration.distinctTargetOrderByField, this.configuration.targetOrderByField, this.configuration.ascending, this.configuration.entriesForPage, [], [], this.configuration.actions, this.configuration.showRowActions, this.configuration.nullsFirst, this.viewOptions, this.currentView);
            }
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: 'error', title: 'Error', message: `${reduceErrors(error)}`}));
        }
        finally {
            this.loaded = true;
        }
    }

    get searchFilterInputIsDisabled() {
        return !(this.searchableFilters?.length > 0)
    }

    /***********************************************************************
    *  SORT
    ************************************************************************/
    defaultSortDirection = 'asc';
    sortDirection = 'asc';
    sortedBy;

    async handleSort(event) {
        try {
            this.loaded = false;
            const targetColumn = this.columns.find(column => column.fieldName === event.detail.fieldName);
            const targetOrderByField = targetColumn.isLinkable ? targetColumn.typeAttributes.label.fieldName : event.detail.fieldName;
            const ascending = targetColumn.isLinkable = this.sortDirection !== "asc";
            const filterGroups = [...this.configuration.filterGroups];

            /* NULL VALUE FILTER FOR SORTING FIELDS *******************************************************************/
            filterGroups.push({
                logicalOperator: "AND",
                filters: [{fieldName: this.configuration.distinctTargetOrderByField, fieldValue: null, filterType: 'NOT_EQUAL'}, {fieldName: targetOrderByField, fieldValue: null, filterType: 'NOT_EQUAL'}]
            });
            /**********************************************************************************************************/

            if (this.searchableFilters != null && this.searchableFilters.length > 0 && this.searchFilterInput?.length > 0) {
                filterGroups.push({
                    logicalOperator: "OR",
                    filters: this.searchableFilters.map(searchableFilter => {return {fieldName: searchableFilter, fieldValue: this.searchFilterInput, filterType: 'LIKE'}})
                });
            }

            await this.initTable(this.configuration.targetObject, this.configuration.targetFields, filterGroups, this.configuration.distinctTargetOrderByField, targetOrderByField, ascending, this.configuration.entriesForPage, [], [], this.configuration.actions, this.configuration.showRowActions, this.configuration.nullsFirst, this.viewOptions, this.currentView);
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: 'error', title: 'Error', message: `${reduceErrors(error)}`}));
        }
        finally {
            this.loaded = true;
        }
    }

    /***********************************************************************
    *  VIEW
    ************************************************************************/
    currentView;
    viewOptions = [];
    customViewOptions = [];
    customViewFields = [];
    showRowActionButton = false;

    async changeViewHandler(event) {
        try {
            this.loaded = false;
            const currentView = event?.detail?.value ?? this.configuration.currentView;

            /* NULL VALUE FILTER FOR SORTING FIELDS *******************************************************************/
            const filterGroups = [...this.configuration.filterGroups];

            filterGroups.push({
                logicalOperator: "AND",
                filters: [{fieldName: this.configuration.distinctTargetOrderByField, fieldValue: null, filterType: 'NOT_EQUAL'}, {fieldName: this.configuration.targetOrderByField, fieldValue: null, filterType: 'NOT_EQUAL'}]
            });
            /**********************************************************************************************************/

            await this.initTable(this.configuration.targetObject, this.configuration.targetFields, filterGroups, this.configuration.distinctTargetOrderByField, this.configuration.targetOrderByField, this.configuration.ascending, this.configuration.entriesForPage, [], [], this.configuration.actions, this.configuration.showRowActions, this.configuration.nullsFirst, this.viewOptions, currentView);
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: 'error', title: 'Error', message: `${reduceErrors(error)}`}));
        }
        finally {
            this.loaded = true;
        }
    }

    customViewOpenModal(event) {
        this.template.querySelector('.custom-view-modal').openModal();
    }

    async customViewCloseModal(event) {
        try {
            this.template.querySelector('.custom-view-modal').closeModal();
            this.loaded = false;
            if(this.currentView === CUSTOM_VIEW) {
                /* NULL VALUE FILTER FOR SORTING FIELDS *******************************************************************/
                const filterGroups = [...this.configuration.filterGroups];

                filterGroups.push({
                    logicalOperator: "AND",
                    filters: [{fieldName: this.configuration.distinctTargetOrderByField, fieldValue: null, filterType: 'NOT_EQUAL'}, {fieldName: this.configuration.targetOrderByField, fieldValue: null, filterType: 'NOT_EQUAL'}]
                });
                /**********************************************************************************************************/

                await this.initTable(this.configuration.targetObject, this.configuration.targetFields, filterGroups, this.configuration.distinctTargetOrderByField, this.configuration.targetOrderByField, this.configuration.ascending, this.configuration.entriesForPage, [], [], this.configuration.actions, this.configuration.showRowActions, this.configuration.nullsFirst, this.viewOptions, this.currentView);
            }

            const eventDetail = {detail: {customView: this.viewOptions.find(view => view.value === CUSTOM_VIEW)}};
            this.dispatchEvent(new CustomEvent('savecustomview', eventDetail));
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: 'error', title: 'Error', message: `${reduceErrors(error)}`}));
        }
        finally {
            this.loaded = true;
        }
    }

    changeCustomViewFieldsHandler(event) {
        this.customViewFields =  event?.detail?.value ?? [];
        this.viewOptions.find(viewOption => viewOption.value === CUSTOM_VIEW).fields = this.customViewFields;
    }

    showRowActionButtonHandler(event) {
        this.showRowActionButton = event?.detail?.checked ?? false;
        this.viewOptions.find(viewOption => viewOption.value === CUSTOM_VIEW).showRowActionButton = this.showRowActionButton;
    }

    /***********************************************************************
    *  PAGINATION
    ************************************************************************/
    rowNumberOffset = 0;

    @track paginationDetails = {
        totalPages: 0,
        totalEntries: 0,
        entriesForPage: 0,
        currentPage: 0,
        firstPageButtonDisabled: true,
        previousPageButtonDisabled: true,
        nextPageButtonDisabled: true,
        lastPageButtonDisabled: true
    };

    @api get pagination() {
        return this.paginationDetails;
    }

    set pagination(value) {
        let totalEntries = 0;
        let entriesForPage = 0;
        let currentPage = 0;
        let totalPages = 0;

        if(value != null && value.totalEntries != null && value.totalEntries > 0 && value.entriesForPage != null && value.entriesForPage > 0 && value.currentPage != null && value.currentPage > 0) {
            const totalEntriesQuotient = Math.floor(value.totalEntries / value.entriesForPage);
            const totalEntriesRemainder = Math.floor(value.totalEntries % value.entriesForPage);
            totalPages = totalEntriesQuotient + (totalEntriesRemainder > 0 ? 1 : 0);
            totalEntries = value.totalEntries;
            entriesForPage = value.entriesForPage;
            currentPage = value.currentPage;
        }

        this.paginationDetails = {
            totalEntries: totalEntries,
            entriesForPage: entriesForPage,
            currentPage: currentPage,
            totalPages: totalPages
        };

        this.updatePaginationButtons();
    }

    updatePaginationButtons() {
        this.paginationDetails.firstPageButtonDisabled = this.paginationDetails.totalPages <= 1 || this.paginationDetails.currentPage <= 1;
        this.paginationDetails.previousPageButtonDisabled = this.paginationDetails.totalPages <= 1 || this.paginationDetails.currentPage <= 1;
        this.paginationDetails.nextPageButtonDisabled = this.paginationDetails.totalPages <= 1 || this.paginationDetails.currentPage >= this.paginationDetails.totalPages;
        this.paginationDetails.lastPageButtonDisabled = this.paginationDetails.totalPages <= 1 || this.paginationDetails.currentPage >= this.paginationDetails.totalPages;
    }

    firstPageButtonHandler(event) {
        this.jumpToPage(1);
    }

    previousPageButtonHandler(event) {
        if(this.pagination.currentPage > 1) {
            this.jumpToPage(this.pagination.currentPage - 1);
        }
    }

    lastPageButtonHandler(event) {
        this.jumpToPage(this.pagination.totalPages);
    }

    nextPageButtonHandler(event) {
        if(this.pagination.currentPage < this.pagination.totalPages) {
            this.jumpToPage(this.pagination.currentPage + 1);
        }
    }

    async jumpToPage(page) {
        try {
            this.loaded = false;
            if(this.pagination.totalPages > 0 && (page >= 1 || page <= this.pagination.totalPages)) {
                let ascending = this.sortDirection === "asc";
                let nullsFirst = this.configuration.nullsFirst;
                let reverse = false;
                let entriesForPage = this.configuration.entriesForPage;
                const filterGroups = [...this.configuration.filterGroups];
                const lastValueOfSortedFields = [];
                const firstValueOfSortedFields = [];
                const targetOrderByField = this.sortedBy;

                if(page === 1) {
                    this.rowNumberOffset = 0;
                }
                else if(page === this.pagination.totalPages) {
                    ascending = !ascending;
                    nullsFirst = !nullsFirst;
                    entriesForPage = entriesForPage === this.pagination.entriesForPage ? this.pagination.entriesForPage : Math.floor(this.pagination.totalEntries % this.pagination.entriesForPage);
                    this.rowNumberOffset = this.pagination.totalEntries - entriesForPage;
                    reverse = true;
                }
                else if(page > this.pagination.currentPage) {
                    lastValueOfSortedFields.push({fieldName: this.configuration.distinctTargetOrderByField, fieldValue: this.rows[this.rows.length - 1][this.configuration.distinctTargetOrderByField]});
                    lastValueOfSortedFields.push({fieldName: targetOrderByField, fieldValue: this.rows[this.rows.length - 1][targetOrderByField]});
                    this.rowNumberOffset = (page - 1) * entriesForPage;
                }
                else if(page < this.pagination.currentPage) {
                    firstValueOfSortedFields.push({fieldName: this.configuration.distinctTargetOrderByField, fieldValue: this.rows[0][this.configuration.distinctTargetOrderByField]});
                    firstValueOfSortedFields.push({fieldName: targetOrderByField, fieldValue: this.rows[0][targetOrderByField]});
                    this.rowNumberOffset = (page - 1) * entriesForPage;
                    reverse = true;
                }

                if (this.searchableFilters != null && this.searchableFilters.length > 0 && this.searchFilterInput?.length > 0) {
                    filterGroups.push({
                        logicalOperator: "OR",
                        filters: this.searchableFilters.map(searchableFilter => {return {fieldName: searchableFilter, fieldValue: this.searchFilterInput, filterType: 'LIKE'}})
                    });
                }

                filterGroups.push({
                    logicalOperator: "AND",
                    filters: [{fieldName: this.configuration.distinctTargetOrderByField, fieldValue: null, filterType: 'NOT_EQUAL'}, {fieldName: targetOrderByField, fieldValue: null, filterType: 'NOT_EQUAL'}]
                });

                //console.log('---> filterGroups: ' + JSON.stringify(filterGroups));
                //console.log('---> firstValueOfSortedFields: ' + JSON.stringify(firstValueOfSortedFields));
                //console.log('---> lastValueOfSortedFields: ' + JSON.stringify(lastValueOfSortedFields));

                const enhancedRecordList = await getEnhancedRecordList({targetObject: this.configuration.targetObject, targetFields: this.configuration.targetFields, filterGroups: filterGroups, distinctTargetOrderByField: this.configuration.distinctTargetOrderByField, targetOrderByField: targetOrderByField, ascending: ascending, entriesForPage: entriesForPage, firstValueOfSortedFields: firstValueOfSortedFields, lastValueOfSortedFields: lastValueOfSortedFields, nullsFirst});
                this.rows = reverse ? [...enhancedRecordList.rows].reverse() : [...enhancedRecordList.rows];

                if(this.configurationData.forEachRow) {
                    this.rows.forEach(row => this.configurationData.forEachRow(row));
                }

                if(this.fieldUrlColumns.length > 0) {
                    this.rows.forEach(row => this.fieldUrlColumns.forEach(fieldUrlColumn => row[fieldUrlColumn.column] = `/${row[fieldUrlColumn.fieldUrl]}`));
                }
                this.pagination.currentPage = page;
                this.updatePaginationButtons();
            }
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: 'error', title: 'Error', message: `${reduceErrors(error)}`}));
        }
        finally {
            this.loaded = true;
        }
    }
}