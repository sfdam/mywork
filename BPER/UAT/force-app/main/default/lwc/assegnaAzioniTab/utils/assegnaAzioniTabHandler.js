const TABELLA_ELENCOCAMPAGNE = [
    { label: 'Bisogno', fieldName: 'bisogno',sortable: "true",initialWidth: 150},
    { label: 'Tipologia', fieldName: 'tipologia',sortable: "true",initialWidth: 150 },
    { label: 'Nome Campagna', fieldName: 'nameUrl', type: 'url', typeAttributes: {label: { fieldName: 'nomeCampagna' }},sortable: "true",initialWidth: 420},
    { label: 'Data Inizio', fieldName: 'startDate', type: "date-local",typeAttributes:{ month: "2-digit",day: "2-digit"}, hideDefaultActions: true,sortable: "true",initialWidth: 100},
    { label: 'Data Fine', fieldName: 'endDate', type: "date-local",typeAttributes:{ month: "2-digit",day: "2-digit"}, hideDefaultActions: true,sortable: "true",initialWidth: 100},
    { label: 'Priorità', fieldName: 'priorita' , hideDefaultActions: true,sortable: "true",initialWidth: 80},
    { label: 'Totale Contatti Da Assegnare', fieldName: 'totaleContatti', sortable: "true",hideDefaultActions: true},
    { label: 'Family', fieldName: 'contattiMdsFamily' , sortable: "true",hideDefaultActions: true},
    { label: 'POE', fieldName: 'contattiMdsPoe' , sortable: "true",hideDefaultActions: true},
    { label: 'Non Portafogliati', fieldName: 'nonPortafogliati' , sortable: "true",hideDefaultActions: true},
    { label: 'Residuale', fieldName: 'residuale' , sortable: "true",hideDefaultActions: true},
    { label: 'Assente', fieldName: 'assente' , sortable: "true",hideDefaultActions: true}
];

const TABELLA_ELENCOEVENTI = [
    { label: 'Bisogno', fieldName: 'bisogno',sortable: "true", initialWidth: 150 },
    { label: 'Nome Evento', fieldName: 'nameUrl', type: 'url', typeAttributes: {label: { fieldName: 'nomeCampagna' }},sortable: "true", initialWidth: 420},
    { label: 'Data Inizio', fieldName: 'startDate', type: "date-local",typeAttributes:{ month: "2-digit",day: "2-digit"}, sortable: "true", hideDefaultActions: true,initialWidth: 100},
    { label: 'Data Fine', fieldName: 'endDate', type: "date-local",typeAttributes:{ month: "2-digit",day: "2-digit"}, sortable: "true", hideDefaultActions: true,initialWidth: 100},
    { label: 'Priorità', fieldName: 'priorita' , sortable: "true", hideDefaultActions: true,initialWidth: 80},
    { label: 'Totale Contatti Da Assegnare', fieldName: 'totaleContatti', sortable: "true", hideDefaultActions: true},
    { label: 'Family', fieldName: 'contattiMdsFamily' , sortable: "true", hideDefaultActions: true},
    { label: 'POE', fieldName: 'contattiMdsPoe' , sortable: "true", hideDefaultActions: true},
    { label: 'Non Portafogliati', fieldName: 'nonPortafogliati' , sortable: "true", hideDefaultActions: true},
    { label: 'Residuale', fieldName: 'residuale' , sortable: "true", hideDefaultActions: true},
    { label: 'Assente', fieldName: 'assente' , sortable: "true", hideDefaultActions: true}
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
    { label: 'Codice Opportunità', fieldName: 'Name', type: 'text', sortable: "true" },
    { label: 'Origine', fieldName: 'CRM_Canale__c', hideDefaultActions: true, wrapText: true, sortable: "true" },
    { label: 'Bisogno', fieldName: 'CRM_Bisogno__c', hideDefaultActions: true, wrapText: true, sortable: "true" },
    { label: 'Oggetto', fieldName: 'CRM_Oggetto__c', hideDefaultActions: true, wrapText: true, sortable: "true" },
    { label: 'NDG', fieldName: 'PTF_AccountUrl', type: 'url', sortable: "true", hideDefaultActions: true, typeAttributes: {hideDefaultActions: true, label: { fieldName: 'CRM_NDG' }}, sortable: "true"},
    { label: 'Nome Cliente', fieldName: 'CRM_AccName', hideDefaultActions: true, wrapText: true, sortable: "true" },
    { label: 'M-MDS', fieldName: 'PTF_ModelloDiServizio', hideDefaultActions: true, wrapText: true, sortable: "true" },
    { label: 'Stato Assegnazione', fieldName: 'CRM_StatoAssegnazione', hideDefaultActions: true, wrapText: true, sortable: "true" },
    { label: 'Nome Referente', fieldName: 'CRM_ReferenteName', hideDefaultActions: true, wrapText: true, sortable: "true" },
    { label: 'Esito', fieldName: 'CRM_EsitoContatto__c', hideDefaultActions: true, wrapText: true, sortable: "true" },
    { label: 'Autore Esitazione', fieldName: 'CRM_Autore__c', hideDefaultActions: true, wrapText: true, sortable: "true" }   
];

