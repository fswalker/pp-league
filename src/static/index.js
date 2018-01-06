import './styles/main.sass';
import * as Elm from '../elm/Main';
import { Storage } from './js/storage'
import { WebappPorts } from './js/webapp_ports'

const storage = new Storage();
storage.test();

// TODO use flags if needed
const app = Elm.Main.embed( document.getElementById( 'main' ) );

const ports = new WebappPorts(app);
ports.init();
