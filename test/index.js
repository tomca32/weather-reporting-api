const request = require('supertest');
const express = require('express');
const api = require('../api');
const test = require('tape');

test('/ping', function (t) {
  request(api)
    .get('/ping')
    .expect(200)
    .end(function(err, res) {
      t.error(err, 'no errors');
      t.same(res.text, 'pong', 'responds with pong');
      t.end();
    });
});
