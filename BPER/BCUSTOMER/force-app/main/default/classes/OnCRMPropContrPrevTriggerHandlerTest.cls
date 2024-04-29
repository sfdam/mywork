@isTest
public class OnCRMPropContrPrevTriggerHandlerTest {
    @TestSetup
    public static void setup(){

        Profile profile = [SELECT id FROM Profile WHERE Name =: Label.System_Administrator LIMIT 1];
        User user = AllDataFactory.getUser('01', profile.Id, 'CORPORATE');
        insert user;

        System.runAs(user)
        {

            Account acc = AllDataFactory.getAccount('01', 'PersonAccount');
            insert acc;

            CRM_ProposteContrattiPreventivi__c crm = new CRM_ProposteContrattiPreventivi__c ();
            crm.CRM_NDGPrimario__c=acc.id; 
            crm.Name='Test';
            crm.CRM_Autore__c	='Test';
            crm.CRM_Banca__c='test';
            crm.CRM_Filiale__c='0032';	
            crm.CRM_Id__c='109066';
            crm.CRM_StatoContratto__c='Contratto da perfezionare';
            crm.CRM_TipologiaRecord__c='ONLINE';
            crm.CRM_Autore__c='test';
            crm.OwnerId=user.id;

            Date today = Date.today();
            crm.CRM_DataInserimento__c=today;
            crm.CRM_DataScadenza__c	=today;
            //CRM_DataUltimaModifica__c	
            crm.CRM_Esito__c='Prodotto venduto';
            crm.CRM_Motivo__c='';	
            //crm.CRM_NDGCointestazione__c='';	
            crm.CRM_Note__c	='';
            crm.CRM_Referente__c='';
            crm.CRM_StatoProposta__c=''	;
            crm.CRM_UnitaOrganizzativa__c='';

            insert crm;
        }

    }

    @IsTest
        static void testUpdateProposte(){
            /*CRM_ProposteContrattiPreventivi__c proposta = [SELECT id,CRM_Esito__c FROM CRM_ProposteContrattiPreventivi__c WHERE Name='Test'];
            proposta.Name='TEST2';
            update proposta;*/
        }
}