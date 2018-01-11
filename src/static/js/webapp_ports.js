import * as Storage from './storage';

export class WebappPorts {

    constructor(elm, storage) {
        this.app = elm;
        this.storage = storage;
    }

    initGetSession() {
        const okHandler = (session) => {
            console.log('gotSession', session, this);
            this.app.ports.updateSession.send(session && session.userCtx);
        };
        const errHandler = (err) => {
            console.error('getSession error', err);
            // TODO call port - abort?? retry?
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
            // TODO call port - abort?? retry?
        };
        this.app.ports.logIn.subscribe((credentials) => {
            this.storage.logIn(credentials, okHandler, errHandler);
        });
    }

    initLogOut() {
        const okHandler = (response) => {
            console.log('logOut', response, this);
            // this.app.ports.updateSession.send(session);
        };
        const errHandler = (err) => {
            console.error('logOut error', err);
            // TODO call port - abort?? retry?
        };
        this.app.ports.logOut.subscribe(() => {
            this.storage.logOut(okHandler, errHandler);
        });
    }

    init() {
        this.initGetSession();        
        this.initLogIn();        
        this.initLogOut();
    }

}
