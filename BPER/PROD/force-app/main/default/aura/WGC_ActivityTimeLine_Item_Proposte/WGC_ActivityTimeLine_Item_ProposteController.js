({
    doInit: function (component, event, helper) {
		let itemDetail = component.get('v.itemDetail');
        let today = new Date();
        console.log('SR itemDetail: ', itemDetail);
        console.log('SR today: ', today);
        let DataScadenza = new Date(itemDetail.CRM_DataScadenza__c);
        console.log('SR Data Scadenza: ', DataScadenza);
        //let StatoContratto=itemDetail.CRM_StatoContratto__c;
        let StatoContratto=itemDetail.CRM_StatoContratto__c__original;
        let StatusEmpty = StatoContratto == "" || StatoContratto == null || StatoContratto == undefined;
        console.log('SR itemDetail.isTracking: ', itemDetail.isTracking);
        console.log('SR Data scadenza >= TODAY: ', DataScadenza >= today);
        console.log('SR Data scadenza < TODAY: ', DataScadenza < today);
        console.log('SR Stato Contratto vuoto: ', StatusEmpty);
        if(!itemDetail.isTracking && (DataScadenza >= today ||  (DataScadenza < today && !StatusEmpty))) itemDetail.notShow = true;
        if(itemDetail.isTracking == undefined && DataScadenza >= today) itemDetail.notShow = true;
        component.set('v.itemDetail', itemDetail);
	},

	showArticle : function(component, event, helper,indexId) {
       var item = component.get('v.itemDetail');
		item.isCollapsed = !item.isCollapsed;
		component.set('v.itemDetail', item);
    },

	navigateToUser : function(component, event, helper) {

        var navService = component.find("navService");

            var pageReference = {
                type: "standard__recordPage",
                attributes: {
                    "recordId": component.get('v.itemDetail').Owner.Id,
                    "objectApiName": "User",
                    "actionName": "view"
                }
            };
             
        navService.navigate(pageReference);       
	},
	
	navigateToActivity : function(component, event, helper) {

        var navService = component.find("navService");
        

            var pageReference = {
                type: "standard__recordPage",
                attributes: {
                    "recordId": component.get('v.itemDetail').Id,
                    "objectApiName": component.get('v.itemDetail').objectType != "Event" ? "Task" : "Event",
                    "actionName": "view"
                }
            };
             
            navService.navigate(pageReference); 
        // }
      
    },
    
    navigateToNDG : function(component, event, helper) {

        var navService = component.find("navService");
        console.log(component.get('v.itemDetail').ObjectFieldLookup);
        

            var pageReference = {
                type: "standard__recordPage",
                attributes: {
                    "recordId": component.get('v.itemDetail')[component.get('v.itemDetail').ObjectFieldLookup],
                    "objectApiName": "Account",
                    "actionName": "view"
                }
            };
             
            navService.navigate(pageReference); 
        // }
      
    },

})