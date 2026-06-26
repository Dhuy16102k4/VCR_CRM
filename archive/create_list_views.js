const fs = require('fs');
const path = require('path');

const objects = [
    'Submission_Report__c', 
    'Sales_Activity_Target__c', 
    'Sales_T_3_Achievement_Target__c', 
    'Sales_Advertising_Target__c', 
    'Legal_Record__c', 
    'Legal_Record_Rule__c'
];

const xmlContent = `<?xml version="1.0" encoding="UTF-8"?>
<ListView xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>All</fullName>
    <filterScope>Everything</filterScope>
    <label>All</label>
</ListView>`;

objects.forEach(obj => {
    const dir = path.join(__dirname, 'project', 'force-app', 'main', 'default', 'objects', obj, 'listViews');
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
    }
    const file = path.join(dir, 'All.listView-meta.xml');
    fs.writeFileSync(file, xmlContent);
    console.log('Created All list view for ' + obj);
});
