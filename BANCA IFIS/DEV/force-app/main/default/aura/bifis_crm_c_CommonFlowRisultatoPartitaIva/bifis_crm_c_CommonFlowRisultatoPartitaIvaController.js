({
    doInit : function(component,event,helper){
        
        var flowInputAnagraficaVar = component.get('v.flowInputAnagraficaVar');
        var flowInputAnagraficaBillingAddressCpd = "";
        var flowInputAnagraficaShippingAddressCpd = "";
        
        flowInputAnagraficaBillingAddressCpd += flowInputAnagraficaVar.BillingStreetType__c + " ";
        flowInputAnagraficaBillingAddressCpd += flowInputAnagraficaVar.BillingStreetName__c + " ";
        flowInputAnagraficaBillingAddressCpd += flowInputAnagraficaVar.BillingStreetNumber__c + " ";
        
        flowInputAnagraficaShippingAddressCpd += flowInputAnagraficaVar.ShippingStreetType__c + " ";
        flowInputAnagraficaShippingAddressCpd += flowInputAnagraficaVar.ShippingStreetName__c + " ";
        flowInputAnagraficaShippingAddressCpd += flowInputAnagraficaVar.ShippingStreetNumber__c + " ";     
        
        flowInputAnagraficaBillingAddressCpd = flowInputAnagraficaBillingAddressCpd.trim();
        flowInputAnagraficaShippingAddressCpd = flowInputAnagraficaShippingAddressCpd.trim();
        
        component.set('v.flowInputAnagraficaBillingAddressCpd',flowInputAnagraficaBillingAddressCpd);
        component.set('v.flowInputAnagraficaShippingAddressCpd',flowInputAnagraficaShippingAddressCpd);
        
    }, 
    
    handleRecordUpdated : function(component,event,helper){
        
    },    
    
    handleNavigate: function(component, event , helper) {
        
        var navigate = component.get("v.navigateFlow");
        
        // CONTROLLI DI VALIDITA'
        
        var overallValidity = true;
        
        if(!overallValidity){       
            
            return;
            
        }
        else {
            
            var flowInputAnagraficaVar = component.get('v.flowInputAnagraficaVar');         
            var flowInputAnagraficaShippingAddressCpd = component.get('v.flowInputAnagraficaShippingAddressCpd');
            
            // CONTROLLI PARTICOLARI DI NULLITA' CON OVERRIDE SILENTE
            
            if(component.find("flowInputAnagraficaViaSpedizioneInputId").get("v.value") === undefined){
                
                flowInputAnagraficaShippingAddressCpd = '';
                
            }    
            
            if(component.find("flowInputAnagraficaCittaSpedizioneInputId").get("v.value") === undefined){
                
                flowInputAnagraficaVar.ShippingCity = '';
                
            }    
            
            if(component.find("flowInputAnagraficaCapSpedizioneInputId").get("v.value") === undefined){
                
                flowInputAnagraficaVar.ShippingPostalCode = '';
                
            }    
            
            if(component.find("flowInputAnagraficaProvinciaSpedizioneInputId").get("v.value") === undefined){
                
                flowInputAnagraficaVar.ShippingState = '';
                
            }    
            
            if(component.find("flowInputAnagraficaTelefonoInputId").get("v.value") === undefined){
                
                flowInputAnagraficaVar.Phone = '';
                
            }
            
            if(component.find("flowInputAnagraficaFaxInputId").get("v.value") === undefined){
                
                flowInputAnagraficaVar.Fax = '';
                
            }            
            
            if(component.find("flowInputAnagraficaEmailInputId").get("v.value") === undefined){
                
                flowInputAnagraficaVar.Email__c = '';
                
            }  
            
            
            if(component.find("flowInputAnagraficaEmailPecInputId").get("v.value") === undefined){
                
                flowInputAnagraficaVar.EmailPEC__c = '';
                
            }           
            
            if(component.find("flowInputAnagraficaFatturatoInputId").get("v.value") === undefined){

                flowInputAnagraficaVar.Fatturato__c = null;
                
            }              
            
            if(component.find("flowInputAnagraficaCCIAAInputId").get("v.value") === undefined){

                flowInputAnagraficaVar.ProvinciaCCIAA__c = '';
                
            }              

            if(component.find("flowInputAnagraficaREAInputId").get("v.value") === undefined){

                flowInputAnagraficaVar.REA__c = '';
                
            }              

            navigate(event.getParam("action"));
            
        }
    } 
})