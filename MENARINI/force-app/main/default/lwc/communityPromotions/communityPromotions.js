import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';
import getPromotions from '@salesforce/apex/CommunityPromotionsController.getPromotions';
import getBase64File from '@salesforce/apex/CommunityPromotionsController.getBase64File';

const GENERIC_ERROR_MESSAGE = "An error has occurred";
const NO_PROMOTIONS_MESSAGE = "Nessuna promozione disponibile al momento."//"Sorry, there are no promotions at the moment.";

export default class CommunityPromotions extends NavigationMixin(LightningElement) {

    loading = false;
    downloading = false;
    promotions = [];
    showPromotions = false;
    noPromotionsMessage = NO_PROMOTIONS_MESSAGE;
    promotionsData;

    connectedCallback() {
        this.init();
    }

    async init() {
        this.loading = true;

        try {
            this.promotionsData = await getPromotions();

            if(this.promotionsData?.campaignMembers) {
                this.promotions = this.promotionsData.campaignMembers.map((campaignMember, campaignMemberIndex) => {

                   const files = [];
                   let logoFile;

                   this.promotionsData?.contentDocumentLinks?.forEach(contentDocumentLink => {
                       if(contentDocumentLink.LinkedEntityId === campaignMember.CampaignId) {
                           if(contentDocumentLink?.ContentDocument?.Title?.toUpperCase() !== "LOGO") {
                               files.push(contentDocumentLink);
                           } else {
                               logoFile = contentDocumentLink;
                           }
                       }
                   });

                   return  {
                       index: `c.${campaignMemberIndex}`,
                       campaignId: campaignMember?.CampaignId,
                       campaignName: campaignMember?.Campaign?.Name,
                       campaignStartDate: campaignMember?.Campaign?.StartDate,
                       campaignEndDate: campaignMember?.Campaign?.EndDate,
                       campaignDivision: campaignMember?.Campaign?.Division__c,
                       campaignCompany: campaignMember?.Campaign?.Company__c,
                       campaignFiles: files?.map((file, fileIndex) => {
                           return {
                               index: `f.${campaignMemberIndex}.${fileIndex}`,
                               name: `${file.ContentDocument.Title}.${file.ContentDocument.FileExtension}`,
                               contentDocumentId: file.ContentDocumentId
                           };
                       }),
                       logoFile: logoFile
                   }
                });
            }

            if(this.promotions?.length > 0) {
                for(const promotion of this.promotions) {
                    const link = await this.getDocumentLink(promotion?.logoFile?.ContentDocumentId, promotion?.logoFile);
                    promotion.logoHref = link?.href;
                }

                this.showPromotions = true;
            }
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}));
        }
        finally {
            this.loading = false;
        }
    }

    async getDocumentLink(contentDocumentId, contentDocumentLink) {
        let link;
        if(contentDocumentId && contentDocumentLink) {
            const base64File = await getBase64File({contentDocumentId: contentDocumentId});

            if(base64File != null) {
                const binaryString = window.atob(base64File);
                const bytes = new Uint8Array(binaryString.length);

                for (let i = 0; i < binaryString.length; i++) {
                    bytes[i] = binaryString.charCodeAt(i);
                }

                const blob = new Blob([bytes], {type: this.getMimeType(contentDocumentLink.ContentDocument.FileType)});
                link = document.createElement("a");
                link.href = window.URL.createObjectURL(blob);
                link.download = `${contentDocumentLink.ContentDocument.Title}.${contentDocumentLink.ContentDocument.FileExtension}`;
            }
        }
        return link;
    }

    async downloadFile(event) {
        try {
            this.downloading = true;
            const contentDocumentId = event?.currentTarget?.dataset?.contentDocumentId;
            const contentDocumentLink = this.promotionsData?.contentDocumentLinks?.find(contentDocumentLink => contentDocumentLink["ContentDocumentId"] === contentDocumentId);
            const link = await this.getDocumentLink(contentDocumentId, contentDocumentLink);
            link?.click();
        }
        catch (error) {
            this.dispatchEvent(new ShowToastEvent({variant: "error", title: "Error", message: GENERIC_ERROR_MESSAGE}));
        }
        finally {
            this.downloading = false;
        }
    }

    getMimeType(contentDocumentFileType) {
        switch (contentDocumentFileType) {
            case 'PDF':
                return "application/pdf";
            case "PNG":
                return "image/png";
            case "GIF":
                return "image/gif";
            case "BMP":
                return "image/bmp";
            case "JPG":
                return "image/jpeg";
            default:
                return "text/plain";
        }
    }
}