
import { clamp } from 'common/math';
import { pureComponentHooks } from 'common/react';
import { Component, createRef } from 'inferno';

export class OrbitalMapSvg extends Component {
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
      dragStartEvent,
      scaledXOffset,
      scaledYOffset,
      xOffset,
      yOffset,
      ourObject,
      lockedZoomScale,
      map_objects,
      elapsed,
      interdiction_range = 0,
      shuttleTargetX = 0,
      shuttleTargetY = 0,
      zoomScale,
      shuttleName,
      children,
    } = this.props;

    let svgComponent = (
      <svg
        onMouseDown={e => {
          dragStartEvent(e);
        }}
        viewBox="-250 -250 500 500"
        position="absolute"
        overflowY="hidden" >
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
        {map_objects.map(map_object => (
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
