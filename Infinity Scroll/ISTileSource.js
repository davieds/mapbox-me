var mapId = 'justin.map-pgygbwdm';
var tileTemplateUrl = 'https://a.tiles.mapbox.com/v3/{mapId}/{z}/{x}/{y}.png';

function tileMake(z, x, y) {
    var result = {
        'z': z,
        'x': x,
        'y': y
    };
    return result;
}

function tileKey(tile) {
    return tile.z + '_' + tile.x + '_' + tile.y;
}

function imageDataForTile(tile) {
    var tileCachePath = '/tmp/' + mapId + '_' + tileKey(tile) + '.png';

    // check file cache

    var tileUrlString = tileTemplateUrl.replace('{mapId}', mapId)
                                       .replace('{z}', tile.z)
                                       .replace('{x}', tile.x)
                                       .replace('{y}', tile.y);

    var tileData = '';

    if (typeof XMLHttpRequest !== 'undefined') {
        var req = new XMLHttpRequest();
        req.open('GET', tileUrlString, false);
        req.overrideMimeType('text\/plain; charset=x-user-defined');
        req.send();
        tileData = req.response;
    } else if (typeof CocoaGet !== 'undefined') {
        tileData = CocoaGet(tileUrlString);
    }

    // store to file cache
    return tileData; // for ObjC
    // return encode64(tileData); // for real JS
}

function encode64(inputStr) 
{
   var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
   var outputStr = "";
   var i = 0;
   
   while (i<inputStr.length)
   {
      //all three "& 0xff" added below are there to fix a known bug 
      //with bytes returned by xhr.responseText
      var byte1 = inputStr.charCodeAt(i++) & 0xff;
      var byte2 = inputStr.charCodeAt(i++) & 0xff;
      var byte3 = inputStr.charCodeAt(i++) & 0xff;

      var enc1 = byte1 >> 2;
      var enc2 = ((byte1 & 3) << 4) | (byte2 >> 4);
	  
	  var enc3, enc4;
	  if (isNaN(byte2))
	   {
		enc3 = enc4 = 64;
	   }
	  else
	  {
      	enc3 = ((byte2 & 15) << 2) | (byte3 >> 6);
		if (isNaN(byte3))
		  {
           enc4 = 64;
		  }
		else
		  {
	      	enc4 = byte3 & 63;
		  }
	  }

      outputStr +=  b64.charAt(enc1) + b64.charAt(enc2) + b64.charAt(enc3) + b64.charAt(enc4);
   } 
   
   return outputStr;
}

// window.onload = function() {
//     var img = imageDataForTile(tileMake(0, 0, 0));
//     document.getElementsByTagName('img')[0].setAttribute('src', 'data:image/jpeg;base64,' + img);
// }