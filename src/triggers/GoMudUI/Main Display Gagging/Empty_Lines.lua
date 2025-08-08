-- Check if settings are loaded and gagging settings exist
if ui and ui.settings and ui.settings.userToggles and ui.settings.userToggles.gagging 
   and ui.settings.userToggles.gagging.blank and ui.settings.userToggles.gagging.blank.state then
  deleteLine()
end