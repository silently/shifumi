import React from 'react';
import Header from '../containers/header';
import Home from '../containers/home';
import Avatar from '../containers/avatar';
import Rules from '../containers/rules';
import About from '../containers/about';
import Footer from '../../common/containers/footer';
import {navigateTo} from '../../common/actions/async';

const PAGES = {
  '/': Home,
  '/avatar': Avatar,
  '/rules': Rules,
  '/about': About
};

class Root extends React.Component {
  constructor(props) {
    super(props);
  }

  shouldComponentUpdate(nextProps) {
    if(nextProps.session.path === '/avatar' && !nextProps.session.logged) {
      this.props.dispatch(navigateTo('/'));
      return false;
    }
    return true;
  }

  render() {
    const Page = PAGES[this.props.session.path];
    return (
      <div id="shell" className="wrapper">
        <main role="main">
          <Page />
        </main>
        <footer>
          <Footer />
        </footer>
      </div>
    );
  }
}

export default Root;
