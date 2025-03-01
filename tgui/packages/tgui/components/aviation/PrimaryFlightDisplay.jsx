import { Component } from 'react';
import '../../styles/components/aviation/PrimaryFlightDisplay.scss';

const FPS = 10;

export class PrimaryFlightDisplay extends Component {
  constructor() {
    super();
    this.state = {
      pitch: 0,
      speed: 170,
    };
  }

  update() {
    this.setState((prevState) => ({
      pitch: prevState.pitch + 1,
      speed: prevState.speed + 1,
    }));
  }

  // Begins the tick update.
  // This makes the UI render at 20 FPS and performs important actions
  componentDidMount() {
    this.tickUpdate = setInterval(() => this.update(), 1000 / FPS);
  }

  // Stops doing the tick update when the component unmounts or something
  componentWillUnmount() {
    clearInterval(this.tickUpdate);
  }

  /**
   * Render the altimeter
   */
  render_altimeter() {
    const speedUnrounded = 3000 + Math.sin((this.state.speed / 180) * Math.PI) * 2000;
    const speed = Math.round(speedUnrounded);
    const speedProportion = speedUnrounded % 1;
    return (
      <svg viewBox="0 0 100 500" width="100%" height="100%">
        <defs>
          <clipPath id="text-cutoff-alt">
            <rect x={64} y={230} width={40} height={40} />
          </clipPath>
          <clipPath id="container_alt">
            <rect x={40} y={50} width={60} height={400} />
          </clipPath>
        </defs>
        <rect
          x={40}
          y={50}
          width={60}
          height={400}
          style={{
            fill: 'rgb(86, 88, 92)',
          }}
        />
        {[speed - 1200, speed - 800, speed - 400, speed, speed + 400, speed + 800, speed + 1200]
          .map((speed) => Math.round(speed / 400) * 400)
          .map((localHeight) => (
            <>
              <line
                x1={40}
                y1={(-(localHeight - speed) * 250) / 1200 + 250}
                x2={60}
                y2={(-(localHeight - speed) * 250) / 1200 + 250}
                style={{
                  stroke: 'rgb(255, 255, 255)',
                  strokeWidth: 2,
                }}
                clip-path="url(#container_alt)"
              />
              <line
                x1={40}
                y1={(-(localHeight - speed + 200) * 250) / 1200 + 250}
                x2={60}
                y2={(-(localHeight - speed + 200) * 250) / 1200 + 250}
                style={{
                  stroke: 'rgb(255, 255, 255)',
                  strokeWidth: 1,
                }}
                clip-path="url(#container_alt)"
              />
              <text
                x={88}
                text-anchor="end"
                y={(-(localHeight - speed) * 250) / 1200 + 250 + 5}
                fill="rgb(255, 255, 255)"
                fontSize={10}
                clip-path="url(#container_alt)">
                {localHeight}
              </text>
            </>
          ))}
        <polygon
          points="54 230 54 240 46 250 54 260 54 270 94 270 94 230"
          style={{
            fill: 'rgb(0, 0, 0)',
            stroke: 'rgb(255, 255, 255)',
            strokeWidth: 2,
          }}
        />
        <text x={78} text-anchor="end" y={255} fill="rgb(255, 255, 255)" fontSize={12}>
          {Math.floor(speed / 10)}
        </text>
        <text x={78} text-anchor="start" y={255 + 17 * speedProportion} fill="rgb(255, 255, 255)" fontSize={12}>
          {speed % 10}
        </text>
        <text
          x={78}
          text-anchor="start"
          y={238 + 17 * speedProportion}
          fill="rgb(255, 255, 255)"
          fontSize={12}
          clip-path="url(#text-cutoff-alt)">
          {((speed % 10) + 1) % 10}
        </text>
        <text
          x={78}
          text-anchor="start"
          y={272 + 17 * speedProportion}
          fill="rgb(255, 255, 255)"
          fontSize={12}
          clip-path="url(#text-cutoff-alt)">
          {((speed % 10) - 1 + 10) % 10}
        </text>
      </svg>
    );
  }

