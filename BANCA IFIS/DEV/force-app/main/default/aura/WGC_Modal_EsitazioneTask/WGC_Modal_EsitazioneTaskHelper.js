({
    loadPicklistValues : function(component) {
        let rtId = component.get("v.rtId");
        let h = this;
        let activityTypeValue = component.get("v.activityType");
        console.log('@@@ activityTypeValue ' , activityTypeValue);

        let fieldsMap = h.getFieldsMap();

        h.callServer(component, "c.getPicklistValues", function(result){
            let json = JSON.parse(result);
            console.log('@@@ json filo diretto ' , json);
            
            let wrapperPicklist = []; // ottimizzabile con iterazione su chiavi mappa fieldsMap
            let activityTypes = h.getPicklistValues(json, "TipoAttivita__c");
            activityTypes.forEach(at => {
                at.picklistValues.forEach(pv => {
                    pv.selected = (pv.value == activityTypeValue);
                });
            });
            wrapperPicklist = wrapperPicklist.concat(activityTypes);
            wrapperPicklist = wrapperPicklist.concat(h.getPicklistValues(json, "EsitoLivello1__c"));
            wrapperPicklist = wrapperPicklist.concat(h.getPicklistValues(json, "EsitoLivello2__c"));
            
            wrapperPicklist.forEach(wp => {
                if (h.isBlank(wp.controllingField))
                    component.set("v."+fieldsMap.get(wp.fieldName), wp.picklistValues);
            });

            component.set("v.picklistValuesContainer" , wrapperPicklist);
            component.set("v.loading", false);

            h.recursiveSetValues(component, wrapperPicklist, "TipoAttivita__c", activityTypeValue);
            
        }, {rtId: rtId});
    },

    loadLabels : function(component) {
        this.callServer(component, "c.getObjectLabels", function(result) {
            component.set("v.labels", result);
        }, {
            objectName: "Task"
        });
    },

    onChangePicklist : function(component, event) {
        let h = this;
        let pvc = component.get("v.picklistValuesContainer");
        let thisFieldName = event.getSource().get("v.name");
        let thisValue = event.getSource().get("v.value");
        
        h.recursiveSetValues(component, pvc, thisFieldName, thisValue);
    },

    recursiveSetValues : function(component, pvc, thisFieldName, thisValue) {
        let h = this;
        let fieldsMap = h.getFieldsMap();
        let fieldsValuesMap = h.getFieldsValuesMap();
        let resultMap = new Map();
        let fieldsToIterate = [];

        pvc.filter(p => {return p.controllingField == thisFieldName;}).forEach(p => {
            resultMap.set(p.fieldName, (h.isBlank(thisValue) ? [] : h.getDependentValues(pvc, thisFieldName, p.fieldName, thisValue)));
        });
        
        for (let key of resultMap.keys()) {
            component.set("v."+fieldsMap.get(key), resultMap.get(key));
            component.set("v."+fieldsValuesMap.get(key), "");
            fieldsToIterate.push(key);
        }

        if (pvc.filter(p => {return fieldsToIterate.includes(p.controllingField);}).length > 0) {
            fieldsToIterate.forEach(fieldName => {
                h.recursiveSetValues(component, pvc, fieldName, "");
            });
        }
    },

    getPicklistValues : function(json, apiName) {
        let layoutInfo = json.detailLayoutSections;
        let arrayPicklist = [];

        for(let key in layoutInfo){
            let layoutSection = layoutInfo[key];
            //Per ogni sezione del layout se la sezione è una layoutRows
            //Ciclo poi tutte le righe del layout e cerco i campi picklist esito
            //Per ogni campo picklist trovato mi recupero il nome del campo, il nome del campo controllante e la lista di possibili valori
            for(let key2 in layoutSection){
                if(key2 == 'layoutRows'){
                    let layoutItems = layoutSection[key2];
                    for(let key3 in layoutItems){
                        let layoutArrayItem = layoutItems[key3].layoutItems;
                        for(let key4 in layoutArrayItem){
                            let listaCampi = layoutArrayItem[key4];
                            if(listaCampi.layoutComponents.length == 1){
                                if(listaCampi.layoutComponents[0].value == apiName){
                                    let arrayComponents = listaCampi.layoutComponents[0].details;
                                    let controllingField = arrayComponents.controllerName;
                                    let actualField = arrayComponents.name;
                                    let picklistValues = arrayComponents.picklistValues;
                                    //Creo un wrapper per ogni campo picklist
                                    let wrapper = {};
                                    wrapper.controllingField = controllingField;
                                    wrapper.fieldName = actualField;
                                    wrapper.picklistValues = picklistValues;
                                    //Aggiungo alla lista di picklist values
                                    arrayPicklist.push(wrapper);
                                }
                            }
                        }
                    }
                }
            }
        }

        return arrayPicklist;
    },

    getDependentValues : function(wrapperPicklist, sourceName, targetName, value) {
        let h = this;
        let sourcepvc = wrapperPicklist.find(pvc => {return pvc.fieldName == sourceName;});
        let targetpvc = wrapperPicklist.find(pvc => {return pvc.fieldName == targetName;});
        
        let arr = [];
        let valoriControllanti = sourcepvc.picklistValues;
        let valoriDipendenti = targetpvc.picklistValues;
        let getValidValue;

        for(let key in valoriDipendenti){
            if(valoriDipendenti[key] !== undefined){

                let validFor = valoriDipendenti[key].validFor;

                //Converto il campo validFor in bit
                let output = validFor.split('').map(function (char) {
                    return char.charCodeAt(0).toString(2);
                }).join(' ');
                
                //Aggiungo un indice
                let l = (output.length + 1);

                //Itero ogni bit che verrà verificato dalla funzione testBit
                for(let i = 0; i < l ; i++){
                    //Funzione utilizzata per trovare la corrispondenza

                    getValidValue = h.getValidPicklistValues(value, valoriDipendenti, valoriControllanti);
                }
            }
        }

        for(let key in getValidValue){
            arr.push(getValidValue[key]);
        }
        //component.set('v.PicklistContainer', arr);
        console.log('@@@ arr ' , arr);
        return arr;
    },

    //Dato il valore controllante e la possibile lista di valori, e la lista di valori controllanti
    //trovo i valori corrispondenti
    getValidPicklistValues : function(controlValue, dependentListValues, controllingValues) {
        let h = this;
        // Figure out the index of the controlValue
        let index = controllingValues.indexOf(controllingValues.find(
            function(item) { return controlValue === item.value; }
        ));
        // Return a list of matching options given the control value
        return dependentListValues.filter(function(item) {
            // atob is base64-decoding.
            return h.testBit(atob(item.validFor), index);
        });
    },

    testBit : function(bitmap, index) {
        // Given an 8-bit binary string, get the index / 8 character,
        // And convert the index % 8 bit to true or false
        return !!(bitmap.charCodeAt(index >> 3) & (128 >> (index % 8)));
    },

    getFieldsMap : function() {
        let m = new Map();
        
        m.set("TipoAttivita__c", "pickActivityType");
        m.set("EsitoLivello1__c", "pickResultLevel1");
        m.set("EsitoLivello2__c", "pickResultLevel2");

        return m;
    },

    getFieldsValuesMap : function() {
        let m = new Map();
        
        m.set("TipoAttivita__c", "activityType");
        m.set("EsitoLivello1__c", "resultLevel1");
        m.set("EsitoLivello2__c", "resultLevel2");

        return m;
    },

    calculateValid : function(component) {
        let fields = component.find("esitazioneField");
        let isValid = true;

        isValid = fields.reduce((start, f) => {
            return start && (!f.get("v.required") || (f.get("v.required") && !this.isBlank(f.get("v.value"))));
        }, true);
        
        component.set("v.isValid", isValid);
    }
})