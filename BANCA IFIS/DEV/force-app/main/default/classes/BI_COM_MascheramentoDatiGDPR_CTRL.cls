/**
  * Progetto:         Mascheramento dati per specifiche GDPR
  * Sviluppatore      Marco Bonin <marco.bonin@bancaifis.it>
  * Descrizione:      Una parte di frontend legge un file CSV con chiave NDG.
  *					  Per ogni NDG viene verificato se è PG o PF e viene fatto l'update dei dati
  *                   in base a quelli presenti nel tracciato che sono "mascherati" a monte
  *					  da Cedacri.
*/

public class BI_COM_MascheramentoDatiGDPR_CTRL  {

	@AuraEnabled
	public static Boolean isProdOrg () {

		Organization org = [SELECT Id, InstanceName, IsSandbox, Name, OrganizationType FROM Organization];

		return !org.IsSandbox;

	}

	@AuraEnabled
	public static String importGDPRCSVRecord (String jsonRECORD) {

		// CHIAMATO PER RIGA DI IMPORT IN MODO DA CAMBIARE I DATI RELATIVI ALL' NDG (PG OD PF)

		fieldWrapper actualRecord = (fieldWrapper) JSON.deserialize(jsonRECORD, fieldWrapper.class);

		resultWrapper rw = new resultWrapper();

		try {

			// VERIFICA DELLO STATO DELL'NDG
			// PUO' ESSERE PRESENTE O NON PRESENTE
			// PUO' ESSERE PG O PF

			List<Account> searchAccount = [SELECT id FROM Account WHERE NDGGruppo__c = : actualRecord.NDG];

			if(searchAccount.size() == 0){

					List<Contact> searchContact = [SELECT id, FirstName, LastName, CF__c FROM Contact WHERE NDGGruppo__c = : actualRecord.NDG];

					if(searchContact.size() == 0){

						// NON TROVATO NE IN ACCOUNT NE IN CONTATTI
				
						rw.TIPO_ENTITA = '';
						rw.ESITO = 'N';

						return JSON.serialize(rw);
				
					}
		
					else{

						// AGGIORNAMENTO DEI DATI DEL CONTATTO

						Contact candidateContact = searchContact.get(0);

						candidateContact.FirstName = actualRecord.NOME;
						candidateContact.LastName = actualRecord.COGNOME;

						// OBBLIGATORIO DOPO L'INSERIMENTO DEL CF INSERIRE DATA NASCITA, SESSO, LUOGO NASCITA COERENTI

						candidateContact.CF__c = actualRecord.CF;

						UtilCodiceFiscale utilCf = new UtilCodiceFiscale();
					
						UtilCodiceFiscale.ContactInfo contactInfo = utilCf.reverseCodiceFiscale(actualRecord.CF, actualRecord.NOME, actualRecord.COGNOME);

						candidateContact.Birthdate = contactInfo.birthDate;

						candidateContact.Sesso__c = contactInfo.sesso;

						candidateContact.CodCatastaleLocNascita__c = contactInfo.codiceCatastale;

						Comune__c actualComune = [SELECT Id, Name, Provincia__c FROM Comune__c WHERE CodiceCatastale__c = :contactInfo.codiceCatastale];

						candidateContact.LuogoNascita__c = actualComune.Name;

						candidateContact.ProvinciaNascita__c = actualComune.Provincia__c;

						// CONTATTI TELEFONICI ED ALTRE FORME DI CONTATTO

						candidateContact.Phone = actualRecord.TELEFONO;

						candidateContact.MobilePhone = actualRecord.CELLULARE;

						candidateContact.Email = actualRecord.EMAIL;

						candidateContact.Fax = actualRecord.FAX;

						// INDIRIZZI

						candidateContact.MailingStreetType__c = actualRecord.RESIDENZA_TIPOVIA;

						candidateContact.MailingStreetName__c = actualRecord.RESIDENZA_NOME;

						candidateContact.MailingStreetNumber__c = actualRecord.RESIDENZA_NUMERO;

						candidateContact.MailingCity__c = actualRecord.RESIDENZA_LOCALITA;

						candidateContact.MailingPostalCode__c = actualRecord.RESIDENZA_CAP;

						candidateContact.MailingCity__c = actualRecord.RESIDENZA_COMUNE;

						candidateContact.MailingState__c = actualRecord.RESIDENZA_PROVINCIA;

						update candidateContact;

						rw.TIPO_ENTITA = 'PF';
						rw.ESITO = 'U';

						return JSON.serialize(rw);

					}
		
			}

			else {
		
				// AGGIORNAMENTO DEI DATI DELL'AZIENDA

				Account candidateAccount = searchAccount.get(0);

				candidateAccount.Name = actualRecord.ATTIVITA;
				candidateAccount.RagioneSociale__c = actualRecord.ATTIVITA;

				candidateAccount.PIVA__c = actualRecord.PARTITAIVA;

				// CONTATTI TELEFONICI ED ALTRE FORME DI CONTATTO

				candidateAccount.TelefonoPrefisso__c = actualRecord.TELEFONO_PREFISSO;

				candidateAccount.TelefonoNumero__c = actualRecord.TELEFONO_NUMERO;

				candidateAccount.Email__c = actualRecord.EMAIL;

				candidateAccount.Fax = actualRecord.FAX;

				// INDIRIZZI

				candidateAccount.BillingStreetType__c = actualRecord.RESIDENZA_TIPOVIA;

				candidateAccount.BillingStreetName__c = actualRecord.RESIDENZA_NOME;

				candidateAccount.BillingStreetNumber__c = actualRecord.RESIDENZA_NUMERO;

				candidateAccount.BillingCity__c = actualRecord.RESIDENZA_LOCALITA;

				candidateAccount.BillingPostalCode__c = actualRecord.RESIDENZA_CAP;

				candidateAccount.BillingCity__c = actualRecord.RESIDENZA_COMUNE;

				candidateAccount.BillingState__c = actualRecord.RESIDENZA_PROVINCIA;

				candidateAccount.ShippingStreetType__c = actualRecord.DOMICILIO_TIPOVIA;

				candidateAccount.ShippingStreetName__c = actualRecord.DOMICILIO_NOME;

				candidateAccount.ShippingStreetNumber__c = actualRecord.DOMICILIO_NUMERO;

				candidateAccount.ShippingCity__c = actualRecord.DOMICILIO_LOCALITA;

				candidateAccount.ShippingPostalCode__c = actualRecord.DOMICILIO_CAP;

				candidateAccount.ShippingCity__c = actualRecord.DOMICILIO_COMUNE;

				candidateAccount.ShippingState__c = actualRecord.DOMICILIO_PROVINCIA;

				candidateAccount.CabComune__c = actualRecord.CAB_COMUNE;

				update candidateAccount;

				rw.TIPO_ENTITA = 'PG';
				rw.ESITO = 'U';

				return JSON.serialize(rw);

			}
		
		}

		catch(Exception ex){
			
			System.debug('ERRORE riscontrato: ' + ex);

			rw.TIPO_ENTITA = '';
			rw.ESITO = 'E';

			return JSON.serialize(rw);

		}


	}

