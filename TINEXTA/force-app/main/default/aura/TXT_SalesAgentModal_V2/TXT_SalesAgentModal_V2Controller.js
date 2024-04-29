({
	doInit : function(component, event, helper) {
        var opts = [];

        helper.apex(component, event, 'getUserInfo', { })
        .then($A.getCallback(function (result) {
            console.log('result getUserInfo', result);
            component.set('v.userInfo',result);        

            return helper.apex(component, event, 'getAgents', { "recordId": component.get("v.recordId"), "societa": result.Societa__c })
        })).then($A.getCallback(function (result) {
            console.log('result getAgents', result);
            var AgentList = result.data;
            var user = component.get('v.userInfo');
            
            // SV S-000442
            if(user.Societa__c == 'Warrant' && user.Profile.Name == 'Warrant - Specialist'){
                let u = {};
                u.Id = user.Id;
                u.Name = user.Name;
                AgentList.push(u);
            }
            
            component.set('v.AgentResult',AgentList); 
            component.set("v.objType", result.objType);
            console.log("objType: ",result.objType);
            if(user.Societa__c == 'CoMark'){
                component.set('v.wherecond', ' AND Agente_CoMark__c = true');
            }

            if(AgentList.length<=1){
                component.set('v.disableSelect','True');
            } else {
                if(!user.Agent_Selected_Access__c){
                    component.set('v.disableSelect','True');
                }
            }

            if(AgentList.length > 0){
                console.log('societa',user.Societa__c);
                switch (user.Societa__c){
                    case 'Innolva':
                      
                        component.set("v.selectedRecord", AgentList[0]);                       
            
                        AgentList.forEach(function (element) {
                            opts.push({
                                class: element.Favourite_Agent_for_CAP__c ? "optionClass" : "",
                                label: (element.Favourite_Agent_for_CAP__c ? "* " : "") + element.Name + ' [' + element.Citta__c + '] ' + (element.Favourite_Agent_for_CAP__c ? " *" : ""),
                                value: element.Titolare__c != null ? element.Titolare__c : element.Id
                                
                            });
                        });                                              
                        break;
                    case 'Warrant':
                         
                        component.set("v.selectedRecord", AgentList[0]);
        
                        AgentList.forEach(function (element) {
                            opts.push({
                                class: "",
                                label:  element.Name ,
                                value:  element.Id
                                
                            });
                        });
                        break;
                    case 'CoMark':
                            console.log("AgentList[0] : ", AgentList[0]);
                            component.set("v.selectedRecord", AgentList[0]);

                            AgentList.forEach(function (element) {
                                opts.push({
                                    class: "",
                                    label:  element.Name ,
                                    value:  element.Id
                                    
                                });
                            });
                            break;
                    default:
                        
                        component.set("v.selectedRecord", AgentList[0]);
            
                        AgentList.forEach(function (element) {
                            opts.push({
                                class: element.Favourite_Agent_for_CAP__c ? "optionClass" : "",
                                label: (element.Favourite_Agent_for_CAP__c ? "* " : "") + element.Name + ' [' + element.Citta__c + '] ' + (element.Favourite_Agent_for_CAP__c ? " *" : ""),
                                value: element.Titolare__c != null ? element.Titolare__c : element.Id
                                
                            });
                        });
                        break;
                    }                    
                    component.set('v.AgentList',opts);
                
            } else {
                
            } 
             
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
        var myRecord = component.get("v.selectedRecord");
        var user = component.get('v.userInfo'); 
        var societa = user.Societa__c;
        var objType;
        console.log('societa :', societa);
        switch (id.substring(0, 3)){
            case '001':
                objType = 'Account';
                break;
            case '00Q':
                objType = 'Lead';
                break;
            case '003':
                objType = 'Contact';
                break;
        }

        var selectedObject = component.get("v.objType");
        var selected;
        switch (selectedObject){
            case 'User':
                selected = myRecord.Id;
                break;
            case 'Anagrafica_Venditori__c':
                selected = myRecord.Titolare__c;
                break;
        }
        console.log('SELECTED: ', selected);
        //alert(objType);
        $A.createComponents([
            
            // ERRORE GRAVE ATTENZIONE IN QUELLO CHE FAI
            //["c:TXT_SalesAgentModal_Body",{recordId: component.get("v.recordId"), selectedId: component.get("v.selectedItem")}]
            ["c:TXT_SalesAgentModal_Body_V2",{recordId: component.get("v.recordId"), selectedId: selected, sObjectName: objType, userInfo: component.get('v.userInfo')}]
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
                    header:  $A.get("$Label.c.WRT_SupportUserModalController_NewAppointment") + ' '+ component.get("v.selectedRecord").Name, //LABEL HERE
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
            if(element.Titolare__c == myAgent || element.Id == myAgent){
                component.set("v.selectedRecord",element);
                 console.log("selectedRecord:",element);
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
    
    handleSelect: function (component, event) {
            // This will contain the string of the "value" attribute of the selected
            // lightning:menuItem
            var selectedMenuItemValue = event.getParam("value");
            var menuItems = component.find("menuItems");
            // Get the selected menu item
            var menuItem = menuItems.find(function(menuItem) {
                return menuItem.get("v.value") === selectedMenuItemValue;
            });
            component.set("v.viewOption",selectedMenuItemValue);
    }

})