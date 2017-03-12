request = require('supertest-as-promised')
async = require('async')
api = require('../api')
measurements = require('../api/measurements');

postMeasurement = (measurement) ->
  request api
    .post '/measurements'
    .send measurement

postMeasurementAsync = (measurement) -> (cb) -> postMeasurement(measurement).expect(201, cb)

putMeasurement = (timestamp, measurement) ->
  request api
    .put "/measurements/#{timestamp}"
    .send measurement

putMeasurementAsync = (timestamp, measurement, status = 204) -> (cb) -> putMeasurement(timestamp, measurement).expect(status, cb)

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

  it 'responds with 400 when a measurement without a timestamp is submitted', (done) ->
    request api
      .post '/measurements'
      .send {temperature: '21.7', dewPoint: '16.7', precipitation: '0'}
      .expect 400
      .end (err, res) ->
        return done(err) if err
        done()
    return

  it 'responds with 400 when a measurement with a nonsense timestamp is submitted', (done) ->
    request api
      .post '/measurements'
      .send {timstamp: 'H4X003 lolz', temperature: '21.7', dewPoint: '16.7', precipitation: '0'}
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

  it 'responds with 404 when getting a measurement that does not exist', (done) ->
    request api
      .get '/measurements/2015-09-01T16:50:00.000Z'
      .expect 404, (err) ->
        return done(err) if err
        done()
    return

  it 'responds with 400 when getting a measurement with a nonsense timestamp', (done) ->
    request api
      .get '/measurements/nonsense'
      .expect 400, (err) ->
        return done(err) if err
        done()
    return

  it 'returns all measurements made at a specific date', (done) ->
    request api
      .get '/measurements/2015-09-01'
      .expect 200
      .expect([
        {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'},
        {timestamp: '2015-09-01T16:10:00.000Z', temperature: '27.3', dewPoint: '16.9', precipitation: '0'},
        {timestamp: '2015-09-01T16:20:00.000Z', temperature: '27.5', dewPoint: '17.1', precipitation: '0'},
        {timestamp: '2015-09-01T16:30:00.000Z', temperature: '27.4', dewPoint: '17.3', precipitation: '0'},
        {timestamp: '2015-09-01T16:40:00.000Z', temperature: '27.2', dewPoint: '17.2', precipitation: '0'}
      ], (err) ->
        return done(err) if err
        done()
      )
    return

  it 'responds with 404 when getting measurements from a day where no measurements were taken.', (done) ->
    request api
      .get '/measurements/2015-09-03'
      .expect 404, (err) ->
        return done(err) if err
        done()
    return

describe 'PUT /measurements', ->
  beforeEach (done) ->
    measurements.clean()
    async.series([
      postMeasurementAsync({timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}),
      postMeasurementAsync({timestamp: '2015-09-01T16:10:00.000Z', temperature: '27.3', dewPoint: '16.9', precipitation: '0'}),
    ], done)

  it 'replaces an existing measurement', (done) ->
    async.series([
      putMeasurementAsync('2015-09-01T16:00:00.000Z', {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '15.2'}),
      (cb) ->
        request(api).get '/measurements/2015-09-01T16:00:00.000Z'
          .expect 200
          .expect {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '15.2'}, cb
    ], done)
    return

  it 'responds with 400 when trying to replace a measurement with invalid values', (done) ->
    async.series([
      putMeasurementAsync('2015-09-01T16:00:00.000Z', {timestamp: '2015-09-01T16:00:00.000Z', temperature: 'invalid value', dewPoint: '16.7', precipitation: '15.2'}, 400),
      (cb) ->
        request(api).get '/measurements/2015-09-01T16:00:00.000Z'
          .expect 200
          .expect {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}, cb
    ], done)
    return

  it 'responds with 409 when trying to replace a measurement with mismatched timestamps', (done) ->
    async.series([
      putMeasurementAsync('2015-09-01T16:00:00.000Z', {timestamp: '2015-09-02T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '15.2'}, 409),
      (cb) ->
        request(api).get '/measurements/2015-09-01T16:00:00.000Z'
          .expect 200
          .expect {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}, cb
    ], done)
    return

  it 'responds with 404 when trying to replace a measurement that does not exist', (done) ->
    async.series([
      putMeasurementAsync('2015-09-02T16:00:00.000Z', {timestamp: '2015-09-02T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '15.2'}, 404),
    ], done)
    return
