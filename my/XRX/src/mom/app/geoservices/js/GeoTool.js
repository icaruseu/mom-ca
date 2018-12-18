/**js-functions to create a map and set markers for positions of charters or archives **/

;(function( $, undefined){
$.widget("ui.GeoTool",{


	options:{
		requestroot: "",
		serviceLink: "",
		imageLink: "",
		mode: "",
		linklabel: "",
		collection: "",
        lat: 0.0,
        lng: 0.0,
        zoomlevel: 0.0,
		zoom: 0,
		loadergif: "resource/?atomid=tag:www.monasterium.net,2011:/mom/resource/images/loader"
	},

	/** constructor **/
	_create: function(){
		var self = this;
		self._createMap();


	},

	/** create leaflet-Map **/
	_createMap: function(){
	    var self = this;

		this.mainMapLayer = L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
			maxZoom: 18,
			attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
				'<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
				'Imagery Â© <a href="http://mapbox.com">Mapbox</a>',
			id: 'mapbox.streets'
		});

		var latlng = [];
		var zoom;
		/**
		 * position of view in map
		 * when values for lat, lng and zoom exist use these, else use default values **/
		if (self.options.lat != 0.0 && self.options.lng !=0.0){
		    latlng = [self.options.lat, self.options.lng];
		    if(self.options.zoom !=0)
		    	zoom = self.options.zoom;
		    else
		    	zoom = 7;
        }
        else{
		    latlng = [ 51.50, 20.21 ];
            zoom = 4;
		}
		this.map = L.map('map')
		.setView(latlng, zoom)
		.addLayer(self.mainMapLayer);


		/** create markers-groups layers and icons for marker * */
		this.markers = new L.MarkerClusterGroup();
		this.markers2 = new L.MarkerClusterGroup();
		this.LeafIcon = L.Icon.extend({
			options: {
				iconSize:     [28, 28],
			}
		});

	    this.archiveIcon = L.icon({
	    	iconUrl: self.options.imageLink,
			iconSize:     [28, 28],
	    })

	    this.collectionIcon = new self.LeafIcon({iconUrl: 'img/collection.png'});
	    this.charterIcon = new self.LeafIcon({iconUrl: 'img/charter.png'});

	    self.map.addLayer(self.markers);
	    self.map.addLayer(self.markers2);


	    /** get data **/
		self._getJson();


		/** when pop-up opens create informations inside popup. Important for chartermap **/
		self.map.on('popupopen', function(ev){
            latlng = ev.popup._latlng;
            actualZoom = self.map.getZoom();
            $(".clickLink").click(function(e){
				place = $(this).attr("place");
				count = $(this).attr("count");
                $.ajax({
                    type: "GET",
                    dataType: 'xml',
                    url: self.options.requestroot + "service/geolocations-charter-results",
                    data: {clickedLocation: place},
					success: function(data){
                    	url = $(location).attr("href")
                    	linkroot = url.substr(0, url.indexOf("?"));
                    	lat = latlng.lat;
                    	lng = latlng.lng;
						window.location.href = linkroot+"?place="+place+"&count="+count+"&pos=1&steps=5&mapview="+lat+";"+lng+"&zoom="+actualZoom+"#results";
                    	},
                    error: function (jqXHR, textStatus, errorThrown) {
                        console.log(jqXHR, textStatus, errorThrown);
                    }
                });
			});

		})
	},

    /**
     * load json-data from database.
     * If options.mode = fonds load json-data related to fonds and run function _createMarker
     * if options.mode = collection load json-data related to charters und run function _createMarkerForCharters.
     **/
    _getJson: function(){
        var self = this;
        mode = self.options.mode;
        if(mode == "fonds") {
            $.ajax({

                type: "GET",
                dataType: 'json',
                url: self.options.serviceLink,
                success: function (json) {
                    self._createMarkerForArchives(json);
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.log(jqXHR, textStatus, errorThrown);
                }
            });
        }
        if(mode == "collection"){
            $(".loader").removeClass("inactive").addClass("active");;
            $.ajax({
                type: "GET",
                dataType: 'json',
                url: self.options.serviceLink,
                data: {collectionpath : self.options.collection},

                success: function(json){
                    $(".loader").removeClass("active").addClass("inactive");;
                    self._createMarkerForCharters(json);
                    if(self.options.lat == 0 && self.options.lng == 0)
                        self.map.fitBounds(self.markers.getBounds());
                },
                error: function (jqXHR, textStatus, errorThrown) {
                    console.log(jqXHR, textStatus, errorThrown);
                }
            });
        }

    },


	/**place markers an map **/
    _setMarker: function(lat, lng, result, mode){
		var self = this;
        if(mode =="charter"){
            var marker = L.marker([lat, lng], {icon: self.charterIcon});
        }
        else{
            var marker = L.marker([lat, lng], {icon: self.archiveIcon});
        }
        marker.bindPopup(result);
        self.markers.addLayer(marker);
	},

	/** create Markers for Archive **/
	_createMarkerForArchives: function(json){
		self = this;
        for(var locationsCounter = 0, locationsLength = json.geolocations.length; locationsCounter < locationsLength; locationsCounter++ ){
            var lat = json.geolocations[locationsCounter].lat;
            var lng = json.geolocations[locationsCounter].lng;
            if(!json.geolocations[locationsCounter].name){
                json.geolocations[locationsCounter].name = "???";
            }
            var result = "<b>"+json.geolocations[locationsCounter].name+"</b><br />";
            for (var resultsCounter = 0, resultsLength = json.geolocations[locationsCounter].results.length; resultsCounter < resultsLength; resultsCounter++) {
            	result = result + "<a href='"+json.geolocations[locationsCounter].results[resultsCounter].url+"'>"+json.geolocations[locationsCounter].results[resultsCounter].displayText+'</a><br/>';
            }
            self._setMarker(lat, lng, result, "archives");
        }

	},

	/** create Markers for Charters **/
	_createMarkerForCharters: function(json){
		self = this;
        for(var locationsCounter = 0, locationsLength = json.geolocations.length; locationsCounter < locationsLength; locationsCounter++ ){
            var lat = json.geolocations[locationsCounter].lat;
            var lng = json.geolocations[locationsCounter].lng;
            if(!json.geolocations[locationsCounter].name){
                json.geolocations[locationsCounter].name = "???";
            }
            var result = "<b>"+json.geolocations[locationsCounter].name+"</b><br />";
            result = result + "<a class='clickLink' href='#' place='"+json.geolocations[locationsCounter].name+"' count='"+json.geolocations[locationsCounter].results.length+"'>"+json.geolocations[locationsCounter].results.length+" "+self.options.linklabel+"</a><br/>";
            self._setMarker(lat, lng, result, "archives");

        }
        },
	});


})

( jQuery );










