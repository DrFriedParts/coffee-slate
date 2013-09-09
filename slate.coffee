# Create Operations
pushRight = slate.operation "push",
  direction: "right"
  style: "bar-resize:screenSizeX/3"

pushLeft = slate.operation "push",
  direction: "left"
  style: "bar-resize:screenSizeX/3"

pushTop = slate.operation "push",
  direction: "top"
  style: "bar-resize:screenSizeY/2"

fullscreen = slate.operation "move",
  x: "screenOriginX"
  y: "screenOriginY"
  width: "screenSizeX"
  height: "screenSizeY"

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
