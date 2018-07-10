import React from 'react';
import Abort from '../containers/abort';
import Error from './error';
import Loading from './loading';
import Hall from '../containers/hall';
import Playground from '../containers/playground';
import Nickname from '../containers/nickname';
import Footer from '../../common/containers/footer';
import {connectSocket, joinPlayerChannel, joinPresenceChannel, loadMe} from '../actions/async';

export default class Root extends React.Component {
  constructor(props) {
    super(props);
    document.body.classList.add('play');
    this.processWindowLocation();
  }

  componentDidMount() {
    const dispatch = this.props.dispatch;
    dispatch(connectSocket())
      .then(() => dispatch(joinPresenceChannel()))
      .then(() => dispatch(joinPlayerChannel()))
      .then(() => dispatch(loadMe()));
  }

  componentWillUnmount() {
    document.body.classList.remove('play');
  }

  processWindowLocation() {
    if(window.location.hash !== '') {
      // Remove fragment added by auth providers
      window.history.replaceState('', document.title, window.location.pathname);
    }
  }

  selectPage() {
    if(this.props.loaded) {
      if(this.props.nicknameNeeded) {
        return Nickname;
      } else if(this.props.inPlayground) {
        return Playground;
      } else if(this.props.inAbort) {
        return Abort;
      } else {
        return Hall;
      }
    } else if(this.props.networkError) {
      return Error;
    } else {
      return Loading;
    }
  }

  render() {
    const Page = this.selectPage();
    return (
      <div id="shell" className="wrapper">
        <main role="main">
          <Page />
        </main>
        {(Page !== Nickname && (Page !== Playground || this.props.inSummary)) &&
          <footer>
            <Footer />
          </footer>
        }
      </div>
    );
  }
}
