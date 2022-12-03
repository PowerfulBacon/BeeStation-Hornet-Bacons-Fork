
import { useBackend } from '../backend';
import { Table, Button, Box, NoticeBox } from '../components';
import { Window } from '../layouts';

export const NewPlayerPanel = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    state = 0,
  } = data;

  switch (state)
  {
    case 0:
      return (
        <Window
          width={450}
          height={600}
          theme="generic"
          canClose={0} >
          <Window.Content>
            <NewPlayerPanelInitial />
          </Window.Content>
        </Window>
      );
    case 1:
      return (
        <Window
          width={450}
          height={600}
          theme="generic"
          canClose={0} >
          <Window.Content>
            <CreateShip />
          </Window.Content>
        </Window>
      );
  }

  return (
    <Window
      width={450}
      height={600}
      theme="generic"
      canClose={0} >
      <Window.Content>
        <NoticeBox color="red">
          You are in an unexpected state. ({state}).
          Might be worth reporting this.
        </NoticeBox>
        <Button
          onClick={() => act("switch_state", {
            "new_state": 0,
          })}>
          Return
        </Button>
      </Window.Content>
    </Window>
  );
};

const CreateShip = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <>
      <NoticeBox
        position="absolute"
        top="10px"
        left="10px"
        right="10px"
        height="30px"
        fontSize="15px"
        textAlign="center">
        Select a faction to join.
      </NoticeBox>
      <Button
        position="absolute"
        top="70px"
        left="10px"
        right="10px"
        height="110px"
        fontSize="28px"
        textAlign="center"
        backgroundColor="#2681a5"
        onClick={() => act("switch_state", {
          "new_state": 0,
        })}>
        <Box
          position="absolute"
          left="130px"
          top="20px"
          fontSize="36px">
          Nanotrasen
        </Box>
        <Box
          position="absolute"
          right="95px"
          top="55px"
          fontSize="18px"
          textAlign="right">
          42 Players
        </Box>
      </Button>
      <Button
        position="absolute"
        top="220px"
        left="10px"
        right="10px"
        height="110px"
        fontSize="28px"
        textAlign="center"
        backgroundColor="#8f4a4b"
        onClick={() => act("switch_state", {
          "new_state": 0,
        })}>
        <Box
          position="absolute"
          left="130px"
          top="20px"
          fontSize="36px">
          The Syndicate
        </Box>
        <Box
          position="absolute"
          right="95px"
          top="55px"
          fontSize="18px"
          textAlign="right">
          42 Players
        </Box>
      </Button>
      <Button
        position="absolute"
        bottom="10px"
        right="10px"
        width="200px"
        height="50px"
        fontSize="28px"
        textAlign="center"
        icon="arrow-left"
        onClick={() => act("switch_state", {
          "new_state": 0,
        })}>
        Back
      </Button>
    </>
  );
};


const NewPlayerPanelInitial = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Table>
      <Table.Row
        width="100%"
        height="150px"
        fontSize={3.8}
        textAlign="center"
        justifyContent="center"
        icon="plus"
        verticalAlign="middle">
        CorgStation
      </Table.Row>
      <Table.Row width="100%" height="150px" mt="20px">
        <Button
          width="90%"
          height="100px"
          ml="5%"
          fontSize={2.8}
          textAlign="center"
          justifyContent="center"
          icon="plus"
          verticalAlign="middle"
          onClick={() => act("switch_state", {
            "new_state": 1,
          })}>
          Create Ship
        </Button>
      </Table.Row>
      <Table.Row width="100%" height="150px" mt="20px">
        <Button
          width="90%"
          height="100px"
          ml="5%"
          fontSize={2.8}
          textAlign="center"
          justifyContent="center"
          icon="users"
          verticalAlign="middle"
          onClick={() => act("switch_state", {
            "new_state": 2,
          })}>
          Join Ship
        </Button>
      </Table.Row>
      <Table.Row width="100%" height="50px" mt="150px">
        <Button
          width="90%"
          height="50px"
          ml="5%"
          fontSize={2}
          textAlign="center"
          justifyContent="center"
          onClick={() => act("observe")}>
          Observe
        </Button>
      </Table.Row>
    </Table>
  );
};
