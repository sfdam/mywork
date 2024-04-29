({
	doInit : function(component, event, helper)  {
        helper.computeProgress(component, event, helper);
        
	},
    
    computeProgress : function(component, event, helper)  {
        var totalVal = component.get("v.totalProgress");
        var actualVal = component.get("v.actualProgress");
        console.log('@@@ totalVal ' , totalVal);
        console.log('@@@ actualVal ' , actualVal);
        if(totalVal != null && actualVal != null && !isNaN(parseInt(totalVal)) && isFinite(totalVal) && !isNaN(parseInt(actualVal)) && isFinite(actualVal)){
            //parameter is number 
            var percVal = (isFinite(parseInt(actualVal) / parseInt(totalVal)) ? parseInt(actualVal) / parseInt(totalVal) : 0) ;
            // console.log('@@@ percVal ' , percVal);
            var progressVal = parseInt(  percVal * 360  ) ;
            console.log('@@@ progressVal ' , progressVal);
            component.set("v.cirDeg" , (progressVal > 360 ? '360' : progressVal));
            component.set("v.perText" , (parseInt(percVal * 100) > 100 ? '100' : parseInt(percVal * 100))  +'%' ); 
        }else if(actualVal != null){
            console.log('@@@ chiama metodo apex');
            helper.callApexMethod(component, event, helper, totalVal, actualVal);
        }
    },
    
    callApexMethod : function(component, event, helper, txt_totalVal, txt_actualVal)  {
        
        var action = component.get('c.computePercentage');
        var txt_recordId = component.get("v.recordId");
        var txt_sObjectName = component.get("v.sObjectName");
        
        action.setParams({
            recordId : txt_recordId,
            sObjectName : txt_sObjectName,
            totalValueFieldName : txt_totalVal,
            actualValueFieldName : txt_actualVal
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === 'SUCCESS') {
                var percVal = a.getReturnValue() ; 
                var progressVal = parseInt(  (percVal/100) * 360  ) ; 
                component.set("v.cirDeg" , progressVal );
                component.set("v.perText" , parseInt(percVal)  +'%' );              
            }  
        });
        $A.enqueueAction(action);  
    }
})