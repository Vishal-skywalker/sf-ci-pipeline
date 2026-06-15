import { LightningElement, api } from 'lwc';
import COMMUNITY_BASE_PATH from '@salesforce/community/basePath';

export default class MockAPIResourceCard extends LightningElement {
    
    @api resource = {}

    get resourceLink() {
        return COMMUNITY_BASE_PATH + '/resource?appId=' + this.resource.AppID__c;
    }

}