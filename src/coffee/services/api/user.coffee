UserFactory = ($resource, $q, API_HOME, Device, Track, Artist) ->

  user_defaults =
    user_id: '@id'

  User = $resource [API_HOME, 'users', ':user_id', ':fn'].join('/'), user_defaults,
    tracks:
      method: 'GET'
      params:
        fn: 'tracks'
      isArray: true
      interceptor:
        response: (response) ->
          if (not response.data) or (not angular.isArray response.data)
            deferred.reject()

          deferred = $q.defer()
          parsed = []
          artists = {}
          artist_count = 0
          tracks = response.data

          delegateArtists = () ->
            for raw_track in tracks
              raw_track.artist = artists[raw_track.artist]
              parsed.push new Track raw_track
            deferred.resolve parsed

          check = () ->
            missing = false

            for id, artist of artists
              if artist.$resolved != true
                missing = true

            if !missing
              delegateArtists()
            else
              false

          fetch = (artist_id) ->
            addOne = (artist) ->
              check()

            failedOne = () ->
              deferred.reject()

            full = Api.Artist.get
              artist_id: artist_id

            full.$promise.then addOne, failedOne
            full

          getArtists = (tracks) ->
            for track, index in tracks
              if not artists[track.artist]
                artists[track.artist] = fetch track.artist
                artist_count++

          if tracks.length > 0
            getArtists(tracks)
          else
            deferred.resolve parsed

          deferred.promise

    devices:
      method: 'GET'
      url: [API_HOME, 'devicepermissions'].join('/')
      isArray: true
      interceptor:
        response: (response) ->
          data = response.data
          devices = []

          parse = (mapping) ->
            device = new Device mapping.device
            device.permission = mapping.level
            device

          if angular.isArray data
            devices.push parse(mapping) for mapping in data

          devices

lft.service 'Api/User', [
  '$resource',
  '$q',
  'API_HOME',
  'Api/Device',
  'Api/Track',
  'Api/Artist',
  UserFactory
]
