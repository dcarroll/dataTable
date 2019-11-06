import { LightningElement, wire, track } from 'lwc';
import listForLightningWithColumns from '@salesforce/apex/dataTableController.listForLightningWithColumns';
import actionForLightning from '@salesforce/apex/dataTableController.actionForLightning';

const columns = [];

export default class Lwcdatatable extends LightningElement {

    @track
    records = [];
    @track
    columns = columns;

    @wire(listForLightningWithColumns, { flowName: '', recordId: '', fieldsetName: '', fActions: '' })
    getData(result) {
        this.records = result.records;
        this.columns = result.columns;
    }

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