const TABELLA_ELENCOREFDAASSEGNARE = [
    { label: 'Nominativo', fieldName: 'Name' },
    { label: 'Ruolo', fieldName: 'PTF_TipologiaRuolo' },
    { label: 'Contatti attuali', fieldName: 'nContattiAttuali' },
    { label: 'Contatti previsti', fieldName: 'nContattiPrevisti' }
];

const JSON_ElegibleRoleMMDS = {
    "POE": ["052","054","055","056","057","037"],
    "Family": ["054","055","056","057","037","097","095","094"],
    "POE_Family": ["054","055","056","057","037"],
    "ruoliDisattivi": ["102","092", "074","000"]
}

const COLUMNSLISTAREFRENTI = [
    // { label: 'Ruolo', fieldName: 'PTF_TipologiaRuolo' },
    { label: 'Nominativo', fieldName: 'nomeRisorsa', sortable: "true"},
    { label: 'Contatti attuali da Campagne', fieldName: 'numeroContattiCampagne', hideDefaultActions: true, typeAttributes:{ hideDefaultActions: true} },
    { label: 'Contatti attuali da Opportunità', fieldName: 'numeroContattiOpportunita', hideDefaultActions: true, typeAttributes:{ hideDefaultActions: true}},
    { label: 'Contatti attuali da Eventi', fieldName: 'numeroContattiEventi', hideDefaultActions: true, typeAttributes:{ hideDefaultActions: true}}
];

const COLUMNSREFERENTI1 = [
    {label: 'Ruolo', fieldName: 'PTF_TipologiaRuolo' },
    {label: 'Nominativo', fieldName: 'nomeRisorsa', hideDefaultActions: true, wrapText: true, sortable: "true"},
    {label: 'Contatti attuali da Eventi', fieldName: 'nEventi', hideDefaultActions: true, wrapText: true},
    {label: 'Contatti previsti da Eventi', fieldName: 'nEventiToBe', hideDefaultActions: true, wrapText: true},
    {label: 'Contatti attuali da Campagne', fieldName: 'nCampagne', hideDefaultActions: true, wrapText: true},
    {label: 'Contatti previsti da Campagne', fieldName: 'nCampagneToBe', hideDefaultActions: true, wrapText: true},    
    {label: 'Contatti attuali da Opportunità', fieldName: 'nOpportunita', hideDefaultActions: true, wrapText: true},
    {label: 'Contatti previsti da Opportunità', fieldName: 'nOpportunitaToBe', hideDefaultActions: true, wrapText: true}
];

