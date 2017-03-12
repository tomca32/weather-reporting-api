request = require('supertest-as-promised')
async = require('async')
api = require('../api')
measurements = require('../api/measurements');

measurementsRequest = (method, measurement, timestamp = '') ->
  request(api)[method]("/measurements/#{timestamp}")
    .send measurement


postMeasurement = (measurement) -> (cb) -> measurementsRequest('post', measurement).expect(201, cb)

putMeasurement = (timestamp, measurement, status = 204) -> (cb) -> measurementsRequest('put', measurement, timestamp).expect(status, cb)

patchMeasurement = (timestamp, measurement, status = 204) -> (cb) -> measurementsRequest('patch', measurement, timestamp).expect(status, cb)

deleteMeasurement = (timestamp, status = 204) -> (cb) -> request(api).delete("/measurements/#{timestamp}").expect(status, cb)

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
      postMeasurement({timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}),
      postMeasurement({timestamp: '2015-09-01T16:10:00.000Z', temperature: '27.3', dewPoint: '16.9', precipitation: '0'}),
      postMeasurement({timestamp: '2015-09-01T16:20:00.000Z', temperature: '27.5', dewPoint: '17.1', precipitation: '0'}),
      postMeasurement({timestamp: '2015-09-01T16:30:00.000Z', temperature: '27.4', dewPoint: '17.3', precipitation: '0'}),
      postMeasurement({timestamp: '2015-09-01T16:40:00.000Z', temperature: '27.2', dewPoint: '17.2', precipitation: '0'}),
      postMeasurement({timestamp: '2015-09-02T16:00:00.000Z', temperature: '27.1', dewPoint: '18.3', precipitation: '0'})
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
      postMeasurement({timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}),
      postMeasurement({timestamp: '2015-09-01T16:10:00.000Z', temperature: '27.3', dewPoint: '16.9', precipitation: '0'}),
    ], done)

  it 'replaces an existing measurement', (done) ->
    async.series([
      putMeasurement('2015-09-01T16:00:00.000Z', {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '15.2'}),
      (cb) ->
        request(api).get '/measurements/2015-09-01T16:00:00.000Z'
          .expect 200
          .expect {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '15.2'}, cb
    ], done)
    return

  it 'responds with 400 when trying to replace a measurement with invalid values', (done) ->
    async.series([
      putMeasurement('2015-09-01T16:00:00.000Z', {timestamp: '2015-09-01T16:00:00.000Z', temperature: 'invalid value', dewPoint: '16.7', precipitation: '15.2'}, 400),
      (cb) ->
        request(api).get '/measurements/2015-09-01T16:00:00.000Z'
          .expect 200
          .expect {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}, cb
    ], done)
    return

  it 'responds with 409 when trying to replace a measurement with mismatched timestamps', (done) ->
    async.series([
      putMeasurement('2015-09-01T16:00:00.000Z', {timestamp: '2015-09-02T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '15.2'}, 409),
      (cb) ->
        request(api).get '/measurements/2015-09-01T16:00:00.000Z'
          .expect 200
          .expect {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}, cb
    ], done)
    return

  it 'responds with 404 when trying to replace a measurement that does not exist', (done) ->
    async.series([
      putMeasurement('2015-09-02T16:00:00.000Z', {timestamp: '2015-09-02T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '15.2'}, 404),
    ], done)
    return

describe 'PATCH /measurements', ->
  beforeEach (done) ->
    measurements.clean()
    async.series([
      postMeasurement({timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}),
      postMeasurement({timestamp: '2015-09-01T16:10:00.000Z', temperature: '27.3', dewPoint: '16.9', precipitation: '0'}),
    ], done)

  it 'updates the metrics of an existing measurement', (done) ->
    async.series([
      patchMeasurement('2015-09-01T16:00:00.000Z', {timestamp: '2015-09-01T16:00:00.000Z', precipitation: '12.3'}),
      (cb) ->
        request(api).get '/measurements/2015-09-01T16:00:00.000Z'
          .expect 200
          .expect {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '12.3'}, cb
    ], done)

  it 'responds with 400 when trying to update a measurement with invalid values', (done) ->
    async.series([
      patchMeasurement('2015-09-01T16:00:00.000Z', {timestamp: '2015-09-01T16:00:00.000Z', precipitation: 'invalid value'}, 400),
      (cb) ->
        request(api).get '/measurements/2015-09-01T16:00:00.000Z'
          .expect 200
          .expect {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}, cb
    ], done)

  it 'responds with 409 when trying to update a measurement with mismatched timestamps', (done) ->
    async.series([
      patchMeasurement('2015-09-01T16:00:00.000Z', {timestamp: '2015-09-02T16:00:00.000Z', precipitation: '12.3'}, 409),
      (cb) ->
        request(api).get '/measurements/2015-09-01T16:00:00.000Z'
          .expect 200
          .expect {timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}, cb
    ], done)
    return

  it 'responds with 404 when trying to update a measurement that does not exist', (done) ->
    async.series([
      patchMeasurement('2015-09-02T16:00:00.000Z', {timestamp: '2015-09-02T16:00:00.000Z', precipitation: '12.3'}, 404),
    ], done)
    return

describe 'DELETE /measurements', ->
  beforeEach (done) ->
    measurements.clean()
    async.series([
      postMeasurement({timestamp: '2015-09-01T16:00:00.000Z', temperature: '27.1', dewPoint: '16.7', precipitation: '0'}),
      postMeasurement({timestamp: '2015-09-01T16:10:00.000Z', temperature: '27.3', dewPoint: '16.9', precipitation: '0'}),
    ], done)

  it 'deletes an existing measurement', (done) ->
    async.series([
      deleteMeasurement('2015-09-01T16:00:00.000Z'),
      (cb) -> request(api).get('/measurements/2015-09-01T16:00:00.000Z').expect(404, cb),
      (cb) ->
        request(api).get('/measurements/2015-09-01T16:10:00.000Z')
        .expect 200
        .expect {timestamp: '2015-09-01T16:10:00.000Z', temperature: '27.3', dewPoint: '16.9', precipitation: '0'}, cb
    ], done);

  it 'responds with 404 when trying to delete a measurement that does not exist', (done) ->
    async.series([
      deleteMeasurement('2015-09-01T16:20:00.000Z', 404)
    ], done);
