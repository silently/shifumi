import React from 'react';
import Modal from '../../common/components/modal';

class Home extends React.Component {
  constructor(props) {
    super(props);
    this.state = {nickname: this.props.avatar.nickname, showModal: false};
    this.handleChange = this.handleChange.bind(this);
    this.showModal = this.showModal.bind(this);
    this.hideModal = this.hideModal.bind(this);
    document.body.classList.add('home');
  }

  componentWillUnmount() {
    document.body.classList.remove('home');
  }

  handleChange(event) {
    const target = event.target;
    this.setState({
      [target.name]: target.value
    });
  }

  showModal() {
    this.setState({showModal: true});
  }

  hideModal() {
    this.setState({showModal: false});
  }

  getAction() {
    if(this.props.session.logged) {
      return (
        <div className="row tm50">
          <div className="col s12">
            <div className="btn btn-large teal" onClick={this.props.handlePlay}>hall</div>
          </div>
        </div>
      );
    } else {
      return (
        <div className="row tm50">
          <div className="col s12">
            <div className="btn btn-large teal" onClick={this.showModal}>start</div>
          </div>
          {this.props.session.flash &&
          <div className="col s12 custom-error">
            <p>{this.props.session.flash}</p>
          </div>
          }
        </div>
      );
    }
  }

  render() {
    const action = this.getAction();
    const playersCount = this.props.session.playersCount;
    const playersCountMessage = playersCount > 1 ?
          <p>{playersCount} players connected</p> :
          <p>1 player connected</p>;

    return (
      <div className="center-align">
        <div className="row">
          <div className="col s12 logo tm2">
            <p className="bigger">play</p>
            <h1>Shifumi</h1>
          </div>
        </div>
        <div className="row">
          <div className="col s12 showcase bigger">
            <div className="shape">
              <span className="label">rock</span>
              <i className="rock icon anim-boom-in anim-delay-100"></i>
            </div>
            <div className="shape">
              <span className="label">paper</span>
              <i className="paper icon anim-boom-in anim-delay-250"></i>
            </div>
            <div className="shape">
              <span className="label">scissors</span>
              <i className="scissors icon anim-boom-in anim-delay-500"></i>
            </div>
            <div className="shape">
              <span className="label">well</span>
              <i className="well icon anim-boom-in anim-delay-1"></i>
            </div>
          </div>
        </div>
        {action}
        <div className="row">
          <div className="col s12 bigger">
            {playersCountMessage}
          </div>
        </div>
        <Modal show={this.state.showModal} exit={this.hideModal}>
          <div className="container center-align">
            <div className="row">
              <p className="bigger">Sign in with</p>
            </div>
            <div className="row">
              <a href="/auth/facebook" className="col s8 offset-s2 btn btn-facebook bigger bm"><span className="icon left"></span>Facebook</a>
              <a href="/auth/google" className="col s8 offset-s2 btn btn-google bigger bm"><span className="icon left"></span>Google</a>
              <a href="/auth/twitter" className="col s8 offset-s2 btn btn-twitter bigger bm"><span className="icon left"></span>Twitter</a>
              <a href="/auth/github" className="col s8 offset-s2 btn btn-github bigger bm"><span className="icon left"><svg height="20" version="1.1" viewBox="0 0 16 16" width="20"><path fillRule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"></path></svg></span> Github</a>
            </div>
            <p className="small">We ask for the minimum permission and only your ID to save your progress.</p>
            <p className="small">Ad blockers may disable some social login options.</p>
          </div>
        </Modal>
      </div>
    );
  }
}

export default Home;