  /**
   * Render the velocity indicator
   */
  render_velocity() {
    const speedUnrounded = 170 + Math.sin((this.state.speed / 180) * Math.PI) * 20;
    const speed = Math.round(speedUnrounded);
    const speedProportion = speedUnrounded % 1;
    return (
      <svg viewBox="0 0 100 500" width="100%" height="100%">
        <defs>
          <clipPath id="text-cutoff">
            <rect x={4} y={230} width={40} height={40} />
          </clipPath>
          <clipPath id="container">
            <rect x={0} y={50} width={60} height={400} />
          </clipPath>
        </defs>
        <rect
          x={0}
          y={50}
          width={60}
          height={400}
          style={{
            fill: 'rgb(86, 88, 92)',
          }}
        />
        {[speed - 60, speed - 40, speed - 20, speed, speed + 20, speed + 40, speed + 60]
          .map((speed) => Math.round(speed / 20) * 20)
          .map((localSpeed) => (
            <>
              <line
                x1={40}
                y1={(-(localSpeed - speed) * 250) / 60 + 250}
                x2={60}
                y2={(-(localSpeed - speed) * 250) / 60 + 250}
                style={{
                  stroke: 'rgb(255, 255, 255)',
                  strokeWidth: 1,
                }}
                clip-path="url(#container)"
              />
              <line
                x1={40}
                y1={(-(localSpeed - speed + 10) * 250) / 60 + 250}
                x2={60}
                y2={(-(localSpeed - speed + 10) * 250) / 60 + 250}
                style={{
                  stroke: 'rgb(255, 255, 255)',
                  strokeWidth: 1,
                }}
                clip-path="url(#container)"
              />
              <text
                x={38}
                text-anchor="end"
                y={(-(localSpeed - speed) * 250) / 60 + 250 + 5}
                fill="rgb(255, 255, 255)"
                fontSize={14}
                clip-path="url(#container)">
                {localSpeed}
              </text>
            </>
          ))}
        <polygon
          points="4 230 4 270 44 270 44 260 56 250 44 240 44 230"
          style={{
            fill: 'rgb(0, 0, 0)',
            stroke: 'rgb(255, 255, 255)',
            strokeWidth: 2,
          }}
        />
        <text x={28} text-anchor="end" y={255} fill="rgb(255, 255, 255)" fontSize={16}>
          {Math.floor(speed / 10)}
        </text>
        <text x={28} text-anchor="start" y={255 + 17 * speedProportion} fill="rgb(255, 255, 255)" fontSize={16}>
          {speed % 10}
        </text>
        <text
          x={28}
          text-anchor="start"
          y={238 + 17 * speedProportion}
          fill="rgb(255, 255, 255)"
          fontSize={16}
          clip-path="url(#text-cutoff)">
          {((speed % 10) + 1) % 10}
        </text>
        <text
          x={28}
          text-anchor="start"
          y={272 + 17 * speedProportion}
          fill="rgb(255, 255, 255)"
          fontSize={16}
          clip-path="url(#text-cutoff)">
          {((speed % 10) - 1 + 10) % 10}
        </text>
      </svg>
    );
  }

