# dataTable Sample App

## What does this Sample App demonstrate?
The purpose of this app is to demonstrate how you can create flows that can be called by Apex, generally in the context of Lightning Components, such that an Admin has control over portions of the logic and the UI for that Lightning Component.  It provides that control by use of input and output variables in Flows that can be set and consumed by Apex, use of Custom Metadata to control execution and loose coupling of Flows within the Apex Code.


## Installation
You can install this sample using Salesforce DX. Simply clone this repo and then, assuming you have the CLI installed and have a Dev Hub org configured to be a default Dev Hub, run the setup.sh script from the dataTable directory that was created from the clone process.

Once the script has run and the new org is open in the browser, launch the Sales app from the App Picker menu and navigate to any Opportunity record.

There is a Lightning Component in the code called dataTable that you can to your Opportunity record page.  Once on the page, set the Field Set property to either `Short Form` or `Long Form` and activate then save the changes.


