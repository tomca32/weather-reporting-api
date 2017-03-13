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
      postMeasurement({timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.9'}),
      postMeasurement({timestamp: '2015-09-01T16:10:00.000Z', temperature: '27.3'}),
      postMeasurement({timestamp: '2015-09-01T16:20:00.000Z', temperature: '27.5', dewPoint: '17.1'}),
      postMeasurement({timestamp: '2015-09-01T16:30:00.000Z', temperature: '27.4', dewPoint: '17.3'}),
      postMeasurement({timestamp: '2015-09-01T16:40:00.000Z', temperature: '27.2'}),
      postMeasurement({timestamp: '2015-09-01T17:00:00.000Z', temperature: '27.1', dewPoint: '18.3'})
    ], done)

  it 'responds with stats for a well reported metric', (done) ->
    request(api).get('/stats')
      .query({stat: ['min', 'max', 'average'], metric: 'temperature', fromDateTime: '2015-09-01T16:00:00.000Z', toDateTime: '2015-09-01T17:00:00.000Z'})
      .expect(200)
      .expect([
        {metric: 'temperature', stat: 'min', value: 27.1},
        {metric: 'temperature', stat: 'max', value: 27.5},
        {metric: 'temperature', stat: 'average', value: 27.3}
      ], done)
    return

  it 'responds with stats for a sparsely reported metric', (done) ->
    request(api).get('/stats')
      .query({stat: ['min', 'max', 'average'], metric: 'dewPoint', fromDateTime: '2015-09-01T16:00:00.000Z', toDateTime: '2015-09-01T17:00:00.000Z'})
      .expect(200)
      .expect([
        {metric: 'dewPoint', stat: 'min', value: 16.9},
        {metric: 'dewPoint', stat: 'max', value: 17.3},
        {metric: 'dewPoint', stat: 'average', value: 17.1}
      ], done)
    return

  it 'responds with empty array when requesting stats for a metric that has never been reported', (done) ->
    request(api).get('/stats')
      .query({stat: ['min', 'max', 'average'], metric: 'precipitation', fromDateTime: '2015-09-01T16:00:00.000Z', toDateTime: '2015-09-01T17:00:00.000Z'})
      .expect(200)
      .expect([], done)
    return

  it 'responds with stats for multiple metrics', (done) ->
    request(api).get('/stats')
      .query({stat: ['min', 'max', 'average'], metric: ['temperature', 'dewPoint', 'precipitation'], fromDateTime: '2015-09-01T16:00:00.000Z', toDateTime: '2015-09-01T17:00:00.000Z'})
      .expect(200)
      .expect([
        {metric: 'temperature', stat: 'min', value: 27.1},
        {metric: 'temperature', stat: 'max', value: 27.5},
        {metric: 'temperature', stat: 'average', value: 27.3},
        {metric: 'dewPoint', stat: 'min', value: 16.9},
        {metric: 'dewPoint', stat: 'max', value: 17.3},
        {metric: 'dewPoint', stat: 'average', value: 17.1}
      ], done)
    return