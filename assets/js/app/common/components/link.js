import React from 'react';

const Link = (props) => (
  <a onClick={props.handleClick.bind(null, props.to)}>{props.text}</a>
);

export default Link;
