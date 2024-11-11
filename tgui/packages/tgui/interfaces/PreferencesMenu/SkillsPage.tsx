import { Box, Icon, Stack } from "tgui/components";

export const SkillsPage = () => {
  return (
    <Box className="PreferencesMenu__Skills__SkillsBox">
      <Stack fill>
        <Stack.Item width="10%">
          <Box className="PreferencesMenu__Skills__SkillsIcon" align="center">
            <Icon color="#333" name="brain" />
          </Box>
        </Stack.Item>

        <Stack.Item
          align="stretch"
          style={{
            'border-right': '1px solid black',
            'margin-left': 0,
          }}
        />
        <Stack.Item grow>
          <Box className="PreferencesMenu__Skills__SkillsIcon" align="center">
            <Icon color="#333" name="brain" />
          </Box>
        </Stack.Item>
      </Stack>
    </Box>
  );
};
