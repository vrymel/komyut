<template>
  <div 
    class="app-index-route"
    :class="{ 'full-map': !showSidebar }">
    <div 
    class="map-container">
      <google-map
        @click="mapClick"
        :center="mapCenter"
        :zoom="mapZoom">
        <route-path-display 
          v-if="!showAllRoutes"
          :route="currentRoute" />
        <div v-if="showAllRoutes">
          <route-path-display
            v-for="(r, index) in allRoutes"
            :show-path-animation="false"
            :key="index"
            :route="r" />
        </div>

        <google-map-polyline
          v-if="focusOnSegmentIndex !== null"
          :name="'focusSearchPathSegment'"
          :path="searchPathSegments[focusOnSegmentIndex].path"
          :stroke-color="getSegmentColor(focusOnSegmentIndex)" />
        <google-map-polyline
          v-else
          v-for="(segment, index) in searchPathSegments"
          :key="segment.id + '' + index"
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

    <div class="mobile-menu-toggle">
      <div @click="toggleSidebar">
        <i class="fa fa-search"/>
      </div>
    </div>

    <modal
      v-if="showAlert"
      :visible="showAlert"
      @modal-hidden="alertHidden">
      <modal-header>
        <h5 class="modal-title">Oh, bummer!</h5>
      </modal-header>
      <modal-body>
        <p>{{ alertMessage }}</p>
      </modal-body>

      <modal-footer>
        <button
          class="btn btn-primary" 
          data-dismiss="modal">Okay</button>
      </modal-footer>
    </modal>

    <div 
    class="sidebar">
      <div class="m-2 card">
        <div 
          class="show-route-accessible-roads card-body"
          :class="{ 'active': showAllRoutes }"
          @click="toggleShowAllRoutes">
          <div class="card-text">
            <i class="fa fa-check"/>
            Show jeepney route accessible roads
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
              class="card-text description"
              v-if="currentRoute">
              <span>{{ currentRoute.description }}</span>
              <button 
                class="btn btn-link"
                @click.stop="clearRouteSelected">Clear</button>
            </div>
            <div 
              v-else
              class="card-text no-route-selected">No route selected</div>
          </div>
        </div>
      </div>

      <div class="m-2 card search-route">
        <div class="card-body">
          <h6 
            v-show="!showSearchResult" 
            class="card-title">Search route</h6>
          <div
          v-show="showSearchResult">
            <h6 class="card-title">
              <a 
                href="#" 
                @click.prevent="backToSearch">
                <i class="fa fa-chevron-left"/>
                Search result
              </a>
            </h6>
            <span class="card-subtitle">Route sequence</span>
          </div>
          
          <search-route-select 
            v-show="!showSearchResult"
            :from-address="searchFromCoordinate"
            :to-address="searchToCoordinate" />
          
          <div 
            v-show="showSearchResult"
            class="search-route-results"
            :class="{ 'has-focused': focusOnSegmentIndex !== null }">
            <div 
              class="route-segment"
              v-for="(routeSegment, index) in routeSegmentsDisplay"
              :class="{ 'focused': index === focusOnSegmentIndex }"
              @click="segmentFocus(index)"
              :key="routeSegment.id + '' + index"
              :style="{ borderColor: getSegmentColor(index), backgroundColor: getSegmentColor(index, 0.4) }"
            >
              <span class="description">{{ routeSegment.description }}</span>
              <i class="fa fa-eye"/>
            </div>
          </div>

          <div 
            v-show="!showSearchResult"
            class="card-block mt-4">
            <button 
              class="btn btn-primary"
              @click="searchPath">
              <i class="fa fa-search"/>
            Search</button>
            <button
              class="btn btn-link"
              @click="clearSearchCoordinatesStack"
            >
            Clear</button>
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
import { isEmpty, assign, memoize } from "lodash";

import api_paths from "../api_paths";
import { APP_LOGO } from "../globals";
import { snapToRoads } from "../services";

import RoutePathDisplay from "./RoutePathDisplay";
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

const doGetRoute = async (routeId) => {
    try {
        const result = await axios.get(`${api_paths.ROUTE_API_INDEX}/${routeId}`);

        return result.data;
    } catch (e) {
        // TODO: add sentry log
        return false;
    }
};
const getRoute = memoize(doGetRoute);

const getRouteDetails = async (route) => {
    const routeDetails = await getRoute(route.id);
    if (routeDetails) {
        const snapToRoadPoints = await snapToRoads(routeDetails.intersections);
        const routeInfo = {
            path: snapToRoadPoints,
            intersections: routeDetails.intersections
        };

        return assign({}, route, routeInfo);
    }

    return null;
};

const preloadRouteDetails = async (routes) => {
    const store = [];

    for (let r of routes) {
        let routeDetails = await getRouteDetails(r);

        store.push(routeDetails);
    }

    return store;
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
    [10, 58, 130],
    [204, 34, 159],
    [216, 125, 15],
    [245, 91, 89],
    [77, 155, 166],
    [5, 45, 62],
    [166, 51, 5],
    [244, 193, 39],
];

const getSegmentColor = (segmentPosition, opacity = 1) => {
    // handle overflow segmentPosition
    const segmentPositionOverflow = segmentPosition >= segmentColors.length;
    if (segmentPositionOverflow) {
        return getSegmentColor(segmentPosition - segmentColors.length, opacity);
    }

    const segmentColor = segmentColors[segmentPosition];
    const [red, green, blue] = segmentColor;

    return `rgba(${red}, ${green}, ${blue}, ${opacity})`;
};

