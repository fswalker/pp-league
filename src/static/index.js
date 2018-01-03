import './styles/main.sass';
import * as Elm from '../elm/Main';
import { Storage } from './js/storage'

// var Elm = require( '../elm/Main' );
// TODO use flags if needed
const app = Elm.Main.embed( document.getElementById( 'main' ) );

// TODO storage should have access to elm ports - pass it as a parameter
const storage = new Storage();
