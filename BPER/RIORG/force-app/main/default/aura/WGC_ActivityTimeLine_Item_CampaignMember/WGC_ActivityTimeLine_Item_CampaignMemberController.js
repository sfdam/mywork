({
	doInit: function (component, event, helper) {
		
        let itemDetail = component.get('v.itemDetail');
        var Opportunita = false;
        var Campagna = false;
        var Evento = false;
        var today = new Date();
        var date = today.getFullYear()+'-'+(today.getMonth()+1)+'-'+today.getDate();
        if(itemDetail.Status == 'Eliminato' && itemDetail.Status__original != 'Eliminato') itemDetail.notShow = true;
        //aggiunto verifica su Status__original
        if(itemDetail.Status == 'Sent' && itemDetail.Status__original != 'Sent') itemDetail.notShow = true;
        /*console.log('IE OPPOrtunita: ',Opportunita);
        console.log('IE ItemDetail: ',itemDetail);
        console.log('IE ItemDetail status: ',itemDetail.Status);
        console.log('IE ItemDetail enddate: ',itemDetail.Campaign.CRM_EndDateFormula__c);*/
        if((itemDetail.Status__original == 'Da Contattare' || itemDetail.Status__original == 'Da proporre' || itemDetail.Status__original == 'Sent'|| itemDetail.Status__original == 'Inviato') && itemDetail.Campaign.CRM_EndDateFormula__c && itemDetail.Campaign.CRM_EndDateFormula__c < date  ) 
        {
            Opportunita = true;
            if(itemDetail.Campaign.RecordType.DeveloperName.includes('Trigger'))
            {
                Evento = true;
            }
            else
            {
                Campagna = true;
            }
        }
        //console.log('IE OPPOrtunita Dopo: ',Opportunita);
        itemDetail.Opportunita = Opportunita;
        component.set('v.itemDetail', itemDetail);
        component.set('v.Opportunita', Opportunita);
        component.set('v.Campagna', Campagna);
        component.set('v.Evento', Evento);
	},

	showArticle : function(component, event, helper) {
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