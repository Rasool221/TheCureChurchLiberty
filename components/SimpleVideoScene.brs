' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' 1st function that runs for the scene component on channel startup
sub init()
  'To see print statements/debug info, telnet on port 8089
  m.Image = m.top.findNode("Image")
  m.ButtonGroup = m.top.findNode("ButtonGroup")
  m.Details     = m.top.findNode("Details")
  m.Title       = m.top.findNode("Title")
  m.Video       = m.top.findNode("Video")
  m.Warning     = m.top.findNode("WarningDialog")
  m.Exiter      = m.top.findNode("Exiter")
  m.VideosRow   = m.top.findNode("videosRowList")
  
  setContent()
  
  m.ButtonGroup.setFocus(true)
  m.ButtonGroup.observeField("buttonSelected","onButtonSelected")

  m.top.backgroundColor = "0x000000FF" 
  m.top.backgroundURI = ""
end sub

sub onButtonSelected()
  'Ok'

  if m.ButtonGroup.buttonSelected = 0
    if m.ButtonGroup.buttons[0] = "Refresh" then
      showspinner()
      m.busyspinner.translation = "[1000, 0]"
      m.busyspinner.visible = true
      setContent()
    else if m.ButtonGroup.buttons[0] = "Play" then
      m.Video.visible = "true"
      m.Video.control = "play"
      m.Video.setFocus(true)
    end if
  'Exit button pressed'
  else
    if m.ButtonGroup.buttons[1] = "Exit" then
      m.Exiter.control = "RUN"
    else if m.ButtonGroup.buttons[1] = "Past Broadcasts" then
      print "Button is past broadcasts"
    end if    
  end if
end sub

sub setContent()  
  m.currentStatus = CreateObject("roSGNode", "GetStatusTask")
  m.currentStatus.control = "RUN"
  m.currentStatus.observeField("isOnline", "loadContentWithStatus")

  m.busyspinner = m.top.findNode("loadingSpinner")
  m.busyspinner.poster.observeField("loadStatus", "showspinner")
  m.busyspinner.poster.uri = "pkg:/images/busyspinner_hd.png"

  m.VideosRow.content = CreateObject("roSGNode", "RowListContent")

  m.ButtonGroup.setFocus(true)
end sub

sub showspinner()
  if(m.busyspinner.poster.loadStatus = "ready")
    centerx = (1280 - m.busyspinner.poster.bitmapWidth) / 2
    centery = (720 - m.busyspinner.poster.bitmapWidth) / 2
    m.busyspinner.translation = [ centerx, centery ]

    m.busyspinner.visible = true

    m.busyspinner.translation = "[640, 480]"
  end if
end sub

sub loadContentWithStatus()
  if m.busyspinner.poster.visible = true then
    m.busyspinner.poster.visible = false
  end if
  
  if m.currentStatus.isOnline = "true" then
    createLiveScene()
  else
    createOfflineScene()
  end if
end sub

sub createLiveScene() 
  Buttons = ["Play", "Past Broadcasts"]
  m.ButtonGroup.buttons = Buttons

  ContentNode = CreateObject("roSGNode", "ContentNode")
  ContentNode.streamFormat = "hls"
  ContentNode.url = "https://cdn3.wowza.com/1/TFhtUG5QTmNOQUtB/bXFqK2tO/hls/live/playlist.m3u8"
  ContentNode.Title = "The Cure Church Liberty Live Stream"
  
  m.Video.content = ContentNode
  m.Image.uri="pkg:/images/streamIsOnline.jpg"

  m.Image.translation = "[200, 200]"

  m.ButtonGroup.setFocus(true)
end sub

sub createOfflineScene() 
  Buttons = ["Refresh", "Past Broadcasts"]
  
  m.ButtonGroup.buttons = Buttons
  m.Image.uri="pkg:/images/streamIsOffline.jpg"

  if m.Video.visible = true then
    m.Video.visible = false
  end if

  m.Image.translation = "[400, 450]"

  m.ButtonGroup.setFocus(true)
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
  print "in SimpleVideoScene.xml onKeyEvent ";key;" "; press
  if press then
    if key = "back"
      print "------ [back pressed] ------"
      if m.Warning.visible
        m.Warning.visible = false
        m.ButtonGroup.setFocus(true)
        return true
      else if m.Video.visible
        m.Video.control = "stop"
        m.Video.visible = false
        m.ButtonGroup.setFocus(true)
        return true
      else
        return false
      end if
    else if key = "OK"
      print "------- [ok pressed] -------"
      if m.Warning.visible
        m.Warning.visible = false
        m.ButtonGroup.setFocus(true)
        return true
      end if
    else if key = "down"
      if m.ButtonGroup.buttonFocused = 1 then
        m.VideosRow.setFocus(true)
      end if
    else
      return false
    end if
  end if
  return false
end function
