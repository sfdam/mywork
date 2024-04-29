({
	doInit : function(component, event, helper) { 

		component.set('v.recordType','Tracciato Record:<ul><li>NDG</li><li>COGNOME</li><li>NOME</li></ul>');
	
        var promise = new Promise( $A.getCallback( function( resolve , reject ) { 

            var action = component.get("c.isProdOrg");
                    
            action.setCallback( this , function(callbackResult) {

                if(callbackResult.getState()=='SUCCESS') {
                    resolve( 
                        callbackResult.getReturnValue()
                    );

					var resultState = callbackResult.getReturnValue();
			
                    var toastEvent = $A.get("event.force:showToast");

					if(resultState){
						toastEvent.setParams({
							title : 'Operazione non possibile',
							message: 'Questa è una ORG di produzione. Il mascheramento non è ammesso!',
							duration:' 10000',
							key: 'info_alt',
							type: 'error',
							mode: 'pester'
						});
					}
                    
                    toastEvent.fire();   

					if(resultState){
						var fileUploaderCSVFile = component.find("fileUploaderCSVFile");
						fileUploaderCSVFile.set("v.disabled",true);
                    }
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));    
        
        return promise;

	},
	
	handleFilesChange: function(component, event, helper) {

		// CLEANUP INIZIALE

		component.set('v.isProgressing', false);
		component.set('v.isEnded', false);
		component.set('v.fileRows',0);
		component.set('v.fileQuality','-');
		component.set('v.recordMalformedLength','-');

		var buttonInfoFile = component.find("buttonInfoFile");
		buttonInfoFile.set("v.disabled",true);

		component.set('v.updatedRecords',0);
		component.set('v.deletedRecords',0);
		component.set('v.notFoundRecords',0);
		component.set('v.errorRecords',0);
		component.set('v.PGRecords',0);
		component.set('v.PFRecords',0);

		var fileName = 'Nessun file selezionato ...';

		if (event.getSource().get("v.files").length > 0) {
			fileName = event.getSource().get("v.files")[0]['name'];

		}

		component.set("v.fileName", fileName);
			
		var buttonUploadCSVFile = component.find("buttonUploadCSVFile");

		buttonUploadCSVFile.set("v.disabled",false);


	},

	fileUploaderAcquireFile: function(component, event, helper) {
	
		var fileInput = component.find("fileUploaderCSVFile").get("v.files");
		var file = fileInput[0];

		var buttonUploadCSVFile = component.find("buttonUploadCSVFile");
		var buttonInfoFile = component.find("buttonInfoFile");

		if (file) {

			console.log("File CSV Mascheramento GDPR");

			var reader = new FileReader();
			reader.readAsText(file, "UTF-8");

				reader.onload = function (evt) {
					console.log("EVT FN");
					var csv = evt.target.result;
					console.log('@@@ csv file contains'+ csv);
					var fileParsingResult = helper.CSV2JSON(component,csv,component.get('v.csvSeparator'));
					console.log('@@@ result = ' + fileParsingResult);

					var obj = JSON.parse(fileParsingResult);

					component.set('v.fileRows',obj.length);
					component.set('v.fileQuality','OK');

					buttonUploadCSVFile.set("v.disabled",true);
					buttonInfoFile.set("v.disabled",false);

					component.set('v.fileParsingResult',fileParsingResult);
		
				}

				reader.onerror = function (evt) {
				
					console.log("ERRORE nella lettura del file");

				}	

		}

		if(component.set('v.fileQuality','KO')){
			buttonInfoFile.set("v.disabled",true);
		}
			
	},

	infoFile: function(component, event, helper) {

		var buttonUploadCSVFile = component.find("buttonUploadCSVFile");
		var buttonInfoFile = component.find("buttonInfoFile");

		buttonUploadCSVFile.set("v.disabled",true);
		buttonInfoFile.set("v.disabled",true);

		component.set('v.isProgressing', true);	

		var fileParsingResult = component.get('v.fileParsingResult');

		var obj = JSON.parse(fileParsingResult);

		while (obj.length > 0)
		{

			helper.promiseExecution(component, event, helper, obj[0]);
			obj.splice(0, 1);

		}
		
		
	}

})