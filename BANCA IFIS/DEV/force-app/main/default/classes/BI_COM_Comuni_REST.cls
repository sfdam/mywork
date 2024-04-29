/**
* Progetto:         Revisione componenti core per CRM 2.0.
* Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
* Descrizione:      Facade di esposizione dell'oggetto Comune__c
*
*/

@RestResource(urlMapping = '/comuni/*')
global with sharing class BI_COM_Comuni_REST  {

	private BI_COM_Comuni_REST() {}

	// RESTITUISCE UNA LISTA DI COMUNI CENSITI NELL'OGGETTO COMUNE__C

	@HttpGet
	global static List<Comune__c> getComuni(){
	

        String includiStorici = RestContext.request.params.get('includiStorici');
		String cap = RestContext.request.params.get('cap');

		Boolean parametro = true;

		if(String.isNotEmpty(includiStorici)){

			if(includiStorici.equalsIgnoreCase('false'))
				parametro = false;

		}

		return BI_COM_UtilitiesAnagrafiche_CODE.getComuni(parametro, cap);
	
	}

}