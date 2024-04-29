({
	doInit : function(component, event, helper) {
        
		var navService = component.find("navService");

        var pageReference = {    
			"type": "standard__webPage",
			"attributes": {
				"url": "https://app.powerbi.com/reportEmbed?reportId=a9869ed0-1b90-420b-a429-2079705cd635&autoAuth=true&ctid=934f8954-f2fc-430f-b0d5-ee79a1dffa51&config=eyJjbHVzdGVyVXJsIjoiaHR0cHM6Ly93YWJpLWV1cm9wZS1ub3J0aC1iLXJlZGlyZWN0LmFuYWx5c2lzLndpbmRvd3MubmV0LyJ9"
			}
		};
        navService.navigate(pageReference);
		
		

	}
})