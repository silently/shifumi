import React from 'react';
import MenuRoot from '../../menu/containers/root';
import PlayRoot from '../../play/containers/root';

const Root = ({session}) => (
  session.path === '/play' ? <PlayRoot /> : <MenuRoot />
)

export default Root;
