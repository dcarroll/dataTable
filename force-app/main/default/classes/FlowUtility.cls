public with sharing class FlowUtility {
    
    public DynamicResults disassembleSObjects(List<SObject> sobjects, String fActions) {
        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.READABLE,
            sobjects);
        List<Sobject> objects = decision.getRecords();
        
        Map<String, Set<String>> removedFields = decision.getRemovedFields();
        System.debug('Removed Fields: ' + removedFields);

        Schema.SObjectType objType = objects.getSObjectType();
        Map<String, Schema.SObjectField> fields = objType.getDescribe().fields.getMap();
        List<Object> jsonRecords = toJSONList(objects);

        Map<String, NameField> nameFields = getNameFields(objects[0], fields);
        if (objects.size() > 0) {
            List<Column> cols = getColumns(objects[0], fields);
            List<Map<String, Object>> JSONCols = new List<Map<String, Object>>();
            if (fActions != null) {
                addActionsToColumns(cols, fActions);
            }

            for (Column col : cols) {
                Map<String, Object> jsonCol = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(col));
                if (nameFields.containsKey(col.fieldName)) {
                    // We need to create a fake field in the data so that the column can reference it
                    // We also need to add the reference to those fields in the columns
                    NameField namefield = nameFields.get(col.fieldName);
                    jsonCol.put('typeAttributes', new Map<String, Object>());
                    Map<String, Object> typeAttributes = (Map<String, Object>)jsonCol.get('typeAttributes');
                    typeAttributes.put('label', new Map<String, Object>());
                    Map<String, Object> label = (Map<String, Object>)typeAttributes.get('label');

                    if (namefield.type != 'REFERENCE') {
                        label.put('fieldName', col.fieldName);
                    } else {
                        label.put('fieldName', 'Link_' + col.fieldName + '_Name');
                    }

                    jsonCol.put('fieldName', 'Link_' + col.fieldName);
                    jsonCol.put('type', 'url');
                    this.addLinkFieldToJSONSobjects(jsonRecords, 'Link_' + col.fieldName, namefield);
                    System.debug('jsonRecords:\n' + jsonRecords);
                }
                JSONCols.add(jsonCol);
            }
            this.lookupReferenceNames(jsonRecords, nameFields, JSONCols);
            System.debug(jsonRecords);
            System.debug(JSONCols);
            return new DynamicResults(jsonRecords, JSONCols, removedFields);
        }
        return null;
    }

    public string validateFieldList(string sobjectType, string fieldList) {
        // Get describe for passed in sobject type name
        Schema.DescribeSObjectResult[] descResults = Schema.describeSObjects(new String[]{sobjectType});

        // Convert the fieldlist keys to lower case
        Map<String, String> lcaseFieldList = new Map<String, String>();
        List<String> invalidFields = new List<String>();

        // Make sure that we have valid describe results
        if (descResults != null && descResults.size() > 0) {
            Schema.DescribeSObjectResult descResult = descResults[0];

            // Get a map of the fields on the sobject
            Map<String, Schema.SObjectField> fields = descResult.fields.getMap();

            // Convert to lower case so that we have a case insensitive comparison
            for (String key : fields.keySet()) {
                lcaseFieldList.put(fields.get(key).getDescribe().getName().toLowerCase(), key);
            }

            // Turn the field list to validate into an array
            List<String> flist = fieldList.split(',');

            for (String fname : flist) {
                // Look to see if the field name is a key in the case insensitive map,
                // if it isn't, then add it to the list of invaled fields to be returned
                // to the colling code.
                if (!lcaseFieldList.containsKey(fname.toLowerCase())) {
                    invalidFields.add(fname);
                }
            }
        }
        return JSON.serialize(invalidFields);
    }
    
    // Schema.FieldSetMember[ getDbRequired=false; getFieldPath=AccountId; getLabel=Account ID; getRequired=false; getType=REFERENCE;]
    public List<String> getFieldListFromFieldSet(string sobjectType, string fieldSetName) {
        Schema.DescribeSObjectResult[] descResults = Schema.describeSObjects(new String[]{sobjectType});
        if (descResults.size() > 0) {

            DescribeSObjectResult descResult = descResults[0];
            FieldSet fieldSet = descResult.fieldsets.getMap().get(fieldSetName);
            
            if (fieldSet == null) {
                return null; // '{ error: "Fieldset ' + fieldSetName + ' not found" }';
            } else {
                List<FieldSetMember> fields = fieldSet.getFields();
                List<String> fieldNames = new List<String>();
            
                for (FieldSetMember field : fields) {
                    fieldNames.add(field.fieldpath);
                }
                return fieldNames;
            }
        } else {
            return null;
        }
    }
    
    public List<String> getFieldListFromFieldSetFromSObjectList(List<SObject> sobjects, string fieldSetName) {
        System.debug('getFieldListFromFieldSetFromSObjectList' + sobjects);
        Schema.SObjectType objType = sobjects.getSObjectType();
        return getFieldListFromFieldSet(objType.getDescribe().localname, fieldSetName);
    }

    public void jsonTest() {
        List<SObject> objects = [Select Id, Name, Email From Contact Limit 2];
        System.debug('-  \n\n' + disassembleSObjects(objects, null) + '\n\n');
    }

    private void addFieldToJSONObject(Map<String, Object> jsonObject, String fieldNameToAdd, Object valueToAdd) {
        jsonObject.put(fieldNameToAdd, valueToAdd);
    }

    private string lookupTypeAssociation(Schema.DisplayType t) {
        switch on t {
            when EMAIL {
                return 'email';
            }
            when STRING, TEXTAREA {
                return 'text';
            }
            when DOUBLE {
                return 'number';
            }
            when PHONE {
                return 'phone';
            }
            when DATE, DATETIME {
                return 'date';
            }
            when URL {
                return 'url';
            }
            when LOCATION {
                return 'location';
            }
            when BOOLEAN {
                return 'boolean';
            }
            when else {
                return 'text';
            }
        }
    }
    
    private List<Object> toJSONList(List<SObject> objects) {
        String jsonStringObjects = JSON.serialize(objects);
        List<Object> jsonObjects = (List<Object>)JSON.deserializeUntyped(jsonStringObjects);
        return jsonObjects;
    }

    private Map<String, FlowUtility.NameField> getNameFields(SObject obj, Map<String, Schema.SObjectField> fields) {
        Map<String, Object> flds = obj.getPopulatedFieldsAsMap();
        Map<String, NameField> nameFields = new Map<String, NameField>();
        for (String fieldName : flds.keySet()) {
            // got the fieldname, now need the type
            SObjectField field = fields.get(fieldName);
           	Schema.DescribeFieldResult dfr = field.getDescribe();
            if (dfr.isNameField()) {
                nameFields.put(fieldName, new NameField(dfr.getName(), 'NAMEFIELD', obj.getSObjectType() + ''));
            } else if (dfr.getType() + '' == 'REFERENCE') {
                nameFields.put(fieldName, new NameField(dfr.getName(), dfr.getType() + '', dfr.referenceto[0] + ''));
            }
        }
        return nameFields;
    }
    
    private List<Column> getColumns(SObject obj, Map<String, Schema.SObjectField> fields) {
        Map<String, Object> fieldMap = obj.getPopulatedFieldsAsMap();
        List<Column> cols = new List<Column>();
        for (String fieldName : fieldMap.keySet()) {
            Object f = fieldMap.get(fieldName);
            if (fieldName != 'Id') {
                cols.add(new Column(fieldname, fields.get(fieldName).getDescribe().getLabel(), this.lookupTypeAssociation(fields.get(fieldName).getDescribe().getType()) + ''));
            }
        }
        return cols;
    }

    private void addLinkFieldToJSONSobjects(List<Object> jsonObjects, String field, FlowUtility.NameField nameField) {
        for (Object jsonObject : jsonObjects) {
            String pageReference;
            if (nameField.type == 'REFERENCE') {
                pageReference = '/lightning/r/' + nameField.objectType + '/' + ((Map<String, Object>)jsonObject).get(nameField.name) + '/view';
            } else {
                System.debug('Adding page reference:\n' + jsonObject);
                pageReference = '/lightning/r/' + nameField.objectType + '/' + ((Map<String, Object>)jsonObject).get('Id') + '/view';
            }
            ((Map<String, Object>)jsonObject).put(field, pageReference);
        }
    }

    // Loop over records and look for fields that are name fields.
    // If the field is a name field and a reference, then we need to find the object that
    // is being reference to query later.  We also need to stash the id in and array for that object
    private void lookupReferenceNames(List<Object> jsonObjects, Map<String, NameField> nameFields, List<Map<String, Object>> cols) {
        // Loop through the records getting a map of SObject names and Id to query for
        Map<String, Object> objIdMap = new Map<String, Object>();
        for (Object jsonObject : jsonObjects) {
            // Turn list into map keyed on IDS
            Map<String, Object> jsonMapObject = (Map<String, Object>)jsonObject;
            // Loop over nameFields so that we can pick out the reference fields
            for (String nameFieldName : nameFields.keySet()) { 
                // Grab the object field value for the nameField if the nameField type is REFERENCE
                NameField nf = nameFields.get(nameFieldName);
                if (nf.type == 'REFERENCE') {
                    if (!objIdMap.containsKey(nf.objectType)) {
                        List<String> ids = new List<String>();
                        ids.add(jsonMapObject.get(nf.name) + '');
                        Map<String, Object> objIdItem = new Map<String, Object>();
                        objIdItem.put('ids', ids);
                        objIdItem.put('nameField', nf.name);
                        System.debug('Adding objIdMapItem' + nf.objectType + '\n' + objIdItem);
                        objIdMap.put(nf.objectType, objIdItem);
                    } else {
                        Map<String, Object> objIdItem = (Map<String, Object>)objIdMap.get(nf.objectType);
                        List<String> ids = (List<String>)objIdItem.get('ids');
                        ids.add(jsonMapObject.get(nf.name) + '');
                    }
                }
            }
        }

        for (String objName : objIdMap.keySet()) {            
            Map<String, Object> objIdItem = (Map<String, Object>)objIdMap.get(objName);
            List<String> ids = (List<String>)(objIdItem).get('ids');
            String cleanObjName = objName.removeEnd(')').removeStart('(');
            String soql = 'Select Name, Id From ' + cleanObjName + ' Where Id in (\'' + String.join(ids, '\',\'') + '\')';

            for(SObject obj : Database.query(soql)) {
                // Now, just need to find the right record and add a new column for reference name!
                for(Object jobj : jsonObjects) {
                    Map<String, Object> jobjMap = (Map<String, Object>)jobj;
                    Map<String, Object> tempMap = new Map<String, Object>();
                    if (jobjMap.get('Id') == obj.Id) {
                        String nfld = (String)objIdItem.get('nameField');
                        tempMap.put('Link_' + nfld, obj.get((String)objIdItem.get('nameField')));
                        System.debug('TempMap:\n' + tempMap);
                        jobjMap.put('Link_' + nfld, obj.get((String)objIdItem.get('nameField')));
                    } else {
                        System.debug('This must be a reference field. \n' + obj.Id);
                        System.debug('What os the nfld? \n' + (String)objIdItem.get('nameField'));
                        tempMap.put('Link_' + (String)objIdItem.get('nameField') + '_Name', obj.get('Name'));
                        System.debug('TempMap:\n' + tempMap);
                        jobjMap.put('Link_' + (String)objIdItem.get('nameField') + '_Name', obj.get('Name'));
                    }
                }
            }
        }
    }

    private void addActionsToColumns(List<Column> columns, String fActions) {
        if(fActions != Null){
            LIST<String> flowActions = fActions.split(',');
            system.debug(flowActions);
            FlowUtility.Column c = new FlowUtility.Column(null, null, 'action');
            c.typeAttributes = new Map<String, Object>();
            List<Map<String, String>> rowActions = new List<Map<String, String>>();
            for(Flow_Action__mdt fa: [SELECT DeveloperName,MasterLabel FROM Flow_Action__mdt WHERE DeveloperName in: flowActions]){
                rowActions.add(new Map<String, String> { 'label' => fa.MasterLabel, 'name' => fa.DeveloperName });
            }
            ((Map<String, Object>)c.typeAttributes).put('rowActions', rowActions);
            columns.add(c);
        }else{
            return;
        }
    }
    
    public class Column {
        String fieldName;
        String label;
        String type;
        Object typeAttributes;

        private Column(String fldName, String lbl, String fldType) {
            fieldName = fldName;
            label = lbl;
            type = fldType;
        }
    }

    public class CustomError {
        String error;

        public CustomError(String msg) {
            error = msg;
        }
    }
  
    public class DynamicResults {
        List<Object> records = new List<Object>();
        List<Map<String, Object>> columns = new List<Map<String, Object>>();
        Map<String, Set<String>> removedFields = new Map<String, Set<String>>();
        CustomError error;

        private DynamicResults(List<Object> recs, List<Map<String, Object>> cols, Map<String, Set<String>> removedFlds) {
            records = recs;
            columns = cols;
            removedFields = removedFlds;
        }
    }
    
    private class NameField {
        String name;
        String type;
        string objectType;

        private NameField(String n, String t, String sobjType) {
            name = n;
            type = t;
            objectType = sobjType;
        }
    }    
}