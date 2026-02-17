import { LightningElement, api, wire } from 'lwc';
import getCaseTimeline from '@salesforce/apex/Case_Manager.getCaseTimeline';
import { refreshApex } from '@salesforce/apex';
import { subscribe, MessageContext } from 'lightning/messageService';
import CASE_MC from '@salesforce/messageChannel/caseMessageChannel__c';
// Added imports to detect standard record changes (Priority, Status, etc.)
import { getRecord } from 'lightning/uiRecordApi';

export default class CaseTimeline extends LightningElement {
    @api recordId;
    wiredActivitiesResult; // Variable to store the wired result for manual refreshing
    activities;

    @wire(MessageContext)
    messageContext;

    // Checks if list exists AND has items so we don't show an empty timeline
    get hasActivities() {
        return this.activities && this.activities.length > 0;
    }

    // This wire monitors the database for any changes to the current Case record
    // It triggers automatically when user clicks the standard "Save" button
    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Compact'] })
    wiredRecord(result) {
        if (result.data || result.error) {
            // Added a 400ms delay to prevent the "Choose values to keep" conflict popup
            // so server-side Save finishes before we refresh the UI.
            // This also ensures the handleAfter trigger has finished inserting the activity.
            setTimeout(() => {
                refreshApex(this.wiredActivitiesResult);
            }, 400);
        }
    }

    // Wired method to fetch the activity list from the Apex controller
    @wire(getCaseTimeline, { caseId: '$recordId' })
    wiredActivities(result) {
        this.wiredActivitiesResult = result; 
        if (result.data) {
            this.activities = result.data;
        } else if (result.error) {
            console.error('Error fetching timeline data', result.error);
        }
    }

    // Runs when the component is inserted into the DOM
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    // Subscribes to the Lightning Message Channel for custom component updates
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                CASE_MC,
                (message) => this.handleMessage(message)
            );
        }
    }

    // Refreshes the timeline if the broadcasted Record ID matches the current one
    handleMessage(message) {
        if (message.recordId === this.recordId) {
            return refreshApex(this.wiredActivitiesResult);
        }
        return null;
    }
}