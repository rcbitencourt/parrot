'use strict';

var gulp = require('gulp'),
    coffee = require('gulp-coffee'),
    gutil = require('gulp-util'),
    nodemon = require('gulp-nodemon'),
    coffeeSrc = './{server,client}/**/*.coffee';

gulp.task('coffee', function() {

  gulp.src( coffeeSrc )
    .pipe( coffee({sourceMap: true}).on('error', gutil.log) )
    .pipe( gulp.dest('build') );
});

gulp.task('default', ['coffee'], function() {

  var watcher = gulp.watch(coffeeSrc, ['coffee']);

  watcher.on('change', function(e) {
    gutil.log('File ' + e.path + ' was ' + e.type + ', building again...');
  });

  nodemon({ script: 'build/server/index.js', ext: 'js' });
});