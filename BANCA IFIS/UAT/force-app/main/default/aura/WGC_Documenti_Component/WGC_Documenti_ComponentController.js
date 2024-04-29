({
	doInit : function(component, event, helper) {
		
	},

	LaunchComponent : function(component, event, helper){
		var over = component.find('overlayLibrary');
		var modalBody;
        var idDoc = event.getSource().getLocalId();
        console.log('@@@ id doc ' , idDoc);
        var recordId = component.get('v.recordId');
        if(idDoc == 'privacy'){
            $A.createComponent("c:WGC_PrivacyPersonaGiuridica_Component", {"recordId" : recordId},
                function(content, status, error) {
                    console.log('@@@ error ' , error);
                    if (status === "SUCCESS") {
                        modalBody = content;
                        component.find('overlayLib').showCustomModal({
                            header: 'Compila Documento',
                            body: modalBody,
                            showCloseButton: true,
                            cssClass: "slds-modal_medium",
                            closeCallback: function() {
                                //alert('You closed the alert!');
                            }
                        })
                    }
                    if (status == "ERROR"){
                        console.log('@@@ error ' , error);
                    }                               
            });
        }
        if(idDoc == 'qq'){
            $A.createComponent("c:WGC_QuestionarioQualitativo_Component", {"recordId" : component.get("v.recordId")},
                                function(content, status, error) {
                                    if (status === "SUCCESS") {
                                        modalBody = content;
                                        component.find('overlayLib').showCustomModal({
                                            header: "Compila Documento",
                                            body: modalBody, 
                                            showCloseButton: true,
                                            cssClass: "slds-modal_medium",
                                            closeCallback: function() {
                                                //alert('You closed the alert!');
                                            }
                                        })
                                    }
                                    if (status == "ERROR"){
                                        console.log('@@@ error ' , error);
                                    }                               
                                });
        }
        if(idDoc == 'mav'){
            $A.createComponent("c:WGC_ModuloAdeguataVerifica_Component", {"recordId" : component.get("v.recordId")},
                               function(content, status, error) {
                                   if (status === "SUCCESS") {
                                       modalBody = content;
                                       component.find('overlayLib').showCustomModal({
                                            header: "Compila Documento",
                                           body: modalBody, 
                                           showCloseButton: true,
                                           cssClass: "slds-modal_medium",
                                           closeCallback: function() {
                                               //alert('You closed the alert!');
                                           }
                                       })
                                   }
                                   if (status == "ERROR"){
                                       console.log('@@@ error ' , error);
                                   }                               
                               });            
        }
        if(idDoc == 'mtc'){
            $A.createComponent("c:WGC_ModuloTecnicheComunicazione_Component", {"recordId" : component.get("v.recordId")},
                               function(content, status, error) {
                                   if (status === "SUCCESS") {
                                       modalBody = content;
                                       component.find('overlayLib').showCustomModal({
                                        header: "Compila Documento",
                                           body: modalBody, 
                                           showCloseButton: true,
                                           cssClass: "slds-modal_medium",
                                           closeCallback: function() {
                                               //alert('You closed the alert!');
                                           }
                                       })
                                   } 
                                   if(status == "ERROR"){
                                       console.log('@@@ error ' , error);
                                   }                              
                               });
        }
        if(idDoc == 'rpv'){
            $A.createComponent("c:WGC_RelazionePrimaVisita_Component", {"recordId" : component.get("v.recordId")},
                               function(content, status, error) {
                                    console.log('@@@ status ', status);
                                    console.log('@@@ content ', content);
                                   if (status === "SUCCESS") {
                                       modalBody = content;
                                       component.find('overlayLib').showCustomModal({
                                        header: "Compila Documento",
                                           body: modalBody, 
                                           showCloseButton: true,
                                           cssClass: "slds-modal_medium",
                                           closeCallback: function() {
                                               //alert('You closed the alert!');
                                           }
                                       })
                                   }
                                   if(status == "ERROR"){
                                        console.log('@@@ error ' , error);
                                   }                               
                               });   
        }
    },
})