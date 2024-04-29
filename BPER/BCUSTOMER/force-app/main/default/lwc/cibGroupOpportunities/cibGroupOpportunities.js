import { LightningElement, api, track } from 'lwc';

import init from '@salesforce/apex/CibGroupOpportunitiesController.init';

// COLUMNS = [
//     {
//         type: 'url',
//         fieldName: 'opp_Url',
//         cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
//         typeAttributes: {
//             label: { fieldName: 'Name' }
//         },
//         label: 'Opportunità',
//         initialWidth: 180,
//     },
//     {type: 'text',fieldName: 'CIB_Nome_Opportunita__c',label: 'Nome Opportunità'},
//     // {type: 'text',fieldName: 'accountName',label: 'Account'},
//     {type: 'text',fieldName: 'ownerName',label: 'Titolare'},
//     {type: 'text',fieldName: 'StageName',label: 'Status'},
//     {type: 'text',fieldName: 'RecordTypeName__c',label: 'Tipo di Record'},
//     {type: 'text',fieldName: 'Tipo_Operazione__c',label: 'Tipo Operazione'},
//     {type: 'text',fieldName: 'Desk__c',label: 'Tipo Operazione'},
// ];
export default class CibGroupOpportunities extends LightningElement {
    @api recordId;
    @api whereCondition;
    @api titolo = 'Opportinità Relazionate'
    @track columns = [
        {
            type: 'url',
            fieldName: 'opp_Url',
            cellAttributes:{ iconName: { fieldName: 'provenanceIconName' } },
            typeAttributes: {
                label: { fieldName: 'Name' }
            },
            label: 'NOME',
            
        },
        {type: 'text',fieldName: 'CIB_Nome_Opportunita__c',label: 'NOME OPPORTUNITÀ', },
        {type: 'text',fieldName: 'accountName',label: 'ACCOUNT', },
        {type: 'text',fieldName: 'ownerName',label: 'TITOLARE', },
        {type: 'text',fieldName: 'StageName',label: 'FASE', },
        {type: 'text',fieldName: 'RecordTypeName__c',label: 'TIPO DI RECORD', initialWidth: 120},
        {type: 'text',fieldName: 'Tipo_Operazione__c',label: 'TIPO OPERAZIONE', initialWidth: 120},
        {type: 'text',fieldName: 'Desk__c',label: 'DESK', initialWidth: 120},
    ];

    @track data;
    @track filteredData;

    connectedCallback(){

        console.log('DK CibGroupOpportunities connectedCallback START');
        try {
            init({recordId: this.recordId, whereCondition: this.whereCondition})
            .then(result =>{
                console.log('DK CibGroupOpportunities connectedCallback result', result);
                if(result){
                    if(result.opportunities && result.opportunities.length > 0){
                        result.opportunities.forEach(opportunita =>{
                            opportunita.opp_Url = '/' + opportunita.Id;
                            opportunita.accountName = opportunita.Account.Name;
                            opportunita.ownerName = opportunita.Owner.Name;
                        })

                        this.data = result.opportunities;
                        this.filteredData = this.data;
                        this.titolo += ' (' + this.data.length + ')';
                        this.setPages(this.data);
                    }
                }
            })
            .catch(err =>{
                console.log('DK CibGroupOpportunities connectedCallback init error', err);
            })
            .finally(() =>{
            })
        } catch (error) {
            console.log('DK CibGroupOpportunities connectedCallback error', error);
        }
    }

    //Test Pagination
    @track page = 1;
    perpage = 25;
    @track pages = [];
    set_size = 25;
    

    handleAvanti(){
        ++this.page;
    }
    handleIndietro(){
        --this.page;
    }
    
    get pagesList(){
        let mid = Math.floor(this.set_size/2) + 1 ;
        if(this.page > mid){
            return this.pages.slice(this.page-mid, this.page+mid-1);
        } 
        return this.pages.slice(0,this.set_size);
    }
    
    pageData = ()=>{
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page*perpage) - perpage;
        let endIndex = (page*perpage);
        return this.filteredData.slice(startIndex,endIndex);
    }

    setPages = (data)=>{
        this.pages = [];
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
        console.log('DK this.pages: ' + this.pages);
    }  
    
    get disabledButtonIndietro(){
        return this.page === 1;
    }
    
    get disabledButtonAvanti(){
        return this.page === this.pages.length || this.filteredData.length === 0
    }

    get currentPageData(){
        return this.pageData();
    }
}