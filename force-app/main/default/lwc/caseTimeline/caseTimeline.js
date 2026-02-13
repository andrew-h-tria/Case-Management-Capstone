import { LightningElement, api, wire } from 'lwc';
import getCaseTimeline from '@salesforce/apex/Case_Manager.getCaseTimeline';

export default class CaseTimeline extends LightningElement {
    @api recordId; // Injects the Current Case ID
    activities;

    // Wiring the Apex method from Case_Manager
    @wire(getCaseTimeline, { caseId: '$recordId' })
    wiredActivities({ error, data }) {
        if (data) {
            this.activities = data;
        } else if (error) {
            console.error('Error fetching timeline data', error);
        }
    }
}