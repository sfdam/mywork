import { LightningElement, track, wire, api } from 'lwc';
import getAccountList from '@salesforce/apex/HelloWorldController.getAccountList';

const columns = [
    { label: 'Name', fieldName: 'Name', type: 'text'},
    { label: 'Phone', fieldName: 'Phone', type: 'text' },
    { label: 'Type', fieldName: 'Type', type: 'text'},
];
export default class HelloWorld extends LightningElement {
    @track greeting = 'test';
    @track data;
    @track accounts;
    @wire(getAccountList, {}) wiredAccounts({error, data}){
        if(data){
            this.accounts = data;
        }else{
            console.log(error);
        }
    };
    colonne = columns;
    connectedCallback(){
        /*getAccountList()
        .then(data =>{
            this.data = data;
        }).catch(error =>{
            console.log(error);
        }).finally(() =>{
            console.log('FINISH');
        })*/
        console.log('DK accounts: ', this.accounts);
	//definisce le azioni da fare al carimento del componente
	//solitamente viene eseguito un retrive dei dati
    //inizializzazione di attributi e controlli vari
    }
    changeHandler(event) {
        this.greeting = event.target.value;
    }
}