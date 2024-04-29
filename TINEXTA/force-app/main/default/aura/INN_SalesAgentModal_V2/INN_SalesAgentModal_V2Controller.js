({
	doInit : function(component, event, helper) {
        var opts = [];

        helper.apex(component, event, 'getUserInfo', { })
        .then($A.getCallback(function (result) {
            console.log('result getUserInfo', result);
            component.set('v.userInfo',result);        

            return helper.apex(component, event, 'getAgent', { "recordId": component.get("v.recordId")})
        })).then($A.getCallback(function (result) {
            console.log('result getAgents', result);
            var AgentList = result.pickData;
            var lookDefault = result.lookData;
            console.log('lookDefault', lookDefault[0]);
            component.set('v.LookupSelected',lookDefault[0]);
            var user = component.get('v.userInfo');
            component.set('v.AgentResult', result.pickData);

            if(AgentList.length<=1){
                component.set('v.disableSelect','True');
            } else {
                if(!user.Agent_Selected_Access__c){
                    component.set('v.disableSelect','True');
                }
                   
                
            }
            console.log('disableselect : ',AgentList.length);

            if(AgentList.length > 0){
                console.log('societa',user.Societa__c);  
                console.log('AgentList[0] : ', AgentList[0]);                    
                component.set("v.PicklistSelected", AgentList[0]);                       
            
                AgentList.forEach(function (element) {
                    opts.push({
                        class: element.Favourite_Agent_for_CAP__c ? "optionClass" : "",
                        label: (element.Favourite_Agent_for_CAP__c ? "* " : "") + element.Name + ' [' + element.Citta__c + '] ' + (element.Favourite_Agent_for_CAP__c ? " *" : ""),
                        value: element.Titolare__c != null ? element.Titolare__c : element.Id
                        
                    });
                });                
            } else {
                opts.push({
                    class: "",
                    label:  '* ' + $A.get("$Label.c.TXT_SalesAgentModal_AgentNotFound") + ' *',
                    value: ''
                });       
            } 
            component.set('v.AgentList',opts);
             
        })).finally($A.getCallback(function () {
			component.set('v.completeLoad', true);
        }));
    },
    
   openModal : function(component, event, helper) {
        var modalBody;
        var modalFooter;
        
        
        /*
        var options = [ { 'title': 'search', 'buttons': [{ 'type': 'next', 'requireValidation': true }], 'recordId': component.get("v.recordId"), 'contactId': component.get("v.contactId") } , 
                        { 'title': 'result', 'buttons': [{ 'type': 'next', 'visible': false }] } , 
                        { 'title': 'submit' } ];
        */
        console.log("DO INIT EDITCONTACTMODAL");
        var id = component.get("v.recordId");
        var pickSelected = component.get("v.PicklistSelected");
        var lookSelected = component.get("v.LookupSelected");
        console.log("pickSelected: ",pickSelected );
        console.log("lookSelected: ",lookSelected );
        var objType = id.substring(0, 3) == '001' ? 'Account' : 'Lead';        
        var selectedId;
        var selectedRecord;
        if (lookSelected != null && lookSelected.Id){
                selectedId = lookSelected.Id;
                selectedRecord = lookSelected;
                console.log("lookSelected.Id : ",lookSelected.Id);
        }else if (pickSelected){
            console.log("pickSelected.Titolare__c: ",pickSelected.Titolare__c);
            selectedId =pickSelected.Titolare__c;
            selectedRecord = pickSelected;
        }
        console.log('SELECTED: ', selectedId);
        //alert(objType);
        $A.createComponents([
            
            // ERRORE GRAVE ATTENZIONE IN QUELLO CHE FAI
            //["c:TXT_SalesAgentModal_Body",{recordId: component.get("v.recordId"), selectedId: component.get("v.selectedItem")}]
            ["c:INN_SalesAgentModal_Body_V2",{recordId: component.get("v.recordId"), selectedId: selectedId, sObjectName: objType, userInfo : component.get('v.userInfo')}]
        ],
        // $A.createComponents([
        //     ["c:EditAccountModal_Body",{accountId: component.get("v.recordId")}]
        // ],
        function(content, status) {
            console.log("content: ", content);
            console.log("status: ", status);
            if (status === "SUCCESS") {
                console.log("SUCCESS");
                modalBody = content[0];
                //modalFooter = content[1];
                component.find('overlayLib').showCustomModal({
                    header:  $A.get("$Label.c.WRT_SupportUserModalController_NewAppointment") + ' '+ selectedRecord.Name, //LABEL HERE
                    body: modalBody,
                    footer: null,
                    showCloseButton: true,
                    cssClass: "cstm-edit-modal slds-modal_medium"
                });
            }
        });
    },
    
    resolveEvent : function(component, event, helper) {
        // manage Footer event
        var json = JSON.parse(event.getParam("json"));
        var originContact = component.get("v.recordId");
        console.log(json);

        var navService = component.find("navService");

        var pageReference = {
                type: "standard__recordPage",
                attributes: {
                    "recordId": originContact,
                    "objectApiName": "Contact",
                    "actionName": "view"
                }
            };
        
             
        navService.navigate(pageReference);       
    },
    
    setItem : function (component,event,helper){
        
        var myAgent = event.getSource().get("v.value");
        var listResult = component.get("v.AgentResult");
        console.log("myAgent:",myAgent);
        
        console.log("listResult:",listResult);
        

        listResult.forEach(function (element) {
            console.log("element.Titolare__c:",element.Titolare__c);
            console.log("element.Id:",element.Titolare__c);


            if(element.Titolare__c == myAgent || element.Id == myAgent){
                component.set("v.PicklistSelected",element);
                 console.log("PicklistSelected:",element);
            }
        });
         console.log("selectedItem:",myAgent);
        
    },

    openVendorListView : function(component,event,helper){
        var navService = component.find("navService");

        var pageReference = {
                type: "standard__objectPage",
                attributes: {
                    "objectApiName": "Anagrafica_Venditori__c",
                    "actionName": "list"
                },
                state: {
                    "filterName": "Recent"
              }
            };
        navService.navigate(pageReference);       

	},
	
	saveOnLead : function(component,event,helper){
        var pickSelected = component.get("v.PicklistSelected");        
        var lookSelected = component.get("v.LookupSelected");
        console.log('picksel: ', pickSelected);
        console.log('lookSel: ', JSON.stringify(lookSelected));
        if(JSON.stringify(lookSelected) == '{}'){lookSelected = null;}
        component.set('v.showSpinner', true);
        helper.apex (component, event, 'updateLead', {"recordId": component.get("v.recordId"), "pickSelected": pickSelected, "lookSelected": lookSelected})
        .then($A.getCallback(function (result) {
            console.log('result delete: ', result);
            if(result.success){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Fuori-Zona Aggiornato",
                    "type" : "success"
                });
                toastEvent.fire();
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Errore",
                    "message": "Salvataggio sul Lead fallito",
                    "type" : "success"
                });
                toastEvent.fire();
            }

        })).finally($A.getCallback(function() {
            
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            dismissActionPanel.fire();

            component.set('v.showSpinner', false);
        }));
    }
})