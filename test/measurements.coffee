request = require('supertest-as-promised')
async = require('async')
api = require('../api')

postMeasurement = (measurement) ->
  request api
    .post '/measurements'
    .send measurement

postMeasurementAsync = (measurement) -> (cb) -> postMeasurement(measurement).expect(201, cb)

describe 'POST /measurements', ->
  it 'responds with 201 and a Location header when a new measurement is created', (done) ->
    request api
      .post '/measurements'
      .send {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}
      .expect 201
      .expect 'Location', '/measurements/2015-09-01T16:00:00.000Z'
      .end (err, res) ->
        return done(err) if err
        done()
    return

  it 'responds with 400 when a measurement without timestamp is submitted', (done) ->
    request api
      .post '/measurements'
      .send {temperature: '21.7', dewPoint: '16.7', precipitation: '0'}
      .expect 400
      .end (err, res) ->
        return done(err) if err
        done()
    return

  it 'responds with 400 when any measurement value is not a number', (done) ->
    request api
      .post '/measurements'
      .send {timestamp: '2015-09-01T16:00:00.000Z', temperature: 'I am wrong', dewPoint: 'As am I', precipitation: '0'}
      .expect 400
      .end (err, res) ->
        return done(err) if err
        done()
    return

describe 'GET /measurements', ->
  beforeEach (done) ->
    async.series([
      postMeasurementAsync({timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}),
      postMeasurementAsync({timestamp: '2015-09-01T16:10:00.000Z', temperature: '27.3', dewPoint: '16.9', precipitation: '0'}),
      postMeasurementAsync({timestamp: '2015-09-01T16:20:00.000Z', temperature: '27.5', dewPoint: '17.1', precipitation: '0'}),
      postMeasurementAsync({timestamp: '2015-09-01T16:30:00.000Z', temperature: '27.4', dewPoint: '17.3', precipitation: '0'}),
      postMeasurementAsync({timestamp: '2015-09-01T16:40:00.000Z', temperature: '27.2', dewPoint: '17.2', precipitation: '0'}),
      postMeasurementAsync({timestamp: '2015-09-02T16:00:00.000Z', temperature: '27.1', dewPoint: '18.3', precipitation: '0'})
    ], done)

  it 'returns a specific measurement', (done) ->
    request api
      .get '/measurements/2015-09-01T16:20:00.000Z'
      .expect(200)
      .expect({timestamp: '2015-09-01T16:20:00.000Z', temperature: '27.5', dewPoint: '17.1', precipitation: '0'})
      .end (err, res) ->
        return done(err) if err
        done()
    return
