global class FieldSetPickList extends VisualEditor.DynamicPickList {
    private VisualEditor.DataRow defaultValue;
    private VisualEditor.DynamicPickListRows myValues;
    
    global override VisualEditor.DataRow getDefaultValue(){
        return defaultValue;
    }

    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  myValues = new VisualEditor.DynamicPickListRows();
        myValues = new VisualEditor.DynamicPickListRows();
        for (Field_Set_DT__mdt fieldSet : [Select DeveloperName, MasterLabel From Field_Set_DT__mdt]) {
            myValues.addRow(new VisualEditor.DataRow(fieldSet.MasterLabel, fieldSet.DeveloperName));
        }
        return myValues;
    }
}
