lft.directive 'lfDeviceControls', ['Api', 'Notifications', 'Lang', 'DEVICE_STATES', (Api, Notifications, Lang, DEVICE_STATES) ->

  lfDeviceControls =
    replace: true
    templateUrl: 'directives.device_controls'
    scope:
      manager: '='
    link: ($scope, $element, $attrs) ->
      notification_id = null
      playing_lang = Lang 'device.playback.starting'
      stopping_lang = Lang 'device.playback.stopping'
      restarting_lang = Lang 'device.playback.restarting'
      feed_loop_id = null

      $scope.currentTrack = () ->
        ping = $scope.ping
        if ping and ping.track_id >= 0
          $scope.manager.currentTrack()
        else
          false

      $scope.playing = () ->
        false

      clear = () ->
        if notification_id
          Notifications.remove notification_id
     
      $scope.play = () ->
        $scope.manager.startPlayback().then clear, clear
        clear()
        notification_id = Notifications.add playing_lang

      $scope.stop = () ->
        $scope.manager.stopPlayback().then clear, clear
        clear()
        notification_id = Notifications.add stopping_lang

      $scope.restart = () ->
        $scope.manager.restartPlayback().then clear, clear
        clear()
        notification_id = Notifications.add restarting_lang

      update = (err, feed_response) ->
        if err
          $scope.ping = false
        else
          $scope.ping = feed_response.ping

      $scope.$on '$destroy', () ->
        $scope.manager.feed.remove feed_loop_id

      feed_loop_id = $scope.manager.feed.add update

]
