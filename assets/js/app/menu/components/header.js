import React from 'react';
import Link from '../../common/containers/link';

const Header = (props) => (
  <header>
    <nav>
      <ul>
        <li><Link to="/" text="Home" /></li>
        <li><Link to="/avatar" text="Avatar" /></li>
        {props.session.logged &&
          <li><Link to="/play" text="Play" /></li>
        }
      </ul>
    </nav>
  </header>
);

export default Header;
