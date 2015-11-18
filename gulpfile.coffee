# gulp packages
gulp       = require 'gulp'
coffeelint = require 'gulp-coffeelint'
mocha      = require 'gulp-mocha'
# npm packages
stylish    = require 'coffeelint-stylish'

gulp.task 'lint', () ->
  gulp.src './libs/*.coffee'
    .pipe coffeelint()
    .pipe coffeelint.reporter stylish

  gulp.src './src/*.coffee'
    .pipe coffeelint()
    .pipe coffeelint.reporter stylish

gulp.task 'mocha', () ->
  gulp.src './tests/*-test.coffee'
    .pipe mocha()

gulp.task 'test', ['lint', 'mocha']
