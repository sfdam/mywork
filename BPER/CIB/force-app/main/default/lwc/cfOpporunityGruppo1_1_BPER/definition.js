let definition =
      {"states":[{"fields":[],"conditions":{"id":"state-condition-object","isParent":true,"group":[]},"definedActions":{"actions":[]},"name":"Active","isSmartAction":false,"smartAction":{},"styleObject":{"padding":[{"type":"around","size":"x-small"}],"margin":[{"type":"bottom","size":"x-small"}],"container":{"class":"slds-card"},"size":{"isResponsive":false,"default":"12"},"sizeClass":"slds-size_12-of-12","class":"slds-card slds-p-around_x-small slds-m-bottom_x-small"},"components":{"layer-0":{"children":[{"name":"Icon","element":"flexIcon","size":{"isResponsive":false,"default":"1"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","card":"{card}","color":"","iconType":"Salesforce SVG","iconName":"standard:opportunity","size":"small","extraclass":"slds-icon_container slds-icon-standard-account","variant":"inverse","imgsrc":""},"type":"element","styleObject":{"sizeClass":"slds-size_1-of-12 ","size":{"isResponsive":false,"default":"1"},"padding":[],"margin":[],"background":{"color":"","image":"","size":"","repeat":"","position":""},"container":{"class":""},"border":{"type":"","width":"","color":"","radius":"","style":""},"elementStyleProperties":{"color":""},"text":{"align":"center","color":""},"inlineStyle":"","class":"slds-text-align_center ","style":"      \n         "},"elementLabel":"Icon-0","styleObjects":[{"key":0,"conditions":"default","styleObject":{"sizeClass":"slds-size_1-of-12 ","size":{"isResponsive":false,"default":"1"},"padding":[],"margin":[],"background":{"color":"","image":"","size":"","repeat":"","position":""},"container":{"class":""},"border":{"type":"","width":"","color":"","radius":"","style":""},"elementStyleProperties":{"color":""},"text":{"align":"center","color":""},"inlineStyle":"","class":"slds-text-align_center ","style":"      \n         "},"label":"Default","name":"Default","conditionString":"","draggable":false}]},{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":"2"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Cdiv%3E%3Cspan%20style=%22font-size:%2012pt;%22%3E%3Cstrong%3EOpportunit&agrave;%3C/strong%3E%3C/span%3E%3C/div%3E","card":"{card}"},"type":"text","styleObject":{"sizeClass":"slds-size_2-of-12 ","size":{"isResponsive":false,"default":"2"}},"elementLabel":"Text-1"},{"name":"Action","element":"action","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"label":"Action","iconName":"standard-default","record":"{record}","card":"{card}","stateObj":"{record}","actionList":[{"stateAction":{"id":"flex-action-1700040163723","type":"Event","openUrlIn":"Current Window","subType":"Custom","eventName":"{recordId}","composed":false,"bubbles":true},"key":"1699889311417-qnpkrq83r","label":"Action","draggable":true,"isOpen":true,"actionIndex":0,"isTrackingDisabled":true}],"showSpinner":"false","iconOnly":true,"hideActionIcon":true,"displayAsButton":false,"flyoutDetails":{}},"type":"element","styleObject":{"sizeClass":"slds-size_12-of-12"},"elementLabel":"Action-2"},{"name":"Datatable","element":"flexDatatable","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","card":"{card}","issearchavailable":false,"issortavailable":true,"cellLevelEdit":true,"pagelimit":3,"groupOrder":"asc","tablename":"Opportunità","userSelectableRow":true,"rowLevelEdit":true,"draggable":false,"hideTableHeader":false,"styles":{"cellMargin":[],"cellPadding":[],"headBgColor":"#f3f3f3"},"pagesize":"6","rowDelete":false,"userSelectableColumn":false,"fireeventOnDeleteconfirm":false,"groupBy":"","extraclass":"","specialcharactersort":false,"rowDeleteDependentColumn":"","confirmdeleterow":false,"columns":[{"fieldName":"Nome","label":"Nome","searchable":"false","sortable":true,"type":"url","userSelectable":"true"},{"fieldName":"Nome Account","label":"Nome Account","searchable":false,"sortable":true,"type":"text"},{"fieldName":"Stage","label":"Stage","searchable":false,"sortable":true,"type":"text"},{"fieldName":"OpportunityId","label":"Id","searchable":true,"sortable":true,"type":"url","userSelectable":"true"},{"fieldName":"Link","label":"Link","searchable":true,"sortable":true,"type":"icon","editable":"false","userSelectable":"true"}],"records":"{records}"},"type":"element","styleObject":{"sizeClass":"slds-size_12-of-12 ","padding":[],"margin":[],"background":{"color":"","image":"","size":"","repeat":"","position":""},"size":{"isResponsive":false,"default":"12"},"container":{"class":""},"border":{"type":"","width":"","color":"","radius":"","style":""},"elementStyleProperties":{"styles":{"cellMargin":[],"cellPadding":[],"headBgColor":"#f3f3f3"}},"text":{"align":"","color":""},"inlineStyle":"","class":"","style":"      \n         "},"elementLabel":"Datatable-3","styleObjects":[{"key":0,"conditions":"default","styleObject":{"sizeClass":"slds-size_12-of-12 ","padding":[],"margin":[],"background":{"color":"","image":"","size":"","repeat":"","position":""},"size":{"isResponsive":false,"default":"12"},"container":{"class":""},"border":{"type":"","width":"","color":"","radius":"","style":""},"elementStyleProperties":{"styles":{"cellMargin":[],"cellPadding":[],"headBgColor":"#f3f3f3"}},"text":{"align":"","color":""},"inlineStyle":"","class":"","style":"      \n         "},"label":"Default","name":"Default","conditionString":"","draggable":false}]},{"name":"Action","element":"action","size":{"isResponsive":false,"default":"2"},"stateIndex":0,"class":"slds-col ","property":{"label":"View","iconName":"View","record":"{record}","card":"{card}","stateObj":"{record}","actionList":[{"stateAction":{"id":"flex-action-1699884079255","type":"Custom","targetType":"Object","openUrlIn":"Current Window","Object":{"targetName":"Opportunity","targetAction":"home"}},"key":"1699884041391-gkpell3ny","label":"Action","draggable":true,"isOpen":true,"actionIndex":0}],"showSpinner":"false","flyoutDetails":{},"displayAsButton":true},"type":"element","styleObject":{"sizeClass":"slds-size_2-of-12 ","size":{"isResponsive":false,"default":"2"}},"elementLabel":"Action-4"},{"name":"Text","element":"outputField","size":{"isResponsive":false,"default":"12"},"stateIndex":0,"class":"slds-col ","property":{"record":"{record}","mergeField":"%3Cdiv%3E%7BDatatable.recordsFound%7D%3C/div%3E","card":"{card}"},"type":"text","styleObject":{"sizeClass":"slds-size_12-of-12"},"elementLabel":"Text-5"}]}},"childCards":[],"actions":[],"omniscripts":[],"documents":[]}],"dataSource":{"type":"DataRaptor","value":{"dsDelay":"","bundle":"DataRaptor_OpportunityGroup","bundleType":"","inputMap":{"Id":"{recordId}"},"jsonMap":"{\"recordId\":\"{recordId}\"}","resultVar":""},"orderBy":{"name":"","isReverse":""},"contextVariables":[]},"title":"OpporunityGruppo1","enableLwc":true,"isFlex":true,"theme":"slds","selectableMode":"Multi","lwc":{"DeveloperName":"cfOpporunityGruppo1_1_BPER","Id":"0RbMT000000CiF10AK","MasterLabel":"cfOpporunityGruppo1_1_BPER","NamespacePrefix":"c","ManageableState":"unmanaged"},"isRepeatable":false,"listenToWidthResize":true,"sessionVars":[{"name":"RecordsFound","val":"{records}"}],"events":[{"eventname":"View","channelname":"Opportunity_{recordId}","element":"action","eventtype":"pubsub","recordIndex":"0","actionList":[{"key":"1699615192298-zlsxk9z6r","label":"Action","draggable":false,"isOpen":true,"card":"{card}","stateAction":{"id":"flex-action-1699885330148","type":"Custom","displayName":"Action","vlocityIcon":"standard-default","openUrlIn":"New Tab/Window","targetType":"Record","Record":{"targetName":"Opportunity","targetAction":"view","targetId":"{OpportunityId}"}},"actionIndex":0,"isTrackingDisabled":true}],"showSpinner":"false","recordId":"OpportunityId","sobject":"Opportunity","selectedFields":"Name","optionalFields":"Opportunity.Name","key":"event-0","displayLabel":"Opportunity_{recordId}:View","eventLabel":"pubsub"}],"hideChildCardPreview":false,"dynamicCanvasWidth":{"type":"desktop"},"Name":"OpporunityGruppo1","uniqueKey":"OpporunityGruppo1_1_BPER","Id":"0koMT000000000BYAQ","OmniUiCardKey":"OpporunityGruppo1/BPER/1.0","OmniUiCardType":"Parent"};
  export default definition