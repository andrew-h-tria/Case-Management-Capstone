import { LightningElement, api } from 'lwc';
import fetchProviders from '@salesforce/apex/Case_ExternalProviderService.fetchProviders';
import selectProvider from '@salesforce/apex/Case_Manager.selectProvider';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ProviderInteraction extends LightningElement {
    @api recordId; // Case Record ID context
    providers;

    // Fetch providers via Apex service
    handleFindProviders() {
        fetchProviders({ caseId: this.recordId, serviceCategory: null })
            .then(result => {
                this.providers = result;
                this.showToast('Success', 'Providers found!', 'success');
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    // Link selected provider to Case and update status
    handleSelectProvider(event) {
        const selectedProvId = event.target.name;
        
        selectProvider({ caseId: this.recordId, providerId: selectedProvId })
            .then(() => {
                this.showToast('Success', 'Case updated to In Progress.', 'success');
                this.providers = null; 
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    // Display platform toast notifications
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}