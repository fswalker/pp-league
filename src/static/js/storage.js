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
            .then(this._getUserDetails.bind(this))
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
            .then(this._getUserCtx)
            .then(this._getUserDetails.bind(this))
            .then(successFn)
            .catch(failureFn);
    }

    _getUserDetails(user) {
        console.log('_getUserDetails', this, user);
        if (user && user.name) {
            return this.local.find({
                selector: {
                    _id: user && user.name
                }
            })
            .then(result => {
                const details = this._getSingleDoc(result);
                console.log('_getUserDetails result', details);
                return this._mergeUser(user, details);
            });
        }
        else {
            return user;
        }
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
        const getSingleDoc = this._getSingleDoc.bind(this);
        return this.local.find({
            selector: {
                type: 'round',
                active: true
              }
        }).then(r => {
            successFn(getSingleDoc(r));
        })
          .catch(failureFn);
    }

    // session is an object returned from getSession method in PouchDB authentication plugin
    _getUserCtx(session) {
        return session && session.userCtx;
    }

    _getSingleDoc(result) {
        return result && result.docs && result.docs[0];
    }

    _mergeUser(user, details) {
        const userDetails = {};
        userDetails.name = user && user.name;
        userDetails.roles = (user && user.roles) || [];
        userDetails.nick = details && details.nick;
        userDetails.league_id = details && details.league_id;
        return userDetails;
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
