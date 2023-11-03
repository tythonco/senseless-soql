import { LightningElement } from 'lwc';

import findTabDefinitionByDurableId from '@salesforce/apex/SenselessSOQL.findTabDefinitionByDurableId';
import findTabDefinitionBySObjectName from '@salesforce/apex/SenselessSOQL.findTabDefinitionBySObjectName';

export default class SenselessSOQL extends LightningElement {

    _msg;

    get msg() {
        return this._msg;
    }
    set msg(val) {
        this._msg = val;
    }

    connectedCallback() {
        this.init();
    }

    handleRerun() {
        this.msg = null;
        this.init();
    }

    async init() {
        try {
            let log = await findTabDefinitionByDurableId();
            log += await findTabDefinitionBySObjectName();
            this.msg = log;
        } catch(e) {
            console.error(e);
        }
    }
}
