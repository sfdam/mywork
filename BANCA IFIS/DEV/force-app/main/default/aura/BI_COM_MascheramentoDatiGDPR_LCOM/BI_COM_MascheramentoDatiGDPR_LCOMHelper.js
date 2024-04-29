({
	CSV2JSON: function (component,csv) {

		component.set('v.recordMalformedLength','NO');

		var arr = []; 

			try{

				arr =  csv.split('\n');;

				arr.pop();
				var jsonObj = [];
				var headers = arr[0].split(component.get('v.csvSeparator'));

				for(var i = 1; i < arr.length; i++) {

					var data = arr[i].split(component.get('v.csvSeparator'));

					if(data.length !== component.get('v.columnNumber')){
						component.set('v.recordMalformedLength','SI');
					}

					var obj = {};

					for(var j = 0; j < data.length; j++) {
						obj[headers[j].trim()] = data[j].trim();
					}

					jsonObj.push(obj);

				}

				var json = JSON.stringify(jsonObj);

				return json;

			}
			catch(e){

				console.log("ECCEZIONE nella lettura del file " + e);
				component.set('v.fileQuality','KO');

			}

	},

    serverSideCall : function(component,action) {

        return new Promise(function(resolve, reject) { 
            action.setCallback(this, 
                               function(response) {
                                   var state = response.getState();
                                   if (state === "SUCCESS") {
                                       resolve(response.getReturnValue());
                                   } else {
                                       reject(new Error(response.getError()));
                                   }
                               }); 
            $A.enqueueAction(action);
        });
    },

    promiseExecution : function(component, event, helper, record) {

        var action = component.get("c.importGDPRCSVRecord");

		action.setParams({
            "jsonRECORD" : JSON.stringify(record)
        });

        helper.serverSideCall(component,action).then(
            function(resultState) {
			
					var resultStateObj = JSON.parse(resultState);
					
					var updatedRecords = component.get('v.updatedRecords');
					var deletedRecords = component.get('v.deletedRecords');
					var notFoundRecords = component.get('v.notFoundRecords');
					var errorRecords = component.get('v.errorRecords');

					if(resultStateObj.ESITO === 'U'){
						updatedRecords++;
						component.set('v.updatedRecords',updatedRecords);
					}
					if(resultStateObj.ESITO === 'D'){
						deletedRecords++;
						component.set('v.deletedRecords',deletedRecords);
					}
					if(resultStateObj.ESITO === 'N'){	
						notFoundRecords++;
						component.set('v.notFoundRecords',notFoundRecords);
					}
					if(resultStateObj.ESITO === 'E'){
						errorRecords++;
						component.set('v.errorRecords',errorRecords);
					}

					if(component.get('v.fileRows') === updatedRecords + deletedRecords + notFoundRecords + errorRecords){
					
						component.set('v.isProgressing', false);
						component.set('v.isEnded', true);

					}

					if(resultStateObj.TIPO_ENTITA === 'PG'){
						var PGRecords = component.get('v.PGRecords');
						component.set('v.PGRecords',PGRecords + 1);
					}

					if(resultStateObj.TIPO_ENTITA === 'PF'){
						var PFRecords = component.get('v.PFRecords');
						component.set('v.PFRecords',PFRecords + 1);
					}
            }
        ).catch(
            function(error) {
                console.log(error);
            }
        );
    }
})