request = require('supertest')
api = require('../api')

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
