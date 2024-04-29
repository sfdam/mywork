global class ReportPerformanceTest {
    
    global String reportId {get;set;}
    global String filter {get;set;}
    
    public ReportPerformanceTest () {
        String reportName = ApexPages.currentPage().getParameters().get('reportName');
		this.reportId = [
            SELECT Id, Name
            FROM Report
            WHERE DeveloperName =: reportName
        ][0].Id;
    }
    
	@AuraEnabled
	global static String getUrl(){
		String hostname = URL.getSalesforceBaseUrl().getHost();
		System.debug('hostname = '+hostname);
		Integer position = hostname.indexOf('--c');
		String mydomain='';
		String endUrl = '';
		if(position!=-1){
			mydomain = hostname.substring(0, position);
			endUrl = '.lightning.force.com'; 
		} else { 
			mydomain = hostname;
		}
		String lcBaseURL = 'https://' + mydomain + endUrl;	    
        System.debug('lcBaseURL = '+lcBaseURL);
		return lcBaseURL;
	}
}