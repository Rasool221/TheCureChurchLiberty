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
  m.PreviewVideo = m.top.findNode("previewVideo")
  
  m.rowListFadeOut = m.top.findNode("RowListFadeOut")
  m.rowListFadeIn = m.top.findNode("RowListFadeIn")
  
  m.offlinePosterFadeOut = m.top.findNode("offlinePosterFadeOut")
  m.offlinePosterFadeIn = m.top.findNode("offlinePosterFadeIn")

  m.offlinePosterMoveUp = m.top.findNode("offlinePosterMoveUp")
  m.offlinePosterMoveDown = m.top.findNode("offlinePosterMoveDown")

  m.buttonGroupMoveDownLive = m.top.findNode("buttonGroupMoveDownLive")
  m.buttonGroupMoveUpLive = m.top.findNode("buttonGroupMoveUpLive")
  m.buttonGroupMoveDown = m.top.findNode("buttonGroupMoveDown")
  m.buttonGroupMoveUp = m.top.findNode("buttonGroupMoveUp")
  
  m.previewVideoFadeOut = m.top.findNode("videoPreviewFadeOut")
  m.previewVideoFadeIn = m.top.findNode("videoPreviewFadeIn")

  m.previewVideoMoveUp = m.top.findNode("videoPreviewMoveUp")
  m.previewVideoMoveDown = m.top.findNode("videoPreviewMoveDown")

  m.ButtonGroupFadeOut = m.top.findNode("ButtonGroupFadeOut")
  m.ButtonGroupFadeIn = m.top.findNode("ButtonGroupFadeIn")

  m.rowListMoveUp = m.top.findNode("rowListMoveUp")
  m.rowListMoveDown = m.top.findNode("rowListMoveDown")

  m.backgroundFadeIn = m.top.findNode("fadeinAnimation")
  
  setContent()
  
  m.ButtonGroup.setFocus(true)
  m.ButtonGroup.observeField("buttonSelected","onButtonSelected")


  m.backgroundFadeIn.control = "start"
  m.top.backgroundColor = "0x000000FF" 
  m.top.backgroundURI = ""
end sub

sub onButtonSelected()
  'Ok'

  if m.ButtonGroup.buttonSelected = 0
    if m.ButtonGroup.buttons[0] = "Refresh" then
      m.busyspinner.poster.translation = "[700, -300]"
      m.busyspinner.poster.visible = true
      refreshLiveStream()
    else if m.ButtonGroup.buttons[0] = "Play" then
      m.VideosRow.visible = false
      
      m.PreviewVideo.visible = "false"
      m.PreviewVideo.control = "stop"
      
      m.Video.visible = "true"
      m.Video.control = "play"
      m.Video.setFocus(true)
    end if
  'Exit button pressed'
  else
    if m.ButtonGroup.buttons[1] = "Exit" then
      m.Exiter.control = "RUN"
    else if m.ButtonGroup.buttons[1] = "Past Broadcasts" then
      scrollScreenDown()
    end if    
  end if
end sub

sub refreshLiveStream()
  m.currentStatus = CreateObject("roSGNode", "GetStatusTask")
  m.currentStatus.control = "RUN"
  m.currentStatus.observeField("isOnline", "loadContentWithStatus")
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
  m.busyspinner.poster.visible = false 
  
  Buttons = ["Play", "Past Broadcasts"]
  m.ButtonGroup.buttons = Buttons

  ContentNode = CreateObject("roSGNode", "ContentNode")

  ContentNode.streamFormat = "hls"
  ContentNode.url = "https://cdn3.wowza.com/1/TFhtUG5QTmNOQUtB/bXFqK2tO/hls/live/playlist.m3u8"
  ContentNode.Title = "The Cure Church Liberty Live Stream"
  
  m.Video.content = ContentNode

  m.Image.visible = false
  m.Image.uri="pkg:/images/streamIsOnline.jpg"
  m.Image.translation = "[200, 200]"

  m.ButtonGroup.translation = "[1420,500]"

  m.PreviewVideo.content = ContentNode
  m.PreviewVideo.control = "play" 
  m.PreviewVideo.visible = true

  m.ButtonGroup.setFocus(true)
end sub

sub createOfflineScene()
  m.ButtonGroup.translation = "[1220,500]"

  m.busyspinner.poster.visible = false 
  
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

        m.PreviewVideo.control = "play"
        m.PreviewVideo.visible = true

        m.ButtonGroup.setFocus(true)
        m.VideosRow.visible = true
        return true
      else if m.VideosRow.hasFocus()
        scrollScreenUp()
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
        scrollScreenDown()
      end if
    else
      return false
    end if
  end if
  return false
end function

sub scrollScreenDown()
  if m.currentStatus.isOnline = "true" then
    m.previewVideoFadeOut.control = "start"
    m.ButtonGroupFadeOut.control = "start"
    m.buttonGroupMoveUpLive.control = "start"
    m.previewVideoMoveUp.control = "start"
    m.previewVideoFadeOut.control = "start"
    m.rowListMoveUp.control = "start"

    m.VideosRow.setFocus(true)
    m.rowListFadeIn.control = "start"
  else
    m.offlinePosterFadeOut.control = "start"
    m.ButtonGroupFadeOut.control = "start"
    m.offlinePosterMoveUp.control = "start"
    m.buttonGroupMoveUp.control = "start"
    m.rowListMoveUp.control = "start"

    m.VideosRow.setFocus(true)
    m.rowListFadeIn.control = "start"
  end if
end sub

sub scrollScreenUp()
  if m.currentStatus.isOnline = "true" then
    m.previewVideoFadeIn.control = "start"
    m.ButtonGroupFadeIn.control = "start"
    m.buttonGroupMoveDownLive.control = "start"
    m.previewVideoMoveDown.control = "start"
    m.previewVideoFadeIn.control = "start"
    m.rowListMoveDown.control = "start"

    m.ButtonGroup.setFocus(true)
    m.rowListFadeOut.control = "start"
  else
    m.offlinePosterFadeIn.control = "start"
    m.ButtonGroupFadeIn.control = "start"
    m.offlinePosterMoveDown.control = "start"
    m.buttonGroupMoveDown.control = "start"
    m.rowListMoveDown.control = "start"

    m.ButtonGroup.setFocus(true)
    m.rowListFadeOut.control = "start"
  end if
end sub