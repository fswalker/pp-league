import * as Storage from './storage';

export class WebappPorts {

    constructor(elm, storage) {
        this.app = elm;
        this.storage = storage;
    }

    initGetSession() {
        const okHandler = (session) => {
            console.log('gotSession', session, this);
            this.app.ports.updateSession.send(session);
        };
        const errHandler = (err) => {
            console.error('getSession error', err);
            // call port - abort?? retry?
        };
        this.app.ports.getSession.subscribe(() => {
            this.storage.getSession(okHandler, errHandler);
        });
    }

    initLogIn() {
        const okHandler = (session) => {
            console.log('logIn', session, this);
            this.app.ports.updateSession.send(session);
        };
        const errHandler = (err) => {
            console.error('logIn error', err);
            // call port - abort?? retry?
        };
        this.app.ports.logIn.subscribe((credentials) => {
            this.storage.logIn(credentials, okHandler, errHandler);
        });
    }

    initLogOut() {
        const okHandler = (response) => {
            console.log('logOut', response, this);
            this.app.ports.updateSession.send(null);
        };
        const errHandler = (err) => {
            console.error('logOut error', err);
            // call port - abort?? retry?
        };
        this.app.ports.logOut.subscribe(() => {
            this.storage.logOut(okHandler, errHandler);
        });
    }

    initGetActiveRound() {
        const okHandler = (response) => {
            console.log('GetActiveRound', response, this);
            this.app.ports.updateActiveRound.send(response);
        };
        const errHandler = (err) => {
            console.error('GetActiveRound error', err);
            // call port - abort?? retry?
        };
        this.app.ports.getActiveRound.subscribe(() => {
            this.storage.getActiveRound(okHandler, errHandler);
        });
    }

    init() {
        this.initLogIn();        
        this.initLogOut();
        this.initGetSession();        
        this.initGetActiveRound();        
    }

}
