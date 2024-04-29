({
	doInit: function(component, event, helper){

		const today = new Date();
		$('#calendar').fullCalendar({
			locale: 'it',
            header: {
				left:   'title', // title
				center: '',
				right:  'today prev,next, agendaWeek, month'
			},
			slotLabelFormat: [
                'MMMM YYYY', // top level of text
                'HH:mm' // lower level of text
			],
			columnHeaderFormat: {
				month: 'dddd',
				week: 'dddd M/D',
				day: 'dddd M/D'
			},
            minTime: "08:00:00",
			maxTime: "20:00:00",
			defaultDate: today,
			height: 'auto',
			weekends: true,
			hiddenDays: [ 0 ],
	    	defaultView: 'agendaWeek',
	    	allDaySlot: false,
	    	selectable: true,
			selectHelper: true,
			businessHours: { start: '09:00', end: '18:00' },
			select: function(start, end) {
				event.preventDefault();
				event.stopPropagation();
				var allDay = !start.hasTime() && !end.hasTime();
				var view = $('#calendar').fullCalendar('getView');			
				if(allDay && view.name == 'month'){
					start = moment(start).set('hour', 9);
					end = moment(start).add(1, 'hours');				
					//end =  moment(start).set('hour', 18);
				}else{
					if(end.get('hours') - start.get('hours') <= 1){
						end =  $.fullCalendar.moment(start);
						end.add(1, 'hours');
					}
				}

				component.set('v.status', 'send');
				component.set('v.start', moment.tz(start.format("YYYY-MM-DD HH:mm:ss"), 'Europe/London').isDST() ? start.subtract(2, 'hours').format("YYYY-MM-DD[T]HH:mm:ss[Z]") : start.subtract(1, 'hours').format("YYYY-MM-DD[T]HH:mm:ss[Z]"));
				component.set('v.end', moment.tz(end.format("YYYY-MM-DD HH:mm:ss"), 'Europe/London').isDST() ? end.subtract(2, 'hours').format("YYYY-MM-DD[T]HH:mm:ss[Z]") : end.subtract(1, 'hours').format("YYYY-MM-DD[T]HH:mm:ss[Z]"));
				//component.set('v.end', end.format("YYYY-MM-DD[T]HH:mm:ss[Z]"));
				// component.set('v.start', start.utc().format("YYYY-MM-DD[T]HH:mm:ss[Z]"));
				// component.set('v.end', end.utc().format("YYYY-MM-DD[T]HH:mm:ss[Z]"));

				$('#calendar').fullCalendar('unselect');
			},
	    	events: function(start, end, timezone, callback) {
	    		var user_id = component.get("v.user_id");	    		
				var action = component.get("c.getEvents");
				action.setParams(
					{ 
						start_time : start,
						end_time   : end,
						user_id    : user_id		
					}
				);

				action.setCallback(this, function(actionResult) {
					var val = JSON.parse(actionResult.getReturnValue());								   
					callback(val);
					
			    });
				$A.enqueueAction(action);	
				
			},
			eventRender: function (info) {

			},
		    eventClick: function(calEvent, jsEvent, view) {
    	        
    	        var navToSObjEvt = $A.get("e.force:navigateToSObject");
		        navToSObjEvt.setParams({
		            recordId: calEvent.id,
		            slideDevName: "detail"
		        }); 
		        navToSObjEvt.fire();
			},
			eventAfterAllRender: function(view) {
				if( /Android|iPhone|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
				  $('#calendar').fullCalendar('changeView', 'agendaDay');
				} //IF MOBILE CHANGE VIEW TO AGENDA DAY
			}
	    });
	},

	recordSelected: function(component, event, helper) {		
		component.set( "v.recordId", event.getParam("recordid") );
		component.set( "v.sObjectName", event.getParam("sobjectname") );		
	},

	return: function(component, event, helper) {		
		component.set('v.status', 'calendar');
		component.set('v.objectAPIName', 'generico');
		component.set('v.selectedRecord_account', {});
		component.set('v.selectedRecord_lead', {});
		component.set('v.selectedRecord_contact', {});
		component.set('v.title', '');
		component.set('v.note', '');
		// // call the event   
		// var compEvent = component.getEvent("clearSelectedRecordEvent");
		// // set the Selected sObject Record to the event attribute.  
		// compEvent.setParams({});
		// // fire the event  
		// compEvent.fire();
		$('#calendar').fullCalendar( 'refetchEvents' );		
		
	},	

	save: function(component, event, helper) {		
		let objectType = component.get('v.objectAPIName');

		var action = component.get("c.createNewEvent");
		var params = { 
			start_time  : moment(component.get("v.start")).format("YYYY-MM-DD HH:mm:ss"),
			end_time    : moment(component.get("v.end")).format("YYYY-MM-DD HH:mm:ss"),
			user_id     : component.get("v.user_id"),
			what_id     : objectType == 'account' ? component.get("v.selectedRecord_account").Id : objectType == 'lead' ? component.get("v.selectedRecord_lead").Id : objectType == 'contact' ? component.get("v.selectedRecord_contact").Id : null,
			sobjectName : objectType,
			title       : component.get("v.title"),
			note        : component.get("v.note")			
		};
        console.log("params",params);
		action.setParams(params);
		action.setCallback(this, function(actionResult) { 
			
	        if( actionResult.getReturnValue() ){
				if(actionResult.getReturnValue().success){
					var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        "title": "Success",
					        "message": "Evento creato",
					        "type" : "success"
					    });
						toastEvent.fire();

				} else {
					var toastEvent = $A.get("e.force:showToast");
					    toastEvent.setParams({
					        "title": "Errore!",
					        "message": actionResult.getReturnValue().msg,
					        "type" : "error"
					    });
					    toastEvent.fire();

				}			
				component.set('v.status', 'calendar');
				component.set('v.objectAPIName', 'generico');
				component.set('v.selectedRecord_account', {});
				component.set('v.selectedRecord_lead', {});
				component.set('v.selectedRecord_contact', {});
				component.set('v.title', '');
				component.set('v.note', '');

				$('#calendar').fullCalendar( 'refetchEvents' );

				console.log("save successful");
			} else {
		    	alert( "Save failed for some reason." );
			}
	    });
				    
			$A.enqueueAction(action);						
	},
	
})