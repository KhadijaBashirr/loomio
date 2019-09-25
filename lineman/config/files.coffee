module.exports = require(process.env["LINEMAN_MAIN"]).config.extend "files",
  ngtemplates:
    dest: "generated/angular/template-cache.js"

  css:
    app: ['app/css/main.css']
    vendor: ['vendor/bower_components/ionicons/css/iconicons.css',
             'vendor/bower_components/font-awesome/css/font-awesome.css',
             'vendor/bower_components/angular-bootstrap-datetimepicker/src/css/datetimepicker.css']

  js:
    vendor: ["vendor/bower_components/lodash/dist/lodash.js",
             "vendor/bower_components/moment/moment.js",
             "vendor/bower_components/jquery/dist/jquery.js",
             "vendor/bower_components/angular/angular.js",
             "vendor/bower_components/angular-route/angular-route.js",
             "vendor/bower_components/angular-cache/dist/angular-cache.js",
             "vendor/bower_components/angular-bootstrap-datetimepicker/src/js/datetimepicker.js",
             "vendor/bower_components/d3/d3.js",
             "vendor/bower_components/angular-translate/angular-translate.js",
             "vendor/bower_components/angular-translate-loader-url/angular-translate-loader-url.js",
             "vendor/bower_components/Chart.js/Chart.js",
             "vendor/bower_components/tc-angular-chartjs/dist/tc-angular-chartjs.js"
             "vendor/js/private_pub.js"]

    app: ["app/js/app.js"
          "app/js/**/*.js"]

  webfonts:
    root: 'webfonts'
