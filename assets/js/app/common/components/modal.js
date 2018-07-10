import React from 'react';

class Modal extends React.Component {
  constructor(props) {
    super(props);
    this.escape = this.escape.bind(this);
  }

  escape(event) {
    if(event.keyCode === 27) {
      this.props.exit();
    }
  }

  componentDidMount(){
    document.addEventListener("keydown", this.escape, false);
  }

  componentWillUnmount(){
    document.removeEventListener("keydown", this.escape, false);
  }

  render() {
    return (
      <div className={this.props.show ? "show" : "hide"}>
        <div className="modal-overlay" onClick={this.props.exit}></div>
        <div className="modal">
          {this.props.children}
        </div>
      </div>
    );
  }
}

export default Modal;
