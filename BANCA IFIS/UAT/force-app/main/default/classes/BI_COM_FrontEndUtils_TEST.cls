/**
  * Progetto:         FrontEndUtils
  * Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
  * Descrizione:      Classe di test abbinata alla classe principale.
*/

 

@isTest(SeeAllData=true)
private class BI_COM_FrontEndUtils_TEST {

 

    @isTest
    private static void checkFreezedUsers() {

 

        BI_COM_FrontEndUtils_CTRL.checkFreezedUsers();

 

    }

 

    @isTest
    private static void freezeUsers() {

 

        BI_COM_FrontEndUtils_CTRL.freezeUsers();

 

    }

 

    @isTest
    private static void unfreezedUsers() {

 

        BI_COM_FrontEndUtils_CTRL.unfreezeUsers();

 

    }

	@IsTest
	private static void riassegnaTerritoriFD() {
		BI_COM_FrontEndUtils_CTRL.riassegnaTerritoriFD();
	}

 

}