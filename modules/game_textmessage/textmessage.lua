TextMessage = {}

-- require styles
importStyle 'textmessage.otui'

-- private variables
local MessageTypes = {
  consoleRed = { color = '#F55E5E', consoleChannel = 'Server Log' },
  eventOrange = { color = '#FE6500', consoleChannel = 'Default' , windowLocation = 'center', consoleOption = 'showEventMessagesInConsole' },
  consoleOrange = { color = '#FE6500', consoleChannel = 'Default' },
  warning = { color = '#F55E5E', consoleChannel = 'Server Log', windowLocation = 'center' },
  eventAdvance = { color = '#FFFFFF', consoleChannel = 'Server Log', windowLocation = 'center', consoleOption = 'showEventMessagesInConsole' },
  eventDefault = { color = '#FFFFFF', consoleChannel = 'Server Log', windowLocation = 'bottom', consoleOption = 'showEventMessagesInConsole' },
  statusDefault = { color = '#FFFFFF', consoleChannel = 'Server Log', windowLocation = 'bottom', consoleOption = 'showStatusMessagesInConsole' },
  infoDescription = { color = '#00EB00', consoleChannel = 'Server Log', windowLocation = 'center', consoleOption = 'showInfoMessagesInConsole' },
  statusSmall = { color = '#FFFFFF', windowLocation = 'bottom' },
  consoleBlue =  { color = '#9F9DFD', consoleChannel = 'Default' },
}

local bottomLabelWidget
local centerLabelWidget
local bottomLabelHideEvent
local centerLabelHideEvent

-- private functions
local function displayMessage(msgtype, msg, time)
  if not Game.isOnline() then return end

  if msgtype.consoleChannel ~= nil then
    if msgtype.consoleOption == nil or Options[msgtype.consoleOption] then
      Console.addChannelMessage(msg, msgtype.color, msgtype.consoleChannel)
    end
  end

  if msgtype.windowLocation  then
    local label
    local style
    if msgtype.windowLocation == 'bottom' then
      label = bottomLabelWidget
      style = 'BottomLabel'
    elseif msgtype.windowLocation == 'center' then
      label = centerLabelWidget
      style = 'CenterLabel'
    end

    label:setVisible(true)
    label:setText(msg)
    label:setStyle(style)
    label:setColor(msgtype.color)

    if not time then
      time = math.max(#msg * 75, 3000)
    else
      time = time * 1000
    end
    removeEvent(label.hideEvent)
    label.hideEvent = scheduleEvent(function() label:setVisible(false) end, time)
  end
end

-- public functions
function TextMessage.create()
  bottomLabelWidget = createWidget('UILabel', Game.gameMapPanel)
  centerLabelWidget = createWidget('UILabel', Game.gameMapPanel)
end

function TextMessage.displayStatus(msg, time)
  displayMessage(MessageTypes.warning, msg)
end

function TextMessage.displayEventAdvance(msg, time)
  displayMessage(MessageTypes.eventAdvance, msg, time)
end

function TextMessage.display(msgtypedesc, msg)
  local msgtype = MessageTypes[msgtypedesc]
  if msgtype then
    displayMessage(msgtype, msg)
  end
end

-- hooked events
local function onGameDeath()
  TextMessage.displayEventAdvance('You are dead.', 10)
  scheduleEvent(function() Game.logout(true) end, 10*1000)
end

local function onGameTextMessage(msgtype, msg)
  TextMessage.display(msgtype, msg)
end

connect(Game, { onLogin = TextMessage.create,
                onLogout = TextMessage.destroy,
                onDeath = onGameDeath,
                onTextMessage = onGameTextMessage })
