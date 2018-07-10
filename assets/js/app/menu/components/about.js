import React from 'react';

class About extends React.Component {
  constructor(props) {
    super(props);
    document.body.classList.add('about');
  }

  componentDidMount() {
    window.scrollTo(0,0);
  }

  componentWillUnmount() {
    document.body.classList.remove('about');
  }

  render() {
    const mainAction = this.props.logged ? <a className="btn-close btn-play btn-floating btn-large teal lighten-1" onClick={this.props.handlePlay}>►</a> : <a className="btn-close btn-floating btn-large teal lighten-1" onClick={this.props.handleClose}>✕</a>;
    return (
      <div>
        {mainAction}
        <div className="row alternate nbm">
          <div className="col s9">
            <div className="contents">
              <h4>About</h4>
              <p><em>Shifumi</em> is a French variant of the rock-paper-scissors game, with an additional shape: well.</p>
              <p><em>Well</em> breaks the game balance: rock and scissors lose against it (they fall in the well) while paper wins (covering it).</p>
            </div>
          </div>
        </div>
        <div className="row nbm">
          <div className="col s9">
            <div className="contents">
              <h4>Why?</h4>
              <p>This has been developed for learning purposes, mainly regarding the Elixir programming language and the Phoenix web framework.</p>
              <p>Additional technologies, resources and inspiration: React & Redux, PWA, Materialize.css, airma.sh, animate.css, BM Block font.</p>
            </div>
          </div>
        </div>
        <div className="row alternate nbm">
          <div className="col s9">
            <div className="contents">
              <h4>Terms of use</h4>
              <p>The terms of use are subject to change at any time without prior notice.</p>
              <h6>Conduct</h6>
              <p>Respecting other players is expected and required (including in specific messages set on your avatar profile).</p>
              <h6>Sign-in and privacy policy</h6>
              <p>Sign-in is delegated to these platforms: Facebook, Google, Twitter and Github. Your user identifier is used to store your game progress, while other personal data is neither processed nor stored.</p>
              <p>Shifumi.io will not ask to act on your behalf on these platforms.</p>
              <h6>Tracking</h6>
              <p>IP addresses may be collected for protection against denial of service attacks.</p>
              <h6>Demo</h6>
              <p>Shifumi.io is a live demo, meaning that data persistence (for instance high scores) is not guaranteed.</p>
            </div>
          </div>
        </div>
        <div className="row">
          <div className="col s9">
            <div className="contents">
              <h4>Source code</h4>
              <p>The source is <a href="https://github.com/silently/shifumi" target="_blank">available here</a>.</p>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default About;
