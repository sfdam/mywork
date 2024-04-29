({
	doInit : function(component, event, helper) {
		var choiseObj = component.get('v.choiseObj');
        console.log('SV choiseObj', JSON.stringify(choiseObj));

        helper.apex(component, event, 'getUserInfo', {  })
        .then($A.getCallback(function (result) {
            console.log('Call getUserInfo result: ', result);
            component.set('v.userInfo', result);
            
        })).finally($A.getCallback(function () {
            helper.fetchPickListVal(component, 'Status', component.get('v.task'), 'stato');           
            helper.getDate(component, event, 'today');
        }));
		
    },  

    handleChange: function(component, event){
        var selectedOptionValue = event.getParam("value");
        component.set('v.selectedStatus',selectedOptionValue);
    },


    handleKeyUp: function (cmp, evt) {
        var isEnterKey = evt.keyCode === 13;
        if (isEnterKey) {
            var queryTerm = cmp.find('enter-search').get('v.value');
            alert('Searched for "' + queryTerm + '"!');
        }
    },

     
    handleClick : function (cmp, event, helper) {
        alert("You clicked: " + event.getSource().get("v.label"));
    },

    saveTask : function(component, event, helper){
        var subject = component.get('v.subject');
        console.log('subject',subject);
        var duedate = component.get('v.dueDate');
        console.log('duedate',duedate);
        var dueTime = component.get('v.dueTime');
        console.log('dueTime',dueTime);
        var status = component.get('v.selectedStatus');
        console.log('selectedStatus',status);
        var comment = component.get('v.comment');
        var userId = component.get('v.userInfo').Id;
        console.log('userId',userId);
        var recordId = component.get('v.recordId');
        console.log('recordId',recordId);
        var sObjectName = component.get('v.sObjectName');        
        helper.apex(component, event, 'createNewTask', { "dueDate": duedate, "DueTime": dueTime, "user_id": userId, "what_id": recordId ,"title": subject, "note": comment, "sObjectName": sObjectName, "Status": status, "Descrizione_Attivita": component.get('v.Descrizione_Attivita'), "Note_Attivita": component.get('v.Note_Attivita'), "Motivazione_chiamata__c": component.get('v.Motivazione_chiamata'), "Esito_Chiamata": component.get('v.Esito_Chiamata')})
        .then($A.getCallback(function (result) {
            if(result){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Task creato con successo",
                    "type" : "success"
                });
                toastEvent.fire();
                component.set('v.subject','');
                component.set('v.dueDate','');
                component.set('v.dueTime','');
                component.set('v.stato','');
                component.set('v.comment','');
                component.set('v.Esito_Chiamata','');
                component.set('v.Motivazione_chiamata','');
                component.set('v.Note_Attivita','');
                component.set('v.Descrizione_Attivita','');
            }
        }))
    },

    saveEvent : function(component, event, helper){
        var subject = component.get('v.subject');
        console.log('subject',subject);
        var startDate = component.get('v.startDate');
        console.log('startDate',startDate);
        var endDate = component.get('v.endDate');
        var comment = component.get('v.comment');
        var userId = component.get('v.userInfo').Id;
        console.log('userId',userId);
        var recordId = component.get('v.recordId');
        console.log('recordId',recordId);
        var sObjectName = component.get('v.sObjectName');
        helper.apex(component, event, 'createNewEvent', { "start_time": startDate, "end_time": endDate, "user_id": userId, "what_id": recordId ,"title": subject, "note": comment, "sObjectName": sObjectName})
        .then($A.getCallback(function (result) {
            if(result){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Evento creato con successo",
                    "type" : "success"
                });
                toastEvent.fire();
                component.set('v.subject','');
                component.set('v.startDate','');
                component.set('v.endDate','');
                component.set('v.comment','');
            }
        }))
    }
});