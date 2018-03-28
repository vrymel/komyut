# Important
* "vue-brunch" must be declared first before "babel-brunch" this is a frustrating feature of brunch! [Read more](http://brunch.io/docs/using-plugins#order-of-execution)
   * Until the [feature](https://github.com/brunch/brunch/issues/1377) to define the plugin order of execution is implemented, we have to remember this package.json order dependency.
   * We need to do this so "babel-polyfill" will work.