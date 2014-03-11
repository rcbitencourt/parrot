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

gulp.task('html', function() {

  gulp.src( '*.html' )
    .pipe( gulp.dest('build/client') );

  gulp.src( './client/views/*.html' )
    .pipe( gulp.dest('build/client/views') );

  // TODO: Remove later, change to other plugin
  gulp.src( 'bower_components/**/*' )
    .pipe( gulp.dest('build/client/bower_components') );
});

gulp.task('build', ['coffee', 'html']);

gulp.task('default', ['build'], function() {

  var watcher = gulp.watch(coffeeSrc, ['build']);

  watcher.on('change', function(e) {
    gutil.log('File ' + e.path + ' was ' + e.type + ', building again...');
  });

  nodemon({ script: 'build/server/index.js', ext: 'js' });
});