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
  
  setContent()
  
  m.ButtonGroup.setFocus(true)
  m.ButtonGroup.observeField("buttonSelected","onButtonSelected")
  
  m.top.backgroundColor = "0x000000FF" 
  m.top.backgroundURI = ""
end sub

sub onButtonSelected()
  'Ok'
  if m.ButtonGroup.buttonSelected = 0
    m.Video.visible = "true"
    m.Video.control = "play"
    m.Video.setFocus(true)
  'Exit button pressed'
  else
    m.Exiter.control = "RUN"
  end if
end sub

sub setContent()  
  m.currentStatus = CreateObject("roSGNode", "GetStatusTask")
  m.currentStatus.control = "RUN"
  m.currentStatus.observeField("isOnline", "loadContentWithStatus")
end sub

sub loadContentWithStatus() 
  if m.currentStatus.isOnline = "true" then
    Buttons = ["Play", "More"]
    m.ButtonGroup.buttons = Buttons
  
    ContentNode = CreateObject("roSGNode", "ContentNode")
    ContentNode.streamFormat = "hls"
    ContentNode.url = "https://cdn3.wowza.com/1/TFhtUG5QTmNOQUtB/bXFqK2tO/hls/live/playlist.m3u8"
    ContentNode.Title = "The Cure Church Liberty live stream"
    m.Title.text = "The Cure Church Liberty live stream"
    m.Video.content = ContentNode
    m.Image.uri="pkg:/images/streamIsOnline.jpg"
  else
    Buttons = ["More"]
    m.ButtonGroup.buttons = Buttons
    m.Image.uri="pkg:/images/streamIsOffline.jpg"
    m.Title.text = "Stream is offline"

  end if

 
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
    else
      return false
    end if
  end if
  return false
end function
