import { LightningElement, track, wire } from 'lwc';
import RESOURCE_OBJECT from '@salesforce/schema/Resource__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import COMMUNITY_BASE_PATH from '@salesforce/community/basePath';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Apex controllers
import getResource from '@salesforce/apex/MockAPIResourceController.getResource';
import upsertResource from '@salesforce/apex/MockAPIResourceController.upsertResource';
import deleteResource from '@salesforce/apex/MockAPIResourceController.deleteResource';
import upsertPath from '@salesforce/apex/MockAPIPathCardController.upsertPath';

// Labels
import CreateNew from '@salesforce/label/c.CreateNew';
import Edit from '@salesforce/label/c.Edit';
import Save from '@salesforce/label/c.Save';
import Cancel from '@salesforce/label/c.Cancel';
import RequireAPIKey from '@salesforce/label/c.RequireAPIKey';
import NewPath from '@salesforce/label/c.NewPath';
import Delete from '@salesforce/label/c.Delete';
import UpdateSuccess from '@salesforce/label/c.UpdateSuccess';
import DeleteSuccess from '@salesforce/label/c.DeleteSuccess';


export default class MockAPIResourceDetailPage extends LightningElement {

    recordId;
    @track
    fileds;
    isEdit = false;
    isAPIKeyRequired = false;
    apiKey = '';
    @track
    resource = {}

    get apiKeyDisabled() {
        return !this.isAPIKeyRequired;
    }

    labels = {
        CreateNew,
        Edit,
        Save,
        Cancel,
        RequireAPIKey,
        NewPath,
        Delete,
        UpdateSuccess,
        DeleteSuccess,
    };

    @wire(getObjectInfo, { objectApiName: RESOURCE_OBJECT })
    objInfo({ data, error }) {
        if (data) this.fileds = data.fields;
        if (error) console.error('Error fetching object info:', error);
    }

    async connectedCallback() {
        this.recordId = this.getSearchParameter('appId');
        if (this.recordId) {
            const response = await getResource({ appId: this.recordId }).catch(error => {
                console.error('Error fetching resource:', error);
            });
            if (response) {
                this.resource = response;
                this.isAPIKeyRequired = this.resource.APIKey__c ? true : false;
                this.apiKey = this.resource.APIKey__c ? this.resource.APIKey__c : '';
                this.isEdit = false;
            } else {
                window.open(COMMUNITY_BASE_PATH + '/resource', '_self');
            }
        } else {
            this.isEdit = true;
        }
    }

    getSearchParameter(key) {
        const searchParams = new URLSearchParams(window.location.search);
        return searchParams.get(key) ?? null;
    }


    async handleSave() {
        const fields = this.template.querySelector('lightning-record-edit-form').querySelectorAll('lightning-input-field');
        fields.forEach(field => {
            this.resource[field.fieldName] = field.value;
        });
        if (!this.resource.Id) {
            this.resource.AppID__c = this.generateGUID();
        }
        const result = await upsertResource({ resource: this.resource }).catch(error => {
            console.error('Error saving resource:', error);
        });
        if (result) {
            this.toast(this.labels.UpdateSuccess, 'success');
            this.resource = result;
            if (!this.recordId) {
                this.recordId = this.resource.AppID__c;
                window.history.replaceState(null, null, '?appId=' + this.recordId);
            }
            this.isEdit = false;
        }
    }

    toast(message, variant) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }

    handleCancel() {
        this.isEdit = false;
    }

    handleEdit() {
        this.isEdit = true;
    }

    generateGUID() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    generateApiKey(length = 32) {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let apiKey = '';
        for (let i = 0; i < length; i++) {
            apiKey += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return apiKey;
    }

    handleAPIKeyCheckbox(e) {
        this.isAPIKeyRequired = e.target.checked;
        if (this.isAPIKeyRequired) {
            this.apiKey = this.generateApiKey();
        } else {
            this.apiKey = '';
        }
    }

    handlePathDelete(e) {
        const pathId = e.detail;
        this.resource.Paths__r = this.resource.Paths__r.filter(path => path.Id !== pathId);
    }

    handleUpdatePath(e) {
        const path = e.detail;
        const index = this.resource.Paths__r.findIndex(p => p.Id === path.Id);
        if (index !== -1) {
            this.resource.Paths__r[index] = { ...path };
        } else {
            this.resource.Paths__r.push({ ...path });
        }
    }

    handleNewPath() {
        const path = {
            Id: null,
            Path__c: 'new-sub-path',
            Method__c: 'GET',
            Resource__c: this.resource.Id,
        };
        upsertPath({ path }).then((data) => {
            if (data) {
                if (!this.resource.Paths__r) {
                    this.resource.Paths__r = [];
                }
                this.resource.Paths__r.splice(0, 0, data);
            }
        }
        ).catch((error) => {
            console.error('Error creating new path:', error);
        });
    }

    handleDelete() {
        deleteResource({ resourceId: this.resource.Id })
            .then(() => {
                this.toast(this.labels.DeleteSuccess, 'success');
                window.open(COMMUNITY_BASE_PATH + '/resource', '_self');
            })
            .catch((error) => {
                console.error('Error deleting resource:', error);
            });
    }
}