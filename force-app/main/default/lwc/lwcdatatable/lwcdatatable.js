import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import listForLightningWithColumns from '@salesforce/apex/dataTableController.listForLightningWithColumns';
import actionForLightning from '@salesforce/apex/dataTableController.actionForLightning';
import togglePerms from '@salesforce/apex/dataTableController.togglePerms';

const columns = [];

export default class Lwcdatatable extends LightningElement {

    @api recordId;
    @api records;
    @api columns = columns;
    @api removedFields = [];
    @track removedColumns;
    @api flowNameLookup;
    @api fsName = 'Long Form';
    @api titleString;
    @api fActions = 'none';
    @track error;
    @api buttonLabel;

    connectedCallback() {
        this.titleString = "Active Contacts";
        this.getData();
        // debugger;
    }

    getData() {
        listForLightningWithColumns({ flowName: this.flowNameLookup, recordId: this.recordId, fieldsetName: this.fsName, fActions: this.fActions }).
        then(result => {
            debugger;
            result = this.handleData(result);
            if (result) {
                this.records = result.records;
                this.columns = result.columns;
                const removedFieldsMap = result.removedFields;
                this.removedFields = [];
                for (const key in removedFieldsMap) {
                    if (removedFieldsMap.hasOwnProperty(key)) {
                        const removedField = removedFieldsMap[key];
                        for (let i = 0; i < removedField.length; i++)  { //removedField.forEach(rf => {
                            this.removedFields.push( { index: i, object: key, field: removedField[i] })
                        }
                    }
                }
                const cols = [ { 
                    label: 'SObject', 
                    fieldName: 'object', 
                    type: 'text',
                    cellAttributes: {
                        class: "redhead"
                    }
                },
                { 
                    label: 'Field', 
                    fieldName: 'field', 
                    type: 'text',
                    cellAttributes: {
                        class: "redhead",
                        id: 'dave'
                    } 
                }];
                //this.removedFields = removedFields;
                this.removedColumns = cols;
                if (!this.removedFields || this.removedFields.size === 0) {
                    this.titleString = 'Active Contact List (Permset Assigned)';
                    this.buttonLabel = 'Remove Permset';
                } else {
                    this.titleString = 'Active Contact List (Permset Not Assigned)';
                    this.buttonLabel = 'Assign Permset';
                }

            } else {
                this.error = result.error;
            }
        }).catch(e => {
            console.log(e);
        });
    }

    reloadTable() {
        this.getData();
    }

    togglePerms() {
        togglePerms().
        then(result => {
            var permsetResult = result;
            const variant = (permsetResult === 'removed') ? 'warning' : 'success';
            const event = new ShowToastEvent({
                title: 'Permset Change',
                message: 'You have just ' + permsetResult + ' the permset for this user',
                variant: variant
            });
            this.dispatchEvent(event);
            this.columns = permsetResult;
            this.getData();
        }).
        catch(e => {
            console.log(e);
        });
    }

    handleData(data) {
        return JSON.parse(data);
    }

    /*@wire(listForLightningWithColumns, { flowName: this.flowNameLookup, recordId: this.recordId, fieldsetName: this.fsName, fActions: this.fActions })
    gotData({ error, data }) {
        debugger;
        data = JSON.parse(data);
        if (data) {
            this.records = data.records;
            this.columns = data.columns;
            this.removedFields = data.removedFields;
        } else {
            this.error = error;
        }
    }*/

    doAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        actionForLightning(action.name, row.Id)
        /*var action = component.get('c.actionForLightning');
        action.setParams({
            recordId : component.get('v.recordId'),
            selectedRecordId : event.getParam('row').Id,
            flowName : event.getParam('action').name
        });
        action.setCallback(this, $A.getCallback(function (response) {
        	var state = response.getState();
            if(state === "SUCCESS"){
            	component.set('v.records',response.getReturnValue());
        		this.getData(component);
        	} else if (state === "ERROR") {
                var errors = response.getError();
                console.error(errors);
            }
    	}));
    	$A.enqueueAction(action);*/
    }

}