  /**
   * Render the vertical heading indicator
   */
  render_vertical_situation() {
    const pitch = Math.sin((this.state.pitch / 180) * Math.PI) * 20;
    return (
      <svg viewBox="-250 -250 500 500" width="100%" height="100%">
        <rect
          x={-250}
          y={-250}
          width={500}
          height={250 + Math.tan((pitch * Math.PI) / 180) * 500}
          style={{
            fill: 'rgb(42, 95, 201)',
          }}
        />
        <rect
          x={-250}
          y={Math.tan((pitch * Math.PI) / 180) * 500}
          width={500}
          height={500 - Math.tan((pitch * Math.PI) / 180) * 500}
          style={{
            fill: 'rgb(156, 76, 33)',
          }}
        />
        <line
          x1={250}
          y1={Math.tan((pitch * Math.PI) / 180) * 500}
          x2={-250}
          y2={Math.tan((pitch * Math.PI) / 180) * 500}
          style={{
            stroke: 'rgb(255, 255, 255)',
            strokeWidth: 1,
          }}
        />
        <rect
          x={-160}
          y={-5}
          width={100}
          height={10}
          style={{
            fill: 'rgb(255, 255, 255)',
          }}
        />
        <rect
          x={-70}
          y={0}
          width={10}
          height={30}
          style={{
            fill: 'rgb(255, 255, 255)',
          }}
        />
        <rect
          x={-157}
          y={-3}
          width={94}
          height={6}
          style={{
            fill: 'rgb(0, 0, 0)',
          }}
        />
        <rect
          x={-67}
          y={3}
          width={4}
          height={24}
          style={{
            fill: 'rgb(0, 0, 0)',
          }}
        />
        <rect
          x={60}
          y={-5}
          width={100}
          height={10}
          style={{
            fill: 'rgb(255, 255, 255)',
          }}
        />
        <rect
          x={60}
          y={0}
          width={10}
          height={30}
          style={{
            fill: 'rgb(255, 255, 255)',
          }}
        />
        <rect
          x={157 - 94}
          y={-3}
          width={94}
          height={6}
          style={{
            fill: 'rgb(0, 0, 0)',
          }}
        />
        <rect
          x={63}
          y={3}
          width={4}
          height={24}
          style={{
            fill: 'rgb(0, 0, 0)',
          }}
        />
        <rect
          x={-5}
          y={-5}
          width={10}
          height={10}
          style={{
            stroke: 'rgb(255, 255, 255)',
            strokeWidth: 3,
            fillOpacity: 0,
          }}
        />
        {/* Autopilot Heading indicator */}
        {false && (
          <>
            <line
              x1={0}
              y1={100}
              x2={0}
              y2={-100}
              style={{
                stroke: 'rgb(242, 154, 255)',
                strokeWidth: 3,
              }}
            />
            <line
              x1={-100}
              y1={0}
              x2={100}
              y2={0}
              style={{
                stroke: 'rgb(242, 154, 255)',
                strokeWidth: 3,
              }}
            />
          </>
        )}
        {[pitch - 30, pitch - 20, pitch - 10, pitch, pitch + 10, pitch + 20]
          .map((angle) => Math.round(angle / 10) * 10)
          .map((angle) => (
            <>
              <line
                x1={-100}
                y1={Math.tan((-(angle - pitch) * Math.PI) / 180) * 500}
                x2={100}
                y2={Math.tan((-(angle - pitch) * Math.PI) / 180) * 500}
                style={{
                  stroke: 'rgb(255, 255, 255)',
                  strokeWidth: 2,
                }}
              />
              <line
                x1={-50}
                y1={Math.tan((-(angle - pitch + 5) * Math.PI) / 180) * 500}
                x2={50}
                y2={Math.tan((-(angle - pitch + 5) * Math.PI) / 180) * 500}
                style={{
                  stroke: 'rgb(255, 255, 255)',
                  strokeWidth: 1,
                }}
              />
              <text
                x={-105}
                text-anchor="end"
                y={Math.tan((-(angle - pitch) * Math.PI) / 180) * 500 + 8}
                fill="rgba(255, 255, 255, 0.5)"
                fontSize={22}>
                {angle}
              </text>
              <text
                x={105}
                y={Math.tan((-(angle - pitch) * Math.PI) / 180) * 500 + 8}
                fill="rgba(255, 255, 255, 0.5)"
                fontSize={22}>
                {angle}
              </text>
            </>
          ))}
      </svg>
    );
  }

  render() {
    return (
      <div class="primary_flight_display">
        <div class="horizontal_display">
          <div class="speed">{this.render_velocity()}</div>
          <div class="vertical_display">
            <div class="notifications" />
            <div class="vertical_situation">
              <div class="flight_box">{this.render_vertical_situation()}</div>
            </div>
            <div class="heading" />
          </div>
          <div class="altimeter">{this.render_altimeter()}</div>
        </div>
      </div>
    );
  }
}
