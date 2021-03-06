dStreamTrackSearch = ($timeout, Api, Notifications, Lang, ArtistCache) ->

  SEARCHING_LANG = Lang 'queuing.searcing'
  DEBOUNCE_TIME = 400
  LFTXS_RGX = /^lftxs$/i
  LF_RGX = /^lf$/i

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
    blank_artist = {name: ''}
    search_note = false

    $scope.getArtist = (track) ->
      artist_id = if track and track.artist then track.artist else null
      found = false

      return null if artist_id == null

      if track.id < 0 and LFTXS_RGX.test track.provider
        return track.artist

      for a in $scope.artists
        found = a if a.id == artist_id

      found or null

    $scope.clear = () ->
      $scope.results = null
      $scope.search.query = null

    display = (search_id) ->
      tracks = null
      artist_ids = []
      artists = []
      attempted = 0

      finish = () ->
        is_latest = search_id == last_id
        $scope.artists = artists
        $scope.results = tracks if search_id == last_id
        Notifications.remove search_note if search_id == last_id
        search_note = false
        true

      loadedArtist = (artist) ->
        artists.push artist
        finish true if ++attempted == artist_ids.length
        true

      failed = () ->
        finish true if ++attempted == artist_ids.length
        true

      (r) ->
        tracks = r

        for t in tracks
          artist_ids.push t.artist if t.id > 0 and (artist_ids.indexOf t.artist) < 0

        if artist_ids.length == 0 and search_id == last_id
          return finish true

        for a in artist_ids
          (ArtistCache a).then loadedArtist, failed

        true

    run = () ->
      last_id = idGen()

      $scope.results = null

      display_fn = display last_id

      if last_val and last_val.length > 3
        (Api.Track.search
          q: last_val).$promise.then display_fn
      else
        Notifications.remove search_note
        search_note = false
        $scope.results = null

      true

    $scope.update = () ->
      $timeout.cancel timeout_id if timeout_id

      if $scope.search.query == ''
        last_id = null
        $scope.results = []
        Notifications.remove search_note
        search_note = false
        return false

      search_note = Notifications.add SEARCHING_LANG, 'info' if !search_note
      last_val = $scope.search.query
      timeout_id = $timeout run, DEBOUNCE_TIME

    $scope.manager.on 'adding', () -> $scope.is_busy = true
    $scope.manager.on 'added', () -> $scope.is_busy = false

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
  'ArtistCache'
]

lft.directive 'lfStreamTrackSearch', dStreamTrackSearch
