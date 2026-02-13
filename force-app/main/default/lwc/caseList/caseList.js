import { LightningElement, api, wire } from 'lwc';
import getCases from '@salesforce/apex/CaseConsoleController.getCases';

export default class CaseList extends LightningElement {

    @api filters = {};
    cases;
    error;

    columns = [
        { label: 'Case #', fieldName: 'CaseNumber' },
        { label: 'Subject', fieldName: 'Subject' },
        { label: 'Status', fieldName: 'Status' },
        { label: 'Priority', fieldName: 'Priority' },
        {
            type: 'button',
            typeAttributes: {
                label: 'View',
                name: 'view'
            }
        }
    ];

    // Convert empty strings to null for wire parameters
    get wireStatus() {
        return this.filters.status || null;
    }

    get wirePriority() {
        return this.filters.priority || null;
    }

    get wireRecordTypeId() {
        return this.filters.recordTypeId || null;
    }

    get wireMyCasesOnly() {
        return this.filters.myCasesOnly || false;
    }

    @wire(getCases, {
        status: '$wireStatus',
        priority: '$wirePriority',
        recordTypeId: '$wireRecordTypeId',
        myCasesOnly: '$wireMyCasesOnly'
    })
    wiredCases({ data, error }) {
        console.log('=== WIRE FIRED ===');
        console.log('Filters:', JSON.stringify(this.filters));
        
        if (data) {
            console.log('✅ Data received:', data.length, 'cases');
            console.log('Cases:', JSON.stringify(data));
            this.cases = data;
            this.error = undefined;
        } else if (error) {
            console.log('❌ Error:', JSON.stringify(error));
            this.error = error;
            this.cases = undefined;
        } else {
            console.log('⚠️ No data and no error - wire not provisioned yet');
        }
    }

    handleRowAction(event) {
        if (event.detail.action.name === 'view') {
            this.dispatchEvent(
                new CustomEvent('caseselect', {
                    detail: event.detail.row.Id
                })
            );
        }
    }
}