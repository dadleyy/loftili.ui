lft.directive 'lfDeviceItem', ['Api', 'Auth', (Api, Auth) ->

  lfDeviceItem =
    replace: true
    templateUrl: 'directives.device_item'
    scope:
      device: '='
      ondelete: '&'
      index: '='
    link: ($scope, $element, $attrs) ->
      # private
      pingSuccess = (response) ->
        if(response.device)
          $scope.device.updatedAt = response.device.updatedAt

        $scope.device.status = true

      pingFail = (response) ->
        if(response.device)
          $scope.device.updatedAt = response.device.updatedAt

        $scope.device.status = false

      # public
      $scope.delete = (device) ->
        success = () ->
          $scope.ondelete()

        fail = () ->
          console.log 'the device was not removed!'

        device.$delete().then success, fail
        Api.DnsRecord.delete({device: device.id, user: Auth.user().id})

      $scope.play = () ->
        console.log 'sending play signal'

      $scope.refresh = () ->
        Api.Device.ping({device_id: $scope.device.id}).$promise.then pingSuccess, pingFail

      $scope.revertPropery = (property, value) ->
        $scope.device[property] = value

      $scope.saveProperty = (property, value) ->
        $scope.device[property] = value

        success = () ->
          console.log 'updated successfully'
        fail = () ->
          console.log 'failed updating'

        $scope.device.$save().then success, fail

]