export default {
    name: "AppIndexRoute",
    components: {
        "route-select-dialog": RouteSelectDialog,
        "search-route-select": SearchRouteSelect,
        "route-path-display": RoutePathDisplay
    },
    data() {
        return {
            app_logo: APP_LOGO,
            currentRoute: null,
            routes: [],
            routesMap: {},
            showSelectRouteDialog: false,
            clickedCoordinatesStack: [],
            searchPathSegments: [],
            showSearchResult: false,
            focusOnSegmentIndex: null,
            showAlert: false,
            showSidebar: true,
            mapZoom: 15,
            allRoutes: [],
            showAllRoutes: true,
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
        },
        mapCenter() {
            if (this.currentRoute) {
                const startIntersection = this.currentRoute.intersections[0];

                if (startIntersection) {
                    return new google.maps.LatLng(startIntersection.lat, startIntersection.lng);
                }
            }

            // this value is just arbitrary
            return new google.maps.LatLng(8.477619, 124.644167);
        }
    },
    async mounted() {
        const routes = await getRoutes();

        this.routes = routes || [];
        this.routesMap = this.routes.reduce((accumulator, route) => {
            accumulator[route.id] = route;

            return accumulator;
        }, {});

        this.allRoutes = await preloadRouteDetails(this.routes);
    },
    methods: {
        getSegmentColor,
        routeSelect() {
            this.showSelectRouteDialog = true;
        },
        clearRouteSelected() {
            this.setCurrentRoute(null);
        },
        closeSelectRouteDialog() {
            this.showSelectRouteDialog = false;
        },
        async setCurrentRoute(route) {
            if (!route) {
                this.currentRoute = null;
                return;
            }

            const routeDetails = await getRouteDetails(route);
            if (routeDetails) {
                this.currentRoute = routeDetails;
            } 
        },
        // route select dialog handler
        routeSelected(route) {
            this.setCurrentRoute(route);
            this.closeSelectRouteDialog();
            this.postRouteSelected();
        },
        postRouteSelected() {
            this.searchPathSegments = [];
            this.showSearchResult = false;
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

                this.showSearchResult = true;
            } else {
                this.showSearchResult = false;

                if (response.nearest_none) {
                    this.showNoNearIntersectionAlert();
                } else {
                    this.showNoRouteAlert();
                }
            }

            this.postSearchPath();
        },
        postSearchPath() {
            this.currentRoute = null;
        },
        clearSearchCoordinatesStack() {
            this.clickedCoordinatesStack = [];
            this.searchPathSegments = [];
        },
        showNoRouteAlert() {
            this.alertMessage = "We could not find a route for the selected locations.";
            this.showAlert = true;
        },
        showNoNearIntersectionAlert() {
            this.alertMessage = "There is no route near the selected locations.";
            this.showAlert = true;
        },
        alertHidden() {
            this.showAlert = false;
            this.alertMessage = null;
        },
        backToSearch() {
            this.showSearchResult = false;
        },
        isObjectEmpty(value) {
            return isEmpty(value);
        },
        segmentFocus(index) {
            const hideIfTheSameIndex = index === this.focusOnSegmentIndex;
            this.focusOnSegmentIndex = hideIfTheSameIndex ? null : index;
        },
        toggleSidebar() {
            this.showSidebar = !this.showSidebar;
        },
        toggleShowAllRoutes() {
            this.showAllRoutes = !this.showAllRoutes;
        }
    }
}
</script>

<style lang="scss" scoped>
    @import "../common/_variables.scss";

    .route-select {
        .description {
            display: flex;
            align-items: center;

            > span {
                flex: 1;
            }

            button {
                padding: 0 5px;
                border-top-width: 0;
                border-bottom-width: 0;
            }
        }
    }

    .search-route-results {
        .route-segment {
            border-left: transparent 4px solid;
            padding: 10px 12px 10px 6px;
            margin-bottom: 5px;
            cursor: pointer;
            display: flex;
            align-items: center;

            .description {
                flex: 1;
            }

            .fa {
                display: none;
            }
        }

        &:hover .route-segment {
            opacity: 0.75;

            &:hover { opacity: 1; }
        }

        &.has-focused .route-segment {
            opacity: 0.75;

            &.focused { 
                opacity: 1; 

                .fa {
                    display: inline-block;
                }
            }
        }
    }

    .map-container {
        transition: height 0.25s linear;
    }

    .sidebar {
        transition: opacity 0.15s linear;
        opacity: 1;

        .show-route-accessible-roads {
            cursor: pointer;
            color: #b9b9b9;

            &.active {
                color: #212529;
            }
        }
    }

    .mobile-menu-toggle {
        display: none;
        position: fixed;
        right: 10px;
        top: 50px;
        background-color: $primaryColor;
        color: white;
        padding: 15px 19px;
        border-radius: 28px;
    }


	@media (max-width: 800px) {
        .app-index-route {
            flex-direction: column;

            .map-container {
                height: 70vh;
            }

            &.full-map {
                .map-container {
                    height: 100vh;
                }

                .sidebar {
                    height: 0;
                    opacity: 0;
                }
            }

            .mobile-menu-toggle {
                display: block;
            }

            .sidebar {
                height: auto;

                .card.search-route {
                    flex: 1;

                    .card-body {
                        flex-direction: row;
                    }
                }
            }
        }
    }
</style>