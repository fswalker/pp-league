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

    initGetLeaguePlayers() {
        const okHandler = (response) => {
            console.log('GetLeaguePlayers', response, this);
            this.app.ports.updateLeaguePlayers.send(response && response.docs);
        };
        const errHandler = (err) => {
            console.error('GetLeaguePlayers error', err);
            // call port - abort?? retry?
        };
        this.app.ports.getLeaguePlayers.subscribe((league_id) => {
            this.storage.getLeaguePlayers(league_id, okHandler, errHandler);
        });
    }

    initGetLeague() {
        const okHandler = (response) => {
            console.log('GetLeague', response, this);
            this.app.ports.updateLeague.send(
                response
                && response.docs
                && response.docs.length > 0
                && response.docs[0]
            );
        };
        const errHandler = (err) => {
            console.error('GetLeague error', err);
            // call port - abort?? retry?
        };
        this.app.ports.getLeague.subscribe((league_id) => {
            this.storage.getLeague(league_id, okHandler, errHandler);
        });
    }

    initGetScores() {
        const okHandler = (response) => {
            console.log('GetScores', response, this);
            this.app.ports.updateScores.send(response && response.docs);
        };
        const errHandler = (err) => {
            console.error('GetScores error', err);
            // call port - abort?? retry?
        };
        this.app.ports.getScores.subscribe(([league_id, round_id]) => {
            this.storage.getScores(league_id, round_id, okHandler, errHandler);
        });
    }

    initAddNewScore() {
        const okHandler = (response) => {
            console.log('AddNewScore::ok', response, this);
            this.app.ports.newScoreAdded.send(response);
        };
        const errHandler = (err) => {
            console.error('AddNewScore::error', err);
            this.app.ports.newScoreAdded.send(err);
        };
        this.app.ports.addNewScore.subscribe(newScore => {
            this.storage.addNewScore(newScore, okHandler, errHandler);
        });
    }

    init() {
        this.initLogIn();
        this.initLogOut();
        this.initGetSession();
        this.initGetActiveRound();
        this.initGetLeague();
        this.initGetLeaguePlayers();
        this.initGetScores();
        this.initAddNewScore();
    }

}
