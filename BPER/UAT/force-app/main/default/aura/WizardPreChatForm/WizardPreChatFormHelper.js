({
    /**
     * Map of pre-chat field label to pre-chat field name (can be found in Setup)
     */
    fieldLabelToName: {
        "Nome": "FirstName",
        "Cognome": "LastName",
        "Name":"Name",
        "* Nome e cognome/Ragione sociale":"CRM_WebChannelName__c",
        "Indirizzo email":"CRM_WebChannelEmail__c",
        "Codice fiscale/Partita iva":"CRM_CodiceFiscalePartitaIva__c",
        //"Motivo della chat": "CRM_MotivoDellaChat__c",
        "Data di nascita": "Data_di_nascita__c",
        //"Codice Fiscale/Partita Iva": "CRM_CodiceFiscale__c",
    },

    /**
     * Event which fires the function to start a chat request (by accessing the chat API component)
     *
     * @param cmp - The component for this state.
     */
    onStartButtonClick: function(cmp) {
        cmp.set("v.showEmptyFieldsError", false)
        cmp.set("v.showInvalidFieldsError", false)

        var firstName;
        var lastName;
        var nomeRagioneS;
        var email;
        var cfPIva;
        var dataNascita; 
        var userCode; 
        let hostingSite = cmp.get("v.hostingSite") == undefined ? '' : cmp.get("v.hostingSite")


        var isValid = false;
        if(cmp.get("v.isLoggedUser")){
            if (this.validateInputTexts(cmp)) {

                isValid = true;

                nomeRagioneS = {label: "Nome e cognome/Ragione sociale", value : null, name: "CRM_WebChannelName__c"};
                firstName = {label: "Nome", value : null, name: "FirstName"};
                lastName = {label: "Cognome", value : "   ", name: "LastName"} ;
                email = {label: "Indirizzo email", value : null, name: "CRM_WebChannelEmail__c"};
                cfPIva = {label: "Codice fiscale/Partita iva", value : null, name: "CRM_CodiceFiscalePartitaIva__c"};
                dataNascita = {label: "Data di nascita", value : null, name: "Data_di_nascita__c" };
                userCode = {label: "CryptoString", value : cmp.get("v.userCode"), name: "CRM_CryptoString__c" };
            }

        }else{
            if(cmp.get("v.isPrivati")){
                if (this.validateInputTexts(cmp)) {
                  isValid = true;
      
                  let fName = cmp.find("prechatField_FirstName1");
                  let lName = cmp.find("prechatField_LastName1");
                  let cfPIva1 = cmp.find("prechatField_CRM_CodiceFiscalePartitaIva__c1");
                  let ddn = cmp.find("prechatField_Data_di_nascita__c1");
      
                  var privatiInfo = cmp.get("v.prechatPrivatiMap");
                  firstName = this.findArrayValue(privatiInfo,"CRM_WebChannelName__c",0,fName);
                  lastName = this.findArrayValue(privatiInfo,"CRM_WebChannelName__c",1,lName);
                  nomeRagioneS = {label: "Nome e cognome/Ragione sociale", value : (firstName.value+" "+lastName.value), name: "CRM_WebChannelName__c"};
                  email = {label: "Indirizzo email", value : null, name: "CRM_WebChannelEmail__c"};
                  cfPIva = this.findArrayValue(privatiInfo,"CRM_CodiceFiscalePartitaIva__c",0,cfPIva1);
                  dataNascita = this.findArrayValue(privatiInfo,"Data_di_nascita__c",0,ddn);
                  userCode = {label: "CryptoString", value : null, name: "CRM_CryptoString__c" };

                }
              }else{
                 if (this.validateInputTexts(cmp)) {
                  isValid = true;
      
                  let nome2 = cmp.find("prechatField_CRM_WebChannelName__c2");
                  let cfPIva2 = cmp.find("prechatField_CRM_CodiceFiscalePartitaIva__c2");
      
                  var impreseInfo = cmp.get("v.prechatImpreseMap");
                  nomeRagioneS = this.findArrayValue(impreseInfo,"CRM_WebChannelName__c",0,nome2);
                  firstName = {label: "Nome", value : null, name: "FirstName"};
                  lastName = {label: "Cognome", value : nomeRagioneS.value, name: "LastName"} ;
                  email = {label: "Indirizzo email", value : null, name: "CRM_WebChannelEmail__c"};
                  cfPIva = this.findArrayValue(impreseInfo,"CRM_CodiceFiscalePartitaIva__c",0,cfPIva2);
                  dataNascita = {label: "Data di nascita", value : null, name: "Data_di_nascita__c" };
                  userCode = {label: "CryptoString", value : null, name: "CRM_CryptoString__c" };

                }
      
              }
      
        }

        if (isValid) {
            var fields = [firstName, lastName, nomeRagioneS, email, cfPIva, dataNascita,userCode];

            var isPreChat = {
                label: 'Case from NewPrechatForm',
                value: 'SI',
                name: "CRM_CasefromNewPrechatForm__c"
            }
            fields.push(isPreChat)

            var motivoHidden = {
                label: 'Source',
                value: 'Wizard',
                name: "CRM_Source__c"
            }
            fields.push(motivoHidden)
            
            var motivoChatHidden = {
                label: 'Motivo della chat',
                value: 'Internet Banking',
                name: "CRM_MotivoDellaChat__c"
            }
            fields.push(motivoChatHidden)

            
            // If the pre-chat fields pass validation, start a chat
            if(cmp.find("prechatAPI").validateFields(fields).valid) {
                cmp.find("prechatAPI").startChat(fields);
            } else {
                console.warn("Prechat fields did not pass validation!");
            }
        }else {
            console.warn("Prechat fields did not pass validation!");
        }
    },
    toggleError: function(component) {
        let checkbox = component.find("checkboxSfdc")
        let policyText = component.find("policyTextSfdc")
        $A.util.removeClass(checkbox, "checkboxClassSfdc")
        $A.util.addClass(checkbox, "errorClassSfdc")
        $A.util.addClass(policyText, "policyErrorClassSfdc")

    },
    validateInputTexts: function(component) {
        let okClass = "slds-style-inputtext", errorClass = "errorClassSfdc", checkboxErrorClass = "checkboxErrorClassSfdc"
        let isOk = true
        if (!this.checkMandatoryFields(component, okClass, errorClass, checkboxErrorClass)) {
            // mostra errore campi obbligatori
            component.set("v.showEmptyFieldsError", true)
            isOk = false
        } else {
            if (!this.checkValidFields(component, okClass, errorClass)) {
                // mostra errore campi invalidi
                component.set("v.showInvalidFieldsError", true)
                isOk = false
            }
        }
        return isOk
    },
    checkMandatoryFields: function(component, okClass, errorClass, checkboxErrorClass) {
        if(component.get("v.isLoggedUser")){
            let checkbox = this.toggleClass(component, "checkboxSfdc", "checkboxClassSfdc", checkboxErrorClass);
            return checkbox
    }else{
            if(component.get("v.isPrivati")){
                let nome = this.toggleClass(component, "prechatField_FirstName1", okClass, errorClass);
                let cognome = this.toggleClass(component, "prechatField_LastName1", okClass, errorClass);
                let ddn = this.toggleClass(component, "prechatField_Data_di_nascita__c1", okClass, errorClass);
                let checkbox = this.toggleClass(component, "checkboxSfdc", "checkboxClassSfdc", checkboxErrorClass);
                var res = nome && cognome && ddn && checkbox;
                return res
            }else{
                let ragiones = this.toggleClass(component, "prechatField_CRM_WebChannelName__c2", okClass, errorClass);
                let piv = this.toggleClass(component, "prechatField_CRM_CodiceFiscalePartitaIva__c2", okClass, errorClass);
                let checkbox = this.toggleClass(component, "checkboxSfdc", "checkboxClassSfdc", checkboxErrorClass);
                var res = ragiones && piv && checkbox;
                return res

            }
        }
    },
    checkValidFields: function(component, okClass, errorClass) {
        var res = true;
        if(component.get("v.isPrivati")){
            let ddn = this.validateDate(component, "prechatField_Data_di_nascita__c1", okClass, errorClass);
            res = ddn;
        }

        //let email = this.validateEmail(component, "prechatField_CRM_WebChannelEmail__c", okClass, errorClass)
        //let cfPIva = this.validateCF(component, "prechatField_CRM_CodiceFiscalePartitaIva__c", okClass, errorClass)
        return res// && cfPIva    
    },

    applyLoggedStyle: function(component, event, helper) {
        //document.getElementById("motivoChatPicklistContainerSfdc").className = "loggedMotivoChatPicklistContainerSfdc";
        document.getElementById("policyContentSfdc").className = "loggedPolicyContentSfdc";
        document.getElementById("policyDivSfdc").className = "loggedPolicyDivSfdc";
        document.getElementById("linkInformativaSfdc").className = "loggedLinkInformativaSfdc";
        component.set('v.hasLoadedStyle',true);

    },


    toggleClass: function(component, apiName, okClass, errorClass) {
        let element = component.find(apiName)
        if (!element.get("v.value")) {
            $A.util.removeClass(element, okClass)
            $A.util.addClass(element, errorClass)
            return false
        } else {
            $A.util.removeClass(element, errorClass)
            $A.util.addClass(element, okClass)
            return true
        }
    },
    validateCF: function(component, apiName, okClass, errorClass) {
        let element = component.find(apiName)
        let isValid = element.get("v.value").length <= 16
        return this.checkValidity(component, element, isValid, okClass, errorClass)
    },
    validateEmail: function(component, apiName, okClass, errorClass) {
        let element = component.find(apiName)
        let fieldValue = element.get("v.value")
        if (fieldValue === "") {
            $A.util.removeClass(element, errorClass)
            $A.util.addClass(element, okClass)
            return true
        }
        const re = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        let isValid = re.test(String(fieldValue).toLowerCase());
        return this.checkValidity(component, element, isValid, okClass, errorClass)
    },

    validateDate: function(component, apiName, okClass, errorClass) {
        let isValid = false;
        let element = component.find(apiName)
        let fieldValue = element.get("v.value")
        if (fieldValue === "") {
            $A.util.removeClass(element, errorClass)
            $A.util.addClass(element, okClass)
            return true
        }
        const re = /^(?:(?:31(\/)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(\/)(?:0?[13-9]|1[0-2])\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})$|^(?:29(\/)0?2\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(\/)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[6-9]|[2-9]\d)?\d{2})$/;

        let isValidRegex = re.test(String(fieldValue).toLowerCase());

        if(isValidRegex){
            var dateArr = fieldValue.split("/");

            var inputDate = new Date('"' + dateArr[2] + "-" + dateArr[1] + "-" + dateArr[0] + '"').setHours(0, 0, 0, 0);
            var toDay = new Date().setHours(0, 0, 0, 0);
              
            
            isValid = (inputDate > toDay) ? false : true;
        }

        return this.checkValidity(component, element, isValid, okClass, errorClass)
    },

    checkValidity: function(component, element, isValid, okClass, errorClass) {
        if (isValid) {
            $A.util.removeClass(element, errorClass)
            $A.util.addClass(element, okClass)
            return true
        } else {
            $A.util.removeClass(element, okClass)
            $A.util.addClass(element, errorClass)
            return false
        }
    },
    /**
     * Create an array of field objects to start a chat from an array of pre-chat fields
     * 
     * @param fields - Array of pre-chat field Objects.
     * @returns An array of field objects.
     */
    createFieldsArray: function(fields) {
        if(fields.length) {
            return fields.map(function(fieldCmp) {
                return {
                    label: fieldCmp.get("v.label"),
                    value: fieldCmp.get("v.value"),
                    name: this.fieldLabelToName[fieldCmp.get("v.label")]
                };
            }.bind(this));
        } else {
            return [];
        }
    },
    
    /**
     * Create an array in the format $A.createComponents expects
     * 
     * Example:
     * [["componentType", {attributeName: "attributeValue", ...}]]
     * 
     * @param prechatFields - Array of pre-chat field Objects.
     * @returns Array that can be passed to $A.createComponents
     */
    getPrechatFieldAttributesArray: function(cmp, prechatFields) {
        // $A.createComponents first parameter is an array of arrays. Each array contains the type of component being created, and an Object defining the attributes.
        var cmpMap = new Map();
        var privatiInfoArray = [];
        var impreseInfoArray = [];

        var self = this;

        try{
            var mappingPrivati = this.generateMappingPrivati();
            var mappingImprese = this.generateMappingImprese();

            // For each field, prepare the type and attributes to pass to $A.createComponents
            prechatFields.forEach(function(field) {
                //if (field.name !== 'CRM_MotivoDellaChat__c') {

                    if (field.name == 'CRM_CryptoString__c' && field.value != null && field.value != "") {
                        cmp.set("v.userCode",field.value);
                        cmp.set("v.isLoggedUser",true);
                    }





                    if(mappingPrivati.has(field.name)){

                        var cmpInfoArray = mappingPrivati.get(field.name);
                        cmpInfoArray.forEach(function(cmpInfo) {
                            var cmpData = self.createComponentData(cmpInfo,field,'1');
                            cmpInfo.component = cmpData;
                        });
        
                    }

                    if(mappingImprese.has(field.name)){

                        var cmpInfoArray = mappingImprese.get(field.name);
                        cmpInfoArray.forEach(function(cmpInfo) {
                            var cmpData = self.createComponentData(cmpInfo,field,'2');
                            cmpInfo.component = cmpData;
                        });

                    }

                //}
            });

            for (const [key, value] of mappingPrivati.entries()) {
                value.forEach(function(cmpData) {
                    privatiInfoArray.push(cmpData.component);
                });       
            }

            for (const [key, value] of mappingImprese.entries()) {
                value.forEach(function(cmpData) {
                    impreseInfoArray.push(cmpData.component);
                });
            }

            
            //this.setMotiviPicklist(cmp);
            //if(!hiddenOutcome) this.setMotiviPicklist(cmp);

            cmpMap.set('Privati',privatiInfoArray);
            cmpMap.set('Imprese',impreseInfoArray);

            cmp.set('v.prechatPrivatiMap',mappingPrivati);
            cmp.set('v.prechatImpreseMap',mappingImprese);
            console.log("CAMPI tab Privati: "+JSON.stringify(privatiInfoArray));
            console.log("CAMPI tab Imprese: "+JSON.stringify(impreseInfoArray));
        }catch(error){
            console.error('ERROR: ',error);
            console.error('error string: ' + JSON.stringify(error));

        }

        return cmpMap;
    },

    openTab: function(evt, currentTab) {
        // Declare all variables
        var i, tabcontent, tablinks;
      
        // Get all elements with class="tabcontent" and hide them
        tabcontent = document.getElementsByClassName("tabcontentSfdc");
        for (i = 0; i < tabcontent.length; i++) {
          tabcontent[i].style.display = "none";
        }
      
        // Get all elements with class="tablinks" and remove the class "active"
        tablinks = document.getElementsByClassName("tablinksSfdc");
        for (i = 0; i < tablinks.length; i++) {

          tablinks[i].className = tablinks[i].className.replace(" active", "");
        }
      
        // Show the current tab, and add an "active" class to the button that opened the tab
        document.getElementById(currentTab).style.display = "block";
        evt.currentTarget.className += " active";
    },

    generateMappingPrivati: function(){

        let objMap = new Map();
        //objMap.set["FirstName", {info:{name: "Nome"   , required:true, readOnly:false, maxLength:50,className:"FirstName",value:"",placeholder:"",componentName:"input"}, component:{}}];
        //objMap.set["LastName",  {info:{name: "Cognome", required:true, readOnly:false, maxLength:50,className:"LastName", value:"",placeholder:"",componentName:"input"}, component:{}}];

        objMap.set("CRM_WebChannelName__c",
            [{info:{fieldLabel:"Nome", name: "Nome", required:true, readOnly:false, maxLength:50,className:"FirstName",value:"",placeholder:"",componentName:"input", additionalClasses: "inputFieldCustom slds-p-around--small slds-size--1-of-2"}, component:{}},
             {info:{fieldLabel:"Cognome", name: "Cognome", required:true, readOnly:false, maxLength:50,className:"LastName", value:"",placeholder:"",componentName:"input", additionalClasses: "inputFieldCustom slds-p-around--small slds-size--1-of-2"}, component:{}}]
        ) ;
        objMap.set("CRM_CodiceFiscalePartitaIva__c",[{info:{fieldLabel:"Codice fiscale/Partita iva", name: "Codice Fiscale", required:false, readOnly:false, maxLength:16,className:"CRM_CodiceFiscalePartitaIva__c",value:"",placeholder:"",componentName:"input", additionalClasses: "inputFieldCustom slds-p-around--small"}, component:{}}]) ;
        objMap.set("Data_di_nascita__c",[{info:{fieldLabel:"Data di nascita", name: "Data di nascita", required:true, readOnly:false, maxLength:10,className:"Data_di_nascita__c",value:"", placeholder:"01/01/2000",componentName:"input", additionalClasses: "inputFieldCustom slds-p-around--small"}, component:{}}]) ;
        return objMap;
    },

    generateMappingImprese: function(){

        let objMap = new Map();

        objMap.set("CRM_WebChannelName__c",[{info:{fieldLabel:"Nome e cognome/Ragione sociale", name: "Ragione Sociale", required:true, readOnly:false, maxLength:80,className:"CRM_WebChannelName__c",value:"",placeholder:"",componentName:"input", additionalClasses: "inputFieldCustom slds-p-around--small"}, component:{}}]) ;
        objMap.set("CRM_CodiceFiscalePartitaIva__c",[{info:{fieldLabel:"Codice fiscale/Partita iva", name: "Partita IVA", required:true, readOnly:false, maxLength:25,className:"CRM_CodiceFiscalePartitaIva__c",value:"",placeholder:"",componentName:"input", additionalClasses: "inputFieldCustom slds-p-around--small"}, component:{}}]) ;
        return objMap;
    },

    createComponentData: function(cmpInfo,field,suffix){
        var cmpData = ["lightning:"+cmpInfo.info.componentName];
        var attributes = {
            //"aura:id": "prechatField",
            "aura:id": "prechatField_"+cmpInfo.info.className+suffix,
            //required: cmpInfo.info.required,
            required: false,
            label: !cmpInfo.info.required ? cmpInfo.info.name : "*"+cmpInfo.info.name,
            disabled: cmpInfo.info.readOnly,
            maxlength: cmpInfo.info.maxLength,
            class: (cmpInfo.info.additionalClasses && cmpInfo.info.additionalClasses.length>0) ? field.className + ' '+ cmpInfo.info.additionalClasses : field.className,
            value: "",
            placeholder: cmpInfo.info.placeholder
        };
        cmpData.push(attributes);
        return cmpData;
    },

    findArrayValue: function(objMap,field,index,currentcmp){
        var obj = objMap.get(field)[index];
        if(currentcmp.get("v.value")){
            return {label : obj.info.fieldLabel, value: currentcmp.get("v.value"), name: obj.info.className};
        }else{
            return {label : obj.info.fieldLabel, value: null, name: obj.info.className};
        }
    }

    /*setMotiviPicklist: function(component){
        let hostingSite = component.get('v.hostingSite');
        let motiviOptions = [];
        if( hostingSite == '' || hostingSite == null || hostingSite == undefined ){
             motiviOptions.push({'label': 'Internet Banking', 'value': 'Internet Banking'});
        }
        motiviOptions.push({'label': 'Carte di pagamento', 'value': 'Carte di pagamento'});
        motiviOptions.push({'label': 'Altri prodotti e servizi', 'value': 'Altri prodotti e servizi'});

        component.set("v.motiviOptions", motiviOptions);
        component.set("v.motivoSelected", motiviOptions[0].value);

    }*/


});