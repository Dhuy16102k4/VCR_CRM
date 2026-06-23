const fs = require('fs');
const path = require('path');
const file = path.join(__dirname, 'project', 'force-app', 'main', 'default', 'objects', 'Rental_Plan__c', 'fields', 'RO_Name__c.field-meta.xml.bak');
if (fs.existsSync(file)) {
    fs.unlinkSync(file);
    console.log('Deleted ' + file);
} else {
    console.log('File not found: ' + file);
}