    public class fieldWrapper {

		// RAPPRESENTA IL TRACCIATO RECORD DEL FILE IN ARRIVO DA CEDACRI

		public String NDG;
        
		public String COGNOME;

		public String NOME;

		public String ATTIVITA;

		public String CF;

		public String PARTITAIVA;

		public String TELEFONO_PREFISSO;

		public String TELEFONO_NUMERO;

		public String TELEFONO;

		public String CELLULARE;

		public String EMAIL;

		public String FAX;

		public String RESIDENZA_TIPOVIA;

		public String RESIDENZA_NOME;

		public String RESIDENZA_NUMERO;

		public String RESIDENZA_LOCALITA;

		public String RESIDENZA_CAP;
		
		public String RESIDENZA_COMUNE;
		
		public String RESIDENZA_PROVINCIA;

		public String DOMICILIO_TIPOVIA;

		public String DOMICILIO_NOME;

		public String DOMICILIO_NUMERO;

		public String DOMICILIO_LOCALITA;

		public String DOMICILIO_CAP;
		
		public String DOMICILIO_COMUNE;
		
		public String DOMICILIO_PROVINCIA;

		public String CAB_COMUNE;

	} 

    public class resultWrapper {

		public String TIPO_ENTITA; // PG/PF
        
		public String ESITO; // U, D, E

	} 
}