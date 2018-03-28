// we alias PAGE_ROUTES here which is defined globally, usually i define
// it on the page view template
// we alias it so we don't have ugly eslint global rules on each file that
// uses the PAGE_ROUTES global
// TODO: make a mix task that compiles phoenix paths to a javascript module
//       so we don't need to do this alias


/* global PAGE_ROUTES */
export default PAGE_ROUTES;