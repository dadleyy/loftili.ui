lft.directive 'lfTrackSearch', ['$timeout', 'Api', ($timeout, Api) ->

  BOUNCE_TIME = 400
  Track = Api.Track
  isArr = angular.isArray

  lfTrackSearch =
    replace: true
    templateUrl: 'directives.track_search'
    scope: {}
    link: ($scope, $element, $attrs) ->
      last_val = null
      bounce_timeout = null
      flag_remove_timeout = null
      url_test = /^(ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?$/
      $scope.searching = false
      $scope.query =
        val: ''

      finish = () ->
        $scope.searching = false

      display = (tracks) ->
        if flag_remove_timeout
          $timeout.cancel flag_remove_timeout
        flag_remove_timeout = $timeout finish, 1000
        $scope.results = if isArr tracks then tracks else [tracks]

      search = () ->
        $scope.searching = true
        if url_test.test last_val
          web()
        else
          library()

      web = () ->
        $scope.searching = true
        track_promise = Track.scout
          url: btoa(last_val)
        track_promise.$promise.then display

      library = () ->
        $scope.searching = true
        track_promise = Track.search
          q: last_val
        track_promise.$promise.then display

      $scope.search = (evt) ->
        last_val = evt.target.value
        if bounce_timeout
          $timeout.cancel bounce_timeout

        if last_val != ''
          bounce_timeout = $timeout search, BOUNCE_TIME
        else
          $scope.results = []

      closed = () ->
        $scope.searching = false
        $scope.query.val = ''

      $scope.$on 'closed', closed
]
