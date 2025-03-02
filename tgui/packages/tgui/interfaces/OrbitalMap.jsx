// :fearful:

// Made by powerfulbacon

import { Box, Button, Section, Table, DraggableClickableControl, Dropdown, Divider, NoticeBox, ProgressBar, Flex, OrbitalMapComponent, OrbitalMapSvg, Knob } from '../components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';
import { useRef } from 'react';
import { PrimaryFlightDisplay } from 'tgui/components/aviation/PrimaryFlightDisplay';
import { classes } from 'common/react';

export const OrbitalMap = (props) => {
  const { act, data } = useBackend();
  const {
    map_objects = [],
    linkedToShuttle = false,
    canLaunch = false,
    recall_docking_port_id = '',
    thrust_alert = false,
    damage_alert = false,
    shuttleName = '',
    designatorInserted = false,
    designatorId = null,
    shuttleId = null,
    landingGear = 0,
    powered = false,
  } = data;
  const [zoomScale, setZoomScale] = useLocalState('zoomScale', 1);
  const [xOffset, setXOffset] = useLocalState('xOffset', 0);
  const [yOffset, setYOffset] = useLocalState('yOffset', 0);
  const [trackedBody, setTrackedBody] = useLocalState('trackedBody', shuttleName);

  const radarRef = useRef(null);

  let dynamicXOffset = xOffset;
  let dynamicYOffset = yOffset;

  let trackedObject = null;
  let ourObject = null;
  let firstObjectName = 'null';
  if (map_objects.length > 0) {
    firstObjectName = map_objects[1].name;
    // Find the right tracked body
    map_objects.forEach((element) => {
      if (element.name === shuttleName) {
        ourObject = element;
      }
      if (element.name === trackedBody && !trackedObject) {
        trackedObject = element;
        if (trackedBody !== map_objects[0].name) {
          dynamicXOffset = trackedObject.position_x + trackedObject.velocity_x;
          dynamicYOffset = trackedObject.position_y + trackedObject.velocity_y;
        }
      }
    });
  }

  return (
    <Window width={1315} height={640}>
      <Window.Content fitted>
        <Flex height="100%">
          <Flex.Item class="OrbitalMap__radar" grow id="radar" innerRef={radarRef}>
            <PrimaryFlightDisplay />
          </Flex.Item>
          <Flex.Item class="OrbitalMap__panel">
            <div class="OrbitalMap__label">Heading</div>
            <div class="OrbitalMap__dial">
              <Knob
                color="yellow"
                fullRotation
                noRing
                offset={180}
                minValue={0}
                maxValue={360}
                step={10}
                stepPixelSize={10}
                value={50}
              />
              <div class="OrbitalMap__indicator">{powered && <>050</>}</div>
            </div>
            <div class="OrbitalMap__label">Altitude</div>
            <div class="OrbitalMap__dial">
              <Knob
                color="yellow"
                fullRotation
                noRing
                offset={180}
                minValue={0}
                maxValue={360}
                step={10}
                stepPixelSize={10}
                value={50}
              />
              <div class="OrbitalMap__indicator">{powered && 18000}</div>
            </div>
            <div class="OrbitalMap__label">Speed</div>
            <div class="OrbitalMap__dial">
              <Knob
                color="yellow"
                fullRotation
                noRing
                offset={180}
                minValue={0}
                maxValue={360}
                step={10}
                stepPixelSize={10}
                value={50}
              />
              <div class="OrbitalMap__indicator">{powered && 180}</div>
            </div>
            <div class={classes(['OrbitalMap__light', !powered && 'bad', !powered && 'flashing'])}>
              <div>APU</div>
            </div>
            <div class="OrbitalMap__button">
              <div>APU</div>
              <div>TOGGLE</div>
            </div>
            <div
              class="OrbitalMap__button"
              onClick={() => {
                act('launch');
              }}>
              <div>LAUNCH</div>
            </div>
            <div
              class={classes(['OrbitalMap__light', landingGear === 1 && 'bad', landingGear === 0 && 'off', !powered && 'off'])}>
              <div>GEAR</div>
              <div>DOWN</div>
            </div>
            <div class="OrbitalMap__light off">
              <div>TOO</div>
              <div>FAST</div>
            </div>
            <div
              class="OrbitalMap__button"
              onClick={() => {
                act('toggleGear');
              }}>
              GEAR
            </div>
            <div class="OrbitalMap__light off">
              <div>ORBIT</div>
              <div>THRUST</div>
            </div>
            <div class="OrbitalMap__button">ORBIT</div>
          </Flex.Item>
          <Flex.Item grow class="OrbitalMap__map">
            <OrbitalMapDisplay
              dynamicXOffset={dynamicXOffset}
              dynamicYOffset={dynamicYOffset}
              isTracking={trackedBody !== map_objects[0].name}
              zoomScale={zoomScale}
              setZoomScale={setZoomScale}
              setTrackedBody={setTrackedBody}
              ourObject={ourObject}
              radarRef={radarRef}
            />
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

export const OrbitalMapDisplay = (props) => {
  const {
    zoomScale,
    setZoomScale,
    setTrackedBody,
    ourObject,
    isTracking = false,
    dynamicXOffset,
    dynamicYOffset,
    radarRef,
  } = props;

  const [offset, setOffset] = useLocalState('offset', [0, 0]);

  let lockedZoomScale = Math.max(Math.min(zoomScale, 4), 0.125);

  const { act, data } = useBackend();

  const {
    map_objects = [],
    shuttleName = '',
    validDockingPorts = [],
    isDocking = false,
    interdiction_range = 150,
    shuttleTargetX = 0,
    shuttleTargetY = 0,
    update_index = 0,
    powered = false,
  } = data;

  return (
    <>
      <Button
        position="absolute"
        icon="search-plus"
        right="20px"
        top="15px"
        fontSize="18px"
        color="grey"
        onClick={() => setZoomScale(zoomScale * 2)}
      />
      <Button
        position="absolute"
        icon="search-minus"
        right="20px"
        top="47px"
        fontSize="18px"
        color="grey"
        onClick={() => setZoomScale(zoomScale / 2)}
      />
      {!isDocking || (
        <NoticeBox
          position="absolute"
          color="red"
          top="50px"
          left="calc(50% - 150px)"
          width="300px"
          textAlign="center"
          fontSize="14px">
          <>
            <NoticeBox mt={1}>DOCKING PROTOCOL ONLINE, FLIGHT DISABLED - SELECT DESTINATION.</NoticeBox>
            <Dropdown
              mt={1}
              selected="Select Docking Location"
              width="100%"
              options={validDockingPorts.map((map_object) => {
                return {
                  displayText: map_object.name,
                  value: map_object.id,
                };
              })}
              displayText="Select Docking Location"
              onSelected={(value) =>
                act('gotoPort', {
                  port: value,
                })
              }
            />
          </>
        </NoticeBox>
      )}
      <OrbitalMapComponent
        position="absolute"
        step={1}
        stepPixelSize={2 * zoomScale}
        onDrag={(e, valueX, valueY) => {
          setOffset([valueX, valueY]);
          setTrackedBody(map_objects[0].name);
        }}
        valueX={isTracking ? dynamicXOffset : offset[0]}
        valueY={isTracking ? dynamicYOffset : offset[1]}
        isTracking={isTracking}
        dynamicXOffset={dynamicXOffset}
        dynamicYOffset={dynamicYOffset}
        currentUpdateIndex={update_index}
        onClick={(e, xOffset, yOffset) => {
          const radar = radarRef?.current;
          if (!radar) {
            return;
          }
          const rect = radar.getBoundingClientRect();
          let proportionalX = ((e.clientX - rect.left) / radar.offsetWidth) * 500;
          let proportionalY = ((e.clientY - rect.top) / radar.offsetHeight) * 500;
          act('setTargetCoords', {
            x: (proportionalX - 250) / zoomScale + (isTracking ? dynamicXOffset : xOffset),
            y: (proportionalY - 250) / zoomScale + (isTracking ? dynamicYOffset : yOffset),
          });
        }}>
        {(control) =>
          powered ? (
            <OrbitalMapSvg
              scaledXOffset={-control.xOffset * zoomScale}
              scaledYOffset={-control.yOffset * zoomScale}
              xOffset={-control.xOffset}
              yOffset={-control.yOffset}
              ourObject={ourObject}
              lockedZoomScale={lockedZoomScale}
              map_objects={map_objects}
              interdiction_range={interdiction_range}
              shuttleTargetX={shuttleTargetX}
              shuttleTargetY={shuttleTargetY}
              dragStartEvent={(e) => control.handleDragStart(e)}
              zoomScale={zoomScale}
              shuttleName={shuttleName}
              currentUpdateIndex={update_index}>
              {(control) => control.svgComponent}
            </OrbitalMapSvg>
          ) : (
            <div class="OrbitalMap__off_screen">No power</div>
          )
        }
      </OrbitalMapComponent>
    </>
  );
};

export const RecallControl = (props) => {
  const { act, data } = useBackend();
  const { request_shuttle_message } = data;
  return (
    <>
      <NoticeBox>Manual control disabled, this location can only recall the shuttle.</NoticeBox>
      <Button
        content={request_shuttle_message}
        textAlign="center"
        fontSize="30px"
        icon="rocket"
        width="100%"
        height="50px"
        onClick={() => act('callShuttle')}
      />
    </>
  );
};

export const ShuttleControls = (props) => {
  const { act, data } = useBackend();
  const {
    map_objects = [],
    shuttleTarget = null,
    shuttleAngle = 0,
    shuttleThrust = 0,
    canDock = false,
    isDocking = false,
    display_fuel = false,
    fuel = 0,
    display_stats = [],
    autopilot_enabled = false,
  } = data;
  // Sort the map objects by priority
  let sortedMapObjects = map_objects.sort((first, second) => {
    return second.priority - first.priority;
  });
  return (
    <>
      <Box bold>Autopilot Target</Box>
      <Dropdown
        mt={1}
        selected={shuttleTarget}
        width="100%"
        options={sortedMapObjects.map((map_object) => map_object.name)}
        onSelected={(value) =>
          act('setTarget', {
            target: value,
          })
        }
      />
      <Box mt={1}>Velocity line will be adjusted to relative speed of this orbital body.</Box>
      <ShuttleMap />
      <NoticeBox color="purple" mt={2}>
        Click on the primary display to fly.
      </NoticeBox>
      <Box bold>Throttle</Box>
      <Box>Shuttle Thrust: {shuttleThrust}</Box>
      <Box bold mt={2}>
        Thrust Angle
      </Box>
      <Box>Angle: {shuttleAngle}</Box>
      {!display_fuel || (
        <>
          <Box bold mt={2}>
            Fuel Remaining
          </Box>
          <ProgressBar value={fuel}>{fuel} moles.</ProgressBar>
        </>
      )}
      <Table mt={2}>
        {Object.keys(display_stats).map((value) => (
          <Table.Row key={value}>
            <Table.Cell bold>{value} :</Table.Cell>
            <Table.Cell textAlign="right">{display_stats[value]}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
      <Button mt={2} content="Toggle Autopilot" onClick={() => act('nautopilot')} color={autopilot_enabled ? 'green' : 'red'} />
      {!(canDock && !isDocking) || <Button mt={2} content="Initiate Docking" onClick={() => act('dock')} />}
      <Button mt={2} content="ENGAGE INTERDICTOR" onClick={() => act('interdict')} color="purple" />
    </>
  );
};

export const ShuttleMap = (props) => {
  const lineStyle = {
    stroke: '#BBBBBB',
    strokeWidth: '2',
  };
  const velLineStyle = {
    stroke: '#00FF00',
    strokeWidth: '2',
  };
  const { act, data } = useBackend();
  const { shuttleAngle = 0, shuttleThrust = 0, shuttleVelX = 0, shuttleVelY = 0 } = data;
  let x = (shuttleThrust + 30) * Math.cos(shuttleAngle * ((2 * Math.PI) / 360));
  let y = (shuttleThrust + 30) * Math.sin(shuttleAngle * ((2 * Math.PI) / 360));
  return (
    <Box width="370px" height="160px">
      <svg position="absolute" height="100%" viewBox="-100 -100 200 200">
        <defs>
          <pattern id="grid" width={200} height={200} patternUnits="userSpaceOnUse">
            <rect width={200} height={200} fill="url(#smallgrid)" />
            <path d={'M 200 0 L 0 0 0 200'} fill="none" stroke="#4665DE" stroke-width="1" />
          </pattern>
          <pattern id="smallgrid" width={100} height={100} patternUnits="userSpaceOnUse">
            <rect width={100} height={100} fill="#2B2E3B" />
            <path d={'M 100 0 L 0 0 0 100'} fill="none" stroke="#4665DE" stroke-width="0.5" />
          </pattern>
        </defs>
        <rect x="-50%" y="-50%" width="100%" height="100%" fill="url(#grid)" />
        <circle r="30px" stroke="#BBBBBB" stroke-width="1" fill="rgba(0,0,0,0)" />
        <line x1={0} y1={0} x2={x} y2={y} style={lineStyle} />
        <line x1={0} y1={0} x2={shuttleVelX} y2={shuttleVelY} style={velLineStyle} />
      </svg>
    </Box>
  );
};
