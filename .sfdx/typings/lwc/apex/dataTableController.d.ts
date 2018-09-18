declare module "@salesforce/apex/dataTableController.listForLightning" {
  export default function listForLightning(param: {flowName: any, recordId: any}): Promise<any>;
}
declare module "@salesforce/apex/dataTableController.listForLightningWithColumns" {
  export default function listForLightningWithColumns(param: {flowName: any, recordId: any, fieldsetName: any, fActions: any}): Promise<any>;
}
declare module "@salesforce/apex/dataTableController.actionForLightning" {
  export default function actionForLightning(param: {flowName: any, recordId: any, selectedRecordId: any}): Promise<any>;
}
declare module "@salesforce/apex/dataTableController.getFieldsFromFieldSet" {
  export default function getFieldsFromFieldSet(param: {fsName: any, oName: any, fActions: any}): Promise<any>;
}
