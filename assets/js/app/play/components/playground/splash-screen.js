import React from 'react';
import {nextFrame} from '../../../common/helpers';

export default class SplashScreen extends React.Component {
  constructor(props) {
    super(props);
    this.launchTransitions();
  }

  launchTransitions() {
    const trigger = (() => { document.querySelector('.full-to-mid').classList.add('start');}).bind(this);
    nextFrame(trigger);
  }

  render() {
    return (
      <div className="full-to-mid">
        <div className="mid-up">
        </div>
        <div className="mid-bottom">
          <div className="valign-wrapper">
            <div className="row">
              <div className="col s12">
                <h2 className="anim-bounce-out anim-delay-750">New Game</h2>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
