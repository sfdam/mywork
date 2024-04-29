({
	
	doInit : function(component, event, helper) {
		helper.apex(component, event, 'getData', {"recordId" : component.get('v.recordId') })
        .then($A.getCallback(function (result) {
			var LineItems = result.ItemList;
			var sheduleItems = result.scheduleList;
			// component.set('v.isSendable',result.isSendable);
			component.set("v.isSendableWon", result.isSendableClosedWon);
			component.set("v.isSendableCodCliente", result.isSendableCodCliente);
			
			LineItems.forEach(function (element){

				sheduleItems.forEach(schedule => {
					if(schedule.OpportunityLineItemId == element.Id ){
						schedule.Name = element.ProductName__c;
						schedule.Invio = false;
						schedule.DescrProd = element.Description;
					}
				});	
			});
			component.set('v.schItems',sheduleItems);
		})).finally($A.getCallback(function () {
				var items= component.get('v.schItems');
				var table = $('#tableId').DataTable({
					"data": items,
					"searching": false,
					"lengthChange": false,
					"select": false,
					"paging" : false,
					"ordering":true,
					"columnDefs": [ 
						{
							"targets": 5, //Targets would be the 0 based index of the column
                            "responsivePriority": 4,
							"data": 'Fatturabile__c',
							"render": function ( data, type, full, meta ){
									return data ? '<input type="checkbox" name="fatturabile" id="check_' + full.Id + '" value=' + full.Fatturabile__c + ' checked />' : '<input type="checkbox" name="fatturabile" id="check_' + full.Id + '" value=' + full.Fatturabile__c + ' onclick="{!c.onClick}"/>'

								}
					   },
					   {
						"targets": 6,
                           "responsivePriority": 5,
						"data": 'Invio',
						"render": function ( data, type, full, meta ){
							return data ? '<input type="checkbox" name="invio" id="check_' + full.Id + '" value=' + full.Invio + ' checked />' : '<input type="checkbox" name="invio" id="check_' + full.Id + '" value=' + full.Invio + ' />'
					  	}
					   },
					   {
						   "targets": 7,
                           "responsivePriority": 6,
						   "data": "Data_ultimo_invio__c",
						   "render": function ( data, type, full, meta ){
							   console.log(data);
								return full.Data_ultimo_invio__c ? moment(full.Data_ultimo_invio__c,'YYYY-MM-DD',true).format("DD/MM/YYYY") : '';

							}
					   },
					   {
							"targets": 2,
                           "responsivePriority": 3,
							"data": "ScheduleDate",
							"render": function ( data, type, full, meta ){
								return moment(data,'YYYY-MM-DD',true).format("DD/MM/YYYY");
							}
						},
						{
							"targets": 1,
                            "responsivePriority": 2,
							"render": $.fn.dataTable.render.number( ',', '.', 2, '', '€'  )
						},{
							"targets": 3,
                            "responsivePriority": 10001 
						},{
							"targets": 4,
                            "responsivePriority": 10002 
						},{
							"targets": 0,
                            "responsivePriority": 1
						}
					 ],
					 "fixedHeader": {
						"footer": true
					},
					
					"columns":[ 						
						{ 	
							"data": 'Name',
							"className": "tableCol1",
							"type": 'string',
							"defaultContent": "",
						 },
                        { 
							"data": 'Revenue', 
							"className": "tableCol3", 
							"type": 'Number', 
							"defaultContent": "" 
						},
						{ 
							"data": 'ScheduleDate', 
							"className": "tableCol6", 
							"type": 'Date', 
							"defaultContent": "" 
						},
						
						{
							"data": 'DescrProd',
							"className": "tableCol8", 
							"type": 'string',
							"orderable": false, 
							"defaultContent": "" 
						},
						{ 
							"data": 'Description', 
							"className": "tableCol5", 
							"type": 'string',
							"orderable": false, 
							"defaultContent": "" 
							
						},						
						{ 
							"data": 'Fatturabile__c', 
							"className": "check", 
							"orderable": false,
							"type": 'html' 
						},
						{ 
							"data": 'Invio', 
							"className": "check",
							"orderable": false, 
							"type": 'html' 
						},
						{ 
							"data": 'Data_ultimo_invio__c', 
							"className": "tableCol9",
							"orderable": false, 
							"type": 'Date',
							"defaultContent": "" 
						},					
					],					
					"rowGroup": true,
					"responsive": true,
					"rowGroup": {
						"dataSrc": 'Name'  
						},					
				});

				

				$('#tableId').on('click', 'input[type="checkbox"]', function() {
					var item = table.row(this.closest('tr')).data();
					var name = $(this).attr("name");
					if(name=='fatturabile')item.Fatturabile__c = !item.Fatturabile__c;
					if(name=='invio')item.Invio = !item.Invio;
				});				
			}));
	},

	

	onClickSave: function(component, event, helper) {
		var items = component.get('v.schItems');
		console.log('save : ',JSON.stringify(items));
		helper.apex(component, event, 'SaveItems', {"itemList" : JSON.stringify(items), "send" : false })
        .then($A.getCallback(function (result) {
			if(result){
				var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": $A.get("$Label.c.INF_SendEmailComponent_ToastSaveSuccess"),
                    "type" : "success"
                });
                toastEvent.fire();
				component.find("overlayLib").notifyClose();
											
				}else{
					var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error",
                        "message": $A.get("$Label.c.INF_SendEmailComponent_ToastSaveError"),
                        "type" : "error"
                    });
                    toastEvent.fire();
				}
			}));
	},

	onClickSend: function(component, event, helper) {
		var items = component.get('v.schItems');

		// var sendable = component.get('v.isSendable');
		let sendableWon = component.get("v.isSendableWon");
		let sendableCodCliente = component.get("v.isSendableCodCliente");

		// if (!sendable){
		// 	var toastEvent = $A.get("e.force:showToast");
        //             	toastEvent.setParams({
        //                     "title": "Error",
        //                     "message": $A.get("$Label.c.INF_SendEmailComponent_ToastSendWon"),
        //                     "type" : "warning"
        //                 });
        //                 toastEvent.fire();
		if(!sendableWon){
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Error",
				"message": $A.get("$Label.c.INF_SendEmailComponent_ToastSendWon"),
				"type" : "warning"
			});
			toastEvent.fire();
		} else if(!sendableCodCliente){
			var toastEvent = $A.get("e.force:showToast");
			toastEvent.setParams({
				"title": "Error",
				"message": $A.get("$Label.c.INF_SendEmailComponent_ToastSendCodCliente"),
				"type" : "warning"
			});
			toastEvent.fire();
		}else{
			helper.apex(component, event, 'SaveItems', {"itemList" : JSON.stringify(items), "send" : true })
					.then($A.getCallback(function (result) {
						if(result){
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								"title": "Success",
								"message": $A.get("$Label.c.INF_SendEmailComponent_ToastSendSuccess"),
								"type" : "success"
								});
							toastEvent.fire();
							component.find("overlayLib").notifyClose();
						}else{
							var toastEvent = $A.get("e.force:showToast");
							toastEvent.setParams({
								"title": "Error",
								"message": $A.get("$Label.c.INF_SendEmailComponent_ToastSendError"),
								"type" : "error"
							});
							toastEvent.fire();
						}
					}));
				}
			}

})