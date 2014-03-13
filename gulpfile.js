'use strict';

var gulp = require('gulp'),
    coffee = require('gulp-coffee'),
    gutil = require('gulp-util'),
    nodemon = require('gulp-nodemon'),
    coffeeSrc = './{server,client}/**/*.coffee',
    templatesSrc = './client/views/*.html',
    styleSrc = './client/styles/*.css';

gulp.task('coffee', function() {

  gulp.src( coffeeSrc )
    .pipe( coffee({sourceMap: true}).on('error', gutil.log) )
    .pipe( gulp.dest('build') );
});

gulp.task('html', function() {

  gulp.src( '*.html' )
    .pipe( gulp.dest('build/client') );

  gulp.src( templatesSrc )
    .pipe( gulp.dest('build/client/views') );

  // TODO: Remove later, change to other plugin
  gulp.src( 'bower_components/**/*' )
    .pipe( gulp.dest('build/client/bower_components') );
});

gulp.task('style', function() {

  gulp.src( styleSrc )
    .pipe( gulp.dest('build/client/styles') );
});

gulp.task('build', ['coffee', 'html', 'style']);

gulp.task('default', ['build'], function() {

  var watcher = gulp.watch([coffeeSrc, templatesSrc, styleSrc], ['build']);

  watcher.on('change', function(e) {
    gutil.log('File ' + e.path + ' was ' + e.type + ', building again...');
  });

  nodemon({ script: 'build/server/index.js', ext: 'js', watch: ['build/server'] });
});