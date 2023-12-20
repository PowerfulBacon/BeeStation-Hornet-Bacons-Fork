import { useBackend, useLocalState } from '../backend';
import { Dropdown, Input, Flex, Box, Button, Chart, Section, Table, Tabs } from '../components';
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
    "employee": <EmployeeManager />,
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
                  onClick={() => {
                    setSelectedDepartment(department.name);
                    act('change_department', {
                      department_id: department.id,
                    });
                  }}>
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
    selected_tab_data,
  } = data;

  const {
    members = [],
  } = selected_tab_data;

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
      {members
        .map(member => (
          <Table.Row
            className="candystripe"
            key={member.name}>
            <Table.Cell width="40%">
              {member.name}
            </Table.Cell>
            <Table.Cell width="20%">
              <Dropdown
                width="100%"
                selected={member.rank}
                overflow-y="scroll"
                options={[
                  "employee",
                  "manager",
                  "administrator",
                ]}
                icon="user-shield"
                onSelected={(e, val) => act('set_rank', {
                  id: member.id,
                  rank: val,
                })} />
            </Table.Cell>
            <Table.Cell width="20%">
              <Input
                width="100%"
                value={member.paycheck}
                icon="pen"
                onInput={(e, val) => act('set_paycheck', {
                  id: member.id,
                  amount: val,
                })} />
            </Table.Cell>
            <Table.Cell width="20%">
              <Button
                width="100%"
                color="red"
                content="Fire"
                icon="user-slash"
                onClick={() => act('fire_employee', {
                  id: member.id,
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
    selected_tab_data,
  } = data;

  const {
    transactions = [],
  } = selected_tab_data;

  return (
    <>
      <Box height="120px" position="relative">
        <Chart.Line
          data={transactions.map(x => [x.tick, x.total_money])}
          rangeX={[Math.min.apply(null, transactions.map(x => x.tick)), Math.max.apply(null, transactions.map(x => x.tick))]}
          rangeY={[Math.min.apply(null, transactions.map(x => x.total_money)) - 500, Math.max.apply(null, transactions.map(x => x.total_money)) + 500]}
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
        {transactions.map(trans => (
          <Table.Row
            key={trans.purchase + "-" + trans.time}
            className="candystripe">
            <Table.Cell>
              {trans.purchase}
            </Table.Cell>
            <Table.Cell color={trans.amount > 0 ? "green" : "red"}>
              {trans.amount > 0 ? trans.amount : ("(" + trans.amount + ")")}
            </Table.Cell>
            <Table.Cell>
              {trans.time}
            </Table.Cell>
            <Table.Cell>
              {trans.reason}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </>
  );
};

/*




*/
