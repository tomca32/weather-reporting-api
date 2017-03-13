# Weather Reporting API

 This is a simple API made for storing, and reporting, weather data. Data is stored in memory with no persistence of any kind.

## Installation

Open up your terminal and start typing:

```sh
$ git clone https://github.com/tomca32/weather-reporting-api.git
$ cd weather-reporting-api
$ npm install
$ npm start
```

In case you want to run tests:

```sh
$ npm test
```

By default, the application will start listening on port 3000. If you want to listen on some other port, run it like this:

```sh
$ npm start -- --port 8080 # This will run on port 8080
```

# API Reference

## Storing data

Application exposes several endpoints for storing and retrieving data, as well as one endpoint for reporting data statistics.

Storing a data point is done by submitting a POST request containing a timestamp and one, or multiple, data points. For example, let's store a temperature reading of 12.5C made on the 1st of September 2015 at 4PM:

```
POST http://localhost:3000/measurements

{"timestamp": "2015-09-01T16:00:00.000Z", "temperature": "12.5"}
```

It is possible to store any metric, you are not restricted to temperature. For example:

```
POST http://localhost:3000/measurements

{"timestamp": "2016-09-01T16:00:00.000Z", "temperature": "15.5", "precipitation": "5.0", "yourmetric": "10.1"}
```

All of the above are valid values and will be stored. The only thing that API requires is a timestamp in ISO-8601 format and metrics as numerical values. Non-numerical values are not valid and will cause the application to respond with 400 Bad Request.

```
POST http://localhost:3000/measurements

{"timestamp": "2016-09-01T16:00:00.000Z", "invalid": "I am an invalid value"}
```

The above will result in a 400 response.

## Retrieving data

Measurements are identified by their timestamps. To retrieve measurements made at a particular time, submit a GET request like the following:

```
GET http://localhost:3000/measurements/2015-09-01T16:20:00.000Z
```

This will produce a response containing a single JSON object (if it exists):

```
{timestamp: '2015-09-01T16:20:00.000Z', temperature: 27.5, dewPoint: 17.1, precipitation: 0}
```

All metrics associated with the timestamp will be returned, including the timestamp itself.

It is also possible to retrieve multiple metrics. For example, all metrics with a particular date in the timestamp, by omitting the time value from the timestamp. For example:

```
GET http://localhost:3000/measurements/measurements/2015-09-01
```

will retrieve all measurements made on the 1st of September 2015:

```
[
    {timestamp: '2015-09-01T16:00:00.000Z', temperature: 27.1, dewPoint: 16.7, precipitation: 0},
    {timestamp: '2015-09-01T16:10:00.000Z', temperature: 27.3, dewPoint: 16.9, precipitation: 0},
    {timestamp: '2015-09-01T16:20:00.000Z', temperature: 27.5, dewPoint: 17.1, precipitation: 0},
    {timestamp: '2015-09-01T16:30:00.000Z', temperature: 27.4, dewPoint: 17.3, precipitation: 0},
    {timestamp: '2015-09-01T16:40:00.000Z', temperature: 27.2, dewPoint: 17.2, precipitation: 0}
]
```

## Updating Measurements

There are two ways of updating measurements. You can replace the whole measurement with a new set of metrics, or you can update individual metrics.

### Replacing Measurements

Replacing measurements is done by submitting PUT requests with the new data. For example:

```
PUT http://localhost:3000/measurements/2015-09-01T16:00:00.000Z

{timestamp: '2015-09-01T16:00:00.000Z', temperature: 27.1, dewPoint: 16.7, precipitation: 15.2}
```

If everything is in order, and the operation succeeded, the response will be 204.

Note that timestamp is duplicated in the request body. This is required and if it's missing, the application will respond with 400 (Bad Request).

***This operation will completely replace the existing measurement and you will lose ALL data that was associated with it.***

### Updating Metrics

Updating metrics is done by submitting a PATCH request with a subset of metrics to update. Example:

```
PATCH http://localhost:3000/measurements/2015-09-01T16:00:00.000Z

{timestamp: '2015-09-01T16:00:00.000Z', temperature: 35.5}
```

Application will respond with 204 if the operation is successful.

This will update the existing measurement with the metrics submitted. Existing metrics will be updated and new ones will be created if they didn't exist before.
Timestamp value is required in the body, like in the PUT request.

## Deleting Measurements

Measurements can be deleted by submitting a DELETE request like the following:

```
PATCH http://localhost:3000/measurements/2015-09-01T16:00:00.000Z
```

This will result in deletion specified measurement and all associated metrics. Successful response is 204.

## Retrieving Statistics

It is possible to retrieve some statistics about the stored data via the `/stats` endpoint. Available statistics are:
- `max` - for maximal reported value of metric
- `min` - for minimal reported value of metric
- `average` - for the average (mean) metric value

Here's an example request:

```
GET http://localhost:3000/stats?stat=min&stat=max&stat=average&metric=temperature&metric=dewPoint&fromDateTime=2015-09-01T16%3A00%3A00.000Z&toDateTime=2015-09-01T17%3A00%3A00.000Z
```

There's a lot of parameters there so let's go through them:

 - `stat` - This is the statistic we are looking for. As mentioned above, it can be `max`, `min`, or `average`. It's also possible to repeat the parameter with different values to retrieve multiple statistics, like in the example above.
 - `metric` - This is the metric that we want to retrieve the statistics for. It can also be repeated. The above query will retrieve stats for temperature and dew point.
 - `fromDateTime` (optional) - ISO 8601 timestamp to serve as the lower boundary for the results. This value is inclusive, meaning it will also include the measurement made at exactly that time.
 - `toDateTime` (optional) - ISO 8601 timestamp to serve as the upper boundary for the results. This value is excluse, meaning it will NOT include the measurement made at exactly that time.

This request will result in a 200 OK response containing a JSON array of objects. Here's an example response:

```
[
    {metric: 'temperature', stat: 'min', value: 27.1},
    {metric: 'temperature', stat: 'max', value: 27.5},
    {metric: 'temperature', stat: 'average', value: 27.3},
    {metric: 'dewPoint', stat: 'min', value: 16.9},
    {metric: 'dewPoint', stat: 'max', value: 17.3},
    {metric: 'dewPoint', stat: 'average', value: 17.1}
]
```

## Feedback, bug reports

Please use the Github issues to report any problems with the API.