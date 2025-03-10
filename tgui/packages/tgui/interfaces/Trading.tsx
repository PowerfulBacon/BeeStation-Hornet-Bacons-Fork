import { useBackend } from 'tgui/backend';
import { Box, Button, Collapsible, Flex, Section } from 'tgui/components';
import { Window } from 'tgui/layouts';
import '../styles/interfaces/Trading.scss';
import { capitalize } from 'common/string';

type TradingData = {
  account_name: string;
  account_balance: number;
  listed_crates: ListedCrate[];
};

type ListedCrate = {
  id: number;
  price: number;
  name: string;
  contents: { [name: string]: number };
};

export const Trading = (props) => {
  const { act, data } = useBackend<TradingData>();
  const { account_name, account_balance = 0, listed_crates = [] } = data;
  return (
    <Window>
      <Window.Content>
        <Section height="100%" title={'Account: ' + account_name} buttons={<Box color="#f5d68e">{account_balance}cr</Box>}>
          <Flex scrollable direction="column">
            {listed_crates.map((crate) => (
              <Flex.Item key={crate.id} className="trading_crate_item">
                <div className="header">
                  <div>{capitalize(crate.name)}</div>
                  <div>{crate.price}cr</div>
                </div>
                <Collapsible title="Contents" mt={1}>
                  <ul>
                    {Object.entries(crate.contents).map((x) => (
                      <li key={x[0]}>
                        {capitalize(x[0])} ({x[1]})
                      </li>
                    ))}
                  </ul>
                </Collapsible>
                <Button
                  onClick={() => {
                    act('purchase', {
                      id: crate.id,
                    });
                  }}>
                  Purchase
                </Button>
              </Flex.Item>
            ))}
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