const optionsStato = () => {
    return [
        { label: '---Nessun filtro---', value: '' },
        { label: 'Assegnato', value: 'Assegnato' },
        { label: 'Non assegnato', value: 'Non assegnato' }
    ];
};

const optionsMMDS = () => {
    return [
        { label: '---Nessun filtro---', value: '' },
        { label: 'POE', value: 'POE' },
        { label: 'Family', value: 'Family' },
        { label: 'Assente', value: 'Assente' },
        { label: 'Residuale', value: 'Residuale' },
        { label: 'Non Portafogliati', value: 'Non Portafogliati' }
    ];
}

const optionsPriorita = () => {
    return [
        { label: '---Nessun filtro---', value: '' },
        { label: '1', value: '1' },
        { label: '2', value: '2' },
        { label: '3', value: '3' },
        { label: '4', value: '4' },
        { label: '5', value: '5' }
    ];
}

const optionsCanale = () => {
    return [
        { label: '---Nessun filtro---', value: '' },
        { label: 'Campagna commerciale', value: 'Campagna commerciale' },
        { label: 'Check-up', value: 'Check-up' },
        { label: 'Contact Center', value: 'Contact Center'},
        { label: 'Self', value: 'Self'}
    ];
}

const optionsBisogno = () => {
    return [
        { label: '---Nessun filtro---', value: '' },
        { label: 'Acquisizione', value: 'Acquisizione' },
        { label: 'Assicurativo', value: 'Assicurativo' },
        { label: 'Finanziamenti', value: 'Finanziamenti' },
        { label: 'Finanziario', value: 'Finanziario' },
        { label: 'Investimento', value: 'Investimento' },
        { label: 'Patrimonio', value: 'Patrimonio' },
        { label: 'Previdenziale', value: 'Previdenziale' },
        { label: 'Transazionale', value: 'Transazionale' },
        { label: 'Wealth Management', value: 'Wealth Management' },
        { label: 'Altri', value: 'Altri' }
    ]
}

const optionsEsito = () =>{
    return [
        { label: '---Nessun filtro---', value: '' },
        { label: 'Da contattare', value: 'Da contattare' },
        { label: 'Non contattabile', value: 'Non contattabile' },
        { label: 'Cliente non adatto', value: 'Cliente non adatto' },
        { label: 'Cliente interessato', value: 'Cliente interessato' },
        { label: 'Prodotto target venduto', value: 'Prodotto target venduto' },
        { label: 'Da ricontattare', value: 'Da ricontattare' },
        { label: 'Fissato appuntamento', value: 'Fissato appuntamento' },
        { label: 'Altro prodotto venduto', value: 'Altro prodotto venduto' },
        { label: 'Ingaggio agente', value: 'Ingaggio agente' },
        { label: 'Cliente non contattabile', value: 'Cliente non contattabile' },
        { label: 'Cliente non interessato', value: 'Cliente non interessato' }                
    ];
}

const optionsFase = () => {
    return [
        { label: '---Nessun filtro---', value: '' },
        { label: 'Da Contattare', value: 'Da Contattare' },
        { label: 'Non Risponde 1', value: 'Non Risponde 1' },
        { label: 'Non Risponde 2', value: 'Non Risponde 2' },
        { label: 'Non Risponde 3', value: 'Non Risponde 3' },
        { label: 'Non raggiungibile', value: 'Non raggiungibile' },
        { label: 'Accettata', value: 'Accettata' },
        { label: 'Rifiutata' , value: 'Rifiutata'},
        { label: 'Eliminata', value: 'Eliminata'}
    ];
}

const optionsEsitoOpp = () => {
    return [
        { label: '---Nessun filtro---', value: ''},
        { label: 'Cliente interessato', value: 'Cliente interessato' },
        { label: 'Da contattare', value: 'Da contattare' },
        { label: 'Da ricontattare', value: 'Da ricontattare' },
        { label: 'Fissato appuntamento', value: 'Fissato appuntamento' },
        { label: 'Prodotto venduto', value: 'Prodotto venduto' },
        { label: 'Prodotto non venduto', value: 'Prodotto non venduto' }
    ];
}

