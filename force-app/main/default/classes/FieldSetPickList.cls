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
        // Schema.DescribeFieldResult p = PickTest__mdt.Flows__c.getDescribe();
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
