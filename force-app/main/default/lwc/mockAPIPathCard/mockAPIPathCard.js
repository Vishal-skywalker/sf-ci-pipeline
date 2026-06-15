import { LightningElement, api } from 'lwc';
import Update from '@salesforce/label/c.Update';
import Delete from '@salesforce/label/c.Delete';
import CopySuccess from '@salesforce/label/c.CopySuccess';
import UpdateSuccess from '@salesforce/label/c.UpdateSuccess';
import DeleteSuccess from '@salesforce/label/c.DeleteSuccess';
import deletePath from '@salesforce/apex/MockAPIPathCardController.deletePath';
import upsertPath from '@salesforce/apex/MockAPIPathCardController.upsertPath';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class MockAPIPathCard extends LightningElement {
    @api path = {}

    labels = {
        Update,
        Delete,
        CopySuccess,
        UpdateSuccess,
        DeleteSuccess,
    }

    handleDelete() {
        if (this.path.Id) {
            deletePath({ pathId: this.path.Id })
                .then(() => {
                    this.dispatchEvent(new CustomEvent('delete', { detail: this.path.Id }));
                    this.toast(this.labels.DeleteSuccess, 'success');
                })
                .catch((error) => {
                    console.error('Error deleting path:', error);
                });
        }
    }

    handleUpdate() {
        const path = { ...this.path };
        const fields = this.template.querySelector('lightning-record-edit-form').querySelectorAll('lightning-input-field');
        fields.forEach(field => {
            path[field.fieldName] = field.value;
        });
        upsertPath({ path })
            .then((data) => {
                if (data) {
                    this.path = data;
                    this.dispatchEvent(new CustomEvent('update', { detail: this.path }));
                    this.toast(this.labels.UpdateSuccess, 'success');
                }
            })
            .catch((error) => {
                console.error('Error updating path:', error);
            });
    }

    copyPath() {
        const url = this.path.Resource__r.RequestURL__c + this.path.Path__c;
        navigator.clipboard.writeText(url);
        this.toast(this.labels.CopySuccess, 'success');
    }

    toast(message, variant) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
}