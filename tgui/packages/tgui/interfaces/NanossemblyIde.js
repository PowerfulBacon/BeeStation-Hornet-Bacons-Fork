import { useBackend, useLocalState } from '../backend';
import { Grid, Section, TextArea, Box, Table, Button, Fragment } from '../components';
import { Window } from '../layouts';

export const NanossemblyIde = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    screenData = "error",
    lines = [],
    output = [],
  } = data;
  return (
    <Window
      width={1080}
      height={720}
      resizeable>
      <Window.Content height="100%">
        <Table height="100%">
          <Table.Cell width="50%" height="100%">
            <Section
              width="100%"
              height="calc(100% - 220px)"
              title={
                <>
                  <Button
                    content="Instruction Help"
                    icon="question-circle"
                    onClick={() => act('setScreen', {
                      screen: "help",
                    })} />
                  <Button
                    content="Memory State"
                    icon="tools"
                    onClick={() => act('setScreen', {
                      screen: "state",
                    })} />
                </>
              }
              overflowY="scroll">
              {screenData.map(line => (
                <Box key={line}>
                  {line}
                </Box>
              ))}
            </Section>
            <Section
              width="100%"
              height="200px"
              title="Console Output"
              overflowY="scroll">
              {output.map(line => (
                <Box key={line}>
                  {line}
                </Box>
              ))}
            </Section>
          </Table.Cell>
          <Table.Cell width="50%" height="100%">
            <Box width="100%" height="30px">
              <Button
                inline
                content="Compile"
                onClick={() => act('compile')}
                icon="microchip" />
              <Button
                inline
                content="Step"
                onClick={() => act('step')}
                icon="step-forward" />
            </Box>
            <TextArea
              width="100%"
              height="calc(100% - 50px)"
              onChange={(e, value) => act('setProgramText', {
                text: value,
              })} />
          </Table.Cell>
        </Table>
      </Window.Content>
    </Window>
  );
};
