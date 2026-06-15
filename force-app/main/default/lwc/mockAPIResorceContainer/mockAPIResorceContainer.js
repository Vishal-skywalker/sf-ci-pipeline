import { LightningElement } from 'lwc';
import { labels } from './labels';
import getResourcesByEmail from '@salesforce/apex/MockAPIResourceController.getResourcesByEmail';
import COMMUNITY_BASE_PATH from '@salesforce/community/basePath';

export default class MockAPIResorceContainer extends LightningElement {

    labels = labels;
    email = '';
    resourceList = [];

    connectedCallback() {
    }

    handleNewMockAPIResource() {
        window.open(COMMUNITY_BASE_PATH + '/resource', '_self');
    }

    handleEmailChange(e) {
        if (e.target.value) {
            this.email = e.target.value.trim();
        }
    }

    async findMockAPIResource() {
        if (this.email) {
            const response = await getResourcesByEmail({ email: this.email }).catch(error => {
                console.error('Error fetching resources:', error);
            });
            if (response) {
                this.resourceList = [...response];
            }
        }
    }
}