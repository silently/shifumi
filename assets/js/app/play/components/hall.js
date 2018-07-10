import React from 'react';
import Series from '../containers/hall/series';
import Sheet from '../containers/hall/sheet';
import {bestLive, best} from '../actions/async';


export default class Hall extends React.Component {
  constructor(props) {
    super(props);
    document.body.classList.add('hall');
    this.showSeries = this.showSeries.bind(this);
    this.showSheet = this.showSheet.bind(this);
    this.state = {showSeries: true};
  }

  componentDidMount() {
    const dispatch = this.props.dispatch;
    dispatch(bestLive())
      .then(() => dispatch(best()));
  }

  componentWillUnmount() {
    document.body.classList.remove('hall');
  }

  showSeries() {
    this.setState({showSeries: true});
  }

  showSheet() {
    this.setState({showSeries: false});
  }

  render() {
    let focus = null;

    const playersCount = this.props.playersCount;
    const playersCountMessage =
        playersCount > 1 ?
          <p><span className="count">{playersCount}</span> players around</p> :
          <p><span className="count">{playersCount}</span> players around</p>;

    const UpStats = this.state.showSeries ? Series : Sheet;
    const seriesClass = this.state.showSeries ? 'btn disabled' : 'btn';
    const sheetClass = this.state.showSeries ? 'btn' : 'btn disabled';

    if(this.props.ready) {
      focus = (
        <div>
          <div className="row center-align">
            <div className="col s12">
              <button className="btn btn-large" onClick={this.props.handleBusy}>pause</button>
            </div>
          </div>
          <div className="row center-align">
            <div className="col s12">
              <div className="spinner-wrapper">
                <div className="spinner">
                  <div className="valign-wrapper"><div>waiting for opponent</div></div>
                  <div className="double-bounce1"></div>
                  <div className="double-bounce2"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      );
    } else {
      focus = (
        <div>
          <div className="row center-align">
            <div className="col s12">
              <button className="btn btn-large" onClick={this.props.handleReady}>► play</button>
            </div>
          </div>
          <div className="row center-align">
            <div className="col s12 bigger">
              {playersCountMessage}
            </div>
          </div>
        </div>
      );
    }

    return (
      <div>
        <div className="big-up">
          <div className="row center-align">
            <div className="col s12">
              <h2>Hall</h2>
            </div>
          </div>
          <div className="row">
            <div className="col s12 center-align toggle">
              <div className={seriesClass} onClick={this.showSeries}>best series</div>
              <div className={sheetClass} onClick={this.showSheet}>my stats</div>
            </div>
          </div>
          <UpStats />
        </div>
        <div className="small-bottom">
          {focus}
        </div>
      </div>
    );
  }
}
