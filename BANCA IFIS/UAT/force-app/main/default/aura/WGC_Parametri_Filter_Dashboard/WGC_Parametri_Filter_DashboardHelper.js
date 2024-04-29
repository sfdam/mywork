({
    setupOptions : function(component, event) {
        var c = component;
        // this.callServer(component,"c.getAllOpportunities",function(result){
        //     // console.log("getAllOpportunities OK >> " + JSON.stringify(result));
        //     var opportunities = [];

        //     result.forEach(opp => {
        //         if (!opportunities.includes(opp.Name))
        //             opportunities.push(opp.Name);
        //     });
            
        //     c.set("v.opportunities", opportunities);
        // },{});
        
        this.callServer(component,"c.getAllProducts",function(result){
            // console.log("getAllProducts OK >> " + JSON.stringify(result));
            c.set("v.products", result);
        },{});
        
        this.callServer(component,"c.getSezioni",function(result){
            // console.log("getAllProducts OK >> " + JSON.stringify(result));
            c.set("v.sezioni", result);
        },{});
    },

    filter : function(component, event) {
        // var opportunity = event.currentTarget.name == "opportunity" ? event.currentTarget.value : component.get("v.opportunity");
        var product = event.currentTarget.name == "product" ? event.currentTarget.value : component.get("v.product");
        // var line = event.currentTarget.name == "line" ? event.currentTarget.value : component.get("v.line");
        var sezione = event.currentTarget.name == "sezione" ? event.currentTarget.value : component.get("v.sezione");

        console.log("params: " + JSON.stringify({
            // opportunity: opportunity,
            product: product,
            // line: line,
            sezione: sezione
        }));

        if (event.currentTarget.name == "sezione") {
            var appEvent = $A.get("e.c:WGC_Parametri_Filter_Dashboard_Event");
            appEvent.setParams({ "paramsJSON" : JSON.stringify( sezione == "Parametri" ? component.get("v.parametri") : component.get("v.condizioni") ) , "action" : "filter" });
            appEvent.fire();
        } else if (event.currentTarget.name == "line") {
            var target = (sezione == "Parametri" ? component.get("v.parametri") : component.get("v.condizioni") );
            
            target.forEach(ps => {
                ps.parameters.forEach(p => {
                    p.isVisible = (p.linea == line);
                });
            });

            var appEvent = $A.get("e.c:WGC_Parametri_Filter_Dashboard_Event");
            appEvent.setParams({ "paramsJSON" : JSON.stringify( sezione == "Parametri" ? component.get("v.parametri") : component.get("v.condizioni") ) , "action" : "filter" });
            appEvent.fire();
        } else {
        
            this.callServer(component,"c.getParametri",function(result){
                var params = result;
                var parametri = [];
                var condizioni = [];

                var sectionsMap = this.mapArrayBy(component.get("v.sezioni"), "Label");

                // var selectedLineId = this.setupLines(component, result);

                for (var p in params) {
                    // if (params[p].linea == selectedLineId) {
                        
                        // params[p].paramId = (this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice}]) ? this.getFirstNodeByFields(parametriConfiguratiPerLinea[selectedLineId], [{field:"codice",value:params[p].codice}]).id : null);
                        // params[p].isVisible = (params[p].linea == selectedLineId);
                        params[p].isVisible = true;

                        if (params[p].soloDeroga) {
                            console.log(JSON.stringify(params[p]));
                            // if (params[p].linea != selectedLineId)
                            //     continue;
                            params[p].value = "";
                            params[p].nomeDebitore = "DEBITORE";
                            params[p].debitore = "debID";
                        }
        
                        // GENERATE SECTIONS AND SUBSECTIONS WITH PARAMETERS
                        if (params[p].sottosezione == undefined || params[p].sottosezione == null) {
                            if (this.getSectionIndex(params[p].sezione, parametri) < 0)
                                this.arrayPusher({
                                    title: sectionsMap[params[p].sezione].NomeSezione__c,
                                    code: params[p].sezione,
                                    order: sectionsMap[params[p].sezione].Ordine__c,
                                    class: (this.isVisibleSection(params[p].sezione) ? "" : "cstm-hidden"), 
                                    parameters: [ params[p] ]
                                }, parametri);
                            else
                                this.arrayPusher(params[p], parametri[this.getSectionIndex(params[p].sezione, parametri)].parameters);
                        }
                        else {
                            if (params[p].sezione == "CE01") { // TODO: INSERIRE CONDIZIONE CAMPO FORMULA PER IDENTIFICARE PARAMETRI / CONDIZIONI
                                if (this.getSectionIndex(params[p].sottosezione, condizioni) < 0)
                                    this.arrayPusher({ title: sectionsMap[params[p].sottosezione].NomeSezione__c, code: params[p].sottosezione, order: sectionsMap[params[p].sezione].Ordine__c, class: (this.isVisibleSection(params[p].sezione) ? "" : "cstm-hidden"), parameters: [ params[p] ] }, condizioni);
                                else
                                    this.arrayPusher(params[p], condizioni[this.getSectionIndex(params[p].sottosezione, condizioni)].parameters);
                            }
                            else {
                                if (this.getSectionIndex(params[p].sottosezione, parametri) < 0)
                                    this.arrayPusher({ title: sectionsMap[params[p].sottosezione].NomeSezione__c, code: params[p].sottosezione, order: sectionsMap[params[p].sezione].Ordine__c, class: (this.isVisibleSection(params[p].sezione) ? "" : "cstm-hidden"), parameters: [ params[p] ] }, parametri);
                                else
                                    this.arrayPusher(params[p], parametri[this.getSectionIndex(params[p].sottosezione, parametri)].parameters);
                            }
                        }
                    // }
                }
                // DA GESTIRE LA VISIBILITA' DEI PARAMETRI (NELLA DASHBOARD DOVRANNO ESSERE VISIBILI ANCHE I PARAMETRI NASCOSTI)
                // var lineProsolutoATD_flags = this.getLineProsolutoATDFlags(component.get("v.items"));
            //     this.evalParamsVisibility(parametri, {
            //     PROSOLUTO: false,
            //     ATD: false
            // });
            //     this.evalParamsVisibility(condizioni, {
            //     PROSOLUTO: false,
            //     ATD: false
            // });

                parametri = this.sortSections(parametri);
                condizioni = this.sortSections(condizioni);

                component.set("v.parametri", parametri);
                component.set("v.condizioni", condizioni);

                var appEvent = $A.get("e.c:WGC_Parametri_Filter_Dashboard_Event");
                appEvent.setParams({ "paramsJSON" : JSON.stringify( sezione == "Parametri" ? parametri : condizioni ) , "action" : "filter" });
                appEvent.fire();
            },{
                // opportunity: opportunity,
                product: product
            });
        }

        // component.set("v.opportunity", opportunity);
        component.set("v.product", product);
        // component.set("v.line", line);
        component.set("v.sezione", sezione);
    },

    // FUNCTION TO EVALUATE THE VISIBILITY OF PARAMETERS BASED ON FIELD "ParametroProdotto__c.FormulaDiControllo__c"
    evalParamsVisibility : function(parameters, lineProsolutoATD_flags) {
        var JSONparams = "{";
        var params;
        var sections = [];
        // ITERATE OVER SECTIONS AND PARAMETERS TO POPULATE "sections" AND "params"
        parameters.forEach((s, si) => {
            // var isSectionComplete = true;
            if (si>0)
                    JSONparams += ',';
            s.parameters.forEach((e, i) => {
                if (i>0)
                    JSONparams += ',';
                JSONparams += '"' + e.codice + '":' + (e.value == "true" || e.value == "false" ? e.value : '"' + e.value + '"');
            });
            // params[e.code] = true;
        });
        JSONparams += "}";
        params = JSON.parse(JSONparams);
        // VARIABLES NEEDS TO BE PUSHED IN THE window IN ORDER TO USE THE eval() FUNCTION
        window.params = params;
        window.lineaFlags = lineProsolutoATD_flags;

        parameters.forEach(s => {
        // for (var p in parameters) {
            var visibleParams = [];

            s.parameters.forEach(e => {
            // for (var e in s.parameters) {
                if (e.formulaControllo != null && (e.formulaControllo.includes("VV_") || e.formulaControllo.includes("LL_"))) {
                    var formula = e.formulaControllo.replace(/VV_/g, "params.").replace(/LL_/g, "lineaFlags.");
                    // console.log(e.codice + " -- " + formula + " --eval: " + eval(formula));
                    if (eval(formula))
                        e.isVisible = true;
                    else
                        e.isVisible = false;
                }
                else if (e.formulaControllo == null) {
                    e.isVisible = true;
                }
                else
                    e.isVisible = false;
            });
            // }
            if (visibleParams.length > 0) {
                s.parameters = visibleParams;
                visibleSections.push(s);
            }
        });
        // }
        return parameters;
    },

    // setupLines : function(component, params) {
    //     var lines = [];

    //     params.forEach(p => {
    //         if (!lines.includes(p.linea))
    //             lines.push(p.linea);
    //     });

    //     component.set("v.lines", lines);
    //     component.set("v.line", lines[0]);

    //     return lines[0];
    // }

    compareParams : function(component) {
        var appEvent = $A.get("e.c:WGC_Parametri_Filter_Dashboard_Event");
        appEvent.setParams({ "paramsJSON" : "" , "action" : "compareParams" });
        appEvent.fire();
    }

})