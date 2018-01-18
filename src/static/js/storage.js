import * as Constants from './constants';

const pouchDB = require('pouchdb-browser').default;
const pouchDbAuthPlugin = require('pouchdb-authentication').default;
pouchDB.plugin(pouchDbAuthPlugin);
const pouchDbFindPlugin = require('pouchdb-find').default;
pouchDB.plugin(pouchDbFindPlugin);

export class Storage {

    constructor() {
        const remoteOptions = { skip_setup: true };
        this.remote = new pouchDB(Constants.dbUrl, remoteOptions);
        this.local = new pouchDB(Constants.dbName);
        this.local.sync(this.remote, { live: true, retry: true }).on('error', console.error.bind(console));
        this._createIndexes();
        // this.test();
    }

    _createIndexes() {
        this._createActiveRoundIndex();
    }

    _createActiveRoundIndex() {
        return this._createIndex({
            fields: [ 'type', 'active' ],
            name: 'indexTypeActive',
            ddoc: 'index_type_active'
        });
    }

    _createIndex(index) {
        return this.local.createIndex({
            index: index
        }).then(() => {
            console.log('Created index', index && index.name);
        }).catch((err) => {
            console.error('Error when creating index', index && index.name, err);
        });
    }

    logIn({ login, password }, successFn, failureFn) {
        console.log('login', this);
        return this.remote.logIn(login, password)
            .then(successFn)
            .catch(failureFn);
    }

    logOut(successFn, failureFn) {
        console.log('logout', this);
        return this.remote.logOut()
            .then(successFn)
            .catch(failureFn);
    }

    getSession(successFn, failureFn) {
        console.log('getSession', this, successFn, failureFn);
        return this.remote.getSession()
            .then(successFn)
            .catch(failureFn);
    }

    // TODO is it required after extending user session?
    getUser(user, successFn, failureFn) {
        console.log('getUser', this, user, successFn, failureFn);
        return this.remote.getUser(user)
            // .then(successFn)
            .then((r) => console.log('internal getUser', r))
            .catch(failureFn);
    }

    // TODO
    getUsers(successFn, failureFn) {
        console.log('getUsers', this, successFn, failureFn);
        return this.remote.getUser(user)
            // .then(successFn)
            .then((r) => console.log('internal getUser', r))
            .catch(failureFn);
    }

    getActiveRound(successFn, failureFn) {
        return this.local.find({
            selector: {
                type: 'round',
                active: true
              }
        }).then(r => {
            var data = r && r.docs && r.docs[0];
            successFn(data);
        })
          .catch(failureFn);
    }

    // TODO remove once testing is finished
    test() {
        // this.remote.getSession().then(x => console.log('ok', x)).catch(e => console.error('err', e));
        // return;
        const okFn = (r) => console.log('ok', r);
        const errFn = (e) => console.log('error', e);
        // this.getSession(okFn, errFn);
        this.getActiveRound(okFn, errFn);
    }

}
