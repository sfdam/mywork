import { LightningElement, api, track } from 'lwc';
import init from '@salesforce/apex/ReportLinkController.init';
import getId from '@salesforce/apex/ReportLinkController.getId';

import { NavigationMixin } from "lightning/navigation";
export default class ReportLink extends NavigationMixin(LightningElement) {


    @api reportDevName;
    @api isRipo=false;
    @api idCed;
    @api showBper = false;
    @api showBDS = false;
    @api isGruppo= false;
    @api noFilter= false;
    @track isUfficioPrivate = false;
    @track drList=[];
    @track cedFilter;
    @track isCapofila;
    @track reportId;
    connectedCallback(){
        if(this.reportDevName==='Riportafogliazione_FDS'){
            this.isRipo=true;
            getId({devName:this.reportDevName})
            .then(result=>{
                this.reportId=result;
            })
            .catch(error=>{
                console.log(JSON.stringify(error));
            })
        }
        else{
            let tempCed;
            console.log('@@@@isgruppo: '+this.isGruppo);
            if(this.isGruppo){
                tempCed=null;
            }
            else{
                tempCed=this.idCed;
            }
            init({idCed:tempCed, reportDevName:this.reportDevName}).
            then(result =>{
                console.log('@@@@@reportresult: '+JSON.stringify(result));
                if(!this.isGruppo){
                    console.log('@@@@isgruppo');
                    if(result.hasOwnProperty('cedFilter')){
                        this.cedFilter=result['cedFilter'];
                    }
                    if(result.hasOwnProperty('capofila')){
                        this.isCapofila=result['capofila'];
                        console.log('@@@@capo'+this.isCapofila);
                    }
                    if(result.hasOwnProperty('banca') && result['banca']=='BPER'){
                        this.showBper=true;
                    }
                    else if(result.hasOwnProperty('banca') && result['banca']=='BDS'){
                        this.showBDS=true;
                    }
                    if(result.hasOwnProperty('private')){
                        console.log('@@@@@sonoqui');
                        this.showBper=true;
                        this.showBDS=false;
                        this.isUfficioPrivate=true;
                        this.drList=result['private'];
                    }
                }
            
                else{
                    this.showBper=true;
                    this.showBDS=true;
                }
                console.log('@@@@@showBper: '+this.showBper);
                console.log('@@@@@showBper: '+this.showBDS);
                if(result.hasOwnProperty('reportId')){
                    this.reportId=result['reportId'];
                }
            })
            .catch(error=>{
                console.log(JSON.stringify(error));
            })
        }
        
    }

