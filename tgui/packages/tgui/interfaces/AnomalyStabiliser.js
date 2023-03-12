

import { useBackend } from "../backend";
import { Button, Section, LabeledList, ProgressBar } from "../components";
import { Window } from "../layouts";

export const AnomalyStabiliser = (props, context) => {

  const { act, data } = useBackend(context);

  const {
    charge = 0,
    enabled = false,
  } = data;

  return (
    <Window
      width={230}
      height={107}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Power switch">
              <Button
                color={enabled ? "green" : "red"}
                icon="power-off"
                content="Toggle Power"
                onClick={() => act('toggle_stabiliser')} />
            </LabeledList.Item>
            <LabeledList.Item label="Internal Cell">
              <ProgressBar
                value={charge}
                maxValue={1}
                ranges={{
                  good: [0.1, Infinity],
                  average: [0.01, 0.1],
                  bad: [-Infinity, 0.01],
                }} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
