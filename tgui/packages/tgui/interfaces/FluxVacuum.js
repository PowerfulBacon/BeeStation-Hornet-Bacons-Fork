

import { useBackend } from "../backend";
import { Button, Knob, NoticeBox, NumberInput, ProgressBar, Section, LabeledList } from "../components";
import { Window } from "../layouts";

export const FluxVacuum = (props, context) => {

  const { act, data } = useBackend(context);

  return (
    <Window
      width={300}
      height={338}>
      <Window.Content>
        <Section
          title="Flux Vacuum Controller"
          height="100%">
          <LabeledList>
            <LabeledList.Item label="Link Status">
              <Button
                width="100%"
                content="Relink"
                onClick={() => act('relink')} />
            </LabeledList.Item>
            <LabeledList.Item label="Activate">
              <Button
                width="100%"
                content="Activate"
                onClick={() => act('activate')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
