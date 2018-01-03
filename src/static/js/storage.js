import * as Constants from './constants';


export class Storage {

    constructor() {
        console.log('Initialize Storage...');
        this._pouchDB = require('pouchdb-browser').default;
        this._remoteOptions = { skip_setup: true };
        this.remote = new this._pouchDB(Constants.dbUrl, this._remoteOptions);
        this.local = new this._pouchDB(Constants.dbName);
        this.local.sync(this.remote, { live: true, retry: true }).on('error', console.error.bind(console));
        console.log('Initialize Storage... DONE', this);
    }

}
