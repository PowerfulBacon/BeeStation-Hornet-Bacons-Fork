
import { Box, Button, Section, Table, DraggableClickableControl, Dropdown, Divider, NoticeBox, Slider, ProgressBar, Fragment, ScrollableBox, OrbitalMapComponent, OrbitalMapSvg, Grid } from '../components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

export const OrbitalWeaponMap = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    map_objects = [],
    shuttleName = "",
    interdictionTime = 0,
    weapon_systems = [],
  } = data;
  const [
    zoomScale,
    setZoomScale,
  ] = useLocalState(context, 'zoomScale', 1);
  const [
    xOffset,
    setXOffset,
  ] = useLocalState(context, 'xOffset', 0);
  const [
    yOffset,
    setYOffset,
  ] = useLocalState(context, 'yOffset', 0);
  const [
    trackedBody,
    setTrackedBody,
  ] = useLocalState(context, 'trackedBody', shuttleName);

  let dynamicXOffset = xOffset;
  let dynamicYOffset = yOffset;

  let trackedObject = null;
  let ourObject = null;
  if (map_objects.length > 0 && interdictionTime === 0)
  {
    // Find the right tracked body
    map_objects.forEach(element => {
      if (element.name === shuttleName)
      {
        ourObject = element;
      }
      if (element.name === trackedBody && !trackedObject)
      {
        trackedObject = element;
        if (trackedBody !== map_objects[0].name)
        {
          dynamicXOffset = trackedObject.position_x
           + trackedObject.velocity_x;
          dynamicYOffset = trackedObject.position_y
           + trackedObject.velocity_y;
        }
      }
    });
  }

  return (
    <Window
      width={1136}
      height={770}
      resizable
      overflowY="hidden">
      <Window.Content overflowY="hidden">
        <div class="OrbitalMap__radar" id="radar">
          <OrbitalWeaponMapDisplay
            dynamicXOffset={dynamicXOffset}
            dynamicYOffset={dynamicYOffset}
            isTracking={map_objects.length > 0
              ? trackedBody !== map_objects[0].name : false}
            zoomScale={zoomScale}
            setZoomScale={setZoomScale}
            setTrackedBody={setTrackedBody}
            ourObject={ourObject} />
        </div>
        <div class="OrbitalMap__panel">
          <ScrollableBox overflowY="scroll" height="100%">
            <Section title="Orbital Body Tracking">
              <Box bold>
                Tracking
              </Box>
              <Box mb={1}>
                {trackedBody}
              </Box>
              <Box>
                <b>
                  X:&nbsp;
                </b>
                {trackedObject && trackedObject.position_x}
              </Box>
              <Box>
                <b>
                  Y:&nbsp;
                </b>
                {trackedObject && trackedObject.position_y}
              </Box>
              <Box>
                <b>
                  Velocity:&nbsp;
                </b>
                ({trackedObject && trackedObject.velocity_x}
                , {trackedObject && trackedObject.velocity_y})
              </Box>
              <Box>
                <b>
                  Radius:&nbsp;
                </b>
                {trackedObject && trackedObject.radius} BSU
              </Box>
              <Divider />
              <Dropdown
                selected={trackedBody}
                width="100%"
                color="grey"
                options={map_objects.map(map_object => (map_object.name))}
                onSelected={value => setTrackedBody(value)} />
            </Section>
            <Divider />
            <Section title="Weapon System Control Panel">
              {weapon_systems.map(weapon_system => (
                <WeaponDisplay
                  key={weapon_system.weaponId}
                  weaponId={weapon_system.weaponId}
                  weaponName={weapon_system.weaponName}
                  ammo={weapon_system.ammo}
                  maxAmmo={weapon_system.maxAmmo}
                  weaponEnabled={weapon_system.weaponEnabled}
                  energyAmmunition={weapon_system.energyAmmunition}
                  weaponSelected={weapon_system.weaponSelected} />
              ))}
            </Section>
          </ScrollableBox>
        </div>
      </Window.Content>
    </Window>
  );
};

