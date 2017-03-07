request = require('supertest')
api = require('../api')

describe 'GET /ping', ->
  it 'respond with pong', (done) ->
    request(api)
      .get('/ping')
      .expect(200)
      .expect('pong')
      .end (err, res) ->
        return done(err) if err
        done()
    return
