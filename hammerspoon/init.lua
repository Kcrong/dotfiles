-- Capslock to escape
local inputEnglish = 'com.apple.keylayout.ABC'

function escapeWithEnglishInput()
  local allowApplications = {'PyCharm', 'GoLand', 'IntelliJ IDEA', 'iTerm2', 'Google Chrome', 'DataGrip', 'WebStorm'}
  local allowApplicationsTable = {}
  for i, v in ipairs(allowApplications) do
    allowApplicationsTable[v] = true
  end
  
  local inputSource = hs.keycodes.currentSourceID() 
  local currentApplicationName = hs.application.frontmostApplication():name()
  
  if (not (inputSource == inputEnglish)) and allowApplicationsTable[currentApplicationName] then
    hs.keycodes.currentSourceID(inputEnglish)
  end

  hs.eventtap.keyStroke({}, 'escape')
end

hs.hotkey.bind({}, 'F13', escapeWithEnglishInput)

-- Helper: open a new window of the given app on the screen where the mouse is.
-- `openCmd` is executed to trigger window creation; we snapshot existing windows
-- before, then poll for a new one and move it to the target screen.
local function openNewWindowAtMouse(bundleID, openCmd)
  local targetScreen = hs.mouse.getCurrentScreen()

  -- Snapshot existing standard window IDs
  local existingIDs = {}
  local app = hs.application.find(bundleID)
  if app then
    for _, w in ipairs(app:allWindows()) do
      existingIDs[w:id()] = true
    end
  end

  -- Trigger window creation
  openCmd()

  -- Poll for the new window, then move it
  local attempts = 0
  local timer
  timer = hs.timer.doEvery(0.1, function()
    attempts = attempts + 1
    local a = hs.application.find(bundleID)
    if a then
      for _, w in ipairs(a:allWindows()) do
        if w:isStandard() and not existingIDs[w:id()] then
          w:moveToScreen(targetScreen, false, true)
          w:focus()
          timer:stop()
          return
        end
      end
    end
    if attempts > 30 then  -- 3 seconds max
      timer:stop()
    end
  end)
end

-- Global hotkey: Cmd+Shift+E → new Ghostty window on the screen where the mouse is
hs.hotkey.bind({'cmd', 'shift'}, 'e', function()
  openNewWindowAtMouse('com.mitchellh.ghostty', function()
    local app = hs.application.find('com.mitchellh.ghostty')
    if app then
      -- Activate then send Cmd+N to open a new window
      app:activate()
      hs.eventtap.keyStroke({'cmd'}, 'n', 0)
    else
      -- First launch creates the initial window
      hs.application.launchOrFocusByBundleID('com.mitchellh.ghostty')
    end
  end)
end)

-- Global hotkey: Cmd+Opt+Space → new Chrome window on the screen where the mouse is
-- Note: Cmd+Opt+Space is macOS Spotlight's "file search" shortcut by default.
-- Disable it in System Settings → Keyboard → Keyboard Shortcuts → Spotlight if it conflicts.
hs.hotkey.bind({'cmd', 'alt'}, 'space', function()
  openNewWindowAtMouse('com.google.Chrome', function()
    hs.execute('/usr/bin/open -na "Google Chrome" --args --new-window')
  end)
end)


