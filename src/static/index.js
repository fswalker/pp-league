import './styles/fontawesome/font-awesome.scss';
import 'bulma/bulma.sass';
import './styles/main.sass';
import * as Elm from '../elm/Main';
import { Storage } from './js/storage'
import { WebappPorts } from './js/webapp_ports'

const storage = new Storage();

const app = Elm.Main.embed( document.getElementById( 'main' ) );

const ports = new WebappPorts(app, storage);

ports.init();
