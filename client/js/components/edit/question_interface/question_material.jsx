"use strict";

import React         from "react";
import _             from "lodash";
import BaseComponent from '../../base_component.jsx';
import Style         from "./css/style.js";
import SimpleRCE     from './simple_rce.jsx';

export default class QuestionMaterial extends BaseComponent{

  constructor(props, state) {
    super(props, state);
  }

  render() {
    let material = this.props.material;
    let style    = Style.styles();

    return (
      <div style={style.qBlock}>
        <div style={_.merge({paddingBottom: "0.25em"}, style.label)}>Question</div>
        <SimpleRCE
          content={material}
          config="basic"
          onChange={this.props.onChange}
          onKeyup={this.props.onKeyup}
          />
      </div>
    )

  }

}
