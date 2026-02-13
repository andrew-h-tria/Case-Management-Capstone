import { LightningElement, track } from 'lwc';

export default class CaseConsole extends LightningElement {

    @track filters = {};
    selectedCaseId;

    connectedCallback() {
        console.log('CaseConsole connected');
    }

    handleFilterChange(event) {
        console.log('CaseConsole received filterchange:', JSON.stringify(event.detail));
        this.filters = { ...event.detail };
        console.log('CaseConsole updated filters:', JSON.stringify(this.filters));
    }

    handleCaseSelect(event) {
        this.selectedCaseId = event.detail;
    }
}