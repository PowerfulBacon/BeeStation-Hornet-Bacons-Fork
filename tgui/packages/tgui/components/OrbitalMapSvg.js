
import { clamp } from 'common/math';
import { pureComponentHooks } from 'common/react';
import { Component, createRef } from 'inferno';

const FPS = 20;

export class OrbitalMapSvg extends Component {
  constructor(props)
  {
    super(props);
    // Single instance objects is a dictionary
    // Key = object ID
    // Value = Object data
    this.state = {
      singleInstanceObjects: {},
      tickIndex: -1,
      tickTimer: new Date(),
    };
  }

  dotick()
  {
    const { props, state } = this;
    // Fetch single instanced objects
    const {
      singleInstanceObjects,
      tickIndex,
      tickTimer,
    } = state;
    // Fetch created and destroyed objects
    const {
      created_objects = [],
      destroyed_objects = [],
      currentUpdateIndex = -1,
    } = props;
    // Don't update if we already updated for this tick
    if (currentUpdateIndex === tickIndex)
    {
      this.setState({
        internalElapsed: (new Date() - tickTimer) / 1000,
      });
      return;
    }

    // Clone the dictionary
    let outputInstances = {};
    for (const [key, singleInstance] of Object.entries(singleInstanceObjects)) {
      if (!(key in destroyed_objects))
      {
        outputInstances[key] = singleInstance;
      }
    }

    // Find differences in created objects
    created_objects.forEach(created_object => {
      // Ignore already made objects
      if (!(created_object.id in singleInstanceObjects))
      {
        // Create the object
        outputInstances[created_object.id] = created_object;
      }
    });

    // Update state
    this.setState({
      singleInstanceObjects: outputInstances,
      tickIndex: currentUpdateIndex,
      tickTimer: new Date(),
      internalElapsed: 0,
    });
  }

  // Begins the tick update.
  // This makes the UI render at 20 FPS and performs important actions
  componentDidMount() {
    this.tickUpdate = setInterval(() => this.dotick(), 1000 / FPS);
  }

  // Stops doing the tick update when the component unmounts or something
  componentWillUnmount() {
    clearInterval(this.tickUpdate);
  }

  // Returns the defs that make up the background grid
  getGridBackground() {
    const {
      scaledXOffset,
      scaledYOffset,
      lockedZoomScale,
    } = this.props;

    return (
      <>
        <defs>
          <pattern id="grid" width={100 * lockedZoomScale}
            height={100 * lockedZoomScale}
            patternUnits="userSpaceOnUse"
            x={scaledXOffset}
            y={scaledYOffset}>
            <rect width={100 * lockedZoomScale}
              height={100 * lockedZoomScale}
              fill="url(#smallgrid)" />
            <path
              fill="none" stroke="#4665DE" stroke-width="1"
              d={"M " + (100 * lockedZoomScale)+ " 0 L 0 0 0 " + (100 * lockedZoomScale)} />
          </pattern>
          <pattern id="smallgrid"
            width={50 * lockedZoomScale}
            height={50 * lockedZoomScale}
            patternUnits="userSpaceOnUse">
            <rect
              width={50 * lockedZoomScale}
              height={50 * lockedZoomScale}
              fill="#2B2E3B" />
            <path
              fill="none"
              stroke="#4665DE"
              stroke-width="0.5"
              d={"M " + (50 * lockedZoomScale) + " 0 L 0 0 0 "
              + (50 * lockedZoomScale)} />
          </pattern>
        </defs>
        <rect x="-50%" y="-50%" width="100%" height="100%"
          fill="url(#grid)" />
      </>
    );
  }

