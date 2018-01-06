import * as Storage from './storage';

export class WebappPorts {

    constructor(elm) {
        console.log('Initialize WebappPorts...');
        this.app = elm;
    }

    init() {
        const app = this.app;
        console.log('init', app);
    }

}
