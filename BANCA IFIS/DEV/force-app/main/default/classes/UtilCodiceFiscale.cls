public class UtilCodiceFiscale {

	//A.M.
	public static final Boolean CONTROLLOCODICEFISCALE = Funzionalita__c.getInstance().ControlloCodiceFiscale__c;

	private Set<String> consonants = new Set<String> {
		'B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z'
	};
	private Set<String> vowels = new Set<String> { 'A', 'E', 'I', 'O', 'U' };

	private Map<Integer, String> months = new Map<Integer, String> {
		1 => 'A', 2 => 'B', 3 => 'C', 4 => 'D', 5 => 'E',
		6 => 'H', 7 => 'L', 8 => 'M', 9 => 'P', 10 => 'R',
		11 => 'S', 12 => 'T'
	};

	private Map<String, Integer> inverseMonths = new Map<String, Integer> {
		'A' => 1, 'B' => 2, 'C' => 3, 'D' => 4, 'E' => 5,
		'H' => 6, 'L' => 7, 'M' => 8, 'P' => 9, 'R' => 10,
		'S' => 11, 'T' => 12
	};

	private Map<String, Integer> evenValues = new Map<String, Integer> {
		'A' => 0, 'B' => 1, 'C' => 2, 'D' => 3, 'E' => 4, 'F' => 5,
		'G' => 6, 'H' => 7, 'I' => 8, 'J' => 9, 'K' => 10, 'L' => 11,
		'M' => 12, 'N' => 13, 'O' => 14, 'P' => 15, 'Q' => 16, 'R' => 17,
		'S' => 18, 'T' => 19, 'U' => 20, 'V' => 21, 'W' => 22, 'X' => 23,
		'Y' => 24, 'Z' => 25, '0' => 0, '1' => 1, '2' => 2, '3' => 3,
		'4' => 4, '5' => 5, '6' => 6, '7' => 7, '8' => 8, '9' => 9
	};

	private Map<String, Integer> oddValues = new Map<String, Integer> {
		'A' => 1, 'B' => 0, 'C' => 5, 'D' => 7, 'E' => 9, 'F' => 13,
		'G' => 15, 'H' => 17, 'I' => 19, 'J' => 21, 'K' => 2, 'L' => 4,
		'M' => 18, 'N' => 20, 'O' => 11, 'P' => 3, 'Q' => 6, 'R' => 8,
		'S' => 12, 'T' => 14, 'U' => 16, 'V' => 10, 'W' => 22, 'X' => 25,
		'Y' => 24, 'Z' => 23, '0' => 1, '1' => 0, '2' => 5, '3' => 7,
		'4' => 9, '5' => 13, '6' => 15, '7' => 17, '8' => 19, '9' => 21
	};

	private Map<Integer, String> controlValues = new Map<Integer, String> {
		0 => 'A', 1 => 'B', 2 => 'C', 3 => 'D',
		4 => 'E', 5 => 'F', 6 => 'G', 7 => 'H',
		8 => 'I', 9 => 'J', 10 => 'K', 11 => 'L',
		12 => 'M', 13 => 'N', 14 => 'O', 15 => 'P',
		16 => 'Q', 17 => 'R', 18 => 'S', 19 => 'T',
		20 => 'U', 21 => 'V', 22 => 'W', 23 => 'X',
		24 => 'Y', 25 => 'Z'
	};

	private Map<String, String> omocodiaValues = new Map<String, String> {
		'0' => 'L', '1' => 'M', '2' => 'N', '3' => 'P',
		'4' => 'Q', '5' => 'R', '6' => 'S', '7' => 'T',
		'8' => 'U', '9' => 'V'
	};


	/*
	  Calcola il codice fiscale partendo da cognome,nome,data di nascita,sesso e codice catastale
	 */
	public String calculateCodiceFiscale(String lastName, String firstName, Date birthDate, String gender, String codiceCatastale) {
		String cf = calculateCognome(lastName) + calculateNome(firstName) +
		getYear(birthDate) + getMonth(birthDate) + getDay(birthDate, gender) +
		codiceCatastale;
		cf += calculateControllo(cf);
		return cf;
	}

	/*
	  Metodo che controlla se cfNoCalc (non calcolato) può essere una trasformazione di cfCalc (calcolato) per omocodia.
	  Due diverse persone potrebbero avere uguali tutte e sedici le lettere/cifre generate usando questo schema (omocodia).
	  In questo caso, l'Agenzia delle entrate provvede a sostituire sistematicamente i soli caratteri numerici
	  (a partire dal carattere numerico più a destra) con una lettera, secondo la mappa omocodiaValues.
	 */
	public Boolean checkOmocodia(String cfNoCalc, String cfCalc) {
		String lCfNoCalc = cfNoCalc.toUpperCase(UserInfo.getLocale());

		if (lCfNoCalc.length() != cfCalc.length()) {
			return false;
		}

		if (calculateControllo(lCfNoCalc.substring(0, lCfNoCalc.length() - 1)) != getChar(lCfNoCalc, lCfNoCalc.length() - 1)) {
			return false;
		}

		for (Integer i = 0; i<cfCalc.length() - 1; i++) {
			if (!(
			      getChar(lCfNoCalc, i) == getChar(cfCalc, i) ||
			(omocodiaValues.keySet().contains(getChar(cfCalc, i)) && getChar(lCfNoCalc, i) == omocodiaValues.get(getChar(cfCalc, i)))
			)) {
				return false;
			}
		}

		return true;
	}

	/*
	  Nome (tre lettere)
	  Vengono prese le consonanti del nome (o dei nomi, se ve ne è più di uno) nel loro ordine (primo nome, di seguito il secondo e così via)
	  in questo modo: se il nome contiene quattro o più consonanti, si scelgono la prima, la terza e la quarta, altrimenti le prime tre in ordine.
	  Se il nome non ha consonanti a sufficienza, si prendono anche le vocali; in ogni caso le vocali vengono riportate dopo le consonanti.
	  Nel caso in cui il nome abbia meno di tre lettere la parte di codice viene completata aggiungendo la lettera X
	 */
	public String calculateNome(String firstName) {
		String lFirstName = this.normalizeText(firstName);
		String result = '';

		String[] consontansFirstName = new String[] { };
		String[] vowelsFirstName = new String[] { };

		//count consonants amd vowels
		for (Integer i = 0; i<lFirstName.length(); i++) {
			if (consonants.contains(getChar(lFirstName, i))) {
				consontansFirstName.add(getChar(lFirstName, i));
			} else {
				vowelsFirstName.add(getChar(lFirstName, i));
			}
		}

		if (consontansFirstName.size() >= 4) {
			result = consontansFirstName[0] + consontansFirstName[2] + consontansFirstName[3];
		} else if (consontansFirstName.size() == 3) {
			result = consontansFirstName[0] + consontansFirstName[1] + consontansFirstName[2];
		} else {
			String[] joinChars = new String[] { };
			joinChars.addAll(consontansFirstName);
			joinChars.addAll(vowelsFirstName);
			joinChars.addAll(new String[] { 'X', 'X', 'X' });
			result = joinChars[0] + joinChars[1] + joinChars[2];
		}

		return result;
	}

	/*
	  Cognome (tre lettere)
	  Vengono prese le consonanti del cognome (o dei cognomi, se ve ne è più di uno) nel loro ordine (primo cognome, di seguito il secondo e così via).
	  Se le consonanti sono insufficienti, si prelevano anche le vocali, sempre nel loro ordine e, comunque, le vocali vengono riportate
	  dopo le consonanti. Nel caso in cui un cognome abbia meno di tre lettere, la parte di codice viene completata aggiungendo la lettera X
	  (per esempio: Fo → FOX). Per le donne, viene preso in considerazione il solo cognome da nubile.
	 */
	public String calculateCognome(String lastName) {
		String lLastName = this.normalizeText(lastName);
		String result = '';


		String[] consontansLastName = new String[] { };
		String[] vowelsLastName = new String[] { };

		//count consonants amd vowels
		for (Integer i = 0; i<lLastName.length(); i++) {
			if (consonants.contains(getChar(lLastName, i))) {
				consontansLastName.add(getChar(lLastName, i));
			} else {
				vowelsLastName.add(getChar(lLastName, i));
			}
		}

		String[] joinChars = new String[] { };
		joinChars.addAll(consontansLastName);
		joinChars.addAll(vowelsLastName);
		joinChars.addAll(new String[] { 'X', 'X', 'X' });
		result = joinChars[0] + joinChars[1] + joinChars[2];

		return result;
	}

	/*
	  Anno di nascita (due cifre): si prendono le ultime due cifre dell'anno di nascita;
	 */
	public String getYear(Date data) {
		String result = String.valueOf(data.year());
		return result.substring(2, 4);
	}

	/*
	  Mese di nascita (una lettera): a ogni mese dell'anno viene associata una lettera in base alla mappa "months"
	 */
	public String getMonth(Date data) {
		return months.get(data.month());
	}

	/*
	  Giorno di nascita e sesso (due cifre): si prendono le due cifre del giorno di nascita
	  (se è compreso tra 1 e 9 si pone uno zero come prima cifra); per i soggetti di sesso femminile, a tale cifra va sommato il numero 40.
	  In questo modo il campo contiene la doppia informazione giorno di nascita e sesso.
	 */
	public String getDay(Date data, String gender) {
		Integer result = data.day();
		if (gender == 'F')
		result += 40;
		String textResult = String.valueOf(result);
		if (textResult.length() < 2)
		textResult = '0' + textResult;
		return textResult;
	}

	/*
	  A partire dai quindici caratteri alfanumerici ricavati in precedenza, si determina il carattere di controllo in base a un particolare algoritmo che opera in questo modo:
	  - si mettono da una parte i caratteri alfanumerici che si trovano in posizione dispari (il primo, il terzo eccetera) e da un'altra quelli
	  che si trovano in posizione pari (il secondo, il quarto eccetera);
	  - fatto questo, i caratteri vengono convertiti in valori numerici secondo le mappe evenValues e oddValues
	  - a questo punto, i valori che si ottengono dai caratteri alfanumerici pari e dispari vanno sommati tra di loro e il risultato va diviso per 26;
	  il resto della divisione fornirà il codice identificativo, ottenuto dalla mappa controlValues
	 */
	public String calculateControllo(String val) {
		String value = val.toUpperCase(UserInfo.getLocale());
		Integer sum = 0;
		String result = '';
		String currentChar;
		for (Integer i = 0; i<value.length(); i++) {
			currentChar = getChar(value, i);
			if ((Math.mod(i, 2)) == 0) {
				sum += oddValues.get(currentChar);
			} else {
				sum += evenValues.get(currentChar);
			}
		}
		Integer controlInt = Math.mod(sum, 26);
		result = controlValues.get(controlInt);
		return result;
	}

	private String getChar(String s, Integer i) {
		return s.substring(i, i + 1);
	}

	/*
	  return a string without blank space and uppercase
	 */
	private String normalizeText(String text) {
		return text.toUpperCase(UserInfo.getLocale()).replaceAll('[^A-Z]', '');
	}

	public class ContactInfo {
		public String firstName;
		public String lastName;
		public Date birthDate;
		public String sesso;
		public String codiceCatastale;
	}

	public ContactInfo reverseCodiceFiscale(String cf, String firstName, String lastName) {
		return reverseCodiceFiscale(cf, firstName + ' ' + lastName);
	}

	public ContactInfo reverseCodiceFiscale(String cf, String fullname) {
		String cognomeCf = cf.substring(0, 3);
		String nomeCf = cf.substring(3, 6);
		Integer annoNascitaCf = Integer.valueOf(cf.substring(6, 8));
		Integer meseDiNascitaCf = inverseMonths.get(cf.substring(8, 9));
		Integer giornoNascitaCf = Integer.valueOf(cf.substring(9, 11));

		if (Date.today().year() - 1900 - annoNascitaCf> 90) {
			annoNascitaCf = 2000 + annoNascitaCf;
		} else {
			annoNascitaCf = 1900 + annoNascitaCf;
		}

		ContactInfo res = new ContactInfo();
		res.birthDate = Date.newInstance(annoNascitaCf, meseDiNascitaCf, giornoNascitaCf> 40 ? giornoNascitaCf - 40 : giornoNascitaCf);
		res.sesso = giornoNascitaCf - 40> 0 ? 'F' : 'M';
		res.codiceCatastale = cf.substring(11, 15);

		try {
			// ricerco ora, tramite il codice fiscale, il nome e il cognome della persona fisica nel nome dell'account
			//System.debug('fullName: ' + fullName);
			fullName = fullName.normalizeSpace().trim();
			//System.debug('fullName normalizeSpace: ' + fullName);
			String[] nameTokens = fullName.split(' ');
			//System.debug('nameTokens: ' + nameTokens);
			if (nameTokens.size() <= 1) return res;
			String parte1, parte2;
			String daEscludere = fullName.subString(0, fullName.length() - nameTokens[nameTokens.size() - 1].length() - 1);
			//System.debug('daEscludere1: ' + daEscludere);
			Boolean trovato = false;
			if (nameTokens.size() == 2) {
				parte1 = nameTokens[0];
				//System.debug('parte1: ' + parte1);
				parte2 = nameTokens[1];
				//System.debug('parte2: ' + parte2);
				if (calculateCognome(parte2) == cognomeCf && calculateNome(parte1) == nomeCf) {
					//System.debug('parte2: ' + parte2);
					// trovato: prima nome e poi cognome
					res.firstName = parte1;
					res.lastName = parte2;
				} else if (calculateCognome(parte1) == cognomeCf && calculateNome(parte2) == nomeCf) {
					//System.debug('parte2: ' + parte2);
					// trovato: prima cognome e poi nome
					res.firstName = parte2;
					res.lastName = parte1;
				}
				return res;
			}
			// inizio considerando solo le ultime due parole della stringa, a ogni step ne aggiungerò una.
			for (Integer j = nameTokens.size() - 2; j> 0; j--) {
				daEscludere = daEscludere.subString(0, daEscludere.length() - nameTokens[j].length() - 1);
				//System.debug('daEscludere2: ' + daEscludere);
				parte1 = nameTokens[j];
				//System.debug('parte1: ' + parte1);
				parte2 = fullName.substring(daEscludere.length() + 1 + parte1.length() + 1);
				//System.debug('parte2: ' + parte2);
				for (Integer i = j + 1; i<nameTokens.size(); i++) {
					if (calculateCognome(parte2) == cognomeCf && calculateNome(parte1) == nomeCf) {
						//System.debug('parte2: ' + parte2);
						// trovato: prima nome e poi cognome
						res.firstName = parte1;
						res.lastName = parte2;
						trovato = true;
					} else if (calculateCognome(parte1) == cognomeCf && calculateNome(parte2) == nomeCf) {
						//System.debug('parte2: ' + parte2);
						// trovato: prima cognome e poi nome
						res.firstName = parte2;
						res.lastName = parte1;
						trovato = true;
					} else {
						// allungo parte1 di una parola, togliendola da parte2
						parte1 += ' ' + nameTokens[i];
						parte2 = fullname.replaceFirst(parte1, '').trim();
						//System.debug('allungo: parte1:' + parte1 + '-parte2: ' + parte2);
						if (calculateCognome(parte2) == cognomeCf && calculateNome(parte1) == nomeCf) {
							//System.debug('parte2: ' + parte2);
							// trovato: prima nome e poi cognome
							res.firstName = parte1;
							res.lastName = parte2;
							trovato = true;
						} else if (calculateCognome(parte1) == cognomeCf && calculateNome(parte2) == nomeCf) {
							//System.debug('parte2: ' + parte2);
							// trovato: prima cognome e poi nome
							res.firstName = parte2;
							res.lastName = parte1;
							trovato = true;
						}
					}
				}
				if (trovato) break;
			}
			//// inizio considerando solo le prime due parole della stringa, a ogni step ne aggiungerò una.
			daEscludere = fullName.subString(nameTokens[nameTokens.size() - 2].length() - 1, fullName.length());
			//System.debug('daEscludere3: ' + daEscludere);
			for (Integer j = nameTokens.size() - 2; j> 0; j--) {
				daEscludere = daEscludere.subString(nameTokens[j].length() + 1, daEscludere.length());
				//System.debug('daEscludere4: ' + daEscludere);
				parte1 = nameTokens[j - 1];
				//System.debug('parte1: ' + parte1);
				parte2 = fullName.substring(parte1.length() + 1, fullName.length() - daEscludere.length() - 1);
				//System.debug('parte2: ' + parte2);
				for (Integer i = j + 1; i<nameTokens.size(); i++) {
					if (calculateCognome(parte2) == cognomeCf && calculateNome(parte1) == nomeCf) {
						//System.debug('parte2: ' + parte2);
						// trovato: prima nome e poi cognome
						res.firstName = parte1;
						res.lastName = parte2;
						trovato = true;
					} else if (calculateCognome(parte1) == cognomeCf && calculateNome(parte2) == nomeCf) {
						//System.debug('parte2: ' + parte2);
						// trovato: prima cognome e poi nome
						res.firstName = parte2;
						res.lastName = parte1;
						trovato = true;
					} else {
						// allungo parte1 di una parola, togliendola da parte2
						parte1 += ' ' + nameTokens[i - 1];
						parte2 = fullname.replaceFirst(parte1, '').trim();
						//System.debug('allungo: parte1:' + parte1 + '-parte2: ' + parte2);
						if (calculateCognome(parte2) == cognomeCf && calculateNome(parte1) == nomeCf) {
							//System.debug('parte2: ' + parte2);
							// trovato: prima nome e poi cognome
							res.firstName = parte1;
							res.lastName = parte2;
							trovato = true;
						} else if (calculateCognome(parte1) == cognomeCf && calculateNome(parte2) == nomeCf) {
							//System.debug('parte2: ' + parte2);
							// trovato: prima cognome e poi nome
							res.firstName = parte2;
							res.lastName = parte1;
							trovato = true;
						}
					}
				}
				if (trovato) break;
			}
		} catch(Exception e){
			return res;
		}
		return res;
	}

	/**
	 * A.M. - Metodo che controlla la coerenza tra cf, nome, cognome, data di nascita, sesso e località di nascita
	 **/
	public Boolean checkCF(String CF, Contact c) {
		Boolean checkCf = true;
		String cfCalc;
		if (!CONTROLLOCODICEFISCALE) return checkCf;

		c.CF__c = CF;

		if (String.isBlank(c.FirstName)) {
			c.FirstName.addError('Nome obbligatorio se presente il codice fiscale');
			checkCf = false;
		}
		if (c.Birthdate == null) {
			c.Birthdate.addError('Data di nascita obbligatoria se presente il codice fiscale');
			checkCf = false;
		}
		if (String.isBlank(c.Sesso__c)) {
			c.Sesso__c.addError('Sesso obbligatorio se presente il codice fiscale');
			checkCf = false;
		}
		if (String.isBlank(c.CodCatastaleLocNascita__c)) {
			c.LuogoNascita__c.addError('Località di nascita obbligatoria se presente il codice fiscale');
			checkCf = false;
		}

		if (checkCf) {
			cfCalc = calculateCodiceFiscale(
			                                c.LastName,
			                                c.FirstName,
			                                c.BirthDate,
			                                c.Sesso__c,
			                                c.CodCatastaleLocNascita__c
			);

			if (!checkOmocodia(c.CF__c, cfCalc)) {
				c.CF__c.addError('Codice fiscale invalido o non coerente con i dati anagrafici');
				checkCf = false;
			}
		}

		return checkCf;
	}
}