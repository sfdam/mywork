({
	helperMethod : function() {
		
	},

	apex: function (component, event, apexAction, params) {
		var p = new Promise($A.getCallback(function (resolve, reject) {
			var action = component.get("c." + apexAction + "");
			action.setParams(params);
			action.setCallback(this, function (callbackResult) {
				if (callbackResult.getState() == 'SUCCESS') {
					resolve(callbackResult.getReturnValue());
				}
				if (callbackResult.getState() == 'ERROR') {
					console.log('ERROR', callbackResult.getError());
					reject(callbackResult.getError());
				}
			});
			$A.enqueueAction(action);
		}));
		return p;
	},

    dataProcess: function (component, event, data) {
        var attivita = component.get('v.attivita');

        var elementList = [];
        if(attivita == 'all' || attivita == 'event'){
            data.eventList.forEach(function (element) {
                    element.objectType = 'Event';
                    element.isCollapsed = true;
                    elementList.push(element);
            });
        }

        if(attivita != 'event'){
            data.taskList.forEach(function (element) {
                    element.objectType = 'Task';
                    element.isCollapsed = true;
                    elementList.push(element);
            });
        }

        elementList.sort( this.compare );

		return elementList;
    },
    
    compare: function  ( first, second ) {
        var a = new Date(first.ActivityDate);
        var b = new Date(second.ActivityDate);
        if ( a < b ){
          return 1;
        }
        if ( a > b ){
          return -1;
        }
        return 0;
    }
})