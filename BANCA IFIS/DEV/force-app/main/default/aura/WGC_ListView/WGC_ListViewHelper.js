({
    getUserProfile: function (component, event, helper) {
        var userId = $A.get("$SObjectType.CurrentUser.Id");

        var action = component.get("c.getUserType");
        action.setParams({
            userId: userId
        });
        action.setCallback(this, (response) => {
            if (response.getState() == 'SUCCESS') {
                var risposta = response.getReturnValue();
                if (risposta.success) {
                    if (risposta.data[0].Profile.Name.includes('Filo Diretto')) {
                        component.set("v.isFiloDiretto", true);
                    }
                    else {
                        component.set("v.isFiloDiretto", false);
                    }
                    component.set("v.userInfo", risposta.data[0]);
                    console.log('@@@ risposta user ', risposta);

                    var a = component.find('container');
					var values = component.get("v.SubTabsFD");
    				console.log('@@@ window.TabFilter ' , window.TabFilter);
    				var ind;
    				values.forEach((item, index) =>{
    					if(window.TabFilter != undefined && window.TabFilter != null && item.value == window.TabFilter){
    						ind = index
						}    
                    });
                    
                    if(a != undefined){
                        a.forEach((item, index) =>{
                            if(ind != undefined && ind != null){
                                if(index == ind){
                                    $A.util.addClass(item, 'active');
                                }
                                else{
                                    $A.util.removeClass(item, 'active');
                                }
                            } else {
                                if(index == 0){
                                    $A.util.addClass(item, 'active');
                                }
                                else{
                                    $A.util.removeClass(item, 'active');
                                }
                            }
                        });
                    }
					
                }
                else {
                    console.log('@@@ not success message ', risposta.message);
                }

            }
            else {
                console.log('@@@ error in apex controller ', response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    loadNewTable: function (component, event, helper, lista) {
        console.log('SV LISTA DATI: ', lista);

        var objectType = component.get("v.objectName");
        if (lista.campiTabella != null && lista.campiTabella != undefined && lista.campiTabella.length > 0) {
            var columns = [];

            lista.campiTabella.forEach((item, index) => {
                if (item.apiName == 'AccountId') {
                    var singleCol = { label: 'Ragione Sociale', fieldName: item.apiName, type: 'url', sortable: true, typeAttributes: { label: { fieldName: 'Account.Name' } } };
                    columns.push(singleCol);
                }
                else if (item.apiName == 'Account.Name') {
                    return;
                }
                else if (item.apiName == 'Name') {
                    var singleCol = {
                        label: item.label, fieldName: 'Id', type: 'url', sortable: true, typeAttributes: { label: { fieldName: 'Name' } },
                        cellAttributes: { iconName: "standard:opportunity", iconPosition: 'left' }
                    };
                    columns.push(singleCol);
                }
                else if (item.apiName == 'Subject') {
                    if(objectType == 'promemoria' || objectType == 'completateTask'){
                        objectType = 'task';
                    } else if(objectType == 'completateEvent'){
                        objectType = 'event';
                    }
                    
                    var singleCol = {
                        label: item.label, fieldName: 'Id', type: 'url', sortable: true, typeAttributes: { label: { fieldName: 'Subject' } },
                        cellAttributes: { iconName: "standard:" + objectType, iconPosition: 'left' }
                    };
                    columns.push(singleCol);
                }
                else if (item.apiName == 'Account.Id') {
                    var singleCol = { label: 'Ragione Sociale', fieldName: 'AccountId', type: 'url', sortable: true, typeAttributes: { label: { fieldName: 'Account.Name' } } };
                    columns.push(singleCol);
                }
                else if (item.apiName.toLowerCase().includes(('Data').toLowerCase()) || item.apiName.toLowerCase().includes(('Date').toLowerCase())) {
                    var singleCol = { label: item.label, fieldName: item.apiName, type: 'date', sortable: true, typeAttributes: { day: "2-digit", month: "2-digit", year: "numeric" }, cellAttributes: { class: { fieldName: "cellClass" } } };
                    columns.push(singleCol);
                }
                else {
                    var singleCol = { label: item.label, fieldName: item.apiName, sortable: true, type: item.type };
                    columns.push(singleCol);
                }
            });

            // if (objectType == 'task') {
            //     var userInfo = component.get("v.userInfo");

            //     if (userInfo != null && userInfo.Profile.Name.toLowerCase().includes(('Filo Diretto').toLowerCase())) {
            //         console.log('@@@ profilo ', userInfo.Profile.Name);
            //         var actions = { label: 'Azione', type: 'button', initialWidth: 150, typeAttributes: { label: 'Seleziona Esito', name: 'Seleziona Esito', title: 'Seleziona Esito', class: 'btn_next' }, class: 'btn_next' };
            //         columns.push(actions);
            //     }

            // }
            
            // else if(type == 'event'){
            //     var actions = {label: 'Azione', type: 'button', initialWidth: 150, typeAttributes: { label: 'Visualizza Visita', name: 'Visualizza Visita', title: 'Visualizza Visita', class: 'btn_next'}, class : 'btn_next'};
            //     columns.push(actions);
            // }
            
            // else if (objectType == 'oppIstruttoria' ||
            // objectType == 'oppPerfContratti' ||
            // objectType == 'oppAttProdotto') {
            //     var actions = { label: 'Azione', type: 'button', initialWidth: 150, typeAttributes: { label: 'Opportunità', name: 'Opportunità', title: 'Opportunità', class: 'btn_next' }, class: 'btn_next' };
            //     columns.push(actions);
            // }

            component.set("v.columns", columns);

            var results = [];

            lista.records.forEach((item, index) => {
                var rec = {};
                console.log('@@@ item ' + JSON.stringify(item));
                columns.forEach((col, colInd) => {
                    
                    if (col.fieldName == 'AccountId') {
                        rec[col.fieldName] = '/' + item.AccountId;
                        if(item.Account != null && item.Account != undefined){
                            rec['Account.Name'] = item.Account.Name;
                            rec['AccountName'] = item.Account.Name;
                        }
                    }
                    else if (col.fieldName == 'Account.Name') {
                        rec['AccountName'] = item.Account.Name;
                        return;
                    }
                    else if (col.fieldName == 'Id' && col.typeAttributes.label.fieldName == 'Name') {
                        rec.Id = '/' + item.Id;
                        rec.Name = item.Name;
                    }
                    else if (col.fieldName == 'Id' && col.typeAttributes.label.fieldName == 'Subject') {
                        rec.Id = '/' + item.Id;
                        rec.Subject = item.Subject;
                    }
                    else if (col.fieldName == 'AccountId' && col.typeAttributes.label.fieldName == 'Account.Name') {
                        rec.AccountId = '/' + item.Account.Id;
                        rec['Account.Name'] = item.Account.Name;
                        rec['AccountName'] = item.Account.Name;
                    }
                    else if (col.fieldName == undefined) {
                        return;
                    }
                    else if (component.get("v.objectName") != 'event' && (col.fieldName.toLowerCase().includes(('Data').toLowerCase()) || col.fieldName.toLowerCase().includes(('Date').toLowerCase()))) {
						console.log('@@@ col.fieldName ' + col.fieldName);
                        if (item[col.fieldName] != null && item[col.fieldName] != undefined) {
                            var date = new Date(item[col.fieldName]);
                            console.log('SV XXXXX');
                                                        console.log(new Date(), date);
                            console.log(date.getDate());
                            //rec[col.fieldName] = date.toLocaleDateString('it-IT', { year: 'numeric', month: '2-digit', day: '2-digit' });
                            rec[col.fieldName] = date;
                            if (date < new Date() && ( col.fieldName == 'ActivityDate' || col.fieldName == 'Data_Inizio__c' || col.fieldName == 'Data_Fine__c') && component.get("v.objectName") != 'completateTask' && component.get("v.objectName") != 'completateEvent' ) {
                                console.log('@@@ objectTYpe ' , component.get("v.objectName"));
                                rec['cellClass'] = 'expired-date';
                            }
                        }
                    }
					else if (component.get("v.objectName") == 'event' && (col.fieldName.toLowerCase().includes(('DateTime').toLowerCase()) || col.fieldName.toLowerCase().includes(('Date').toLowerCase()))) {
						console.log('@@@ col.fieldName ' + col.fieldName);
                        if (item[col.fieldName] != null && item[col.fieldName] != undefined) {
                            var date2 = new Date(item[col.fieldName]);
                            console.log('SV XXXXX');
                                                        console.log(new Date(), date2);
                            console.log(date2.getDate());
                            //rec[col.fieldName] = date2.toLocaleDateString('it-IT', { year: 'numeric', month: '2-digit', day: '2-digit' });
                            rec[col.fieldName] = date2;
                            if (date2 < new Date() && ( col.fieldName == 'ActivityDate' || col.fieldName == 'StartDateTime' || col.fieldName == 'EndDateTime') && component.get("v.objectName") != 'completateTask' && component.get("v.objectName") != 'completateEvent' ) {
                                console.log('@@@ objectTYpe ' , component.get("v.objectName"));
                                rec['cellClass'] = 'expired-date';
                            }
                        }
                    }
                    //Usato quando il campo si trova direttamente nell'oggetto
                    else if (!col.fieldName.includes('.')) {
                        rec[col.fieldName] = item[col.fieldName];
                    }
                    else {
                        //Usato quando esistono campi di lookup su altri oggetti
                        var tmp = col.fieldName.split('.');
                        rec[col.fieldName] = item[tmp[0]][tmp[1]];
                    }
                });
                results.push(rec);
            });

            console.log('@@@ results ', results);
            component.set("v.data", results);
        }
    },

    navigate: function (component, event, helper, objectType, row, userInfo) {

        var navigator = component.find('navService');
        var pg = {};

        console.log('@@@ userInfo.Profile.Name ' , userInfo.Profile.Name);
        console.log('@@@ objectType ' , objectType);

        if (userInfo.Profile.Name.includes('Filo Diretto') && objectType == 'task') {

            pg = {
                "type": "standard__component",
                "attributes": {
                    "componentName": "c__WGC_FiloDiretto_EsitazioneTask",
                },
                "state": {
                    "c__taskId": row.Id,
                    "c__rowData": row
                }
            };

            navigator.navigate(pg);
        }
        else {
            pg = {
                "type": "standard__recordPage",
                "attributes": {
                    "recordId": row.Id,
                    "objectApiName": objectType,
                    "actionName": "edit"
                }
            };

            navigator.navigate(pg);
        }
    },

    /*
    formatRecord : function(component, event, helper, fieldValue, column){
             
        if(column.type == 'DATE'){
            fieldValue = fieldValue.substring(0,10);
        }
        else if(column.type == 'DATETIME'){
            var tmp = [];
            tmp = fieldValue.split('T');
            fieldValue = tmp[0] + ' ' + tmp[1].substring(0,5);
        }

        return fieldValue;
    },
    */

   createDataTable: function (component, event) {
        var activityList = [];
        
        var eventList = component.get('v.resultActivity')[0].eventList;
        eventList.forEach(function (element) {
            activityList.push(element);
        });

        var taskList = component.get('v.resultActivity')[0].taskList;
        taskList.forEach(function (element) {
            activityList.push(element);
        });

        activityList =  activityList.sort((a, b) => {
            let aDate = new Date(a.ActivityDate);
            let bDate = new Date(b.ActivityDate);
            return aDate - bDate;
        });

        component.set('v.columns', [
            {label: 'Subject', fieldName: 'Subject', type: 'text', sortable: true, cellAttributes: {iconName: { fieldName: 'trendIcon' }, iconPosition: 'left' }},
            {label: "Data attività",
            fieldName: "ActivityDate",
            type: "date",
            sortable: true,
            typeAttributes:{
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                //hour: "2-digit",
                //minute: "2-digit"
            }},
            { label: 'Azione', type: 'button', typeAttributes: { label: $A.get("$Label.c.WGC_Esita"), name: 'Esita', title: 'Esita', class: 'btn_next' }, class: { fieldName: 'btn_next' } }
        ]);

        activityList.forEach(function (element) {
            if(element.Id.substring(0,3) == '00T'){
                element.trendIcon = 'standard:task';
            } else {
                element.trendIcon = 'standard:event';
            }
        });

        component.set("v.data",activityList);
    },

    sortData: function (cmp, fieldName, sortDirection) {
        var data = cmp.get("v.data");
        var reverse = sortDirection !== 'asc';

        var objName = cmp.get("v.objectName");
        if(fieldName == 'Id' && ( objName == 'oppIstruttoria' || objName == 'oppPerfContratti' || objName == 'oppAttProdotto' )) data = Object.assign([], data.sort(this.sortBy('Name', reverse ? -1 : 1)));
        else if(fieldName == 'Id' && ( objName == 'event' || objName == 'task' || objName == 'promemoria' || objName == 'completateEvent' || objName == 'completateTask' )) data = Object.assign([], data.sort(this.sortBy('Subject', reverse ? -1 : 1)));
        else if(fieldName == 'AccountId') data = Object.assign([], data.sort(this.sortBy('AccountName', reverse ? -1 : 1)));
        else data = Object.assign([], data.sort(this.sortBy(fieldName, reverse ? -1 : 1)));

        cmp.set("v.data", data);
    },
    sortBy: function (field, reverse, primer) {
        var key = primer
                    ? function(x) {
        return primer(x[field]);
        }
                    : function(x) {
        return x[field];
        };

        return function (a, b) {
            var A = key(a);
            var B = key(b);
            return reverse * ((A > B) - (B > A));
        };
    },

})