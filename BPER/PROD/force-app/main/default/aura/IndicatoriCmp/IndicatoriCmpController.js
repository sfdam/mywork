({
    doInit: function(component, event, helper) {
		var recordId = component.get("v.recordId");
        const movFilters = '&AccId=CRM_Movimenti__c.CRM_AccountId__c&AccountId='+recordId.slice(0, -3)
		var crossReports = []
		//var getUrl = component.get("c.getUrl")
        var getBuiltWrapper = component.get("c.getBuiltWrapper")
        getBuiltWrapper.setParams({recordId: recordId})
        getBuiltWrapper.setCallback(this, function(response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                component.set("v.lcBaseURL", response.getReturnValue().baseURL)
                var initialURL = component.get("v.lcBaseURL")
                var reportName = component.get("v.reportName")
                if (component.get("v.isGruppo")) {
                
                }
                var movimentiDareImporti = 
                    initialURL +
                    "/apex/VF_Indicatori?reportName=Report_DARE_Importi_pf5"+movFilters
                var movimentiDareNumeri = 
                    initialURL +
                    "/apex/VF_Indicatori?reportName=Report_DARE_Numeri_K5T"+movFilters
                var movimentiAvereImporti = 
                    initialURL +
                    "/apex/VF_Indicatori?reportName=Report_AVERE_Importi_qNY"+movFilters
                var movimentiAvereNumeri = 
                    initialURL +
                    "/apex/VF_Indicatori?reportName=Report_AVERE_Numeri_NKn"+movFilters
                crossReports.push(movimentiDareImporti + ", " + movimentiDareNumeri + ", " + movimentiAvereImporti + ", " + movimentiAvereNumeri)
                var encodedCrossReports = []
                crossReports.forEach(item => {
                    var encoded = encodeURI(item)
                    encodedCrossReports.push(encoded)
                })
                component.set("v.encodedCrossReports", encodedCrossReports)
                
                var movimenti = response.getReturnValue().movimenti;
                var encodedUrl = encodeURI(movimentiDareImporti)
                component.set("v.movimentiDareImporti", encodedUrl)
                component.set("v.percScostDareImporti", movimenti.CRM_Dare_PercScostTotImporti__c)
                component.set("v.percScostDareImportiStyle", parseInt(movimenti.CRM_Dare_PercScostTotImporti__c, 10) > 0 ? 'color: #00AFA0; font-weight:bold' : 'color: red; font-weight:bold')
                
                var encodedUrl = encodeURI(movimentiDareNumeri)
                component.set("v.movimentiDareNumeri", encodedUrl)
                component.set("v.percScostDareNumeri", movimenti.CRM_Dare_PercScostTotNumeri__c)
                component.set("v.percScostDareNumeriStyle", parseInt(movimenti.CRM_Dare_PercScostTotNumeri__c, 10) > 0 ? 'color: #00AFA0; font-weight:bold' : 'color: red; font-weight:bold')
                
                
                var encodedUrl = encodeURI(movimentiAvereImporti)
                component.set("v.movimentiAvereImporti", encodedUrl)
                component.set("v.percScostAvereImporti", movimenti.CRM_Avere_PercScostTotImporti__c)
                component.set("v.percScostAvereImportiStyle", parseInt(movimenti.CRM_Avere_PercScostTotImporti__c, 10) > 0 ? 'color: #00AFA0; font-weight:bold' : 'color: red; font-weight:bold')
                
                
                var encodedUrl = encodeURI(movimentiAvereNumeri)
                component.set("v.movimentiAvereNumeri", encodedUrl)
                component.set("v.percScostAvereNumeri", movimenti.CRM_Avere_PercScostTotNumeri__c)
                component.set("v.percScostAvereNumeriStyle", parseInt(movimenti.CRM_Avere_PercScostTotNumeri__c, 10) > 0 ? 'color: #00AFA0; font-weight:bold' : 'color: red; font-weight:bold')
                
            }
        })
        $A.enqueueAction(getBuiltWrapper);  
    },



})