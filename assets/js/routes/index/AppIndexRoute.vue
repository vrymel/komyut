<template>
  <div class="app-index-route">
    <div class="map-container">
      <google-map
      @click="mapClick">
        <google-map-circle 
          v-for="(intersection) in debugIntersections"
          :key="intersection.id"
          :center="intersection"/>

        <google-map-polyline 
          v-if="routePath.length"
          :name="'routePath'"
          :path="routePath" />

        <google-map-polyline
          v-for="(segment, index) in searchPathSegments"
          :key="segment.id"
          :name="'searchPathSegments'"
          :path="segment.path"
          :stroke-color="getSegmentColor(index)"/>

        <google-map-marker
          v-if="!isObjectEmpty(searchFromCoordinate)"
          :position="searchFromCoordinate"
          :label="'A'" />

        <google-map-marker
          v-if="!isObjectEmpty(searchToCoordinate)"
          :position="searchToCoordinate"
          :label="'B'" />
      </google-map>
    </div>

    <div 
    class="sidebar">
      <div class="m-2 card">
        <div class="card-body">
          <h6 class="card-title">Debug controls</h6>
          
          <div class="card-block">
            <toggle-button
              :value="'debugShowIntersections'"
              :active="debugShowIntersections"
              @click="debugOnShowIntersections">
              <i 
                class="fa"
                :class="{ 'fa-eye-slash': !showIntersections, 'fa-eye': showIntersections }"/>
            </toggle-button>
          </div>
        </div>
      </div>

      <div class="m-2 card">
        <div class="card-body">
          <h6 class="card-title">City</h6>

          <div class="card-text">
            Cagayan de Oro City
          </div>
        </div>

        <div 
          class="m-2 card route-select"
          @click="routeSelect">
          <div class="card-body">
            <h6 class="card-title">Route</h6>

            <div 
              class="card-text"
              v-if="currentRoute">
              {{ currentRoute.description }}
            </div>
            <div 
              v-else
              class="card-text no-route-selected">No route selected</div>
          </div>
        </div>
      </div>

      <div class="m-2 card">
        <div class="card-body">
          <h6 class="card-title">Search route</h6>
          
          <search-route-select 
            v-if="!searchPathSegments.length"
            :from-address="searchFromCoordinate"
            :to-address="searchToCoordinate" />
          
          <div 
            class="search-route-results"
            v-else>
            <div 
              class="route-segment"
              v-for="(routeSegment, index) in routeSegmentsDisplay"
              :key="routeSegment.id"
              :style="{ borderColor: getSegmentColor(index), backgroundColor: getSegmentColor(index, 0.4) }"
            >
              {{ routeSegment.description }}
            </div>
          </div>

          <div class="card-block mt-4">
            <button 
              class="btn btn-primary"
              @click="searchPath">Search</button>
          </div>
        </div>
      </div>
    </div>

    <route-select-dialog
      v-show="showSelectRouteDialog"
      :routes="routes"
      @close="closeSelectRouteDialog"
      @routeSelected="routeSelected"/>
  </div>
</template>

<script>
import axios from "axios";
import { isEmpty } from "lodash";

import api_paths from "../api_paths";
import { APP_LOGO } from "../globals";
import { snapToRoads } from "../services";
import ToggleButton from "../common/ToggleButton";

import Map from "../common/Map";
import Circle from "../common/Circle";
import Polyline from "../common/Polyline";
import Marker from "../common/Marker";

import RouteSelectDialog from "./RouteSelectDialog";
import SearchRouteSelect from "./SearchRouteSelect";

const getRoutes = async () => {
    try {
        const result = await axios.get(api_paths.ROUTE_API_INDEX);

        return result.data;
    } catch (e) {
        // TODO: add sentry log
        return false;
    }
};

const getRoute = async (routeId) => {
    try {
        const result = await axios.get(`${api_paths.ROUTE_API_INDEX}/${routeId}`);

        return result.data;
    } catch (e) {
        // TODO: add sentry log
        return false;
    }
};

const getIntersections = async () => {
    try {
        const response = await axios.get(api_paths.INTERSECTION_API_INDEX);

        return response.data;
    } catch (e) {
        // TODO: add sentry log
        return false;
    }
};

const doSearchPath = async (searchCoordinates) => {
    const response = await axios.get(api_paths.GRAPH_API_SEARCH_PATH, {params: searchCoordinates});

    return response.data;
};

