let definition =
      {"states":[{"fields":[],"conditions":{"id":"state-condition-object","isParent":true,"group":[]},"definedActions":{"actions":[]},"name":"Active","isSmartAction":false,"smartAction":{},"styleObject":{"padding":[{"type":"around","size":"x-small"}],"margin":[{"type":"bottom","size":"x-small"}],"container":{"class":"slds-card"},"size":{"isResponsive":false,"default":"12"},"sizeClass":"slds-size_12-of-12","class":"slds-card slds-p-around_x-small slds-m-bottom_x-small"},"components":{"layer-0":{"children":[{"name":"Formatecnica__c","element":"outputField","size":{"isResponsive":false,"default":"5"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"Formatecnica__c","label":"Formatecnica__c","card":"{card}","type":"text"},"type":"field","styleObject":{"sizeClass":"slds-size_5-of-12 ","size":{"isResponsive":false,"default":"5"}},"elementLabel":"Formatecnica__c-0"},{"name":"Interessi_attivi__c","element":"outputField","size":{"isResponsive":false,"default":7},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"Interessi_attivi__c","label":"Interessi_attivi__c","card":"{card}","type":"number"},"type":"field","styleObject":{"size":{"isResponsive":false,"default":7},"sizeClass":"slds-size_7-of-12"},"elementLabel":"Interessi_attivi__c-1"},{"name":"Tipo_di_ammortamento__c","element":"outputField","size":{"isResponsive":false,"default":"5"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"Tipo_di_ammortamento__c","label":"Tipo_di_ammortamento__c","card":"{card}","type":"text"},"type":"field","styleObject":{"sizeClass":"slds-size_5-of-12 ","size":{"isResponsive":false,"default":"5"}},"elementLabel":"Tipo_di_ammortamento__c-2"},{"name":"Costo_del_funding__c","element":"outputField","size":{"isResponsive":false,"default":7},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"Costo_del_funding__c","label":"Costo_del_funding__c","card":"{card}","type":"number"},"type":"field","styleObject":{"size":{"isResponsive":false,"default":7},"sizeClass":"slds-size_7-of-12"},"elementLabel":"Costo_del_funding__c-3"},{"name":"Importo__c","element":"outputField","size":{"isResponsive":false,"default":"5"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"Importo__c","label":"Importo__c","card":"{card}","type":"number"},"type":"field","styleObject":{"sizeClass":"slds-size_5-of-12 ","size":{"isResponsive":false,"default":"5"}},"elementLabel":"Importo__c-4"},{"name":"Margine_di_interesse__c","element":"outputField","size":{"isResponsive":false,"default":7},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"Margine_di_interesse__c","label":"Margine_di_interesse__c","card":"{card}","type":"number"},"type":"field","styleObject":{"size":{"isResponsive":false,"default":7},"sizeClass":"slds-size_7-of-12"},"elementLabel":"Margine_di_interesse__c-5"},{"name":"Tipo_funding__c","element":"outputField","size":{"isResponsive":false,"default":"5"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"Tipo_funding__c","label":"Tipo_funding__c","card":"{card}","type":"text"},"type":"field","styleObject":{"sizeClass":"slds-size_5-of-12 ","size":{"isResponsive":false,"default":"5"}},"elementLabel":"Tipo_funding__c-6"},{"name":"Commissioni_up_front__c","element":"outputField","size":{"isResponsive":false,"default":7},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"Commissioni_up_front__c","label":"Commissioni_up_front__c","card":"{card}","type":"number"},"type":"field","styleObject":{"size":{"isResponsive":false,"default":7},"sizeClass":"slds-size_7-of-12"},"elementLabel":"Commissioni_up_front__c-7"},{"name":"Valuta__c","element":"outputField","size":{"isResponsive":false,"default":"5"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"Valuta__c","label":"Valuta__c","card":"{card}","type":"text"},"type":"field","styleObject":{"sizeClass":"slds-size_5-of-12 ","size":{"isResponsive":false,"default":"5"}},"elementLabel":"Valuta__c-8"},{"name":"Commissioni_running__c","element":"outputField","size":{"isResponsive":false,"default":"6"},"stateIndex":0,"class":"slds-col ","property":{"placeholder":"output","record":"{record}","fieldName":"Commissioni_running__c","label":"Commissioni_running__c","card":"{card}","type":"number"},"type":"field","styleObject":{"sizeClass":"slds-size_6-of-12 ","size":{"isResponsive":false,"default":"6"}},"elementLabel":"Commissioni_running__c-9"}]}},"childCards":[],"actions":[],"omniscripts":[],"documents":[]}],"dataSource":{"type":"Query","value":{"dsDelay":"","query":"SELECT Id,Formatecnica__c, Tipo_di_ammortamento__c,Importo__c,Tipo_funding__c,Valuta__c,UtilizzoPercentuale__c,Durata__c,Periodicita_rata__c,Preammortamento__c,Periodi_di_preammortamento__c,baloonFinalePercentuale__c,SAL__c,\nNumero_periodi_di_erogazione__c,Tipo_tasso__c,Indicizzazionetassovariabile__c,Spread_TassoFisso_Commdifirma__c,Capvalore__c,Floorvalore__c,Intereststep__c,TIT_base_di_partenza__c,Up_Front_perc__c,Up_Front__c,CMUannuale__c,\nCommissione_running_annuale_perc__c,Commissione_running_annuale__c,Add_on_commissionale_medio_annuo__c,Garanzia__c,Tipo_garanzia__c,Valore_del_bene_ipotecato__c,Valore_del_pegno_SACE__c,Valore_del_PegnoSACE_Perc__c, commissioneDiFirma__c,Interessi_attivi__c, Costo_del_funding__c, Margine_di_interesse__c, Commissioni_up_front__c, Commissioni_running__c, Commissioni_altro__c, Commissioni__c, Margine_di_intermediazione__c, Costo_del_rischio_lordo__c, Costo_del_capitale__c, Costi_operativi__c, Margine_operativo_netto__c from Linea__c where Id='{recordId}'","jsonMap":"{\"recordId\":\"{recordId}\"}","resultVar":""},"orderBy":{"name":"","isReverse":""},"contextVariables":[]},"title":"SintesiLinea","enableLwc":true,"isFlex":true,"theme":"slds","selectableMode":"Multi","lwc":{"DeveloperName":"cfSintesiLinea_2_BPER","Id":"0RbMT000000Ck7E0AS","MasterLabel":"cfSintesiLinea_2_BPER","NamespacePrefix":"c","ManageableState":"unmanaged"},"Name":"SintesiLinea","uniqueKey":"SintesiLinea_2_BPER","Id":"0koMT000000000aYAA","OmniUiCardKey":"SintesiLinea/BPER/2.0","OmniUiCardType":"Parent"};
  export default definition