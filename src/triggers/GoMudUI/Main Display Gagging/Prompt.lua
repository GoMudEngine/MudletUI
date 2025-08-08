-- Check if settings are loaded and gagging settings exist
if ui and ui.settings and ui.settings.userToggles and ui.settings.userToggles.gagging 
   and ui.settings.userToggles.gagging.prompt and ui.settings.userToggles.gagging.prompt.state and gmcp.Char then
  deleteLine()
end