import { useBackend, useLocalState } from '../backend';
import { Flex, Box, Button, Chart, Section, Table, Tabs } from '../components';
import { map } from 'common/collections';
import { NtosWindow } from '../layouts';

export const NtosDepartmentManager = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    managed_departments = [],
    selected_tab = "",
  } = data;

  const [
    selectedDepartment,
    setSelectedDepartment,
  ] = useLocalState(context, 'department', '');

  const [
    selectedTab,
    setSelectedTab,
  ] = useLocalState(context, 'selectedTab', 'funding');

  const functions = {
    "funding": <FundManager />,
  };

  return (
    <NtosWindow width={900} height={600}>
      <NtosWindow.Content>
        <Flex direction="column" height="100%">
          <Flex.Item>
            <Section>
              <Tabs>
                {managed_departments.map(department => (
                <Tabs.Tab
                  key={department.name}
                  selected={department.name === selectedDepartment}
                  onClick={() => setSelectedDepartment(department.name)}>
                    {department.name}
                </Tabs.Tab>))}
              </Tabs>
            </Section>
          </Flex.Item>
          <Flex.Item grow={1} >
            <Section
              title={
                <Tabs size={1}>
                  {Object.keys(functions).map(f => (
                    <Tabs.Tab
                      key={f}
                      selected={selectedTab === f}
                      onClick={() => {
                        setSelectedTab(f);
                        act('change_tab', {
                          tab: f,
                          department_id: managed_departments.find(x => x.name === selectedDepartment)?.id,
                        });
                      }}>
                      {f}
                    </Tabs.Tab>
                  ))}
                </Tabs>
              }
              width="100%"
              height="100%"
              overflowY="scroll">
              {managed_departments.find(x => x.name === selectedDepartment) && (selected_tab === selectedTab) && (selected_tab in functions) && functions[selected_tab]}
            </Section>
          </Flex.Item>
        </Flex>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const EmployeeManager = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    managed_departments = [],
  } = data;

  const [
    selectedDepartment,
    setSelectedDepartment,
  ] = useLocalState(context, 'department', '');

  return (
    <Table>
      <Table.Row>
        <Table.Cell bold width="40%">
          Name
        </Table.Cell>
        <Table.Cell bold width="20%">
          Rank
        </Table.Cell>
        <Table.Cell bold width="20%">
          Paycheck
        </Table.Cell>
        <Table.Cell bold width="20%">
          Action
        </Table.Cell>
      </Table.Row>
      {managed_departments
        .find(x => x.name === selectedDepartment)
        ?.members
        .map(member => (
          <Table.Row
            className="candystripe"
            key={member.name}>
            <Table.Cell width="40%">
              {member.name}
            </Table.Cell>
            <Table.Cell width="20%">
              <Button
                width="100%"
                content={member.rank}
                icon="user-shield" />
            </Table.Cell>
            <Table.Cell width="20%">
              <Button
                width="100%"
                content={member.payment}
                icon="pen" />
            </Table.Cell>
            <Table.Cell width="20%">
              <Button
                width="100%"
                color="red"
                content="Fire"
                icon="user-slash"
                onClick={() => act('fire_employee', {
                  id: member.id,
                  department_id: managed_departments.find(x => x.name === selectedDepartment)?.id,
                })} />
            </Table.Cell>
          </Table.Row>
        ))}
    </Table>
  );
};

const FundManager = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    managed_departments = [],
  } = data;

  const [
    selectedDepartment,
    setSelectedDepartment,
  ] = useLocalState(context, 'department', '');

  return (
    <>
      <Box height="120px" position="relative">
        <Chart.Line
          data={[[0, 50], [100, 0]]}
          rangeX={[0, 100]}
          rangeY={[0, 50]}
          strokeColor="rgba(217, 85, 85, 1)"
          fillColor="rgba(217, 85, 85, 0.25)"
          fillPositionedParent
        />
        <Chart.Line
          data={[[0, 0], [100, 50]]}
          rangeX={[0, 100]}
          rangeY={[0, 50]}
          strokeColor="rgba(214, 187, 114, 1)"
          fillColor="rgba(214, 187, 114, 0.25)"
          fillPositionedParent
        />
      </Box>
      <Table mt={2}>
        <Table.Row>
          <Table.Cell bold width="30%">
            Department
          </Table.Cell>
          <Table.Cell bold width="10%">
            Amount
          </Table.Cell>
          <Table.Cell bold width="10%">
            Time
          </Table.Cell>
          <Table.Cell bold width="50%">
            Reason
          </Table.Cell>
        </Table.Row>
        <Table.Row
          className="candystripe">
          <Table.Cell>
            Supply - `Medical Supplies Crate`
          </Table.Cell>
          <Table.Cell color="red">
            -(2000)
          </Table.Cell>
          <Table.Cell>
            8:50pm
          </Table.Cell>
          <Table.Cell>
            We have run out of medical supplies and need more.
          </Table.Cell>
        </Table.Row>
        <Table.Row
          className="candystripe">
          <Table.Cell>
            Burnard Silkwind - Medical Insurance
          </Table.Cell>
          <Table.Cell color="green">
            20
          </Table.Cell>
          <Table.Cell>
            6:20pm
          </Table.Cell>
          <Table.Cell>
            Standard medical insurance payment
          </Table.Cell>
        </Table.Row>
        <Table.Row
          className="candystripe">
          <Table.Cell>
            Elizibeth Green - Medical Insurance
          </Table.Cell>
          <Table.Cell color="green">
            20
          </Table.Cell>
          <Table.Cell>
            6:20pm
          </Table.Cell>
          <Table.Cell>
            Standard medical insurance payment
          </Table.Cell>
        </Table.Row>
      </Table>
    </>
  );
};

/*




*/
