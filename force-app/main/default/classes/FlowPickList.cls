global class FlowPickList extends VisualEditor.DynamicPickList{
    private VisualEditor.DataRow defaultValue;
    private VisualEditor.DynamicPickListRows myValues;
    
    global override VisualEditor.DataRow getDefaultValue(){
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues = new VisualEditor.DynamicPickListRows();
        for (LookupFlows__mdt lookupFlow : [Select DeveloperName, MasterLabel From LookupFlows__mdt]) {
            myValues.addRow(new VisualEditor.DataRow(lookupFlow.MasterLabel, lookupFlow.DeveloperName));
        }
        return myValues;
    }

}