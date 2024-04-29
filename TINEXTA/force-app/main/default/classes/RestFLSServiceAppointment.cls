@RestResource(urlMapping='/v1.0/InserimentoServiceAppointment')
global without sharing class RestFLSServiceAppointment 
{
    @HttpPost
    global static ResponseWrapper doPost() 
    {
        ObjectResponseWrapper response = new ObjectResponseWrapper();
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        Boolean success = true;
        String msg = '';
        Integer statusCode = null;
        //String response = res;
        String jsonString = String.valueOf(req.requestBody.toString());
        string idRecordLog = '';

        map<string, Object> respMap = new map<string, object>();
        List<ServiceAppointment> servInsert = new List<ServiceAppointment>();
        List<ServiceAppointment> servUpdate = new List<ServiceAppointment>();
        List<ServiceAppointment> servUpsert = new List<ServiceAppointment>();

        try
        {
            system.debug(res);
            Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());

            List<Map<String, Object>> test = new List<Map<String, Object>>();

            serviceappointment serviceApp = (serviceappointment) JSON.deserializeStrict(JSON.serialize(body.get('ServiceAppointment'), true), serviceappointment.Class);
            system.debug('body ' + body);
            system.debug('serviceApp ' + serviceApp);
            if(serviceApp != null)
            {
                if(serviceApp.id != null && String.valueOf(serviceApp.id) != '')
                {
                    update serviceApp;
                }
                if(serviceApp.id == null || String.valueOf(serviceApp.id) == '')
                {
                    insert serviceApp;
                    //serviceApp.put('Id', serviceApp.id);
                }
                response.data = new Map<String,Object>{
                    'ServiceAppointment' => serviceApp
                };
                idRecordLog = serviceApp.id;
            }
            else if (serviceApp == null)
            {
                success = false;throw new CalloutException('ERRORE - Nessun Service Appointment'); 
            } 
        }
        catch (CalloutException e) 
        {
            response.message = e.getMessage();response.success = false;success = false;
            System.debug(
                '@@@ error ' +
                e.getMessage() +
                ' - ' +
                e.getLineNumber()
            );
        } catch (Exception e) 
        {
            response.message =e.getMessage() + ' -- ' +e.getStackTraceString();response.success = false;success = false;
            System.debug(
                '@@@ error exc ' +
                e.getMessage() +
                ' - ' +
                e.getLineNumber()+
                ' '+e
            );
        }

        insert new Log__c(
            Success__c = success,
            Societa__c = 'WarrantHub',
            Source__c = 'IntegrazioneHDR',
            Nome_Classe__c = 'RestFLSServiceAppointment',
            ID_Record__c = idRecordLog,
            ErrorMessage__c = String.valueOf(response.message),
            InputPayload__c = jsonString,
            OutputPayload__c = String.valueOf(JSON.serializePretty(response,true))
        );

        return response;
    }
}