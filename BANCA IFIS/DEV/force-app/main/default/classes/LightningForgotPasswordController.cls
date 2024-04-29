public without sharing class LightningForgotPasswordController {

    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        try {
            //Site.forgotPassword(username);
			String c = Site.getName();
			if(Test.isRunningTest()){
				c='Banca_Ifis_Segnalatori21';
			}
			if(c.equals('Banca_Ifis_Segnalatori21') || c.equals('Banca_Ifis_Segnalatori2')) {
				List<String> parts = username.split('@');
				username = parts[0] + '.b1p3@' + parts[1];
			}
            List<Profile> segnDebIdList = [select id from Profile where Name = 'IFIS - Segnalatori' OR Name = 'IFIS - Segnalatori Partner'];
			List<Id> idProfileSegnalatori = new List<Id>();
			for (Profile tmp : segnDebIdList){
				idProfileSegnalatori.add(tmp.Id);
			}

			User u = [select Id, Name from User where username = :username and ProfileId in :idProfileSegnalatori and isActive = true limit 1 ];
			
            System.resetPassword(u.Id, true);
            
            ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
            if(!Site.isValidUsername(username)) {
                return Label.Site.invalid_email;
            }
            aura.redirect(checkEmailRef);
            return null;
        }
        catch (Exception ex) {
            return ex.getMessage();
        }
    }

}