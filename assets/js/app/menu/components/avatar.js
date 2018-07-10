import React from 'react';
import {loadAvatar} from '../actions/async'

class Avatar extends React.Component {
  constructor(props) {
    super(props);
    document.body.classList.add('avatar');
    this.handleInputChange = this.handleInputChange.bind(this);
    this.handleFileChange = this.handleFileChange.bind(this);
    this.handlePreviewClick = this.handlePreviewClick.bind(this);
    this.resizePreview = this.resizePreview.bind(this);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.state = Avatar.stateFromProps(props);
  }

  static stateFromProps(props, previousUpdateNeeded, previousUpdateImageNeeded) {
    const avatar = props.avatar;
    // don't update when waiting for server response
    // don't update other parts of state if there are errors
    if(avatar.updating || avatar.errors) return {errors: avatar.errors};
    // main path now: on load and on update success
    // conditionnally add a query parameter so that src refreshes after an update
    const timestamp = previousUpdateImageNeeded ? '?v' + (new Date()).getTime() : '';
    const imageSrc = avatar.picture ?
      '/media/' + avatar.player_id + '.jpg' + timestamp :
      '#';
    const updateNeeded = !!previousUpdateNeeded && !avatar.updated;
    const updateImageNeeded = !!previousUpdateImageNeeded && !avatar.updated;
    return {
      nickname: avatar.nickname || '',
      mantra: avatar.mantra || '',
      roar: avatar.roar || '',
      location: avatar.location || '',
      imageSrc,
      updateNeeded,
      updateImageNeeded
    }
  }

  static getDerivedStateFromProps(nextProps, prevState) {
    return Avatar.stateFromProps(nextProps, prevState.updateNeeded, prevState.updateImageNeeded);
  }

  static capitalize(s) {
    return s.charAt(0).toUpperCase() + s.slice(1);
  }

  componentWillUnmount() {
    document.body.classList.remove('avatar');
  }

  componentDidMount() {
    this.props.dispatch(loadAvatar());
  }

  handlePreviewClick(e) {
    e.preventDefault();
    this.fileInput.click();
  }

  handleInputChange(e) {
    const value = e.target.value;
    const name = e.target.name;

    this.setState({
      [name]: value,
      updateNeeded: true
    });
  }

  handleFileChange(handleFileChange) {
    const reader = new FileReader();
    reader.onload = (e => this.resizePreview(e.target.result));
    reader.readAsDataURL(this.fileInput.files[0]);
    this.setState({
      updateNeeded: true,
      updateImageNeeded: true
    });
  }

  resizePreview(rawData) {
    const buffer = document.createElement('img');
    const self = this;
    buffer.src = rawData;
    // wait for buffer src to be rendered, width and height would be 0 otherwise
    requestAnimationFrame(() => {
      const canvas = document.getElementById('canvas');
      const MAX_SIZE = 200;

      let width = buffer.width;
      let height = buffer.height;
      // we want the smallest dimension to be capped at MAX_SIZE
      if (width > height) {
        if (height > MAX_SIZE) {
          width *= MAX_SIZE / height;
          height = MAX_SIZE;
        }
      } else {
        if (width > MAX_SIZE) {
          height *= MAX_SIZE / width;
          width = MAX_SIZE;
        }
      }

      canvas.width = width;
      canvas.height = height;
      var ctx = canvas.getContext('2d');
      ctx.drawImage(buffer, 0, 0, width, height);

      const newData = canvas.toDataURL("image/png");
      self.setState({imageSrc: newData});
    });
  }

  handleSubmit(e) {
    e.preventDefault()
    const formData = new FormData(e.target);
    const imageDataURI = this.state.updateImageNeeded ? this.state.imageSrc : undefined;
    this.props.update(formData, imageDataURI);
  }

  render() {
    const preview = this.state.imageSrc === '#' ?
      <div className="default">:)</div> :
      <img src={this.state.imageSrc} className="responsive-img"/>;

    const errors = this.state.errors;
    const errorsMessage = errors && Object.entries(errors).map(([k, v], i) =>
      <li key={i}>{Avatar.capitalize(k)} {v}</li>
    );

    return (
      <div>
        {this.state.errors &&
          <div className="card-ref">
            <div className="card-wrapper">
              <div className="card-contents anim-bounce-in-out">
                <ul>{errorsMessage}</ul>
              </div>
            </div>
          </div>
        }
        <a className="btn-play btn-floating btn-large teal lighten-1" onClick={this.props.handleClose}>►</a>
        <div className="row">
          <div className="col s12">
            <h2>Avatar</h2>
          </div>
          <form onSubmit={this.handleSubmit}>
            <div className="col s6">
              <div className="row">
                <div className="input-field col s12">
                  <input id="nickname" type="text" name="nickname" maxLength="20" value={this.state.nickname} onChange={this.handleInputChange} />
                  <label htmlFor="nickname" className="active">Nickname</label>
                </div>
              </div>
              <div className="row">
                <div className="col s12 file-field input-field">
                  <div className="btn">
                    <span>Picture</span>
                    <input name="file" type="file" accept="image/*" ref={input => {this.fileInput = input;}} onChange={this.handleFileChange}/>
                  </div>
                  <div className="file-path-wrapper">
                    <input className="file-path" type="text" />
                  </div>
                </div>
              </div>
            </div>
            <div className="col s4 offset-s1">
              <div onClick={this.handlePreviewClick}>
                {preview}
              </div>
            </div>
            <div className="col s12">
              <div className="row">
                <div className="row">
                  <div className="input-field col s9">
                    <input id="location" type="text" name="location" maxLength="30" value={this.state.location} onChange={this.handleInputChange} />
                    <label htmlFor="location" className="active">Location</label>
                  </div>
                </div>
                <div className="input-field col s9">
                  <input id="mantra" type="text" name="mantra" maxLength="30" value={this.state.mantra} onChange={this.handleInputChange} />
                  <label htmlFor="mantra" className="active">Mantra</label>
                </div>
              </div>
              <div className="row">
                <div className="input-field col s9">
                  <input id="roar" type="text" name="roar" maxLength="30" value={this.state.roar} onChange={this.handleInputChange} />
                  <label htmlFor="roar" className="active">Victory shout</label>
                </div>
              </div>
              <div className="row center-align">
                <div className="input-field col s12">
                  <button className="btn" type="submit" disabled={!this.state.updateNeeded}>
                    {this.state.updateNeeded ? 'update' : 'up to date'}
                  </button>
                </div>
              </div>
            </div>
          </form>
        </div>
        <canvas id="canvas" className="hide"></canvas>
      </div>
    );
  }
}

export default Avatar;
