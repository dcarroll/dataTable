# dataTable Sample App

## What does this Sample App demonstrate?
The purpose of this app is to demonstrate how you can create flows that can be called by Apex, generally in the context of Lightning Components, such that an Admin has control over portions of the logic and the UI for that Lightning Component.  It provides that control by use of input and output variables in Flows that can be set and consumed by Apex, use of Custom Metadata to control execution and loose coupling of Flows within the Apex Code.


## Installation
You can install this sample using Salesforce DX. Simply clone this repo and then, assuming you have the CLI installed and have a Dev Hub org configured to be a default Dev Hub, run the setup.sh script from the dataTable directory that was created from the clone process.

Once the script has run and the new org is open in the browser, launch the Sales app from the App Picker menu and navigate to any Opportunity record.

There is a Lightning Component in the code called dataTable that you can to your Opportunity record page.  Once on the page, set the Field Set property to either `Short Form` or `Long Form` and activate then save the changes.

![Image of Opportunity](/images/screenshot-73.png)

## How it works
### Rendering The Data Table
The Lightning component uses a dataTable component to render the data.  The dataTable requires a dataset and also column definitions.  The Apex controller uses a utility class that takes in a set of records and emits an object that contains supplemented records and column definitions.

The utility scans the records set and uses the describe information for the SObject type to determine the column defintion, including if it is a namefield that should link to the record home and if it is a reference field that should link to a parent record.  If it is parent, then the parent object is queried to get it's name field and a virtual field is create on the dataset to contain the name such that the Id for the parent is hidden, but the link still works.

### Using Fieldsets
For this sample, field sets drive what is displayed in the datatable and Flows determine the records that are displyed.  This means the all that need be returned from the flow is a collection of SObjects with just the Id present on the SObjects.  

Once the Flow returns the list of SObjects, a query is generated for the SObject use the field set to determine the values for the SELECT clause.  The criteria for the filter use the IN operated and the list of ids to determine the records to return.

This makes the Flow simpler and not tied to a particular UI experience, the Lightning component handles that.

## Some things to try
Modify the `activeContacts_Opportunity` flow to use different criteria in the Lookup.

Modify the `Long Form` or `Short Form` field sets.

Try putting the `dataTable` Lightning Component on a Case record page.

Add some custom fields to the contact object and then add to one of the Field Sets.

Create your own flow that does some other type of action, maybe send an email?

## Things to Inspect
Check out the Apex code to create picklists out of Metadata or Custom Metadata.
```
global class FieldSetPickList extends VisualEditor.DynamicPickList {
    private VisualEditor.DataRow defaultValue;
    private VisualEditor.DynamicPickListRows myValues;
    
    global override VisualEditor.DataRow getDefaultValue(){
        return defaultValue;
    }

    private Map<String, Schema.FieldSet> getFieldSets() {
        Schema.DescribeSObjectResult d = Contact.sObjectType.getDescribe();
        return d.fieldSets.getMap();
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues = new VisualEditor.DynamicPickListRows();
        Map<String, Schema.FieldSet> fieldSets = this.getFieldSets();
        for (String key : fieldSets.keySet()) {
            Schema.FieldSet fs = fieldSets.get(key);
            myValues.addRow(new VisualEditor.DataRow(fs.label, fs.name));
        }
        return myValues;
    }
}
```

Check out the Apex code that runs any Flow that you put into the Lightning Component.
```
    @auraEnabled
    public static String listForLightningWithColumns(String flowName, String recordId, String fieldsetName, string fActions){
        FlowUtility flowUtil = new FlowUtility();
        Flow.Interview flow = Flow.Interview.createInterview(flowName, new MAP<String, Object> {'recordId' => recordId});
        flow.start();
        LIST<SObject> lightningList = (LIST<SObject>) flow.getVariableValue('records');
        FlowUtility.DynamicResults cleanedUp = flowUtil.disassembleSObjects(applyFieldSet(lightningList, fieldsetName), fActions);
        return JSON.serialize(cleanedUp);
    }
```
Check out the [Apex Code](/force-app/main/default/classes/FlowUtility.cls#L3) that takes a `List<SObject>` and generates both a datatable compatible set of data and the columns for that table in `FlowUtility.cls` and figures out the linking for namefields and reference fields.

## Contributors and Thanks
[Rich Englhard](https://github.com/Englhard) - Lightning Comoponent and Flows and Custom Metadata

[Andrew Fawcett](https://github.com/afawcett) - Concepts and Architecture


