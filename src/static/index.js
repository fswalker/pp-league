var PouchDB = require('pouchdb-browser');
require( './styles/main.sass' );


var Elm = require( '../elm/Main' );

var app = Elm.Main.embed( document.getElementById( 'main' ) );

// TODO
var db = new PouchDB.default('ping-pong-rel-krk');
var remoteCouch = 'http://ping:pong@localhost:5984/ping-pong-rel-krk';

// function sync() {
//     var opts = { live: true };
//     var syncError = function(err) { console.error(err); };
//     db.replicate.to(remoteCouch, opts, syncError);
//     db.replicate.from(remoteCouch, opts, syncError);
// }
// sync();

// var showQuotes = function() {
//     db.allDocs({include_docs: true}, function(err, doc) {
//         if (doc && doc.rows && Array.isArray(doc.rows)) {
//             const quotes = doc.rows.map(function(r) { 
//                 let doc = r.doc;
//                 return { id: doc._id
//                     , version: doc._rev
//                     , author: doc.author
//                     , quote: doc.quote
//                     };
//                 }
//             );
//             console.log('From PouchDB:', quotes);
//             app.ports.quotesChange.send(quotes); 
//         }
//     });
// };
// showQuotes();

// db.changes({
//     since: 'now',
//     live: true
//   }).on('change', showQuotes);


// app.ports.saveQuotes.subscribe(function(quotes) {
//     if (quotes && Array.isArray(quotes)) {
//         var storageQuotes = quotes.map(function(q) {
//             return q && q.id && q.quote && q.author
//                 ? { _id: q.id
//                   , _rev: q.version
//                   , quote: q.quote
//                   , author: q.author
//                   }
//                 : null;
//         }).filter(function(o) { return !!o });
//         console.log('Elm: Save quotes!', storageQuotes);
//         db.bulkDocs(storageQuotes)
//             .then(function (result) {
//                 console.log('PouchDB save result:', result);
//                 // TODO all docs in Elm should be updated with proper rev - version
//             }).catch(function (err) {
//                 console.log(err);
//             });
//     }
// });
