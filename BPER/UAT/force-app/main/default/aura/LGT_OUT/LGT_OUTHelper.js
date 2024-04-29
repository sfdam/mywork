({
    
    getAlldataHelper : function(component, event, helper) {

        component.set('v.eventsColumns', [
            {label: 'Oggetto', fieldName: 'eventsUrl', type: 'url', typeAttributes: {label: { fieldName: "EventsName"},target: "_blank"}},
            {label: 'Proprietario', fieldName: 'ownerName', type: 'text'},
            {label: 'Tipo', fieldName: 'Type', type: 'text'},
            {label: 'Canale', fieldName: 'CRM_Canale__c', type: 'text'},
            {label: 'Esito Contatto', fieldName: 'ServiceAppointment.Status', type: 'text'}
        ]);

        component.set('v.campaignsColumns', [
            {label: 'Nome', fieldName: 'campaignUrl', type: 'url', typeAttributes: {label: { fieldName: "CampaignName"},target: "_blank"}},
            {label: 'Assegnatario', fieldName: 'CRM_AssegnatarioFormula__c', type: 'text'},
            {label: 'Tipologia Campagna', fieldName: 'campaignType', type: 'text'},
            {label: 'Data Inizio', fieldName: 'campaignStartDate', type: 'date'},
            {label: 'Data Fine', fieldName: 'campaignEndDate', type: 'date'},
            {label: 'Esito Contatto', fieldName: 'CRM_Esito__c', type: 'text'}
        ]);

        component.set('v.opportunitiesColumns', [
            {label: 'Numero', fieldName: 'opportunityUrl', type: 'url', typeAttributes: {label: { fieldName: "OpportunityName"},target: "_blank"}},
            {label: 'Referente', fieldName: 'Referente__c', type: 'text'},
            {label: 'Oggetto', fieldName: 'CRM_Oggetto__c', type: 'text'},
            {label: 'Fase', fieldName: 'StageName', type: 'text'},
            {label: 'Canale', fieldName: 'CRM_Canale__c', type: 'text'},
            {label: 'Bisogno', fieldName: 'CRM_Bisogno__c', type: 'text'}
        ]);

        component.set('v.deadlinesColumns', [
            {label: 'Prodotto', fieldName: 'prductUrl', type: 'url', typeAttributes: {label: { fieldName: "productName"},target: "_blank"}},
            {label: 'Importo', fieldName: 'CRM_Importo__c', type: 'currency', typeAttributes: { currencyCode: 'EUR', maximumSignificantDigits: 5}},
            {label: 'Data', fieldName: 'CRM_FormulaData__c', type: 'date'},
            {label: 'Bisogno', fieldName: 'CRM_InfoProdottoBisogno__c', type: 'text'},
            {label: 'Esito Contatto', fieldName: 'CRM_EsitoContatto__c', type: 'text'}
        ]);

        component.set('v.memosColumns', [
            {label: 'Titolo', fieldName: 'memoUrl', type: 'url', typeAttributes: {label: { fieldName: "memoName"},target: "_blank"}},
            {label: 'Descrizione', fieldName: 'CRM_Note__c', type: 'text'},
            {label: 'Termine Validità', fieldName: 'CRM_FineValidita__c', type: 'date'},
            {label: 'Autore', fieldName: 'Autore__c', type: 'text'}
        ]);
       
        var action = component.get("c.getAllData");
        console.log('NDG** ',component.get("v.ndg"));
        console.log('ABI** ',component.get("v.abi"));
        var ndg = component.get("v.ndg");
        var abi = component.get("v.abi");
        
        
        
        
        action.setParams({ndg:ndg, abi:abi});
        action.setCallback(this, function(a){
            var rtnValue = JSON.parse(a.getReturnValue());
            var state = a.getState();
                if (state==="SUCCESS") {
                    
                    console.log('rtnValue', rtnValue);
                    if(rtnValue !== null){


                        rtnValue['events'].forEach(element => {
                            element.EventsName = element.Subject;
                            element.eventsUrl = '/' + element.Id;
                            if(element.Owner)
                                element.ownerName = element.Owner.Name;

                        });
                        component.set('v.events', rtnValue['events']);

                        rtnValue['campaigns'].forEach(element => {
                            element.CampaignName = element.Campaign.Name;
                            element.campaignUrl = '/' + element.Id;
                            element.campaignType = element.Campaign.Tipologia_Azione__c;
                            element.campaignStartDate = element.Campaign.StartDate;
                            element.campaignEndDate = element.Campaign.EndDate;
                        });
                        component.set('v.campaigns', rtnValue['campaigns']);

                        rtnValue['opportunities'].forEach(element => {
                            element.OpportunityName = element.Name;
                            element.opportunityUrl = '/' + element.Id;
                        });
                        component.set('v.opportunities', rtnValue['opportunities']);

                        rtnValue['scadenze'].forEach(element =>{
                            console.log('@@@GB: '+element.FinServ__FinancialAccount__c);
                            if(element.FinServ__FinancialAccount__c){
                                element.productName = element.FinServ__FinancialAccount__r.Name;
                                element.prductUrl = '/' + element.Id;
                            }
                        });
                        component.set('v.deadlines', rtnValue['scadenze']);

                        rtnValue['memos'].forEach(element =>{
                            element.memoName = element.Name;
                            console.log('@@@GB: '+element.CRM_Titolo__c);
                            element.memoUrl = '/' + element.Id;

                        });
                        component.set('v.memos', rtnValue['memos']); 
                    }
                }
                if (state==="ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            notifiLib.showToast({
                                title:"Errore!",
                                message:errors[0].message,
                                variant:"error"
                            });
                        }
                    } else {
                        notifiLib.showToast({
                            title:"Errore!",
                            message:"unknown error",
                            variant:"error"
                        });
                    }
                }
        });
        $A.enqueueAction(action);
    }
})