@RestResource(urlMapping='/v1/getReferentiAziendali/*')
global class REST_getReferentiAziendali
{
    public REST_getReferentiAziendali()
    {

    }

    @HttpGet
    global static void getReferentiAziendaliRequest ()
    {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        
        try
        {
            String abi = req.params.get('abi');
            String ndg = req.params.get('ndg');

            String abi_ndg = abi + '_' + ndg;
            List<Contact> contactList = [select Name, CRM_Ambito__c, CRM_Telefono__c, CRM_Email__c, Description from Contact where RecordTypeid='0123X0000015xpdQAA' AND Account.NDW_ExternalId__c = :abi_ndg order by createddate desc];

            String contactsJson = JSON.serialize(contactList);
            res.responseBody = Blob.valueOf(contactsJson);
        }
        catch(Exception ex)
        {
            System.debug(ex);
        }
    }
}