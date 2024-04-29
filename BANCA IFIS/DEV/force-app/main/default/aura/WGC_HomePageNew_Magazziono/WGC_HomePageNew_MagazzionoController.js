({
    doInit : function(component, event, helper) {
		//Setting the Callback
        var action = helper.apexPromise(component,'c.countMagazzionoAperto');
        let count = 0;
        action.then(
            function(res) {
                
                component.set("v.accList",res.accList);
                component.set("v.taskMap", res.taskMap);
                component.set("v.eventMap", res.eventMap);
                component.set("v.opptyMap", res.opptyMap);
                
            }
        ).catch(
            function(error) {
                //component.set("v.status" ,error ) ; 
                console.log(error);
            }
        ).finally(() => {
            console.log('finally');
            
            let accList = component.get("v.accList");
            let taskMap = component.get("v.taskMap");
            let eventMap = component.get("v.eventMap");
            let opptyMap = component.get("v.opptyMap");
            accList.forEach(function (element) {
                    
                let taskCreatedDate = taskMap[element.Id]  ? taskMap[element.Id].CreatedDate : null;
                let eventCreatedDate = eventMap[element.Id]  ? eventMap[element.Id].CreatedDate : null;
                let opptyCreatedDate = opptyMap[element.Id]  ? opptyMap[element.Id].CreatedDate : null;
                
                console.log('AT : data ' +element.Id+'-------------' + taskCreatedDate + '-------------'+ eventCreatedDate + '-------------'+ opptyCreatedDate); 
                let datepiuricente = null;
                let curRec = new Object();
                let obj = '';
                if(taskCreatedDate != null && eventCreatedDate != null){
                    if(  taskCreatedDate > eventCreatedDate){
                    datepiuricente = taskCreatedDate;
                    curRec = taskMap[element.Id];
                    obj = 'Task';
                    }else{
                      datepiuricente = eventCreatedDate;
                      curRec = eventMap[element.Id];
                      obj = 'Event';
                    }
                }else{
                      if(taskCreatedDate != null){
                        datepiuricente = taskCreatedDate;
                        curRec = taskMap[element.Id];
                        obj = 'Task';
                      }else if(eventCreatedDate != null){
                        datepiuricente = eventCreatedDate;
                        curRec = eventMap[element.Id];
                        obj = 'Event';
                      }
                }
         
                //console.log('AT : taskCreatedDate '+element.Id+ '-------------'  + datepiuricente + '-------------'+ opptyCreatedDate);
                if(datepiuricente != null && opptyCreatedDate != null){
                    if(  datepiuricente < opptyCreatedDate){
                      curRec = opptyMap[element.Id];
                    }
                }else{
                      if(opptyCreatedDate != null){
                        curRec = opptyMap[element.Id];
                        obj = 'Opportunity';
                      }
                }
                
                console.log('AT : curRec ',JSON.stringify(curRec));
                console.log('AT : obj ',obj);
                if(obj == 'Task' || obj =='Event'){
                    if(curRec != null && curRec.Esito__c != null && (curRec.Esito__c == 'Positivo' || curRec.Esito__c == 'Neutro')){
                        count++;
                    }
                }
                if(obj == 'Opportunity'){
                    if(curRec != null && curRec.StageName != null && curRec.StageName != 'Vinta' && curRec.StageName != 'Persa'){
                        count++;
                    }
                }
                
                    
                     // VERIFICA DATA TASK
                    // VERIFICA DATA EVENT
                    // VERIFICA DATA OPP
                    // IL PIU Rrecente vince se rispetta le regole step 5 allora count++;
                  });
           component.set("v.numMagazzionoAperto",count);
             
        });
    },
    redirectReport : function(component, event, helper){
		var reportId = event.currentTarget.dataset.report;
		var navService = component.find("navService");
        var pageReference = {    
			"type": "standard__recordPage",
			"attributes": {
				"recordId": reportId,
				"objectApiName": "Report",
				"actionName": "view"
			}
	 	}

		navService.generateUrl(pageReference).then($A.getCallback(function(url) {
			window.open(url, '_self');
		}));
        // navService.navigate(pageReference);
    },
     tooltipOn : function(component, event, helper) {
        component.set("v.tooltip",true);
    },

    tooltipOff : function(component,event,helper) {
        component.set("v.tooltip", false);
    },
})