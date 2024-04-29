({
	doInit: function(component, event, helper){
		var actionNoteAgente = component.get("c.getNoteAgentePicklist");
		actionNoteAgente.setCallback(this, function(res) {
			console.log('@@@ res ' , res.getReturnValue());
			component.set("v.noteAgenteOptions", res.getReturnValue());
		});
		$A.enqueueAction(actionNoteAgente);

		var soc = component.get("v.userInfo").Societa__c;
		const today = new Date();
		if(soc == 'CoMark'){
			today.setDate(today.getDate() + 7);
		}
		$('#calendar').fullCalendar({
			locale: 'it',
            header: {
				left:   '', // title
				center: '',
				right:  'today prev,next'
			  },
            minTime: "08:00:00",
			maxTime: "20:00:00",
			defaultDate: today,
			weekends: false,
            allDaySlot: false,
			defaultView: 'agendaWeek',
			height: 300,
			firstDay: 1,
            slotLabelFormat: [
                'MMMM YYYY', // top level of text
                'HH:mm' // lower level of text
			],
			columnHeaderFormat: {
				month: 'dddd',
				week: 'dddd M/D',
				day: 'dddd M/D'
			},
	    	selectable: true,
			selectHelper: true,
			select: function(start, end) {
				var soc = component.get("v.userInfo").Societa__c;
                var userInfo = component.get("v.userInfo");
				console.log('soc: ',soc);
				console.log('delta: ',(end.get('hours') - start.get('hours')));

				if(soc == 'CoMark' || soc == 'Warrant' || soc == 'Innolva'){
					if(soc == 'CoMark' && (end.get('hours') - start.get('hours') < 2)){
						end =  $.fullCalendar.moment(start);
						end.add(2, 'hours');
						console.log(start);
						console.log(end);
					}else if(soc == 'Warrant'  && (end.get('hours') - start.get('hours') <= 1)){
						end =  $.fullCalendar.moment(start);
						end.add(1, 'hours');
						console.log(start);
						console.log(end);
					}
					
					component.set('v.status', 'send');
					component.set('v.start', moment.tz(start.format("YYYY-MM-DD HH:mm:ss"), 'Europe/London').isDST() ? start.subtract(2, 'hours').format("YYYY-MM-DD[T]HH:mm:ss[Z]") : start.subtract(1, 'hours').format("YYYY-MM-DD[T]HH:mm:ss[Z]"));
					component.set('v.end', moment.tz(end.format("YYYY-MM-DD HH:mm:ss"), 'Europe/London').isDST() ? end.subtract(2, 'hours').format("YYYY-MM-DD[T]HH:mm:ss[Z]") : end.subtract(1, 'hours').format("YYYY-MM-DD[T]HH:mm:ss[Z]"));

				}else{
					var title = prompt($A.get("$Label.c.WRT_CalendarViewController_prompt"));
					var eventData;
					if (title) {
	
						var action = component.get("c.createNewEvent");
						var params = { 
							start_time : start.format("YYYY-MM-DD HH:mm:ss"),
							end_time   : end.format("YYYY-MM-DD HH:mm:ss"),
							user_id    : component.get("v.user_id"),
							what_id    : component.get("v.recordId"),
							sobjectName    : component.get("v.sObjectName"),
							title      : title		
						};
						console.log("params",params);
						action.setParams(params);
	
						action.setCallback(this, function(actionResult) {
							
							if( actionResult.getReturnValue() ){
								$('#calendar').fullCalendar( 'refetchEvents' );
								console.log("save successful");
							}
							else{
	
								alert( "Save failed for some reason." );
							}
						});
						
						$A.run(function(){
							$A.enqueueAction(action);						
						});		
	
					}
				}
				$('#calendar').fullCalendar('unselect');
			},
	    	events: function(start, end, timezone, callback) {
				console.log('SV EVENTS');
	    		var user_id = component.get("v.user_id");	    		
				var action = component.get("c.getEvents");
				console.log('user_id',user_id);
				console.log('action: ',action);
				action.setParams(
					{ 
						start_time : start,
						end_time   : end,
						user_id    : user_id		
					}
				);

				action.setCallback(this, function(actionResult) {
					var val = JSON.parse(actionResult.getReturnValue());
					var soc = component.get("v.userInfo").Societa__c;
					console.log('SV actionResult', val);
					val.forEach(function (element) {
						var information = element.title;
						if(element.objectId){
							switch(element.objectId.substring(0, 3)) {
								case '001':
								  // code block for Account
								  if(soc != 'CoMark' && soc!= 'Warrant')
								  	information = information + '\n' + (element.accountName != null ? element.accountName : '') + ((element.accountCity || element.accountCap) ? ' - ' : '') + (element.accountCity != null ? element.accountCity + ' ' : '') + (element.accountCap != null ? element.accountCap : '');
								  break;
								case '00Q':
								  // code block for Lead
								  if(soc != 'CoMark' && soc!= 'Warrant')
								  	information = information + '\n' + (element.leadName != null ? element.leadName : '') + ((element.leadCity || element.leadCap) ? ' - ' : '') + (element.leadCity != null ? element.leadCity + ' ' : '') + (element.leadCap != null ? element.leadCap : '');
								  break;
								default:
								  // code block
								  information = information;
							}
						}						
						element.title = information;
					});
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
		    }
	    });
	},
	loadCalendar: function(component, event, helper) {
		component.set("v.user_id", event.getParam("calendarUserId"));
		
		$('#calendar').fullCalendar( 'refetchEvents' );
	},
	recordSelected: function(component, event, helper) {		
		component.set( "v.recordId", event.getParam("recordid") );
		component.set( "v.sObjectName", event.getParam("sobjectname") );		
	},

	return: function(component, event, helper) {		
		component.set('v.status', 'calendar');
		$('#calendar').fullCalendar( 'refetchEvents' );		
	},	

	save: function(component, event, helper) {		
		var action = component.get("c.createNewEvent");
		var params = { 
			start_time          : moment(component.get("v.start")).format("YYYY-MM-DD HH:mm:ss"),
			end_time            : moment(component.get("v.end")).format("YYYY-MM-DD HH:mm:ss"),
			user_id             : component.get("v.user_id"),
			what_id             : component.get("v.recordId"),
			sobjectName         : component.get("v.sObjectName"),
			title               : component.get("v.title"),
			note                : component.get("v.note"),
            noteAgente          : component.get("v.noteAgente"),
			motivazioneChiamata : component.get("v.motivazioneChiamata"),
            location            : component.get("v.location"),
			descrizioneAttivita : component.get("v.descrizioneAttivita"),
			noteAttivita: component.get("v.noteAttivita"),
			contactId: component.get("v.selectedRecord") !== undefined && component.get("v.selectedRecord") !== null ? component.get("v.selectedRecord").Id : null
		};
        console.log("params",params);
		action.setParams(params);
		action.setCallback(this, function(actionResult) {                        
	        if( actionResult.getReturnValue() ){
				component.set('v.status', 'calendar');
				component.set('v.note', '');

				$('#calendar').fullCalendar( 'refetchEvents' );
				console.log("save successful");
			} else {
				console.log('@@@ ', actionResult.getError());
		    	alert( "Save failed for some reason." );
			}
	    });
				    
		$A.run(function(){
			$A.enqueueAction(action);						
		});
	},	

})