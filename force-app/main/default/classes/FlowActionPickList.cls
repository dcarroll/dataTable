global class FlowActionPickList extends VisualEditor.DynamicPickList {
    private VisualEditor.DataRow defaultValue;
    private VisualEditor.DynamicPickListRows myValues;
    
    global override VisualEditor.DataRow getDefaultValue(){
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues = new VisualEditor.DynamicPickListRows();
        for (Flow_Action__mdt actionFlow : [Select DeveloperName, MasterLabel From Flow_Action__mdt]) {
            myValues.addRow(new VisualEditor.DataRow(actionFlow.MasterLabel, actionFlow.DeveloperName));
        }
        return myValues;
    }
}
