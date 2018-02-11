import axios from "axios";
import qs from "query-string";
import { memoize } from "lodash";
import { GOOGLE_MAP_API_KEY as api_key } from "./globals";

const geocoder = new google.maps.Geocoder;

/**
 * @param {array} waypoints - an array of objects with shape of { lat, lng }
 */
const snapToRoads = async (waypoints) => {
    var pathValues = waypoints.map((w) => {
        const {lat, lng} = w;

        return `${lat},${lng}`;
    });

    const params = {
        interpolate: true,
        key: api_key,
        path: pathValues.join('|')
    };
    const url = `https://roads.googleapis.com/v1/snapToRoads?${qs.stringify(params)}`;

    try {
        const response = await axios.get(url);
        const data = response.data;

        return data.snappedPoints.map((point) => {
            return new google.maps.LatLng(point.location.latitude, point.location.longitude);
        });
    } catch (e) {
        return false;
    }
};

const _reverseGeocode = (lat, lng) => {
    return new Promise((resolve, reject) => {
        geocoder.geocode({"location": new google.maps.LatLng(lat, lng)}, (results, status) => {
            if (status === "OK") {
                resolve(results);
            } else {
                reject();
            }
        });
    });
};
const reverseGeocode = memoize(_reverseGeocode);

export { snapToRoads, reverseGeocode }