import { LightningElement, api, track } from 'lwc';

export default class Wgc_chart_button extends LightningElement {

    //Attributo di backup al primo salvataggio dei pulsanti ereditati dal parent
    @track _backupButtons = [];
    //Attributo per i pulsanti di secondo livello
    @track _buttons = [];
    //Attributo per i pulsanti di primo livello (nel caso fossero presenti)
    @track _firstLevelButtons = [];

    @api
    get buttons(){
        return this._buttons;
    }

    //Attributo settato dal parent, e gestisco la visualizzazione di default dei pulsanti
    set buttons(btns){
        btns.forEach(btn => {
            if(Array.isArray(btn.value))
                this._firstLevelButtons.push(btn);
        });

        btns.forEach(btn => {
            if(!Array.isArray(btn.value)){
                this._backupButtons.push(btn);
                if(this._firstLevelButtons.find(b => { return b.cssClass.includes('selected') && btn.id.startsWith(b.id); }) != undefined || this._firstLevelButtons.length == 0)
                    this._buttons.push(btn);
            }
        });
    }

    // Event Handlers utilizzato per gestire la selezione dei pulsanti di secondo livello
    // manda un evento al componente padre per poter ricalcolare il nuovo grafico
    handleBtn(event){
        let newButtons = [];
        this._buttons.forEach(btn => {
            let newBtn = {...btn};
            if(newBtn.id == event.currentTarget.dataset.id)
                newBtn.cssClass = 'cstm-button selected';
            else
                newBtn.cssClass = 'cstm-button';

            newButtons.push(newBtn);
        });

        this._buttons = newButtons;

        //Copio l'array per modificare i pulsanti
        let newbackup = [];
        this._backupButtons.forEach(btn => {
            let newBackupBtn = {...btn};
            newbackup.push(newBackupBtn);
        });

        //Una volta copiato, copio la classe css attuale per poter mantenere lo stato
        newbackup.forEach(btn => {
            let newBtn = this._buttons.find(btn2 => { return btn2.id == btn.id });
            if(newBtn != undefined){
                btn.cssClass = newBtn.cssClass;
            }
        });

        this._backupButtons = newbackup;

        this.dispatchEvent(
            new CustomEvent('changegraphics', { detail: { graph: event.currentTarget.dataset.value, btnId: event.currentTarget.dataset.id } })
        );
    }

    // Event handlers utilizzato per gestire i pulsanti di primo livello e mostrare quelli di secondo livello in base al metadato
    handleBtnFirstLevel(event){
        let newButtons = [];
        let selectedBtn;
        this._backupButtons.forEach(btn => {
            if(btn.id.startsWith(event.currentTarget.dataset.id)){
                let newBtn = {...btn};
                newButtons.push(newBtn);
                if(newBtn.cssClass.includes('selected'))
                    selectedBtn = newBtn.value;
            }
        });

        let newFLButtons = [];
        this._firstLevelButtons.forEach(btn => {
            var newBtn = {...btn};
            if(newBtn.id == event.currentTarget.dataset.id)
                newBtn.cssClass = 'cstm-button selected';
            else
                newBtn.cssClass = 'cstm-button';

            newFLButtons.push(newBtn);
        });

        this._firstLevelButtons = newFLButtons;
        this._buttons = newButtons;

        this.dispatchEvent(
            new CustomEvent('changegraphics', { detail: { graph: selectedBtn, btnId: event.currentTarget.dataset.id } })
        )
    }


}