import { LightningElement } from 'lwc';

export default class CaseFilters extends LightningElement {

    filters = {
    status: '',
    priority: '',
    recordTypeId: '',  // Changed from recordType
    myCasesOnly: false
};

    statusOptions = [
        { label: 'New', value: 'New' },
        {label: 'In Triage', value: 'In_Triage'},
        {label: 'Waiting on External', value: 'Waiting_on_External'},
        { label: 'In Progress', value: 'In_Progress' },
        {label: 'Resolved', value: 'Resolved'},
        { label: 'Closed', value: 'Closed' }
    ];

    priorityOptions = [
        { label: 'Low', value: 'Low' },
        { label: 'Medium', value: 'Medium' },
        { label: 'High', value: 'High' }
    ];

  recordTypeOptions = [
    {label: 'Housing', value: '012fj0000047QUvAAM'},  // Use actual RecordTypeId
    {label: 'Nutrition', value: '012fj0000047QY9AAM'},
    {label: 'Medical', value: '012fj0000047QTJAA2'}
]

    handleChange(event) {
        const field = event.target.dataset.field;

        this.filters = {
            ...this.filters,
            [field]: event.detail.value
        };

        this.notify();
    }

    handleCheckbox(event) {
        this.filters = {
            ...this.filters,
            myCasesOnly: event.target.checked
        };

        this.notify();
    }

    notify() {
        this.dispatchEvent(
            new CustomEvent('filterchange', {
                detail: { ...this.filters }
            })
        );
    }
}