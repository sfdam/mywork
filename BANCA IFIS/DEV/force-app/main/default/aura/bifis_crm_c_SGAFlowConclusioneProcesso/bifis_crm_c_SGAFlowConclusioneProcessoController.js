({
    doInit : function(component, event, helper) {    
        

    },
    
    handleNavigate: function(component, event , helper) {

        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;    
        
        
        if(!overallValidity){       
            
            return;
            
        }
        else {
  
            if(event.getParam("action") == 'FINISH'){

                //navigate(event.getParam("action"));           

				$A.get("e.force:closeQuickAction").fire() ;
                
                $A.get('event.force:refreshView').fire(); 
  
                
            }      
            
        }
        
        
    }    
})