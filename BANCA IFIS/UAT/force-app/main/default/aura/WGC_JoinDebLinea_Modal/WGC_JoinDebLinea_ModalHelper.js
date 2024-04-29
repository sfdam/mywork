({
    setupData : function(component) {
        // let availableJoins = component.get("v.availableJoins");
        // let selectedJoins = [];
        // let payload = component.get("v.payload");
        // console.log('@@@ payload ' , JSON.stringify(payload));
        // let joinLineaAttore = payload.joinLineaAttore;
        // let debitori = payload.debitori;
        // let linee = payload.linee;
        // let joins = JSON.parse(JSON.stringify(availableJoins));
        // let selectedLine;

        // console.log('@@@ joins ' , joins);

        // for (let key in joins) {
        //     let newLine = null;
        //     if (joinLineaAttore.find(jla => {return jla.debitore == key;}).hasOwnProperty("linee"))
        //         if (joinLineaAttore.find(jla => {return jla.debitore == key;}).linee.reduce((start, l) => {return start || joins[key].map(j => {return j.Id;}).includes(l);}, false) === true) {
        //             selectedLine = joinLineaAttore.find(jla => {return jla.debitore == key;}).linee.find(l => {return joins[key].map(j => {return j.Id;}).includes(l);});
        //         } else if (joinLineaAttore.find(jla => {return jla.debitore == key;}).linee.reduce((start, l) => {return start || joins[key].map(j => {return j.Id;}).includes(l);}, false) === false) {
        //             let existingLines = joinLineaAttore.find(jla => {return jla.debitore == key;}).linee.join(",");
        //             if (linee.filter(l => {return joins[key].map(j => {return j.Prodotto__r.Name;}).includes(l.nome);}).reduce((start, l) => {return start || existingLines.includes(l.id);}, false)) { // linee.find(l => {return joins[key].map(j => {return j.Prodotto__r.Name;}).includes(l.nome);})
        //                 selectedLine = linee.filter(l => {return joins[key].map(j => {return j.Prodotto__r.Name;}).includes(l.nome);}).find(l => {return existingLines.includes(l.id);}).id;
        //                 newLine = {
        //                     id: selectedLine,
        //                     name: linee.find(l => {return l.id == selectedLine;}).nome,
        //                     numeroLinea: ""
        //                 };
        //             }
        //         }

        //     newLine = (newLine == null ? {
        //         id: "",
        //         name: joins[key].map(j => {return j.Prodotto__r.Name}).join(" + "),
        //         numeroLinea: ""
        //     } : newLine);

        //     selectedJoins.push({
        //         debitore: {
        //             id: key,
        //             name: debitori.find(d => {return d.id == key;}).rsociale
        //         },
        //         selectedLine: selectedLine,
        //         lines: [newLine].concat(joins[key].filter(j => {return j.TipoLinea__c != "lineaDiCarico";}).map(j => {
        //             return {
        //                 id: j.Id,
        //                 lineaDiCarico: ( joins[key].filter(jj => {return jj.TipoLinea__c == "lineaDiCarico";}).length > 0 ? joins[key].find(jj => {return jj.TipoLinea__c == "lineaDiCarico";}).Id : "" ),
        //                 name: j.Prodotto__r.Name + ( joins[key].filter(jj => {return jj.TipoLinea__c == "lineaDiCarico";}).length > 0 ? " + " + joins[key].find(jj => {return jj.TipoLinea__c == "lineaDiCarico";}).Prodotto__r.Servizio__c : "" ),
        //                 numeroLinea: j.WGC_Numero_Linea_Credito__c
        //             };
        //         }))
        //     });

        //     if (!this.isBlank(selectedLine) && payload.joinLineaAttore.find(jla => {return jla.debitore == key;}).linee && payload.joinLineaAttore.find(jla => {return jla.debitore == key;}).linee.length > 0)
        //         payload.joinLineaAttore.find(jla => {return jla.debitore == key;}).linee.splice(payload.joinLineaAttore.find(jla => {return jla.debitore == key;}).linee.indexOf(selectedLine), 1);
        // }

        // component.set("v.selectedJoins", selectedJoins);
        // component.set("v.payload", payload);

        // console.log('@@@ payload passato ' , JSON.stringify(component.get("v.payload")));
        // console.log('@@@ linee ' , JSON.stringify(component.get("v.availableJoins")));
        // console.log('@@@ debitori ' , JSON.stringify(component.get("v.debitori")));

        var availableJoins = component.get("v.availableJoins");
        var joinLineaAttore = component.get("v.joinLineaAttore");
        var debitori = component.get("v.debitori");

        var selectedJoins = [];
        var singleJoin = { "debitore" : {} };
        console.log('@@@ availableJoins ' , JSON.stringify(availableJoins));
        //var selectedLine;
        for(var key in availableJoins){
            singleJoin.debitore.id = key;
            singleJoin.debitore.name =  debitori.filter((item) =>{ return item.id == key })[0].rsociale;//.map(item => {return item.name});
            singleJoin.lines = [ { id: "", name: "Nuova Linea", numeroLinea: "" } ];
            availableJoins[key].forEach((item, index) =>{
                console.log('@@@ item ' + JSON.stringify(item));
                if(item.LineaATD__c == true && item.TipoLinea__c == 'lineaDiAcquisto')
                    singleJoin.lines.push({ id: item.Id, numeroLinea: item.WGC_Numero_Linea_Credito__c, name: item.Prodotto__r.Name, lineaDiCarico: availableJoins[key].filter(jj => { console.log('@@@ aaa ' , JSON.stringify(jj)); return jj.TipoLinea__c == 'lineaDiCarico' })[0].Id });
                else if(item.LineaATD__c == true && !item.hasOwnProperty('TipoLinea__c'))
					singleJoin.lines.push({ id: item.Id, numeroLinea: item.WGC_Numero_Linea_Credito__c, name: item.Prodotto__r.Name });                                                                                                                                                 
				else if(!item.hasOwnProperty('LineaATD__c'))
                    singleJoin.lines.push({ id: item.Id, numeroLinea: item.WGC_Numero_Linea_Credito__c, name: item.Prodotto__r.Name });
            });

            selectedJoins.push(singleJoin);
            
            //
            // if (!this.isBlank(selectedLine) && payload.joinLineaAttore.find(jla => {return jla.debitore == key;}).linee && payload.joinLineaAttore.find(jla => {return jla.debitore == key;}).linee.length > 0)
            //    payload.joinLineaAttore.find(jla => {return jla.debitore == key;}).linee.splice(payload.joinLineaAttore.find(jla => {return jla.debitore == key;}).linee.indexOf(selectedLine), 1);
        }

        console.log('@@@ selectedJoins ' , selectedJoins);
        component.set("v.selectedJoins", selectedJoins);

    },

    saveJoin : function(component) {
        let selectedJoins = component.get("v.selectedJoins");
        let joinLineaAttore = component.get("v.joinLineaAttore");
        let debitori = component.get("v.debitori");
        let debitoreAssociato;

        
        console.log('@@@ jla init ' , joinLineaAttore );
        console.log('@@@ deb init ' , debitori );

        //selectedJoins.forEach(j => {
        let j = selectedJoins[0];
        console.log('@@@ j.selectedLine ' , j.selectedLine );
        if (!this.isBlank(j.selectedLine)) {
            let jlaSelected = joinLineaAttore.filter(jla =>{ if(jla.hasOwnProperty("linee")){ return jla.linee.includes(j.selectedLine) } });
            debitoreAssociato = jlaSelected[0].debitore;
            if (joinLineaAttore.find(jla => { return jla.debitore == j.debitore.id;}) == undefined){//.hasOwnProperty("linee"))
                let newJla = { "debitore" : j.debitore.id , "linee" : [j.selectedLine], "servizi" : j.lines.filter(item => { return item.name == j.selectedLine.name}) };
                newJla.linee = (this.isBlank(j.lines.find(jj => {return jj.id == j.selectedLine;}).lineaDiCarico) ? [j.selectedLine] : [j.selectedLine, j.lines.find(jj => {return jj.id == j.selectedLine;}).lineaDiCarico]);
                joinLineaAttore.push(newJla);
            //} else if (!joinLineaAttore.find(jla => {return jla.debitore == j.debitore.id;}).linee.includes(j.selectedLine))
            } else if (!joinLineaAttore.find(jla => {return jla.debitore == j.debitore.id;}).hasOwnProperty("linee")){
                let jla = joinLineaAttore.find(jla => {return jla.debitore == j.debitore.id;});
                console.log('@@@ str ' , JSON.stringify(jla));
                jla.linee = new Array();
                joinLineaAttore.forEach((item, index) =>{ if( item.debitore == jla.debitore ){ item = jla; } });
                joinLineaAttore.find(jla => {return jla.debitore == j.debitore.id;}).linee.push(j.selectedLine, (this.isBlank(j.lines.find(jj => {return jj.id == j.selectedLine;}).lineaDiCarico) ? "" : j.lines.find(jj => {return jj.id == j.selectedLine;}).lineaDiCarico));
            } else if(joinLineaAttore.find(jla => {return jla.debitore == j.debitore.id;}).hasOwnProperty("linee") ) {
                let jla = joinLineaAttore.find(jla => {return jla.debitore == j.debitore.id;});
                jla.linee = new Array();
                console.log('@@@ tipo 2 ' , typeof jla.linee);
                joinLineaAttore.forEach((item, index) =>{ if( item.debitore == jla.debitore ){ item = jla; } });
                joinLineaAttore.find(jla => {return jla.debitore == j.debitore.id;}).linee.push(j.selectedLine, (this.isBlank(j.lines.find(jj => {return jj.id == j.selectedLine;}).lineaDiCarico) ? "" : j.lines.find(jj => {return jj.id == j.selectedLine;}).lineaDiCarico));
            }
        } else {
            if(joinLineaAttore.find(jla => { return jla.debitore == j.debitore.id;}) == undefined){
                let newJla = { "debitore" : j.debitore.id , "linee" : [], "servizi" : j.lines.filter(item => { return item.name == j.selectedLine.name}) };
                joinLineaAttore.push(newJla);
            } else if( !joinLineaAttore.find(jla => {return jla.debitore == j.debitore.id;}).hasOwnProperty("linee") ){
                let jla = joinLineaAttore.find(jla => {return jla.debitore == j.debitore.id;});
            } else if( joinLineaAttore.find(jla => {return jla.debitore == j.debitore.id;}).hasOwnProperty("linee") ){
                let jla = joinLineaAttore.find(jla => {return jla.debitore == j.debitore.id;});
                jla.linee = [];
            }
        }
        //});

        if(!this.isBlank(j.selectedLine)){
            let debToCopy = debitori.filter(deb => { return deb.id == debitoreAssociato})[0];

            debitori.forEach(deb => {
                if(deb.id == selectedJoins[0].debitore.id){
                    deb.aNotifica = debToCopy.aNotifica;
                    deb.maturity = debToCopy.maturity;
                    deb.mercato = debToCopy.mercato;
                    deb.divisa = debToCopy.divisa;
                    console.log('@@@ debToCopy ' , JSON.stringify(debToCopy));
                }
            });
        }

        console.log('@@@ jla final ' , joinLineaAttore );
        console.log('@@@ deb final ' , debitori );

        component.set("v.joinLineaAttore", joinLineaAttore);
        component.set("v.debitori", debitori);
        
        component.find("overlayLib").notifyClose();
        
        // //SM-CART-REVI
        // var appEvent = $A.get("e.c:WGC_Cart_Call_Server");
        // //appEvent.setParams({ "method" : "c.saveWizard" , "params" : { payload: JSON.stringify(payload), step: "servizi" } });
        // appEvent.setParams({ "method" : "c.saveWizard" , "params" : { payload: JSON.stringify(payload), step: "categorie" } });
        // appEvent.fire();
    }
})