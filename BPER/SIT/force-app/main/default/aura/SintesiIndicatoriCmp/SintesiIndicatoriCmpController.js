({
    doInit: function(component, event, helper) {
		var recordId = component.get("v.recordId");
        const indFilters = '&AccId=CRM_IndicatoriCliente__c.CRM_AccountId__c&AccountId='+recordId.slice(0, -3)
		var crossReports = []
		//var getUrl = component.get("c.getUrl")
		var getUrl = component.get("c.getUrl")
		var getUserWrapper = component.get("c.getUserWrapper")
		getUserWrapper.setParams({recordId: component.get("v.recordId")});
		getUserWrapper.setCallback(this, function(response) {
			var state = response.getState()
            if (state === 'SUCCESS') {
                component.set("v.isIndividual", response.getReturnValue().isIndividual)
				component.set("v.isBusiness", response.getReturnValue().isBusiness)
            }
        })
        $A.enqueueAction(getUserWrapper); 

        getUrl.setParams({recordId: recordId})
        getUrl.setCallback(this, function(response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
				component.set("v.lcBaseURL", response.getReturnValue())
                var initialURL = component.get("v.lcBaseURL")
                var reportName = component.get("v.reportName")
                if (component.get("v.isGruppo")) {
                
                }
                var benchmarkMINTER = 
                    initialURL +
                    "/apex/VF_Indicatori?reportName=Benchmark_MINTER_Qrm"+indFilters
                var benchmarkAccordatoSOW = 
                    initialURL +
                    "/apex/VF_Indicatori?reportName=Benchmark_Accordato_SOW_mPS"+indFilters
                var benchmarkUtilizzatoSOW = 
                    initialURL +
                    "/apex/VF_Indicatori?reportName=Benchmark_Utilizzato_SOW_MhE"+indFilters
                var benchmarkSmartIndex = 
                    initialURL +
                    "/apex/VF_Indicatori?reportName=Benchmark_Smart_Index_wh0"+indFilters
                var benchmarkRaccComplessiva = 
                    initialURL +
					"/apex/VF_Indicatori?reportName=Benchmark_Raccolta_Complessiva_QyK"+indFilters 
				var benchmarkSOW = 
					initialURL + 
					"/apex/VF_Indicatori?reportName=Benchmark_SOW_L4t"+indFilters
                var benchmarkCS = 
                    initialURL +
                    "/apex/VF_Indicatori?reportName=Benchmark_CS_ABI_HC3"+indFilters
                crossReports.push(benchmarkMINTER + ", " + benchmarkAccordatoSOW + ", " + benchmarkUtilizzatoSOW + ", " + benchmarkSmartIndex + ", " + benchmarkRaccComplessiva + ", " + benchmarkSOW + ", " + benchmarkCS)
                var encodedCrossReports = []
                crossReports.forEach(item => {
                    var encoded = encodeURI(item)
                    encodedCrossReports.push(encoded)
                })
                component.set("v.encodedCrossReports", encodedCrossReports)
                
                //var indicatori = response.getReturnValue().indicatori;
                var encodedUrl = encodeURI(benchmarkMINTER)
                component.set("v.benchmarkMINTER", encodedUrl)
                /* component.set("v.percScostDareImporti", movimenti.CRM_Dare_PercScostTotImporti__c)
                component.set("v.percScostDareImportiStyle", parseInt(movimenti.CRM_Dare_PercScostTotImporti__c, 10) > 0 ? 'color: #00AFA0; font-weight:bold' : 'color: red; font-weight:bold') */
                
                var encodedUrl = encodeURI(benchmarkAccordatoSOW)
                component.set("v.benchmarkAccordato", encodedUrl)
                /* component.set("v.percScostDareNumeri", movimenti.CRM_Dare_PercScostTotNumeri__c)
                component.set("v.percScostDareNumeriStyle", parseInt(movimenti.CRM_Dare_PercScostTotNumeri__c, 10) > 0 ? 'color: #00AFA0; font-weight:bold' : 'color: red; font-weight:bold') */
                
                
                var encodedUrl = encodeURI(benchmarkUtilizzatoSOW)
                component.set("v.benchmarkUtilizzato", encodedUrl)
                /* component.set("v.percScostAvereImporti", movimenti.CRM_Avere_PercScostTotImporti__c)
                component.set("v.percScostAvereImportiStyle", parseInt(movimenti.CRM_Avere_PercScostTotImporti__c, 10) > 0 ? 'color: #00AFA0; font-weight:bold' : 'color: red; font-weight:bold') */
                
                
                var encodedUrl = encodeURI(benchmarkSmartIndex)
                component.set("v.benchmarkSmartIndex", encodedUrl)
                /* component.set("v.percScostAvereNumeri", movimenti.CRM_Avere_PercScostTotNumeri__c)
                component.set("v.percScostAvereNumeriStyle", parseInt(movimenti.CRM_Avere_PercScostTotNumeri__c, 10) > 0 ? 'color: #00AFA0; font-weight:bold' : 'color: red; font-weight:bold') */
                
                var encodedUrl = encodeURI(benchmarkRaccComplessiva)
                component.set("v.benchmarkRaccolta", encodedUrl)
				
				var encodedUrl = encodeURI(benchmarkCS)
				component.set("v.benchmarkCS", encodedUrl)
				
				var encodedUrl = encodeURI(benchmarkSOW)
				component.set("v.benchmarkSOW", encodedUrl)
            }
        })
        $A.enqueueAction(getUrl);  
    },



})