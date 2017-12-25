import { first, last, slice } from "lodash/fp"

const origin = (waypoints) => {
    return first(waypoints)
}

const destination = (waypoints) => {
    return last(waypoints)
}

const between = (waypoints) => {
    if (waypoints.length <= 2)
        return []
    
    return slice(1, waypoints.length - 1)(waypoints)
}

export { origin, destination, between }