import { map } from 'common/collections';
import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, LabeledList, Section, Table, Tabs, Box, Divider, NumberInput, Grid } from '../components';
import { Window } from '../layouts';
import { TableCell } from '../components/Table';
import { GridColumn } from '../components/Grid';

export const GalacticMarket = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    categories,
  } = data;
  const [
    selectedCategory,
    setSelectedCategory,
  ] = useLocalState(context, 'category', categories[0]?.name);
  return (
    <Window
      theme="ntos">
      <Window.Content scrollable>
        <GalacticMarketTitle />
        <GalacticMarketStocks />
        <Table>
          <Table.Row>
            <Table.Cell
              collapsible
              width="220px">
              <GalacticMarketSideTab
                selectedCategory={selectedCategory}
                setSelectedCategory={setSelectedCategory} />
            </Table.Cell>
            <Table.Cell
              collapsible
              height="525px">
              <GalacticMarketMain
                selectedCategory={selectedCategory} />
            </Table.Cell>
          </Table.Row>
        </Table>
      </Window.Content>
    </Window>
  );
};

export const GalacticMarketTitle = (props, context) => {
  const { data } = useBackend(context);
  const {
    money,
    account_name,
  } = data;
  return (
    <Section>
      <Table>
        <Table.Row>
          <Table.Cell>
            <Box
              bold
              fontSize="16px">
              Galactic Market
            </Box>
          </Table.Cell>
          <Table.Cell>
            Paymet ID: {account_name}
          </Table.Cell>
          <Table.Cell
            collapsing
            textAlign="right">
            <Box
              bold>
              Credits: {money}c
            </Box>
          </Table.Cell>
          <Table.Cell
            textAlign="right"
            collapsing>
            <Button
              content="Refresh" />
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

export const GalacticMarketStocks = (props, context) => {
  const stockText = [
    ["iron", 0.41],
    ["gold", -6.35],
    ["unobtainium", -1.21],
    ["telecrystals", 25.24],
    ["diamond", 0.53],
  ];
  return (
    <Section>
      <Table>
        <Table.Row>
          {stockText.map(stock => (
            <Table.Cell
              key={stock[0]}
              inline
              textWrap>
              <Box
                bold
                inline>
                {stock[0] + ": "}
              </Box>
              <Box
                inline
                textColor={stock[1]>0?"green":"red"}>
                {stock[1] + "%"}
              </Box>
            </Table.Cell>
          ))}
        </Table.Row>
      </Table>
    </Section>
  );
};

export const GalacticMarketSideTab = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    categories = [],
    categories_hacked = [],
    current_order = [],
    total_cost,
  } = data;
  const {
    selectedCategory,
    setSelectedCategory,
  } = props;
  return (
    <Section>
      <Box
        height="424px"
        overflowY="scroll">
        <Table>
          {categories.map(category => (
            <Table.Row
              key={category.name}>
              <Button
                fluid
                content={category.name}
                onClick={() => setSelectedCategory(category.name)}
                selected={category.name === selectedCategory} />
            </Table.Row>
          ))}
          {categories_hacked.map(category => (
            <Table.Row
              key={category.name}>
              <Button
                color="bad"
                fluid
                content={category.name} />
            </Table.Row>
          ))}
        </Table>
      </Box>
      <Box>
        <Grid>
          <GridColumn>
            <b>
              Basket
            </b>
          </GridColumn>
          <GridColumn
            textAlign="right">
            <Button
              color="bad"
              content="Clear"
              onClick={() => act('clear')} />
          </GridColumn>
        </Grid>
        <Divider />
        <Box
          height="100px"
          overflowY="scroll">
          <Table>
            {current_order.map(order => (
              <Table.Row
                key={order.name}>
                {order.name}(x{order.amount}) - {-order.cost} credits
              </Table.Row>
            ))}
          </Table>
        </Box>
        <Divider />
        <Button
          onClick={() => act('buy')}
          content={"Order (" + (-total_cost) + " credits)"} />
      </Box>
    </Section>
  );
};

export const GalacticMarketMain = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    categories,
    amount_list,
  } = data;
  const {
    selectedCategory,
  } = props;
  const items = categories.find(category => category.name === selectedCategory)
    ?.items;
  return (
    <Section>
      <Box
        overflowY="scroll"
        height="525px">
        <Table>
          <Table.Row
            bold>
            <Table.Cell>
              Name
            </Table.Cell>
            <Table.Cell>
              Current Price
            </Table.Cell>
            <Table.Cell>
              Supply
            </Table.Cell>
            <Table.Cell>
              Fair price
            </Table.Cell>
            <Table.Cell>
              Amount
            </Table.Cell>
          </Table.Row>
          {items.map(item => (
            <Table.Row
              key={item.name}>
              <Table.Cell
                bold="0"
                color={item.illegal?"grey":"white"}>
                {item.name}
              </Table.Cell>
              <Table.Cell>
                {item.cost}
              </Table.Cell>
              <Table.Cell>
                {item.supply}
              </Table.Cell>
              <Table.Cell>
                {item.fairprice}
              </Table.Cell>
              <Table.Cell>
                <NumberInput
                  value={item.id in amount_list ? amount_list[item.id] : 1}
                  unit="u"
                  width="43px"
                  stepPixelSize={2}
                  step={1}
                  minValue={-item.supply}
                  maxValue={item.suppy}
                  onChange={(e, value) => act('change_num', {
                    new: value,
                    id: item.id,
                  })} />
              </Table.Cell>
              <Table.Cell>
                <Button
                  content="Add"
                  onClick={() => act('add_to_basket', {
                    item: item.id,
                    amount: item.id in amount_list ? amount_list[item.id] : 1,
                  })} />
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Box>
    </Section>
  );
};
