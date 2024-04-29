({
    doInit: function (component, event, helper) {


        helper.apex(component, event, 'getselectOptions', { "objObject": component.get("v.resultSistemaIncentivante"), "fld": 'Tipo_Premio__c' })
            .then(function (result) {
                component.set("v.fieldsMap", result);
                console.log('SV APEX RESULT: ', result);
                return helper.apex(component, event, 'getSistemaIncentivante', {});
            }).then(function (result) {
                console.log('SV APEX RESULT2: ', result);
                var fieldsMap = component.get("v.fieldsMap");
                console.log('SV fieldsMap result: ', fieldsMap);
                var Premi = [];
                var P1 = {};
                P1.data = [];
                P1.Tot = 0;
                var P1_NB = {};
                P1_NB.data = [];
                P1_NB.Tot = 0;
                P1_NB.budget = [];
                P1_NB.soglia = [];
                var P2 = {};
                P2.data = [];
                P2.Tot = 0;
                var P3 = {};
                P3.data = [];
                P3.Tot = 0;
                var P4 = {};
                P4.data = [];
                P4.Tot = 0;
                P4.budget = [];
                P4.soglia = [];
                var P5 = {};
                P5.data = [];
                P5.Tot = 0;
                var P6 = {};
                P6.data = [];
                P6.Tot = 0;

                var nameP1IsSetting = false;
                var nameP1_NBIsSetting = false;
                var nameP2IsSetting = false;
                var nameP3IsSetting = false;
                var nameP4IsSetting = false;
                var nameP5IsSetting = false;
                var nameP6IsSetting = false;
                result.data[0].sistemaIncentivanteList.forEach(function (element) {
                    if (element.Tipo_Premio__c == 'P1') {
                        if (!nameP1IsSetting) {
                            nameP1IsSetting = true;
                            P1.Name = fieldsMap[element.Tipo_Premio__c];
                            P1.TipoPremio = element.Tipo_Premio__c;
                            P1.Euro = true;
                        }
                        P1.Tot = P1.Tot + element.Valore__c;
                        P1.data.push(element);
                    }
                    if (element.Tipo_Premio__c == 'P1_NB') {
                        if (!nameP1_NBIsSetting) {
                            nameP1_NBIsSetting = true;
                            P1_NB.Name = fieldsMap[element.Tipo_Premio__c];
                            P1_NB.TipoPremio = 'P1';
                            P1_NB.Euro = true;
                        }
                        P1_NB.Tot = element.Valore__c ? P1_NB.Tot + element.Valore__c : P1_NB.Tot + 0;
                        P1_NB.data.push(element);
                    }
                    if (element.Tipo_Premio__c == 'P2') {
                        if (!nameP2IsSetting) {
                            nameP2IsSetting = true;
                            P2.Name = fieldsMap[element.Tipo_Premio__c];
                            P2.TipoPremio = element.Tipo_Premio__c;
                            P2.Euro = true;
                        }
                        P2.Tot = P2.Tot + element.Valore__c;
                        P2.data.push(element);
                    }
                    if (element.Tipo_Premio__c == 'P3') {
                        if (!nameP3IsSetting) {
                            nameP3IsSetting = true;
                            P3.Name = fieldsMap[element.Tipo_Premio__c];
                            P3.TipoPremio = element.Tipo_Premio__c;
                            P3.Euro = true;
                        }
                        P3.Tot = P3.Tot + element.Valore__c;
                        P3.data.push(element);
                    }
                    if (element.Tipo_Premio__c == 'P4') {
                        if (!nameP4IsSetting) {
                            nameP4IsSetting = true;
                            P4.Name = fieldsMap[element.Tipo_Premio__c];
                            P4.TipoPremio = element.Tipo_Premio__c;
                            P4.Euro = false;
                        }
                        P4.Tot = element.Valore__c ? P4.Tot + element.Valore__c : P4.Tot + 0;
                        P4.data.push(element);
                    }
                    if (element.Tipo_Premio__c == 'P5') {
                        if (!nameP5IsSetting) {
                            nameP5IsSetting = true;
                            P5.Name = fieldsMap[element.Tipo_Premio__c];
                            P5.TipoPremio = element.Tipo_Premio__c;
                            P5.Euro = true;
                        }
                        P5.Tot = P5.Tot + element.Valore__c;
                        P5.data.push(element);
                    }
                    if (element.Tipo_Premio__c == 'P6') {
                        if (!nameP6IsSetting) {
                            nameP6IsSetting = true;
                            P6.Name = fieldsMap[element.Tipo_Premio__c];
                            P6.TipoPremio = element.Tipo_Premio__c;
                            P6.Euro = true;
                        }
                        P6.Tot = P6.Tot + element.Valore__c;
                        P6.data.push(element);
                    }

                });


                if (P1.Name) Premi.push(P1);
                if (P2.Name) Premi.push(P2);
                if (P3.Name) Premi.push(P3);
                if (P5.Name) Premi.push(P5);
                if (P6.Name) Premi.push(P6);

                console.log('SV Premio ', Premi);
                console.log('SV P4 ', P4);
                component.set('v.Premi', Premi);
                component.set('v.Premio4', P4);
                component.set('v.PremioP1_NB', P1_NB);
                if (Premi.length <= 0 && P4.Tot <= 0 && P1_NB.Tot <= 0) {
                    component.set('v.showPremi', false);
                }

                if (P4.Tot <= 0 || P1_NB.Tot <= 0) {
                    console.log('DENTRO');
                    helper.generateChart(helper.dataChart((P4.Tot > 0) ? P4.data : P1_NB.data, component, event), helper.optionsChart(component, event), 'line', 'chartJS1_SistemaIncentivante', component, event);
                }
            }).finally($A.getCallback(function () {

            }));



        // helper.getSistemaIncentivante(component, event);
        // helper.fetchPickListVal(component, 'Tipo_Premio__c', component.get("v.resultSistemaIncentivante"), 'fieldsMap');



    },

    collapse: function (component, event, helper) {
        component.set("v.IsCollapsed", !component.get("v.IsCollapsed"));

        helper.apex(component, event, 'getselectOptions', { "objObject": component.get("v.resultSistemaIncentivante"), "fld": 'Tipo_Premio__c' })
        .then(function (result) {
            component.set("v.fieldsMap", result);
            console.log('SV APEX RESULT: ', result);
            return helper.apex(component, event, 'getSistemaIncentivante', {});
        }).then(function (result) {
            console.log('SV APEX RESULT2: ', result);
            var fieldsMap = component.get("v.fieldsMap");
            console.log('SV fieldsMap result: ', fieldsMap);
            var Premi = [];
            var P1 = {};
            P1.data = [];
            P1.Tot = 0;
            var P1_NB = {};
            P1_NB.data = [];
            P1_NB.Tot = 0;
            P1_NB.budget = [];
            P1_NB.soglia = [];
            var P2 = {};
            P2.data = [];
            P2.Tot = 0;
            var P3 = {};
            P3.data = [];
            P3.Tot = 0;
            var P4 = {};
            P4.data = [];
            P4.Tot = 0;
            P4.budget = [];
            P4.soglia = [];
            var P5 = {};
            P5.data = [];
            P5.Tot = 0;
            var P6 = {};
            P6.data = [];
            P6.Tot = 0;

            var nameP1IsSetting = false;
            var nameP1_NBIsSetting = false;
            var nameP2IsSetting = false;
            var nameP3IsSetting = false;
            var nameP4IsSetting = false;
            var nameP5IsSetting = false;
            var nameP6IsSetting = false;
            result.data[0].sistemaIncentivanteList.forEach(function (element) {
                if (element.Tipo_Premio__c == 'P1') {
                    if (!nameP1IsSetting) {
                        nameP1IsSetting = true;
                        P1.Name = fieldsMap[element.Tipo_Premio__c];
                        P1.TipoPremio = element.Tipo_Premio__c;
                        P1.Euro = true;
                    }
                    P1.Tot = P1.Tot + element.Valore__c;
                    P1.data.push(element);
                }
                if (element.Tipo_Premio__c == 'P1_NB') {
                    if (!nameP1_NBIsSetting) {
                        nameP1_NBIsSetting = true;
                        P1_NB.Name = fieldsMap[element.Tipo_Premio__c];
                        P1_NB.TipoPremio = 'P1';
                        P1_NB.Euro = true;
                    }
                    P1_NB.Tot = element.Valore__c ? P1_NB.Tot + element.Valore__c : P1_NB.Tot + 0;
                    P1_NB.data.push(element);
                }
                if (element.Tipo_Premio__c == 'P2') {
                    if (!nameP2IsSetting) {
                        nameP2IsSetting = true;
                        P2.Name = fieldsMap[element.Tipo_Premio__c];
                        P2.TipoPremio = element.Tipo_Premio__c;
                        P2.Euro = true;
                    }
                    P2.Tot = P2.Tot + element.Valore__c;
                    P2.data.push(element);
                }
                if (element.Tipo_Premio__c == 'P3') {
                    if (!nameP3IsSetting) {
                        nameP3IsSetting = true;
                        P3.Name = fieldsMap[element.Tipo_Premio__c];
                        P3.TipoPremio = element.Tipo_Premio__c;
                        P3.Euro = true;
                    }
                    P3.Tot = P3.Tot + element.Valore__c;
                    P3.data.push(element);
                }
                if (element.Tipo_Premio__c == 'P4') {
                    if (!nameP4IsSetting) {
                        nameP4IsSetting = true;
                        P4.Name = fieldsMap[element.Tipo_Premio__c];
                        P4.TipoPremio = element.Tipo_Premio__c;
                        P4.Euro = false;
                    }
                    P4.Tot = element.Valore__c ? P4.Tot + element.Valore__c : P4.Tot + 0;
                    P4.data.push(element);
                }
                if (element.Tipo_Premio__c == 'P5') {
                    if (!nameP5IsSetting) {
                        nameP5IsSetting = true;
                        P5.Name = fieldsMap[element.Tipo_Premio__c];
                        P5.TipoPremio = element.Tipo_Premio__c;
                        P5.Euro = true;
                    }
                    P5.Tot = P5.Tot + element.Valore__c;
                    P5.data.push(element);
                }
                if (element.Tipo_Premio__c == 'P6') {
                    if (!nameP6IsSetting) {
                        nameP6IsSetting = true;
                        P6.Name = fieldsMap[element.Tipo_Premio__c];
                        P6.TipoPremio = element.Tipo_Premio__c;
                        P6.Euro = true;
                    }
                    P6.Tot = P6.Tot + element.Valore__c;
                    P6.data.push(element);
                }

            });


            if (P1.Name) Premi.push(P1);
            if (P2.Name) Premi.push(P2);
            if (P3.Name) Premi.push(P3);
            if (P5.Name) Premi.push(P5);
            if (P6.Name) Premi.push(P6);

            console.log('SV Premio ', Premi);
            console.log('SV P4 ', P4);
            component.set('v.Premi', Premi);
            component.set('v.Premio4', P4);
            component.set('v.PremioP1_NB', P1_NB);
            if (Premi.length <= 0 && P4.Tot <= 0 && P1_NB.Tot <= 0) {
                component.set('v.showPremi', false);
            }

            if (P4.Tot <= 0 || P1_NB.Tot <= 0) {
                helper.generateChart(helper.dataChart((P4.Tot > 0) ? P4.data : P1_NB.data, component, event), helper.optionsChart(component, event), 'line', 'chartJS1_SistemaIncentivante', component, event);
            }
        }).finally($A.getCallback(function () {

        }));


    },
})