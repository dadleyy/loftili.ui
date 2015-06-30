dStreamTrackSearch = ($timeout, Api, Notifications, Lang) ->

  DEBOUNCE_TIME = 400

  idGen = do ->
    index = 0
    () ->
      index++
      index = 0 if index > 100
      index

  dStreamTrackSearchLink = ($scope, $element, $attrs) ->
    timeout_id = null
    last_val = null
    last_id = null
    $scope.results = null

    $scope.clear = () ->
      $scope.results = null
      $scope.search.query = null

    display = (search_id) ->
      (results) ->
        if search_id == last_id
          $scope.results = results

    run = () ->
      last_id = idGen()

      $scope.results = null

      if last_val != '' and last_val.length > 3
        (Api.Track.search
          q: last_val).$promise.then display(last_id)

    $scope.add = (track) ->
      success = (new_queue) ->
        $scope.manager.refresh()

      fail = () ->
        failed_lang = Lang 'queuing.failed'
        Notifications.flash failed_lang, 'error'

      ($scope.manager.add
        id: track.id
        provider: track.provider
        pid: track.pid
      ).then success, fail

    $scope.update = () ->
      last_val = $scope.search.query
      if timeout_id
        $timeout.cancel timeout_id
      timeout_id = $timeout run, DEBOUNCE_TIME

  lfStreamTrackSearch =
    replace: true
    templateUrl: 'directives.stream_track_search'
    scope:
      manager: '='
      queue: '='
    link: dStreamTrackSearchLink

dStreamTrackSearch.$inject = [
  '$timeout'
  'Api'
  'Notifications'
  'Lang'
]

lft.directive 'lfStreamTrackSearch', dStreamTrackSearch
