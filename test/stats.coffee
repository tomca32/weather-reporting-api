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
      postMeasurement({timestamp: '1005-09-01T16:00:00.000Z', temperature: '10.1', dewPoint: '12.9'}),
      postMeasurement({timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.9'}),
      postMeasurement({timestamp: '2015-09-01T16:10:00.000Z', temperature: '27.3'}),
      postMeasurement({timestamp: '2015-09-01T16:20:00.000Z', temperature: '27.5', dewPoint: '17.1'}),
      postMeasurement({timestamp: '2015-09-01T16:30:00.000Z', temperature: '27.4', dewPoint: '17.3'}),
      postMeasurement({timestamp: '2015-09-01T16:40:00.000Z', temperature: '27.2'}),
      postMeasurement({timestamp: '2015-09-01T17:00:00.000Z', temperature: '27.1', dewPoint: '18.3'})
      postMeasurement({timestamp: '3055-09-01T17:00:00.000Z', temperature: '45.1', dewPoint: '37.3'})
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

  it 'responds with with stats without lower timestamp boundary, if fromDateTime was not provided', (done) ->
    request(api).get('/stats')
      .query({stat: ['min', 'max', 'average'], metric: 'temperature', toDateTime: '2015-09-01T17:00:00.000Z'})
      .expect(200)
      .expect([
        {metric: 'temperature', stat: 'min', value: 10.1},
        {metric: 'temperature', stat: 'max', value: 27.5},
        {metric: 'temperature', stat: 'average', value: 24.433}
      ], done)
    return

  it 'responds with with stats without upper timestamp boundary, if toDateTime was not provided', (done) ->
    request(api).get('/stats')
      .query({stat: ['min', 'max', 'average'], metric: 'temperature', fromDateTime: '2015-09-01T16:00:00.000Z'})
      .expect(200)
      .expect([
        {metric: 'temperature', stat: 'min', value: 27.1},
        {metric: 'temperature', stat: 'max', value: 45.1},
        {metric: 'temperature', stat: 'average', value: 29.814}
      ], done)
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

  it 'responds with 400 if fromDateTime parameter is not a timestamp', (done) ->
    request(api).get('/stats')
      .query({stat: ['min', 'max', 'average'], metric: 'dewPoint', fromDateTime: 'NONSENSE', toDateTime: '2015-09-01T17:00:00.000Z'})
      .expect(400, done)
    return