const groupByRouteId = (pathList, previousElement = null, bag = []) => {
    if (!pathList.length) {
        return bag;
    }

    const arrCopy = Array.from(pathList);
    const element = arrCopy.shift();

    const sameRouteId = previousElement && (previousElement.route_id === element.route_id);
    const chunk = sameRouteId ? bag.pop() : [];

    // without this the resulting polyline will appear disconnected
    // hence we need to include the current element (the connection to the previous chunk)
    // to make it appear that the group is connected
    // comment this block of code to see what I'm talking about
    const addConnectingIntersection = !sameRouteId && previousElement;
    if (addConnectingIntersection) {
        const prevChunk = bag.pop();
        const elementCopy = Object.assign({}, element);
        elementCopy.connecting_intersection = true;

        prevChunk.push(elementCopy);
        bag.push(prevChunk);
    }

    chunk.push(element);
    bag.push(chunk);

    return groupByRouteId(arrCopy, element, bag);
};

const segmentColors = [
    [5, 45, 62],
    [166, 51, 5],
    [244, 193, 39],
    [77, 155, 166],
    [216, 125, 15],
];

const getSegmentColor = (segmentPosition, opacity = 1) => {
    const segmentColor = segmentColors[segmentPosition];
    const [red, green, blue] = segmentColor;

    return `rgba(${red}, ${green}, ${blue}, ${opacity})`;
};

export default {
    name: "AppIndexRoute",
    components: {
        "google-map": Map,
        "google-map-circle": Circle,
        "google-map-polyline": Polyline,
        "google-map-marker": Marker,
        "route-select-dialog": RouteSelectDialog,
        "toggle-button": ToggleButton,
        "search-route-select": SearchRouteSelect
    },
    data() {
        return {
            app_logo: APP_LOGO,
            currentRoute: null,
            routePath: [],
            routes: [],
            routesMap: {},
            showSelectRouteDialog: false,
            debugIntersections: [],
            clickedCoordinatesStack: [],
            searchPathSegments: [],
        };
    },
    computed: {
        searchFromCoordinate() {
            return this.clickedCoordinatesStack[0] || {};
        },
        searchToCoordinate() {
            return this.clickedCoordinatesStack[1] || {};
        },
        routeSegmentsDisplay() {
            return this.searchPathSegments.map((segment) => {
                return this.routesMap[segment.id];
            });
        }
    },
    async mounted() {
        const routes = await getRoutes();

        this.routes = routes || [];
        this.routesMap = this.routes.reduce((accumulator, route) => {
            accumulator[route.id] = route;

            return accumulator;
        }, {});
    },
    methods: {
        getSegmentColor,
        routeSelect() {
            this.showSelectRouteDialog = true;
        },
        closeSelectRouteDialog() {
            this.showSelectRouteDialog = false;
        },
        async routeSelected(route) {
            this.currentRoute = route;

            const routeDetails = await getRoute(route.id);
            if (routeDetails) {
                const snapToRoadPoints = await snapToRoads(routeDetails.intersections);

                this.routePath = snapToRoadPoints;
            } else {
                this.routePath = [];
            }
            
            this.closeSelectRouteDialog();
        },
        async debugOnShowIntersections() {
            if (this.debugShowIntersections) {
                this.debugIntersections = [];
                this.debugShowIntersections = false;
            } else {
                const result = await getIntersections();
                if (!result.success) {
                    alert("Could not fetch intersections at this time."); // TODO: use something beautiful
                    return false;
                }
        
                this.debugIntersections = result.intersections;
                this.debugShowIntersections = true;
            }
        },
        mapClick({latLng}) {
            const coordinate = { lat: latLng.lat(), lng: latLng.lng() };
            const stackLimit = 2;
            this.clickedCoordinatesStack.push(coordinate);

            if (this.clickedCoordinatesStack.length > stackLimit) {
                this.clickedCoordinatesStack = this.clickedCoordinatesStack.splice(1);
            }
        },
        async searchPath() {
            this.searchPathSegments = [];
            const params = {
                from: this.searchFromCoordinate,
                to: this.searchToCoordinate
            };
            const response = await doSearchPath(params);

            if (response.exist) {
                const grouped = groupByRouteId(response.path);

                for (let group of grouped) {
                    let groupMetadata = {
                        id: group[0].route_id,
                        group: group,
                        path: await snapToRoads(group)
                    };

                    this.searchPathSegments.push(groupMetadata);
                }
            }
        },
        isObjectEmpty(value) {
            return isEmpty(value);
        }
    }
}
</script>

<style lang="scss" scoped>
    .route-segment {
        border-left: transparent 4px solid;
        padding: 10px 0 10px 6px;
        margin-bottom: 5px;
    }
</style>