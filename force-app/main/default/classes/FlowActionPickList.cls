global class FlowActionPickList extends VisualEditor.DynamicPickList {
    private VisualEditor.DataRow defaultValue;
    private VisualEditor.DynamicPickListRows myValues;
    
    global override VisualEditor.DataRow getDefaultValue(){
        return defaultValue;
    }

    private List<Flow_Action__mdt> getFlowActions() {
        return [Select DeveloperName, MasterLabel From Flow_Action__mdt];
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues = new VisualEditor.DynamicPickListRows();
        for (Flow_Action__mdt lookupFlow : this.getFlowActions()) {
            myValues.addRow(new VisualEditor.DataRow(lookupFlow.MasterLabel, lookupFlow.DeveloperName));
        }
        return myValues;
    }
}
