({
    /**
     * Map of pre-chat field label to pre-chat field name (can be found in Setup)
     */
    fieldLabelToName: {
        "Nome": "FirstName",
        "Cognome": "LastName",
        "Name":"Name",
        "* Nome e cognome/Ragione sociale":"CRM_WebChannelName__c",
        "Cognome_1":"CRM_WebChannelSurname__c",
        "Indirizzo email":"CRM_WebChannelEmail__c",
        "Codice fiscale/Partita iva":"CRM_CodiceFiscalePartitaIva__c",
        "Motivo della chat": "CRM_MotivoDellaChat__c",
        //"Codice Fiscale/Partita Iva": "CRM_CodiceFiscale__c",
        "Email": "Email",
        "Phone": "Phone",
        "Fax": "Fax",
        "Mobile": "MobilePhone",
        "Home Phone": "HomePhone",
        "Other Phone": "OtherPhone",
        "Asst. Phone": "AssistantPhone",
        "Title": "Title",
        "Lead Source": "LeadSource",
        "Assistant": "AssistantName",
        "Department": "Department",
        "Subject": "Subject",
        "Case Reason": "Reason",
        "Type": "Type",
        "Web Company": "SuppliedCompany",
        "Web Phone": "SuppliedPhone",
        "Priority": "Priority",
        "Web Name": "SuppliedName",
        "Web Email": "SuppliedEmail",
        "Company": "Company",
        "Industry": "Industry",
        "Rating": "Rating"
    },

    /**
     * Event which fires the function to start a chat request (by accessing the chat API component)
     *
     * @param cmp - The component for this state.
     */
    onStartButtonClick: function(cmp) {
        cmp.set("v.showEmptyFieldsError", false)
        cmp.set("v.showInvalidFieldsError", false)
        if (this.validateInputTexts(cmp)) {
            //var prechatFieldComponents = cmp.find("prechatField");
            let fName = cmp.find("prechatField_FirstName")
            let lName = cmp.find("prechatField_LastName")
            //let cfPIva = cmp.find("prechatField_CRM_CodiceFiscale__c")
            let email = cmp.find("prechatField_Email")
            let email1 = cmp.find("prechatField_CRM_WebChannelEmail__c")
            let cfPIva1 = cmp.find("prechatField_CRM_CodiceFiscalePartitaIva__c")
            let nome1 = cmp.find("prechatField_CRM_WebChannelName__c")
            //let cognome1 = cmp.find("prechatField_CRM_WebChannelSurname__c")
            //let motivoChat = cmp.find("prechatField_CRM_MotivoDellaChat__c")
            var prechatFieldComponents = [fName, lName, email, email1, cfPIva1, nome1]
            var fields;

            // Make an array of field objects for the library
            fields = this.createFieldsArray(prechatFieldComponents);
            var motivoObject = {
                label: 'Motivo della chat',
                value: cmp.get("v.motivoSelected"),
                name: "CRM_MotivoDellaChat__c"
            }
            fields.push(motivoObject)
            
            fields[0].value = "      "
            fields[1].value = "      "
            fields[2].value = "      "
            fields[5].label = "Nome e cognome/Ragione sociale"

            // If the pre-chat fields pass validation, start a chat
            if(cmp.find("prechatAPI").validateFields(fields).valid) {
                cmp.find("prechatAPI").startChat(fields);
            } else {
                console.warn("Prechat fields did not pass validation!");
            }
        }
    },
    toggleError: function(component) {
        let checkbox = component.find("checkbox")
        let policyText = component.find("policyText")
        $A.util.removeClass(checkbox, "checkboxClass")
        $A.util.addClass(checkbox, "errorClass")
        $A.util.addClass(policyText, "policyErrorClass")

    },
    validateInputTexts: function(component) {
        let okClass = "slds-style-inputtext", errorClass = "errorClass", checkboxErrorClass = "checkboxErrorClass"
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
        let nomeCognome = this.toggleClass(component, "prechatField_CRM_WebChannelName__c", okClass, errorClass)
        let checkbox = this.toggleClass(component, "checkbox", "checkboxClass", checkboxErrorClass)
        var res = nomeCognome && checkbox
        return res
    },
    checkValidFields: function(component, okClass, errorClass) {
        let email = this.validateEmail(component, "prechatField_CRM_WebChannelEmail__c", okClass, errorClass)
        //let cfPIva = this.validateCF(component, "prechatField_CRM_CodiceFiscalePartitaIva__c", okClass, errorClass)
        return email// && cfPIva    
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
        let isValid = re.test(String(fieldValue).toLowerCase())
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
        var prechatFieldsInfoArray = [];

        // For each field, prepare the type and attributes to pass to $A.createComponents
        prechatFields.forEach(function(field) {
            if (field.name !== 'CRM_MotivoDellaChat__c') {
                //var componentName = field.name === 'CRM_MotivoDellaChat__c' ? 'select' : 'input'
                var componentName = field.name === 'CRM_MotivoDellaChat__c' ? 'combobox' : 'input'

                var componentInfoArray = ["lightning:"+componentName]
                var attributes = {
                    //"aura:id": "prechatField",
                    "aura:id": "prechatField_"+field.name,
                    required: field.required,
                    label: field.name === "CRM_WebChannelName__c" ? "* " + field.label : field.label,
                    disabled: field.readOnly,
                    maxlength: field.maxLength,
                    class: field.className,
                    value: field.name === 'CRM_MotivoDellaChat__c' ? 'New' : field.value,
                };

                if (field.name === 'CRM_MotivoDellaChat__c') {
                    attributes.options = cmp.get("v.options")        
                    console.log("qui = "+JSON.stringify(attributes))
                }

                // Special handling for options for an input:select (picklist) component
                //if(field.name === "select" && field.picklistOptions) attributes.options = field.picklistOptions;
                // Append the attributes Object containing the required attributes to render this pre-chat field
                componentInfoArray.push(attributes);
                
                // Append this componentInfoArray to the fieldAttributesArray
                prechatFieldsInfoArray.push(componentInfoArray);
            }
            console.log("TUTTI I CAMPI: "+JSON.stringify(prechatFieldsInfoArray))
        });

        return prechatFieldsInfoArray;
    },
});