export const WeaponDisplay = (props, context) => {

  const { act } = useBackend(context);

  const {
    weaponId,
    weaponName,
    ammo,
    maxAmmo,
    weaponEnabled,
    weaponSelected,
    energyAmmunition,
  } = props;

  const outlined = {
    outline: "#dec443 solid 3px",
    margin: "auto",
  };

  return (
    <Section
      fontSize={0.9}
      style={weaponSelected ? outlined : null}
      title={
        <Fragment width="100%" >
          <Box inline width="90%"
            textColor={weaponEnabled ? "default" : "red"}>
            {weaponName}
          </Box>
          <Button
            icon={weaponEnabled ? "toggle-on" : "toggle-off"}
            color="transparent"
            textColor={weaponEnabled ? "default" : "red"}
            onClick={e => act("toggle_weapon", {
              weapon_id: weaponId,
            })} />
        </Fragment>
      }
      width="49%"
      className="Button" >
      <Fragment>
        <Box fontSize={1}>
          <Table>
            <Table.Row>
              <Table.Cell bold>
                Ammunition
              </Table.Cell>
              <Table.Cell width="100%">
                <ProgressBar
                  value={ammo}
                  maxValue={maxAmmo}
                  width="100%">
                  {weaponEnabled ? energyAmmunition
                    ? ((ammo / maxAmmo * 100) + "%")
                    : ammo + " / " + maxAmmo
                    : "Offline"}
                </ProgressBar>
              </Table.Cell>
            </Table.Row>
          </Table>
        </Box>
        <NoticeBox mt={1}
          color={weaponEnabled ? weaponSelected ? "green" : "blue" : "red"}>
          <Button
            content={weaponEnabled ? weaponSelected
              ? "!! ONLINE !!" : "SELECT" : "Disabled"}
            width="100%"
            color="transparent"
            textColor="white"
            bold
            onClick={e => {
              if (weaponEnabled && !weaponSelected)
              {
                act("selectWeapon", {
                  weapon_id: weaponId,
                });
              }
            }} />
        </NoticeBox>

      </Fragment>
    </Section>
  );
};

export const OrbitalWeaponMapDisplay = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    zoomScale,
    setZoomScale,
    setTrackedBody,
    ourObject,
    isTracking = false,
    dynamicXOffset,
    dynamicYOffset,
  } = props;

  const [
    offset,
    setOffset,
  ] = useLocalState(context, 'offset', [0, 0]);

  const {
    map_objects = [],
    shuttleName = "",
    update_index = 0,
    created_objects = [],
    destroyed_objects = [],
    interdictionTime = 0,
  } = data;

  let lockedZoomScale = Math.max(Math.min(zoomScale, 4), 0.125);

  return (
    <Fragment>
      <Button
        position="absolute"
        icon="search-plus"
        right="20px"
        top="15px"
        fontSize="18px"
        color="grey"
        onClick={() => setZoomScale(zoomScale * 2)} />
      <Button
        position="absolute"
        icon="search-minus"
        right="20px"
        top="47px"
        fontSize="18px"
        color="grey"
        onClick={() => setZoomScale(zoomScale / 2)} />
      <OrbitalMapComponent
        position="absolute"
        step={1}
        stepPixelSize={2 * zoomScale}
        onDrag={(e, valueX, valueY) => {}}
        valueX={isTracking ? dynamicXOffset : offset[0]}
        valueY={isTracking ? dynamicYOffset : offset[1]}
        isTracking={isTracking}
        dynamicXOffset={dynamicXOffset}
        dynamicYOffset={dynamicYOffset}
        currentUpdateIndex={update_index}
        onClick={(e, xOffset, yOffset) => {
          let clickedOnDiv = document.getElementById("radar"); // This is kind
          // of funky but A) I don't know react / javascript and B) Nobody in
          // the history of the universe knows react / javascript so nobody
          // will probably ever read this so I'm good.
          let proportionalX = e.offsetX / clickedOnDiv.offsetWidth * 500;
          let proportionalY = (e.offsetY - 30) / clickedOnDiv.offsetHeight
            * 500;
          act("fireAtCoordinates", {
            x: (proportionalX - 250) / zoomScale + (isTracking
              ? dynamicXOffset : xOffset),
            y: (proportionalY - 250) / zoomScale + (isTracking
              ? dynamicYOffset : yOffset),
          });
        }} >
        {control => (
          <OrbitalMapSvg
            scaledXOffset={-control.xOffset * zoomScale}
            scaledYOffset={-control.yOffset * zoomScale}
            xOffset={-control.xOffset}
            yOffset={-control.yOffset}
            ourObject={ourObject}
            lockedZoomScale={lockedZoomScale}
            map_objects={map_objects}
            dragStartEvent={e => control.handleDragStart(e)}
            zoomScale={zoomScale}
            shuttleName={shuttleName}
            created_objects={created_objects}
            destroyed_objects={destroyed_objects}
            currentUpdateIndex={update_index}>
            {control => (
              control.svgComponent
            )}
          </OrbitalMapSvg>
        )}
      </OrbitalMapComponent>
    </Fragment>
  );

};
