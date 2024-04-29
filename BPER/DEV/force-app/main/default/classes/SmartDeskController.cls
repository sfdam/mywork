public with sharing class SmartDeskController {
    @AuraEnabled
    public static Id getAccountId(Id caseId) {
        return [SELECT Id, AccountId FROM Case WHERE Id = :caseId].AccountId;
    }
    
    @AuraEnabled
    public static String getTestResponse()
    {
        return '{"offset":0,"pagedResults":4,"totalResults":4,"list":[{"id":"14150","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customId":"Testrichi2302","customType":"Testrichi2302","customCategoryList":[{"id":"181","customCategory":"Multicanale"}],"channel":{"id":"1","channelCode":"OAD","descrizione":"OffertaaDistanza","enabled":true},"dataCreazione":"2024-02-23T14:35:04.12Z","status":{"codice":"ENABLED","descrizione":"Attiva"},"boxDocumentList":[{"boxId":"14150","id":"17558","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customTitle":"RichiestaBebop","boxDocumentStatusNdg":[{"status":{"codice":"DOCUMENT_TO_UPLOAD","descrizione":"Dacaricare","enabled":true,"boxDocumentTypeCode":"DOCUMENT_TO_UPLOAD"},"ndg":{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"},"requiredAction":true}],"boxDocumentType":{"id":"DOCUMENT_TO_UPLOAD","descrizione":"UploadDocumento","enabled":true},"dataCreazione":"2024-02-23T14:36:34.265Z","dataScadenza":"2024-09-05T14:44:20.574Z","hiddenToCustomer":false,"applicationId":"3","applicationUserId":"181","documentAmount":1}],"hiddenToCustomer":false,"applicationId":"1","applicationUserId":"1"},{"id":"13844","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customId":"TestFrancesconew","customType":"TestFrancesconew","customCategoryList":[{"id":"181","customCategory":"Multicanale"}],"channel":{"id":"1","channelCode":"OAD","descrizione":"OffertaaDistanza","enabled":true},"dataCreazione":"2024-02-13T13:47:27.015Z","status":{"codice":"ENABLED","descrizione":"Attiva"},"boxDocumentList":[{"boxId":"13844","id":"16988","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customTitle":"RichiestaBebop","boxDocumentStatusNdg":[{"status":{"codice":"DOCUMENT_UPLOADED","descrizione":"Caricato","enabled":true,"boxDocumentTypeCode":"DOCUMENT_TO_UPLOAD"},"ndg":{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"},"updated":"2024-02-20T10:04:09.507Z","requiredAction":false}],"boxDocumentType":{"id":"DOCUMENT_TO_UPLOAD","descrizione":"UploadDocumento","enabled":true},"dataCreazione":"2024-02-13T13:47:53.926Z","dataScadenza":"2024-09-05T14:44:20.574Z","hiddenToCustomer":false,"applicationId":"3","applicationUserId":"181","documentAmount":1},{"boxId":"13844","id":"17156","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customTitle":"RichiestaBebop","boxDocumentStatusNdg":[{"status":{"codice":"DOCUMENT_TO_UPLOAD","descrizione":"Dacaricare","enabled":true,"boxDocumentTypeCode":"DOCUMENT_TO_UPLOAD"},"ndg":{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"},"updated":"2024-03-01T08:59:38.116658Z","requiredAction":true}],"boxDocumentType":{"id":"DOCUMENT_TO_UPLOAD","descrizione":"UploadDocumento","enabled":true},"dataCreazione":"2024-02-15T08:58:42.293Z","dataScadenza":"2024-09-05T14:44:20.574Z","hiddenToCustomer":false,"applicationId":"3","applicationUserId":"181","documentAmount":0},{"boxId":"13844","id":"17157","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customId":"#123-456-2","customTitle":"Prospettoinformativo","boxDocumentStatusNdg":[{"status":{"codice":"DOCUMENT_READ","descrizione":"Visto","enabled":true,"boxDocumentTypeCode":"DOCUMENT_TO_READ"},"ndg":{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"},"updated":"2024-02-15T09:03:02.101724Z","requiredAction":false}],"boxDocumentType":{"id":"DOCUMENT_TO_READ","descrizione":"ConsultazioneDocumento","enabled":true},"dataCreazione":"2024-02-15T09:02:33.491Z","hiddenToCustomer":false,"applicationId":"1","applicationUserId":"1","documentAmount":1}],"hiddenToCustomer":false,"applicationId":"1","applicationUserId":"1"},{"id":"13822","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customId":"TestFrancesco13/02","customType":"TESTFrancesco13/02","customCategoryList":[{"id":"181","customCategory":"Multicanale"}],"channel":{"id":"1","channelCode":"OAD","descrizione":"OffertaaDistanza","enabled":true},"dataCreazione":"2024-02-13T11:12:18.56Z","status":{"codice":"ENABLED","descrizione":"Attiva"},"boxDocumentList":[{"boxId":"13822","id":"16975","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customTitle":"RichiestaBebop","boxDocumentStatusNdg":[{"status":{"codice":"DOCUMENT_TO_UPLOAD","descrizione":"Dacaricare","enabled":true,"boxDocumentTypeCode":"DOCUMENT_TO_UPLOAD"},"ndg":{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"},"updated":"2024-02-28T13:40:52.765714Z","requiredAction":true}],"boxDocumentType":{"id":"DOCUMENT_TO_UPLOAD","descrizione":"UploadDocumento","enabled":true},"dataCreazione":"2024-02-13T11:12:48.699Z","dataScadenza":"2024-09-05T14:44:20.574Z","hiddenToCustomer":false,"applicationId":"3","applicationUserId":"181","documentAmount":0},{"boxId":"13822","id":"17012","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customTitle":"RichiestaBebop","boxDocumentStatusNdg":[{"status":{"codice":"DOCUMENT_TO_UPLOAD","descrizione":"Dacaricare","enabled":true,"boxDocumentTypeCode":"DOCUMENT_TO_UPLOAD"},"ndg":{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"},"updated":"2024-02-28T11:47:18.148591Z","requiredAction":true}],"boxDocumentType":{"id":"DOCUMENT_TO_UPLOAD","descrizione":"UploadDocumento","enabled":true},"dataCreazione":"2024-02-13T11:46:46.998Z","dataScadenza":"2024-09-05T14:44:20.574Z","hiddenToCustomer":false,"applicationId":"3","applicationUserId":"181","documentAmount":0},{"boxId":"13822","id":"17013","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customTitle":"RichiestaBebop","boxDocumentStatusNdg":[{"status":{"codice":"DOCUMENT_UPLOADED","descrizione":"Caricato","enabled":true,"boxDocumentTypeCode":"DOCUMENT_TO_UPLOAD"},"ndg":{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"},"updated":"2024-02-20T09:30:39.039Z","requiredAction":false}],"boxDocumentType":{"id":"DOCUMENT_TO_UPLOAD","descrizione":"UploadDocumento","enabled":true},"dataCreazione":"2024-02-13T11:55:08.499Z","dataScadenza":"2024-09-05T14:44:20.574Z","hiddenToCustomer":false,"applicationId":"3","applicationUserId":"181","documentAmount":1},{"boxId":"13822","id":"16987","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customTitle":"RichiestaBebop","boxDocumentStatusNdg":[{"status":{"codice":"DOCUMENT_UPLOADED","descrizione":"Caricato","enabled":true,"boxDocumentTypeCode":"DOCUMENT_TO_UPLOAD"},"ndg":{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"},"updated":"2024-02-20T09:45:26.247Z","requiredAction":false}],"boxDocumentType":{"id":"DOCUMENT_TO_UPLOAD","descrizione":"UploadDocumento","enabled":true},"dataCreazione":"2024-02-13T13:42:33.989Z","dataScadenza":"2024-09-05T14:44:20.574Z","hiddenToCustomer":false,"applicationId":"3","applicationUserId":"181","documentAmount":2}],"hiddenToCustomer":false,"applicationId":"1","applicationUserId":"1"},{"id":"9326","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customId":"TestManinderupdate","customType":"Vendita","customCategoryList":[{"id":"21","customCategory":"Multicanale","customCategoryDescription":"SmartWebInfo","customOperationName":"Attivazioneutenza"}],"customStatus":"Inapertura","channel":{"id":"1","channelCode":"OAD","descrizione":"OffertaaDistanza","enabled":true},"dataCreazione":"2023-09-15T16:03:18.927Z","status":{"codice":"ENABLED","descrizione":"Attiva"},"boxDocumentList":[{"boxId":"9326","id":"10672","ndg":[{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"}],"customId":"TestManinder","customTitle":"Informativaprivacy","boxDocumentStatusNdg":[{"status":{"codice":"DOCUMENT_TO_UPLOAD","descrizione":"Dacaricare","enabled":true,"boxDocumentTypeCode":"DOCUMENT_TO_UPLOAD"},"ndg":{"abi":"05387","ndg":"501433","nome":"Xubjo","cognome":"Zava","ndgType":"PF_MONO"},"updated":"2024-02-28T11:25:47.493901Z","requiredAction":true}],"boxDocumentType":{"id":"DOCUMENT_TO_UPLOAD","descrizione":"UploadDocumento","enabled":true},"dataCreazione":"2023-09-15T16:04:01.649Z","hiddenToCustomer":false,"applicationId":"1","applicationUserId":"1","documentAmount":0}],"hiddenToCustomer":false,"applicationId":"1","applicationUserId":"1"}]}';
    }
}