const extendCampaignEventMembers = (campaignEventMembers) => {
    let response = {};
    let campaign = campaignEventMembers;
    let data = [];
    let clientListData = [];
    let referentiListData = [];
    let foundAttributo1 = [];
    let foundAttributo2 = [];
    let typeMap = {};
    let optionsAttributo1 = [];
    let optionsAttributo2 = [];
    let idReferentiAssegnate = [];
    
    for(let keyC in campaign){
        let keyArray = keyC.split('_');
        campaign[keyC] = JSON.parse(JSON.stringify(campaign[keyC]));
        campaign[keyC].CRM_NDG = campaign[keyC].CRM_Account__r.CRM_NDG__c;
        campaign[keyC].PTF_AccountUrl =  '/' + campaign[keyC].CRM_Account__c;
        campaign[keyC].CRM_AccountName = campaign[keyC].CRM_Account__r.Name;
        campaign[keyC].CampaignName =  campaign[keyC].Campaign__r.Name;
        campaign[keyC].PTF_NaturaGiuridica = campaign[keyC].CRM_Account__r.PTF_NaturaGiuridica__c;
        campaign[keyC].PTF_PortafoglioUrl =  campaign[keyC].CRM_Account__r.hasOwnProperty('PTF_Portafoglio__c') ? '/' + campaign[keyC].CRM_Account__r.PTF_Portafoglio__c : '';
        campaign[keyC].PTF_Portafoglio = campaign[keyC].CRM_Account__r.hasOwnProperty('PTF_Portafoglio__c') ? campaign[keyC].CRM_Account__r.PTF_Portafoglio__r.Name : '';
        campaign[keyC].PTF_Miniportafoglio = campaign[keyC].CRM_Account__r.hasOwnProperty('PTF_MiniPortafoglio__c') ? campaign[keyC].CRM_Account__r.PTF_MiniPortafoglio__r.Name : '';
        //console.log('PTF_Miniportafoglio: '+campaign[keyC].PTF_Miniportafoglio);
        campaign[keyC].PTF_ModelloDiServizio = Boolean(campaign[keyC].CRM_Account__r.ModelloDiServizio__c) ? campaign[keyC].CRM_Account__r.ModelloDiServizio__c : 'Non Portafogliati';
        campaign[keyC].CRM_StatoAssegnazione = campaign[keyC].hasOwnProperty('CRM_AssegnatarioUser__c') ? 'Assegnato' : 'Non assegnato';
        campaign[keyC].CRM_ReferenteName = campaign[keyC].hasOwnProperty('CRM_AssegnatarioUser__c') ? campaign[keyC].CRM_AssegnatarioUser__r.Name : '';
        // ATTRIBUTI DINAMICI
        campaign[keyC].CRM_NomeAttributo1 = campaign[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c;
        campaign[keyC].CRM_NomeAttributo2 = campaign[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c;

        campaign[keyC].CRM_Autore = campaign[keyC].hasOwnProperty('CRM_Autore__c') ? campaign[keyC].CRM_Autore__c : '';
        if(Boolean(campaign[keyC].CRM_ValoreAttributo1_Date__c)){
            campaign[keyC].CRM_ValoreAttributo1 = campaign[keyC].CRM_ValoreAttributo1_Date__c;
            campaign[keyC].type1 = 'date';
            
        }else if(Boolean(campaign[keyC].CRM_ValoreAttributo1_Number__c)){
            campaign[keyC].CRM_ValoreAttributo1 = campaign[keyC].CRM_ValoreAttributo1_Number__c;
            campaign[keyC].type1 = 'number';
        }else{
            campaign[keyC].CRM_ValoreAttributo1 = campaign[keyC].CRM_ValoreAttributo1_Text__c;
            campaign[keyC].type1 = 'text';
        }

        if(Boolean(campaign[keyC].CRM_ValoreAttributo2_Date__c)){
            campaign[keyC].CRM_ValoreAttributo2 = campaign[keyC].CRM_ValoreAttributo2_Date__c;
            campaign[keyC].type2 = 'date';
        }else if(Boolean(campaign[keyC].CRM_ValoreAttributo2_Number__c)){
            campaign[keyC].CRM_ValoreAttributo2 = campaign[keyC].CRM_ValoreAttributo2_Number__c;
            campaign[keyC].type2 = 'number';
        }else{
            campaign[keyC].CRM_ValoreAttributo2 = campaign[keyC].CRM_ValoreAttributo2_Text__c;
            campaign[keyC].type2 = 'text';
        }

        if(Boolean(campaign[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c)){
            if(!foundAttributo1.includes(campaign[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c)){
                typeMap[campaign[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c] = campaign[keyC].type1;foundAttributo1.push(campaign[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c);
                optionsAttributo1.push({
                    label : campaign[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c,
                    value: campaign[keyC].Campaign__r.CRM_Nome_Attributo_1_formula__c
                })
            }
        }
        if(Boolean(campaign[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c)){
            if(!foundAttributo2.includes(campaign[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c)){
                typeMap[campaign[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c] = campaign[keyC].type2;foundAttributo2.push(campaign[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c);
                optionsAttributo2.push({
                    label : campaign[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c,
                    value: campaign[keyC].Campaign__r.CRM_Nome_Attributo_2_formula__c
                })
            }
        }
        // ATTRIBUTI DINAMICI

        let findCampaign = data.filter(obj => {
            return obj.Id === keyArray[0]
        })

        let findClient = clientListData.filter(obj => {
            return obj.modelloServizio === keyArray[2]
        })

        let findReferente = [];
        if(campaign[keyC].hasOwnProperty('CRM_AssegnatarioUser__c')){
            idReferentiAssegnate.push(campaign[keyC].CRM_AssegnatarioUser__c);
            findReferente = referentiListData.filter(obj => {
                return obj.Id === campaign[keyC].CRM_AssegnatarioUser__c
            })
        }

        if(findCampaign.length === 0){
            let obj = {};
            obj.Id = keyArray[0];
            obj.bisogno = campaign[keyC].Campaign__r.CRM_Categoria__c;
            obj.nomeCampagna = campaign[keyC].Campaign__r.Name;
            obj.nameUrl = '/' + keyArray[0];
            obj.priorita = campaign[keyC].Campaign__r.CRM_Priorita__c;
            obj.startDate = campaign[keyC].Campaign__r.CRM_StartDateFormula__c;
            obj.endDate = campaign[keyC].Campaign__r.CRM_EndDateFormula__c;

            obj.totaleContatti = !campaign[keyC].CRM_AssegnatarioUser__r ? 1 : 0;
            obj.contattiMdsFamily = (keyArray[2] == 'Family' && !campaign[keyC].CRM_AssegnatarioUser__r) ? 1 : 0;
            obj.contattiMdsPoe = (keyArray[2] == 'POE' && !campaign[keyC].CRM_AssegnatarioUser__r) ? 1 : 0;
            obj.nonPortafogliati = (keyArray[2] == 'Non Portafogliati' && !campaign[keyC].CRM_AssegnatarioUser__r) ? 1 : 0;
            obj.assente = (keyArray[2] == 'Assente' && !campaign[keyC].CRM_AssegnatarioUser__r) ? 1 : 0;
            obj.residuale = (keyArray[2] == 'Residuale' && !campaign[keyC].CRM_AssegnatarioUser__r) ? 1 : 0;

            obj.tipologia = campaign[keyC].Campaign__r.Tipologia_Azione__c;
            data.push(obj);

        } else {
            if(!campaign[keyC].CRM_AssegnatarioUser__r){
                findCampaign[0].totaleContatti = findCampaign[0].totaleContatti + 1;
                findCampaign[0].contattiMdsFamily = keyArray[2] == 'Family' ? findCampaign[0].contattiMdsFamily + 1 : findCampaign[0].contattiMdsFamily;
                findCampaign[0].contattiMdsPoe = keyArray[2] == 'POE' ? findCampaign[0].contattiMdsPoe + 1 : findCampaign[0].contattiMdsPoe;
                findCampaign[0].nonPortafogliati =  keyArray[2] == 'Non Portafogliati' ? findCampaign[0].nonPortafogliati + 1 : findCampaign[0].nonPortafogliati;
                findCampaign[0].assente = keyArray[2] == 'Assente' ? findCampaign[0].assente + 1 : findCampaign[0].assente;
                findCampaign[0].residuale = keyArray[2] == 'Residuale' ? findCampaign[0].residuale + 1 : findCampaign[0].residuale;
            }
        }

        if(findClient.length === 0){
            let obj = {};
            obj.modelloServizio = keyArray[2];

            obj.countNum = 1;
            obj.countDaAss = campaign[keyC].hasOwnProperty('CRM_AssegnatarioUser__c') ? 0 : 1;

            clientListData.push(obj);

        } else {
            findClient[0].countNum = findClient[0].countNum + 1;
            findClient[0].countDaAss = campaign[keyC].hasOwnProperty('CRM_AssegnatarioUser__c') ? findClient[0].countDaAss : findClient[0].countDaAss + 1;
        }

        if(campaign[keyC].hasOwnProperty('CRM_AssegnatarioUser__c')){
            if(findReferente.length === 0){
                let obj = {};
                obj.Id = campaign[keyC].CRM_AssegnatarioUser__c;
                obj.nomeRisorsa = campaign[keyC].CRM_AssegnatarioUser__r.Name;

                obj.numeroContatti = 1;

                obj._children = [];
                let objChild = {};
                objChild.Id = keyArray[0];
                objChild.nomeRisorsa = campaign[keyC].Campaign__r.Name;
                objChild.numeroContatti = 1;

                obj._children.push(objChild);
                referentiListData.push(obj);

            } else {
                findReferente[0].numeroContatti = findReferente[0].numeroContatti + 1;
                let findCampaignRef = findReferente[0]._children.filter(obj => {
                    return obj.Id === keyArray[0]
                })

                if(findCampaignRef.length === 0){
                    let objChild = {};
                    objChild.Id = keyArray[0];
                    objChild.nomeRisorsa = campaign[keyC].Campaign__r.Name;
                    objChild.numeroContatti = 1;

                    findReferente[0]._children.push(objChild);
                } else {
                    findCampaignRef[0].numeroContatti = findCampaignRef[0].numeroContatti + 1;
                }
            }
        }
    }

    response.data = data;
    response.clientListData = clientListData;
    response.referentiListData = referentiListData;
    response.foundAttributo1 = foundAttributo1;
    response.foundAttributo2 = foundAttributo2;
    response.typeMap = typeMap;
    response.optionsAttributo1 = optionsAttributo1;
    response.optionsAttributo2 = optionsAttributo2;
    response.idReferentiAssegnate = idReferentiAssegnate;

    return response;
}


export {TABELLA_ELENCOCAMPAGNE, TABELLA_ELENCOEVENTI,TABELLA_ELENCOMMDS,TABELLA_ELENCOREF,TABELLA_ELENCOOPP,TABELLA_ELENCOREFDAASSEGNARE,JSON_ElegibleRoleMMDS,COLUMNSLISTAREFRENTI,COLUMNSREFERENTI1, optionsStato, optionsMMDS, optionsPriorita, optionsCanale, optionsBisogno, optionsEsito, optionsFase, optionsEsitoOpp, extendCampaignEventMembers}