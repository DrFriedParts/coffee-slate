# Create Operations
pushRight = slate.operation "push",
  direction: "right"
  style: "bar-resize:screenSizeX/3"

pushLeft = slate.operation "push",
  direction: "left"
  style: "bar-resize:2*screenSizeX/3"

pushTop = slate.operation "push",
  direction: "top"
  style: "bar-resize:screenSizeY/2"

fullscreen = slate.operation "move",
  x: "screenOriginX"
  y: "screenOriginY"
  width: "screenSizeX"
  height: "screenSizeY"

# Cleanup
slate.bind "f1", (win) ->


# Bind A Crazy Function to 1+ctrl
slate.bind "1:ctrl", (win) ->
  
  # here win is a reference to the currently focused window
  if win.title() is "OMG I WANT TO BE FULLSCREEN"
    win.doOperation fullscreen
    return
  appName = win.app().name()
  if appName is "iTerm"
    win.doOperation pushRight
  else if appName is "Google Chrome"
    win.doOperation pushLeft
  else
    win.doOperation pushTop

# order screens left to right so they are easier to reference
slate.config "orderScreensLeftToRight", true

# Set up screen reference variables to avoid typos :)
leftScreenRef = "0"
middleScreenRef = "1"
rightScreenRef = "2"

# Create the various operations used in the layout
hideSpotify = slate.operation("hide",
  app: "Spotify"
)
focusITerm = slate.operation("focus",
  app: "iTerm"
)
leftBottomLeft = slate.operation("move",
  screen: leftScreenRef
  x: "screenOriginX"
  y: "screenOriginY+(screenSizeY/2)"
  width: "screenSizeX/2"
  height: "screenSizeY/2"
)
leftRight = slate.operation("push",
  screen: leftScreenRef
  direction: "right"
  style: "bar-resize:screenSizeX/2"
)
middleTopBar = slate.operation("bar",
  screen: middleScreenRef
  direction: "up"
  style: "bar-resize:screenSizeY/2"
)
middleTopRight = slate.operation("move",
  screen: middleScreenRef
  x: "screenOriginX+(screenSizeX/2)"
  y: "screenOriginY"
  width: "screenSizeX/2"
  height: "screenSizeY/2"
)
middleTopLeft = slate.operation("move",
  screen: middleScreenRef
  x: "screenOriginX"
  y: "screenOriginY"
  width: "screenSizeX/2"
  height: "screenSizeY/2"
)
middleBottomRight = slate.operation("move",
  screen: middleScreenRef
  x: "screenOriginX+(2*screenSizeX/3)"
  y: "screenOriginY+(screenSizeY/2)"
  width: "screenSizeX/3"
  height: "screenSizeY/2"
)
middleBottomMiddle = slate.operation("move",
  screen: middleScreenRef
  x: "screenOriginX+(screenSizeX/3)"
  y: "screenOriginY+(screenSizeY/2)"
  width: "screenSizeX/3"
  height: "screenSizeY/2"
)
middleBottomLeft = slate.operation("move",
  screen: middleScreenRef
  x: "screenOriginX"
  y: "screenOriginY+(screenSizeY/2)"
  width: "screenSizeX/3"
  height: "screenSizeY/2"
)
rightChatBar = slate.operation("push",
  screen: rightScreenRef
  direction: "left"
  style: "bar-resize:screenSizeX/9"
)
rightMain = slate.operation("push",
  screen: rightScreenRef
  direction: "right"
  style: "bar-resize:8*screenSizeX/9"
)


# Create the layout itself
threeMonitorsLayout = slate.layout("threeMonitors",
  _before_: # before the layout is activated, hide Spotify
    operations: hideSpotify

  _after_: # after the layout is activated, focus iTerm
    operations: focusITerm

  Adium:
    operations: [rightChatBar, leftBottomLeft]
    "ignore-fail": true # Adium's Contacts window cannot be resized, so the operation rightChatBar will fail.
    # No big deal, if we ignore the failure Slate will happily move on to leftBottomLeft.
    "title-order": ["Contacts"] # Make sure the window with the title "Contacts" gets ordered first so that
    # we apply the operation rightChatBar to the Contacts window.
    "repeat-last": true # If I have more that two Adium windows, just use leftBottomLeft on the rest of them.

  MacVim:
    operations: [middleTopLeft, middleTopRight]
    "title-order-regex": ["^.slate(.js)?.+$"] # If we see a window whose title matches this regex, order
    # it first. Or in other words, if I'm editing my .slate or
    # .slate.js in MacVim, make sure it uses middleTopLeft.
    repeat: true # If I have more than two MacVim windows, keep applying middleTopLeft and middleTopRight.

  iTerm:
    operations: [middleBottomLeft, middleBottomMiddle, middleBottomRight]
    "sort-title": true # I have my iTerm window titles prefixed with the window number e.g. "1. bash".
    # Sorting by title ensures that my iTerm windows always end up in the same place.
    repeat: true # If I have more than three iTerm windows, keep applying the three operations above.

  "Google Chrome":
    operations: [(windowObject) ->
      
      # I want all Google Chrome windows to use the rightMain operation *unless* it is a Developer Tools window.
      # In that case I want it to use the leftRight operation. I can't use title-order-regex here because if it
      # doesn't see the regex, it won't skip the leftRight operation and that will cause one of my other Chrome
      # windows to use it which I don't want. Also, I could have multiple Developer Tools windows which also
      # makes title-order-regex unusable. So instead I just write my own free form operation.
      title = windowObject.title()
      if title isnt `undefined` and title.match(/^Developer\sTools\s-\s.+$/)
        windowObject.doOperation leftRight
      else
        windowObject.doOperation rightMain
    ]
    "ignore-fail": true # Chrome has issues sometimes so I add ignore-fail so that Slate doesn't stop the
    # layout if Chrome is being stupid.
    repeat: true # Keep repeating the function above for all windows in Chrome.

  Xcode:
    operations: [middleTopBar, leftRight]
    "main-first": true # I want the main window of Xcode to always go to middleTopBar. Any other windows
    # should use leftRight. So main-first in conjunction with repeat-last is perfect.
    "repeat-last": true # If I have more than two Xcode windows, keep applying leftRight.
)


# bind the layout to activate when I press Control and the Enter key on the number pad.
slate.bind "padEnter:ctrl", slate.operation "layout", { "name" : threeMonitorsLayout }

# default the layout so it activates when I plug in my two external monitors.
slate.default ["1920x1080", "1920x1080", "2560x1440"], threeMonitorsLayout


S.log "=========== Slate js init success =========="