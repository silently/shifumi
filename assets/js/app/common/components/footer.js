import React from 'react';
import Link from '../containers/link';
import Modal from './modal';

class Footer extends React.Component {
  constructor(props) {
    super(props);
    this.state = {showModal: false, showNav: false};
    this.toggleNav = this.toggleNav.bind(this);
    this.showModal = this.showModal.bind(this);
    this.hideModal = this.hideModal.bind(this);
    this.handleExit = this.handleExit.bind(this);
  }

  toggleNav() {
    const showNav = !this.state.showNav;
    this.setState({showNav: showNav});
  }

  handleExit(e) {
    e.preventDefault();
    this.hideModal();
    this.props.exit();
  }

  showModal() {
    this.setState({showModal: true});
  }

  hideModal() {
    this.setState({showModal: false});
  }

  renderModal() {
    return (
      <Modal show={this.state.showModal} exit={this.hideModal}>
        <div className="container center-align">
          <div className="row">
            <p className="bigger">Are you sure you want to logout?</p>
            <button className="btn btn-large" onClick={this.handleExit}>Yes</button>
            <button className="btn-flat btn-large white-text" onClick={this.hideModal}>Cancel</button>
          </div>
        </div>
      </Modal>
    );
  }

  activeClassName(pathname, target) {
    return pathname === target ? 'active' : '';
  }

  renderNav() {
    const session = this.props.session;
    if(session.logged) {
      return (
        <nav>
          <ul>
            <li className={this.activeClassName(session.path, '/play')}><Link to="/play" text="Hall" /></li>
            <li className={this.activeClassName(session.path, '/avatar')}><Link to="/avatar" text="Avatar" /></li>
            <li className={this.activeClassName(session.path, '/rules')}><Link to="/rules" text="Rules" /></li>
            <li className={this.activeClassName(session.path, '/about')}><Link to="/about" text="About" /></li>
            <li className="logout"><a onClick={this.showModal}>Logout</a></li>
          </ul>
        </nav>
      );
    } else {
      return (
        <nav>
          <ul>
            <li className={this.activeClassName(session.path, '/rules')}><Link to="/rules" text="Rules" /></li>
            <li className={this.activeClassName(session.path, '/about')}><Link to="/about" text="About" /></li>
          </ul>
        </nav>
      );
    }
  }

  render() {
    const toggleSign = this.state.showNav ? '×' : <span className="hamburger"><span className="bar"></span><span className="bar"></span><span className="bar"></span></span>;
    const toggleClass = this.state.showNav ? 'toggle-container opened' : 'toggle-container';
    return (
      <div className={toggleClass}>
        <div className="toggle" onClick={this.toggleNav}>{toggleSign}</div>
        {this.renderNav()}
        {this.renderModal()}
      </div>
    )
  }
};

export default Footer;
