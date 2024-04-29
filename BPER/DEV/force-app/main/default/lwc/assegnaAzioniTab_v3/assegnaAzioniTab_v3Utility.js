const TABELLA_ELENCOCAMPAGNE = [
    { label: 'Bisogno', fieldName: 'bisogno',initialWidth: 200, sortable: "true" },
    { label: 'Tipologia', fieldName: 'tipologia',initialWidth: 150, sortable: "true" },
    { label: 'Nome Campagna', fieldName: 'nameUrl', type: 'url', typeAttributes: {label: { fieldName: 'nomeCampagna' }},initialWidth: 150},
    { label: 'Data Inizio', fieldName: 'startDate', type: "date-local",typeAttributes:{ month: "2-digit",day: "2-digit"}, hideDefaultActions: true,initialWidth: 100},
    { label: 'Data Fine', fieldName: 'endDate', type: "date-local",typeAttributes:{ month: "2-digit",day: "2-digit"}, hideDefaultActions: true,initialWidth: 100},
    { label: 'Priorità', fieldName: 'priorita' , hideDefaultActions: true},
    { label: 'Totale Contatti Da Assegnare', fieldName: 'totaleContatti', hideDefaultActions: true},
    { label: 'Family', fieldName: 'contattiMdsFamily' , hideDefaultActions: true},
    { label: 'POE', fieldName: 'contattiMdsPoe' , hideDefaultActions: true},
    { label: 'Non Portafogliati', fieldName: 'nonPortafogliati' , hideDefaultActions: true},
    { label: 'Residuale', fieldName: 'residuale' , hideDefaultActions: true},
    { label: 'Assente', fieldName: 'assente' , hideDefaultActions: true}
];

const TABELLA_ELENCOEVENTI = [
    { label: 'Bisogno', fieldName: 'bisogno',initialWidth: 200 },
    { label: 'Nome Evento', fieldName: 'nameUrl', type: 'url', typeAttributes: {label: { fieldName: 'nomeCampagna' }},initialWidth: 150},
    { label: 'Data Inizio', fieldName: 'startDate', type: "date-local",typeAttributes:{ month: "2-digit",day: "2-digit"}, hideDefaultActions: true,initialWidth: 100},
    { label: 'Data Fine', fieldName: 'endDate', type: "date-local",typeAttributes:{ month: "2-digit",day: "2-digit"}, hideDefaultActions: true,initialWidth: 100},
    { label: 'Priorità', fieldName: 'priorita' , hideDefaultActions: true},
    { label: 'Totale Contatti Da Assegnare', fieldName: 'totaleContatti', hideDefaultActions: true},
    { label: 'Family', fieldName: 'contattiMdsFamily' , hideDefaultActions: true},
    { label: 'POE', fieldName: 'contattiMdsPoe' , hideDefaultActions: true},
    { label: 'Non Portafogliati', fieldName: 'nonPortafogliati' , hideDefaultActions: true},
    { label: 'Residuale', fieldName: 'residuale' , hideDefaultActions: true},
    { label: 'Assente', fieldName: 'assente' , hideDefaultActions: true}
];

const TABELLA_ELENCOMMDS = [
    { label: 'MdS', fieldName: 'modelloServizio' },
    { label: 'Numero Contatti', fieldName: 'countNum', hideDefaultActions: true},
    { label: 'Contatti da Assegnare', fieldName: 'countDaAss', hideDefaultActions: true}
];

const TABELLA_ELENCOREF = [
    { label: 'Nominativo', fieldName: 'nomeRisorsa' , hideDefaultActions: true},
    { label: 'Numero Totale Contatti', fieldName: 'numeroContatti', hideDefaultActions: true },
];