    redirectToReportBPER(){
        if(this.noFilter){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.reportId,
                    objectApiName: 'Report',
                    actionName: 'view'
                },
                state:{
                    fv6: '05387'

                }
            });
        }
        else{
            if(!this.isGruppo && !this.isUfficioPrivate){
                let defaultValues = {};
    
                defaultValues.fv7=this.cedFilter;
                defaultValues.fv8=this.cedFilter;
                defaultValues.fv9=this.cedFilter;
                defaultValues.fv10=this.cedFilter;
                defaultValues.fv11=this.cedFilter;  
                defaultValues.fv12=this.cedFilter;
                defaultValues.fv13=this.cedFilter;
                defaultValues.fv14=this.cedFilter;
                defaultValues.fv15=this.cedFilter;
                defaultValues.fv16=this.cedFilter;
    
    
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.reportId,
                        objectApiName: 'Report',
                        actionName: 'view'
                    },
                    state:{
                        fv7: defaultValues.fv7,
                        fv8: defaultValues.fv8,
                        fv9: defaultValues.fv9,
                        fv10: defaultValues.fv10,
                        fv11: defaultValues.fv11,
                        fv12: defaultValues.fv12,
                        fv13: defaultValues.fv13,
                        fv14: defaultValues.fv14,
                        fv15: defaultValues.fv15,
                        fv16: defaultValues.fv16,
                        fv17: '05387'
    
                    }
                });
            }
            else if(this.isUfficioPrivate){
                let fv10='filter';
                let fv11='filter';
                let fv12='filter';
                let fv13='filter';
                let fv14='filter';
                for (let i = 0; i < this.drList.length; i++){
                    if(i===0){
                        fv10=this.drList[i];
                    }
                    else if(i===1){
                        fv11=this.drList[i];
                    }
                    else if(i===2){
                        fv12=this.drList[i];
                    }
                    else if(i===3){
                        fv13=this.drList[i];
                    }
                    else if(i===4){
                        fv14=this.drList[i];
                    }
    
                }
                if(this.drList.length===1){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.reportId,
                            objectApiName: 'Report',
                            actionName: 'view'
                        },
                        state:{
                            fv10: fv10,
                            fv17:'05387'
        
                        }
                    });
                }
                else if(this.drList.length===2){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.reportId,
                            objectApiName: 'Report',
                            actionName: 'view'
                        },
                        state:{
                            fv10: fv10,
                            fv11: fv11,
                            fv17:'05387'
        
                        }
                    });
                }
                else if(this.drList.length===3){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.reportId,
                            objectApiName: 'Report',
                            actionName: 'view'
                        },
                        state:{
                            fv10: fv10,
                            fv11: fv11,
                            fv12: fv12,
                            fv17:'05387'
        
                        }
                    });
                }
                else if(this.drList.length===4){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.reportId,
                            objectApiName: 'Report',
                            actionName: 'view'
                        },
                        state:{
                            fv10: fv10,
                            fv11: fv11,
                            fv12: fv12,
                            fv13: fv13,
                            fv17:'05387'
        
                        }
                    });
                }
                else if(this.drList.length===5){
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.reportId,
                            objectApiName: 'Report',
                            actionName: 'view'
                        },
                        state:{
                            fv10: fv10,
                            fv11: fv11,
                            fv12: fv12,
                            fv13: fv13,
                            fv14: fv14,
                            fv17:'05387'
        
                        }
                    });
                }
    
            }
            else{
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.reportId,
                        objectApiName: 'Report',
                        actionName: 'view'
                    },
                    state:{
                        fv17: '05387'
    
                    }
                });
            }
        }
        
        
        
    }

    redirectToReportBDS(){
        if(this.noFilter){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.reportId,
                    objectApiName: 'Report',
                    actionName: 'view'
                },
                state:{
                    fv6: '01015'

                }
            });
        }
        else{
            if(!this.isGruppo){
                let defaultValues = {};
    
                defaultValues.fv7=this.cedFilter;
                defaultValues.fv8=this.cedFilter;
                defaultValues.fv9=this.cedFilter;
                defaultValues.fv10=this.cedFilter;
                defaultValues.fv11=this.cedFilter;  
                defaultValues.fv12=this.cedFilter;
                defaultValues.fv13=this.cedFilter;
                defaultValues.fv14=this.cedFilter;
                defaultValues.fv15=this.cedFilter;
                defaultValues.fv16=this.cedFilter;
    
    
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.reportId,
                        objectApiName: 'Report',
                        actionName: 'view'
                    },
                    state:{
                        fv7: defaultValues.fv7,
                        fv8: defaultValues.fv8,
                        fv9: defaultValues.fv9,
                        fv10: defaultValues.fv10,
                        fv11: defaultValues.fv11,
                        fv12: defaultValues.fv12,
                        fv13: defaultValues.fv13,
                        fv14: defaultValues.fv14,
                        fv15: defaultValues.fv15,
                        fv16: defaultValues.fv16,
                        fv17: '05387'
    
                    }
                });
            }
            else{
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.reportId,
                        objectApiName: 'Report',
                        actionName: 'view'
                    },
                    state:{
                        fv17: '01015'
    
                    }
                });
            }
        }
        
    }
    navigateToRipo(){
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.reportId,
                objectApiName: 'Report',
                actionName: 'view'
            }
        });
    }
}