  // Handles rendering of the orbital map
  render() {
    // SVG Background Style
    const lineStyle = {
      stroke: '#BBBBBB',
      strokeWidth: '2',
    };
    const blueLineStyle = {
      stroke: '#8888FF',
      strokeWidth: '2',
    };
    const boxTargetStyle = {
      "fill-opacity": 0,
      stroke: '#DDDDDD',
      strokeWidth: '1',
    };
    const lineTargetStyle = {
      opacity: 0.4,
      stroke: '#DDDDDD',
      strokeWidth: '1',
    };

    const {
      singleInstanceObjects = {},
      tickIndex,
      tickTimer,
      internalElapsed,
    } = this.state;

    const {
      dragStartEvent,
      xOffset,
      yOffset,
      ourObject,
      lockedZoomScale,
      map_objects,
      interdiction_range = 0,
      shuttleTargetX = 0,
      shuttleTargetY = 0,
      zoomScale,
      shuttleName,
      currentUpdateIndex,
      children,
    } = this.props;

    // Calculate elapsed here to not do a bunch of stupid updates.
    let elapsed = 0;

    // Calculate an elapsed time
    if (tickIndex === currentUpdateIndex)
    {
      elapsed = internalElapsed;
    }

    // Fetch values
    let instancedObjects = [];

    for (const [key, singleInstance] of Object.entries(singleInstanceObjects)) {
      let ticksSince = currentUpdateIndex - singleInstance.created_at;
      instancedObjects.push({
        name: singleInstance.name,
        position_x: singleInstance.position_x
          + ticksSince * singleInstance.velocity_x,
        position_y: singleInstance.position_y
          + ticksSince * singleInstance.velocity_y,
        velocity_x: singleInstance.velocity_x,
        velocity_y: singleInstance.velocity_y,
        radius: singleInstance.radius,
      });
    }

    let orbitalObjects = map_objects.concat(instancedObjects);

    let svgComponent = (
      <svg
        onMouseDown={e => {
          dragStartEvent(e);
        }}
        viewBox="-250 -250 500 500"
        position="absolute"
        overflowY="hidden" >
        {this.getGridBackground()}
        {orbitalObjects.map(map_object => (
          <>
            <circle
              cx={Math.max(Math.min((map_object.position_x
                + xOffset
                + map_object.velocity_x * elapsed)
                * zoomScale, 250), -250)}
              cy={Math.max(Math.min((map_object.position_y
                + yOffset
                + map_object.velocity_y * elapsed)
                * zoomScale, 250), -250)}
              r={((map_object.position_y + yOffset)
                * zoomScale > 250
                || (map_object.position_y + yOffset)
                * zoomScale < -250
                || (map_object.position_x + xOffset)
                * zoomScale > 250
                || (map_object.position_x + xOffset)
                * zoomScale < -250)
                ? 5 * zoomScale
                : Math.max(5 * zoomScale, map_object.radius
                  * zoomScale)}
              stroke="#BBBBBB"
              stroke-width="1"
              fill="rgba(0,0,0,0)" />
            <line
              style={lineStyle}
              x1={Math.max(Math.min((map_object.position_x
                + xOffset
                + map_object.velocity_x * elapsed)
                * zoomScale, 250), -250)}
              y1={Math.max(Math.min((map_object.position_y
                + yOffset
                + map_object.velocity_y * elapsed)
                * zoomScale, 250), -250)}
              x2={Math.max(Math.min((map_object.position_x
                + xOffset
                + map_object.velocity_x * 10)
                * zoomScale, 250), -250)}
              y2={Math.max(Math.min((map_object.position_y
                + yOffset
                + map_object.velocity_y * 10)
                * zoomScale, 250), -250)} />
            <text
              x={Math.max(Math.min((map_object.position_x
                + xOffset
                + map_object.velocity_x * elapsed)
                * zoomScale, 200), -250)}
              y={Math.max(Math.min((map_object.position_y
                + yOffset
                + map_object.velocity_y * elapsed)
                * zoomScale, 250), -240)}
              fill="white"
              fontSize={Math.min(40 * lockedZoomScale, 14)}>
              {map_object.name}
            </text>
            {shuttleName !== map_object.name || (
              <line
                style={blueLineStyle}
                x1={Math.max(Math.min((map_object.position_x
                  + xOffset
                  + map_object.velocity_x * elapsed)
                  * zoomScale, 250), -250)}
                y1={Math.max(Math.min((map_object.position_y
                  + yOffset
                  + map_object.velocity_y * elapsed)
                  * zoomScale, 250), -250)}
                x2={Math.max(Math.min((map_object.position_x
                  + xOffset
                  + map_object.velocity_x * elapsed
                  + desired_vel_x * 10)
                  * zoomScale, 250), -250)}
                y2={Math.max(Math.min((map_object.position_y
                  + yOffset
                  + map_object.velocity_y * elapsed
                  + desired_vel_y * 10)
                  * zoomScale, 250), -250)} />
            )}
          </>
        ))};
        {/*
          Shuttle Target Locator
        */}
        {((shuttleTargetX || shuttleTargetY) && ourObject) && (
          <>
            <rect
              x={Math.max(Math.min((shuttleTargetX
                + xOffset - 25)
                * zoomScale, 250), -250)}
              y={Math.max(Math.min((shuttleTargetY
                + yOffset - 25)
                * zoomScale, 250), -250)}
              width={50 * zoomScale}
              height={50 * zoomScale}
              style={boxTargetStyle} />
            <line
              x1={Math.max(Math.min((shuttleTargetX
                + xOffset - 25)
                * zoomScale, 250), -250) + 25 * zoomScale}
              y1={Math.max(Math.min((shuttleTargetY
                + yOffset - 25)
                * zoomScale, 250), -250) - 25 * zoomScale}
              x2={Math.max(Math.min((shuttleTargetX
                + xOffset - 25)
                * zoomScale, 250), -250) + 25 * zoomScale}
              y2={Math.max(Math.min((shuttleTargetY
                + yOffset - 25)
                * zoomScale, 250), -250) + 75 * zoomScale}
              style={boxTargetStyle} />
            <line
              x1={Math.max(Math.min((shuttleTargetX
                + xOffset - 25)
                * zoomScale, 250), -250) - 25 * zoomScale}
              y1={Math.max(Math.min((shuttleTargetY
                + yOffset - 25)
                * zoomScale, 250), -250) + 25 * zoomScale}
              x2={Math.max(Math.min((shuttleTargetX
                + xOffset - 25)
                * zoomScale, 250), -250) + 75 * zoomScale}
              y2={Math.max(Math.min((shuttleTargetY
                + yOffset - 25)
                * zoomScale, 250), -250) + 25 * zoomScale}
              style={boxTargetStyle} />
            <line
              x1={Math.max(Math.min((ourObject.position_x
                + xOffset
                + ourObject.velocity_x * elapsed)
                * zoomScale, 250), -250)}
              y1={Math.max(Math.min((ourObject.position_y
                + yOffset
                + ourObject.velocity_y * elapsed)
                * zoomScale, 250), -250)}
              x2={Math.max(Math.min((shuttleTargetX
                + xOffset)
                * zoomScale, 250), -250)}
              y2={Math.max(Math.min((shuttleTargetY
                + yOffset)
                * zoomScale, 250), -250)}
              style={lineTargetStyle} />
          </>
        )}
        {ourObject && (
          <circle
            cx={Math.max(Math.min((ourObject.position_x
              + xOffset
              + ourObject.velocity_x * elapsed)
              * zoomScale, 250), -250)}
            cy={Math.max(Math.min((ourObject.position_y
              + yOffset
              + ourObject.velocity_y * elapsed)
              * zoomScale, 250), -250)}
            r={((ourObject.position_y + yOffset)
              * zoomScale > 250
              || (ourObject.position_y + yOffset)
              * zoomScale < -250
              || (ourObject.position_x + xOffset)
              * zoomScale > 250
              || (ourObject.position_x + xOffset)
              * zoomScale < -250)
              ? 5 * zoomScale
              : Math.max(5 * zoomScale, interdiction_range
                * zoomScale)}
            stroke="#00FF00"
            stroke-width="1"
            fill="rgba(0,0,0,0)" />
        )}
      </svg>
    );

    return children({
      svgComponent: svgComponent,
    });
  }
}
