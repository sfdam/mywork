import { LightningElement , wire,  api, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import File_Name from '@salesforce/label/c.filesDeletesController_File_Name';
import Owner from '@salesforce/label/c.filesDeletesController_Owner';
import File_Type from '@salesforce/label/c.filesDeletesController_File_Type';
import Last_Modified from '@salesforce/label/c.filesDeletesController_Last_Modified';
import getFilesByKnowledgeId from '@salesforce/apex/filesDeletesController.getFilesByKnowledgeId';
import deleteFilesSElected from '@salesforce/apex/filesDeletesController.deleteFilesSelected';
import showDeleteButtonMethod from '@salesforce/apex/filesDeletesController.showDeleteButtonMethod';
import getExistingFiles from '@salesforce/apex/filesDeletesController.getExistingFiles';
import getStatusKnowledge from '@salesforce/apex/filesDeletesController.getStatusKnowledge';
import uploadFile from '@salesforce/apex/filesDeletesController.uploadFile';
const cols = [
     { label: 'File_Name', fieldName: 'Title' ,type: 'text'},
     { label: 'Owner', fieldName: 'Owner',type: 'text'},
     { label: 'Created_Date', fieldName: 'CreatedDate',type: 'date'},
     { label: 'File_Type', fieldName: 'FileType',type: 'text'}
 ];

export default class FilesDeletesController extends LightningElement {
    @api recordId;
    @track pageRef;
    @track files;
    @track title;
    filesNumberZero;
    statusNoAvailable = false;
    showNotAvailableMessage = false;
    @track ownerName;
    nextBaseURL = '/lightning/r/Knowledge__kav/';
    fullBaseURL = '';
    nextBaseURLContent = '';
    showModal = false;
    showAlwaysModal = true;
    _imgItems = [];
    columns = cols;
    showModalAdFile = false;
    showDeleteButton =false;
    @track contDocuments = [];
    @track contDocumentsFinal = [];
    @track dataIds = [];
    fileData
    FIELDS = ['ContentDocument.Owner.Name'];


    async connectedCallback() {
        this.sfdcBaseURL = window.location.origin ? window.location.origin : '';
        this.nextBaseURL = '/lightning/r/' + this.recordId + '/related/AttachedContentDocuments/view';
        this.sfdcBaseURL = this.removeUndefinedFromString(this.sfdcBaseURL);
        this.fullBaseURL = this.makeFullBaseURL(this.sfdcBaseURL, this.nextBaseURL);
    
        console.log('record id 1 >> ' + this.recordId);
        console.log('fullBaseURL >> ' + this.fullBaseURL);
    
        try {
            this.showDeleteButton = await showDeleteButtonMethod();
            console.log('showDeleteButton >> ' + this.showDeleteButton);
    
            const result = await getStatusKnowledge({ recordId: this.recordId });
            if (result && result.length > 0) {
                this.statusNoAvailable = true;
            } else {
                this.statusNoAvailable = false;
            }
        } catch (error) {
            console.log('ERROR', error);
        }
    }

    @wire(getFilesByKnowledgeId, {recordId : '$recordId'})
    retrieveData({error, data}){
        if(data){
            console.log('record id 2 >> ' + this.recordId );
            if(!data.error){
                this.files = data.files;
                this.contDocuments = data.contentDocs;
                this.title = ' Files (' + this.files.length + ')';
                let titleLength = this.files.length ;
                console.log('titleLength => '+ titleLength);

                if( titleLength == 0){
                this.filesNumberZero = true;
                console.log('this.filesNumberZero => '+ this.filesNumberZero);
                }else{
                this.filesNumberZero = false;
                console.log('this.filesNumberZero => '+ this.filesNumberZero);
                }
                console.log('files => ', JSON.stringify(this.files));
                console.log('contDocuments => ', JSON.stringify(this.contDocuments));
                console.log('contDocuments.OwnerId => ', JSON.stringify(this.contDocuments.Owner));
                let objToInsert = {};
                this.contDocumentsFinal = [];
                data.contentDocs.forEach(element => {
                    objToInsert = {};
                    objToInsert.Id = element.Id;
                    objToInsert.CreatedDate = element.CreatedDate;
                    objToInsert.ContentSize = element.ContentSize;
                    objToInsert.Owner = element.Owner.Name;
                    objToInsert.FileType = element.FileType;
                    objToInsert.OwnerId = element.OwnerId;
                    objToInsert.Title = element.Title;
                    this.contDocumentsFinal.push(objToInsert);
                });
                console.log('files length >> ' + this.files.length);
            }else{
                console.log('data getFilesByKnowledgeId => ', JSON.stringify(data));
            }
        }
        if(error){
            //this.showPromptMessage(true,'Erroe','error',JSON.stringify(error.body.message));
        }
    }

    showNotAvailableAction() {
        this.showNotAvailableMessage = true;
        console.log('showNotAvailableMessage' +this.showNotAvailableMessage);
    }
    



    // @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    // wiredRecord({ error, data }) {
    //     if (data) {
    //         this.ownerName = data.fields.Owner.value.fields.Name.value;
    //     } else if (error) {
    //         console.error('Error retrieving record', error);
    //     }
    // }

    // @wire(showDeleteButtonMethod, {})
    //     showDeleteButtonfiles({data}) {
    //         console.log('data  ', data); 
    //        if (data) {
    //             this.showDeleteButton = data;
                
    //        }
    //     }   


    removeUndefinedFromString(sfdcBaseURL){
        let undef = 'undefined';
        let result = '';
        if(sfdcBaseURL === ''){
            console.log('sfdcBaseURL empty!');
            return;
        }
        if (sfdcBaseURL.indexOf(undef) === -1) {
            console.log('Match Not found');
            result = sfdcBaseURL;
            return result;
        }else{
            let index = sfdcBaseURL.indexOf(undef);
            console.log('Match found: '+index);
            result = sfdcBaseURL.substring(0, index);
            console.log('result: '+result);
        }
        return result;
    }

    makeFullBaseURL(baseURL, nextBaseURL){
        if(baseURL === ''){
            console.log('baseURL empty!');
            return;
        }
        this.sfdcBaseURL += nextBaseURL;
        return this.sfdcBaseURL;
    }

    // @wire(getFilesByKnowledgeId,{recordId: '$recordId'})
    // getFilesByKnowledge({error, data}) {
    //     if(data){
    //         this.files =data;
    //     }
    //     if(error){
    //         console.log('ERROR -> ' + error);
    //     }
    // }
    DeleteFiles(){
        this.showModal = true;
    }
    viewAll(){
        window.open(this.fullBaseURL, '_blank')
        //window.location.href = this.fullBaseURL;
    }
    
    AddFile(){
        this.showModalAdFile = true; 
    }

    
    set getFileRecordUrl(val){
        this._imgItems= val;
    }

    get getFileRecordUrl() {
        let items = [];
        if (this.files && this.files.length > 0) {
          this.files.forEach((element) => {
            let el = {};
            el.fileuRL = '/lightning/r/' + element.ContentDocumentId + '/view';
            el.contentDocumentTitle = element.ContentDocument.Title;
            el.contentDocumentFileType = element.ContentDocument.FileType;
            el.contentDocumentCreatedDate = new Intl.DateTimeFormat('en-US', {
              month: 'short',
              day: 'numeric',
              year: 'numeric'
            }).format(new Date(element.ContentDocument.CreatedDate));
            el.contentDocumentOwner = element.ContentDocument.Owner.name;
      
            console.log('ContentSize:', element.ContentDocument.ContentSize);
      
            const contentSizeInBytes = element.ContentDocument.ContentSize;
            if (contentSizeInBytes > 1024) {
              el.contentDocumentSize = (contentSizeInBytes / 1024).toFixed(0) + ' KB';
            } else {
              el.contentDocumentSize = contentSizeInBytes + ' B';
            }
      
            items.push(el);
          });
        }
        return items;
      }

    handleRowSelection(event) {
        this.dataIds= [];
        const selectedRows = event.detail.selectedRows;
        selectedRows.forEach(element => {
            this.dataIds.push(element.Id)
        });
       // this.data = selectedRows;
        console.log('data rowselec => ', JSON.stringify(this.dataIds));
    }
    closeModal(event){
        this.showModal = false; 
    }
    closeModalAdFile(event){
        this.showModalAdFile = false; 
    }
    
    handleDeleteButtonClick(){
        console.log('data rowselec1 => ',this.dataIds.length);
        let params = {
            selectedRows : JSON.stringify(this.dataIds)
        };
        deleteFilesSElected({ selectedRows: this.dataIds })
        .then(result => {
            console.log(result);
            this.showModal = false;
            window.location.reload(true);
        })
        .catch(error => {
            console.error(error);
            this.showModal = false;
            window.location.reload(true);
        });
    }

    openfileUpload(event) {
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            this.fileData = {
                'filename': file.name,
                'base64': base64,
                'recordId': this.recordId
            }
            console.log(this.fileData)
        }
        reader.readAsDataURL(file)
    }
    
    
    handleClick() {
        const { base64, filename, recordId } = this.fileData;
    
        getExistingFiles({ recordId, filename })
                .then(result => {
                if (result && result.length > 0) {
                    // File with the same filename already exists
                    let message = `A file with the name "${filename}" already exists for this record.`;
                    this.showToast('File Exists', message, 'warning');
                } else {
                    // File does not exist, proceed with the upload
                    uploadFile({ base64, filename, recordId })
                        .then(result => {
                            this.fileData = null;
                            let title = `${filename} uploaded successfully!!`;
                            this.showToast('Success', title, 'success');
                            setTimeout(() => {
                                window.location.reload(true);
                            }, 1000);
                        })
                        .catch(error => {
                            this.showToast('Error', 'File upload failed. Please try again.', 'error');
                        });
                }
            })
            .catch(error => {
                this.showToast('Error', 'An error occurred. Please try again.', 'error');
            });
        
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

}