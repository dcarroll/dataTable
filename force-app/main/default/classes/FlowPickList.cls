global class FlowPickList extends VisualEditor.DynamicPickList{
    private VisualEditor.DataRow defaultValue;
    private VisualEditor.DynamicPickListRows myValues;
    
    global override VisualEditor.DataRow getDefaultValue(){
        return defaultValue;
    }

    private List<LookupFlows__mdt> getLookupFlows() {
        return [Select DeveloperName, MasterLabel From LookupFlows__mdt];
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues = new VisualEditor.DynamicPickListRows();
        for (LookupFlows__mdt lookupFlow : this.getLookupFlows()) {
            myValues.addRow(new VisualEditor.DataRow(lookupFlow.MasterLabel, lookupFlow.DeveloperName));
        }
        return myValues;
    }

}