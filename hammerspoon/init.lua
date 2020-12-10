-- Capslock to escape
-- 특정 프로그램에서 자동으로 영어 입력 소스로 전환합니다.
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
