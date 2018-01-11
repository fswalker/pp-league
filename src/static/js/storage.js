import * as Constants from './constants';

const pouchDB = require('pouchdb-browser').default;
const pouchDbPlugin = require('pouchdb-authentication').default;
pouchDB.plugin(pouchDbPlugin);

export class Storage {

    constructor() {
        const remoteOptions = { skip_setup: true };
        this.remote = new pouchDB(Constants.dbUrl, remoteOptions);
        this.local = new pouchDB(Constants.dbName);
        this.local.sync(this.remote, { live: true, retry: true }).on('error', console.error.bind(console));
    }

    getSession(successFn, failureFn) {
        console.log('getSession', this, successFn, failureFn);
        return this.remote.getSession()
            .then(successFn)
            .catch(failureFn);
    }

    getUser(user, successFn, failureFn) {
        console.log('getUser', this, user, successFn, failureFn);
        return this.remote.getUser(user)
            .then(successFn)
            .catch(failureFn);
    }

    // TODO remove once testing is finished
    test() {
        // this.remote.getSession().then(x => console.log('ok', x)).catch(e => console.error('err', e));
        // return;
        const okFn = (r) => console.log('ok', r);
        const errFn = (e) => console.log('error', e);
        this.getSession(okFn, errFn);
    }

}
