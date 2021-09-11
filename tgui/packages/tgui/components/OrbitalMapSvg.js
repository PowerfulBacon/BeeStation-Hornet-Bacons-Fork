
import { clamp } from 'common/math';
import { pureComponentHooks } from 'common/react';
import { Component, createRef } from 'inferno';

const FPS = 20;
// Scales the positions to make things on the map appear closer or further away.
const mapDistanceScale = 1;

export class OrbitalMapSvg extends Component {
  constructor(props)
  {
    super(props);
    // Single instance objects is a dictionary
    // Key = object ID
    // Value = Object data
    this.state = {
      singleInstanceObjects: [],
      tickIndex: -1,
      tickTimer: new Date(),
      renderableObjectTypes: {},
    };
    this.renderTypeDict = {
      "broken": Broken,
      "default": RenderableObjectType,
      "planet": PlanettaryBody,
      "beacon": Beacon,
      "shuttle": Shuttle,
      "projectile": Projectile,
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
      renderableObjectTypes,
    } = state;
    // Fetch created and destroyed objects
    const {
      created_objects = [],
      destroyed_objects = [],
      currentUpdateIndex = -1,
      map_objects = [],
    } = props;
    // Don't update if we already updated for this tick
    if (currentUpdateIndex === tickIndex)
    {
      this.setState({
        internalElapsed: (new Date() - tickTimer) / 1000,
      });
      return;
    }

    // CREATION OF RENDERABLE OBJECT OBJECTS
    let newRenderableObjectTypes = {};

    // Boop: Create new map objects and persist old ones
    map_objects.forEach(mapObject => {
      newRenderableObjectTypes[mapObject.id]
        = renderableObjectTypes[mapObject.id]
        || new this.renderTypeDict[mapObject.render_mode];
      newRenderableObjectTypes[mapObject.id].onTick(
        mapObject.name,
        mapObject.position_x,
        mapObject.position_y,
        mapObject.velocity_x,
        mapObject.velocity_y,
        mapObject.radius,
      );
    });

    // =================================
    // SINGLE INSTANCE HANDLING
    // =================================

    // Clone the dictionary
    let outputInstances = [];
    for (const existingId in singleInstanceObjects) {
      if (!(existingId in destroyed_objects))
      {
        outputInstances.push(existingId);
      }
    }

    // Find differences in created objects
    created_objects.forEach(created_object => {
      // Ignore already made objects
      if (!(created_object.id in singleInstanceObjects))
      {
        // Create the object
        outputInstances.push(created_object.id);
        // Create the renderable object
        newRenderableObjectTypes[created_object.id]
          = new this.renderTypeDict[created_object.render_mode];
        // Initial variable setup
        newRenderableObjectTypes[created_object.id].onTick(
          created_object.name,
          created_object.position_x,
          created_object.position_y,
          created_object.velocity_x,
          created_object.velocity_y,
          created_object.radius,
        );
      }
    });

    // Tick any single instances still alive
    outputInstances.forEach(id => {
      let singleInstanceObject = newRenderableObjectTypes[id];
      singleInstanceObject.onTick(
        singleInstanceObject.name,
        singleInstanceObject.position_x + singleInstanceObject.velocity_x,
        singleInstanceObject.position_y + singleInstanceObject.velocity_y,
        singleInstanceObject.velocity_x,
        singleInstanceObject.velocity_y,
        singleInstanceObject.radius,
      );
    });

    // Update state
    this.setState({
      tickIndex: currentUpdateIndex,
      tickTimer: new Date(),
      internalElapsed: 0,
      singleInstanceObjects: outputInstances,
      renderableObjectTypes: newRenderableObjectTypes,
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
      tickIndex,
      internalElapsed,
      renderableObjectTypes,
    } = this.state;

    const {
      dragStartEvent,
      xOffset,
      yOffset,
      ourObject,
      interdiction_range = 0,
      shuttleTargetX = 0,
      shuttleTargetY = 0,
      zoomScale,
      shuttleName,
      currentUpdateIndex,
      children,
      desired_vel_x,
      desired_vel_y,
      lockedZoomScale,
    } = this.props;

    // Calculate elapsed here to not do a bunch of stupid updates.
    let elapsed = 0;

    // Calculate an elapsed time
    if (tickIndex === currentUpdateIndex)
    {
      elapsed = internalElapsed;
    }

    let svgComponent = (
      <svg
        onMouseDown={e => {
          dragStartEvent(e);
        }}
        viewBox="-250 -250 500 500"
        position="absolute"
        overflowY="hidden" >
        {this.getGridBackground()}
        {Object.values(renderableObjectTypes).map(render_object => (
          <>
            {render_object.generateComponentImage(
              xOffset,
              yOffset,
              elapsed,
              zoomScale,
              lockedZoomScale
            )}
            {(shuttleName === render_object.name
              && (desired_vel_x || desired_vel_y)) && (
              <line
                style={blueLineStyle}
                x1={Math.max(Math.min((render_object.position_x
                  + xOffset
                  + render_object.velocity_x * elapsed)
                  * zoomScale * mapDistanceScale, 250), -250)}
                y1={Math.max(Math.min((render_object.position_y
                  + yOffset
                  + render_object.velocity_y * elapsed)
                  * zoomScale * mapDistanceScale, 250), -250)}
                x2={Math.max(Math.min((render_object.position_x
                  + xOffset
                  + render_object.velocity_x * elapsed
                  + desired_vel_x * 10)
                  * zoomScale * mapDistanceScale, 250), -250)}
                y2={Math.max(Math.min((render_object.position_y
                  + yOffset
                  + render_object.velocity_y * elapsed
                  + desired_vel_y * 10)
                  * zoomScale * mapDistanceScale, 250), -250)} />
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
                * zoomScale * mapDistanceScale, 250), -250)}
              y1={Math.max(Math.min((ourObject.position_y
                + yOffset
                + ourObject.velocity_y * elapsed)
                * zoomScale * mapDistanceScale, 250), -250)}
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
            cx={(ourObject.position_x
              + xOffset
              + ourObject.velocity_x * elapsed)
              * zoomScale * mapDistanceScale}
            cy={(ourObject.position_y
              + yOffset
              + ourObject.velocity_y * elapsed)
              * zoomScale * mapDistanceScale}
            r={Math.max(5 * zoomScale, interdiction_range
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

// ===========================
// RENDER CLASSES
// ===========================

// DEFAULT TYPE
class RenderableObjectType {
  constructor() {
    this.name;
    this.position_x;
    this.position_y;
    this.velocity_x;
    this.velocity_y;
    this.radius;
    this.outlineColour = "#BBBBBB";
    this.outlineWidth = 1;
    this.fill = "rgba(0, 0, 0, 0)";
    this.textSize = 40;
    this.minSize = 5;
    this.fontFill = "white";
    this.lineStyle = {
      stroke: '#BBBBBB',
      strokeWidth: '2',
    };
    this.velocityLengthMult = 10;
    this.inBounds;
  }

  // Called every second
  // Updates the data
  onTick(name, position_x, position_y, velocity_x, velocity_y, radius)
  {
    this.name = name;
    this.position_x = position_x;
    this.position_y = position_y;
    this.velocity_x = velocity_x;
    this.velocity_y = velocity_y;
    this.radius = radius;
  }

  // Called on render()
  generateComponentImage(
    // Offset of the map
    xOffset,
    yOffset,
    // Elapsed time since last full update
    elapsed,
    // Zoom scale of the map
    zoomScale,
    lockedZoomScale,
  )
  {

    let outputXPosition = (this.position_x
      + xOffset
      + this.velocity_x * elapsed)
      * zoomScale * mapDistanceScale;
    let outputYPosition = (this.position_y
      + yOffset
      + this.velocity_y * elapsed)
      * zoomScale * mapDistanceScale;
    let outputRadius = this.radius * zoomScale;

    this.inBounds = outputXPosition < 250 && outputYPosition < 250
      && outputXPosition > -250 && outputYPosition > -250;

    if (!this.inBounds)
    {
      outputRadius = 5 * zoomScale;
      outputXPosition = clamp(outputXPosition, -250, 250);
      outputYPosition = clamp(outputYPosition, -250, 250);
    }

    let textXPos = clamp(outputXPosition, -250, 200);
    let textYPos = clamp(outputYPosition, -240, 250);

    return (
      <>
        <circle
          cx={outputXPosition}
          cy={outputYPosition}
          r={Math.max(outputRadius, this.minSize * zoomScale)}
          stroke={this.outlineColour}
          stroke-width={this.outlineWidth}
          fill={this.fill} />
        {this.inBounds && (
          <line
            style={this.lineStyle}
            x1={outputXPosition}
            y1={outputYPosition}
            x2={outputXPosition + (this.velocity_x * zoomScale)
               * this.velocityLengthMult}
            y2={outputYPosition + (this.velocity_y * zoomScale)
               * this.velocityLengthMult} />
        )}
        <text
          x={textXPos}
          y={textYPos}
          fill={this.fontFill}
          fontSize={Math.min(this.textSize * lockedZoomScale, 14)}>
          {this.name}
        </text>
      </>
    );
  }
}

// ===========================
// SUBTYPES
// ===========================

// Planets
class PlanettaryBody extends RenderableObjectType {
  constructor() {
    super();
    this.outlineColour = "#BBBBBB";
    this.outlineWidth = 1;
    this.fill = "rgba(0, 0, 0, 0)";
    this.textSize = 40;
    this.fontFill = "white";
    this.lineStyle = {
      stroke: '#BBBBBB',
      strokeWidth: '2',
    };
    this.velocityLengthMult = 10;
  }
}

// Beacons
class Beacon extends RenderableObjectType {
  constructor() {
    super();
    this.outlineColour = "#BBBBBB";
    this.outlineWidth = 1;
    this.fill = "rgba(0, 0, 0, 0)";
    this.textSize = 40;
    this.fontFill = "white";
    this.lineStyle = {
      stroke: '#BBBBBB',
      strokeWidth: '2',
    };
    this.velocityLengthMult = 10;
    this.beacon_radius = 500;
    this.beacon_colour = "#f58473";
    this.random_offset = Math.random();
  }

  // Called every render
  generateComponentImage(
    // Offset of the map
    xOffset,
    yOffset,
    // Elapsed time since last full update
    elapsed,
    // Zoom scale of the map
    zoomScale,
    lockedZoomScale,
  )
  {
    // Get the base look
    let baseStuff = RenderableObjectType.prototype.generateComponentImage.call(
      this, xOffset, yOffset, elapsed, zoomScale, lockedZoomScale);

    let outputXPosition = (this.position_x
      + xOffset
      + this.velocity_x * elapsed)
      * zoomScale * mapDistanceScale;
    let outputYPosition = (this.position_y
      + yOffset
      + this.velocity_y * elapsed)
      * zoomScale * mapDistanceScale;

    let beaconTimer = ((elapsed + this.random_offset) % 1);

    return (
      <>
        {baseStuff}
        <circle
          cx={outputXPosition}
          cy={outputYPosition}
          r={this.beacon_radius * beaconTimer
            * zoomScale}
          stroke={this.beacon_colour}
          stroke-width={this.outlineWidth}
          fill={this.fill}
          style={{
            opacity: 0.8 * (1 - beaconTimer),
          }} />
      </>
    );
  }
}

// Shuttles
class Shuttle extends RenderableObjectType {
  constructor() {
    super();
    this.outlineColour = "#a4eea4";
    this.fontFill = "#a4eea4";
    this.lineStyle = {
      stroke: '#a4eea4',
      strokeWidth: '2',
      opacity: 0.5,
    };
    this.thinLineStyle = {
      stroke: '#a4eea4',
      strokeWidth: '0.5',
      opacity: 0.5,
    };
    // Draw a path line
    // Circular queue since javascript handles arrays kinda poorly.
    this.recordedTrack = [
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
      { x: 0, y: 0 },
    ];
    this.recordedTrackLength = 20;
    this.recordedTrackLastIndex = 0;
    this.recordedTrackStartIndex = 0;
  }

  // Called every updateTick
  // Record the path and update variables.
  onTick(name, position_x, position_y, velocity_x, velocity_y, radius)
  {
    // wtf is this
    RenderableObjectType.prototype.onTick.call(
      this, name, position_x, position_y, velocity_x, velocity_y, radius);
    // Set the position
    this.recordedTrack[this.recordedTrackLastIndex] = {
      x: this.position_x,
      y: this.position_y,
    };

    // Add the new point to the path map
    if ((this.recordedTrackLastIndex + 1) % this.recordedTrackLength
      === this.recordedTrackStartIndex)
    {
      // End index is 1 before the start index, move both forward 1
      this.recordedTrackLastIndex = (this.recordedTrackLastIndex + 1)
        % this.recordedTrackLength;
      this.recordedTrackStartIndex = (this.recordedTrackStartIndex + 1)
      % this.recordedTrackLength;
    }
    else
    {
      // Move just the last position forward
      this.recordedTrackLastIndex = (this.recordedTrackLastIndex + 1)
        % this.recordedTrackLength;
    }
  }

  // Called every render
  generateComponentImage(
    // Offset of the map
    xOffset,
    yOffset,
    // Elapsed time since last full update
    elapsed,
    // Zoom scale of the map
    zoomScale,
    lockedZoomScale,
  )
  {

    let outputXPosition = (this.position_x
      + xOffset
      + this.velocity_x * elapsed)
      * zoomScale * mapDistanceScale;
    let outputYPosition = (this.position_y
      + yOffset
      + this.velocity_y * elapsed)
      * zoomScale * mapDistanceScale;
    let outputRadius = this.radius * zoomScale;

    this.inBounds = outputXPosition < 250 && outputYPosition < 250
      && outputXPosition > -250 && outputYPosition > -250;

    if (!this.inBounds)
    {
      outputRadius = 5 * zoomScale;
      outputXPosition = clamp(outputXPosition, -250, 250);
      outputYPosition = clamp(outputYPosition, -250, 250);
    }

    // Calculate Path
    let path = [];

    let highestOpacity = 0;
    let opacityIndex = 0;

    for (let i = (this.recordedTrackStartIndex + 1) % this.recordedTrackLength;
      i !== this.recordedTrackLastIndex;
      i = (i + 1) % this.recordedTrackLength)
    {
      let firstPoint = this.recordedTrack[(i + this.recordedTrackLength - 1)
        % this.recordedTrackLength];
      let secondPoint = this.recordedTrack[i];
      highestOpacity = (opacityIndex / this.recordedTrackLength) * 0.5;
      opacityIndex ++;
      path.push({
        x1: (firstPoint.x + xOffset) * zoomScale * mapDistanceScale,
        y1: (firstPoint.y + yOffset) * zoomScale * mapDistanceScale,
        x2: (secondPoint.x + xOffset) * zoomScale * mapDistanceScale,
        y2: (secondPoint.y + yOffset) * zoomScale * mapDistanceScale,
        opacity: highestOpacity,
      });
    }

    if (path.length)
    {
      path.push({
        x1: path[path.length - 1].x2,
        y1: path[path.length - 1].y2,
        x2: outputXPosition,
        y2: outputYPosition,
        opacity: highestOpacity,
      });
    }

    if (!this.inBounds)
    {
      outputRadius = 5;
      outputXPosition = clamp(outputXPosition, -250, 250);
      outputYPosition = clamp(outputYPosition, -250, 250);
    }

    return (
      <>
        <circle
          cx={outputXPosition}
          cy={outputYPosition}
          r={Math.max(outputRadius, this.minSize * zoomScale)}
          stroke={this.outlineColour}
          stroke-width={this.outlineWidth}
          fill={this.fill} />
        {this.inBounds && (
          <line
            style={this.lineStyle}
            x1={outputXPosition}
            y1={outputYPosition}
            x2={outputXPosition + (this.velocity_x * zoomScale)
               * this.velocityLengthMult}
            y2={outputYPosition + (this.velocity_y * zoomScale)
               * this.velocityLengthMult} />
        )}
        <text
          x={clamp(outputXPosition, -250, 200) + 5 * zoomScale}
          y={clamp(outputYPosition, -240, 250) + 15 * zoomScale}
          fill={this.fontFill}
          fontSize={Math.min(this.textSize * lockedZoomScale, 14)}>
          {this.name}
        </text>
        {(this.velocity_x || this.velocity_y) && (
          <text
            x={clamp(outputXPosition, -250, 200) + 5 * zoomScale}
            y={clamp(outputYPosition, -240, 250) + 15 * zoomScale
              + clamp(this.textSize * zoomScale + 2, 8, 16)}
            fill={this.fontFill}
            fontSize={Math.min(this.textSize * lockedZoomScale, 14)}>
            {Math.round(Math.sqrt(this.velocity_x * this.velocity_x
              + this.velocity_y * this.velocity_y) * 100) / 100} bkts.
          </text>
        )}
        {path.map(point => (
          <line
            key={point.x1}
            style={{
              stroke: '#a4eea4',
              strokeWidth: '0.5',
              opacity: point.opacity,
            }}
            x1={point.x1}
            y1={point.y1}
            x2={point.x2}
            y2={point.y2} />
        ))}
      </>
    );
  }
}

// Projectiles
class Projectile extends RenderableObjectType {
  constructor() {
    super();
    this.outlineColour = "#BBBBBB";
    this.outlineWidth = 1;
    this.fill = "rgba(0, 0, 0, 0)";
    this.textSize = 40;
    this.fontFill = "white";
    this.lineStyle = {
      stroke: '#BBBBBB',
      strokeWidth: '2',
    };
    this.velocityLengthMult = 10;
  }
}

// Broken
class Broken extends RenderableObjectType {
  constructor() {
    super();
    this.outlineColour = "#FF0000";
    this.outlineWidth = 1;
    this.fill = "rgba(255, 0, 0, 0)";
    this.textSize = 40;
    this.fontFill = "red";
    this.lineStyle = {
      stroke: '#FF0000',
      strokeWidth: '2',
    };
    this.velocityLengthMult = 10;
  }
}
