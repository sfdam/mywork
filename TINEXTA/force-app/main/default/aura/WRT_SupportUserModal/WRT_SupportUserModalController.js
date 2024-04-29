({
	doInit : function(component, event, helper) {
        var opts = [];

        helper.apex(component, event, 'getUserInfo', { })
        .then($A.getCallback(function (result) {
            console.log('result getUserInfo', result);
            component.set('v.userInfo',result);        

		    return helper.apex(component, event, 'getSupportUsers', { })
        })).then($A.getCallback(function (result) {
            console.log('result getSupportUsers:', result);
            var SupportList = result.data;
            var user = component.get('v.userInfo');
            component.set('v.AgentResult',result.data);  

            if(SupportList.length<=1){
                component.set('v.disableSelect','True');
            }

            if(SupportList.length > 0){
                component.set('v.selectedItem',SupportList[0].Id);  
                component.set("v.AgentSelected", SupportList[0]);

                SupportList.forEach(function (element) {
                	opts.push({
                    	class: "",
                    	label:  element.Name ,
                    	value:  element.Id
                        
                	});
            	});
            
            
                component.set('v.SupportList',opts);   
            } else {
                
            } 
             
        })).finally($A.getCallback(function () {
			
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
        console.log("recordId: ", component.get("v.selectedItem"));
        var id = component.get("v.recordId");
        
        var objType = id.substring(0, 3) == '001' ? 'Account' : 'Lead';
        //alert(objType);
        $A.createComponents([
            
            // ERRORE GRAVE ATTENZIONE IN QUELLO CHE FAI
            //["c:TXT_SalesAgentModal_Body",{recordId: component.get("v.recordId"), selectedId: component.get("v.selectedItem")}]
            ["c:WRT_SupportUserModal_Body",{recordId: component.get("v.recordId"), selectedId: component.get("v.selectedItem"), sObjectName: objType}]
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
                    header:  $A.get("$Label.c.WRT_SupportUserModalController_NewAppointment") + ' '+ component.get("v.AgentSelected").Name, //LABEL HERE
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

        listResult.forEach(function (element) {
            if(element.Titolare__c == myAgent || element.Id == myAgent){
                component.set("v.AgentSelected",element);
            }
        });


        component.set("v.selectedItem",myAgent);
    },

    openListView : function(component,event,helper){
        var navService = component.find("navService");

        var pageReference = {
                type: "standard__objectPage",
                attributes: {
                    "objectApiName": "User",
                    "actionName": "list"
                },
                state: {
                    "filterName": "Recent"
              }
            };
        navService.navigate(pageReference);
        

    }
})