request = require('supertest-as-promised')
async = require('async')
api = require('../api')
measurements = require('../api/measurements');

measurementsRequest = (method, measurement, timestamp = '') ->
  request(api)[method]("/measurements/#{timestamp}")
    .send measurement

postMeasurement = (measurement) -> (cb) -> measurementsRequest('post', measurement).expect(201, cb)

describe 'GET /stats', ->
  beforeEach (done) ->
    measurements.clean()
    async.series([
      postMeasurement({timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7'}),
      postMeasurement({timestamp: '2015-09-01T16:10:00.000Z', temperature: '27.3'}),
      postMeasurement({timestamp: '2015-09-01T16:20:00.000Z', temperature: '27.5', dewPoint: '17.1'}),
      postMeasurement({timestamp: '2015-09-01T16:30:00.000Z', temperature: '27.4', dewPoint: '17.3'}),
      postMeasurement({timestamp: '2015-09-01T16:40:00.000Z', temperature: '27.2'}),
      postMeasurement({timestamp: '2015-09-01T17:00:00.000Z', temperature: '27.1', dewPoint: '18.1'})
    ], done)

  it 'responds with stats for a well reported metric', (done) ->
    request(api).get('/stats')
      .query({stat: ['min', 'max', 'average'], metric: 'temperature', fromDateTime: '2015-09-01T16:00:00.000Z', toDateTime: '2015-09-01T17:00:00.000Z'})
      .expect(200)
      .expect([
        {metric: 'temperature', stat: 'min', value: '27.1'},
        {metric: 'temperature', stat: 'max', value: '27.5'},
        {metric: 'temperature', stat: 'average', value: '27.3'}
      ], done)
    return
