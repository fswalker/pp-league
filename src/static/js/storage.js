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
        this.local.sync(this.remote, { live: true, retry: true }).on('error', err => console.error('Sync error', err));
        this._createIndexes();
        // this.test();
    }

    // TODO make createIndex public and return promise
    // Call rest of the index.js inside then??

    _createIndexes() {
        this._createActiveRoundIndex();
        this._createLeagueRoundIndex();
        this._createLeaguePlayersIndex();
    }

    _createActiveRoundIndex() {
        return this._createIndex({
            fields: [ 'type', 'active' ],
            name: 'indexTypeActive',
            ddoc: 'index_type_active'
        });
    }

    _createLeagueRoundIndex() {
        return this._createIndex({
            fields: [ 'type', 'league_id', 'round_id' ],
            name: 'indexTypeLeagueRound',
            ddoc: 'index_type_league_round'
        });
    }

    _createLeaguePlayersIndex() {
        return this._createIndex({
            fields: [ 'type', 'league_id' ],
            name: 'indexTypeLeague',
            ddoc: 'index_type_league'
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

    getUsers(successFn, failureFn) {
        console.log('getUsers', this, successFn, failureFn);
        return this.local.find({
            selector: {
                type: 'player'
              }
            })
            .then(successFn)
            .catch(failureFn);
    }

    getLeaguePlayers(league_id, successFn, failureFn) {
        console.log('getLeaguePlayers', league_id, this, successFn, failureFn);
        return this.local.find({
            selector: {
                type: 'player',
                league_id: league_id
              }
            })
            .then(successFn)
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

    getScores(league_id, round_id, successFn, failureFn) {
        console.log('getScores', league_id, round_id, this, successFn, failureFn);
        return this.local.find({
            selector: {
                type: 'score',
                league_id: league_id,
                round_id: round_id
              }
            })
            .then(successFn)
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
        // this.getActiveRound(okFn, errFn);
        this.getUsers(okFn, errFn);
        this.getLeaguePlayers('16a596e5b990d9e498f93fbc94007e2a', okFn, errFn);

    }

}
