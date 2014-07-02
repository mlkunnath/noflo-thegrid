noflo = require 'noflo'
superagent = require 'superagent'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Retrieves available layout filters for a given theme.'
  c.endpointGroups = []

  # Defining in-ports.
  c.inPorts.add 'endpoint',
    datatype: 'string'
    description: 'Name of the theme being used.'
  c.inPorts.add 'data',
    datatype: 'object'
    description: "Data being send to the server"
    required: true
  c.inPorts.add 'token',
    datatype: 'string'
    description: 'API token used for authentication.'
    required: true

  # Defining out-ports.
  c.outPorts.add 'data',
    datatype: 'object'
    description: 'The data retrieved from the API endpoint.'
  c.outPorts.add 'status',
    datatype: 'int'
    description: 'The http status code of the response.'
  c.outPorts.add 'error',
    datatype: 'object'

  noflo.helpers.WirePattern c,
    in: 'endpoint'
    params: ['token', 'data']
    out: ['data', 'status']
    forwardGroups: true
    async: true
  , (url, groups, outPorts, callback) ->
    superagent.post url
    .send c.params.data
    .set('Authorization', "Bearer #{c.params.token}")
    .set('Accept', 'application/json')
    .end (err, res) ->
      return callback err if err

      outPorts['status'].send res.status
      return callback res.body if res.status >= 400

      outPorts['data'].send res.body
      callback()

  return c
