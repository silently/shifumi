import React from 'react';

class Nickname extends React.Component {
  constructor(props) {
    super(props);
    document.body.classList.add('avatar');
    this.handleInputChange = this.handleInputChange.bind(this);
    this.state = {nickname: ""};
  }

  componentWillUnmount() {
    document.body.classList.remove('avatar');
  }

  handleInputChange(event) {
    const value = event.target.value;
    this.setState({
      nickname: value
    });
  }

  render() {
    let error = this.props.me.avatar && this.props.me.avatar.errors && this.props.me.avatar.errors.nickname;
    return (
      <div className="valign-wrapper">
        <div className="row center-align">
          <form onSubmit={this.props.handleSubmit}>
            <div className="col s12">
              <h3 className="blocks">Nickname</h3>
              <div className="row">
                <div className="input-field col s6 offset-s3">
                  <input type="text" name="nickname" maxLength="30" value={this.state.nickname} onChange={this.handleInputChange} />
                </div>
                <div className="col s12 custom-error">
                  <p>{error}</p>
                </div>
              </div>
              <div className="row center-align">
                <div className="input-field col s12">
                  <button className="btn" type="submit">save</button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>
    );
  }
}

export default Nickname;
