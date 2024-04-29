({
    doInit: function(component, event, helper) {
        const ndgReportFilters = '&IdCEDFiliale=Account.PTF_Filiale__c.PTF_IdCED__c&IdCEDArea=Account.PTF_Area__c.PTF_IdCED__c&IdCEDDR=Account.PTF_DirezioneRegionale__c.PTF_IdCED__c&IdCEDBanca=Account.PTF_Banca__c.PTF_IdCED__c&NDGPortafogliato=Account.PTF_PortafoglioAssegnato__c&ModelloDiServizio=Account.ModelloDiServizio__c&IdCEDCapofila=Account.PTF_Capofila__c.PTF_IdCED__c';
        const ndgReportFiltersBPER = '&IdCEDFiliale=Account.PTF_Filiale__c.PTF_IdCED__c&IdCEDArea=Account.PTF_Area__c.PTF_IdCED__c&IdCEDDR=Account.PTF_DirezioneRegionale__c.PTF_IdCED__c&IdCEDBanca=Account.PTF_Banca__c.PTF_IdCED__c&ABI=Account.FinServ__BankNumber__c';
        //const ndgReportFilters = '&IdCEDFiliale=Account.PTF_Filiale__c.PTF_IdCED__c&IdCEDArea=Account.PTF_Area__c.PTF_IdCED__c&IdCEDDR=Account.PTF_DirezioneRegionale__c.PTF_IdCED__c&IdCEDBanca=Account.PTF_Banca__c.PTF_IdCED__c&ABI=Account.FinServ__BankNumber__c';
        var getUrl = component.get("c.getUrl")
        var getUserWrapper = component.get("c.getUserWrapper")
        var crossReports = []
        getUserWrapper.setCallback(this, function(response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                component.set("v.idCed", response.getReturnValue().usr.idced__c)
                component.set("v.isGruppo", response.getReturnValue().isGruppo)
            }
        })
        $A.enqueueAction(getUserWrapper); 
        
        getUrl.setCallback(this, function(response) {
            var state = response.getState()
            if (state === 'SUCCESS') {
                component.set("v.lcBaseURL", response.getReturnValue())
                var initialURL = component.get("v.lcBaseURL")
                var reportName = component.get("v.reportName")
                if (component.get("v.isGruppo")) {
                                    
                }
                var ndgMdsPtf = 
                    initialURL +
                    "/apex/ReportPerformance?reportName=PERF_NDG_per_modello_di_servizio_e_portafogli_a56"+ndgReportFilters
                var distribNdgRoleMDS = 
                    initialURL + 
                    "/apex/ReportPerformance?reportName=Distribuzione_NDG_per_Ruolo_e_MMDS_v1_5XP" // modificato il 18/05/2021 da VP
				var ptf0078 = 
                    initialURL + 
                    "/apex/ReportPerformance?reportName=Distribuzione_NDG_per_MDS_dashboard_v7Q" //Qui ci va il report grafico VP 27/10/2021 New_PTF_0078_v04_Djn
                var distribNDG_NEW = 
                    initialURL + 
                    "/apex/ReportPerformance?reportName=PTF_0128_Nuovo_Distribuzione_NDG_Grafico_Q83" // modificato il 25/08/2021 da VP - per il grafico nella Dashboard 
                var utilizzatoNDG = 
                    initialURL + 
                    "/apex/ReportPerformance?reportName=PERF_Utilizzato_per_MDS_yb3"+ndgReportFilters
                var redditoFatturatoNDG = 
                    initialURL + 
                    "/apex/ReportPerformance?reportName=PERF_RedditoFatturato_per_MDS_Yi1"+ndgReportFilters
                var accordatoNDG = 
                    initialURL + 
                    "/apex/ReportPerformance?reportName=Perf_Accordato_per_MDS_biT"+ndgReportFilters
                var patrimonioNDG = 
                    initialURL + 
                    "/apex/ReportPerformance?reportName=Perf_Patrimonio_per_MDS_E1r"+ndgReportFilters
                var nucleiMDSPtf = 
                    initialURL + 
                    "/apex/ReportPerformance?reportName=Nuclei_per_MMDS_e_PTF_new_sDZ"+ndgReportFilters
                crossReports.push(ndgMdsPtf+", " + distribNdgRoleMDS + ", "+utilizzatoNDG + ", " + redditoFatturatoNDG + ", " +distribNDG_NEW+ ", " + accordatoNDG + ",  " +patrimonioNDG + ", " +redditoFatturatoNDG + ", " + ptf0078) 
                var encodedCrossReports = []
                crossReports.forEach(item => {
                    var encoded = encodeURI(item)
                    encodedCrossReports.push(encoded)
                })
                component.set("v.encodedCrossReports", encodedCrossReports)
                
                //var url = initialURL + "/apex/ReportPerformance?reportName=Report_Performance_NDG_Report_Jrt&MDS=Account.ModelloDiServizio__c"
                var encodedUrl = encodeURI(ndgMdsPtf)
                component.set("v.ndgMdsPtf", encodedUrl)

                encodedUrl = encodeURI(distribNdgRoleMDS)
                component.set("v.distribNdgRoleMDS", distribNdgRoleMDS)


                encodedUrl = encodeURI(utilizzatoNDG)
                component.set("v.utilizzatoNDG", utilizzatoNDG)

                encodedUrl = encodeURI(redditoFatturatoNDG)
                component.set("v.redditoFatturatoNDG", redditoFatturatoNDG)

                encodedUrl = encodeURI(accordatoNDG)
                component.set("v.accordatoNDG", accordatoNDG)

                encodedUrl = encodeURI(distribNDG_NEW) // distribNDGRoleMDSNew
                component.set("v.distribNDG_NEW", distribNDG_NEW)//distribNDGRoleMDSNew

        
                encodedUrl = encodeURI(patrimonioNDG)
                component.set("v.patrimonioNDG", patrimonioNDG)

                
                encodedUrl = encodeURI(nucleiMDSPtf)
                component.set("v.nucleiMDSPtf", nucleiMDSPtf)
				
				encodedUrl = encodeURI(ptf0078)
                component.set("v.ptf0078", ptf0078)

                
            }
        })
        $A.enqueueAction(getUrl);  
    },



})