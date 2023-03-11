import { useBackend } from "../backend";
import { Button, Flex, Knob, NoticeBox, NumberInput, ProgressBar, Section } from "../components";
import { Window } from "../layouts";

export const FluxHarvester = (props, context) => {

  const { act, data } = useBackend(context);

  const {
    status = "",
    harvest_amount = 0,
    is_processing = false,
    ticks_left = 0,
  } = data;

  return (
    <Window
      width={300}
      height={338}>
      <Window.Content>
        <Flex
          direction="column"
          height="100%">
          <Flex.Item
            grow={0}
            mb="20px">
            <NoticeBox
              color={status === "Ready to process"
                ? "green"
                : "red"}>
              Status: {status}
            </NoticeBox>
          </Flex.Item>
          <Flex.Item
            grow={1}
            mb="20px">
            <Section height="100%">
              <Flex direction="column" height="100%">
                <Flex.Item grow={1}>
                  <Knob
                    mt={2}
                    mb={2}
                    value={harvest_amount}
                    minValue={0}
                    maxValue={1000}
                    size={3}
                    onChange={(e, value) => act('set_harvest_amount', {
                      amount: value,
                    })} />
                  Current Harvest Amount: {harvest_amount}
                </Flex.Item>
                <Flex.Item grow={0}>
                  {is_processing ? (
                    <ProgressBar value={600-ticks_left} maxValue={600}>{ticks_left/10}s</ProgressBar>
                  ) : (
                    <ProgressBar value={0} maxValue={600}>Not Processing</ProgressBar>
                  )}
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
          <Flex.Item>
            <Section>
              <Flex direction="row">
                <Flex.Item grow={1}>
                  {!is_processing
                    ? (
                      <Button
                        content="Start"
                        onClick={() => act('begin_harvest')} />)
                    : (
                      <Button
                        content="Emergency Stop"
                        color="red"
                        icon="exclamation-triangle"
                        onClick={() => act('emergency_stop')} />)}
                </Flex.Item>
                <Flex.Item align="flex-end">
                  <Button
                    content="Eject"
                    onClick={() => act('eject_canister')} />
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
