({
	doInit : function(component, event, helper) {
		console.log('TEST start INIT');

        var test1 = [];
        var action = component.get("c.getRecordTypes");
        var finalList = [];

        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS') {

                test1 = response.getReturnValue();
                console.log('DEBUG***** NewOpportunityCmpControllerjs.doInit - test1 is: '+JSON.stringify(test1.length));

                if(test1.length>0){
                    for(var i=0;i<test1.length;i++){
                        finalList.push({'label':test1[i],'value':test1[i]});
                    }
                }
                console.log('DEBUG***** NewOpportunityCmpControllerjs.doInit - finalList is: '+JSON.stringify(finalList));
                component.set('v.ListOption',finalList);

                var test2 = component.get('v.ListOption');
                 console.log('DEBUG***** NewOpportunityCmpControllerjs.doInit - v.ListOption is: '+JSON.stringify(test2));
                
            }
        });   

        $A.enqueueAction(action);
	},

    handleClick : function(component, event, helper){
        console.log('TEST start handleClick');
        var getOptionSelected = component.get('v.value');
        console.log('DEBUG***** NewOpportunityCmpControllerjs.handleClick - getOptionSelected is: '+getOptionSelected);
        var action = component.get("c.getRecordtypeSelected");

        if(!getOptionSelected){
            console.log('DEBUG***** NON HAI INSERITO IL TYPE');
            component.set('v.showError',true);
        }else{
        
            if(getOptionSelected != 'Corporate Finance' && getOptionSelected != 'Structured Finance' && getOptionSelected != 'Traditional Banking' && getOptionSelected != 'Estero' && getOptionSelected != 'Leasing'){
                component.set('v.showChoise',false);
                

                action.setParams({
                    recordType: getOptionSelected
                });

                action.setCallback(this, function(response){

                    var state = response.getState();

                    if(state == 'SUCCESS') {

                        var returnValue = response.getReturnValue();
                        console.log('DEBUG***** NewOpportunityCmpHelperjs.handleClick - returnValue is: '+returnValue);
                        var urlTo = '/lightning/o/Opportunity/new?count=1&nooverride=1&useRecordTypeCheck=1&navigationLocation=LIST_VIEW&recordTypeId='+returnValue;

                        helper.redirect(component, event, helper,urlTo);
                    }
                });
            
            }else if((getOptionSelected == 'Corporate Finance' || getOptionSelected == 'Structured Finance' || getOptionSelected == 'Traditional Banking' || getOptionSelected == 'Estero' || getOptionSelected == 'Leasing')){
                component.set('v.showChoise',false);
                console.log('DEBUG***** IN ELSE IF');
                var flow = component.find("flowData");
                var inputVariables = [
                {
                    name : 'RecordTypeChoise',
                    type : 'String',
                    value : component.get("v.value")
                }
                ];
                flow.startFlow("CIB_Create_New_Opportunity", inputVariables);

            }else{
                if(!getOptionSelected){
                    console.log('DEBUG***** NON HAI INSERITO IL TYPE');
                }
            }
            $A.enqueueAction(action);
        }

        
        
    },

    closeTab : function(component, event, helper){
        var workspaceAPI = component.find("workspace");
		workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
    }

})