const TABELLA_ELENCOOPP = [
    { label: 'Opportunity', fieldName: 'PTF_OppUrl', type: 'url', typeAttributes: {label: { fieldName: 'Name' }} },
    { label: 'Origine', fieldName: 'CRM_Canale__c', hideDefaultActions: true, wrapText: true },
    { label: 'Bisogno', fieldName: 'CRM_Bisogno__c', hideDefaultActions: true, wrapText: true },
    { label: 'Oggetto', fieldName: 'CRM_Oggetto__c', hideDefaultActions: true, wrapText: true },
    { label: 'NDG', fieldName: 'CRM_NDG', hideDefaultActions: true, wrapText: true },
    { label: 'Nome Cliente', fieldName: 'CRM_AccName', hideDefaultActions: true, wrapText: true },
    { label: 'M-MDS', fieldName: 'PTF_ModelloDiServizio', hideDefaultActions: true, wrapText: true },
    { label: 'Stato Assegnazione', fieldName: 'CRM_StatoAssegnazione', hideDefaultActions: true, wrapText: true },
    { label: 'Nome Referente', fieldName: 'CRM_ReferenteName', hideDefaultActions: true, wrapText: true },
    { label: 'Esito', fieldName: 'CRM_EsitoContatto__c', hideDefaultActions: true, wrapText: true },
    { label: 'Autore Esitazione', fieldName: 'CRM_Autore__c', hideDefaultActions: true, wrapText: true }   
];

const TABELLA_ELENCOREFDAASSEGNARE = [
    { label: 'Nominativo', fieldName: 'Name' },
    { label: 'Ruolo', fieldName: 'PTF_TipologiaRuolo' },
    { label: 'Contatti attuali', fieldName: 'nContattiAttuali' },
    { label: 'Contatti previsti', fieldName: 'nContattiPrevisti' }
];

const JSON_ElegibleRoleMMDS = {
    "POE": ["052","054","055","056","057","037"],
    "Family": ["054","055","056","057","037","097","095"],
    "POE_Family": ["054","055","056","057","037"],
    "ruoliDisattivi": ["100","102","092", "074","000"]
}

const COLUMNSLISTAREFRENTI = [
    // { label: 'Ruolo', fieldName: 'PTF_TipologiaRuolo' },
    { label: 'Nominativo', fieldName: 'nomeRisorsa' },
    { label: 'Contatti attuali da Campagne', fieldName: 'numeroContattiCampagne', hideDefaultActions: true, typeAttributes:{ hideDefaultActions: true} },
    { label: 'Contatti attuali da Opportunità', fieldName: 'numeroContattiOpportunita', hideDefaultActions: true, typeAttributes:{ hideDefaultActions: true}},
    { label: 'Contatti attuali da Eventi', fieldName: 'numeroContattiEventi', hideDefaultActions: true, typeAttributes:{ hideDefaultActions: true}}
];

const COLUMNSREFERENTI1 = [
    {label: 'Ruolo', fieldName: 'PTF_TipologiaRuolo' },
    {label: 'Nominativo', fieldName: 'nomeRisorsa', hideDefaultActions: true, wrapText: true},
    {label: 'Contatti attuali da Eventi', fieldName: 'nEventi', hideDefaultActions: true, wrapText: true},
    {label: 'Contatti previsti da Eventi', fieldName: 'nEventiToBe', hideDefaultActions: true, wrapText: true},
    {label: 'Contatti attuali da Campagne', fieldName: 'nCampagne', hideDefaultActions: true, wrapText: true},
    {label: 'Contatti previsti da Campagne', fieldName: 'nCampagneToBe', hideDefaultActions: true, wrapText: true},    
    {label: 'Contatti attuali da Opportunità', fieldName: 'nOpportunita', hideDefaultActions: true, wrapText: true},
    {label: 'Contatti previsti da Opportunità', fieldName: 'nOpportunitaToBe', hideDefaultActions: true, wrapText: true}
];

const getTermOptions = () => {
    return [
        { label: '20 years', value: 20 },
        { label: '25 years', value: 25 },
    ];
};

const calculateMonthlyPayment = (principal, years, rate) => {
    // Your calculation logic here
};

export {TABELLA_ELENCOCAMPAGNE, TABELLA_ELENCOEVENTI,TABELLA_ELENCOMMDS,TABELLA_ELENCOREF,TABELLA_ELENCOOPP,TABELLA_ELENCOREFDAASSEGNARE,JSON_ElegibleRoleMMDS,COLUMNSLISTAREFRENTI,COLUMNSREFERENTI1}