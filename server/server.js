
var fs = require('fs');

var express = require('express');
var app = express();


app.get('/siri.json', function(req, res){
    var data = require('./data.json');

    var vehicles = data.Siri.ServiceDelivery.VehicleMonitoringDelivery[0].VehicleActivity;
    vehicles.forEach(function(vehicle) {
        var location = vehicle.MonitoredVehicleJourney.VehicleLocation;
        location.Longitude += 0.003;
        location.Latitude += 0.003;
    });

    var stringData = JSON.stringify(data)

    res.setHeader('Content-Type', 'application/json');
    res.send(stringData);

    fs.writeFileSync('data.json', stringData);
});


var server = app.listen(3000, function() {
    console.log('Listening on port %d', server.address().port);
});
